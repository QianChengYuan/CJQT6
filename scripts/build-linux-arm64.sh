#!/bin/bash
# ============================================================
# build-linux-arm64.sh — Linux ARM64(aarch64)原生构建脚本
# ------------------------------------------------------------
# 用法:
#   bash scripts/build-linux-arm64.sh                   # 默认构建(需 aarch64 主机)
#   QTDIR=/custom/qt6 bash scripts/build-linux-arm64.sh  # 指定 Qt6 路径
# 前置:ARM64 主机 + Qt6 (>= 6.2) + CMake >= 3.16 + C++17 编译器
# 产物:releases/linux-arm64/libcjqt6_bridge.so
# 共享函数:scripts/lib/common.sh
# ============================================================

set -euo pipefail