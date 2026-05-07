# CJQT6 发布操作指南

## 发布流程概述

```
本地测试发布 → 验证成功 → 发布到官网 → 最终验证
```

## 第一步：本地测试发布

### 1.1 配置中心仓Token

确认 `~/.cjpm/cangjie-repo.toml` 已配置token：

```toml
[repository.home]
  registry = "https://pkg.cangjie-lang.cn/registry"
  token = "your-token-here"  # ← 确认已填写
```

### 1.2 验证包完整性

```bash
# 运行包验证脚本
bash scripts/verify-package.sh

# 确认所有检查项通过
```

### 1.3 测试发布流程（dry-run）

```bash
# 打包但不发布（测试模式）
cjpm pack --dry-run

# 检查生成的包结构
ls -lh *.cjpkg
```

### 1.4 发布到测试环境

如果中心仓支持测试仓库：

```bash
# 修改配置指向测试仓库
# 在 cangjie-repo.toml 中修改 registry

# 发布
cjpm pack
cjpm publish

# 验证测试发布
cjpm search CJQT6
cjpm show CJQT6@1.0.0
```

## 第二步：正式发布到官网

### 2.1 最终检查

```bash
# 1. 确认版本号
grep "version" cjpm.toml

# 2. 确认所有文件已提交
git status

# 3. 确认文档已更新
cat CHANGELOG.md | head -20

# 4. 最后一次验证包
bash scripts/verify-package.sh
```

### 2.2 发布主包

```bash
# 打包
cjpm pack

# 发布
cjpm publish

# 查看发布结果
echo "主包发布完成"
```

### 2.3 发布平台包（如需要）

```bash
# 发布各平台原生库包
for platform in linux-x64 linux-arm64 windows-x64 macos-x64 macos-arm64; do
    echo "发布平台包: $platform"
    cd "packages/CJQT6-native-$platform"
    cjpm pack
    cjpm publish
    cd ../..
    echo "$platform 发布完成"
    echo ""
done
```

### 2.4 创建Git标签

```bash
# 创建版本标签
git tag -a v1.0.0 -m "Release v1.0.0"

# 推送标签
git push origin v1.0.0

# 验证标签
git tag -l
```

## 第三步：发布后验证

### 3.1 等待索引更新

```bash
# 等待5-10分钟，让中心仓索引更新
sleep 300
```

### 3.2 验证包可搜索

```bash
# 搜索包
cjpm search CJQT6

# 查看包详情
cjpm show CJQT6@1.0.0
```

### 3.3 测试安装

```bash
# 创建测试项目
cjpm init test-install
cd test-install

# 安装CJQT6
cjpm add CJQT6

# 检查安装结果
ls -lh .cjpm/repository/CJQT6/

# 测试运行（如果有示例）
cjpm run
```

## 第四步：发布公告

### 4.1 更新GitHub Release

访问：https://gitcode.com/yuan_1992/CJQT6/-/releases

创建新Release，内容参考：

```markdown
## CJQT6 v1.0.0 发布

### 安装方式
\`\`\`bash
cjpm add CJQT6
\`\`\`

### 主要特性
- 完整的Qt6控件封装
- FFI桥接技术
- 跨平台支持（Linux/Windows/macOS）
- 仓颉原生API风格

### 平台支持
- ✅ Linux x86_64/arm64
- ✅ Windows x86_64
- ✅ macOS x86_64/arm64

### 文档
- [快速开始](docs/quick-start.md)
- [API文档](docs/api/)
- [安装指南](docs/installation.md)

### 更新日志
查看 [CHANGELOG.md](CHANGELOG.md)
```

### 4.2 发布公告

在社区或社交媒体发布公告（可选）

## 常见问题处理

### Q: 发布失败，提示认证错误

```bash
# 检查token配置
cat ~/.cjpm/cangjie-repo.toml

# 重新生成token
# 访问中心仓 → 用户设置 → 生成新token
```

### Q: 发布成功但搜索不到

```bash
# 等待索引更新（5-10分钟）
# 或手动刷新索引
cjpm update
```

### Q: 如何发布新版本

```bash
# 1. 更新版本号
# 修改 cjpm.toml 中的 version

# 2. 更新CHANGELOG
# 记录变更内容

# 3. 提交代码
git commit -am "chore: bump version to 1.0.1"

# 4. 发布
cjpm pack && cjpm publish

# 5. 打标签
git tag v1.0.1
git push origin v1.0.1
```

## 发布检查清单

### 发布前
- [ ] Token已配置
- [ ] 包验证通过
- [ ] 文档已更新
- [ ] CHANGELOG已更新
- [ ] 本地测试通过

### 发布时
- [ ] 主包打包成功
- [ ] 主包发布成功
- [ ] 平台包发布成功（如需）
- [ ] Git标签已创建

### 发布后
- [ ] 包可搜索
- [ ] 包详情正确
- [ ] 安装测试成功
- [ ] GitHub Release已创建
- [ ] 发布公告已完成

## 相关命令速查

```bash
# 包管理
cjpm pack              # 打包
cjpm publish           # 发布
cjpm search <name>     # 搜索包
cjpm show <name>@<ver> # 查看包详情
cjpm add <name>        # 安装包
cjpm update            # 更新索引

# 验证
bash scripts/verify-package.sh  # 包验证
bash scripts/test-publish.sh    # 测试发布

# Git
git tag v1.0.0         # 创建标签
git push origin --tags # 推送标签
```

---

*祝发布顺利！* 🎉
