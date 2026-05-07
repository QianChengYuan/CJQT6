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

> **首次构建？** 请参阅 [完整构建指南](doc/build-guide.md) 了解详细步骤和常见问题解决方法。

| 依赖 | 版本要求 | 快速安装 |
|------|----------|---------|
| 仓颉编译器 | >= 1.0.0 (推荐 1.1.0) | [安装指南](doc/build-guide.md#21-安装仓颉编译器) |
| Qt6 | >= 6.2 | [安装指南](doc/build-guide.md#22-安装qt6) |
| CMake | >= 3.16 | [安装指南](doc/build-guide.md#23-安装cmake) |
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
mkdir -p native/build && cd native/build
cmake ..                            # 配置构建系统
make -j$(nproc)                     # 编译(使用多核加速)
cd ../..

# 步骤2: 构建仓颉项目
cjpm build
```

#### 快速构建 (Windows)

```powershell
# 步骤1: 构建FFI桥接库
New-Item -ItemType Directory -Force -Path native\build
cd native\build
cmake .. -G "Visual Studio 17 2022" -A x64    # 生成VS项目
cmake --build . --config Release               # 编译
cd ..\..

# 步骤2: 构建仓颉项目
cjpm build
```

<details>
<summary>❓ 构建遇到问题?</summary>

常见问题快速诊断:
- `cjpm: command not found` → [安装仓颉编译器](doc/build-guide.md#21-安装仓颉编译器)
- `Could not find Qt6` → [安装Qt6](doc/build-guide.md#22-安装qt6) 或设置 `CMAKE_PREFIX_PATH`
- `cmake: command not found` → [安装CMake](doc/build-guide.md#23-安装cmake)
- `cannot find -lcjfw_bridge` → 桥接库未构建，请先执行步骤1
- 其他问题 → [完整错误诊断指南](doc/build-guide.md#5-错误诊断)
</details>

### 3. 验证构建

```bash
# 验证FFI桥接库 (Linux/macOS)
ls build/lib/libcjqt6_bridge.so    # Linux
ls build/lib/libcjqt6_bridge.dylib # macOS

# 验证FFI桥接库 (Windows PowerShell)
dir build\bin\libcjqt6_bridge.dll
```

### 4. 运行示例

```bash
cjpm run --example hello_window
```

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
├── doc/                        # 文档目录
│   ├── api/                    # API参考文档
│   ├── tutorial/               # 教程文档
│   ├── guides/                 # 开发指南
│   ├── architecture.md         # 架构设计
│   └── resource-management.md  # 资源管理指南
├── native/                     # C++原生桥接代码
│   ├── includes/               # C++头文件
│   ├── src/                    # C++实现
│   └── build/                  # CMake构建输出
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
│   └── music_player/           # 音乐播放器
└── tests/                      # 测试代码
```

## 文档导航

| 文档类型 | 路径 | 说明 |
|---------|------|------|
| **构建指南** | [doc/build-guide.md](doc/build-guide.md) | 详细构建步骤和错误诊断 |
| 快速入门 | [doc/tutorial/01-quick-start.md](doc/tutorial/01-quick-start.md) | 15分钟入门教程 |
| API参考 | [doc/api/](doc/api/) | 完整API文档 |
| 架构设计 | [doc/architecture.md](doc/architecture.md) | 系统架构说明 |
| 资源管理 | [doc/resource-management.md](doc/resource-management.md) | 内存管理指南 |
| 常见问题 | [doc/faq.md](doc/faq.md) | FAQ |

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

欢迎贡献代码、文档或提出Issue。请参阅 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详情。

### 贡献流程

1. Fork本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交Pull Request

## 许可证

本项目采用 MIT 许可证，详见 [LICENSE](LICENSE) 文件。

## 联系方式

- 项目主页：https://gitcode.com/yuan_1992/CJQT6
- 问题反馈：https://gitcode.com/yuan_1992/CJQT6/-/issues
- QQ群：1023882445

欢迎加入QQ群交流讨论！

## 致谢

感谢仓颉语言团队和Qt项目提供的优秀基础。
