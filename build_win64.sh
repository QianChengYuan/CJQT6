#!/bin/bash
# Windows x64 交叉编译脚本
# 需要先安装: sudo apt install mingw-w64
# 需要下载 Qt6 for Windows 并设置 QT6_WIN_PATH 环境变量

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/native/build-win64"

# Qt6 Windows 路径 - 默认使用 WSL 挂载的 Windows Qt 路径
if [ -z "$QT6_WIN_PATH" ]; then
    # 默认路径: Windows C:\Qt\6.10.2\mingw_64
    export QT6_WIN_PATH="/mnt/c/Qt/6.10.2/mingw_64"
    echo "使用默认 Qt6 路径: $QT6_WIN_PATH"
fi

echo "=========================================="
echo "CJFW Windows x64 交叉编译"
echo "=========================================="
echo "Qt6 路径: $QT6_WIN_PATH"
echo "构建目录: $BUILD_DIR"
echo ""

# 创建构建目录
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 运行 CMake
cmake ../.. \
    -DCMAKE_TOOLCHAIN_FILE="$SCRIPT_DIR/cmake/win64-mingw.cmake" \
    -DCMAKE_PREFIX_PATH="$QT6_WIN_PATH" \
    -DCMAKE_BUILD_TYPE=Release

# 编译
make cjfw_bridge -j$(nproc)

echo ""
echo "=========================================="
echo "编译完成!"
echo "输出文件: $BUILD_DIR/lib/cjfw_bridge.dll"
echo "=========================================="
