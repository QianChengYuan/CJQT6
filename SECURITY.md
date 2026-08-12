# 安全说明（SECURITY.md）

CJQT6 是仓颉（Cangjie）语言对 Qt6 的 FFI 封装库。本文件说明漏洞上报渠道、响应策略、已知安全风险与对使用者的安全建议。

## 支持的版本

当前仅维护最新稳定版本（见 `docs/CHANGELOG.md` 最新 tag）。安全修复会随下一个补丁版本（`x.y.z`）发布，不提供旧版本回溯维护。

## 报告安全漏洞

请**不要在公开渠道（GitCode Issues / QQ 群 / PR 评论）直接张贴漏洞细节**，优先走私有渠道：

- **GitCode Issues 私密模板**：仓库主页 → Issues → 新建 → 选择「安全漏洞上报」模板（模板字段：影响版本、复现步骤、预期/实际行为、建议修复方向）；GitCode 支持 Mark 私密，提交后你与维护者可见。
- **若需加密通信**：在私密 Issue 中联系维护者索要 PGP 公钥后再传敏感细节。

我们会：

1. **48 小时内**确认收到并初步评估影响面；
2. **7 天内**给出修复或缓解方案与时间表；
3. **修复发布后**再在 CHANGELOG 中公开描述（细节脱敏），同步在公开 Issue 中致谢上报者（若同意署名）。

## 已知风险声明

CJQT6 是 FFI 库，安全性很大程度上取决于**调用方是否遵守资源生命周期约定**：

| 风险 | 说明 | 缓解 |
|------|------|------|
| **CString 生命周期** | 字符串跨 FFI 需 `LibC.mallocCString` 分配、`LibC.free` 释放；返回的 `CString` 必须立即 `.toString()`，长期持有会导致悬垂指针或泄漏 | 库约定见 AGENTS.md「字符串过 FFI」；修复 `docs/resource/` 有内存管理指南 |
| **存活表竞态** | `trackObject`/`isObjectAlive`/`untrackObject` 在不同线程同时读写可能竞态；Qt 对象被级联销毁后 `ptr` 尚未置零 | `bridge_core.cpp` 已用互斥保护存活表；`isValid()` 三条件（`!closed && ptr != 0 && isObjectAlive(ptr)`）兜底 |
| **回调跨线程异常** | 仓颉异常穿透 C FFI 边界是未定义行为 | `bridge_signal.cpp` 38 处 `try{...}catch(...)` 已捕获，仅记日志不抛出 |
| **对象释放** | 终结器（`~init`）被刻意禁用，依赖 GC 会在 Qt 对象仍被使用时提前删除 | 必须显式 `close()`/`delete()`；见 SKILL 与 `docs/resource/` |
| **Qt 动态链接（LGPL）** | 通过动态库链接 Qt，未修改 Qt 源码 | 遵循 [LGPL v3](https://www.gnu.org/licenses/lgpl-3.0.html)；详见 `docs/LICENSE-ANALYSIS.md` |
| **ABI 敏感** | 不同 Qt 小版本 / MinGW 与 MSVC 之间符号可能不兼容（已踩 `qt_qFindChild_helper`、`valueChanged(QString)` 等坑） | 见 [Qt 版本兼容矩阵](docs/qt-version-matrix.md)，换版本必须跑全量测试 |

## 使用安全建议

- 只在你**信任的用户输入**范围构建字符串/路径后传入 FFI；不要将未受信输入直接作为动态执行内容。
- 多线程下操作同一 Qt 对象的持有/释放需加锁，或保持在 GUI 线程（`runOnUiThread`）。
- 将 CJQT6 置于沙箱内运行不受信任的 QML/脚本内容。
- 发布部署用 `windeployqt.exe` 或示例目录的 `deploy_qt.ps1`，确保 Qt 运行时 DLL 与主程序同目录，避免意外加载路径劫持。

## 依赖 HW 明细

- cjqt6_bridge（C++ 桥接库）仅依赖 Qt6 公共 API；不引入第三方二进制。
- 仓颉运行时（cjnative）由仓颉 SDK 提供，版本以 `cjpm.toml` 的 `cjc-version` 钉死。

## 联系维护者

- 项目主页：https://gitcode.com/yuan_1992/CJQT6
- 私密漏洞上报：https://gitcode.com/yuan_1992/CJQT6/issues（选「安全漏洞上报」模板）
- 社区交流：QQ 群 1023882445（仅讨论使用，不用于漏洞细节）