# CJQT6 发行版

本目录包含预编译的二进制文件，供不想自行编译的用户下载使用。

## 目录结构

```
releases/
├── windows-x64/           # Windows x64 平台
│   └── cjqt6_bridge.dll      # Qt桥接库 (MSVC 2022)
├── linux-x64/             # Linux x64 平台
│   └── libcjqt6_bridge.so
├── linux-arm64/           # Linux ARM64 平台
│   └── libcjqt6_bridge.so
├── macos-x64/             # macOS Intel
│   └── libcjqt6_bridge.dylib
└── macos-arm64/           # macOS Apple Silicon
    └── libcjqt6_bridge.dylib
```

## 使用方法

### 1. 下载对应平台的桥接库

从 [Releases](https://gitcode.com/Cangjie-TPC/CJQT6/releases) 页面下载对应平台的压缩包。

### 2. 安装到系统路径

**Windows:**
```powershell
# 方式1: 复制到仓颉运行时目录
copy cjqt6_bridge.dll \path\to\cangjie\cangjie_1.1.0\runtime\lib\windows_x86_64_cjnative\

# 方式2: 添加到PATH环境变量
$env:PATH += ";\path\to\cjqt6_bridge"
```

**Linux:**
```bash
# 复制到仓颉运行时目录
sudo cp libcjqt6_bridge.so /usr/local/cangjie/runtime/lib/linux_x86_64_cjnative/

# 或设置LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/path/to/cjqt6_bridge:$LD_LIBRARY_PATH
```

**macOS:**
```bash
# 复制到仓颉运行时目录
sudo cp libcjqt6_bridge.dylib /usr/local/cangjie/runtime/lib/macos_x86_64_cjnative/

# 或设置DYLD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=/path/to/cjqt6_bridge:$DYLD_LIBRARY_PATH
```

### 3. 在项目中使用

**方式1: Git 依赖安装 (推荐)**
```toml
[dependencies]
  cjqt6 = { git = "https://gitcode.com/Cangjie-TPC/CJQT6.git", branch = "main" }
```

**方式2: 本地路径引用**
```toml
[dependencies]
  cjqt6 = { path = "/path/to/CJQT6" }
```

## 依赖要求

使用这些预编译库需要：

| 依赖 | 版本要求 |
|------|----------|
| 仓颉编译器 | >= 1.1.0 |
| Qt6 | >= 6.2 |
| CMake | >= 3.16 |

### Qt6 环境配置

**Windows:**
```powershell
# 设置Qt路径 (MSVC 2022)
$env:PATH += ";\path\to\Qt\6.10.3\msvc2022_64\bin"
```

**Linux:**
```bash
# 安装Qt6 (Ubuntu/Debian)
sudo apt install qt6-base-dev qt6-tools-dev

# 设置环境
export QTDIR=/usr/lib/qt6
```

**macOS:**
```bash
# 使用Homebrew安装
brew install qt@6

# 设置环境 (Apple Silicon 为 /opt/homebrew)
export QTDIR=/opt/homebrew/opt/qt@6
```

## 自行编译

如果预编译库不适用于您的平台，可以自行编译：

```bash
# 克隆项目
git clone https://gitcode.com/Cangjie-TPC/CJQT6.git
cd CJQT6

# 编译桥接库
mkdir native/build_linux && cd native/build_linux
cmake ../.. -DCMAKE_PREFIX_PATH=/path/to/qt6
make -j$(nproc)

# 编译产物位于 native/build_linux/lib/
```

各平台推荐使用脚本一键构建（自动探测 Qt 路径并部署到 `releases/`）：

| 平台 | 脚本 | 产物 |
|------|------|------|
| Windows x64 (MSVC) | `scripts/update-bridge.ps1` | `releases/windows-x64/cjqt6_bridge.dll` |
| Linux x86_64 | `scripts/build-linux-x64.sh` | `releases/linux-x64/libcjqt6_bridge.so` |
| macOS Intel | `scripts/build-macos-x64.sh` | `releases/macos-x64/libcjqt6_bridge.dylib` |
| macOS Apple Silicon | `scripts/build-macos-arm64.sh` | `releases/macos-arm64/libcjqt6_bridge.dylib` |

在目标 macOS 机器上可直接运行 `bash scripts/build-all-platforms.sh` 自动检测平台并调用对应脚本。

详细编译指南请参阅 [构建文档](../docs/build-guide.md)。

## 版本对应关系

| CJQT6版本 | 桥接库版本 | Qt版本 | 仓颉版本 |
|-----------|------------|--------|----------|
| 1.0.0     | 1.0.0      | >= 6.2 | >= 1.1.0 |

## 许可证

本发行版遵循与主项目相同的 [MIT许可证](../LICENSE)。
