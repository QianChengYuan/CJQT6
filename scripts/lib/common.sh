#!/bin/bash
# ============================================================
# scripts/lib/common.sh — CJQT6 脚本共享函数(bash)
# ------------------------------------------------------------
# 提供:
#   - detect_platform    探测当前 OS + 架构,返回 linux-x64 / linux-arm64 / wsl /
#                        macos-x64 / macos-arm64 / windows / unknown
#   - find_qt            探测 Qt6 安装根,可用 QTDIR 环境变量覆盖
#   - is_qt6_root        判断某目录是否为真正的 Qt6 安装根(而非仅仅是库目录)
#   - qt_query           用 qmake6 -query 查询 Qt 安装信息(仅当 qmake 属于 Qt6)
#   - qt_version         取 Qt 版本号(如 6.4.2)
#   - apply_qt_env       注入 QTDIR / PATH / LD_LIBRARY_PATH / 插件路径(唯一注入入口)
#   - qt_runtime_check   校验桥接库在运行期实际解析到的 Qt 是否与所选 Qt 一致
#   - get_jobs           获取可用并行数(nproc / sysctl,fallback 4)
#   - get_root_dir       定位 CJQT6 项目根(本 lib 父目录的父目录)
#   - print_section      打印带颜色的 section 标题(便于 build-* 脚本复用)
#   - die / warn         错误退出 / 警告(不退出)
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

# ---------- 判断目录是否为真正的 Qt6 安装根 ----------
# 为什么需要它:仅"目录存在"不足以当安装根。例如 Debian/Ubuntu 的
# /usr/lib/x86_64-linux-gnu/qt6 只是**库目录**(插件在 .../qt6/plugins,cmake 配置在
# .../cmake/Qt6),把库目录当 QTDIR 会让 `-DQt6_DIR=$QTDIR/lib/cmake/Qt6` 指向不存在
# 的路径,并让插件路径推导全错(库与插件跨版本混用正是"窗口空白"类问题的根源)。
# 判据:含 lib/cmake/Qt6/Qt6Config.cmake(官方安装包/aqtinstall),或含 bin/qmake(6)。
is_qt6_root() {
    local d="${1:-}"
    [ -n "$d" ] && [ -d "$d" ] || return 1
    [ -f "$d/lib/cmake/Qt6/Qt6Config.cmake" ] && return 0
    [ -x "$d/bin/qmake6" ] && return 0
    [ -x "$d/bin/qmake" ] && return 0
    return 1
}

# ---------- 用 qmake 查询 Qt 安装信息 ----------
# 仅当 qmake 属于 Qt6(QT_VERSION 以 6. 开头)才采纳,避免误取 Qt5 的 qmake。
# 用法:prefix="$(qt_query QT_INSTALL_PREFIX)"
# 可用键:QT_INSTALL_PREFIX / QT_INSTALL_LIBS / QT_INSTALL_PLUGINS / QT_INSTALL_BINS / QT_VERSION
qt_query() {
    local key="${1:-}" exe ver
    [ -n "$key" ] || return 1
    for exe in qmake6 qmake-qt6 qmake; do
        command -v "$exe" >/dev/null 2>&1 || continue
        ver="$("$exe" -query QT_VERSION 2>/dev/null || true)"
        case "$ver" in
            6.*) "$exe" -query "$key" 2>/dev/null; return $? ;;
        esac
    done
    return 1
}

# ---------- 取 Qt 版本号(如 6.4.2)----------
# 用法:qt_version "$QTDIR"(不传则以当前 QTDIR / PATH 中的 qmake6 为准)
qt_version() {
    local dir="${1:-${QTDIR:-}}" v=""
    # 1) qmake 查询最准(Debian multiarch、aqtinstall、brew 都适用)
    if [ -z "$dir" ] || [ "$dir" = "$(qt_query QT_INSTALL_PREFIX 2>/dev/null || true)" ]; then
        v="$(qt_query QT_VERSION || true)"
    fi
    [ -n "$v" ] && { echo "$v"; return 0; }
    # 2) 兜底:从安装根的 cmake 配置读(无 qmake 的精简安装)
    if [ -n "$dir" ] && [ -f "$dir/lib/cmake/Qt6/Qt6ConfigVersion.cmake" ]; then
        v="$(sed -n 's/^set(PACKAGE_VERSION[[:space:]]*"\{0,1\}\([0-9][0-9.]*\).*/\1/p' \
            "$dir/lib/cmake/Qt6/Qt6ConfigVersion.cmake" | head -n1)"
    fi
    [ -n "$v" ] && { echo "$v"; return 0; }
    return 1
}

