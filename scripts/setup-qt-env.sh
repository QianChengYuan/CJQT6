#!/usr/bin/env bash
# ============================================================
# setup-qt-env.sh — CJQT6 运行/构建环境配置(Linux / macOS / WSL)
# ------------------------------------------------------------
# 用法:
#   source ./scripts/setup-qt-env.sh                  # 自动探测 Qt6 并配置当前 shell
#   source ./scripts/setup-qt-env.sh /path/to/qt6     # 显式指定 Qt6 安装根
#   source ./scripts/setup-qt-env.sh && cjpm run      # 配置后直接运行
#   bash ./scripts/setup-qt-env.sh                    # 只预览探测结果(不修改父 shell,用于自查)
#
# 做了什么(与 setup-qt-env.ps1、lib/common.sh::apply_qt_env 对称):
#   1) 选定一份 Qt6(QTDIR 环境变量 > 命令行参数 > 自动探测)并导出 QTDIR;
#   2) 把该 Qt 的 bin 加入 PATH、lib 加入 LD_LIBRARY_PATH(macOS 用 DYLD_*);
#   3) 把**插件路径**(QT_PLUGIN_PATH / QT_QPA_PLATFORM_PLUGIN_PATH)也指向同一份 Qt;
#   4) 导出 CJQT6_ROOT 指向本仓库;
#   5) 多 Qt 环境下打印"将加载哪一份 Qt"并列出其它可用版本 —— 库与插件跨版本混用会
#      导致窗口能创建但内容不绘制(表现为"窗口空白/透出后方窗口")、主题异常或启动即崩,
#      排查步骤见 docs/guides/build-guide.md「多 Qt 环境下窗口空白」。
#
# 注意:本文件设计为 source 使用,因此**不使用 set -e**(避免污染调用者的 shell);
#       直接 bash 执行时只打印预览,不会修改父 shell 的环境。
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"

ROOT_DIR="$(get_root_dir "${BASH_SOURCE[0]}")"

# 是否被 source(而不是 bash 直接执行):source 时才真正修改环境
_SOURCED=0
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    _SOURCED=1
fi

_QT_ARG="${1:-}"

# ---------- 1. 选定 Qt6 ----------
QT_DIR=""
QT_FROM=""
if [ -n "$_QT_ARG" ]; then
    if [ -d "$_QT_ARG" ]; then
        QT_DIR="$(cd "$_QT_ARG" && pwd)"
        QT_FROM="命令行参数"
    else
        echo "错误: 指定的 Qt 目录不存在: $_QT_ARG" >&2
        return 1 2>/dev/null || exit 1
    fi
elif [ -n "${QTDIR:-}" ] && [ -d "$QTDIR" ]; then
    QT_DIR="$QTDIR"
    QT_FROM="环境变量 QTDIR"
else
    QT_DIR="$(find_qt || true)"
    QT_FROM="自动探测"
fi

if [ -z "$QT_DIR" ]; then
    echo "错误: 未找到 Qt6。" >&2
    echo "      请安装 Qt6 后重试,或显式指定安装根:" >&2
    echo "      source ./scripts/setup-qt-env.sh ~/Qt/6.8.0/gcc_64" >&2
    return 1 2>/dev/null || exit 1
fi

print_section "CJQT6 环境配置"
echo "Qt6 安装根 : $QT_DIR"
echo "来源       : $QT_FROM"
_QT_VER="$(qt_version "$QT_DIR" || true)"
echo "Qt6 版本   : ${_QT_VER:-未知(未能从该目录读出 Qt6 版本)}"

if ! is_qt6_root "$QT_DIR"; then
    warn "该目录不像标准 Qt6 安装根(缺 lib/cmake/Qt6/Qt6Config.cmake 与 bin/qmake)——
      若构建或运行异常,请改用真正的安装根(如 ~/Qt/6.x.x/gcc_64),而不是库目录"
fi

# ---------- 2. 多 Qt 环境自查:列出其它可用版本 ----------
_OTHERS=""
for _p in $(ls -d "$HOME"/Qt/6.*/gcc_64 /home/*/Qt/6.*/gcc_64 /opt/Qt/6.*/gcc_64 /opt/qt6 2>/dev/null | sort -Vu); do
    [ -d "$_p" ] || continue
    _rp="$(cd "$_p" 2>/dev/null && pwd || echo "$_p")"
    [ "$_rp" = "$QT_DIR" ] && continue
    is_qt6_root "$_rp" || continue
    _OTHERS="$_OTHERS $_rp"
done
if [ -n "$_OTHERS" ]; then
    echo ""
    echo "另检测到其它 Qt6 安装(未被使用,注意不要混用):"
    for _p in $_OTHERS; do
        _v="$(qt_version "$_p" || true)"
        echo "  - $_p${_v:+  (版本 $_v)}"
    done
fi

# ---------- 3. 应用(仅 source 时生效)----------
if [ "$_SOURCED" -eq 1 ]; then
    apply_qt_env "$QT_DIR" || true
    export CJQT6_ROOT="$ROOT_DIR"
    echo ""
    echo "已应用到当前 shell:"
    echo "  QTDIR                       = ${QTDIR:-}"
    echo "  QT_PLUGIN_PATH              = ${QT_PLUGIN_PATH:-（未设置）}"
    echo "  QT_QPA_PLATFORM_PLUGIN_PATH = ${QT_QPA_PLATFORM_PLUGIN_PATH:-（未设置）}"
    echo "  CJQT6_ROOT                  = ${CJQT6_ROOT:-}"
    echo ""
    echo "可选:再执行下面这条确认窗口渲染所需的插件来自同一份 Qt"
    echo "      ldd ./examples/<示例>/target/release/bin/<可执行> | grep -i qt6 | head"
else
    _pv_lib="$(qt_lib_dir "$QT_DIR" || true)"
    _pv_plug="$(qt_plugin_dir "$QT_DIR" || true)"
    echo ""
    echo "[预览模式] 直接执行不会修改父 shell 的环境;将会设置:"
    echo "  QTDIR                       = $QT_DIR"
    echo "  库搜索路径追加              = ${_pv_lib:-（未解析到,将回退 <QTDIR>/lib）}"
    echo "  QT_PLUGIN_PATH              = ${_pv_plug:-（未解析到,将回退 <QTDIR>/plugins）}"
    echo "  QT_QPA_PLATFORM_PLUGIN_PATH = ${_pv_plug:+$_pv_plug/platforms}"
    echo "  CJQT6_ROOT                  = $ROOT_DIR"
    echo ""
    echo "要让环境生效请用: source $0"
fi

unset _QT_ARG _SOURCED _OTHERS _p _rp _v _pv_lib _pv_plug 2>/dev/null || true
