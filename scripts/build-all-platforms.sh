#!/bin/bash
# ============================================================
# build-all-platforms.sh — 统一构建入口(自动检测平台)
# ------------------------------------------------------------
# 用法:
#   bash scripts/build-all-platforms.sh   # 自动检测平台并调用对应 build-*.sh
# Windows 平台指引:此脚本无法处理,Windows 用户请用
#   pwsh -File .\scripts\update-bridge.ps1
# ============================================================

set -euo pipefail