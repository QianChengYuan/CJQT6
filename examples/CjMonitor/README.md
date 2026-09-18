# CjMonitor —— 系统监控台

CJQT6 的**性能与实时性压测示例**：100ms 高频采样 + 实时自绘渲染 + 长时间挂机运行，用来压出 CJQT6 在**性能、对象生命周期、跨进程**三方面的真实表现。

与其它示例的分工：`analog_clock` 验低频定时器与自绘、`charts_demo` 验静态图表、`all_controls_demo` 验控件覆盖；CjMonitor 验的是**数据管道与帧预算**。

## 能力矩阵

| 子包 | 职责 |
|---|---|
| `cjqt6.core` | `QTimer` 100ms 驱动、`QProcess` 采集、`QEventWidget` 事件、对象存活表 |
| `cjqt6.paint` | `QPainter` 逐帧自绘曲线与仪表 |
| `cjqt6.widgets` / `cjqt6.gui` / `cjqt6.menu` | 主窗口、页签、弹性布局 |
| `cjqt6.views` | 进程表（1s 降频刷新） |
| `cjqt6.sql` | 降采样攒批落库与区间查询 |
| `cjqt6.charts` | 历史区间对照图 |
| `cjqt6.print` | 巡检报告 PDF |
| `cjqt6.richwidgets` | 告警浮动提示 |
| `cjqt6.multimedia` | 阈值告警提示音（资源缺失时静默降级） |
| `cjqt6.dialogs` | 阈值设置对话框 |

## 目录结构

```
examples/CjMonitor/
├── cjpm.toml                 # 独立 cjpm 工程
├── README.md
├── deploy_qt.ps1             # 把 Qt6 运行时 / 插件 / MSVC 运行库 / 桥接库拷入 bin
├── CjMonitor_开发方案.md      # 需求源文档（含指标定义）
├── scripts/
│   ├── run_debug.ps1         # Windows 调试运行
│   └── run.sh                # Linux / macOS 运行
└── src/
    ├── main.cj               # 入口（唯一装配点）
    ├── common/               # RingBuffer / Sample / 统计 / 调色板（叶子包）
    ├── probe/                # 三平台采集
    ├── widget/               # 自绘曲线与仪表
    ├── app/                  # AppState 全局持有 + 主题
    ├── ui/                   # 主窗口与各页签
    ├── store/                # 落库与查询
    ├── alert/                # 阈值判定与告警
    └── report/               # PDF 巡检报告
```

包依赖严格单向（`common` 为叶子，`app` 不依赖 `ui`，`main.cj` 为唯一装配点）。

## 前置条件

- 仓颉工具链 1.1.0（`cjc -v` 可查）
- Qt6（≥6.2）与 CMake（≥3.16）
- **CJQT6 桥接库已构建并部署**到 `releases/windows-x64/`（或对应平台目录）
- 构建前设置环境变量 `CJQT6_ROOT` 指向仓库根（根包 `cjpm.toml` 依赖它做链接路径替换）

## 构建

> 📌 **本项目的 Windows Qt 版本为 6.9.1，与 GitHub CI 一致**。原默认 6.10.3 已**同步降级**至 6.9.1：
> CI 的 `setup-qt` action 用 aqtinstall 安装 6.10.3 时解压失败（`Bad7zFile`），CI 侧先降级，项目侧随之一致
> （详见 `docs/CHANGELOG.md` 与 `docs/guides/qt-version-matrix.md`）。
>
> ⚠ **桥接库必须与运行时 Qt 版本一致**，否则加载期会以 `0xC0000139`（找不到程序入口）秒退。
> `native/build_windows_x64/CMakeCache.txt` 会把 Qt 版本锁住，缓存存在时 `update-bridge.ps1`
> 会跳过 configure。切换 Qt 版本后**必须删掉构建目录重配**：
> ```powershell
> Remove-Item -Recurse -Force native\build_windows_x64
> ```
> 用 `dumpbin /dependents native\build_windows_x64\bin\cjqt6_bridge.dll` 可复核其 Qt 依赖。

