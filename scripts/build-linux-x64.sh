#!/bin/bash
# Linux x86_64 构建脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "======================================"
echo "构建 FFI Bridge - Linux x86_64"
echo "======================================"

# 检测Qt6路径
if [ -z "$QTDIR" ]; then
    # 尝试常见路径
    for path in /usr/lib/qt6 /usr/lib/x86_64-linux-gnu/qt6 /opt/qt6; do
        if [ -d "$path" ]; then
            QTDIR="$path"
            break
        fi
    done
fi

if [ -z "$QTDIR" ]; then
    echo "错误: 未找到Qt6安装路径"
    echo "请设置环境变量 QTDIR 或安装Qt6到标准路径"
    exit 1
fi

echo "Qt6路径: $QTDIR"

# 创建构建目录
BUILD_DIR="$PROJECT_DIR/native/build-linux-x64"
mkdir -p "$BUILD_DIR"

# CMake配置
echo "配置CMake..."
cd "$BUILD_DIR"
cmake "$PROJECT_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_PREFIX_PATH="$QTDIR" \
    -DCMAKE_INSTALL_RPATH="\$ORIGIN" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=TRUE

# 构建
echo "开始构建..."
cmake --build . --config Release -j$(nproc)

# 验证构建产物
if [ -f "lib/libcjqt6_bridge.so" ]; then
    echo "======================================"
    echo "构建成功!"
    echo "======================================"
    echo "产物位置: $(pwd)/lib/libcjqt6_bridge.so"
    file lib/libcjqt6_bridge.so
    echo ""
    echo "依赖库:"
    ldd lib/libcjqt6_bridge.so || true

    # 部署到 releases/
    RELEASE_DIR="$PROJECT_DIR/releases/linux-x64"
    mkdir -p "$RELEASE_DIR"
    cp lib/libcjqt6_bridge.so "$RELEASE_DIR/"
    echo "已部署到: $RELEASE_DIR/libcjqt6_bridge.so"
else
    echo "错误: 构建产物未生成"
    exit 1
fi
