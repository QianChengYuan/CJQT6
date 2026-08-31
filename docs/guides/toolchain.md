# 工具链治理指南（cjfmt + cjlint + CI）

> 对应 roadmap 9.5。本仓库的仓颉代码格式化、静态检查与 CI 门禁配置。

---

## 1. 代码格式化（cjfmt）

### 1.1 配置文件

项目根目录 `cangjie-format.toml`：

```toml
indentWidth = 4                                # 缩进宽度
linelimitLength = 120                          # 行长度限制
lineBreakType = "LF"                           # 换行类型（跨平台一致）
allowMultiLineMethodChain = false              # 不强制多行方法链
multipleLineMethodChainLevel = 5               # 方法链层级达 5 时考虑多行
multipleLineMethodChainOverLineLength = true   # 超过行长度时自动多行
```

### 1.2 用法

```bash
# 格式化整个 src 目录（覆盖）
cjfmt -d src/ -c cangjie-format.toml

# 格式化单个文件
cjfmt -f src/richwidgets/switch.cj -c cangjie-format.toml

# 格式化到输出目录（不覆盖源文件）
cjfmt -d src/ -o ./formatted/ -c cangjie-format.toml
```

### 1.3 注意事项

- cjfmt **不支持宏代码**格式化（本项目 src/ 无宏，可安全格式化）
- 已有代码遵循格式化规范，新增 `.cj` 文件提交前建议跑一次 `cjfmt -d src/richwidgets/ -c cangjie-format.toml`
- **不建议批量格式化已有文件**：会产生大量无关 diff，影响 git blame。仅格式化新增/修改的文件

---

## 2. 静态检查（cjlint）

### 2.1 规则白名单

项目 `config/cjlint_rule_list.json` 配置了白名单规则集，**排除了项目结构/Qt 风格决定的误报规则**：

| 排除规则 | 排除原因 |
|----------|----------|
| `G.NAM.01` | 包名与目录路径匹配——项目结构 `src/<module>/` = `cjqt6.<module>`，cjlint 期望不同 |
| `G.NAM.05` | static let 全大写——枚举值用驼峰是 Qt 风格（如 `Horizontal`/`Vertical`） |
| `G.PKG.01` | import 通配符 `*`——项目大量使用 `import cjqt6.core.*`，风格选择 |
| `G.NAM.04` | 函数名小驼峰——枚举值/静态工厂被误判为函数名（如 `LocalHost`/`Any`） |
| `G.FUN.01` | 函数功能单一——桥接函数天然多功能，主观判断 |
| `G.OPR.01` | 运算符重载——`|` 位运算是 Alignment 合理设计 |

**保留的有价值规则**：`G.DCL.01`（变量遮盖）、`G.DCL.02`（public 显式类型）、`G.CON.01`（锁暴露）、`G.SEC.01`（安全方法）、`G.OTH.01/02`（敏感信息）等。

### 2.2 structural_rule 配置

部分规则需要 `structural_rule_*.json` 配置文件（从仓颉 SDK 复制到 `config/`）：

```bash
# 首次配置或 SDK 升级时执行
cp $CANGJIE_HOME/tools/config/structural_rule* config/
```

### 2.3 用法

```bash
# 检查 src 目录（-c . 表示 config/ 在当前目录下）
cjlint -f src/ -c .

# 输出 JSON 报告
cjlint -f src/ -c . -o cjlint-report -r json
```

当前结果：**白名单规则下 0 告警**（项目代码完全合规）。

---

## 3. 环境变量

| 变量 | 用途 | 设置位置 |
|------|------|----------|
| `CJQT6_ROOT` | 仓库根目录，供 `cjpm.toml` 的 `${CJQT6_ROOT}` 链接路径替换 | `setup-qt-env.ps1/.sh`、CI env、`verify_all.ps1` 等脚本自动注入 |
| `QTDIR` | Qt6 安装路径（如 `C:\Qt\6.10.3\msvc2022_64`） | `setup-qt-env.ps1/.sh` 自动探测或手动指定 `-QtDir` |
| `CANGJIE_HOME` | 仓颉 SDK 安装路径（cjpm/cjc/cjfmt/cjlint 所在） | CI 中解压 SDK 后设置；本机按安装位置 |

> **命名已统一**：全仓库脚本和 CI 均使用 `CJQT6_ROOT` + `QTDIR`，无变体。

---

## 4. CI 集成

`.github/workflows/ci.yml` 三端（Linux/Windows/macOS）均在「构建仓颉包」后加入 cjlint 步骤：

```yaml
      - name: 静态检查（cjlint）
        shell: bash   # Windows 用 pwsh
        run: |
          cjlint -f src/ -c .
```

- cjlint 退出码 0 表示通过（有告警也不阻断，当前 0 告警）
- `config/` 目录随仓库提交，CI 直接使用
- 格式化（cjfmt）未接入 CI：避免格式化 diff 噪音，由开发者本地运行

---

## 5. 本地一键检查

```bash
# 格式化新增代码
cjfmt -d src/richwidgets/ -c cangjie-format.toml

# 静态检查
cjlint -f src/ -c .

# 构建验证
cjpm build
```