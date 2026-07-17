#!/bin/bash
# CJFW 仓颉语言Qt6测试程序运行脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CANGJIE_RUNTIME="/home/yuan123/cangjie/cangjie_1.0.5/cangjie/runtime/lib/linux_x86_64_cjnative"
BUILD_LIB="$SCRIPT_DIR/build/lib"

export LD_LIBRARY_PATH="$BUILD_LIB:$CANGJIE_RUNTIME:$LD_LIBRARY_PATH"

echo "=== 运行 CJFW 测试程序 ==="
echo "仓颉运行时: $CANGJIE_RUNTIME"
echo "桥接库路径: $BUILD_LIB"
echo ""

"$SCRIPT_DIR/build/bin/test_qt" "$@"
