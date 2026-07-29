#!/bin/bash
# CJQT6 运行环境配置脚本（Linux/macOS/WSL）
# 设置 Qt6 环境变量
#
# 用法:
#   source ./scripts/setup-qt-env.sh            # 配置环境
#   source ./scripts/setup-qt-env.sh && cjpm run  # 配置后直接运行

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---- 检测平台 ----
detect_platform() {
    OS=$(uname -s)
    ARCH=$(uname -m)

    case "$OS" in
        Linux)
            # WSL 检测
            if grep -qi microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi ;;
        Darwin) echo "macos" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "unknown" ;;
    esac
}

PLATFORM=$(detect_platform)
echo "平台: $PLATFORM"

# ---- 查找 Qt6 ----
find_qt() {
    # 1. 环境变量
    if [ -n "$QTDIR" ] && [ -d "$QTDIR/bin" ]; then
        echo "$QTDIR"
        return 0
    fi

    case "$PLATFORM" in
        linux)
            for p in /usr/lib/qt6 /usr/lib/x86_64-linux-gnu/qt6 /opt/qt6; do
                [ -d "$p/bin" ] && echo "$p" && return 0
            done
            # 扫描用户目录
            for dir in /home/*/Qt/6.*/gcc_64; do
                [ -d "$dir/bin" ] && echo "$dir" && return 0
            done 2>/dev/null
            ;;
        wsl)
            # WSL: 挂载的 Windows Qt
            for p in /mnt/c/Qt/6.*/msvc2022_64 /mnt/c/Qt/6.*/msvc2019_64; do
                for d in $p; do
                    [ -d "$d/bin" ] && echo "$d" && return 0
                done
            done 2>/dev/null
            ;;
        macos)
            if command -v brew &>/dev/null; then
                local q=$(brew --prefix qt@6 2>/dev/null) && [ -n "$q" ] && echo "$q" && return 0
            fi
            for p in /usr/local/qt6 /opt/qt6; do
                [ -d "$p" ] && echo "$p" && return 0
            done
            ;;
    esac
    return 1
}

QT_PATH=$(find_qt)
if [ -z "$QT_PATH" ]; then
    echo "❌ 未找到 Qt6 安装"
    echo "请安装 Qt6 (>= 6.2) 或设置 QTDIR 环境变量"
    exit 1
fi

# ---- 设置环境变量 ----
export PATH="$QT_PATH/bin:$PATH"
export QTDIR="$QT_PATH"

echo "✅ Qt6 环境已配置"
echo "Qt路径: $QT_PATH"
echo ""
echo "环境变量:"
echo "  QTDIR = $QT_PATH"
echo "  PATH 已添加: $QT_PATH/bin"
echo ""
echo "现在可以运行: cjpm run"

# 如果有参数，执行该命令
if [ $# -gt 0 ]; then
    echo ""
    echo "执行命令: $@"
    "$@"
fi
