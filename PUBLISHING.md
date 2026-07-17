# CJQT6 发布指南

本文档说明如何将 CJQT6 发布到仓颉中心仓（Cangjie Central Repository）。

## 发布流程概览

```
cjpm bundle  →  打包成制品包 (.cjp)
cjpm publish →  发布到中心仓
```

---

## 1. 前置条件：中心仓客户端配置

发布前需要配置 `cangjie-repo.toml`，用于 cjpm 与中心仓的认证通信。

### 1.1 配置文件位置

cjpm 按以下优先级搜索 `cangjie-repo.toml`，找到第一个即停止：

| 优先级 | 位置 | 说明 |
|--------|------|------|
| ① | 项目内（与 `cjpm.toml` 同级） | 项目级配置 |
| ② | `~/.cjpm/cangjie-repo.toml`（Linux/macOS）<br>`%USERPROFILE%\.cjpm\cangjie-repo.toml`（Windows） | 用户级全局配置 |
| ③ | `<SDK>/tools/config/cangjie-repo.toml` | SDK 默认配置 |

**推荐**：将 `cangjie-repo.toml` 放在用户目录（②），避免 token 泄露到项目仓库。

### 1.2 配置文件格式

```toml
[repository.cache]
  path = ""  # 本地缓存路径，留空则默认为 ~/.cjpm 或 %USERPROFILE%\.cjpm

[repository.home]
  registry = "https://pkg.cangjie-lang.cn/registry"  # 中心仓地址（固定值）
  token = "user-token"                                # 用户个人 token
```

字段说明：

- **`repository.cache.path`**：本地缓存路径，用于存放从中心仓下载的制品包源码
  - 可为绝对路径或相对路径（相对于当前 `cangjie-repo.toml`）
  - 若留空，Linux/macOS 默认为 `$HOME/.cjpm`，Windows 默认为 `%USERPROFILE%\.cjpm`
  - 制品包实际存放在 `${CACHE_PATH}/repository` 目录下
- **`repository.home.registry`**：中心仓地址，固定为 `https://pkg.cangjie-lang.cn/registry`
- **`repository.home.token`**：用户个人 token，用于上传制品包时进行用户认证

### 1.3 获取 Token

1. 访问中心仓官网：https://pkg.cangjie-lang.cn
2. 注册/登录账号
3. 进入用户设置 → 生成个人 token
4. 将 token 填入 `cangjie-repo.toml` 的 `token` 字段

> **安全提醒**：token 相当于你的密码，不要提交到代码仓库。推荐的做法：
> - 将 `cangjie-repo.toml` 放在用户目录（~/.cjpm/）
> - 或使用环境变量注入（`$env:MY_TOKEN`），但官方配置目前仅支持文件中的 token 字段

---

## 2. 项目配置要求

发布前，需要确保 `cjpm.toml` 的配置满足中心仓要求。

### 2.1 必填字段

| 字段 | 当前值 | 要求 |
|------|--------|------|
| `cjc-version` | `"1.1.0"` | 仓颉 SDK 最低版本号 |
| `name` | `"cjqt6"` | 模块名，长度 [3, 64]，不能为仓颉关键字 |
| `description` | ✅ 已填 | 模块说明，打包时必须 |
| `version` | `"1.1.0"` | 语义化版本号 |
| `output-type` | `"dynamic"` | static / dynamic / executable |
| `include` | ✅ 已配 | 打包范围，建议包含 `["src", "doc", "native/includes"]` |
| `exclude` | ✅ 已配 | 排除文件 |
| `license` | `"MIT"` | 需遵循 SPDX Identifier 规范 |

### 2.2 建议填写的字段

| 字段 | 当前值 | 说明 |
|------|--------|------|
| `organization` | 未设置 | 组织名，为空则为无组织模块。设置后发布到组织名下 |
| `authors` | `author = "CJQT6 Team"` | 官方字段为 `authors`（数组），建议改为 `authors = ["CJQT6 Team"]` |
| `repository` | ✅ 已填 | 源码仓库 url |
| `homepage` | ✅ 已填 | 项目主页 url |
| `documentation` | ✅ 已填 | 文档页 url |
| `tag` | ✅ 已配 (`keywords`) | 制品标签，用于中心仓搜索 |
| `category` | ✅ 已配 (`metadata.category`) | 制品分类 |

### 2.3 README 要求

中心仓要求模块根目录下必须包含以下至少一个文件：
- `README.md`（英文文档）
- `README_zh.md`（中文文档）

