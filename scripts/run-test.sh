#!/bin/bash
# CJQT6 测试程序运行脚本
# 设置 Qt6 运行时环境并运行测试
#
# 用法:
#   ./scripts/run-test.sh                    # 运行所有测试
#   ./scripts/run-test.sh <test_name>        # 运行指定测试

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---- 检测平台 ----
detect_platform() {
    OS=$(uname -s)
    ARCH=$(uname -m)

    case "$OS" in
        Linux)
            if [ "$ARCH" = "x86_64" ]; then echo "linux-x64"
            elif [ "$ARCH" = "aarch64" ]; then echo "linux-arm64"
            else echo "linux-unknown"
            fi ;;
        Darwin)
            if [ "$ARCH" = "x86_64" ]; then echo "macos-x64"
            elif [ "$ARCH" = "arm64" ]; then echo "macos-arm64"
            else echo "macos-unknown"
            fi ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "windows-x64" ;;
        *) echo "unknown" ;;
    esac
}

PLATFORM=$(detect_platform)
echo "平台: $PLATFORM"

# ---- 查找 Qt6 ----
find_qt() {
    if [ -n "$QTDIR" ] && [ -d "$QTDIR/lib" ]; then
        echo "$QTDIR"
        return 0
    fi

    case "$PLATFORM" in
        linux-x64)
            for p in /usr/lib/qt6 /usr/lib/x86_64-linux-gnu/qt6 /opt/qt6 /home/*/Qt/6.*/gcc_64; do
                [ -d "$p" ] && echo "$p" && return 0
            done 2>/dev/null
            ;;
        macos-x64|macos-arm64)
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

QT_DIR=$(find_qt)
if [ -z "$QT_DIR" ]; then
    echo "⚠ 未找到 Qt6，仅测试无需 Qt 的项"
else
    echo "Qt6: $QT_DIR"

    # 设置运行时环境
    case "$PLATFORM" in
        linux-x64)
            export LD_LIBRARY_PATH="$QT_DIR/lib:$LD_LIBRARY_PATH"
            ;;
        macos-x64|macos-arm64)
            export DYLD_LIBRARY_PATH="$QT_DIR/lib:$DYLD_LIBRARY_PATH"
            ;;
    esac
fi

# ---- 查找 Cangjie 运行时 ----
CANGJIE_HOME="${CANGJIE_HOME:-}"
if [ -z "$CANGJIE_HOME" ]; then
    for p in "$HOME/.cangjie" /opt/cangjie /usr/local/cangjie; do
        [ -d "$p/tools/bin" ] && CANGJIE_HOME="$p" && break
    done
fi

if [ -n "$CANGJIE_HOME" ]; then
    export PATH="$CANGJIE_HOME/tools/bin:$PATH"
    echo "Cangjie: $CANGJIE_HOME"
else
    echo "⚠ 未找到 Cangjie，请设置 CANGJIE_HOME"
fi

echo ""

# ---- 运行测试 ----
TEST_DIR="$PROJECT_DIR/tests"
if [ ! -d "$TEST_DIR" ]; then
    echo "测试目录不存在: $TEST_DIR"
    exit 0
fi

if [ $# -gt 0 ]; then
    echo "运行测试: $@"
    cd "$PROJECT_DIR"
    cjpm test "$@"
else
    echo "运行所有测试..."
    cd "$PROJECT_DIR"
    cjpm test
fi
