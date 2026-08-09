#!/bin/bash
# 统一构建入口脚本

set -e

echo "======================================"
echo "CJQT6 FFI Bridge 多平台构建"
echo "======================================"

# 检测当前平台
detect_platform() {
    OS=$(uname -s)
    ARCH=$(uname -m)
    
    case "$OS" in
        Linux)
            if [ "$ARCH" = "x86_64" ]; then
                echo "linux-x64"
            elif [ "$ARCH" = "aarch64" ]; then
                echo "linux-arm64"
            else
                echo "linux-unknown"
            fi
            ;;
        Darwin)
            if [ "$ARCH" = "x86_64" ]; then
                echo "macos-x64"
            elif [ "$ARCH" = "arm64" ]; then
                echo "macos-arm64"
            else
                echo "macos-unknown"
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "windows-x64"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

PLATFORM=$(detect_platform)
echo "检测到平台: $PLATFORM"

# 构建对应平台
case "$PLATFORM" in
    linux-x64)
        bash scripts/build-linux-x64.sh
        ;;
    linux-arm64)
        echo "ARM64构建尚未实现"
        ;;
    macos-x64)
        bash scripts/build-macos-x64.sh
        ;;
    macos-arm64)
        bash scripts/build-macos-arm64.sh
        ;;
    windows-x64)
        echo "请使用PowerShell脚本: scripts/build-windows-x64.ps1"
        ;;
    *)
        echo "错误: 不支持的平台 $PLATFORM"
        exit 1
        ;;
esac

echo ""
echo "======================================"
echo "构建完成!"
echo "======================================"
