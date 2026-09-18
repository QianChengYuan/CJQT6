#!/bin/bash
# ============================================================
# build-linux-arm64.sh — Linux aarch64 FFI 桥接库构建脚本
# ------------------------------------------------------------
# 用法:
#   bash scripts/build-linux-arm64.sh                    # 默认构建(探测常见 Qt6 路径)
#   QTDIR=/custom/qt6 bash scripts/build-linux-arm64.sh  # 指定 Qt6 路径
# 产物:releases/linux-arm64/libcjqt6_bridge.so
# 共享函数:scripts/lib/common.sh
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"

ROOT_DIR="$(get_root_dir "${BASH_SOURCE[0]}")"
PLATFORM_DIR="releases/linux-arm64"
BUILD_DIR="$ROOT_DIR/native/build_linux_arm64"

print_section "编译 FFI Bridge - Linux aarch64"

QT="$(find_qt || true)"
if [ -z "$QT" ]; then
    die "未找到 Qt6,请设置 QTDIR 或安装 Qt6 开发包(见 scripts/lib/common.sh 的 find_qt)"
fi
echo "Qt6 路径: $QT"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 显式传 Qt6_DIR:CMake 缓存中的旧 Qt6_DIR 优先级高于 CMAKE_PREFIX_PATH。
cmake "$ROOT_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="$QT" \
    -DQt6_DIR="$QT/lib/cmake/Qt6" \
    -DCMAKE_INSTALL_RPATH='$ORIGIN'

JOBS="$(get_jobs)"
cmake --build . --config Release --target cjqt6_bridge -j "$JOBS"

RELEASE_DIR="$ROOT_DIR/$PLATFORM_DIR"
mkdir -p "$RELEASE_DIR"
cp lib/libcjqt6_bridge.so "$RELEASE_DIR/"
echo "已部署: $PLATFORM_DIR/libcjqt6_bridge.so"
