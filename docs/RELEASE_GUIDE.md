# CJQT6 发布操作指南（更新版）

## 正确的发布命令

根据仓颉中心仓官方文档，发布流程如下：

1. **打包**：`cjpm bundle`
2. **发布**：`cjpm publish`

## 发布前准备

### 1. 检查 cjpm.toml 必需字段

确保包含以下字段：
- `name` - 模块名 ✅
- `version` - 版本号 ✅
- `description` - 描述信息（必须）
- `cjc-version` - 仓颉版本要求 ✅
- `output-type` - 输出类型 ✅

### 2. 检查文档文件

根目录必须包含：
- `README.md` 或 `README_zh.md` ✅

### 3. 配置打包范围

在 `cjpm.toml` 中添加：

```toml
[package]
  # ... 其他配置
  
  # 打包范围
  include = ["src", "doc", "docs"]
  exclude = ["*.txt", "*.log", "*.bak"]
```

## 发布流程

### 第一步：验证包完整性

```bash
bash scripts/verify-package.sh
```

### 第二步：打包

```bash
# 打包模块（生成 target/CJQT6-1.0.0.cjp）
cjpm bundle

# 查看生成的制品包
ls -lh target/*.cjp
ls -lh target/meta-data.json
```

打包流程会：
1. 检查模块配置
2. 编译检查
3. 运行测试（除非 --skip-test）
4. 代码静态检查（除非 --skip-lint）
5. 生成制品包 `CJQT6-1.0.0.cjp`
6. 生成元数据 `meta-data.json`

### 第三步：发布到中心仓

```bash
# 发布到中心仓
cjpm publish
```

发布前会自动检查：
- 编译产物目录中是否存在制品包
- 元数据文件是否存在
- 校验码是否匹配

如不存在会自动重新执行 `bundle`

### 第四步：验证发布结果

```bash
# 等待几分钟让索引更新
sleep 300

# 搜索包
cjpm search CJQT6

# 查看包详情
cjpm show CJQT6@1.0.0
```

### 第五步：测试安装

```bash
# 创建测试项目
cjpm init test-cjqt6
cd test-cjqt6

# 安装CJQT6
cjpm add CJQT6

# 查看安装结果
ls -la .cjpm/repository/
```

## 打包范围说明

### 默认打包的文件

- `cjpm.toml`
- `README.md` 和 `README_zh.md`

### 默认不打包的文件

- `cjpm.lock`
- `cangjie-repo.toml`
- 编译产物目录
- 构建脚本产物目录
- 所有二进制文件

### 自定义打包范围

在 `cjpm.toml` 中配置：

```toml
[package]
  # 包含 src 和 doc 目录
  include = ["src", "doc", "docs"]
  
  # 排除临时文件
  exclude = ["*.txt", "*.log", "*.bak", "test_*"]
```

## 常用命令

```bash
# 打包（跳过测试和静态检查）
cjpm bundle --skip-test --skip-lint

# 完整打包（运行测试和静态检查）
cjpm bundle

# 发布
cjpm publish

# 搜索包
cjpm search CJQT6

# 查看包详情
cjpm show CJQT6@1.0.0

# 安装包
cjpm add CJQT6
```

## 发布检查清单

### 打包前
- [ ] cjpm.toml 包含 description 字段
- [ ] README.md 存在
- [ ] include/exclude 配置正确
- [ ] 版本号已更新

### 打包后
- [ ] target/CJQT6-1.0.0.cjp 生成成功
- [ ] target/meta-data.json 生成成功
- [ ] 包大小合理

### 发布前
- [ ] token 已配置
- [ ] 制品包完整

### 发布后
- [ ] 包可搜索
- [ ] 包详情正确
- [ ] 安装测试成功

## 故障排查

### Q: bundle 失败，提示缺少 description

```bash
# 在 cjpm.toml 中添加 description
[package]
  description = "仓颉语言的Qt6封装库"
```

### Q: bundle 失败，提示缺少 README

```bash
# 确保根目录有 README.md
ls README.md
```

### Q: publish 失败，提示认证错误

```bash
# 检查 token 配置
cat ~/.cjpm/cangjie-repo.toml
```

### Q: publish 失败，提示包已存在

```bash
# 更新版本号
# 修改 cjpm.toml 中的 version

# 重新打包和发布
cjpm bundle
cjpm publish
```

## 完整示例

```bash
# 1. 验证包
bash scripts/verify-package.sh

# 2. 打包
cjpm bundle

# 3. 检查制品包
ls -lh target/CJQT6-1.0.0.cjp
ls -lh target/meta-data.json

# 4. 发布
cjpm publish

# 5. 验证
sleep 300
cjpm search CJQT6
cjpm show CJQT6@1.0.0

# 6. 测试安装
cjpm init test-app && cd test-app
cjpm add CJQT6
```

---

*正确的命令：`cjpm bundle` 打包，`cjpm publish` 发布*
