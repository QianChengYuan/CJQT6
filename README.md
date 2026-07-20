# CJQT6 - 仓颉语言的Qt6封装库

CJQT6 是一个为仓颉(Cangjie)语言提供的Qt6封装库，通过FFI桥接技术让仓颉语言能够使用Qt6的GUI功能。

## 项目简介

CJQT6通过FFI（外部函数接口）技术，将Qt6的C++ API封装为仓颉语言的原生API风格，为仓颉开发者提供完整的GUI开发能力。本项目具有以下核心特性：

- **完整的Qt6组件封装**：涵盖控件、布局、绘图、多媒体等模块
- **仓颉原生API风格**：遵循仓颉语言习惯，类型安全
- **FFI桥接技术**：高效的C++与仓颉交互机制
- **信号槽机制**：完整的事件驱动编程支持
- **资源管理保障**：明确的内存管理策略和终结器机制

## 环境要求

> **首次构建？** 请参阅 [完整构建指南](docs/build-guide.md) 了解详细步骤和常见问题解决方法。

| 依赖 | 版本要求 | 快速安装 |
|------|----------|---------|
| 仓颉编译器 | >= 1.0.0 (推荐 1.1.0) | [安装指南](docs/build-guide.md#21-安装仓颉编译器) |
| Qt6 | >= 6.2 | [安装指南](docs/build-guide.md#22-安装qt6) |
| CMake | >= 3.16 | [安装指南](docs/build-guide.md#23-安装cmake) |
| 操作系统 | Linux / Windows / macOS | - |

<details>
<summary>🔍 点击查看环境检查命令</summary>

```bash
# Linux/macOS
cjpm --version      # 检查仓颉编译器
qmake6 --version    # 检查Qt6 (Linux)
qmake --version     # 检查Qt6 (macOS)
cmake --version     # 检查CMake

# Windows (PowerShell)
cjpm --version
cmake --version
# Qt6检查需查看环境变量QTDIR
echo %QTDIR%
```
</details>

## 快速开始

### 1. 克隆项目

```bash
git clone https://gitcode.com/yuan_1992/CJQT6.git
cd CJQT6
```

### 2. 构建项目

#### 快速构建 (Linux/macOS)

```bash
# 步骤1: 构建FFI桥接库(C++部分)
mkdir -p native/build_linux && cd native/build_linux
cmake ../..                         # 配置构建系统（指定项目根目录的 CMakeLists.txt）
make -j$(nproc)                     # 编译(使用多核加速)
cd ../..

# 步骤2: 部署桥接库到 releases/（供 cjpm build 链接）
mkdir -p releases/linux-x64/
cp native/build_linux/lib/libcjqt6_bridge.so releases/linux-x64/

# 验证桥接库
ldd releases/linux-x64/libcjqt6_bridge.so

# 步骤3: 构建仓颉项目
cjpm build
```

#### 快速构建 (Windows)

```powershell
# 步骤0: 设置 Qt6 路径环境变量（请将 path\to\Qt6 替换为实际路径，如 C:\Qt\6.10.3\msvc2022_64）
$env:QTDIR = "path\to\Qt6"

# 步骤1: 构建FFI桥接库
# 如果 native\build_windows 已存在，先删除：Remove-Item -Recurse -Force native\build_windows
New-Item -ItemType Directory -Force -Path native\build_windows
cd native\build_windows

# MSVC 2022 构建（Visual Studio 17 2022）
cmake ..\.. -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="$env:QTDIR"

cmake --build . --config Release               # 编译
cd ..\..

# ⚠️ MSVC 构建时，产物位于 bin\Release / lib\Release 目录
#    编译后只有 DLL 文件，不会生成 .lib（MSVC 特性）
# 步骤2: 将编译好的桥接库部署到 releases/（供 cjpm build 链接使用）
Copy-Item native\build_windows\bin\Release\cjqt6_bridge.dll releases\windows-x64\ -Force
Copy-Item native\build_windows\lib\Release\cjqt6_bridge.lib releases\windows-x64\ -Force

# 或使用脚本一键完成步骤1-2：
# .\scripts\update-bridge.ps1

# 步骤3: 构建仓颉项目
cjpm build
```

<details>
<summary>❓ 构建遇到问题?</summary>

常见问题快速诊断:
- `cjpm: command not found` → [安装仓颉编译器](docs/build-guide.md#21-安装仓颉编译器)
- `Could not find Qt6` → [安装Qt6](docs/build-guide.md#22-安装qt6) 或设置 `CMAKE_PREFIX_PATH`
- `cmake: command not found` → [安装CMake](docs/build-guide.md#23-安装cmake)
- `cannot find -lcjqt6_bridge` → 桥接库未构建或未部署到 releases/，请先执行步骤1-2
- 其他问题 → [完整错误诊断指南](docs/build-guide.md#5-错误诊断)
</details>

### 3. 验证构建

```bash
# 验证FFI桥接库 (Linux/macOS)
ls native/build_linux/lib/libcjqt6_bridge.so    # Linux
ls native/build_macos/lib/libcjqt6_bridge.dylib # macOS

# 验证FFI桥接库 (Windows PowerShell)
dir native\build_windows\bin\Release\cjqt6_bridge.dll
```

### 4. 运行示例

**设置Qt6环境**：

```powershell
# Windows PowerShell
.\scripts\setup-qt-env.ps1

# 或手动设置
$env:PATH = "C:\Qt\6.10.3\msvc2022_64\bin;$env:PATH"
```

```bash
# Linux/macOS
./scripts/setup-qt-env.sh

# 或手动设置
export PATH="/path/to/qt6/bin:$PATH"
```

**运行示例**：

```bash
cd examples/notepad
cjpm run
```

<details>
<summary>❓ 运行时缺少Qt6 DLL？</summary>

Qt应用需要Qt6动态库才能运行：

**方案1：使用配置脚本（推荐）**
```powershell
# PowerShell
.\scripts\setup-qt-env.ps1
cjpm run
```

**方案2：手动设置环境变量**
```powershell
$env:PATH = "C:\Qt\6.10.3\msvc2022_64\bin;$env:PATH"
cjpm run
```

**方案3：复制Qt DLL到exe目录**
```powershell
Copy-Item C:\Qt\6.10.3\msvc2022_64\bin\Qt6*.dll examples\notepad\target\release\bin\
```

**方案4：使用windeployqt自动部署**
```powershell
cd examples\notepad\target\release\bin
C:\Qt\6.10.3\msvc2022_64\bin\windeployqt.exe main.exe
```

</details>

预期结果：显示一个GUI窗口，可正常关闭。

### 5分钟最小示例

```cangjie
import cjqt6.core.*
import cjqt6.widgets.*

main() {
    let app = QApplication()
    let window = QWidget()
    window.setWindowTitle("Hello CJQT6")
    window.resize(400, 300)
    
    let label = QLabel("欢迎使用CJQT6!", window)
    label.setAlignment(QtAlignment.AlignCenter)
    
    window.show()
    app.exec()
}
```

## 项目结构

```
CJQT6/
├── README.md                   # 项目说明文档
├── cjpm.toml                   # 仓颉项目配置
├── CMakeLists.txt              # CMake构建配置
├── docs/                        # 文档目录
│   ├── api/                    # API参考文档
│   ├── tutorial/               # 教程文档
│   ├── resource/               # 资源管理指南
│   ├── testing/                # 测试指南
│   ├── internal/               # 内部开发笔记
│   ├── CHANGELOG.md            # 变更日志
│   ├── CONTRIBUTING.md         # 贡献指南
│   ├── LICENSE                 # 许可证
│   ├── NOTICE                  # 依赖声明
│   ├── architecture.md         # 架构设计
│   ├── build-guide.md          # 构建指南
│   ├── installation.md         # 安装指南
│   ├── cross-compile.md        # 交叉编译指南
│   ├── resource-management.md  # 资源管理指南
│   └── resource-utils-guide.md # 资源工具指南
├── scripts/                    # 构建/辅助脚本
│   ├── build-all-platforms.sh  # 全平台构建
│   ├── build-linux-x64.sh      # Linux x64构建
│   ├── build-macos-x64.sh      # macOS x64构建
│   ├── build-windows-x64.ps1   # Windows x64构建
│   ├── build-win64.sh          # Windows(备选)构建
│   ├── run-test.sh             # 运行测试
│   ├── setup-qt-env.ps1        # Windows Qt环境配置
│   ├── setup-qt-env.sh         # Linux/macOS Qt环境配置
│   ├── check_qt6.cj            # Qt6环境检测
│   ├── detect_platform.cj      # 平台检测
│   ├── post_install.cj         # 安装后脚本
│   └── verify_install.cj       # 安装验证脚本
├── cmake/                      # CMake配置
│   └── win64-mingw.cmake       # Linux→Windows MinGW交叉编译工具链
├── native/                     # C++原生桥接代码
│   ├── includes/               # C++头文件
│   ├── src/                    # C++实现
│   ├── build_linux/            # Linux CMake构建输出
│   └── build_windows/          # Windows CMake构建输出
├── src/                        # 仓颉源代码
│   ├── core/                   # 核心模块
│   ├── widgets/                # 控件模块
│   ├── gui/                    # GUI模块
│   ├── dialogs/                # 对话框模块
│   ├── paint/                  # 绘图模块
│   └── qml/                    # QML模块
├── examples/                   # 示例程序
│   ├── widgets_demo/           # 常用控件演示
│   ├── calculator/             # 计算器
│   ├── notepad/                # 记事本
│   ├── paint_app/              # 绘图应用
│   ├── music_player/           # 音乐播放器
│   └── ...
├── releases/                   # 发行版目录
└── tests/                      # 测试代码
```

## 文档导航

| 文档类型 | 路径 | 说明 |
|---------|------|------|
| **构建指南** | [docs/build-guide.md](docs/build-guide.md) | 详细构建步骤和错误诊断 |
| **发布指南** | [PUBLISHING.md](PUBLISHING.md) | 中心仓发布流程 |
| 快速入门 | [docs/tutorial/01-quick-start.md](docs/tutorial/01-quick-start.md) | 15分钟入门教程 |
| API参考 | [docs/api/](docs/api/) | 完整API文档 |
| 架构设计 | [docs/architecture.md](docs/architecture.md) | 系统架构说明 |
| 资源管理 | [docs/resource-management.md](docs/resource-management.md) | 内存管理指南 |
| 交叉编译 | [docs/cross-compile.md](docs/cross-compile.md) | 交叉编译说明 |

## 核心模块

### 基础控件
- QLabel - 文本标签
- QPushButton - 按钮
- QLineEdit - 单行输入
- QTextEdit - 多行文本
- QCheckBox - 复选框
- QRadioButton - 单选按钮

### 布局管理
- QHBoxLayout - 水平布局
- QVBoxLayout - 垂直布局
- QGridLayout - 网格布局
- QFormLayout - 表单布局

### 绘图系统
- QPainter - 绘图设备
- QPen - 画笔
- QBrush - 画刷
- QImage - 图像

### 多媒体
- QMediaPlayer - 媒体播放器
- QAudioOutput - 音频输出

## 示例程序

| 示例 | 说明 | 难度 |
|-----|------|------|
| hello_window | 最小窗口示例 | 入门 |
| widgets_demo | 常用控件演示 | 入门 |
| calculator | 计算器应用 | 初级 |
| notepad | 记事本应用 | 初级 |
| paint_app | 绘图应用 | 中级 |
| music_player | 音乐播放器 | 中级 |
| analog_clock | 模拟时钟 | 中级 |

## 贡献指南

欢迎贡献代码、文档或提出Issue。请参阅 [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) 了解详情。

### 贡献流程

1. Fork本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交Pull Request

## 许可证

### CJQT6代码

本项目采用MIT许可证，详见 [docs/LICENSE](docs/LICENSE) 文件。

### 依赖库声明

本项目依赖Qt6框架，Qt6采用LGPL v3许可证：
- **Qt6版权所有**：The Qt Company Ltd
- **Qt6许可证**：LGPL v3 或商业许可证
- **Qt6源码**：https://code.qt.io/cgit/qt/
- **Qt6许可详情**：https://www.gnu.org/licenses/lgpl-3.0.html

**用户权利**：
1. 自由使用、修改和分发本软件
2. 替换Qt6库为其他版本（动态链接方式支持）
3. 按LGPL v3要求获取Qt6源码

**使用声明**：
- 本项目是Qt6的FFI封装层，通过动态链接库（DLL/SO）使用Qt6
- 未修改Qt6源代码，仅调用Qt6公开API
- 本项目不归属Qt官方，由社区独立开发维护

详见 [docs/NOTICE](docs/NOTICE) 文件和 [许可证分析](docs/LICENSE-ANALYSIS.md)。

## 联系方式

- 项目主页：https://gitcode.com/yuan_1992/CJQT6
- 问题反馈：https://gitcode.com/yuan_1992/CJQT6/issues
- QQ群：1023882445

欢迎加入QQ群交流讨论！

## 致谢

感谢仓颉语言团队和Qt项目提供的优秀基础。
