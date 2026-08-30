# cjlint 项目级配置说明

本目录存放 CJQT6 项目专用的 `cjlint` 静态检查配置，用于屏蔽与 Qt6 封装库命名习惯冲突、以及封装库同质化守卫模式的规则。

## 使用方式

```powershell
# 项目根目录执行
.\scripts\run-lint.ps1                 # 检查整个 src
.\scripts\run-lint.ps1 -Summary        # 仅看分类统计
.\scripts\run-lint.ps1 -SourceDir src\widgets   # 仅检查某子包
```

脚本会调用 `cjlint -f src -c <项目根>` 指向本目录的 `cjlint_rule_list.json`，不污染全局配置。

## 已屏蔽规则及原因

下表 8 条规则因与 Qt6 API 命名习惯冲突或封装库同质化模式而屏蔽：

| 规则 | 告警数 | 屏蔽原因 |
|------|--------|----------|
| `G.NAM.01` | 182 | 仓颉多段包名 `cjqt6.views` 是合法且推荐的命名方式，cjlint 该规则只识别单段包名，属误报 |
| `G.NAM.03` | 1 | `ARGB32_Premultiplied` 等对齐 Qt 格式名，保持 API 一致 |
| `G.NAM.04` | 14 | Qt 静态工厂方法名 `LocalHost`/`Any`/`Broadcast`/`Null` 等对齐 Qt API |
| `G.NAM.05` | 500 | Qt 枚举值用 PascalCase（`Horizontal`/`NoEditTriggers`/`ConnectedState`），对齐 Qt 枚举风格 |
| `G.PKG.01` | 234 | 封装库通配符 `import cjqt6.core.*` 合理，避免大量逐个导入 |
| `G.FUN.01` | 35 | "函数功能单一"为主观判断，FFI 桥接封装函数常需多步操作 |
| `G.OPR.01` | 2 | 重载 `\|` 运算符对齐 Qt API（如 `Alignment \| Alignment`） |
| `G.ERR.01` | 364 | `throw` 未在 `///` 注释中描述异常类型。本库 throw 集中在 `checkValid()` 守卫（`ResourceDisposedException`）与 `init()` 创建失败（`CreateFailedException`）两处同质化模式，异常类型从代码一目了然，逐一补全 364 处 `/// throws:` 注释收益低，暂屏蔽 |

合计屏蔽 **1332 条**告警（即 `cjpm build -l` 原始全部告警）。

## 保留检查的规则

其余 49 条规则（含 `G.SEC.01` 安全、`G.CON.01` 并发、`G.CHK.01` 跨信任边界校验、`G.OTH.02` 禁硬编码敏感信息等）继续生效，暴露真实代码问题。

## 恢复某条规则

从 `cjlint_rule_list.json` 的 `RuleList` 数组中添加对应规则名即可重新启用；反之删除则屏蔽。

例如恢复 `G.ERR.01`（要求 throw 处补全异常注释）：

```json
{
  "RuleList": [
    ...
    "G.CON.02",
    "G.ERR.01",
    "G.ERR.02",
    ...
  ]
}
```

## 与 `cjpm build -l` 的关系

`cjpm build -l` 内部调用 `cjlint` 时使用**全局配置**（`<cangjie>/tools/config/cjlint_rule_list.json`），不支持指向项目内 config。因此：

- **项目 lint 统一用 `scripts/run-lint.ps1`**（本地与 CI 一致，可版本化）。
- `cjpm build -l` 仍会报全部 1332 条告警（因走全局配置），本项目不依赖它做 lint 门槛。

如需让本机 `cjpm build -l` 也干净，可同步把上述 8 条规则从全局 `cjlint_rule_list.json` 移除，但会影响该机器上所有仓颉项目。
