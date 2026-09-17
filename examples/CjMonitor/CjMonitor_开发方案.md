# CjMonitor —— 系统监控台（CJQT6 性能与实时性压测项目）

> 定位：**压力验证**。高频采样 + 实时渲染 + 长时间运行，用来压出 CJQT6 在**性能、生命周期、跨进程**三方面的真实表现。
> 与 CjDash 的分工：CjDash 验"广度"（模块覆盖），CjMonitor 验"深度"（跑得快不快、久不久）。

> ⚠️ **本文档写于实现之前，其中的 API 示例已过期，请以仓库源码为准**（2026-09-18 补注）
>
> 下列写法在 **CJQT6 1.9.0 中并不存在**，照抄会直接编译失败：
> `import cjqt6.process.*`、`import cjqt6.datetime.*`、`QColor.rgb(...)`、`TextAlignment.AlignLeft`、
> `QChartView.fromChart(...)`、`QChart.addSeries(ptr)` 通用重载、`QLineSeries.setColor/setPen/clear`、
> `QDateTime.toMSecsSinceEpoch(...)`、`Toast.show(...)`、`QSqlQuery.addBindValue(...)`、
> `db.transaction()` / `db.commit()`、`QLabel.setMinimumWidth/setFixedWidth`、
> `QMainWindow.setWindowTitle(...)`、`QApplication.setStyleSheet(...)`。
>
> - 逐条对照表（写法人 ↔ 真实接口）：`docs/internal/cjmonitor-findings.md` 第 4 节
> - 实际可运行代码：本目录 `src/`（唯一权威实现）
> - 权威 API 速查：`docs/api/` 与 `.agents/skills/cjqt6/SKILL.md`

---

## 一、为什么是它：与官方已有示例的差异化

| 已有示例 | 已覆盖 | CjMonitor 的差异 |
|---|---|---|
| `analog_clock` | QTimer 1s + 自绘 | **100ms 高频** + 多通道 + 环形缓冲 |
| `chart_demo` | 静态图表 | **实时流式追加** + 性能对比（自绘 vs charts） |
| `snake_game` / `tank_battle` | 逐帧自绘 | 但数据是人造的；这里处理**真实外部数据** |
| `all_controls_demo` | 控件全览 | 控件只是容器，重点在**数据管道** |

**CjMonitor 独占的验证组合**：`core(QTimer 高频)` × `process(QProcess 跨进程采集)` × `paint(逐帧自绘)` × `sql(降采样落库)` × `datetime(时间轴)`。

> 特别说明：**`process` 和 `datetime` 两个模块在 docs/api 里有文档（09、10），但官方示例中几乎没被使用**——CjMonitor 正好补上这块验证空白。

---

## 二、能力矩阵

| 子包 | 职责 | 压测/验证点 |
|---|---|---|
| `core` | QTimer 100ms 驱动、事件循环、存活表 | **高频回调开销**、事件循环是否被阻塞 |
| `process` | QProcess 调系统命令采集指标 | 跨进程 IO、异步输出、进程回收 |
| `paint` | QPainter 逐帧自绘实时曲线 | **渲染帧率与 CPU 占用** |
| `widgets` | QMainWindow / QTabWidget / QPushButton | 嵌套布局下的刷新抖动 |
| `gui` | QSplitter / 布局 / QFont | 弹性布局 |
| `views` | QTableWidget 进程列表 | 高频刷新表格是否卡顿 |
| `sql` | 降采样落库 + 历史查询 | **写放大**与批量事务 |
| `charts` | 历史区间对比图（低频） | 与自绘方案的**性能对照** |
| `datetime` | QDateTime 时间轴格式化 | 时间戳 ↔ 显示串转换 |
| `print` | 导出"巡检报告" PDF | 报告版式 |
| `multimedia` | 阈值告警提示音 | 短音频重复播放 |
| `richwidgets` | Toast / Badge | 高频 Toast 是否堆积 |
| `resource` | QSS 深色主题 + SVG | 深色仪表盘风格 |
| `menu` / `dialogs` | 阈值设置 / 导出对话框 | 交互完整性 |