```powershell
# 0) 重建桥接库（在仓库根执行；务必让它用与运行时相同的 Qt）
.\scripts\update-bridge.ps1            # 或 -QtDir "C:\Qt\6.9.1\msvc2022_64"

# 1) 构建本示例
cd examples\CjMonitor
$env:CJQT6_ROOT = "<仓库根绝对路径>"
cjpm build
```

## 运行

```powershell
# 1) 先部署运行时（Qt 运行时 / 平台与 sqldrivers 插件 / MSVC 运行库 / 桥接库 / 仓颉运行时）
pwsh -ExecutionPolicy Bypass -File deploy_qt.ps1

# 2) 再启动（脚本会自动定位 Qt、注入 CJQT6_ROOT 与 PATH）
pwsh -ExecutionPolicy Bypass -File scripts\run_debug.ps1
```

```bash
# Linux / macOS
bash scripts/run.sh
```

### 采集自测（无需人工观察，适合 CI/回归）

```powershell
$env:CJMONITOR_SELFTEST = "120"        # 采集 120 组后自动退出
pwsh -File scripts\run_debug.ps1
```

自测结束会在当前目录写出 `cjmonitor_selftest.txt`（可直接读的验收报告）与
`cjmonitor_selftest.db`（落库验证）。**结果落盘而非仅打印**，因为 GUI 进程的 stdout
未必可见。

### 绘制自测（M2 验收，需真实平台）

```powershell
$env:CJMONITOR_PAINT_SELFTEST = "300"   # 驱动 300 帧后自动退出（约 3 秒，会短暂弹窗）
pwsh -File scripts\run_debug.ps1
```

不启动采集，直接向实时页的曲线/仪表注入**合成的 600 点 × 4 通道**数据，以 10ms 间隔
驱动重绘，统计实际帧率并写出 `cjmonitor_paint_selftest.txt`。实测（2026-09-18，
Windows x64 · Qt 6.9.1 · MSVC 2022，窗口 1280×800、曲线画布 1226×428）：

```
曲线帧率   : 99.97 FPS（下限 10.0）        ← M2 目标：≥10 FPS @ 600 点
每帧墙钟   : 10.00ms
绘制瓶颈   : 绘制跟得上驱动（单帧绘制 < 10ms）
结论       : 达标
```

⚠ **必须用真实平台运行**：`QT_QPA_PLATFORM=offscreen` 下控件虽然 `visible=true`、
画布尺寸也正确（实测 1226×428），但 Qt **不派发 `paintEvent`**，自测会得到
「0 绘制帧」的假阴性。离屏平台只适合布局与逻辑校验。

### 界面自测（M3 验收）

```powershell
$env:CJMONITOR_UI_SELFTEST = "10"       # 观察 10 秒后自动退出（会弹窗）
pwsh -File scripts\run_debug.ps1
```

装配与正常运行**完全一致**（采集 + 落库 + 告警 + 主窗口 + 启动采样），额外在
「设计最小尺寸」与「1920×1080」两档下采样关键控件几何、统计进程表 1s 降频与状态栏刷新，
报告写入 `cjmonitor_ui_selftest.txt`。实测（2026-09-18，Windows x64 · Qt 6.9.1 · MSVC 2022）：

```
布局·A [最小 960×640 · 实时页]        窗口 960×694；曲线 906×322 visible=true；仪表 906×120 visible=true
布局·B [全高清 1920×1080 · 进程页可见] 窗口 1920×1080；进程页 1886×922；状态栏 326×16
布局判定 : 不塌（关键控件均非 0 尺寸）
进程表   : tick 10 / 完成轮次 9 / 单轮 last=1ms max=1ms（周期 1000ms）/ 行数 60
状态栏   : 写入 9 次 · "采样=90 间隔=109.3ms 超窗=4 帧率=0FPS 落库=0 空载=0"
结论     : M3 达标
```

三点如实说明：

