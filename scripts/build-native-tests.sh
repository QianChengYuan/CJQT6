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