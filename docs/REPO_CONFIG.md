# 中心仓客户端配置说明

## 配置文件位置

`cangjie-repo.toml` 配置文件可以放在以下三个位置，cjpm按顺序搜索：

1. **模块内配置**（优先级最高）
   - 位置：与 `cjpm.toml` 同级目录
   - 适用：项目特定配置

2. **用户目录配置**（推荐）
   - Linux/macOS: `$HOME/.cjpm/cangjie-repo.toml`
   - Windows: `%USERPROFILE%\.cjpm\cangjie-repo.toml`
   - 适用：用户全局配置

3. **SDK默认配置**（优先级最低）
   - 位置：仓颉SDK的 `tools/config` 目录
   - 适用：系统默认配置

## 配置字段说明

### [repository.cache]

本地缓存配置：

```toml
[repository.cache]
  path = "/path/to/cache"
```

- `path`: 本地缓存路径
  - 用于存放从中心仓下载的制品包源码
  - 可为绝对路径或相对路径
  - 若为空，使用系统默认路径：
    - Linux/macOS: `$HOME/.cjpm`
    - Windows: `%USERPROFILE%\.cjpm`
  - 制品包最终存放在 `${path}/repository` 目录

### [repository.home]

中心仓连接配置：

```toml
[repository.home]
  registry = "https://pkg.cangjie-lang.cn/registry"
  token = "your-personal-token"
```

- `registry`: 中心仓仓库地址
  - 用于与中心仓进行上传下载通信
  - 官方地址：`https://pkg.cangjie-lang.cn/registry`

- `token`: 用户个人token
  - 用于在上传制品包时进行用户认证
  - 下载制品包时不需要token

## 配置示例

### 示例1：使用默认缓存路径

```toml
[repository.cache]
  path = ""

[repository.home]
  registry = "https://pkg.cangjie-lang.cn/registry"
  token = "cj_1234567890abcdef"
```

### 示例2：自定义缓存路径

```toml
[repository.cache]
  path = "/home/user/.cjpm-cache"

[repository.home]
  registry = "https://pkg.cangjie-lang.cn/registry"
  token = "cj_1234567890abcdef"
```

### 示例3：仅下载（无需token）

```toml
[repository.cache]
  path = ""

[repository.home]
  registry = "https://pkg.cangjie-lang.cn/registry"
  token = ""
```

## 获取Token

1. 访问中心仓：https://pkg.cangjie-lang.cn/index
2. 登录您的账号
3. 进入用户设置 → API Tokens
4. 点击 "生成新token"
5. 复制token并配置到 `cangjie-repo.toml`

## 安全注意事项

### ⚠️ 重要提醒

- **不要将token提交到git仓库**
- 将 `cangjie-repo.toml` 添加到 `.gitignore`
- 使用环境变量或Secrets管理token

### 推荐做法

**方式1：使用用户目录配置**

将配置文件放在用户目录，而不是项目目录：

```bash
# Linux/macOS
mkdir -p ~/.cjpm
cp cangjie-repo.toml ~/.cjpm/

# Windows
mkdir %USERPROFILE%\.cjpm
copy cangjie-repo.toml %USERPROFILE%\.cjpm\
```

**方式2：使用环境变量**

在CI/CD中使用环境变量传递token：

```bash
# 设置环境变量
export CJPM_TOKEN="your-token"

# 在工作流中动态生成配置
cat > cangjie-repo.toml << EOF
[repository.cache]
  path = ""

[repository.home]
  registry = "https://pkg.cangjie-lang.cn/registry"
  token = "$CJPM_TOKEN"
EOF
```

**方式3：使用Secrets（GitHub Actions）**

```yaml
- name: Configure cjpm
  env:
    CJPM_TOKEN: ${{ secrets.CJPM_REGISTRY_TOKEN }}
  run: |
    mkdir -p ~/.cjpm
    cat > ~/.cjpm/cangjie-repo.toml << EOF
    [repository.cache]
      path = ""
    
    [repository.home]
      registry = "https://pkg.cangjie-lang.cn/registry"
      token = "$CJPM_TOKEN"
    EOF
```

## 验证配置

配置完成后，可以使用以下命令验证：

```bash
# 搜索包（验证下载功能）
cjpm search CJQT6

# 查看包详情
cjpm show CJQT6@1.0.0

# 发布包（验证上传功能，需要token）
cjpm publish --dry-run
```

## 常见问题

### Q: 下载包时提示连接失败？

检查：
1. `registry` 地址是否正确
2. 网络连接是否正常
3. 是否有防火墙或代理设置

### Q: 发布包时提示认证失败？

检查：
1. `token` 是否正确配置
2. token是否过期
3. token权限是否包含发布权限

### Q: 缓存路径权限错误？

检查：
1. 配置的 `path` 路径是否存在
2. 是否有读写权限
3. 磁盘空间是否充足

## 参考文档

- [中心仓客户端配置](https://pkgdocs.cangjie-lang.cn/docs/zh/1.0.0/central-repo/source_zh_cn/client/config.html)
- [制品包使用](https://pkgdocs.cangjie-lang.cn/docs/zh/1.0.0/central-repo/source_zh_cn/client/download.html)
- [制品包发布](https://pkgdocs.cangjie-lang.cn/docs/zh/1.0.0/central-repo/source_zh_cn/client/upload.html)

---

*最后更新: 2026-05-07*
