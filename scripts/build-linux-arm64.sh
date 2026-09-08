#!/bin/bash
# Linux ARM64 (aarch64) 原生构建脚本
#
# 前置条件：
#   1. 在 ARM64 Linux 主机上运行（或使用 ubuntu-24.04-arm 等原生 ARM runner）
#   2. 已安装 Qt6（>= 6.2，含 Core/Gui/Widgets/Qml/Quick/Sql/Multimedia/Charts 组件）
#   3. 已安装 CMake >= 3.16 与 C++17 编译器（gcc/g++）
#
# 用法：
#   QTDIR=/path/to/Qt6 bash scripts/build-linux-arm64.sh
#
# 产物：releases/linux-arm64/libcjqt6_bridge.so

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "======================================"
echo "构建 FFI Bridge - Linux ARM64 (aarch64)"
echo "======================================"

# 检测架构（必须为 aarch64，否则无法原生链接 aarch64 运行时库）
ARCH="$(uname -m)"
if [ "$ARCH" != "aarch64" ] && [ "$ARCH" != "arm64" ]; then
    echo "警告: 当前架构为 $ARCH，非 ARM64。"
    echo "本脚本用于 ARM64 原生构建。如需从 x64 交叉编译，请参考 docs/guides/cross-compile.md。"
    echo "若使用 qemu-user 模拟 aarch64 环境可继续，但性能较差。"
fi

# 检测 Qt6 路径
if [ -z "$QTDIR" ]; then
    # 尝试常见路径
    for path in /usr/lib/qt6 /usr/lib/aarch64-linux-gnu/qt6 /opt/qt6 /usr/local/Qt6; do
        if [ -d "$path" ]; then
            QTDIR="$path"
            break
        fi
    done
fi

if [ -z "$QTDIR" ]; then
    echo "错误: 未找到 Qt6 安装路径"
    echo "请设置环境变量 QTDIR 指向 Qt6 安装目录（含 lib/cmake/Qt6）"
    echo "或通过 apt 安装（推荐）: sudo apt-get install qt6-base-dev qt6-declarative-dev qt6-multimedia-dev qt6-charts-dev"
    echo "  然后设置 QTDIR=/usr/lib/aarch64-linux-gnu"
    exit 1
fi

echo "Qt6 路径: $QTDIR"
echo "当前架构: $ARCH"

# 创建构建目录
BUILD_DIR="$PROJECT_DIR/native/build-linux-arm64"
mkdir -p "$BUILD_DIR"

# CMake 配置
echo "配置 CMake..."
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
    RELEASE_DIR="$PROJECT_DIR/releases/linux-arm64"
    mkdir -p "$RELEASE_DIR"
    cp lib/libcjqt6_bridge.so "$RELEASE_DIR/"
    echo "已部署到: $RELEASE_DIR/libcjqt6_bridge.so"
else
    echo "错误: 构建产物未生成"
    exit 1
fi
