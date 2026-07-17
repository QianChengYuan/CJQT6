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

### 方式一：通过仓颉中心仓安装（推荐）

```bash
# 安装最新版本
cjpm install CJQT6

# 安装指定版本
cjpm install CJQT6@1.0.0
```

### 方式二：从源码构建

```bash
# 克隆仓库
git clone https://gitcode.com/yuan_1992/CJQT6.git
cd CJQT6

# 构建FFI桥接库
bash scripts/build-all-platforms.sh

# 本地安装
cjpm install --local
```

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
cjpm init my-qt-app
cd my-qt-app
```

### 2. 添加CJQT6依赖

编辑 `cjpm.toml`:
```toml
[package]
  name = "my-qt-app"
  version = "1.0.0"

[dependencies]
  CJQT6 = "1.0.0"
```

### 3. 编写代码

创建 `main.cj`:
```cangjie
import CJQT6.core.*
import CJQT6.widgets.*

main() {
    let app = QApplication()
    
    let window = QWidget()
    window.setWindowTitle("我的第一个CJQT6应用")
    window.resize(400, 300)
    
    let button = QPushButton("点击我", window)
    button.resize(100, 30)
    button.move(150, 135)
    
    window.show()
    app.exec()
}
```

### 4. 构建和运行

```bash
cjpm build
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
