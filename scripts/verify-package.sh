#!/bin/bash
# CJQT6包完整性验证脚本

set -e

echo "========================================"
echo "CJQT6 包完整性验证"
echo "========================================"

ERRORS=0
WARNINGS=0

# 检查主包配置
check_main_package() {
    echo ""
    echo "1. 检查主包配置 (cjpm.toml)"
    echo "   ------------------------"
    
    if [[ ! -f "cjpm.toml" ]]; then
        echo "   ❌ 错误: cjpm.toml 不存在"
        ((ERRORS++))
        return
    fi
    
    # 检查必需字段
    NAME=$(grep '^  name = ' cjpm.toml | sed 's/.*"\(.*\)".*/\1/')
    VERSION=$(grep '^  version = ' cjpm.toml | sed 's/.*"\(.*\)".*/\1/')
    CJC_VERSION=$(grep '^  cjc-version = ' cjpm.toml | sed 's/.*"\(.*\)".*/\1/')
    
    echo "   包名: $NAME"
    echo "   版本: $VERSION"
    echo "   仓颉版本要求: $CJC_VERSION"
    
    if [[ -z "$NAME" ]] || [[ -z "$VERSION" ]]; then
        echo "   ❌ 错误: 缺少必需字段"
        ((ERRORS++))
    else
        echo "   ✅ 主包配置完整"
    fi
    
    # 验证版本号格式
    if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "   ❌ 错误: 版本号不符合语义化规范"
        ((ERRORS++))
    fi
}

# 检查平台包配置
check_platform_packages() {
    echo ""
    echo "2. 检查平台包配置"
    echo "   ----------------"
    
    PLATFORMS=("linux-x64" "linux-arm64" "windows-x64" "macos-x64" "macos-arm64")
    FOUND=0
    
    for platform in "${PLATFORMS[@]}"; do
        PKG_DIR="packages/CJQT6-native-$platform"
        PKG_TOML="$PKG_DIR/cjpm.toml"
        
        if [[ ! -f "$PKG_TOML" ]]; then
            echo "   ❌ 缺少: $platform"
            ((ERRORS++))
        else
            PKG_NAME=$(grep '^  name = ' "$PKG_TOML" | sed 's/.*"\(.*\)".*/\1/')
            PKG_VERSION=$(grep '^  version = ' "$PKG_TOML" | sed 's/.*"\(.*\)".*/\1/')
            PKG_PLATFORM=$(grep '^  platform = ' "$PKG_TOML" | sed 's/.*"\(.*\)".*/\1/')
            
            echo "   ✅ $platform: $PKG_NAME@$PKG_VERSION"
            ((FOUND++))
            
            # 验证版本号一致性
            if [[ "$PKG_VERSION" != "$VERSION" ]]; then
                echo "      ⚠️  警告: 版本号与主包不一致 ($PKG_VERSION vs $VERSION)"
                ((WARNINGS++))
            fi
        fi
    done
    
    echo ""
    echo "   平台包总数: $FOUND / ${#PLATFORMS[@]}"
}

# 检查源代码
check_source_code() {
    echo ""
    echo "3. 检查源代码"
    echo "   -----------"
    
    if [[ ! -d "src" ]]; then
        echo "   ❌ 错误: src目录不存在"
        ((ERRORS++))
        return
    fi
    
    # 检查核心模块
    CORE_MODULES=("core" "widgets" "gui")
    for module in "${CORE_MODULES[@]}"; do
        if [[ -d "src/$module" ]]; then
            FILES=$(find "src/$module" -name "*.cj" | wc -l)
            echo "   ✅ $module: $FILES 个文件"
        else
            echo "   ❌ 缺少模块: $module"
            ((ERRORS++))
        fi
    done
}

# 检查文档
check_documentation() {
    echo ""
    echo "4. 检查文档"
    echo "   --------"
    
    DOCS=("README.md" "CHANGELOG.md" "PUBLISHING.md" "docs/SECRETS_SETUP.md" "docs/REPO_CONFIG.md")
    
    for doc in "${DOCS[@]}"; do
        if [[ -f "$doc" ]]; then
            LINES=$(wc -l < "$doc")
            echo "   ✅ $doc ($LINES 行)"
        else
            echo "   ⚠️  缺少文档: $doc"
            ((WARNINGS++))
        fi
    done
}

# 检查配置文件
check_config_files() {
    echo ""
    echo "5. 检查配置文件"
    echo "   ------------"
    
    CONFIGS=(".gitignore" "cangjie-repo.toml" ".github/workflows/publish.yml")
    
    for config in "${CONFIGS[@]}"; do
        if [[ -f "$config" ]]; then
            echo "   ✅ $config"
        else
            echo "   ❌ 缺少配置: $config"
            ((ERRORS++))
        fi
    done
}

# 检查中心仓配置
check_repo_config() {
    echo ""
    echo "6. 检查中心仓配置"
    echo "   --------------"
    
    if [[ -f "cangjie-repo.toml" ]]; then
        REGISTRY=$(grep 'registry = ' cangjie-repo.toml | sed 's/.*"\(.*\)".*/\1/')
        TOKEN=$(grep 'token = ' cangjie-repo.toml | sed 's/.*"\(.*\)".*/\1/')
        
        echo "   中心仓地址: $REGISTRY"
        
        if [[ -z "$TOKEN" ]] || [[ "$TOKEN" == "" ]]; then
            echo "   ⚠️  警告: 未配置token（发布时需要）"
            ((WARNINGS++))
        else
            echo "   ✅ token已配置"
        fi
    fi
}

# 生成验证报告
generate_report() {
    echo ""
    echo "========================================"
    echo "验证报告"
    echo "========================================"
    echo ""
    echo "错误数: $ERRORS"
    echo "警告数: $WARNINGS"
    echo ""
    
    if [[ $ERRORS -eq 0 ]]; then
        echo "✅ 包结构完整，可以发布"
        
        if [[ $WARNINGS -gt 0 ]]; then
            echo "⚠️  有 $WARNINGS 个警告，建议修复后再发布"
        fi
        
        echo ""
        echo "下一步操作："
        echo "1. 配置中心仓token（如未配置）"
        echo "2. 测试发布: git push触发GitHub Actions"
        echo "3. 正式发布: git tag v$VERSION && git push --tags"
        
        return 0
    else
        echo "❌ 发现 $ERRORS 个错误，请修复后再发布"
        return 1
    fi
}

# 主函数
main() {
    check_main_package
    check_platform_packages
    check_source_code
    check_documentation
    check_config_files
    check_repo_config
    generate_report
}

main
