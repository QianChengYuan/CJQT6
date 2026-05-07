#!/bin/bash
# CJQT6 Linux编译脚本
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
RELEASE_DIR="$PROJECT_ROOT/releases/linux-x64"

echo "=== 编译Linux x64桥接库 ==="

# 检查Qt6
if ! command -v qmake6 &> /dev/null; then
    echo "❌ 错误: 未找到Qt6"
    echo "安装: sudo apt install qt6-base-dev qt6-tools-dev"
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
    -DCMAKE_PREFIX_PATH=/usr/lib/qt6

# 编译
echo "编译中..."
make -j$(nproc)

# 安装
mkdir -p "$RELEASE_DIR"
cp lib/libcjqt6_bridge.so "$RELEASE_DIR/"

echo ""
echo "✅ 编译完成: $RELEASE_DIR/libcjqt6_bridge.so"
ls -lh "$RELEASE_DIR/libcjqt6_bridge.so"
echo ""
echo "验证依赖:"
ldd "$RELEASE_DIR/libcjqt6_bridge.so" | head -10
