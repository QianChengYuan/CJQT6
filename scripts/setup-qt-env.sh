#!/bin/bash
# CJQT6 运行环境配置脚本
# 设置Qt6环境变量

QT_PATH="/c/Qt/6.10.2/mingw_64"
MINGW_PATH="/c/Qt/Tools/mingw1310_64/bin"

echo "=== 配置Qt6运行环境 ==="

# 检查Qt路径
if [ ! -d "$QT_PATH" ]; then
    echo "❌ Qt6路径不存在: $QT_PATH"
    echo "请修改脚本中的QT_PATH变量为您的Qt安装路径"
    exit 1
fi

# 设置环境变量
export PATH="$QT_PATH/bin:$MINGW_PATH:$PATH"
export QTDIR="$QT_PATH"

echo "✅ Qt6环境已配置"
echo "Qt路径: $QT_PATH"
echo ""
echo "环境变量已设置："
echo "PATH已添加: $QT_PATH/bin"
echo "PATH已添加: $MINGW_PATH"
echo ""
echo "现在可以运行Qt应用："
echo "  cjpm run"
echo "  或直接运行exe文件"
echo ""

# 如果有参数，执行该命令
if [ $# -gt 0 ]; then
    echo "执行命令: $@"
    "$@"
fi
