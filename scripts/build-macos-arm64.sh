#!/bin/bash
# ============================================================
# build-macos-arm64.sh — macOS Apple Silicon(arm64)构建脚本
# ------------------------------------------------------------
# 用法:
#   bash scripts/build-macos-arm64.sh                    # 默认构建(brew 探测 Qt6)
#   QTDIR=/custom/qt6 bash scripts/build-macos-arm64.sh  # 指定 Qt6 路径
# 前置:`brew install qt@6`
# 产物:releases/macos-arm64/libcjqt6_bridge.dylib
# 共享函数:scripts/lib/common.sh
# ============================================================

set -euo pipefail