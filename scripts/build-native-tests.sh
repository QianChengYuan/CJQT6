#!/bin/bash
# 用法：在 CJQT6 根目录下运行
#   bash scripts/build-native-tests.sh [-asan]
# 编译并运行桥接层 C++ 单元测试（P0-3：存活表三件套 + 字符串工具）。
# 使用独立构建目录 native/build_native_tests，不影响 bridge 主构建。
# -asan：启用 AddressSanitizer（字符串泄漏检测，需可执行 ASAN 的编译器/运行时）。

set -e

ASAN="OFF"
for arg in "$@"; do
    case "$arg" in
        -asan) ASAN="ON" ;;
        *) echo "未知参数: $arg（支持 -asan）"; exit 1 ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

# 检测Qt6路径
if [ -z "$QTDIR" ]; then
    for path in /usr/lib/qt6 /usr/lib/x86_64-linux-gnu/qt6 /opt/qt6; do
        if [ -d "$path" ]; then
            QTDIR="$path"
            break
        fi
    done
fi
if [ -z "$QTDIR" ]; then
    echo "错误: 未找到Qt6安装路径（请设置 QTDIR 或安装Qt6到标准路径）"
    exit 1
fi
echo "Qt6路径: $QTDIR"

BUILD_DIR="$PROJECT_DIR/native/build_native_tests"
mkdir -p "$BUILD_DIR"

echo "[1/3] cmake configure ..."
cd "$BUILD_DIR"
cmake "$PROJECT_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="$QTDIR" \
    -DCJQT6_BUILD_TESTS=ON \
    -DCJQT6_NATIVE_TESTS_ASAN="$ASAN"

echo "[2/3] 编译 bridge_core_tests ..."
cmake --build . --config Release --target bridge_core_tests -j"$(nproc)"

echo "[3/3] ctest 运行 ..."
export ASAN_OPTIONS=detect_leaks=1
export LD_LIBRARY_PATH="$BUILD_DIR/lib:$QTDIR/lib:${LD_LIBRARY_PATH:-}"
ctest --output-on-failure -C Release -R bridge_core_tests

echo "✅ 桥接层 C++ 单元测试全部通过"