- **窗口内在高度 694 ≠ 640**：`setMinimumSize(960, 640)` 作用于中央容器，窗口还要加菜单栏与状态栏。M3 原稿写的 **800×600 不可达**，故按设计值 960×640 验收（报告里也标注了这一点）。
- **帧率=0FPS**：最后阶段切到了「进程」页签，实时曲线页隐藏 → 不再派发绘制事件，属预期行为；帧率验收请用上面的绘制自测。
- **隐藏页签不参与布局**：进程页在切换前恒为 Qt 默认 640×480，量尺寸前必须先 `setCurrentIndex` 切过去。

### M4 自测（落库 / 历史 / 报告）

```powershell
$env:CJMONITOR_M4_SELFTEST = "10"       # 观察 10 秒后自动退出（不显示窗口）
pwsh -File scripts\run_debug.ps1
```

装配与正常运行一致但**不显示窗口**（M4 的验收对象是数据通路与报告，布局见界面自测），
结束后写出 `cjmonitor_m4_selftest.txt`，PDF 落在 `cjmonitor_m4_selftest.pdf`。实测
（2026-09-18，Windows x64 · Qt 6.9.1 · MSVC 2022）：

```
采样数     : 92
落库行数   : 9（最近 10 分钟区间）
降采样比   : 10.22（目标 ≈ 10）
区间查询   : 0ms
历史重建   : 已重建图表：9 点，跨度 8s（图表对象每次重建，不复用）
              ｜ CPU 峰值=78.5% 均值=66.3% · 内存 峰值=63.0% 均值=63.0%
数据库体积 : 8192 字节（9 行 → 每行 910 字节）
1 小时外推 : 3272 行 → 2977520 字节（2.84MB，上限 5MB）
PDF        : 37064 字节，页数 3
结论       : M4 达标
```

> 体积外推是**保守上界**：8192 字节里含 SQLite 的固定页开销（首次写入即 4KB 级），
> 按「总字节 ÷ 行数」摊分必然偏高；即便如此 1 小时也只有 2.84MB，故 `<5MB` 结论成立。

### M5 自测（告警 / 主题 / 阈值窗口）

```powershell
$env:CJMONITOR_M5_SELFTEST = "6"       # 观察 6 秒后自动退出（不显示主窗口）
pwsh -File scripts\run_debug.ps1
```

装配与正常运行一致但**不显示主窗口**（阈值窗口会被真实打开一次以验收，属预期），
结束后写出 `cjmonitor_m5_selftest.txt`。验收分两层：**确定性用例**（向判定器喂合成样本，
精确校验去抖/去重语义）与**集成检查**（真实采样是否走通告警链路）。实测
（2026-09-19，Windows x64 · Qt 6.9.1 · MSVC 2022）：

```
[确定性] 连续 3 次才告警（第 1、2 次不触发）: 通过
[确定性] 第 3 次触发                        : 通过
[确定性] 持续超阈不重复触发（精确等值语义）  : 通过
[确定性] 5s 窗口内再次达标被抑制            : 通过
[确定性] 窗口=0 立即再触发 + 阈值 0 禁用通道  : 通过
[确定性] 首次告警不被去重窗口吞掉（哨兵回归）: 通过
[集成] 内存阈值 1.0%，真实采样告警次数 : 1
[集成] 首次告警延迟 : 754ms（3 次采样 ≈ 330ms，≥200ms 即去抖生效）
[集成] 样本数/判定数 : 54 / 54（应相等；附加实例告警数 1）
[集成] 最新样本     : ts=1789749641059 CPU=55.3% MEM=59.0% DISK=79.2% NET=0.0/0.0KB/s
[集成] 告警文本     : 内存 59.0% 超过阈值 1.0
[集成] 告警条文本   : 内存 59.0% 超过阈值 1.0
深色主题   : QSS 6575 字符，命中 #0E1013=true #00D9B5=true
提示音     : res/alert.wav 存在=false（缺失即静默降级，本机已走该路径）
阈值窗口   : 尺寸 460×320，回填值 85.0 / 1.0 / 90.0 / 0.0
结论       : M5 达标
```