---

## 三、数据采集方案（跨平台）

采集是这个项目的地基。CJQT6 未封装系统 API，所以走 **QProcess 调系统命令**——这恰好把 `process` 模块压了一遍。

| 平台 | CPU | 内存 | 网络 | 磁盘 |
|---|---|---|---|---|
| Linux | `/proc/stat` | `/proc/meminfo` | `/proc/net/dev` | `/proc/diskstats` |
| Windows | `typeperf` / PowerShell `Get-Counter` | 同上 | 同上 | 同上 |
| macOS | `top -l 1 -n 0` | `vm_stat` | `netstat -ib` | `iostat` |

> Linux 下优先**直接读 /proc 文件**（开销极低，100ms 采样无压力）；Windows/macOS 用 QProcess。
> 两条路都实现，等于同时验证了「文件 IO 路径」和「QProcess 路径」。

### CPU 使用率计算（Linux /proc/stat 差值法）

```
两次采样之间：
  total_delta = Σ(user, nice, system, idle, iowait, irq, softirq, steal) 之差
  idle_delta  = Σ(idle, iowait) 之差
  cpu_usage   = 1 - idle_delta / total_delta
```

**注意**：首次采样无基线，必须丢弃第一帧，否则首帧永远是 0 或 100%。这是新手最常见的 bug。

---

## 四、核心设计：环形缓冲区（性能关键）

高频采样最忌讳每帧新建数组——GC 抖动会让曲线肉眼可见地卡顿。用固定容量环形缓冲：

```cangjie
// 固定容量，预分配，运行时零分配
public class RingBuffer {
    private let cap: Int64
    private var buf: Array<Float64>
    private var head: Int64 = 0      // 写入位置
    private var count: Int64 = 0     // 已填数量

    public init(cap: Int64) {
        this.cap = cap
        this.buf = Array<Float64>(cap, repeat: 0.0)
    }

    public func push(v: Float64): Unit {
        buf[head] = v
        head = (head + 1) % cap
        if (count < cap) { count += 1 }
    }

    // 按时间顺序取第 i 个（最老 → 最新）
    public func at(i: Int64): Float64 {
        let start = if (count < cap) { 0 } else { head }
        return buf[(start + i) % cap]
    }

    public func size(): Int64 { count }
}
```

**为什么重要**：100ms × 4 通道 × 600 点（1 分钟窗口），若每帧重建数组，一分钟产生 2400 次分配；环形缓冲把这个数字压到 0。

---

## 五、目录结构

```
CJQT6/examples/CjMonitor/
├── cjpm.toml
├── README.md
├── src/
│   ├── main.cj                   # 入口 + 事件循环
│   ├── app/
│   │   ├── app_state.cj          # ★ 全局持有所有 Qt 对象与缓冲区
│   │   └── theme.cj              # 深色 QSS 主题
│   ├── probe/
│   │   ├── probe.cj              # 采集器接口 + 调度
│   │   ├── probe_linux.cj        # /proc 文件解析
│   │   ├── probe_win.cj          # QProcess + typeperf
│   │   ├── probe_mac.cj          # QProcess + vm_stat / iostat
│   │   └── sample.cj             # Sample 数据结构
│   ├── buffer/
│   │   └── ring_buffer.cj        # 环形缓冲
│   ├── ui/
│   │   ├── main_window.cj        # QMainWindow + QTabWidget
│   │   ├── realtime_tab.cj       # 实时页：多通道自绘曲线
│   │   ├── process_tab.cj        # 进程列表（QTableWidget）
│   │   ├── history_tab.cj        # 历史对比（charts）
│   │   ├── gauge_widget.cj       # ★ 自绘圆形仪表
│   │   └── threshold_dialog.cj   # 阈值设置
│   ├── store/
│   │   └── db.cj                 # 降采样落库 + 查询
│   ├── alert/
│   │   └── alerter.cj            # 阈值判定 + 提示音 + Toast
│   ├── report/
│   │   └── pdf_report.cj         # 巡检报告 PDF
│   └── res/
│       ├── monitor.qss
│       └── icons/*.svg
└── scripts/
    ├── run_debug.ps1
    └── run.sh
```

