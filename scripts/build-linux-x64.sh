#!/bin/bash
# ============================================================
# build-linux-x64.sh — Linux x86_64 FFI 桥接库构建脚本
# ------------------------------------------------------------
# 用法:
#   bash scripts/build-linux-x64.sh                    # 默认构建(探测常见 Qt6 路径)
#   QTDIR=/custom/qt6 bash scripts/build-linux-x64.sh  # 指定 Qt6 路径
# 产物:releases/linux-x64/libcjqt6_bridge.so
# 共享函数:scripts/lib/common.sh
# ============================================================

set -euo pipefail