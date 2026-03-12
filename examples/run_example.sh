#!/bin/bash
# CJQT6 示例运行脚本
# 设置库路径和输入法支持并运行示例

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LIB_PATH="$SCRIPT_DIR/lib"
BRIDGE_LIB="$PROJECT_ROOT/native/build/lib/libcjqt6_bridge.so"

# 如果lib目录不存在或库文件过期，自动复制
if [ ! -f "$LIB_PATH/libcjqt6_bridge.so" ] || [ "$BRIDGE_LIB" -nt "$LIB_PATH/libcjqt6_bridge.so" ]; then
    mkdir -p "$LIB_PATH"
    cp "$BRIDGE_LIB" "$LIB_PATH/"
    echo "已更新库文件到 examples/lib/"
fi

# 设置库路径（包含cjqt6_bridge和仓颉运行时）
CANGJIE_RUNTIME="/home/yuan123/cangjie/cangjie_1.1.0/cangjie/runtime/lib/linux_x86_64_cjnative"
export LD_LIBRARY_PATH="$LIB_PATH:$CANGJIE_RUNTIME:$LD_LIBRARY_PATH"

# QML 导入路径（Qt6 QML 模块位置）
export QML2_IMPORT_PATH="/usr/lib/x86_64-linux-gnu/qt6/qml"

# ===== 输入法配置 =====
# 检查并启动ibus
if command -v ibus-daemon &> /dev/null; then
    # 启动ibus守护进程（如果未运行）
    if ! pgrep -x "ibus-daemon" > /dev/null; then
        ibus-daemon -drx
        sleep 1
    fi
    
    # 设置ibus输入法环境变量
    export GTK_IM_MODULE=ibus
    export QT_IM_MODULE=ibus
    export XMODIFIERS=@im=ibus
    export IBUS_ADDRESS=unix:path=/run/user/$(id -u)/ibus/socket
    
    echo "已启用 IBus 输入法支持"
    echo "切换输入法: 点击输入框后按 Super+Space 或 Ctrl+Space"
elif command -v fcitx &> /dev/null || command -v fcitx5 &> /dev/null; then
    export QT_IM_MODULE=fcitx
    export GTK_IM_MODULE=fcitx
    export XMODIFIERS=@im=fcitx
    echo "已启用 Fcitx 输入法支持"
else
    # WSL环境下使用XIM作为后备
    export QT_IM_MODULE=xim
    echo "使用 XIM 输入法（后备模式）"
fi

# 运行参数指定的可执行文件
if [ -n "$1" ]; then
    # QML 应用与某些输入法配置有兼容性问题，清除输入法环境变量
    if [[ "$1" == *"qml"* ]]; then
        unset GTK_IM_MODULE
        unset QT_IM_MODULE
        unset XMODIFIERS
        unset IBUS_ADDRESS
        echo "正在运行: $1 (QML模式)"
    else
        echo "正在运行: $1"
    fi
    echo "----------------------------------------"
    exec "$@"
else
    echo "用法: $0 <可执行文件路径>"
    exit 1
fi