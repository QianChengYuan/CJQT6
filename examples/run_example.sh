#!/bin/bash
# CJQT6 示例运行脚本
# 设置库路径和输入法支持并运行示例

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LIB_PATH="$PROJECT_ROOT/native/build/lib"

# 设置库路径
export LD_LIBRARY_PATH="$LIB_PATH:$LD_LIBRARY_PATH"

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
    echo "正在运行: $1"
    echo "----------------------------------------"
    exec "$@"
else
    echo "用法: $0 <可执行文件路径>"
    exit 1
fi