# CJQT6 安装指南

## 前置要求

### 1. 仓颉编译器
- 版本要求: >= 1.1.0
- 安装方式: 参考[仓颉官方文档](https://cangjie-lang.cn)

### 2. Qt6框架
- 版本要求: >= 6.2
- 推荐版本: 6.5.0 或更高

#### Linux安装Qt6
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install qt6-base-dev qt6-base-dev-tools

# Fedora
sudo dnf install qt6-qtbase-devel

# Arch Linux
sudo pacman -S qt6-base
```

#### Windows安装Qt6
1. 从 [Qt官网](https://www.qt.io/download) 下载在线安装器
2. 安装时选择 Qt 6.5.0 (MSVC 2019 64-bit)
3. 设置环境变量:
```powershell
setx QTDIR "C:\Qt\6.5.0\msvc2019_64"
setx PATH "%PATH%;C:\Qt\6.5.0\msvc2019_64\bin"
```

#### macOS安装Qt6
```bash
# 使用 Homebrew
brew install qt@6

# 设置环境变量 (如需要)
export QTDIR=$(brew --prefix qt@6)
```

## 安装CJQT6

> CJQT6 由两部分组成：**仓颉源码包**（通过 GitCode Git 方式安装）+ **FFI 桥接库**（原生编译产物，需单独下载）。
> 
> `cjpm bundle` 打包的源码包 **不包含** 编译好的桥接库。桥接库通过 GitCode Releases 分平台分发。
> 参见[发布指南](PUBLISHING.md)了解分发策略。

### 前置准备

```bash
# 确认仓颉编译器已安装
cjpm --version

# 确认 Qt6 已安装（版本 ≥ 6.2）
# Linux:  qmake6 --version
# macOS:  qmake --version
# Windows: echo %QTDIR%
```

### 步骤一：安装仓颉源码包

CJQT6 通过 GitCode 分发，作为项目依赖安装源码：

在项目的 `cjpm.toml` 的 `[dependencies]` 中添加：

```toml
[dependencies]
cjqt6 = { git = "https://gitcode.com/yuan_1992/CJQT6.git", tag = "v1.6.0" }
```

支持的引用方式（优先级：`commitId` > `tag` > `branch`）：

```toml
# 固定版本（推荐）
cjqt6 = { git = "https://gitcode.com/yuan_1992/CJQT6.git", tag = "v1.6.0" }
# 最新提交
cjqt6 = { git = "https://gitcode.com/yuan_1992/CJQT6.git", branch = "main" }
# 指定 commit
cjqt6 = { git = "https://gitcode.com/yuan_1992/CJQT6.git", commitId = "abc123" }
```

添加后执行以下命令下载依赖：

```bash
cjpm update
```

CJQT6 的仓颉源码和 C++ 桥接源码会被下载到本地缓存。

### 步骤二：下载 FFI 桥接库

CJQT6 需要 FFI 桥接库才能调用 Qt6。预编译的桥接库在 GitCode Releases 分平台提供：

| 平台 | 下载资源 |
|------|---------|
| Windows x86_64 | `cjqt6-bridge-windows-x64.zip` |
| Linux x86_64 | `cjqt6-bridge-linux-x64.zip` |
| macOS x86_64 | `cjqt6-bridge-macos-x64.zip` |
| macOS ARM64 | `cjqt6-bridge-macos-arm64.zip` |
| Linux ARM64 | `cjqt6-bridge-linux-arm64.zip` |

**下载地址**：https://gitcode.com/yuan_1992/CJQT6/releases

下载对应平台的 zip 包后，解压到项目的 `releases/<platform>/` 目录：

```bash
# 示例：Windows x64
# 解压 cjqt6-bridge-windows-x64.zip 到项目根目录
# 确保 releases/windows-x64/ 下包含:
#   cjqt6_bridge.dll
#   cjqt6_bridge.lib
```

### 步骤三：在项目中使用

在 `cjpm.toml` 中添加依赖并配置链接：

```toml
[package]
  name = "my-qt-app"
  version = "1.0.0"
  cjc-version = "1.1.0"
  output-type = "executable"

[dependencies]
  cjqt6 = { git = "https://gitcode.com/yuan_1992/CJQT6.git", tag = "v1.6.0" }

# Windows MSVC 链接桥接库
[target.x86_64-pc-windows-msvc]
  link-option = "releases/windows-x64/cjqt6_bridge.lib"
```

然后构建：

```bash
cjpm build
```

运行前需要确保运行时库路径正确配置：

**运行时 PATH 配置**

`cjpm run` 不会自动添加 CJQT6 的编译产物（`libcjqt6.*.dll`）和桥接库（`cjqt6_bridge.dll`）到系统 PATH。运行前需要手动设置：

```bash
# Windows PowerShell
$env:PATH = "target\release\cjqt6;releases\windows-x64;$env:PATH"
cjpm run

# Linux
export LD_LIBRARY_PATH=target/release/cjqt6:releases/linux-x64:$LD_LIBRARY_PATH
cjpm run
```

或者将桥接库部署到仓颉运行时目录（只需一次，后续无需手动设 PATH）：

```bash
# Windows PowerShell
copy releases\windows-x64\cjqt6_bridge.dll <cangjie-sdk>\runtime\lib\windows_x86_64_cjnative\

# Linux
cp releases/linux-x64/libcjqt6_bridge.so <cangjie-sdk>/runtime/lib/linux_x86_64_cjnative/
```

### 方式二：从源码构建（开发者）

如果需要自行编译桥接库（如修改了 C++ 桥接代码），可以直接克隆完整仓库：

```bash
# 克隆仓库
git clone https://gitcode.com/yuan_1992/CJQT6.git
cd CJQT6

# 构建FFI桥接库
bash scripts/build-all-platforms.sh

# 本地安装
cjpm install --local
```

完整的构建说明参见 [构建指南](build-guide.md)。

## 验证安装

运行验证脚本检查安装是否成功：

```bash
cjc scripts/verify_install.cj
```

预期输出：
```
验证CJQT6安装...
=====================================

1. 检查必需文件...
  ✓ 核心文件检查通过

2. 检查平台兼容性...
  ✓ 平台兼容性检查通过

3. 检查Qt6依赖...
  ✓ Qt6依赖检查通过

4. 检查FFI桥接库...
  ✓ FFI桥接库检查通过

=====================================
✓ 验证通过！CJQT6安装成功
```

## 在项目中使用

### 1. 创建新项目

```bash
cjpm init --name my-qt-app
cd my-qt-app
```

### 2. 添加CJQT6依赖

编辑 `cjpm.toml`:
```toml
[package]
  name = "my-qt-app"
  version = "1.0.0"

[dependencies]
  cjqt6 = { git = "https://gitcode.com/yuan_1992/CJQT6.git", tag = "v1.6.0" }
```

### 3. 编写代码

创建 `main.cj`:
```cangjie
import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

main() {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("我的第一个CJQT6应用")
    window.resize(400, 300)

    let button = QPushButton()
    button.setText("点击我")
    let layout = QVBoxLayout()
    layout.addWidget(button.getPtr())
    window.setLayout(layout.getPtr())

    window.show()
    app.exec()
}
```

### 4. 构建和运行

```bash
cjpm build
```

运行前配置运行时库路径：

```powershell
# Windows PowerShell
$env:PATH = "target\release\cjqt6;releases\windows-x64;$env:PATH"
cjpm run
```

```bash
# Linux
export LD_LIBRARY_PATH=target/release/cjqt6:releases/linux-x64:$LD_LIBRARY_PATH
cjpm run
```

## 故障排查

### 问题：找不到Qt6

**症状**:
```
错误: Qt6 not found
```

**解决方案**:
1. 确认Qt6已安装
2. 检查环境变量 `QTDIR` 是否设置
3. 运行检测脚本: `cjc scripts/check_qt6.cj`

### 问题：FFI桥接库加载失败

**症状**:
```
错误: cannot load library libcjfw_bridge.so
```

**解决方案**:
- **Linux**: 设置 `LD_LIBRARY_PATH`
  ```bash
  export LD_LIBRARY_PATH=/path/to/CJQT6/lib/native/linux-x64:$LD_LIBRARY_PATH
  ```
  
- **Windows**: 确保DLL在PATH中或应用程序目录
  
- **macOS**: 通常自动配置，如需要设置 `DYLD_LIBRARY_PATH`

### 问题：版本不兼容

**症状**:
```
警告: Qt6版本过低，建议升级
```

**解决方案**:
升级Qt6到6.2或更高版本

## 获取帮助

- 文档: https://gitcode.com/yuan_1992/CJQT6
- 问题反馈: https://gitcode.com/yuan_1992/CJQT6/issues
- 示例代码: `examples/` 目录
