# ============================================================
# DEPRECATED — 仓颉 1.1.0 暂不提供 macOS x86_64 SDK,此平台不在官方支持矩阵。
# 保留脚本结构以便将来 SDK 发布后启用。
# 替代:macOS arm64 用户请用 build-macos-arm64.sh。
# 详见:releases/macos-x64/README.md 与 cjpm.toml [target.x86_64-apple-darwin](已注释)。
# ------------------------------------------------------------
# 用法(已废弃):
#   bash scripts/build-macos-x64.sh    # ⚠️ 仓颉 1.1.0 无 macOS x64 SDK,产物无法使用
# ============================================================
#!/bin/bash
# macOS x86_64 构建脚本(DEPRECATED)
# 仓颉 1.1.0 SDK 无 macOS x86_64 版本,此脚本当前无 CI 引用。

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "======================================"
echo "构建 FFI Bridge - macOS x86_64 (DEPRECATED)"
echo "======================================"
echo "⚠️  仓颉 1.1.0 SDK 无 macOS x86_64,产物无法使用"
echo ""

# 检测Qt6路径
if [ -z "$QTDIR" ]; then
    if command -v brew &> /dev/null; then
        QTDIR=$(brew --prefix qt@6 2>/dev/null || true)
    fi
    for path in /usr/local/qt6 /opt/qt6; do
        if [ -d "$path" ]; then
            QTDIR="$path"
            break
        fi
    done
fi

if [ -z "$QTDIR" ]; then
    echo "错误: 未找到Qt6安装路径"
    exit 1
fi

echo "Qt6路径: $QTDIR"

# 创建构建目录
BUILD_DIR="$PROJECT_DIR/native/build-macos-x64"
mkdir -p "$BUILD_DIR"

# CMake配置
cd "$BUILD_DIR"
cmake "$PROJECT_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="$QTDIR" \
    -DCMAKE_OSX_ARCHITECTURES=x86_64 \
    -DCMAKE_INSTALL_RPATH="@rpath" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=TRUE

cmake --build . --config Release -j$(sysctl -n hw.ncpu)

# 部署
if [ -f "lib/libcjqt6_bridge.dylib" ]; then
    RELEASE_DIR="$PROJECT_DIR/releases/macos-x64"
    mkdir -p "$RELEASE_DIR"
    cp lib/libcjqt6_bridge.dylib "$RELEASE_DIR/"
    echo "已部署: $RELEASE_DIR/libcjqt6_bridge.dylib"
fi