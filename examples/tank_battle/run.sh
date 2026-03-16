#!/bin/bash

# 坦克大战游戏运行脚本

# 设置库路径
export LD_LIBRARY_PATH=/home/yuan123/cangjiecode/CJQT6/native/build/lib:$LD_LIBRARY_PATH

# 编译项目
echo "正在编译坦克大战..."
cjpm build

if [ $? -ne 0 ]; then
    echo "编译失败！"
    exit 1
fi

echo "编译成功，启动游戏..."
echo ""
echo "操作说明："
echo "  方向键/WASD - 移动坦克"
echo "  空格/J - 发射子弹"
echo "  P - 暂停游戏"
echo "  R - 重新开始（游戏结束后）"
echo ""

# 运行游戏
cjpm run