# ---------- 取所选 Qt 的库目录 ----------
# 为什么不能直接用 <root>/lib:Debian/Ubuntu 的 Qt6 是 multiarch 布局(库在
# /usr/lib/<triplet>、插件在 /usr/lib/<triplet>/qt6/plugins),此时必须用
# `qmake6 -query QT_INSTALL_LIBS` 的结果。**但仅当该 qmake 就属于这份 Qt
# (prefix 相同)才采纳**,否则会拿到"系统 Qt 的路径"而误配到另一份 Qt ——
# 那正是本次要消除的"库与所选 Qt 不是同一份"的隐蔽混用。
# 用法:qt_lib_dir "$QTDIR"
qt_lib_dir() {
    local dir="${1:-${QTDIR:-}}" prefix="" p=""
    prefix="$(qt_query QT_INSTALL_PREFIX 2>/dev/null || true)"
    if [ -n "$prefix" ] && [ "$prefix" = "$dir" ]; then
        p="$(qt_query QT_INSTALL_LIBS 2>/dev/null || true)"
        [ -n "$p" ] && { echo "$p"; return 0; }
    fi
    if [ -n "$dir" ] && [ -d "$dir/lib" ]; then echo "$dir/lib"; return 0; fi
    if [ -n "$dir" ] && [ -d "$dir" ]; then echo "$dir"; return 0; fi   # macOS framework 兜底
    return 1
}

# ---------- 取所选 Qt 的插件目录 ----------
# 用法:qt_plugin_dir "$QTDIR"
qt_plugin_dir() {
    local dir="${1:-${QTDIR:-}}" prefix="" p=""
    prefix="$(qt_query QT_INSTALL_PREFIX 2>/dev/null || true)"
    if [ -n "$prefix" ] && [ "$prefix" = "$dir" ]; then
        p="$(qt_query QT_INSTALL_PLUGINS 2>/dev/null || true)"
        [ -n "$p" ] && { echo "$p"; return 0; }
    fi
    if [ -n "$dir" ] && [ -d "$dir/plugins" ]; then echo "$dir/plugins"; return 0; fi
    return 1
}

# ---------- 把目录前置到某冒号分隔路径变量(幂等) ----------
# 用法:prepend_path_var LD_LIBRARY_PATH "$lib_dir"
# 幂等的理由:setup-qt-env.sh / run-example.sh / 用户手写 export 可能各调一次,
# 重复前置会让变量无限增长(且排查时难以辨认真正的顺序)。
prepend_path_var() {
    local var="${1:-}" dir="${2:-}" cur="" part=""
    [ -n "$var" ] && [ -n "$dir" ] || return 0
    cur="${!var:-}"        # 间接引用,避免 eval
    local IFS=':'
    for part in $cur; do
        [ "$part" = "$dir" ] && return 0
    done
    if [ -n "$cur" ]; then
        printf -v "$var" '%s' "$dir:$cur"
    else
        printf -v "$var" '%s' "$dir"
    fi
    export "$var"
    return 0
}

# ---------- 注入 Qt6 环境变量(唯一注入入口)----------
# 与 PowerShell 侧 scripts/lib/common.ps1::Set-QtEnv 对应:
#   导出 QTDIR / PATH / LD_LIBRARY_PATH(或 macOS 的 DYLD_*) / QT_PLUGIN_PATH /
#   QT_QPA_PLATFORM_PLUGIN_PATH。全部幂等,可重复调用。
# 为什么必须同时注入**插件路径**:Qt 的库与插件必须来自同一份安装。多 Qt 机器上若只把
# 库加入搜索路径,插件仍可能从系统 Qt 目录被加载(反之亦然),跨版本混用会导致
# 窗口能创建但内容不绘制(表现为"窗口内容空白/透出后方窗口")、主题异常或启动即崩。
# 用法:apply_qt_env "$QTDIR"
apply_qt_env() {
    local dir="${1:-${QTDIR:-}}"
    if [ -z "$dir" ] || [ ! -d "$dir" ]; then
        warn "apply_qt_env: 未提供有效的 Qt 目录(\"$dir\"),跳过环境注入"
        return 1
    fi
    export QTDIR="$dir"

    local lib_dir plugin_dir
    lib_dir="$(qt_lib_dir "$dir" || true)"
    plugin_dir="$(qt_plugin_dir "$dir" || true)"

    # PATH 与库搜索路径(均为幂等前置)
    [ -d "$dir/bin" ] && prepend_path_var PATH "$dir/bin"

    local platform
    platform="$(detect_platform)"
    if [ "$platform" = "macos-x64" ] || [ "$platform" = "macos-arm64" ]; then
        [ -n "$lib_dir" ] && prepend_path_var DYLD_LIBRARY_PATH "$lib_dir"
        [ -n "$lib_dir" ] && prepend_path_var DYLD_FRAMEWORK_PATH "$lib_dir"
    else
        [ -n "$lib_dir" ] && prepend_path_var LD_LIBRARY_PATH "$lib_dir"
    fi

    if [ -n "$plugin_dir" ] && [ -d "$plugin_dir" ]; then
        prepend_path_var QT_PLUGIN_PATH "$plugin_dir"
        if [ -d "$plugin_dir/platforms" ]; then
            export QT_QPA_PLATFORM_PLUGIN_PATH="$plugin_dir/platforms"
        fi
    fi
    return 0
}

