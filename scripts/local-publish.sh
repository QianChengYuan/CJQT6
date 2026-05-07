#!/bin/bash
# CJQT6本地发布脚本

set -e

echo "========================================"
echo "CJQT6 本地发布流程"
echo "========================================"

# 获取版本号
VERSION=$(grep '^  version = ' cjpm.toml | sed 's/.*"\(.*\)".*/\1/')
echo "版本: $VERSION"
echo ""

# 步骤1：验证包
echo "步骤1: 验证包完整性"
echo "-------------------"
bash scripts/verify-package.sh

if [[ $? -ne 0 ]]; then
    echo "❌ 包验证失败，请修复后再发布"
    exit 1
fi

echo ""
echo "✅ 包验证通过"
echo ""

# 步骤2：确认配置
echo "步骤2: 检查中心仓配置"
echo "-------------------"

if [[ ! -f "$HOME/.cjpm/cangjie-repo.toml" ]]; then
    echo "❌ 未找到用户目录配置: $HOME/.cjpm/cangjie-repo.toml"
    echo ""
    echo "请先创建配置文件:"
    echo "mkdir -p ~/.cjpm"
    echo "cp cangjie-repo.toml ~/.cjpm/"
    echo "# 编辑并填入token"
    exit 1
fi

TOKEN=$(grep 'token = ' "$HOME/.cjpm/cangjie-repo.toml" | sed 's/.*"\(.*\)".*/\1/')
if [[ -z "$TOKEN" ]] || [[ "$TOKEN" == "" ]]; then
    echo "❌ 未配置token，请在 ~/.cjpm/cangjie-repo.toml 中配置"
    exit 1
fi

echo "✅ 中心仓配置正确"
echo ""

# 步骤3：构建（如果需要）
echo "步骤3: 检查原生库"
echo "-------------------"

if [[ ! -d "native/build" ]] || [[ ! -f "native/build/libCJQT6_bridge.so" ]]; then
    echo "⚠️  原生库未构建"
    echo ""
    read -p "是否现在构建？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "开始构建原生库..."
        # bash scripts/build-all-platforms.sh
        echo "⚠️  请手动执行构建脚本"
    else
        echo "取消发布"
        exit 1
    fi
else
    echo "✅ 原生库已存在"
fi

echo ""

# 步骤4：发布前确认
echo "步骤4: 发布确认"
echo "-------------------"
echo ""
echo "即将发布以下内容到中心仓:"
echo "  主包: CJQT6@$VERSION"
echo "  平台包: 5个平台的native库包"
echo ""
echo "中心仓地址: https://pkg.cangjie-lang.cn/index"
echo ""

read -p "确认发布吗？(yes/no): " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "取消发布"
    exit 0
fi

# 步骤5：发布主包
echo ""
echo "步骤5: 发布主包"
echo "-------------------"
echo ""
echo "执行命令: cjpm pack"
# cjpm pack

echo ""
echo "执行命令: cjpm publish"
# cjpm publish

echo ""
echo "⚠️  注意: 上述命令已注释，请手动执行:"
echo "  cjpm pack"
echo "  cjpm publish"

# 步骤6：发布平台包
echo ""
echo "步骤6: 发布平台包（可选）"
echo "-------------------"
echo ""
echo "平台包发布命令:"
echo ""
for platform in linux-x64 linux-arm64 windows-x64 macos-x64 macos-arm64; do
    echo "  # 发布 $platform"
    echo "  cd packages/CJQT6-native-$platform"
    echo "  cjpm pack"
    echo "  cjpm publish"
    echo "  cd ../.."
    echo ""
done

# 步骤7：验证发布
echo "步骤7: 验证发布"
echo "-------------------"
echo ""
echo "发布后，请等待几分钟，然后验证:"
echo ""
echo "  # 搜索包"
echo "  cjpm search CJQT6"
echo ""
echo "  # 查看包详情"
echo "  cjpm show CJQT6@$VERSION"
echo ""
echo "  # 测试安装"
echo "  cjpm init test-app"
echo "  cd test-app"
echo "  cjpm add CJQT6"
echo ""

echo "========================================"
echo "发布流程说明完成"
echo "========================================"
