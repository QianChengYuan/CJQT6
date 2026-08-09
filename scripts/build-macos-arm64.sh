#!/bin/bash
# macOS Apple Silicon (arm64) 构建脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "======================================"
echo "构建 FFI Bridge - macOS arm64"
echo "======================================"

# 检测Qt6路径
if [ -z "$QTDIR" ]; then
    # 尝试通过brew检测
    if command -v brew &> /dev/null; then
        QTDIR=$(brew --prefix qt@6 2>/dev/null || true)
    fi

    # 尝试常见路径
    for path in /opt/homebrew /usr/local/qt6 /opt/qt6; do
        if [ -d "$path" ]; then
            QTDIR="$path"
            break
        fi
    done
fi

if [ -z "$QTDIR" ]; then
    echo "错误: 未找到Qt6安装路径"
    echo "请通过brew安装: brew install qt@6"
    echo "或设置环境变量 QTDIR"
    exit 1
fi

echo "Qt6路径: $QTDIR"

# 创建构建目录
BUILD_DIR="$PROJECT_DIR/native/build-macos-arm64"
mkdir -p "$BUILD_DIR"

# CMake配置
echo "配置CMake..."
cd "$BUILD_DIR"
cmake "$PROJECT_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="$QTDIR" \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_INSTALL_RPATH="@rpath" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=TRUE

# 构建
echo "开始构建..."
cmake --build . --config Release -j$(sysctl -n hw.ncpu)

# 验证构建产物
if [ -f "lib/libcjqt6_bridge.dylib" ]; then
    echo "======================================"
    echo "构建成功!"
    echo "======================================"
    echo "产物位置: $(pwd)/lib/libcjqt6_bridge.dylib"
    file lib/libcjqt6_bridge.dylib
    echo ""
    echo "依赖库:"
    otool -L lib/libcjqt6_bridge.dylib || true
else
    echo "错误: 构建产物未生成"
    exit 1
fi

# 部署到 releases/
echo ""
echo "部署到 releases/macos-arm64 ..."
RELEASE_DIR="$PROJECT_DIR/releases/macos-arm64"
mkdir -p "$RELEASE_DIR"
cp "lib/libcjqt6_bridge.dylib" "$RELEASE_DIR/"
echo "已复制: $RELEASE_DIR/libcjqt6_bridge.dylib"