# ---------- 运行时一致性校验:桥接库实际解析到的 Qt ----------
# 返回:0=桥接库用的就是所选 Qt / 1=解析到了别的 Qt(可能跨版本) / 2=无法判定
# 用法:qt_runtime_check "$ROOT_DIR/releases/linux-x64/libcjqt6_bridge.so"
qt_runtime_check() {
    local bridge="${1:-}"
    [ -n "$bridge" ] && [ -f "$bridge" ] || return 2
    command -v ldd >/dev/null 2>&1 || return 2

    local got
    got="$(ldd "$bridge" 2>/dev/null | awk '/libQt6Core\.so|QtCore\.framework/{print $3; exit}')"
    [ -n "$got" ] || return 2              # 桥接库未链接 Qt6 或 ldd 解析失败
    echo "  桥接库实际解析到: $got"
    [ -n "${QTDIR:-}" ] || return 2
    echo "  所选 Qt (QTDIR): $QTDIR"

    # 1) 解析结果就在所选 Qt 内 → 一致
    case "$got" in
        "$QTDIR"/*) return 0 ;;
    esac

    # 2) 不在所选 Qt 内:用版本段判断(用户安装路径形如 ~/Qt/6.4.2/gcc_64/lib/...)。
    #    版本段相同 → 视为一致(例如系统 Qt 与所选版本相同);不同 → 明确不一致。
    local got_ver want_ver
    got_ver="$(printf '%s' "$got" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
    want_ver="$(qt_version "$QTDIR" 2>/dev/null || true)"
    if [ -n "$got_ver" ] && [ -n "$want_ver" ]; then
        if [ "$got_ver" = "$want_ver" ]; then
            echo "  （路径不同但版本相同: $got_ver,视为一致）"
            return 0
        fi
        echo "  版本不一致: 桥接库用 $got_ver,所选 Qt 为 $want_ver"
        return 1
    fi
    # 3) 无法判版本且不在所选 Qt 内 → 提示但不阻断
    return 1
}

# ---------- 探测 Qt6 路径 ----------
# 优先级:QTDIR 环境变量 > 平台常见路径 > brew(仅 macOS)
# 输出:Qt6 根路径;失败返回非 0(不输出)
# 用法:QTDIR="$(find_qt)"
find_qt() {
    # 1. 环境变量优先
    if [ -n "${QTDIR:-}" ] && [ -d "$QTDIR" ]; then
        echo "$QTDIR"
        return 0
    fi

    local platform
    platform="$(detect_platform)"

    case "$platform" in
        linux-x64|wsl)
            # 1) 用户目录下的官方在线安装包(aqtinstall 默认路径):多版本时取版本号最大者,
            #    优先于系统 Qt —— 用户显式装的版本通常就是要配套使用的那一份
            local p
            for p in $(ls -d "$HOME"/Qt/6.*/gcc_64 /home/*/Qt/6.*/gcc_64 2>/dev/null | sort -Vr); do
                if is_qt6_root "$p"; then echo "$p"; return 0; fi
            done
            # 2) 常见自定义安装位置
            for p in /opt/qt6 /opt/Qt/6.*/gcc_64 /usr/local/Qt6; do
                if is_qt6_root "$p"; then echo "$p"; return 0; fi
            done
            # 3) 系统 Qt6:用 qmake6 查真实安装根(Debian/Ubuntu 为 multiarch 布局)
            local sys_prefix
            sys_prefix="$(qt_query QT_INSTALL_PREFIX 2>/dev/null || true)"
            if [ -n "$sys_prefix" ] && [ -d "$sys_prefix" ]; then
                echo "$sys_prefix"
                return 0
            fi
            # 4) 旧候选路径:仅在确为 Qt6 安装根时采纳(避免把库目录当安装根)
            for p in /usr/lib/qt6 /usr/lib/x86_64-linux-gnu/qt6 /opt/qt6; do
                if is_qt6_root "$p"; then echo "$p"; return 0; fi
            done
            # 5) WSL 挂载的 Windows Qt
            if [ "$platform" = "wsl" ]; then
                for p in /mnt/c/Qt/6.*/msvc2022_64 /mnt/c/Qt/6.*/msvc2019_64; do
                    for d in $p; do
                        if is_qt6_root "$d"; then echo "$d"; return 0; fi
                    done
                done 2>/dev/null
            fi
            ;;
        linux-arm64)
            for p in /opt/qt6 /usr/local/Qt6 /usr/lib/qt6 /usr/lib/aarch64-linux-gnu/qt6; do
                if is_qt6_root "$p"; then echo "$p"; return 0; fi
            done
            local arm_prefix
            arm_prefix="$(qt_query QT_INSTALL_PREFIX 2>/dev/null || true)"
            if [ -n "$arm_prefix" ] && [ -d "$arm_prefix" ]; then
                echo "$arm_prefix"
                return 0
            fi
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