要点与如实说明：

- **首版自测的「0 次告警」是真缺陷，不是测试噪声**：`monoMs()` 是**进程相对**时钟
  （`common/clock.cj`），而 `lastFireMs` 初始化为 `0`、去重判断为
  `now - lastFireMs[ch] < toastWindowMs` → **进程启动后第一个 5 秒窗口内的告警全部被当作
  「窗口内重复」丢弃**；又因判定层用精确等值 `breaches == requiredBreaches`，计数此后不再
  回到 3 → 该通道在数值回落到阈值下之前**再也无法告警**（启动初期越界即永久静默）。
  已改为哨兵 `-1`（「从未提示」不受窗口约束），并补了用超大窗口复现该条件的回归用例。
- **持续超阈只告警一次**：判定层是「连续 3 次」**精确等值**触发，数值不回落就不会再次触发；
  5s 窗口作用于「回落至阈值下、再次连续达标」的情形。这是刻意的防刷屏设计，报告据此判定。
- **集成检查的陷阱通道不要选 CPU**：空闲机器 CPU% 常在 0~1% 间抖动，`v >= th` 一回落就把
  连续计数清零，永远凑不满 3 次——那测的是数据波动而非去抖。故用**内存**通道（必然 ≥1%）。
- **判定链路可观测性**：报告同时给出「AppState 样本数 / 判定器已判样本数 / 附加实例告警数」，
  用于区分「未喂到数据」「未达阈值」「回调未接上」三种失败，避免只看到一个 0 无从定位。

### 静态检查（cjlint 门禁）

```powershell
cd examples\CjMonitor
cjlint -f src/ -c .        # -c . ⇒ 使用本工程 config/cjlint_rule_list.json
```

结果：**0 告警，退出码 0**（2026-09-19）。规则集取自仓库根 `config/cjlint_rule_list.json`，
仅额外排除 2 条：`G.VAR.02`（对模块级自测常量、以及 `CFunc` 不能捕获局部变量所强制的顶层全局量
系统性误报）、`G.ITF.04`（`Probe` 以接口注入是刻意设计，改泛型会把类型参数污染到全部调用点），
理由与同步约定见 `config/README.md`。

本轮收敛同时修掉三类**实问题**：

- `G.DCL.02` 19 条 **error**：`common/palette.cj` 的 public 常量缺显式类型标注。
  按 `docs/PUBLISHING.md`，error 级会**阻断打包**，不是风格问题。
- `G.EXP.07` 10 条：比较运算把常量写在左侧（`if (v > m)` → `if (m < v)`），语义等价但可读性差。
- `G.NAM.02` 6 条：文件名未对应其唯一对外可见类型，已重命名为 `gauge_panel.cj`、
  `sample_store.cj`、`linux_probe.cj`、`process_probe.cj`、`threshold_window.cj`、`report_data.cj`
  （另将 `probe_win/probe_mac` 一并改为 `windows_probe.cj`/`mac_probe.cj` 保持同族一致；
  重命名用 `git mv` 保留历史，`ui/` 目录当时尚未纳入版本管理，故直接移动）。

### 运行时产物

| 文件 | 说明 | 是否入库 |
|---|---|---|
| `cjmonitor_startup.log` | 启动跟踪（每阶段一行，用于定位启动期崩溃；`CJMONITOR_TRACE=0` 关闭） | 否（`*.log` 已忽略） |
| `cjmonitor.db` | 运行期落库（SQLite，1/10 降采样 + 每 60 条批量提交） | 否（`examples/**/*.db` 已忽略） |
| `cjmonitor_report.pdf` | 「文件 → 导出巡检报告」的三页报告 | 否（运行时生成） |
| `cjmonitor_selftest.txt` / `.db` | 采集自测报告与自测库 | 否 |
| `cjmonitor_paint_selftest.txt` | 绘制自测报告（M2 帧率） | 否 |
| `cjmonitor_ui_selftest.txt` / `.db` | 界面自测报告（M3 布局/降频/状态栏）与自测库 | 否 |
| `cjmonitor_m4_selftest.txt` / `.pdf` / `.db` | M4 自测报告、巡检报告 PDF 与自测库 | 否 |
| `cjmonitor_m5_selftest.txt` / `.db` | M5 自测报告（告警去抖/去重、主题、阈值窗口）与自测库 | 否 |