---

## 六、里程碑与关键实现

### M1 采集层（core / process）

目标：100ms 稳定出数，先把数据通路打通，不做界面。

```cangjie
import cjqt6.core.*
import cjqt6.process.*

// 全局持有：定时器与进程对象一旦被 GC，整个采集链就断了
var gTimer: Option<QTimer> = Option<QTimer>.None
var gProc:  Option<QProcess> = Option<QProcess>.None

@C func onProbeOutput(): Unit {
    // 从 QProcess 读标准输出，解析成 Sample
    let raw = gProc.getOrThrow().readAllStandardOutput().toString()
    let s = parseSample(raw)
    gBuffers.cpu.push(s.cpu)
    gBuffers.mem.push(s.mem)
    triggerRepaint()          // 请求重绘（不要在这里直接画）
}

func startProbe(intervalMs: Int64): Unit {
    let proc = QProcess()
    proc.setProgram("typeperf")                       // Windows 示例
    proc.setArguments(["\\Processor(_Total)\\% Processor Time", "-si", "1"])
    proc.onReadyReadStandardOutput(onProbeOutput)
    proc.start()
    gProc = Some(proc)        // ★ 必须存进全局

    let timer = QTimer()
    timer.setInterval(intervalMs)
    timer.setOnTimeoutCapture({ => tickProbe() })
    timer.start()
    gTimer = Some(timer)      // ★ 必须存进全局
}
```

**验收**：`println` 打出 100 组采样，间隔误差 < 20ms；QProcess 退出后无僵尸。

---

### M2 实时自绘曲线（paint）

本项目性能核心。用 `QEventWidget` + `QPainter` 逐帧绘制：

```cangjie
import cjqt6.paint.*
import cjqt6.datetime.*

@C func paintRealtime(widgetPtr: Int64, painterPtr: Int64): Unit {
    let painter = QPainter.fromPtr(painterPtr)
    painter.setRenderHint(RenderHint.Antialiasing.value)

    let w = widgetWidth(widgetPtr)
    let h = widgetHeight(widgetPtr)

    // 背景
    painter.setPenColor(QColor.rgba(0, 0, 0, 0))
    painter.setBrushColor(QColor.rgb(24, 26, 32))
    painter.drawRect(0, 0, w, h)

    // 网格：横向 4 条
    painter.setPenColor(QColor.rgba(255, 255, 255, 40))
    for (i in 1..4) {
        let y = h * i / 4
        painter.drawLine(0, y, w, y)
    }

    // 曲线：从环形缓冲取点，零分配
    let n = gBuffers.cpu.size()
    if (n >= 2) {
        painter.setPenColor(QColor.rgb(0, 217, 181))
        let step = Float64(w) / Float64(n - 1)
        for (i in 0..(n - 1)) {
            let x1 = Int32(Float64(i) * step)
            let y1 = Int32(h - gBuffers.cpu.at(i) / 100.0 * Float64(h))
            let x2 = Int32(Float64(i + 1) * step)
            let y2 = Int32(h - gBuffers.cpu.at(i + 1) / 100.0 * Float64(h))
            painter.drawLine(x1, y1, x2, y2)
        }
    }

    // 时间轴标签
    let font = QFont("Microsoft YaHei UI", 10)
    painter.setFont(font)
    painter.setPenColor(QColor.rgba(255, 255, 255, 160))
    let now = QDateTime.currentDateTime()
    painter.drawTextRect(8, h - 24, 160, 18,
                         TextAlignment.AlignLeft.value,
                         now.toString("HH:mm:ss"))

    painter.close()          // ★ 每帧一个 QPainter，不 close 就是稳定泄漏
}

public func createRealtimeView(): QEventWidget {
    let w = QEventWidget()
    w.setOnPaint(paintRealtime)
    w.setMinimumSize(600, 200)
    return w
}
```

