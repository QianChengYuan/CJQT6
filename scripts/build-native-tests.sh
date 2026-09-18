#!/bin/bash
# ============================================================
# build-native-tests.sh — 桥接层 C++ 单元测试构建与运行
# ------------------------------------------------------------
# 用法:
#   bash scripts/build-native-tests.sh            # 默认构建并跑测试
#   bash scripts/build-native-tests.sh -asan      # 启用 AddressSanitizer
#   bash scripts/build-native-tests.sh -h         # 显示帮助
# 选项:
#   -asan           启用 AddressSanitizer(字符串泄漏检测,需可执行 ASAN 的编译器/运行时)
#   -h, --help      显示帮助
# 产物:native/build_native_tests 编译产物 + ctest 运行 bridge_core_tests
# 使用独立构建目录,不影响 bridge 主构建
# 共享函数:scripts/lib/common.sh
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"

ROOT_DIR="$(get_root_dir "${BASH_SOURCE[0]}")"
BUILD_DIR="$ROOT_DIR/native/build_native_tests"

ASAN_OPT="OFF"
for arg in "$@"; do
    case "$arg" in
        -asan|--asan) ASAN_OPT="ON" ;;
        -h|--help)
            echo "用法: bash scripts/build-native-tests.sh [-asan]"
            echo "  -asan   启用 AddressSanitizer(字符串泄漏检测)"
            exit 0
            ;;
        *) die "未知参数: $arg(可用 -asan / -h)" ;;
    esac
done

print_section "桥接层 C++ 单元测试(build-native-tests)"

QT="$(find_qt || true)"
if [ -z "$QT" ]; then
    die "未找到 Qt6,请设置 QTDIR 或安装 Qt6 开发包"
fi
echo "Qt6 路径: $QT"
echo "ASAN: $ASAN_OPT"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 与 scripts/build-native-tests.ps1 保持同一组 CMake 选项
cmake "$ROOT_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="$QT" \
    -DQt6_DIR="$QT/lib/cmake/Qt6" \
    -DCJQT6_BUILD_TESTS=ON \
    -DCJQT6_NATIVE_TESTS_ASAN="$ASAN_OPT"

JOBS="$(get_jobs)"
cmake --build . --config Release --target bridge_core_tests -j "$JOBS"

# 运行时需能加载 Qt 与桥接库(测试可执行文件位于 bin/,桥接库同目录)
case "$(detect_platform)" in
    macos-*)
        export DYLD_LIBRARY_PATH="$QT/lib:${DYLD_LIBRARY_PATH:-}"
        ;;
    *)
        export LD_LIBRARY_PATH="$QT/lib:${LD_LIBRARY_PATH:-}"
        ;;
esac

print_section "ctest 运行"
ctest --output-on-failure -C Release -R bridge_core_tests

echo "✅ 桥接层 C++ 单元测试全部通过"
