#!/bin/bash
# CJQT6 一键编译所有平台（Docker版）
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE_DIR="$PROJECT_ROOT/releases"

echo "=== CJQT6 多平台编译 ==="
echo ""

# 检查Docker
if ! command -v docker &> /dev/null; then
    echo "❌ 错误: 需要安装Docker"
    echo "安装: https://docs.docker.com/get-docker/"
    exit 1
fi

# Linux x64
echo "1. 编译 Linux x64..."
mkdir -p "$RELEASE_DIR/linux-x64"
docker run --rm \
    -v "$PROJECT_ROOT:/src" \
    -w /src \
    ubuntu:22.04 \
    bash -c "
        apt update && apt install -y \
            build-essential cmake \
            qt6-base-dev qt6-tools-dev qt6-qmltooling-dev && \
        mkdir -p build && cd build && \
        cmake .. -DCMAKE_BUILD_TYPE=Release && \
        make -j\$(nproc) && \
        cp lib/libcjqt6_bridge.so ../releases/linux-x64/
    "

# Linux ARM64
echo "2. 编译 Linux ARM64..."
mkdir -p "$RELEASE_DIR/linux-arm64"
docker run --rm \
    -v "$PROJECT_ROOT:/src" \
    -w /src \
    arm64v8/ubuntu:22.04 \
    bash -c "
        apt update && apt install -y \
            build-essential cmake \
            qt6-base-dev qt6-tools-dev && \
        mkdir -p build && cd build && \
        cmake .. -DCMAKE_BUILD_TYPE=Release && \
        make -j\$(nproc) && \
        cp lib/libcjqt6_bridge.so ../releases/linux-arm64/
    "

# Windows x64 (MinGW cross-compile)
echo "3. 编译 Windows x64..."
mkdir -p "$RELEASE_DIR/windows-x64"
docker run --rm \
    -v "$PROJECT_ROOT:/src" \
    -w /src \
    debian:bullseye \
    bash -c "
        apt update && apt install -y \
            build-essential cmake mingw-w64 && \
        mkdir -p build && cd build && \
        cmake .. \
            -DCMAKE_SYSTEM_NAME=Windows \
            -DCMAKE_CXX_COMPILER=x86_64-w64-mingw32-g++ && \
        make -j\$(nproc) && \
        cp lib/libcjqt6_bridge.dll ../releases/windows-x64/
    "

echo ""
echo "✅ 所有平台编译完成！"
echo ""
echo "生成的文件："
ls -lh "$RELEASE_DIR"/*/libcjqt6_bridge.*