**关键性能红线**：
- `QPainter` 每帧创建 → **必须每帧 `close()`**，这是全项目最容易泄漏的点
- 绘制循环的 step 用 `Float64` 预计算，避免循环内重复除法
- 抗锯齿开销大：曲线 `Antialiasing` 可开，文字 `TextAntialiasing` 在高频下建议关掉

**验收**：600 点曲线稳定 10 FPS 以上；CPU 占用 < 3%（单核）。

---

### M3 多通道仪表盘 + 进程表（widgets / gui / views）

```cangjie
import cjqt6.widgets.*
import cjqt6.views.*

// 顶部：4 个自绘圆形仪表（CPU / 内存 / 磁盘 / 网络）
let gaugeRow = QHBoxLayout()
for (ch in ["CPU", "MEM", "DISK", "NET"]) {
    let g = createGauge(ch)                 // 同样是 QEventWidget 自绘
    gaugeRow.addWidget(g.getPtr())
}

// 中部：实时曲线
let curve = createRealtimeView()

// 底部：进程表（高频刷新，注意节流）
let procTable = QTableWidget()
procTable.setColumnCount(4)
procTable.setHorizontalHeaderLabels(["PID", "名称", "CPU%", "内存"])

let root = QVBoxLayout()
root.addLayout(gaugeRow.getPtr())
root.addWidget(curve.getPtr(), 3)           // 曲线占 3 份
root.addWidget(procTable.getPtr(), 2)
```

> **进程表刷新要降频**：曲线 100ms 刷，但进程表 1s 刷一次就够——否则 `setItem` 调用量是曲线的 10 倍，会成为新瓶颈。

**验收**：窗口缩放到 800×600 与 1920×1080 布局都不塌；进程表滚动流畅。

---

### M4 落库与历史对比（sql / charts / print）

```cangjie
import cjqt6.sql.*
import cjqt6.charts.*

// 降采样：100ms 采集，1s 落一次库，写放大降低 10 倍
let DOWNSAMPLE_N = 10
var gTick: Int64 = 0

func onSample(s: Sample): Unit {
    gTick += 1
    if (gTick % DOWNSAMPLE_N != 0) { return }
    gPendingRows.add(s)                      // 攒批
    if (gPendingRows.size >= 60) {           // 60 条 = 1 分钟，批量写
        flushRows(gPendingRows)
        gPendingRows.clear()
    }
}

func flushRows(rows: ArrayList<Sample>): Unit {
    db.transaction()
    let q = QSqlQuery()
    q.prepare("INSERT INTO samples(ts, cpu, mem, disk, net_rx, net_tx) VALUES(?,?,?,?,?,?)")
    for (r in rows) {
        q.addBindValue(r.ts); q.addBindValue(r.cpu)
        q.addBindValue(r.mem); q.addBindValue(r.disk)
        q.addBindValue(r.netRx); q.addBindValue(r.netTx)
        q.exec()
    }
    db.commit()
    q.close()
}
```

历史页用 `charts` 画区间对比（低频，只在切换时间范围时重绘），**并与自绘方案做性能对照**——这是给 CJQT6 提交 issue 时最有说服力的素材。

```cangjie
func buildHistoryChart(rows: Array<Sample>): QChartView {
    let cpuSeries = QLineSeries(); cpuSeries.setName("CPU")
    let memSeries = QLineSeries(); memSeries.setName("内存")
    for (r in rows) {
        cpuSeries.append(Float64(r.ts), r.cpu)
        memSeries.append(Float64(r.ts), r.mem)
    }
    let chart = QChart()
    chart.addSeries(cpuSeries.getPtr())
    chart.addSeries(memSeries.getPtr())
    chart.createDefaultAxes()
    return QChartView.fromChart(chart)
}
```

