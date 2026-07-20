# CJQT6 交叉编译指南

本文档说明如何为不同平台编译Qt桥接库。

## 目录

- [概述](#概述)
- [Linux平台](#linux平台)
- [Windows平台](#windows平台)
- [macOS平台](#macos平台)
- [自动化脚本](#自动化脚本)
- [常见问题](#常见问题)

---

## 概述

CJQT6需要为每个平台编译对应的桥接库：

| 平台 | 库文件 | 输出路径 |
|------|--------|----------|
| Linux x64 | `libcjqt6_bridge.so` | `releases/linux-x64/` |
| Linux ARM64 | `libcjqt6_bridge.so` | `releases/linux-arm64/` |
| Windows x64 | `libcjqt6_bridge.dll` | `releases/windows-x64/` |
| macOS x64 | `libcjqt6_bridge.dylib` | `releases/macos-x64/` |
| macOS ARM64 | `libcjqt6_bridge.dylib` | `releases/macos-arm64/` |

### 编译依赖

所有平台需要：
- **Qt6** >= 6.2（包含Core, Gui, Widgets, Qml, Quick, Sql, PrintSupport组件）
- **CMake** >= 3.16
- **C++17编译器**

---

## Linux平台

### 本地编译（x64）

```bash
# 安装依赖（Ubuntu/Debian）
sudo apt update
sudo apt install -y \
    build-essential \
    cmake \
    qt6-base-dev \
    qt6-tools-dev \
    qt6-qmltooling-dev \
    libqt6sql6 \
    libqt6printsupport6

# 创建构建目录
mkdir -p build && cd build

# 配置CMake
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=/usr/lib/qt6

# 编译
make -j$(nproc)

# 安装到releases目录
mkdir -p ../releases/linux-x64
cp lib/libcjqt6_bridge.so ../releases/linux-x64/
```

### 交叉编译（ARM64）

在x64机器上编译ARM64版本：

```bash
# 安装交叉编译工具链
sudo apt install -y \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    qt6-base-dev:arm64

# 创建构建目录
mkdir -p build-arm64 && cd build-arm64

# 配置CMake（指定交叉编译工具链）
cmake .. \
    -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
    -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc \
    -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ \
    -DCMAKE_FIND_ROOT_PATH=/usr/aarch64-linux-gnu \
    -DCMAKE_PREFIX_PATH=/usr/aarch64-linux-gnu/qt6

# 编译
make -j$(nproc)

# 安装
mkdir -p ../releases/linux-arm64
cp lib/libcjqt6_bridge.so ../releases/linux-arm64/
```

---

## Windows平台

### 本地编译（x64）

**使用MSVC（推荐）：**

```powershell
# 打开Visual Studio Developer Command Prompt
# 或使用PowerShell（需要先运行vcvars64.bat）

# 配置CMake
cmake ..\.. -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="C:/Qt/6.10.3/msvc2022_64"

# 编译
cmake --build . --config Release

# 安装到 releases/
Copy-Item bin\Release\cjqt6_bridge.dll ..\..\releases\windows-x64\
Copy-Item lib\Release\cjqt6_bridge.lib ..\..\releases\windows-x64\
```

**使用MinGW（备选）：**

```powershell
# 安装Qt6 MinGW版本（从qt.io下载在线安装器）
# 安装路径：C:\Qt\6.10.3\mingw_64

# 设置环境
$env:PATH = "C:\Qt\6.10.3\mingw_64\bin;C:\Qt\Tools\mingw1310_64\bin;$env:PATH"

# 在项目根目录创建构建目录
New-Item -ItemType Directory -Force -Path native\build_windows
cd native\build_windows

# 配置CMake
cmake ..\.. `
    -G "MinGW Makefiles" `
    -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_PREFIX_PATH="C:/Qt/6.10.3/mingw_64" `
    -DCMAKE_CXX_COMPILER="C:/Qt/Tools/mingw1310_64/bin/g++.exe"

# 编译
mingw32-make -j4

# 安装到 releases/
Copy-Item bin\libcjqt6_bridge.dll ..\..\releases\windows-x64\
```

### 交叉编译（从Linux到Windows）

使用MinGW-w64交叉编译：

```bash
# 安装MinGW-w64
sudo apt install -y mingw-w64

# 下载Qt6 for Windows（从qt.io）
# 解压到 /path/to/qt6-win

# 创建构建目录
mkdir -p build-win64 && cd build-win64

# 配置CMake
cmake .. \
    -DCMAKE_SYSTEM_NAME=Windows \
    -DCMAKE_C_COMPILER=x86_64-w64-mingw32-gcc \
    -DCMAKE_CXX_COMPILER=x86_64-w64-mingw32-g++ \
    -DCMAKE_PREFIX_PATH=/path/to/qt6-win

# 编译
make -j$(nproc)

# 转换DLL格式（可选）
# 结果：libcjqt6_bridge.dll
```

---

## macOS平台

### 本地编译（x64/ARM64通用）

```bash
# 安装Qt6（使用Homebrew）
brew install qt@6

# 或从qt.io下载官方安装器

# 创建构建目录
mkdir -p build && cd build

# 配置CMake（Intel Mac）
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=/usr/local/opt/qt@6 \
    -DCMAKE_OSX_ARCHITECTURES=x86_64

# 或配置CMake（Apple Silicon）
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=/opt/homebrew/opt/qt@6 \
    -DCMAKE_OSX_ARCHITECTURES=arm64

# 编译
make -j$(sysctl -n hw.ncpu)

# 安装
mkdir -p ../releases/macos-x64  # 或 macos-arm64
cp lib/libcjqt6_bridge.dylib ../releases/macos-x64/
```

### 通用二进制（Universal Binary）

同时支持x64和ARM64：

```bash
# 编译x64版本
mkdir -p build-x64 && cd build-x64
cmake .. -DCMAKE_OSX_ARCHITECTURES=x86_64
make -j$(sysctl -n hw.ncpu)
cd ..

# 编译ARM64版本
mkdir -p build-arm64 && cd build-arm64
cmake .. -DCMAKE_OSX_ARCHITECTURES=arm64
make -j$(sysctl -n hw.ncpu)
cd ..

# 合并为通用二进制
lipo -create \
    build-x64/lib/libcjqt6_bridge.dylib \
    build-arm64/lib/libcjqt6_bridge.dylib \
    -output releases/macos-universal/libcjqt6_bridge.dylib
```

---

## 自动化脚本

### Linux一键编译脚本

创建 `scripts/build-linux.sh`：

```bash
#!/bin/bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
RELEASE_DIR="$PROJECT_ROOT/releases/linux-x64"

echo "=== 编译Linux x64桥接库 ==="

# 清理旧构建
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 配置
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=/usr/lib/qt6

# 编译
make -j$(nproc)

# 安装
mkdir -p "$RELEASE_DIR"
cp lib/libcjqt6_bridge.so "$RELEASE_DIR/"

echo "✅ 编译完成: $RELEASE_DIR/libcjqt6_bridge.so"
ls -lh "$RELEASE_DIR/libcjqt6_bridge.so"
```

### Windows一键编译脚本

创建 `scripts\build-windows-msvc.ps1`：

```powershell
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$BuildDir = Join-Path $ProjectRoot "native\build_windows"
$ReleaseDir = Join-Path $ProjectRoot "releases\windows-x64"

Write-Host "=== 编译Windows x64桥接库 (MSVC 2022) ===" -ForegroundColor Green

# 设置Qt路径（根据实际安装路径调整）
$QtPath = "C:\Qt\6.10.3\msvc2022_64"
$env:PATH = "$QtPath\bin;$env:PATH"

# 配置
New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
Set-Location $BuildDir
cmake ..\.. -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH=$QtPath

# 编译
cmake --build . --config Release

# 安装到 releases/
New-Item -ItemType Directory -Force -Path $ReleaseDir | Out-Null
Copy-Item "bin\cjqt6_bridge.dll" $ReleaseDir
Copy-Item "lib\cjqt6_bridge.lib" $ReleaseDir

Write-Host "✅ 编译完成: $ReleaseDir\cjqt6_bridge.dll" -ForegroundColor Green
Get-Item "$ReleaseDir\cjqt6_bridge.dll" | Format-List Length, LastWriteTime
```

### macOS一键编译脚本

创建 `scripts/build-macos.sh`：

```bash
#!/bin/bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    RELEASE_DIR="$PROJECT_ROOT/releases/macos-x64"
    QT_PATH="/usr/local/opt/qt@6"
else
    RELEASE_DIR="$PROJECT_ROOT/releases/macos-arm64"
    QT_PATH="/opt/homebrew/opt/qt@6"
fi

echo "=== 编译macOS $ARCH桥接库 ==="

# 清理旧构建
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 配置
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="$QT_PATH" \
    -DCMAKE_OSX_ARCHITECTURES="$ARCH"

# 编译
make -j$(sysctl -n hw.ncpu)

# 安装
mkdir -p "$RELEASE_DIR"
cp lib/libcjqt6_bridge.dylib "$RELEASE_DIR/"

echo "✅ 编译完成: $RELEASE_DIR/libcjqt6_bridge.dylib"
ls -lh "$RELEASE_DIR/libcjqt6_bridge.dylib"
```

---

## 常见问题

### Q1: 找不到Qt6

**错误**：`Could not find Qt6`

**解决**：
```bash
# 方式1: 设置CMAKE_PREFIX_PATH
cmake .. -DCMAKE_PREFIX_PATH=/path/to/qt6

# 方式2: 设置Qt6_DIR环境变量
export Qt6_DIR=/usr/lib/qt6/lib/cmake/Qt6
cmake ..

# 方式3: 使用qt-cmake（Qt提供的工具）
/path/to/qt6/bin/qt-cmake ..
```

### Q2: Qt组件缺失

**错误**：`Could not find Qt6Multimedia`

**解决**：
```bash
# Ubuntu/Debian
sudo apt install qt6-multimedia-dev

# macOS
brew install qt@6  # 已包含所有组件

# Windows: 使用Qt在线安装器选择Multimedia组件
```

### Q3: 交叉编译工具链问题

**错误**：`CMAKE_CXX_COMPILER not found`

**解决**：
```bash
# 检查工具链是否安装
which aarch64-linux-gnu-g++
which x86_64-w64-mingw32-g++

# 安装缺失的工具链
sudo apt install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
sudo apt install mingw-w64
```

### Q4: 链接错误

**错误**：`undefined reference to Qt::*`

**解决**：
```bash
# 检查Qt库是否完整
ldconfig -p | grep Qt6

# 重新安装Qt
sudo apt install --reinstall qt6-base-dev
```

### Q5: macOS签名问题

**错误**：`library not loaded: @rpath/QtCore.framework`

**解决**：
```bash
# 设置install_name
install_name_tool -change \
    @rpath/QtCore.framework/Versions/A/QtCore \
    @loader_path/../Frameworks/QtCore.framework/Versions/A/QtCore \
    libcjqt6_bridge.dylib

# 或使用otool检查依赖
otool -L libcjqt6_bridge.dylib
```

---

## 验证编译结果

编译完成后，验证库文件：

```bash
# Linux
ldd releases/linux-x64/libcjqt6_bridge.so
file releases/linux-x64/libcjqt6_bridge.so

# Windows (在Git Bash中)
objdump -p releases/windows-x64/libcjqt6_bridge.dll | grep "DLL Name"

# macOS
otool -L releases/macos-x64/libcjqt6_bridge.dylib
file releases/macos-x64/libcjqt6_bridge.dylib
```

---

## 相关文档

- [构建指南](build-guide.md)
- [安装说明](../releases/README.md)
- [API文档](api/)

---

## 许可证

本指南遵循 [MIT License](LICENSE)。
