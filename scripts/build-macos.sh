#!/bin/bash
# CJQT6 macOS编译脚本
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    RELEASE_DIR="$PROJECT_ROOT/releases/macos-x64"
    QT_PATH="/usr/local/opt/qt@6"
    ARCH_NAME="Intel"
else
    RELEASE_DIR="$PROJECT_ROOT/releases/macos-arm64"
    QT_PATH="/opt/homebrew/opt/qt@6"
    ARCH_NAME="Apple Silicon"
fi

echo "=== 编译macOS $ARCH_NAME桥接库 ==="

# 检查Qt6
if [ ! -d "$QT_PATH" ]; then
    echo "❌ 错误: 未找到Qt6 at $QT_PATH"
    echo "安装: brew install qt@6"
    exit 1
fi

# 清理旧构建
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 配置CMake
echo "配置CMake..."
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="$QT_PATH" \
    -DCMAKE_OSX_ARCHITECTURES="$ARCH"

# 编译
echo "编译中..."
make -j$(sysctl -n hw.ncpu)

# 安装
mkdir -p "$RELEASE_DIR"
cp lib/libcjqt6_bridge.dylib "$RELEASE_DIR/"

echo ""
echo "✅ 编译完成: $RELEASE_DIR/libcjqt6_bridge.dylib"
ls -lh "$RELEASE_DIR/libcjqt6_bridge.dylib"
echo ""
echo "验证依赖:"
otool -L "$RELEASE_DIR/libcjqt6_bridge.dylib" | head -10
