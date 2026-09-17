#!/usr/bin/env bash
# ============================================================
# run.sh —— CjMonitor 运行（Linux / macOS）
#
# 作用：注入 CJQT6_ROOT 与动态库搜索路径，启动已构建的 main。
# 路径由脚本位置推导，不写死绝对路径。
#
# 前置：已在 examples/CjMonitor 下执行过 cjpm build
# 用法：bash scripts/run.sh
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${EXAMPLE_ROOT}/../.." && pwd)"

BIN_DIR="${EXAMPLE_ROOT}/target/release/bin"
EXE="${BIN_DIR}/main"

if [[ ! -x "${EXE}" ]]; then
    echo "[!] 未找到 ${EXE}"
    echo "    请先在 examples/CjMonitor 下执行: cjpm build"
    exit 1
fi

# ---- 选择平台对应的桥接库目录 ----
case "$(uname -s)" in
    Linux)  BRIDGE_DIR="${REPO_ROOT}/releases/linux-x64" ;;
    Darwin) BRIDGE_DIR="${REPO_ROOT}/releases/macos-arm64" ;;
    *)      BRIDGE_DIR="${REPO_ROOT}/releases/linux-x64" ;;
esac

export CJQT6_ROOT="${REPO_ROOT}"
export DYLD_LIBRARY_PATH="${BRIDGE_DIR}:${BIN_DIR}:${EXAMPLE_ROOT}/target/release/cjqt6:${DYLD_LIBRARY_PATH:-}"
export LD_LIBRARY_PATH="${BRIDGE_DIR}:${BIN_DIR}:${EXAMPLE_ROOT}/target/release/cjqt6:${LD_LIBRARY_PATH:-}"

echo "[*] 仓库根  : ${REPO_ROOT}"
echo "[*] 桥接库  : ${BRIDGE_DIR}"
echo "[*] 启动    : ${EXE}"
echo

cd "${EXAMPLE_ROOT}"
exec "${EXE}" "$@"