当前项目已有 `README.md` ✅

### 2.4 依赖项要求

所有 `[dependencies]` 必须为中心仓形式（即 `"版本号"` 格式），不能有 `path` 或 `git` 形式的本地依赖。

---

## 3. 打包（cjpm bundle）

### 3.1 打包命令

```bash
# 基础打包
cjpm bundle

# 打包时跳过测试
cjpm bundle --skip-test

# 打包时跳过 lint 检查
cjpm bundle --skip-lint

# 打包时跳过测试和 lint
cjpm bundle --skip-test --skip-lint
```

### 3.2 打包流程

`cjpm bundle` 执行以下四个步骤：

1. **模块检查**
   - 模块名、组织名长度 [3, 64]，非仓颉关键字
   - `cjpm.toml` 包含 `description`
   - 根目录包含 `README.md` 或 `README_zh.md`
   - 所有依赖项均为中心仓形式（不能有 `path`/`git` 依赖）
   - 若上述检查不通过，打包失败

2. **编译检查**
   - 确保模块能够编译通过
   - 若未配置 `--skip-test`，会运行单元测试
   - 编译或测试失败 → 打包失败

3. **代码静态检查**
   - 若未配置 `--skip-lint`，会调用 `cjlint` 进行代码静态检查
   - 出现 `error` 级别的错误 → 打包失败

4. **打包**
   - 基于 `include` 和 `exclude` 字段，将当前模块打包为 `tar.gz` 格式的制品源码包
   - 制品包位于编译产物目录，文件名格式：`模块名-版本号.cjp`
   - 同时生成元数据文件 `meta-data.json`

### 3.3 打包范围规则

`include` 和 `exclude` 均遵循 gitignore 格式的匹配规则，最终打包范围如下：

- **默认始终打包**：`cjpm.toml`、`README.md`、`README_zh.md`
- **默认始终排除**：`cjpm.lock`、`cangjie-repo.toml`、编译产物目录、所有二进制文件
- **其他文件**：匹配任意 `include` 且不匹配任意 `exclude` 的文件会被打包

当前配置：

```toml
include = ["src", "doc", "docs", "examples", "native/includes"]
exclude = ["*.txt", "*.log", "*.bak", "*.tmp", "test_*", "build_*"]
```

> **注意**：如果模块包含本地 `path` 或 `git` 依赖，`bundle` 会失败。需要先将所有依赖改为中心仓形式，或使用 `replace` 字段处理冲突。

### 3.4 打包产物

```text
target/
├── cjqt6-1.1.0.cjp   # 制品源码包（tar.gz 格式）
├── meta-data.json     # 制品元数据
└── ...                # 其他编译产物
```

---

## 4. 发布（cjpm publish）

### 4.1 发布命令

```bash
cjpm publish
```

### 4.2 发布流程

`cjpm publish` 执行以下操作：

1. 检查编译产物目录中是否存在 `模块名-版本号.cjp` 和 `meta-data.json`
2. 若任意文件不存在，或元数据中的校验码与制品包不匹配，则自动重新执行 `bundle` 流程
3. 将有效的制品源码包和元数据发布到中心仓

### 4.3 发布成功条件

1. **Token 有效**：已在 `cangjie-repo.toml` 中配置有效的用户 token
2. **制品唯一**：中心仓中不存在另一个组织名、制品名和版本号均相同的制品包
3. **组织权限**：若制品包隶属于某个组织，token 对应的用户需是该组织成员
4. **安全扫描**：发布的制品包通过中心仓的安全扫描

> **注意**：中心仓不允许覆盖已存在的版本。如需修复问题，只能发布新版本（升级版本号）。

---

## 5. 完整发布流程

```bash
# 1. 确保代码已提交
git status

# 2. 更新版本号
# 编辑 cjpm.toml 中的 version 字段

# 3. 更新 CHANGELOG.md

# 4. 本地验证
cjpm build
cjpm test

# 5. 打包
cjpm bundle

# 6. 发布到中心仓
cjpm publish
```

### 一键发布脚本

```bash
#!/bin/bash
set -e
echo "=== 发布 CJQT6 ==="
git status
cjpm build
cjpm test
cjpm bundle
cjpm publish
echo "=== 发布完成 ==="
```

---

## 6. 发布后验证

```bash
# 搜索包
cjpm search cjqt6

# 查看包详情
cjpm show cjqt6@1.1.0

# 测试安装到新项目
mkdir -p /tmp/test-publish && cd /tmp/test-publish
cjpm init test-app
cd test-app
# 在 cjpm.toml 中添加依赖
# [dependencies]
#   cjqt6 = "1.1.0"
cjpm build
```

