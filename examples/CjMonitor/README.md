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

### 运行时产物

| 文件 | 说明 | 是否入库 |
|---|---|---|
| `cjmonitor_startup.log` | 启动跟踪（每阶段一行，用于定位启动期崩溃；`CJMONITOR_TRACE=0` 关闭） | 否（`*.log` 已忽略） |
| `cjmonitor.db` | 运行期落库（SQLite，1/10 降采样 + 每 60 条批量提交） | 否（`examples/**/*.db` 已忽略） |
| `cjmonitor_report.pdf` | 「文件 → 导出巡检报告」的三页报告 | 否（运行时生成） |
| `cjmonitor_selftest.txt` / `.db` | 自测报告与自测库 | 否 |

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
| 长跑指标 | 4 小时 RSS 漂移、24 小时挂机、600 点帧率与 CPU 占用**尚未测** | 需长跑；测量步骤见 `.agents/skills/cjmonitor/references/acceptance.md` |

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
