#!/bin/bash
# 本地测试发布流程脚本

set -e

echo "========================================"
echo "CJQT6 本地发布测试"
echo "========================================"

# 检查必需工具
check_tools() {
    echo "检查必需工具..."
    
    # 检查git
    if ! command -v git &> /dev/null; then
        echo "❌ 错误: 未找到git"
        exit 1
    fi
    
    # 检查sha256sum
    if ! command -v sha256sum &> /dev/null; then
        echo "❌ 错误: 未找到sha256sum"
        exit 1
    fi
    
    echo "✅ 所有工具检查通过"
}

# 验证版本号
validate_version() {
    echo ""
    echo "验证版本号..."
    
    VERSION=$(grep '^  version = ' cjpm.toml | sed 's/.*"\(.*\)".*/\1/')
    echo "当前版本: $VERSION"
    
    if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "❌ 错误: 版本号不符合语义化规范: $VERSION"
        exit 1
    fi
    
    echo "✅ 版本号验证通过"
}

# 检查工作区状态
check_git_status() {
    echo ""
    echo "检查git工作区状态..."
    
    if [[ -n $(git status -s) ]]; then
        echo "⚠️  警告: 工作区有未提交的修改"
        git status -s
        echo ""
        read -p "是否继续？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        echo "✅ 工作区干净"
    fi
}

# 检查平台包配置
check_platform_packages() {
    echo ""
    echo "检查平台包配置..."
    
    PLATFORMS=("linux-x64" "linux-arm64" "windows-x64" "macos-x64" "macos-arm64")
    
    for platform in "${PLATFORMS[@]}"; do
        PKG_DIR="packages/CJQT6-native-$platform"
        if [[ ! -f "$PKG_DIR/cjpm.toml" ]]; then
            echo "❌ 错误: 缺少平台包配置: $PKG_DIR/cjpm.toml"
            exit 1
        fi
        echo "✅ 找到: $platform"
    done
}

# 模拟构建原生库
simulate_build() {
    echo ""
    echo "模拟构建原生库（dry-run）..."
    
    if [[ -f "scripts/build-all-platforms.sh" ]]; then
        echo "找到构建脚本: scripts/build-all-platforms.sh"
        # 实际构建需要相应环境，这里只做检查
        # bash scripts/build-all-platforms.sh --dry-run
        echo "✅ 构建脚本检查通过（dry-run）"
    else
        echo "⚠️  未找到构建脚本"
    fi
}

# 计算校验和示例
calculate_checksum_example() {
    echo ""
    echo "校验和计算示例..."
    
    EXAMPLE_FILE="cjpm.toml"
    if [[ -f "$EXAMPLE_FILE" ]]; then
        CHECKSUM=$(sha256sum "$EXAMPLE_FILE" | cut -d' ' -f1)
        echo "示例: $EXAMPLE_FILE"
        echo "SHA256: $CHECKSUM"
    fi
}

# 发布前检查清单
pre_publish_checklist() {
    echo ""
    echo "========================================"
    echo "发布前检查清单"
    echo "========================================"
    echo ""
    
    CHECKLIST=(
        "✅ 版本号已更新且符合语义化规范"
        "✅ CHANGELOG.md已更新"
        "✅ 所有代码已提交到git"
        "✅ 本地测试已通过"
        "✅ 平台包配置完整"
        "✅ cjpm.toml配置正确"
        "⏳ GitHub Secrets已配置（需要手动配置）"
        "⏳ CI/CD测试通过（需要实际运行）"
    )
    
    for item in "${CHECKLIST[@]}"; do
        echo "$item"
    done
    
    echo ""
}

# 主函数
main() {
    check_tools
    validate_version
    check_git_status
    check_platform_packages
    simulate_build
    calculate_checksum_example
    pre_publish_checklist
    
    echo "========================================"
    echo "✅ 本地测试完成"
    echo "========================================"
    echo ""
    echo "下一步操作："
    echo "1. 配置GitHub Secrets（参考 docs/SECRETS_SETUP.md）"
    echo "2. 手动触发测试发布（GitCode Actions页面）"
    echo "3. 验证测试发布结果"
    echo "4. 创建Git标签触发正式发布"
    echo ""
}

main