## 压测验收指标

| 指标 | 目标 | 测量方法 |
|---|---|---|
| 采样间隔误差 | 100ms ± 20ms | 连续 1000 次采样打时间戳统计 |
| 曲线帧率 | ≥10 FPS（600 点） | 绘制回调内帧计数，每秒输出 |
| 进程 CPU 占用 | <5%（单核） | 系统任务管理器对照 |
| 内存 RSS 漂移 | 4 小时 ±10MB | 每小时记录一次 RSS |
| 绘图对象泄漏 | 0 | 跑 1 小时后对比句柄数 |
| 数据库体积 | 1 小时 <5MB | 降采样后实测 |
| 长时间稳定性 | 24 小时不崩 | 挂机测试，退出后无残留子进程 |

## 已知限制（如实记录，非缺陷隐藏）

| 项 | 现状 | 原因 / 后续 |
|---|---|---|
| Windows 磁盘通道语义 | 取「系统盘已用空间占比」，非磁盘 IO 繁忙度 | 无性能计数器依赖是换取稳定性的代价（计数器类目名在非英文系统会本地化，WMI 单次开销 >100ms）；曲线近似水平线 |
| macOS 采集 | 按 POSIX 工具约定实现（`ps`/`vm_stat`/`netstat`/`df`），**未在 macOS 实机验证** | 开发机为 Windows；首次在 macOS 运行请先单独执行临时目录下的 `cjmonitor_probe.sh` 核对输出 |
| 阈值设置窗口 | 基于 `QWidget` 的独立窗口，非严格模态 `QDialog` | CJQT6 当前未封装通用 `QDialog`（只有 `QMessageBox`/`QFileDialog` 等具体对话框） |
| PDF 报告版式 | 三页固定坐标排版（摘要 / 曲线 / 进程 TOP10） | 按 A4、约 72dpi 逻辑坐标绘制；不同打印机驱动的实际边距可能有差异 |
| 长跑指标 | 4 小时 RSS 漂移、24 小时挂机、**真实采样链路下**的帧率与 CPU 占用尚未测（600 点 × 4 通道的纯绘制帧率已由「绘制自测」测得 **99.97 FPS**） | 需长跑；测量步骤见 `.agents/skills/cjmonitor/references/acceptance.md` |

## ⚠️ 关于 `CjMonitor_开发方案.md`

该文档是**需求与指标的来源**，但其中的代码片段**不可照抄**——它假设了若干不存在的 API（例如 `cjqt6.process` / `cjqt6.datetime` 两个包并不存在；`QColor.rgb`、`TextAlignment.AlignLeft`、`QChartView.fromChart`、`QSqlQuery.addBindValue`、`QSqlDatabase.transaction`、`Toast` 静态方法、`QLabel.setMinimumWidth` 等均不存在）。

编码前请查阅已核实的真实签名清单：

- `.agents/skills/cjqt6-realtime/references/api-cheatsheet.md`
- `.agents/skills/cjqt6-realtime/references/pitfalls.md`
- `.agents/skills/cjqt6/SKILL.md`

## 相关技能（本地，不入版本控制）

| 技能 | 用途 |
|---|---|
| `.agents/skills/cjqt6-realtime/` | 通用方法论：高频采样 + 实时自绘 + 长稳运行的骨架、红线与坑位 |
| `.agents/skills/cjmonitor/` | 本项目专属：模块划分、数据管道、采集矩阵、验收清单与实测记录 |

完整方案设计说明见 `.agents/skills/cjmonitor/references/design.md`。
