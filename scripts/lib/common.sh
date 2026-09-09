#!/bin/bash
# ============================================================
# scripts/lib/common.sh — CJQT6 脚本共享函数(bash)
# ------------------------------------------------------------
# 提供:
#   - detect_platform    探测当前 OS + 架构,返回 linux-x64 / linux-arm64 / wsl /
#                        macos-x64 / macos-arm64 / windows / unknown
#   - find_qt            探测 Qt6 安装根,可用 QTDIR 环境变量覆盖
#   - get_jobs           获取可用并行数(nproc / sysctl,fallback 4)
#   - get_root_dir       定位 CJQT6 项目根(本 lib 父目录的父目录)
#   - print_section      打印带颜色的 section 标题(便于 build-* 脚本复用)
#
# 用法:
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   # shellcheck disable=SC1091
#   source "$SCRIPT_DIR/lib/common.sh"
#
# 依赖:
#   - bash >= 4(数组支持)
#   - 无外部依赖(uname / sysctl / brew 可选)
# ============================================================

# ---------- 防止重复 source ----------
if [ -n "${__CJQT6_COMMON_SH_INCLUDED:-}" ]; then
    return 0 2>/dev/null || true
fi
__CJQT6_COMMON_SH_INCLUDED=1

# ---------- 颜色(自动检测是否启用)----------
if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
    _CJ_COLOR_CYAN="$(tput setaf 6 2>/dev/null || echo '')"
    _CJ_COLOR_YELLOW="$(tput setaf 3 2>/dev/null || echo '')"
    _CJ_COLOR_GREEN="$(tput setaf 2 2>/dev/null || echo '')"
    _CJ_COLOR_RED="$(tput setaf 1 2>/dev/null || echo '')"
    _CJ_COLOR_RESET="$(tput sgr0 2>/dev/null || echo '')"
else
    _CJ_COLOR_CYAN=""
    _CJ_COLOR_YELLOW=""
    _CJ_COLOR_GREEN=""
    _CJ_COLOR_RED=""
    _CJ_COLOR_RESET=""
fi

# ---------- 探测平台 ----------
# 输出:linux-x64 / linux-arm64 / wsl / macos-x64 / macos-arm64 / windows / unknown
detect_platform() {
    local OS ARCH
    OS="$(uname -s)"
    ARCH="$(uname -m)"

    case "$OS" in
        Linux)
            # WSL 检测(/proc/version 含 microsoft 字样)
            if [ -r /proc/version ] && grep -qi microsoft /proc/version 2>/dev/null; then
                echo "wsl"
                return 0
            fi
            case "$ARCH" in
                x86_64)  echo "linux-x64" ;;
                aarch64) echo "linux-arm64" ;;
                *)       echo "linux-unknown" ;;
            esac
            ;;
        Darwin)
            case "$ARCH" in
                x86_64) echo "macos-x64" ;;
                arm64)  echo "macos-arm64" ;;
                *)      echo "macos-unknown" ;;
            esac
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# ---------- 探测 Qt6 路径 ----------
# 优先级:QTDIR 环境变量 > 平台常见路径 > brew(仅 macOS)
# 输出:Qt6 根路径(可能含 bin/lib 子目录),失败返回空
# 用法:QTDIR="$(find_qt)"
find_qt() {
    # 1. 环境变量优先
    if [ -n "$QTDIR" ] && [ -d "$QTDIR" ]; then
        echo "$QTDIR"
        return 0
    fi

    local platform
    platform="$(detect_platform)"

    case "$platform" in
        linux-x64|wsl)
            for p in /usr/lib/qt6 /usr/lib/x86_64-linux-gnu/qt6 /opt/qt6; do
                [ -d "$p" ] && echo "$p" && return 0
            done
            # 用户目录下 Qt 安装(aqtinstall 默认路径)
            for p in /home/*/Qt/6.*/gcc_64; do
                [ -d "$p" ] && echo "$p" && return 0
            done 2>/dev/null
            # WSL 挂载的 Windows Qt
            if [ "$platform" = "wsl" ]; then
                for p in /mnt/c/Qt/6.*/msvc2022_64 /mnt/c/Qt/6.*/msvc2019_64; do
                    for d in $p; do
                        [ -d "$d" ] && echo "$d" && return 0
                    done
                done 2>/dev/null
            fi
            ;;
        linux-arm64)
            for p in /usr/lib/qt6 /usr/lib/aarch64-linux-gnu/qt6 /opt/qt6 /usr/local/Qt6; do
                [ -d "$p" ] && echo "$p" && return 0
            done
            ;;
        macos-x64|macos-arm64)
            # brew 优先(用户最常用安装方式)
            if command -v brew >/dev/null 2>&1; then
                local q
                q="$(brew --prefix qt@6 2>/dev/null || true)"
                [ -n "$q" ] && [ -d "$q" ] && echo "$q" && return 0
            fi
            for p in /opt/homebrew /usr/local/qt6 /opt/qt6; do
                [ -d "$p" ] && echo "$p" && return 0
            done
            ;;
    esac
    return 1
}

# ---------- 获取可用并行数 ----------
# 用法:JOBS=$(get_jobs)
get_jobs() {
    if command -v nproc >/dev/null 2>&1; then
        nproc
    elif command -v sysctl >/dev/null 2>&1; then
        sysctl -n hw.ncpu 2>/dev/null || echo 4
    else
        echo 4
    fi
}

# ---------- 定位 CJQT6 项目根 ----------
# 假设调用脚本位于 scripts/ 下,返回其父目录
# 用法:ROOT_DIR="$(get_root_dir)"
get_root_dir() {
    # 调用者传入脚本路径(如 ${BASH_SOURCE[1]});若不传,默认按 scripts/lib/common.sh 推算
    local src="${1:-${BASH_SOURCE[1]:-$0}}"
    local script_dir
    script_dir="$(cd "$(dirname "$src")" && pwd)"
    # scripts/foo.sh → scripts/ → 项目根
    # scripts/lib/common.sh → scripts/lib/ → scripts/ → 项目根
    if [ "$(basename "$script_dir")" = "lib" ]; then
        script_dir="$(dirname "$script_dir")"
    fi
    cd "$script_dir/.." && pwd
}

# ---------- 打印 section 标题(可选彩色)----------
# 用法:print_section "编译 FFI Bridge"
print_section() {
    local title="$1"
    local color="${_CJ_COLOR_CYAN}"
    local reset="${_CJ_COLOR_RESET}"
    echo ""
    echo "${color}======================================${reset}"
    echo "${color} $title${reset}"
    echo "${color}======================================${reset}"
}

# ---------- 错误退出 ----------
# 用法:die "未找到 Qt6"
die() {
    echo "${_CJ_COLOR_RED}错误:${_CJ_COLOR_RESET} $*" >&2
    exit 1
}

# ---------- 警告(不退出)----------
# 用法:warn "Qt 路径探测失败,使用默认值"
warn() {
    echo "${_CJ_COLOR_YELLOW}警告:${_CJ_COLOR_RESET} $*" >&2
}