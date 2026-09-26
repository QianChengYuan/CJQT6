# CJQT6 示例

本目录是 CJQT6 的示例工程集合，每个子目录都是一个**独立的 cjpm 工程**，通过
`cjqt6 = { path = "../../" }` 依赖仓库根目录的库。

推荐用本目录下的 `run-example.ps1` / `run-example.sh` 运行：**只换一个示例名**，脚本会自动
备好环境（Qt 版本、运行库、桥接库）并完成构建、部署与启动。

---

## 快速开始

### Windows（PowerShell 7+）

```powershell
# 在仓库根目录或 examples 目录下均可
.\examples\run-example.ps1                    # 列出全部可运行示例
.\examples\run-example.ps1 hello_cjqt6        # 构建 + 部署 + 运行
```

### Linux / macOS

```bash
./examples/run-example.sh                     # 列出全部可运行示例
./examples/run-example.sh hello_cjqt6         # 构建 + 运行
```

### 环境要求

| 平台 | 要求 |
|---|---|
| Windows | Qt **6.9.1**（`msvc2022_64`，与 `releases/windows-x64/` 内的桥接库、CI 同 ABI）+ 仓颉 SDK 1.1.0+ |
| Linux | 系统 Qt6（`qt6-base-dev` 等，Ubuntu 24.04 自带 6.4.2）+ 仓颉 SDK 1.1.0+ |
| macOS | Qt 6.x（Apple Silicon）+ 仓颉 SDK 1.1.0+ |

Qt 目录的确定顺序：`-QtDir` 参数 → 环境变量 `QTDIR` → 常见安装路径（优先 `C:\Qt\6.9.1\msvc2022_64`）。

---

## 脚本参数

| 参数（`.ps1`） | 参数（`.sh`） | 说明 |
|---|---|---|
| `<示例名>` | `<示例名>` | 位置参数；可带子目录，如 `qq_chat_lan/server` |
| `-QtDir <路径>` | 环境变量 `QTDIR` | 指定 Qt6 目录 |
| `-SkipBuild` | `-s` / `--skip-build` | 跳过 `cjpm build`（已构建过、只想重新部署运行） |
| `-NoRun` | `-n` / `--no-run` | 只构建 + 部署，不启动程序 |
| （不带参数） | （不带参数） | 列出全部可运行示例 |

脚本内部按 5 步执行：**选 Qt 并剔除其它版本 → 桥接库 ABI 自检 → 清理陈旧示例缓存 →
`cjpm build` + 部署运行时 → `cjpm run`**。

---

## 示例清单

| 示例 | 简介 | 备注 |
|---|---|---|
| `hello_cjqt6` | 最小演示 | 建议作为第一个跑通的示例 |
| `notepad` | 记事本 | |
| `calculator` | 计算器 | |
| `todo_list` | 待办事项 | |
| `expense_tracker` | 个人记账本 | |
| `dormitory_manager` | 宿舍管理系统（登录 / 权限） | |
| `paint_app` | 画图板 | |
| `analog_clock` | 模拟时钟 | |
| `chart_demo` | Qt Charts 折线图 | |
| `charts_demo` | Qt Charts 全序列 + 极坐标图 | |
| `all_controls_demo` | 全控件演示（侧边栏导航） | 控件覆盖最全 |
| `delegate_demo` | `QStyledItemDelegate` 自绘委托 | |
| `music_player` | 音乐播放器（示例版） | |
| `CjMusic` | 完整桌面音乐播放器 | 额外依赖中心仓 `lrc4cj`，首次构建需联网 |
| `snake_game` | 贪吃蛇 | |
| `tank_battle` | 坦克大战 | |
| `signal_smoke` | 信号桥接无头冒烟测试 | 无窗口，适合 CI / 无显示器环境 |
| `bench` | 信号 / FFI 性能基准 | 控制台输出 |
| `ui2cj_demo` | Qt Designer `.ui` → 仓颉脚手架 | 需要 `tools/ui2cj` |
| `CjMonitor` | 系统监控台（性能与实时性压测项目） | 有自己的 README 与规则集 |

**子目录工程**：`qq_chat_lan/server`（先启动服务端）、`qq_chat_lan/client`。
**非工程目录**：`resource/`（素材）、`CjDash/`（方案文档，无 cjpm 工程）。

---

## 脚本替你处理了哪些坑

1. **`CJQT6_ROOT` 指向当前仓库**。示例与根库的链接路径都依赖这个变量；若它指向另一份克隆
   （很常见：环境变量是之前配的），就会出现「改的是 A 仓库、跑的是 B 仓库产物」的怪象。
2. **Qt 版本对齐**。桥接库 `cjqt6_bridge.dll` 是按 **Qt 6.9.1** 编译的，运行时会加载 PATH 里
   最先命中的 `Qt6Core.dll`。若 PATH 里优先命中别的版本（如 6.10.3），加载期就会失败。
   脚本会把选定 Qt 提到 PATH 最前、并把其它 `\Qt\6.*` 目录从 PATH 中剔除。
3. **ABI 自检**。启动前比对桥接库需要的 Qt 符号与本机 `Qt6Core.dll` 实际导出的符号，
   不匹配直接给出可读报错，而不是让程序在启动时弹一个看不懂的对话框。
