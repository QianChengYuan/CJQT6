# CjMonitor 的 cjlint 配置

CjMonitor 是 `examples/` 下**独立可运行的 cjpm 工程**，因此有自己的 lint 配置：
规则集取自仓库根 `config/cjlint_rule_list.json`（同一套白名单，与封装库门禁口径一致），
仅**再去掉 2 条与本工程约束冲突的规则**。

## 门禁命令

```powershell
cd examples\CjMonitor
cjlint -f src/ -c .          # -c . ⇒ 读取本目录 config/cjlint_rule_list.json
```

## 相比仓库根白名单额外排除的规则

| 规则 | 告警数 | 排除原因 |
|------|--------|----------|
| `G.VAR.02` | 67 | 「变量尽量缩小作用域」对本工程的两类**必需**写法系统性误报：<br>① 自测参数常量（`M4_*` / `M5_*` / `PAINT_*` / `UI_SIZE_*` 等）刻意集中在文件顶部，便于一眼看全验收口径；<br>② FFI 回调用的顶层全局（`gProc*` / `gUi*` / `onM5*` 等）是 `CFunc` **不能捕获局部变量**这一硬约束的产物（见 `cjqt6-realtime` 技能 pitfalls 第 4 节），无法下沉到更小作用域 |
| `G.ITF.04` | 2 | 「避免直接用接口作参数/返回类型，改用泛型约束」——本工程采集器抽象 `Probe` 就是以接口注入 `AppState`、并由 `createPlatformProbe()` 按平台返回实现。改成泛型约束会把类型参数污染到 `AppState` 与全部调用点，属**为规则而劣化设计** |

其余 45 条规则保持启用，本工程当前**0 告警**。

## 与仓库根配置的同步

- `structural_rule_*.json` 是**仓库根 `config/` 的原样镜像**（`cjlint -c <dir>` 只认单一目录，
  不支持继承，缺这些文件会报 `open json file failed` 且退出码 254）。
- 根 `config/cjlint_rule_list.json` 或上述结构性配置变更时，本目录需同步（规则清单仅此 2 条差异）。
- `G.NAM.01`/`G.NAM.05`/`G.PKG.01`/`G.FUN.01` 等与 Qt 风格冲突的规则已在根白名单屏蔽，此处不重复说明。

## 当前结果（2026-09-19）

```
cjlint -f src/ -c .      →  0 告警，退出码 0
```

收敛过程：`G.DCL.02`（19 条 error，public 常量缺显式类型）、`G.EXP.07`（10 条，比较运算常量未置右）、
`G.NAM.02`（6 条，文件名未对应唯一对外类型）已按规则修复；`G.VAR.02`/`G.ITF.04` 见上表排除。
