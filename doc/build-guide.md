# CJQT6 完整构建指南

本文档提供详细的构建步骤说明，适合首次构建项目的用户。如果您是编程初学者或不熟悉C++/Qt/FFI，请仔细阅读本章内容。

## 目录

- [1. 概念介绍](#1-概念介绍) - FFI、CMake、动态库等基础概念
- [2. 环境准备](#2-环境准备) - 依赖安装详细步骤
- [3. 构建步骤](#3-构建步骤) - 逐步详细说明
- [4. 构建验证](#4-构建验证) - 如何确认构建成功
- [5. 错误诊断](#5-错误诊断) - 常见问题解决方案
- [6. 平台特定说明](#6-平台特定说明) - Linux/Windows/macOS详解
- [7. 进阶主题](#7-进阶主题) - 自定义构建配置

---

## 1. 概念介绍

> 💡 **提示**: 如果您有C++/Qt开发经验，可以跳过本章直接进入[环境准备](#2-环境准备)。

### 1.1 什么是FFI(外部函数接口)?

**定义**: FFI (Foreign Function Interface) 是一种让不同编程语言相互调用函数的机制。

**本项目中的应用**: 
CJQT6使用FFI技术，让仓颉语言能够调用Qt6的C++函数。

**比喻说明**: 
FFI就像一个翻译官，让仓颉语言和C++语言能够"对话"。

**工作原理图**:
```
┌─────────────┐
│  仓颉代码   │
│ (Cangjie)   │
└──────┬──────┘
       │ FFI调用
       ↓
┌─────────────┐
│ FFI桥接库   │  ← C++编写的中间层
│ (Bridge)    │
└──────┬──────┘
       │ C++调用
       ↓
┌─────────────┐
│   Qt6库     │
│   (C++)     │
└─────────────┘
```

**为什么需要FFI桥接库?**
- Qt6是C++库，仓颉无法直接调用
- FFI桥接库用C++编写，封装Qt6接口
- 仓颉通过FFI调用桥接库的C风格函数

### 1.2 什么是动态库?

**定义**: 动态库(Dynamic Library)是程序运行时加载的共享库文件。

**不同平台的文件形式**:
- Linux: `.so` (Shared Object)
- Windows: `.dll` (Dynamic Link Library)
- macOS: `.dylib` (Dynamic Library)

**本项目的动态库**: 
`libcjfw_bridge.so` / `libjfw_bridge.dll` / `libcjfw_bridge.dylib`
- 这是FFI桥接库的编译产物
- 包含C++编译的Qt6封装代码
- 仓颉程序运行时加载此库

### 1.3 什么是CMake?

**定义**: CMake是一个跨平台的构建配置工具。

**作用**: 
- 根据操作系统生成对应的构建文件
  - Linux/macOS: 生成 Makefile
  - Windows: 生成 Visual Studio 项目文件

**两阶段工作流程**:
1. **配置阶段** (`cmake ..`): 检测环境，生成构建文件
2. **构建阶段** (`make`): 编译源代码，生成库文件

**配置文件**: `CMakeLists.txt`
- 定义如何编译C++代码
- 指定Qt6等依赖库
- 设置输出文件位置

### 1.4 构建流程概览

**完整构建流程图**:
```
准备阶段
├── 安装仓颉编译器 (>= 1.0.0，推荐 1.1.0)
├── 安装Qt6开发环境 (>= 6.2)
└── 安装CMake (>= 3.16)

构建阶段
├── 步骤1: 创建构建目录 (native/build)
├── 步骤2: 运行CMake配置 (cmake ..)
│   ├── 检测Qt6路径
│   ├── 检测编译器
│   └── 生成Makefile/VS项目
├── 步骤3: 编译C++代码 (make)
│   ├── 编译C++源文件
│   ├── 链接Qt6库
│   └── 生成FFI桥接库
└── 步骤4: 构建仓颉项目 (cjpm build)
    ├── 编译仓颉源代码
    ├── 链接FFI桥接库
    └── 生成可执行程序/库

验证阶段
└── 运行示例程序验证
```

---

## 2. 环境准备

### 2.1 安装仓颉编译器

**版本要求**: >= 1.0.0 (推荐 1.1.0)

#### Linux

**方法1: 使用官方安装包 (推荐)**
```bash
# 1. 下载仓颉编译器安装包
# 访问仓颉官网下载页面: https://cangjie-lang.cn/download

# 2. 解压安装包
tar -xzf cangjie-1.1.0-linux-x64.tar.gz
sudo mv cangjie-1.1.0 /usr/local/cangjie

# 3. 配置环境变量
echo 'export PATH=/usr/local/cangjie/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 4. 验证安装
cjpm --version
```

**方法2: 使用包管理器 (部分发行版支持)**
```bash
# Ubuntu/Debian (如官方提供apt源)
# sudo apt install cangjie-compiler

# Arch Linux (AUR)
# yay -S cangjie-compiler
```

#### Windows

**安装步骤**:
1. 访问仓颉官网下载页面: https://cangjie-lang.cn/download
2. 下载Windows安装包: `cangjie-1.1.0-windows-x64.msi`
3. 双击运行安装程序，按向导完成安装
4. 安装程序会自动配置环境变量
5. 打开新的命令提示符或PowerShell窗口
6. 验证安装:
   ```powershell
   cjpm --version
   ```

**手动配置环境变量 (如需)**:
```powershell
# 添加到系统PATH
setx PATH "%PATH%;C:\Program Files\Cangjie\bin"
```

#### macOS

**方法1: 使用官方安装包**
```bash
# 1. 下载安装包
# 访问: https://cangjie-lang.cn/download

# 2. 挂载并安装
hdiutil attach cangjie-1.1.0-macos-x64.dmg
sudo installer -pkg /Volumes/cangjie-1.1.0/cangjie.pkg -target /

# 3. 验证安装
cjpm --version
```

**方法2: 使用Homebrew (如官方提供)**
```bash
# brew install cangjie-compiler
```

### 2.2 安装Qt6

**版本要求**: >= 6.2

#### Linux

**Ubuntu/Debian**:
```bash
# 安装Qt6开发包
sudo apt update
sudo apt install qt6-base-dev qt6-base-dev-tools

# 可选: 安装额外模块
sudo apt install qt6-multimedia-dev qt6-declarative-dev

# 验证安装
qmake6 --version
```

**Fedora/RHEL**:
```bash
sudo dnf install qt6-qtbase-devel

# 验证
qmake-qt6 --version
```

**Arch Linux**:
```bash
sudo pacman -S qt6-base

# 验证
qmake6 --version
```

#### Windows

**方法1: 使用Qt在线安装器 (推荐)**

1. **下载安装器**:
   - 访问: https://www.qt.io/download
   - 下载在线安装器: `qt-unified-windows-x64-online.exe`

2. **运行安装器**:
   - 双击运行安装器
   - 登录Qt账号(可免费注册)
   - 选择安装位置，建议: `C:\Qt`

3. **选择组件**:
   - 勾选 Qt 6.x.x
   - 勾选编译器:
     - MSVC 2019 64-bit (如已安装Visual Studio)
     - 或 MinGW 11.2.0 64-bit
   - 建议选择"Qt 6.x.x"下的所有组件

4. **完成安装并配置环境变量**:
   ```powershell
   # 设置Qt6路径 (根据实际安装路径调整)
   setx QTDIR "C:\Qt\6.5.3\msvc2019_64"
   
   # 添加到PATH
   setx PATH "%PATH%;%QTDIR%\bin"
   ```

5. **验证安装**:
   ```powershell
   # 检查环境变量
   echo %QTDIR%
   
   # 检查qmake
   "%QTDIR%\bin\qmake.exe" --version
   ```

**方法2: 使用vcpkg (高级用户)**
```powershell
# 安装vcpkg
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
.\bootstrap-vcpkg.bat

# 安装Qt6
.\vcpkg install qt6-base:x64-windows
```

#### macOS

**方法1: 使用Homebrew (推荐)**
```bash
# 安装Qt6
brew install qt

# 查看安装路径
brew --prefix qt

# 验证
qmake --version  # 应显示 Qt version 6.x.x
```

**方法2: 使用Qt官方安装器**
- 步骤类似Windows安装器
- 安装路径建议: `/Users/你的用户名/Qt`

### 2.3 安装CMake

**版本要求**: >= 3.16

#### Linux

**方法1: 包管理器 (推荐)**
```bash
# Ubuntu/Debian
sudo apt install cmake

# Fedora/RHEL
sudo dnf install cmake

# Arch Linux
sudo pacman -S cmake
```

**方法2: 官方二进制包 (获取最新版)**
```bash
# 下载
wget https://github.com/Kitware/CMake/releases/download/v3.28.0/cmake-3.28.0-linux-x86_64.sh

# 安装
chmod +x cmake-3.28.0-linux-x86_64.sh
sudo ./cmake-3.28.0-linux-x86_64.sh --prefix=/usr/local

# 验证
cmake --version
```

#### Windows

**方法1: 使用安装程序 (推荐)**
1. 访问: https://cmake.org/download/
2. 下载: `cmake-3.28.0-windows-x86_64.msi`
3. 运行安装程序，选择"Add CMake to the system PATH"
4. 验证:
   ```powershell
   cmake --version
   ```

**方法2: 使用winget**
```powershell
winget install Kitware.CMake
```

#### macOS

**使用Homebrew (推荐)**:
```bash
brew install cmake

# 验证
cmake --version
```

### 2.4 环境验证检查列表

完成所有依赖安装后，请逐项检查:

- [ ] **仓颉编译器已安装**
  ```bash
  cjpm --version
  # 应输出: cjpm version 1.x.x
  ```

- [ ] **Qt6已安装**
  - Linux/macOS:
    ```bash
    qmake6 --version  # 或 qmake --version (macOS)
    # 应输出: QMake version 3.1
    # Using Qt version 6.x.x
    ```
  - Windows:
    ```powershell
    echo %QTDIR%  # 应显示Qt安装路径
    ```

- [ ] **CMake已安装**
  ```bash
  cmake --version
  # 应输出: cmake version 3.x.x
  ```

- [ ] **版本号满足最低要求**
  - 仓颉 >= 1.0.0 ✓
  - Qt6 >= 6.2 ✓
  - CMake >= 3.16 ✓

---

## 3. 构建步骤

> 💡 **提示**: 确保已完成[环境准备](#2-环境准备)中的所有步骤。

### 3.1 创建构建目录

**命令**:
```bash
mkdir native/build && cd native/build
```

**详细说明**:

**`mkdir native/build`**:
- **作用**: 在`native`目录下创建`build`子目录
- **原因**: CMake推荐在独立目录中进行构建(out-of-source build)
- **好处**: 
  - 不污染源码目录
  - 易于清理构建产物(直接删除build目录)
  - 支持多种构建配置(Debug/Release)

**`cd native/build`**:
- **作用**: 进入构建目录
- **原因**: 后续命令需在构建目录中执行

**目录结构变化**:
```
构建前:
native/
├── includes/
└── src/

构建后:
native/
├── includes/
├── src/
└── build/  ← 新建目录
```

### 3.2 配置构建系统

**命令**:
```bash
cmake ..
```

**详细说明**:

**`cmake ..`**:
- **作用**: 运行CMake配置，生成平台特定的构建文件
- **参数 `..`**: 指向父目录的`CMakeLists.txt`配置文件
- **执行过程**:
  1. 读取`CMakeLists.txt`
  2. 检测Qt6安装路径
  3. 检测C++编译器(g++/clang++/MSVC)
  4. 生成构建文件(Makefile或VS项目文件)

**常见输出信息含义**:
```
-- The CXX compiler identification is GNU 11.3.0
✓ 检测到C++编译器为GCC 11.3.0

-- Found Qt6: /usr/lib/x86_64-linux-gnu/cmake/Qt6 (found version "6.4.2")
✓ 找到Qt6，版本6.4.2

-- Configuring done
-- Generating done
-- Build files have been written to: /path/to/native/build
✓ 配置成功，生成构建文件完成
```

**可选参数**:

指定Qt6路径(如自动检测失败):
```bash
cmake .. -DCMAKE_PREFIX_PATH=/path/to/Qt6
```

指定构建类型:
```bash
cmake .. -DCMAKE_BUILD_TYPE=Release  # Release版本
cmake .. -DCMAKE_BUILD_TYPE=Debug    # Debug版本(含调试信息)
```

### 3.3 编译桥接库

**命令 (Linux/macOS)**:
```bash
make -j$(nproc)
```

**命令 (Windows)**:
```powershell
cmake --build . --config Release
```

**详细说明**:

**`make`**:
- **作用**: 执行Makefile中定义的编译和链接任务
- **过程**:
  1. 编译C++源文件 → 生成目标文件(.o)
  2. 链接目标文件和Qt6库 → 生成动态库

**`-j$(nproc)`**:
- **作用**: 并行编译，加速构建过程
- **`$(nproc)`**: 获取CPU核心数
- **效果**: 充分利用多核CPU，显著加快编译速度

**编译产物**:

| 平台 | 库文件位置 | 文件名 |
|------|-----------|--------|
| Linux | `native/build/lib/` | `libcjfw_bridge.so` |
| Windows | `native/build/bin/` 或 `native/build_win64/bin/` | `libjfw_bridge.dll` |
| macOS | `native/build/lib/` | `libcjfw_bridge.dylib` |

**验证库文件已生成**:
```bash
# Linux
ls native/build/lib/libcjfw_bridge.so

# macOS
ls native/build/lib/libcjfw_bridge.dylib

# Windows (PowerShell)
dir native\build_win64\bin\libjfw_bridge.dll
```

### 3.4 构建仓颉项目

**命令**:
```bash
cd ../..  # 返回项目根目录
cjpm build
```

**详细说明**:

**`cjpm build`**:
- **作用**: 使用仓颉包管理器编译仓颉源代码
- **过程**:
  1. 读取`cjpm.toml`项目配置
  2. 编译仓颉源代码
  3. 链接FFI桥接库
  4. 生成构建产物

**构建产物位置**:
- 库文件: `target/release/`
- 可执行文件: `target/release/bin/`

### 3.5 完整构建命令汇总

**Linux/macOS**:
```bash
# 步骤1: 构建FFI桥接库
mkdir -p native/build && cd native/build
cmake ..
make -j$(nproc)
cd ../..

# 步骤2: 构建仓颉项目
cjpm build
```

**Windows (PowerShell)**:
```powershell
# 步骤1: 构建FFI桥接库
New-Item -ItemType Directory -Force -Path native\build
cd native\build
cmake .. -G "Visual Studio 17 2022" -A x64
cmake --build . --config Release
cd ..\..

# 步骤2: 构建仓颉项目
cjpm build
```

---

## 4. 构建验证

完成构建后，请按以下步骤验证构建成功。

### 4.1 验证FFI桥接库

**Linux**:
```bash
ls -lh native/build/lib/libcjfw_bridge.so
# 应显示库文件信息，文件大小应>0
```

**Windows**:
```powershell
dir native\build_win64\bin\libjfw_bridge.dll
# 应显示库文件信息
```

**macOS**:
```bash
ls -lh native/build/lib/libcjfw_bridge.dylib
# 应显示库文件信息
```

### 4.2 验证仓颉构建产物

```bash
# 检查target目录
ls target/release/

# 应包含:
# - 编译生成的库文件或可执行文件
```

### 4.3 运行示例程序验证

**运行最小窗口示例**:
```bash
cjpm run --example hello_window
```

**预期结果**:
- ✓ 程序启动无错误
- ✓ 显示一个GUI窗口
- ✓ 窗口标题为"Hello Window"或类似
- ✓ 可正常关闭窗口
- ✓ 程序正常退出，无崩溃

**如果验证失败**:
1. 检查终端输出的错误信息
2. 参考[错误诊断](#5-错误诊断)章节
3. 检查动态库路径是否正确

### 4.4 完整验证检查列表

- [ ] FFI桥接库文件存在
- [ ] 桥接库文件大小 > 0
- [ ] 仓颉构建产物已生成
- [ ] 示例程序可正常运行
- [ ] 示例窗口可正常显示

✅ **全部检查通过**: 恭喜！构建成功，您可以开始使用CJQT6了。

---

## 5. 错误诊断

本章按错误类型分类，提供常见构建错误的诊断和解决方案。

### 5.1 依赖缺失错误

| 错误信息 | 原因 | 解决方案 |
|---------|------|---------|
| `cjpm: command not found` | 仓颉编译器未安装或PATH未配置 | 按[2.1 安装仓颉编译器](#21-安装仓颉编译器)安装 |
| `CMake Error: Could not find Qt6` | Qt6未安装或路径未设置 | 按[2.2 安装Qt6](#22-安装qt6)安装，或设置`CMAKE_PREFIX_PATH` |
| `cmake: command not found` | CMake未安装或PATH未配置 | 按[2.3 安装CMake](#23-安装cmake)安装 |
| `CMake Error: CMake was not able to find a build program` | 缺少make或构建工具 | Linux: `sudo apt install build-essential`<br>Windows: 安装Visual Studio或MinGW |

**案例: Qt6路径未找到**

**错误输出**:
```
CMake Error at CMakeLists.txt:10 (find_package):
  Could not find a package configuration file provided by "Qt6" with any of
  the following names:
    Qt6Config.cmake
    qt6-config.cmake
```

**诊断步骤**:
1. 检查Qt6是否已安装: `qmake6 --version`
2. 如已安装，找到Qt6的cmake路径:
   ```bash
   # Linux (apt安装)
   /usr/lib/x86_64-linux-gnu/cmake/Qt6
   
   # macOS (Homebrew)
   $(brew --prefix qt)/lib/cmake/Qt6
   
   # Windows
   C:\Qt\6.x.x\msvc2019_64\lib\cmake\Qt6
   ```
3. 在cmake命令中指定路径:
   ```bash
   cmake .. -DCMAKE_PREFIX_PATH=/path/to/Qt6
   ```

### 5.2 编译错误

| 错误信息 | 原因 | 解决方案 |
|---------|------|---------|
| `fatal error: QWidget: No such file or directory` | Qt6头文件路径错误 | 检查Qt6开发包是否安装:<br>`sudo apt install qt6-base-dev` |
| `error: 'QApplication' has no member named 'xxx'` | Qt6版本过低，缺少新API | 升级Qt6到>= 6.2版本 |
| `undefined reference to 'QApplication::QApplication()'` | Qt6库未链接到项目 | 检查`CMakeLists.txt`中的`target_link_libraries` |
| `C++ compiler not found` | 缺少C++编译器 | Linux: `sudo apt install g++`<br>Windows: 安装Visual Studio |

### 5.3 链接错误

| 错误信息 | 原因 | 解决方案 |
|---------|------|---------|
| `cannot find -lcjfw_bridge` | FFI桥接库未构建 | 先执行[3.3 编译桥接库](#33-编译桥接库) |
| `error while loading shared libraries: libcjfw_bridge.so: cannot open shared object file` | 运行时找不到动态库 | 设置`LD_LIBRARY_PATH`:<br>`export LD_LIBRARY_PATH=native/build/lib:$LD_LIBRARY_PATH` |
| `The specified module could not be found` (Windows) | DLL路径未在PATH中 | 将DLL目录加入PATH或复制到可执行文件目录 |

**案例: 动态库加载失败**

**错误输出 (Linux)**:
```
error while loading shared libraries: libcjfw_bridge.so: 
cannot open shared object file: No such file or directory
```

**解决方案**:

**方法1: 设置环境变量**
```bash
export LD_LIBRARY_PATH=$PWD/native/build/lib:$LD_LIBRARY_PATH
```

**方法2: 使用rpath (编译时设置)**
在`cjpm.toml`中配置库搜索路径。

**方法3: 复制库文件 (不推荐)**
```bash
cp native/build/lib/libcjfw_bridge.so /usr/lib/
```

### 5.4 运行时错误

| 错误信息 | 原因 | 解决方案 |
|---------|------|---------|
| `Segmentation fault (core dumped)` | 空指针访问或内存错误 | 检查对象初始化，参考[资源管理指南](resource-management.md) |
| `QWidget: Must construct a QApplication before a QWidget` | 未先创建QApplication | 确保main()中首先创建`QApplication()` |
| `SIGSEGV: address not mapped to object` | 访问已释放的对象 | 检查对象生命周期，使用调试版本构建 |
| `This application failed to start because no Qt platform plugin could be initialized` | Qt平台插件缺失 | Linux: `sudo apt install qt6-platform-plugins` |

### 5.5 Windows特定错误

| 错误信息 | 原因 | 解决方案 |
|---------|------|---------|
| `CMake Error: Could not find CMAKE_C_COMPILER` | Visual Studio未安装或未配置 | 安装Visual Studio 2019或2022，选择"使用C++的桌面开发" |
| `LINK : fatal error LNK1181: cannot open input file 'Qt6.lib'` | Qt6库路径未设置 | 设置环境变量`QTDIR`，或在CMake中指定 |
| `The code execution cannot proceed because Qt6Core.dll was not found` | 运行时Qt DLL未找到 | 将`%QTDIR%\bin`加入PATH，或复制DLL到程序目录 |

### 5.6 错误诊断流程

遇到构建错误时，按以下流程诊断:

```
错误发生
    ↓
1. 阅读完整错误信息
    ↓
2. 在本章查找匹配的错误类型
    ↓
找到 → 按解决方案处理
    ↓
未找到 ↓
    ↓
3. 检查环境依赖
   - 仓颉版本
   - Qt6版本和路径
   - CMake版本
    ↓
4. 检查构建步骤顺序
   - 是否先构建桥接库
   - 是否在正确目录执行命令
    ↓
5. 搜索解决方案
   - 项目Issue: https://gitcode.com/yuan_1992/CJQT6/issues
   - 仓颉社区
   - Qt论坛
    ↓
6. 提交Issue (如仍无法解决)
   - 使用Issue模板
   - 附上完整错误日志
   - 说明环境信息
```

### 5.7 如何提交有效的Issue

如果遇到文档中未覆盖的错误，欢迎提交Issue。

**Issue模板**:
```markdown
### 环境信息
- 操作系统: [如 Ubuntu 22.04]
- 仓颉版本: [cjpm --version输出]
- Qt6版本: [qmake6 --version输出]
- CMake版本: [cmake --version输出]

### 构建步骤
[列出执行的命令]

### 错误信息
```
[粘贴完整错误输出]
```

### 已尝试的解决方案
[描述已尝试的方法]
```

---

## 6. 平台特定说明

### 6.1 Linux详细说明

#### 6.1.1 依赖安装 (Ubuntu/Debian)

```bash
# 完整依赖安装
sudo apt update
sudo apt install -y \
    build-essential \
    cmake \
    qt6-base-dev \
    qt6-base-dev-tools \
    qt6-multimedia-dev \
    pkg-config

# 验证
cjpm --version
qmake6 --version
cmake --version
pkg-config --modversion Qt6
```

#### 6.1.2 构建命令

```bash
# 完整构建流程
git clone https://gitcode.com/yuan_1992/CJQT6.git
cd CJQT6

# 构建FFI桥接库
mkdir -p native/build && cd native/build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
cd ../..

# 构建仓颉项目
cjpm build --release

# 验证
cjpm run --example hello_window
```

#### 6.1.3 环境变量 (如需)

```bash
# 如果Qt6安装到自定义路径
export Qt6_DIR=/custom/path/to/Qt6/lib/cmake/Qt6
export LD_LIBRARY_PATH=/custom/path/to/Qt6/lib:$LD_LIBRARY_PATH
```

#### 6.1.4 常见问题

**问题: Qt6包找不到**
```bash
# Ubuntu 20.04可能没有Qt6包
# 解决方案: 使用Qt官方安装器或升级到Ubuntu 22.04
```

**问题: Wayland显示问题**
```bash
# 如果GUI在Wayland下有问题
export QT_QPA_PLATFORM=xcb  # 使用X11后端
```

### 6.2 Windows详细说明

#### 6.2.1 前置要求

- Visual Studio 2019或2022 (推荐社区版，免费)
  - 安装时勾选"使用C++的桌面开发"
- 或 MinGW-w64 (GCC for Windows)

#### 6.2.2 依赖安装

**Visual Studio安装**:
1. 下载: https://visualstudio.microsoft.com/zh-hans/downloads/
2. 运行安装程序
3. 选择"使用C++的桌面开发"
4. 完成安装

**Qt6安装**:
- 参见[2.2 安装Qt6 - Windows](#22-安装qt6)
- 建议安装路径: `C:\Qt\6.x.x\msvc2019_64`

**环境变量配置**:
```powershell
# Qt6
setx QTDIR "C:\Qt\6.5.3\msvc2019_64"

# PATH
setx PATH "%PATH%;%QTDIR%\bin;C:\Program Files\CMake\bin"
```

#### 6.2.3 构建命令 (PowerShell)

```powershell
# 克隆项目
git clone https://gitcode.com/yuan_1992/CJQT6.git
cd CJQT6

# 构建FFI桥接库
New-Item -ItemType Directory -Force -Path native\build
cd native\build

# 生成Visual Studio项目
cmake .. -G "Visual Studio 17 2022" -A x64

# 编译 (Release版本)
cmake --build . --config Release

cd ..\..

# 构建仓颉项目
cjpm build --release

# 验证
cjpm run --example hello_window
```

#### 6.2.4 使用CMake GUI (可选)

1. 打开CMake GUI
2. 设置源码路径: `C:/path/to/CJQT6/native`
3. 设置构建路径: `C:/path/to/CJQT6/native/build`
4. 点击"Configure"，选择Visual Studio生成器
5. 点击"Generate"
6. 点击"Open Project"打开VS
7. 在VS中构建项目

#### 6.2.5 常见问题

**问题: 路径包含空格**
```
错误: CMake Error: The source directory "C:/My Documents/CJQT6" contains spaces
解决: 将项目移动到无空格路径，如 C:\Projects\CJQT6
```

**问题: MSVC编译器未找到**
```
错误: Could not find CMAKE_CXX_COMPILER
解决: 
1. 确认Visual Studio已安装
2. 打开"x64 Native Tools Command Prompt for VS 2022"
3. 在该命令提示符中执行构建命令
```

### 6.3 macOS详细说明

#### 6.3.1 依赖安装

```bash
# 安装Xcode命令行工具
xcode-select --install

# 安装Homebrew (如未安装)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装依赖
brew install cmake qt

# 安装仓颉编译器
# 参见[2.1 安装仓颉编译器 - macOS](#21-安装仓颉编译器)
```

#### 6.3.2 构建命令

```bash
# 克隆项目
git clone https://gitcode.com/yuan_1992/CJQT6.git
cd CJQT6

# 构建FFI桥接库
mkdir -p native/build && cd native/build

# 注意: 指定Qt6路径
cmake .. -DCMAKE_PREFIX_PATH=$(brew --prefix qt)

make -j$(sysctl -n hw.ncpu)
cd ../..

# 构建仓颉项目
cjpm build --release

# 验证
cjpm run --example hello_window
```

#### 6.3.3 常见问题

**问题: Qt framework未找到**
```bash
# 设置CMAKE_PREFIX_PATH
cmake .. -DCMAKE_PREFIX_PATH=$(brew --prefix qt)
# 或
cmake .. -DCMAKE_PREFIX_PATH=/usr/local/Cellar/qt/6.x.x
```

**问题: 签名问题**
```bash
# 如果运行时提示签名问题
# 允许任意来源的应用(谨慎使用)
sudo spctl --master-disable
```

---

## 7. 进阶主题

### 7.1 自定义Qt6路径

如果Qt6安装到非标准路径，需要在CMake配置时指定:

```bash
cmake .. -DCMAKE_PREFIX_PATH=/your/custom/path/to/Qt6
```

多个路径:
```bash
cmake .. -DCMAKE_PREFIX_PATH="/path1;/path2;/path3"
```

### 7.2 调试版本构建

**FFI桥接库调试版本**:
```bash
cd native/build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make
```

**仓颉项目调试版本**:
```bash
cjpm build --debug
```

### 7.3 交叉编译

**为不同平台编译 (高级)**:
```bash
# 示例: 为ARM64编译
cmake .. -DCMAKE_SYSTEM_NAME=Linux \
         -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
         -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc \
         -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++
```

### 7.4 清理构建产物

**清理FFI桥接库**:
```bash
rm -rf native/build
```

**清理仓颉构建**:
```bash
cjpm clean
```

**完全清理**:
```bash
rm -rf native/build target/
```

### 7.5 查看构建选项

```bash
cd native/build
cmake .. -L  # 列出所有CMake选项
```

### 7.6 性能优化构建

**启用LTO (链接时优化)**:
```bash
cmake .. -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON
```

**使用更快的链接器 (Linux)**:
```bash
# 安装lld
sudo apt install lld

# 配置CMake使用lld
cmake .. -DCMAKE_LINKER=lld
```

---

## 相关文档

- [项目架构设计](architecture.md) - 了解CJQT6整体架构
- [资源管理指南](resource-management.md) - 了解内存管理和对象生命周期
- [快速入门教程](tutorial/) - 学习如何使用CJQT6开发应用
