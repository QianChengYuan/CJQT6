#!/usr/bin/env bash
# ============================================================
# new-qt6-project.sh — CJQT6 项目脚手架(Linux/macOS/WSL)
# ------------------------------------------------------------
# 用法:
#   bash scripts/new-qt6-project.sh <项目名> [路径]
#   bash scripts/new-qt6-project.sh myapp              # 在当前目录创建 ./myapp
#   bash scripts/new-qt6-project.sh myapp ./projects   # 在 ./projects/myapp 创建
# 参数:
#   <项目名>           必填,作为 cjpm.toml package.name 与 src/main.cj 包名
#   [路径]             可选,父目录路径(默认当前目录 ".")
# 对应 roadmap 9.5:cjqt6-cli 脚手架(cjpm init --template qt6 等价物)
# 与 new-qt6-project.ps1 对称(Windows 版本生成 Windows 平台 link-option)
# ============================================================

set -euo pipefail