导出"巡检报告"PDF：一页摘要（峰值、均值、告警次数）+ 一页历史曲线 + 一页进程 TOP10。

---

### M5 告警与压测调优（multimedia / richwidgets）

```cangjie
import cjqt6.multimedia.*
import cjqt6.richwidgets.*

// 连续 3 次超阈值才告警，避免抖动误报
var gBreachCount: Int64 = 0

func checkAlert(s: Sample): Unit {
    if (s.cpu > gThreshold) {
        gBreachCount += 1
        if (gBreachCount == 3) {
            gAlertPlayer.setSource("qrc:/res/alert.wav")
            gAlertPlayer.play()
            showToast("CPU ${s.cpu}% 超过阈值 ${gThreshold}%", ToastType.Warning.value)
        }
    } else {
        gBreachCount = 0
    }
}
```

> Toast 要做**去重节流**：高频采样下同一告警可能每秒触发 10 次，Toast 会堆积成灾。

---

## 七、已知坑位清单

| 坑 | 表现 | 规避 |
|---|---|---|
| **QPainter 每帧泄漏** | 内存持续上涨，几小时后 OOM | 每帧 `painter.close()`，M2 里重点标注 |
| **首帧 CPU 100%** | 首次采样无基线 | 丢弃第一帧，自第二帧起计算差值 |
| **QProcess 变僵尸** | 采样停止但进程还在 | 退出时显式 `proc.close()` / `kill()` |
| **表格刷新拖垮帧率** | 曲线卡成幻灯片 | 进程表降频到 1s，曲线保持 100ms |
| **Toast 堆积** | 告警刷屏 | 同类告警 5 秒内只弹一次 |
| **RingBuffer 索引错乱** | 曲线首尾错位 | `at(i)` 的起点要区分「未满」和「已绕圈」两种状态 |
| **Qt 运行时 PATH** | 启动崩 | 抄 `examples/CjMusic/run_debug.ps1` |
| **对象被 GC** | 定时器跑几十秒后停摆 | 全局 `AppState` 持有 + 显式 `close()` |
| **回调捕获局部变量** | 编译失败 | 顶层 `@C func` + 全局表传上下文 |

---

## 八、压测验收清单（这是本项目的核心 KPI）

| 指标 | 目标 | 测量方法 |
|---|---|---|
| 采样间隔误差 | 100ms ± 20ms | 连续 1000 次打时间戳统计 |
| 曲线帧率 | ≥ 10 FPS（600 点） | 帧计数器 |
| 进程 CPU 占用 | < 5%（单核） | 系统任务管理器对照 |
| **内存 RSS 漂移** | **4 小时 ± 10MB** | 每小时记录一次 RSS |
| QPainter 泄漏 | 0 | 跑 1 小时后对比句柄数 |
| 数据库体积 | 1 小时 < 5MB | 降采样后实测 |
| 长时间稳定性 | 24 小时不崩 | 挂机测试 |
| `cjlint` | 0 告警 | CI |
| 四平台 CI | 全绿 | Win x64 / Linux x64 / Linux ARM64 / macOS arm64 |

---

## 九、给 CJQT6 的反馈价值

做完这个项目，最有价值的产出不是应用本身，而是这几组**可量化的对照数据**：

1. **自绘 vs charts**：同为 600 点曲线，两者的 CPU 占用与帧率差多少 → 决定 charts 该不该用于实时场景
2. **QTimer 高频下限**：100ms / 50ms / 16ms 三档的实际抖动 → 暴露仓颉事件循环与 Qt 的衔接损耗
3. **FFI 调用开销**：单次 `QProcess` + 解析链路的耗时 → 验证官方宣称的"性能损耗低于 5%"
4. **泄漏点地图**：哪几个 API 不显式 `close()` 会持续泄漏

这四条都适合整理成 issue 或评测文章反馈给上游。
