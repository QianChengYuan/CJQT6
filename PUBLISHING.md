# CJQT6 发布指南

本文档说明如何将CJQT6发布到仓颉中心仓。

## 发布流程

### 1. 准备发布

```bash
# 1. 确保代码已提交
git status

# 2. 更新版本号（在cjpm.toml中）
# 遵循语义化版本：MAJOR.MINOR.PATCH

# 3. 更新CHANGELOG.md
# 记录本次发布的变更内容

# 4. 本地测试
cjpm build
cjpm test
```

### 2. 触发发布

**方式A：通过Git标签触发（推荐）**

```bash
# 创建版本标签
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions将自动：
# - 构建所有平台原生库
# - 发布到中心仓
# - 创建GitHub Release
```

**方式B：手动触发**

访问 GitHub Actions 页面：
https://gitcode.com/yuan_1992/CJQT6/pipelines

选择 "Publish to Central Repository" 工作流，点击 "Run workflow"，选择目标：
- `test` - 发布到测试仓
- `production` - 发布到生产仓

### 3. 发布后验证

```bash
# 搜索包
cjpm search CJQT6

# 查看包详情
cjpm show CJQT6@1.0.0

# 测试安装
cjpm init test-app
cd test-app
cjpm add CJQT6
cjpm run
```

## 平台包说明

CJQT6采用**平台分包策略**，用户安装时自动下载对应平台的原生库：

| 主包 | 平台包 | 大小 |
|-----|--------|------|
| CJQT6 | - | ~1MB（仓颉代码） |
| - | CJQT6-native-linux-x64 | ~5MB |
| - | CJQT6-native-windows-x64 | ~5MB |
| - | CJQT6-native-macos-x64 | ~5MB |

用户只需执行 `cjpm add CJQT6`，系统自动选择平台包。

## 版本管理

### 语义化版本规范

- **MAJOR**（主版本）：不兼容的API变更
- **MINOR**（次版本）：向下兼容的功能新增
- **PATCH**（修订版本）：向下兼容的问题修复

### 版本对应关系

推荐与Qt版本对应：

| CJQT6版本 | Qt版本 | 说明 |
|----------|--------|------|
| 6.2.0 | Qt 6.2.x | 基础版本 |
| 6.3.0 | Qt 6.3.x | 新增功能 |
| 6.4.0 | Qt 6.4.x | 新增功能 |

### 更新版本步骤

1. 更新主包 `cjpm.toml` 的 `version`
2. 更新所有平台包的 `version`
3. 更新 `CHANGELOG.md`
4. 提交并打标签

## 发布检查清单

### 发布前

- [ ] 代码已全部提交
- [ ] 版本号已更新（符合语义化规范）
- [ ] CHANGELOG.md已更新
- [ ] 本地测试通过（build、test）
- [ ] CI/CD构建成功
- [ ] 文档已更新

### 发布后

- [ ] 中心仓可搜索到包
- [ ] 版本号正确
- [ ] 安装测试成功
- [ ] 示例程序运行正常
- [ ] GitHub Release已创建
- [ ] 发布公告已完成

## 凭据配置

### GitHub Secrets

需要在仓库设置中配置以下Secrets：

| Secret名称 | 说明 | 获取方式 |
|-----------|------|---------|
| CJPM_REGISTRY_TOKEN | 中心仓发布token | 中心仓用户设置 |
| CJPM_REGISTRY_URL | 中心仓地址（可选） | 默认使用官方地址 |

配置步骤：

1. 访问中心仓 https://pkg.cangjie-lang.cn/index，生成发布token
2. 在GitCode仓库设置中添加Secret
3. 工作流会自动使用Secret

## 常见问题

### Q: 发布失败，提示认证错误？

检查：
- CJPM_REGISTRY_TOKEN是否正确配置
- token是否过期
- 是否有发布权限

### Q: 发布成功但搜索不到？

等待中心仓索引更新（通常需要几分钟）

### Q: 如何发布测试版本？

使用版本前缀：
- `1.0.0-alpha.1` - alpha版本
- `1.0.0-beta.1` - beta版本
- `1.0.0-rc.1` - release candidate

### Q: 如何回滚发布？

中心仓通常不允许删除已发布版本，只能发布新版本修复问题。

## 相关资源

- [仓颉中心仓文档](https://pkgdocs.cangjie-lang.cn/docs/zh/1.0.0/central-repo/source_zh_cn/client/config.html)
- [语义化版本规范](https://semver.org/lang/zh-CN/)
- [GitHub Actions文档](https://docs.github.com/actions)

---

*最后更新: 2026-05-07*
