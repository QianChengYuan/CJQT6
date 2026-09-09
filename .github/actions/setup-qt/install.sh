#!/bin/bash
# install.sh — Qt6 安装脚本(全平台统一走 bash)
# 由 .github/actions/setup-qt composite action 调用
# 环境变量:
#   INPUT_OS        linux | macos | linux-arm64 | windows
#   INPUT_VERSION   Qt 版本(Linux ARM64 忽略)
#   INPUT_ARCH      Qt 架构(Linux ARM64 忽略)
#   INPUT_MODULES   附加模块,逗号分隔(默认 qtmultimedia,qtcharts)

set -euo pipefail

INPUT_OS="${INPUT_OS:-linux}"
INPUT_VERSION="${INPUT_VERSION:-}"
INPUT_ARCH="${INPUT_ARCH:-}"
INPUT_MODULES="${INPUT_MODULES:-qtmultimedia,qtcharts}"

# 默认 Qt 版本与架构(锁定与各平台 release/ 一致;用户可通过 inputs 覆盖)
case "$INPUT_OS" in
  linux)          DEFAULT_VERSION="6.4.2"; DEFAULT_ARCH="gcc_64" ;;
  macos)          DEFAULT_VERSION="6.4.2"; DEFAULT_ARCH="clang_64" ;;
  windows)        DEFAULT_VERSION="6.9.1"; DEFAULT_ARCH="win64_msvc2022_64" ;;
  linux-arm64)    DEFAULT_VERSION="";      DEFAULT_ARCH="" ;;
  *)
    echo "::error::setup-qt 不支持平台: $INPUT_OS"
    exit 1
    ;;
esac

QT_VERSION="${INPUT_VERSION:-$DEFAULT_VERSION}"
QT_ARCH="${INPUT_ARCH:-$DEFAULT_ARCH}"

case "$INPUT_OS" in
  linux|macos|windows)
    # aqtinstall 路径(linux/windows 用系统 python;macOS 因 PEP 668 用 venv)
    case "$INPUT_OS" in
      linux)
        python3 -m pip install --quiet --user aqtinstall
        AQT_PY="python3"
        ;;
      windows)
        python -m pip install --quiet aqtinstall
        AQT_PY="python"
        ;;
      macos)
        python3 -m venv "$RUNNER_TEMP/aqt-venv"
        "$RUNNER_TEMP/aqt-venv/bin/pip" install --quiet aqtinstall
        AQT_PY="$RUNNER_TEMP/aqt-venv/bin/python3"
        ;;
    esac

    echo "==> aqtinstall 安装 Qt ${QT_VERSION} ${QT_ARCH} (modules: ${INPUT_MODULES})"
    "$AQT_PY" -m aqt install-qt "${INPUT_OS%arm64}" desktop "$QT_VERSION" "$QT_ARCH" \
      -O "$RUNNER_TEMP/Qt" -m "$INPUT_MODULES"

    case "$INPUT_OS" in
      linux)   QTDIR="$RUNNER_TEMP/Qt/$QT_VERSION/$QT_ARCH" ;;
      macos)   QTDIR="$RUNNER_TEMP/Qt/$QT_VERSION/macos" ;;
      windows)
        # aqt 实际目录名可能与 arch 参数不一致(如 win64_msvc2022_64 → msvc2022_64),探测真实路径
        qtBase="$RUNNER_TEMP/Qt/$QT_VERSION"
        QTDIR=""
        for d in "$qtBase"/*/; do
          [ -f "${d}bin/Qt6Core.dll" ] && { QTDIR="${d%/}"; break; }
        done
        if [ -z "$QTDIR" ]; then
          echo "::error::未找到 Qt 安装目录: $qtBase"
          exit 1
        fi
        ;;
    esac
    ;;

  linux-arm64)
    echo "==> apt 安装 Qt6 系统开发包"
    sudo apt-get update
    sudo apt-get install -y \
      qt6-base-dev qt6-base-private-dev \
      qt6-declarative-dev qt6-tools-dev \
      qt6-multimedia-dev qt6-charts-dev qt6-svg-dev
    QTDIR="/usr/lib/aarch64-linux-gnu"
    QT_VERSION=""  # 系统版本由 apt 决定
    ;;
esac

if [ -z "$QTDIR" ] || [ ! -d "$QTDIR" ]; then
  echo "::error::Qt 安装失败或路径无效: $QTDIR"
  exit 1
fi

echo "QTDIR=$QTDIR"  >> "$GITHUB_ENV"
echo "$QTDIR/bin"     >> "$GITHUB_PATH"

echo "qtdir=$QTDIR"  >> "$GITHUB_OUTPUT"
echo "==> Qt 安装完成: $QTDIR"