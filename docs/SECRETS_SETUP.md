# GitHub Secrets 配置指南

## 为什么需要配置Secrets？

GitHub Secrets用于安全地存储敏感信息，如发布token。工作流会自动使用这些Secrets进行中心仓认证。

## 需要配置的Secrets

| Secret名称 | 说明 | 是否必需 | 默认值 |
|-----------|------|---------|--------|
| CJPM_REGISTRY_TOKEN | 仓颉中心仓发布token | ✅ 必需 | 无 |
| CJPM_REGISTRY_URL | 中心仓地址 | ⭕ 可选 | https://registry.cangjie.cn |

## 配置步骤

### 步骤1：获取中心仓发布Token

1. **登录仓颉中心仓**
   - 访问：https://registry.cangjie.cn（或官方提供的地址）
   - 使用您的账号登录

2. **生成发布Token**
   - 进入用户设置 → API Tokens 或 Developer Settings
   - 点击 "Generate new token"
   - 选择权限：`publish` (发布权限)
   - 复制生成的token（⚠️ 仅显示一次，请妥善保存）

### 步骤2：在GitCode配置Secret

1. **访问仓库设置**
   ```
   https://gitcode.com/yuan_1992/CJQT6/-/settings/secrets
   ```

2. **添加新Secret**
   - 点击 "New secret" 或 "添加密钥"
   - Name: `CJPM_REGISTRY_TOKEN`
   - Value: 粘贴步骤1获取的token
   - 点击 "Add secret" 保存

3. **验证配置**
   - 在Secrets列表中应能看到 `CJPM_REGISTRY_TOKEN`
   - 状态显示为 "Updated just now"

### 步骤3：测试Secret配置

1. **手动触发工作流**
   - 访问：https://gitcode.com/yuan_1992/CJQT6/-/pipelines
   - 选择 "Publish to Central Repository"
   - 点击 "Run workflow"
   - 选择 target: `test`
   - 点击 "Run workflow"

2. **查看执行日志**
   - 点击正在运行的工作流
   - 查看 "Login to registry" 步骤
   - 确认没有认证错误

## 安全最佳实践

### ✅ 应该做的

- ✅ 使用最小权限原则，token只授予必需的权限
- ✅ 定期轮换token（建议每3-6个月）
- ✅ token泄露后立即撤销并重新生成
- ✅ 使用环境变量引用，不要硬编码

### ❌ 不应该做的

- ❌ 不要在代码中硬编码token
- ❌ 不要在日志中输出token
- ❌ 不要将token提交到git仓库
- ❌ 不要与他人共享token

## Token权限说明

仓颉中心仓token通常需要以下权限：

| 权限 | 说明 | 必需 |
|-----|------|------|
| read:packages | 读取包信息 | ✅ |
| write:packages | 发布包 | ✅ |
| delete:packages | 删除包（可选） | ❌ |

## 多环境配置

如果需要区分测试和生产环境，可以配置不同的token：

| Secret名称 | 用途 |
|-----------|------|
| CJPM_REGISTRY_TOKEN_TEST | 测试仓token |
| CJPM_REGISTRY_TOKEN_PROD | 生产仓token |

在发布工作流中根据环境选择使用哪个token。

## 故障排查

### 问题1：Secret配置后仍提示认证失败

**可能原因：**
- Token权限不足
- Token已过期
- Token格式错误

**解决方法：**
1. 检查token权限是否包含 `write:packages`
2. 重新生成token并更新Secret
3. 确认token没有多余的空格或换行

### 问题2：Secret在fork的仓库中不可用

**说明：**
GitHub Secrets不会自动复制到fork的仓库

**解决方法：**
在fork的仓库中重新配置Secrets

### 问题3：如何更新已配置的Secret？

**步骤：**
1. 进入仓库设置 → Secrets
2. 找到要更新的Secret
3. 点击 "Update" 或直接添加同名Secret覆盖
4. 保存新值

## 参考链接

- [GitHub Actions Secrets文档](https://docs.github.com/actions/security-guides/encrypted-secrets)
- [仓颉中心仓API文档](https://cangjie-lang.cn/docs/registry-api)

---

**配置完成后，您就可以：**
- ✅ 通过Git标签触发自动发布
- ✅ 手动触发测试发布
- ✅ CI/CD自动完成构建和发布

**下一步：** 测试发布流程 → 正式发布v1.0.0
