﻿# CJQT6 — 仓颉语言的 Qt6 封装库

> 让仓颉语言像 Python 使用 PyQt 一样便捷地开发 Qt6 跨平台 GUI 应用

[![Qt](https://img.shields.io/badge/Qt-6.10.3-blue)](https://www.qt.io/)
[![Cangjie](https://img.shields.io/badge/Cangjie-1.1.0-orange)](https://cangjie-lang.cn/)
[![Version](https://img.shields.io/badge/version-1.7.0-green)](cjpm.toml)
[![License](https://img.shields.io/badge/license-MIT-green)](docs/LICENSE)

CJQT6（版本 1.7.0）是为 [仓颉编程语言](https://cangjie-lang.cn/) 提供的 **Qt6 封装库**：仓颉源码（`src/`）通过 FFI 调用 C++ 桥接动态库（`cjqt6_bridge`，`native/`）包装 Qt6 API。项目采用三层架构（仓颉封装层 → C ABI 桥接层 → Qt6 原生层），在主流桌面平台上提供接近原生的性能与开发体验。

远端仓库在 **GitCode**（`https://gitcode.com/yuan_1992/CJQT6.git`）；GitHub 镜像仓（`QianChengYuan/CJQT6`）挂载 `.github/workflows/ci.yml` 跑三端无人值守 CI（Linux 主仓、Windows 镜像仓）。

> 💡 CJQT6 与 Cangjie-TPC 组织下的 CJQT（Qt5.15 绑定）是**并行关系**——CJQT6 面向 Qt6 新特性，覆盖 QML / Network / SQL / Print 等更完整的模块体系。
>
> 📖 **写任何 cjqt6 代码前先读 [`.agents/skills/cjqt6/SKILL.md`](.agents/skills/cjqt6/SKILL.md)**（随 git 版本化），包含模块地图、API 约定、信号槽写法、内存管理陷阱与常见错误速查。

---

## ✨ 核心特性

- **🚀 接近原生的性能**：C ABI 桥接层零拷贝传递，避免 C++ name mangling，性能损耗低于 5%
- **🛡️ 安全的对象生命周期**：桥接层实现反向失效存活表（`qTrackObject` / `qUntrackObject` / `qIsObjectAlive`），通过 `QObject::destroyed` 信号自动标记级联析构的子对象为失效，彻底解决 double-free / 悬空指针问题
- **🔗 完整的信号槽机制**：复合键 `(ptr, signalId)` + 真 `QObject::disconnect` + 跨线程 `QueuedConnection`，支持自定义信号发射
- **🧩 广泛的模块覆盖**：13 个仓颉子包（core/widgets/gui/dialogs/menu/paint/qml/multimedia/network/sql/views/print/resource），53 个 C++ 桥接源文件
- **✅ 工程化闭环**：34 个测试文件、千余测试用例全通过，代码覆盖率约 79%，`cjcov` 覆盖率门禁已集成
- **🌐 跨平台预编译**：Linux x64 / Windows x64 提供预编译 bridge 库，开箱即用
- **📦 一键门禁**：`scripts/verify_all.ps1` 集成构建 → 测试 → 覆盖率 → 冒烟全流程

---

## 📋 环境要求

| 依赖 | 版本 | 说明 |
|---|---|---|
| **仓颉 SDK** | 1.1.0 | 编译器 `cjc` 及包管理器 `cjpm` |
| **Qt6** | 6.4.2（Linux）<br/>6.10.3（Windows） | 桌面版，需包含 `qtbase` + `qttools`；见 [版本兼容矩阵](docs/qt-version-matrix.md) |
| **C++ 编译器** | MSVC 2022（Win）<br/>GCC 13.3+（Linux） | 仅修改 `native/` 桥接层时需要重编 |
| **CMake** | 3.16+ | 编译 `native/` 桥接库 |
| **操作系统** | Windows 10/11 x64<br/>Linux x64（Ubuntu 20.04+ / WSL2） | macOS 目录已建，bridge 待补 |

> ⚠️ **Qt 版本与编译器 ABI 强绑定**：Windows 必须用 MSVC 版 Qt6.10.3，混用 MinGW 会导致链接失败。CJQT6 桥接库对 Qt **小版本**敏感（存在 ABI 差异），换 Qt 版本必须重编 `cjqt6_bridge` 并跑全量测试。

<details>
<summary>🔍 点击查看环境检查命令</summary>

```bash
# Linux/macOS
cjpm --version            # 仓颉工具链
qmake6 --version          # Qt6 (Linux)
cmake --version           # CMake

# Windows (PowerShell)
cjpm --version
cmake --version
echo $env:QTDIR           # Qt6 路径，如 C:\Qt\6.10.3\msvc2022_64
```
</details>

---

## 🚀 快速开始

### 1. 克隆仓库

```bash
git clone https://gitcode.com/yuan_1992/CJQT6.git
cd CJQT6
```

### 2. 构建项目（两步，顺序不可颠倒）

任何改动后验证，都**必须先重编 C++ 桥接库，再 `cjpm build`**。桥接库产物必须部署到 `releases/<platform>/`，`cjpm.toml` 的 `link-option` 引用它。

#### Windows（推荐一键脚本）

```powershell
# 设置环境变量（脚本已自动注入，手动跑需确保）
$env:CJQT6_ROOT = "C:\CodeTools\cangjie_git\CJQT6"   # 仓库根目录
$env:QTDIR = "C:\Qt\6.10.3\msvc2022_64"

# 步骤1: 重编 C++ FFI 桥接库并同步到 releases/windows-x64/
.\scripts\update-bridge.ps1

# 步骤2: 构建仓颉项目（链接 releases/windows-x64/cjqt6_bridge.lib）
cjpm build
```

#### Linux

```bash
# 步骤1: 重编桥接库，产物部署到 releases/linux-x64/
bash scripts/build-linux-x64.sh

# 步骤2: 构建仓颉项目
cjpm build
```

<details>
<summary>🔧 手动构建（Windows，不用脚本）</summary>

```powershell
$env:QTDIR = "C:\Qt\6.10.3\msvc2022_64"
New-Item -ItemType Directory -Force -Path native\build_windows_x64
cmake -S native -B native\build_windows_x64 -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="$env:QTDIR"
cmake --build native\build_windows_x64 --config Release
# 部署桥接库到 releases/（供 cjpm build 链接）
Copy-Item native\build_windows_x64\bin\cjqt6_bridge.dll releases\windows-x64\ -Force
Copy-Item native\build_windows_x64\lib\cjqt6_bridge.lib releases\windows-x64\ -Force
cjpm build
```
</details>

<details>
<summary>❓ 构建遇到问题?</summary>

- `cjpm: command not found` → 安装仓颉 SDK 1.1.0 并加入 PATH
- `Could not find Qt6` → 设置 `QTDIR` / `CMAKE_PREFIX_PATH`
- 链接失败 `/releases/...` 路径错 → **未设 `CJQT6_ROOT` 环境变量**，将其指向仓库根目录
- `cannot find -lcjqt6_bridge` → 桥接库未构建或未部署到 `releases/`
- 改了 C++ 但行为不变 → **增量构建陷阱**，见下方"已知坑"
- 其他 → [完整构建指南](docs/build-guide.md)
</details>

### 3. 运行示例

Qt 运行时 DLL 必须可找到，先配置环境：

```powershell
# Windows
.\scripts\setup-qt-env.ps1
cd examples\notepad
cjpm run
```

```bash
# Linux
./scripts/setup-qt-env.sh
cd examples/notepad
cjpm run
```

发布部署用 `windeployqt.exe` 或示例目录内的 `deploy_qt.ps1`。

### 5 分钟最小示例

```cangjie
import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

main() {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("Hello CJQT6")
    window.resize(400, 300)

    let label = QLabel()
    label.setText("欢迎使用 CJQT6!")
    label.setAlignment(Alignment.Center.value)

    let layout = QVBoxLayout()
    layout.addWidget(label.getPtr())      // 布局收 Int64 原生指针
    window.setLayout(layout.getPtr())

    window.show()
    app.exec()
}
```

> 📌 **资源管理约定**：每个 Qt 对象封装为 class 并实现 `QtResource` 接口，用完必须**显式 `close()`**，不要依赖 GC（终结器被刻意禁用）。信号槽回调不能捕获局部变量，详见 [SKILL.md](.agents/skills/cjqt6/SKILL.md)。

---

## 📁 项目结构

```
CJQT6/
├── src/                        # 仓颉封装层（13 子包）
│   ├── core/                   # QObject/QTimer/QVariant/事件系统/存活表
│   ├── widgets/                # QPushButton/QMainWindow/布局等
│   ├── gui/                    # QPainter/QFont/QColor/QIcon
│   ├── dialogs/                # 对话框
│   ├── menu/                   # 菜单
│   ├── paint/                  # 绘图
│   ├── qml/                    # QML 引擎
│   ├── multimedia/             # 媒体播放
│   ├── network/                # HTTP/TCP/UDP
│   ├── sql/                    # 数据库 + 表模型
│   ├── views/                  # 列表/树/表格视图
│   ├── print/                  # 打印支持
│   ├── resource/               # 资源管理
│   └── test/                   # 测试源码（package cjqt6.test，34 个 *_test.cj）
├── native/                     # C++ FFI 桥接层（53 个 .cpp）
│   ├── src/<module>/bridge_*.cpp   # extern "C" 导出 qXxx* 函数
│   ├── includes/               # 桥接头文件（含 MOC 类）
│   └── tests/                  # 桥接层 C++ 单元测试
├── releases/                   # 预编译桥接库（入库，cjpm 链接目标）
│   ├── windows-x64/            # MSVC + Qt 6.10.3
│   ├── linux-x64/              # GCC 13.3 + Qt 6.4.2
│   ├── macos-x64/              # 占位（待补 dylib）
│   └── macos-arm64/            # 占位（待补 dylib）
├── examples/                   # 21 个独立示例工程
├── scripts/                    # 构建/测试/辅助脚本
├── docs/                       # 文档（api/tutorial/resource/testing/…）
├── tests/                      # 测试部署脚本（deploy_qt_test.ps1）
├── cjpm.toml                   # cjpm 包配置（output-type = "dynamic"）
├── CMakeLists.txt              # CMake 构建配置
└── .agents/skills/cjqt6/SKILL.md  # 项目自带 skill，权威速查（必读）
```

---

## 🧪 测试与覆盖率

- 测试源码在根包 `src/test/`（`package cjqt6.test`，34 个 `*_test.cj`，千余 `@Expect` 断言），**根目录 `cjpm test` 直接发现并运行**，随仓库版本化。
- 桥接层 C++ 单元测试在 `native/tests/`，由 `scripts/build-native-tests.ps1` 构建、`ctest` 运行。
- GUI 测试类用 `GUITestEnvironment`（`src/core/gui_test_env.cj`）在 `@BeforeAll` 里建 `QApplication`。

```powershell
# Windows 一键跑测试（部署 Qt 运行时 + offscreen 平台 + 全量 + 覆盖率）
powershell -File scripts\run-test.ps1
# 或
powershell -File tests\deploy_qt_test.ps1 -RunTest
```

```bash
# Linux 无显示环境
xvfb-run cjpm test
```

**一键门禁**（推荐 PR 前跑）：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify_all.ps1
```

该脚本自动完成：编译 bridge → `cjpm build` → offscreen 全量测试 → 生成覆盖率报告 → 冒烟示例验证。当前覆盖率约 **79%**。

> 崩溃退出码 `3221227010` 通常是缺 `QApplication` 实例。

---

## 🌐 平台支持

| 平台 | 预编译 bridge | 运行时验证 | 生产可用度 |
|---|---|---|---|
| Linux x64（Ubuntu 20.04+ / WSL2） | ✅ GCC 13.3 + Qt 6.4.2 | ✅ 全量测试通过 | **可用** |
| Windows x64（Win10/11） | ✅ MSVC 2022 + Qt 6.10.3 | ✅ 全量测试通过 | **可用** |
| macOS x64 | ⚠️ 目录已建，dylib 待补 | ⚠️ 需自编译 | 自担风险 |
| macOS arm64 | ⚠️ 目录已建，dylib 待补 | ⚠️ 需自编译 | 自担风险 |
| Linux ARM64 / Windows ARM64 | ❌ | ❌ | 不支持 |

---

## 🧩 核心模块

| 模块 | 代表控件 |
|---|---|
| **core** | QObject, QTimer, QVariant, 事件系统, 存活表 |
| **widgets** | QPushButton, QLabel, QLineEdit, QMainWindow, 布局 |
| **gui** | QPainter, QFont, QColor, QIcon, QImage |
| **dialogs** | QFileDialog, QMessageBox, QColorDialog |
| **qml** | QQmlApplicationEngine |
| **multimedia** | QMediaPlayer, QAudioOutput |
| **network** | HTTP / TCP / UDP |
| **sql** | 数据库连接 + 表模型 |
| **views** | QListView, QTreeWidget, QTableView |
| **paint / print / menu / resource** | 绘图 / 打印 / 菜单 / 资源 |

---

## 📂 示例程序（21 个）

| 示例 | 说明 |
|---|---|
| hello_uic2cj / ui2cj_demo / ui2cj_test | UI 转仓颉工具链 |
| all_controls_demo | 控件大全 |
| notepad | 记事本 |
| calculator | 计算器 |
| music_player | 音乐播放器 |
| paint_app | 绘图应用 |
| analog_clock | 模拟时钟 |
| dormitory_manager / expense_tracker / todo_list | 业务应用 |
| qq_chat_lan | 局域网聊天 |
| snake_game / tank_battle | 游戏 |
| qml / qml_test | QML 示例 |
| signal_smoke / bench / resource / my_qy_app | 信号冒烟/基准/资源/综合 |

---

## ⚠️ 已知坑（踩过才会知道）

- **两步构建顺序不可颠倒**：必须先重编 C++ 桥接库再 `cjpm build`，否则链接到旧 bridge。
- **`CJQT6_ROOT` 环境变量**：`cjpm.toml` Windows 目标段用 `${CJQT6_ROOT}/releases/windows-x64/cjqt6_bridge.dll` 替换链接路径。构建前必须设置 `CJQT6_ROOT` 指向仓库根目录（`scripts/update-bridge.ps1`、`verify_all.ps1`、`setup-qt-env.ps1/.sh` 已自动注入）；**不设置会拼成 `/releases/...` 直接链接失败**。
- **增量构建陷阱**：`native\build_windows_x64` 有 CMake 缓存时，`cmake --build` 可能判定"已最新"跳过链接，导致改了 C++ 代码但行为不变。强制重编：`cmake --build . --config Release --clean-first`，或删掉 `native\build_windows_x64` 重来。
- **终结器（`~init`）被刻意禁用**：GC 时机不确定，依赖它会在 Qt 对象仍被使用时提前删除导致崩溃。用完必须显式 `close()`/`delete()`。
- **`CFunc` 回调不能捕获局部变量**：回调定义为顶层 `let` 绑定 + 全局 `?T` 变量共享状态，再传给 `setOnXxx(...)`。
- **布局收 `Int64` 原生指针**：`addWidget(xxx.getPtr())`，不是对象；`setAlignment` 收 `Int32`（`Alignment.Center.value`）。
- `src/main.cj` 只是打印占位，不是入口；库本身是 `output-type = "dynamic"`，真正运行入口在各示例。

---

## 📚 文档导航

| 文档 | 路径 | 说明 |
|---|---|---|
| **项目 Skill** | [.agents/skills/cjqt6/SKILL.md](.agents/skills/cjqt6/SKILL.md) | 模块地图/API 约定/信号槽/内存陷阱速查（必读） |
| 构建指南 | [docs/build-guide.md](docs/build-guide.md) | 详细构建步骤与错误诊断 |
| 架构设计 | [docs/architecture.md](docs/architecture.md) | 三层架构说明 |
| API 参考 | [docs/api/](docs/api/) | 完整 API 文档 |
| 快速入门 | [docs/tutorial/](docs/tutorial/) | 入门教程 |
| 资源管理 | [docs/resource/](docs/resource/) | 内存管理指南 |
| 测试指南 | [docs/testing/](docs/testing/) | 测试规范 |
| 交叉编译 | [docs/cross-compile.md](docs/cross-compile.md) | 交叉编译说明 |
| Qt 版本矩阵 | [docs/qt-version-matrix.md](docs/qt-version-matrix.md) | Qt 版本 × 平台兼容矩阵 |
| 性能基线 | [docs/performance-baseline.md](docs/performance-baseline.md) | FFI/信号/异步路径性能基线 |
| 贡献指南 | [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) | 新增控件/类流程 |
| 安全说明 | [SECURITY.md](SECURITY.md) | 漏洞上报渠道与已知风险声明 |
| 变更日志 | [docs/CHANGELOG.md](docs/CHANGELOG.md) | 版本变更记录 |

---

## 🗺️ 路线图

- [x] **v1.0** — Widgets 基础链路 + 信号槽 P0/P1
- [x] **v1.5** — 反向失效存活表、跨线程 QueuedConnection
- [x] **v1.7** — QML / Network / SQL / Print 模块落地，千余用例 + 约 79% 覆盖率
- [ ] **v1.8** — macOS 官方 bridge 预编译、GraphicsView 封装
- [ ] **v2.0** — QML 深度集成、QAbstractItemModel 子类化、鸿蒙（OHOS）适配预研
- [ ] **中心仓发布** — 申请加入 Cangjie-TPC 组织，支持 `cjpm add cjqt6`

---

## 🤝 贡献指南

欢迎参与 CJQT6 的开发！请参阅 [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) 了解新增控件/类的完整流程。发现安全问题请走 [SECURITY.md](SECURITY.md) 的私密上报渠道，勿公开发布漏洞细节。

### 新增控件/类流程

1. `native/src/<module>/bridge_*.cpp` 加 `extern "C"` 函数（含 `qXxxDelete`）+ `native/includes/*.h` 声明；
2. 把 .cpp 加进根 `CMakeLists.txt` 对应模块 SOURCES 列表；
3. 重编 bridge 并同步 `releases/`；
4. `src/<module>/xxx.cj` 写封装 class（foreign 声明 + QtResource + checkValid + close）；
5. `cjpm build` 验证，补 `src/test/` 测试与 `docs/api/` 文档。

### 贡献流程

1. Fork 本项目 → 创建特性分支
2. 确保 `scripts/verify_all.ps1` 全量通过
3. 新增 API 必须配套测试用例
4. 提交 Pull Request

**代码规范**：全仓库文档/注释/commit message 均为中文；类大驼峰、函数小驼峰；C++ 桥接函数 `qXxxCreate`/`qXxxSetXxx`；格式化用 `cjfmt`、静态检查用 `cjlint`。

---

## 📜 许可证

### CJQT6 代码

本项目采用 **MIT 许可证**，详见 [docs/LICENSE](docs/LICENSE)。

### 依赖库声明

本项目依赖 Qt6 框架，Qt6 采用 **LGPL v3** 或商业许可证：
- **Qt6 版权所有**：The Qt Company Ltd
- **Qt6 源码**：https://code.qt.io/cgit/qt/
- **Qt6 许可详情**：https://www.gnu.org/licenses/lgpl-3.0.html

**用户权利**：
1. 自由使用、修改和分发本软件
2. 替换 Qt6 库为其他版本（动态链接方式支持）
3. 按 LGPL v3 要求获取 Qt6 源码

**使用声明**：
- 本项目是 Qt6 的 FFI 封装层，通过动态链接库（DLL/SO）使用 Qt6
- 未修改 Qt6 源代码，仅调用 Qt6 公开 API
- 本项目不归属 Qt 官方，由社区独立开发维护

详见 [docs/NOTICE](docs/NOTICE) 与 [许可证分析](docs/LICENSE-ANALYSIS.md)。

---

## 📮 联系与社区

- **GitCode 主仓**：https://gitcode.com/yuan_1992/CJQT6
- **GitHub 镜像**：https://github.com/QianChengYuan/CJQT6
- **问题反馈**：https://gitcode.com/yuan_1992/CJQT6/issues
- **QQ 交流群**：1023882445

欢迎加入 QQ 群交流讨论！

---

## 致谢

感谢仓颉语言团队和 Qt 项目提供的优秀基础。

<p align="center">
  Made with ❤️ for the Cangjie Community
</p>