---

## 7. 版本管理

### 7.1 语义化版本规范

- **MAJOR**：不兼容的 API 变更
- **MINOR**：向下兼容的功能新增
- **PATCH**：向下兼容的问题修复

### 7.2 与 Qt 版本对应

| CJQT6 版本 | Qt 版本 | 说明 |
|------------|---------|------|
| 1.0.0 | Qt 6.2.x | 初始版本 |
| 1.1.0 | Qt 6.2.x | 新增网络模块、SQL 模块 |

### 7.3 预发布版本后缀

- `1.0.0-alpha.1` — Alpha 版本
- `1.0.0-beta.1` — Beta 版本
- `1.0.0-rc.1` — Release Candidate

---

## 8. 发布检查清单

### 发布前

- [ ] 代码已全部提交
- [ ] 版本号已更新（`cjpm.toml` 中的 `version`）
- [ ] `CHANGELOG.md` 已更新
- [ ] `description` 字段已填写
- [ ] `README.md` 或 `README_zh.md` 存在
- [ ] 所有依赖项均为中心仓形式（`version` 格式，无 `path`/`git`）
- [ ] `cangjie-repo.toml` 中已配置有效 token
- [ ] 本地构建通过（`cjpm build`）
- [ ] 本地测试通过（`cjpm test`）
- [ ] 打包无报错（`cjpm bundle`）

### 发布后

- [ ] 中心仓可搜索到包（`cjpm search cjqt6`）
- [ ] 版本号正确（`cjpm show cjqt6@1.x.x`）
- [ ] 从零安装测试通过

---

## 9. 常见问题

### Q: `cjpm bundle` 失败，提示模块检查不通过？

检查以下项目：
- 模块名长度是否在 [3, 64] 范围内
- 模块名是否为仓颉关键字（大小写不敏感）
- `cjpm.toml` 中是否包含 `description` 字段
- 根目录是否存在 `README.md` 或 `README_zh.md`
- 所有依赖项是否已改为中心仓形式（`版本号` 格式）

### Q: `cjpm publish` 失败，提示认证错误？

检查：
- `cangjie-repo.toml` 中的 token 是否配置正确
- token 是否已过期（需在中心仓官网重新生成）
- 是否有目标组织/模块的发布权限

### Q: 发布成功但搜索不到？

等待中心仓索引更新（通常需要几分钟）。如果长时间未出现，检查：
- 是否发布了正确的版本号
- 搜索命令是否匹配了正确的包名

### Q: 中心仓没有这个包，怎么第一次上传？

正常执行 `cjpm bundle` + `cjpm publish` 即可。中心仓会自动创建新的制品记录。

### Q: 如何回滚发布？

中心仓通常不允许删除已发布版本，只能发布新版本修复问题。如需废弃某个版本，请发布新版本并在 `CHANGELOG.md` 中说明。

### Q: 项目有本地/路径依赖（path/git 依赖），怎么发布？

中心仓要求所有依赖项均为中心仓形式。需要：
1. 将本地依赖的模块先发布到中心仓
2. 将当前项目的依赖改为中心仓引用方式
3. 或使用 `[replace]` 字段强制指定版本（仅限单一版本号）

### Q: `cjpm bundle` 提示编译错误？

检查：
- 仓颉编译器版本是否满足 `cjc-version` 要求
- 运行 `cjpm build` 是否可以通过
- 如果有测试失败，使用 `--skip-test` 临时跳过（但不推荐）

---

## 10. 相关资源

- [仓颉中心仓官网](https://pkg.cangjie-lang.cn)
- [中心仓客户端配置](https://pkgdocs.cangjie-lang.cn/docs/zh/1.0.0/central-repo/source_zh_cn/client/config.html)
- [制品包使用](https://pkgdocs.cangjie-lang.cn/docs/zh/1.0.0/central-repo/source_zh_cn/client/download.html)
- [制品包发布](https://pkgdocs.cangjie-lang.cn/docs/zh/1.0.0/central-repo/source_zh_cn/client/upload.html)
- [中心仓概述](https://pkgdocs.cangjie-lang.cn/docs/zh/1.0.0/central-repo/source_zh_cn/overview.html)
- [semver 语义化版本规范](https://semver.org/lang/zh-CN/)

---

*最后更新: 2026-07-17*