4. **运行时自包含**。构建后把 Qt 运行时 DLL、平台插件、MSVC 运行库、`cjqt6` 依赖与桥接库
   统一部署到 exe 同目录（`target/release/bin`）—— Windows 的 DLL 搜索顺序中 **exe 同目录优先**，
   这样即便 PATH 里有别的 Qt 也不会被误加载。
5. **陈旧示例缓存**。库的对外形态变更后，示例的 `target/` 缓存可能只被「重新链接」而不重编，
   导致链接期报 `undefined symbol: …cjqt6.core…`；脚本会在构建前自动判定并清理。

---

## 常见问题

### 1. 弹窗：`无法定位程序输入点 ?registerTimer@QEventDispatcherWin32@@… 于动态链接库 …cjqt6_bridge.dll 上`

**原因**：Qt 版本与桥接库的 ABI 不匹配。桥接库由 Qt 6.9.1 编译，而运行时加载了别的版本
（典型是 PATH 里只有 `C:\Qt\6.10.3\msvc2022_64\bin`）。Qt 6.9 → 6.10 之间
`QEventDispatcherWin32::registerTimer` 的签名从 `(int, qint64, Qt::TimerType, QObject*)`
改成了 `Qt::TimerId` + `std::chrono` 形态，符号对不上，Windows 在**加载期**就报「找不到入口」。

**解决**（任选其一）：

```powershell
# 1) 用脚本跑（会自动选定 6.9.1 并剔除其它 Qt 版本）
.\examples\run-example.ps1 hello_cjqt6

# 2) 指定 Qt 目录
.\examples\run-example.ps1 hello_cjqt6 -QtDir "C:\Qt\6.9.1\msvc2022_64"

# 3) 手动把 6.9.1 前置（当前会话生效）
. .\scripts\setup-qt-env.ps1
```

> 注意 `setup-qt-env.ps1` 要用**点号加载**（`. .\scripts\...`）才会作用于当前会话；
> 直接执行只影响子进程。
> 另外建议把 `C:\Qt\6.10.3\...\bin` 从系统 PATH 中移除（或卸载），6.9 与 6.10 的 ABI 不兼容。

### 2. 提示缺少某个 `Qt6*.dll`

运行时没有部署完整。用脚本运行（会自动部署），或手动执行：

```powershell
# 先构建，再部署到该示例的 target/release/bin
cd examples\hello_cjqt6; cjpm build
pwsh -File ..\..\scripts\deploy-qt-example.ps1 -ExampleRoot .
```

### 3. `cjpm build` 链接期报 `undefined symbol: _CN10cjqt6.core…` / `undefined symbol: cjqt6.core:…`

示例缓存来自旧版本的库。清掉该示例的 `target/` 后重编即可（脚本会自动做）：

```powershell
.\scripts\clean-example-cache.ps1            # 按 src/ mtime 判定陈旧
.\scripts\clean-example-cache.ps1 -Force     # 无条件清
```

### 4. 无显示器 / CI 环境运行

设置 offscreen 平台插件即可（`signal_smoke`、`bench` 这类无界面示例更适合）：

```powershell
$env:QT_QPA_PLATFORM = "offscreen"
.\examples\run-example.ps1 signal_smoke
```

### 5. `CjMusic` 首次构建很慢 / 需要联网

它额外依赖中心仓的 `lrc4cj`，首次需拉取依赖；离线环境会失败。

### 6. `qq_chat_lan` 直接运行无效

它是 C/S 结构，需先起服务端：

```powershell
.\examples\run-example.ps1 qq_chat_lan/server     # 终端 1
.\examples\run-example.ps1 qq_chat_lan/client     # 终端 2
```

### 7. Linux：窗口打开了，但内容空白（透出后方窗口）

**典型**：运行 `./examples/run-example.sh hello_cjqt6`，窗口标题正常，内容区却什么都不显示——
看起来像透出了后面的其它窗口。

**原因**：本机装了多个 Qt（系统 Qt + 自装 Qt）时，`releases/linux-x64/libcjqt6_bridge.so`
与运行期实际加载的 Qt / 平台插件**不是同一份**。库与插件跨版本混用会让窗口能创建但不渲染。

**自查与修复**：

```bash
source ./scripts/setup-qt-env.sh        # 选定一份 Qt,并把「库 + 插件」一并注入(会打印所选版本)
ldd releases/linux-x64/libcjqt6_bridge.so | grep -i qt6 | head   # 应与 $QTDIR 指向同一份 Qt
```

`run-example.sh` 已内置该检查（不一致时打印警告）。完整排查步骤见
[docs/guides/build-guide.md](../docs/guides/build-guide.md) 的「多 Qt 环境下窗口空白」(5.4.1)。

---

## 不用脚本时的手动步骤

**Windows**

```powershell
. .\scripts\setup-qt-env.ps1                       # 点号加载：配置 Qt 与 CJQT6_ROOT
cd examples\hello_cjqt6
cjpm build
pwsh -File ..\..\scripts\deploy-qt-example.ps1 -ExampleRoot .
cjpm run
```

**Linux / macOS**

```bash
source ./scripts/setup-qt-env.sh                   # 配置 Qt 与 CJQT6_ROOT
cd examples/hello_cjqt6
cjpm build
cjpm run
```

更多构建细节见 [docs/guides/build-guide.md](../docs/guides/build-guide.md)，
桥接库编译见 [scripts/README.md](../scripts/README.md) 与仓库根 [`AGENTS.md`](../AGENTS.md)。
