#!/bin/bash
# ============================================================
# run-test.sh — CJQT6 测试程序运行脚本(Linux/macOS/WSL)
# ------------------------------------------------------------
# 用法:
#   bash scripts/run-test.sh                    # 运行所有测试
#   bash scripts/run-test.sh <test_name>        # 运行指定测试(透传给 cjpm test)
# 仅设置运行环境 + 调 cjpm test,不构建。
# 完整流程(桥接库 + 部署 + 测试)Windows 用户请用 verify_all.ps1
# 共享函数:scripts/lib/common.sh
# ============================================================

set -euo pipefail