#!/bin/bash
# 安全推送脚本 - 推送前确认

echo "========================================"
echo "Git推送确认"
echo "========================================"

# 显示当前状态
echo ""
echo "当前分支: $(git branch --show-current)"
echo "最新提交: $(git log -1 --oneline)"
echo ""

# 显示未推送的提交
AHEAD=$(git rev-list --count origin/main..HEAD 2>/dev/null || echo "0")
echo "未推送的提交数: $AHEAD"

if [[ $AHEAD -gt 0 ]]; then
    echo ""
    echo "未推送的提交列表:"
    git log origin/main..HEAD --oneline --decorate
fi

# 显示工作区状态
echo ""
echo "工作区状态:"
git status --short

# 询问是否推送
echo ""
echo "========================================"
echo "⚠️  即将推送到远程仓库"
echo "========================================"
echo ""
echo "远程仓库: $(git remote get-url origin)"
echo ""
read -p "确认推送吗？(yes/no): " -r
echo

if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "正在推送..."
    git push origin main
    
    if [[ $? -eq 0 ]]; then
        echo ""
        echo "✅ 推送成功！"
        
        # 显示推送后的状态
        echo ""
        echo "推送后的状态:"
        git log --oneline -3
    else
        echo ""
        echo "❌ 推送失败！"
    fi
elif [[ $REPLY =~ ^[Nn][Oo]$ ]]; then
    echo "取消推送"
else
    echo "无效输入，取消推送"
fi
