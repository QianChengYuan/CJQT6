#!/usr/bin/env bash
# ============================================================
# run-example.sh — CJQT6 示例一键运行(Linux / macOS)
# ------------------------------------------------------------
# 换一个示例名就能跑起来。脚本自动处理三件事:
#   1) CJQT6_ROOT 指向「当前这份仓库」—— 避免误用其它克隆目录的产物;
#   2) 把 releases/<平台>、仓颉运行时库、Qt 库(若设了 QTDIR)加入动态库搜索路径;
#   3) 按需 cjpm build,然后 cjpm run。
#
# 用法:
#   ./examples/run-example.sh                     # 列出全部可运行示例
#   ./examples/run-example.sh CjMusic             # 构建 + 运行
#   ./examples/run-example.sh hello_cjqt6 -n      # 只构建,不启动
#   ./examples/run-example.sh CjMusic -s          # 跳过构建,直接运行
#   ./examples/run-example.sh qq_chat_lan/server  # 子目录工程
#
# 参数:
#   第 1 个位置参数 = 示例名(可带子目录,相对 examples/)
#   -n | --no-run     只构建,不启动
#   -s | --skip-build 跳过 cjpm build
#   环境变量 QTDIR 已设置时,会把 $QTDIR/lib 置于搜索路径最前
#
# 说明文档: examples/README.md
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

NAME=""
NO_RUN=0
SKIP_BUILD=0
while [ $# -gt 0 ]; do
    case "$1" in
        -n|--no-run)     NO_RUN=1 ;;
        -s|--skip-build) SKIP_BUILD=1 ;;
        -h|--help)       NAME="" ;;
        *)               NAME="$1" ;;
    esac
    shift
done

# ---------- 不带参数: 列出所有可运行示例 ----------
if [ -z "$NAME" ]; then
    echo "CJQT6 可运行示例(用法: $0 <示例名> [参数])"
    echo
    for d in "$SCRIPT_DIR"/*/; do
        [ -f "$d/cjpm.toml" ] || continue
        ex_name="$(basename "$d")"
        ex_desc="$(sed -n 's/^[[:space:]]*description[[:space:]]*=[[:space:]]*"\(.*\)".*/\1/p' "$d/cjpm.toml" | head -n1)"
        printf "  %-20s %s\n" "$ex_name" "$ex_desc"
    done
    echo
    echo "子目录工程: qq_chat_lan/server(先起服务端) 与 qq_chat_lan/client"
    echo "其它目录  : examples/resource(素材)、examples/CjDash(方案文档, 无 cjpm 工程)"
    exit 0
fi

EX_DIR="$SCRIPT_DIR/$NAME"
if [ ! -f "$EX_DIR/cjpm.toml" ]; then
    echo "错误: 未找到示例工程 examples/$NAME(不带参数运行本脚本可列出全部示例)" >&2
    exit 1
fi

export CJQT6_ROOT="$ROOT_DIR"

# ---------- 平台 -> releases 目录 ----------
case "$(uname -s)" in
    Linux)  REL_DIR="linux-x64" ;;
    Darwin) REL_DIR="macos-arm64" ;;
    *)      echo "错误: 暂不支持的平台 $(uname -s)(Windows 请用 run-example.ps1)" >&2; exit 1 ;;
esac
if [ "$(uname -s)" = "Linux" ] && [ "$(uname -m)" = "aarch64" ]; then
    REL_DIR="linux-arm64"
fi

# ---------- 组装动态库搜索路径 ----------
LIBS="$ROOT_DIR/releases/$REL_DIR"
if [ -n "${QTDIR:-}" ] && [ -d "$QTDIR/lib" ]; then
    LIBS="$QTDIR/lib:$LIBS"
fi
if [ -n "${CANGJIE_HOME:-}" ] && [ -d "$CANGJIE_HOME/runtime/lib" ]; then
    CJ_RT="$(find "$CANGJIE_HOME/runtime/lib" -maxdepth 1 -type d -name '*cjnative' | head -n1 || true)"
    if [ -n "$CJ_RT" ]; then
        LIBS="$CJ_RT:$CANGJIE_HOME/tools/lib:$LIBS"
    fi
fi
if [ "$(uname -s)" = "Darwin" ]; then
    export DYLD_LIBRARY_PATH="$LIBS:${DYLD_LIBRARY_PATH:-}"
    if [ -n "${QTDIR:-}" ]; then
        export DYLD_FRAMEWORK_PATH="$QTDIR/lib:${DYLD_FRAMEWORK_PATH:-}"
    fi
else
    export LD_LIBRARY_PATH="$LIBS:${LD_LIBRARY_PATH:-}"
fi

echo "==> 示例      : $NAME"
echo "==> CJQT6_ROOT: $CJQT6_ROOT"
echo "==> 桥接库目录: releases/$REL_DIR"
if [ -n "${QTDIR:-}" ]; then
    echo "==> QTDIR     : $QTDIR"
fi
if [ ! -f "$ROOT_DIR/releases/$REL_DIR/libcjqt6_bridge.so" ] && [ ! -f "$ROOT_DIR/releases/$REL_DIR/libcjqt6_bridge.dylib" ]; then
    echo "[!] 未找到 releases/$REL_DIR 下的桥接库,若链接或加载失败请先构建(见 docs/guides/build-guide.md)" >&2
fi

cd "$EX_DIR"
if [ "$SKIP_BUILD" -eq 0 ]; then
    echo "==> cjpm build"
    cjpm build
fi

if [ "$NO_RUN" -eq 1 ]; then
    echo "==> 已按 -n/--no-run 跳过运行;可自行执行: cd examples/$NAME && cjpm run"
    exit 0
fi

echo "==> cjpm run(关闭程序窗口即结束)"
exec cjpm run
