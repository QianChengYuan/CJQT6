#!/bin/bash
# ============================================================
# setup-qt-env.sh — CJQT6 运行环境配置脚本(Linux/macOS/WSL)
# ------------------------------------------------------------
# 用法:
#   source ./scripts/setup-qt-env.sh                  # 配置环境(当前 shell 立即生效)
#   source ./scripts/setup-qt-env.sh && cjpm run      # 配置后直接运行命令
# 与 setup-qt-env.ps1 对称(Windows);共享函数走 scripts/lib/common.sh
# macOS 额外设置 DYLD_FRAMEWORK_PATH(framework 形式)
# ============================================================

set -e