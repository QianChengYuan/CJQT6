#!/bin/bash
# Linux x86_64 构建脚本

set -e

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
BUILD_DIR="native/build-linux-x64"
mkdir -p "$BUILD_DIR"

# CMake配置
echo "配置CMake..."
cd "$BUILD_DIR"
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_PREFIX_PATH="$QTDIR" \
    -DCMAKE_INSTALL_RPATH="\$ORIGIN" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=TRUE

# 构建
echo "开始构建..."
cmake --build . --config Release -j$(nproc)

# 验证构建产物
if [ -f "libcjfw_bridge.so" ]; then
    echo "======================================"
    echo "构建成功!"
    echo "======================================"
    echo "产物位置: $(pwd)/libcjfw_bridge.so"
    file libcjfw_bridge.so
    echo ""
    echo "依赖库:"
    ldd libcjfw_bridge.so || true
else
    echo "错误: 构建产物未生成"
    exit 1
fi
