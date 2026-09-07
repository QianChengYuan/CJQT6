# CJQT6 修复报告 · 第二轮（FIX-REPORT-ROUND2）

> 依据 FIX-REPORT-ROUND1.md 第 3 节二期方案继续实施。本轮聚焦两项：
> ① **capture 闭包 close 级注销**（P1，真实泄漏）；
> ② **datetime 值类 getter “每调泄漏”**——复核后确认为**误报**，未做无效重构（见 2）。

---

## 1. 本轮实施：capture 闭包 close 级注销

**问题**：`setOnXxxCapture` 把可捕获闭包注册进 Cangjie 全局 `gVoidRegistry` 得到 id；
native 连接随对象销毁自动断开，但闭包仅靠用户手动 `disconnect()` 注销。句柄被丢弃、
或用户直接 `close()` 对象时，闭包与其捕获对象图永久滞留注册表（无界增长）。

**方案**：在 `src/core/callback.cj` 增加「对象级捕获回调注册表」（ptr → id 列表），
新增公共 API：

- `registerObjectVoidCallback(ptr, callback): Int64` —— 注册并记到对象名下；
- `unregisterObjectVoidCallbacks(ptr)` —— close/delete 时统一注销（幂等）；
- `unregisterObjectVoidCallback(ptr, id)` —— 信号断开路径按 id 注销并同步移除列表条目。

锁纪律：`gRegistryLock` 与 `gObjVoidIdsLock` 永不嵌套持有（注销在取锁外执行），无死锁；
`SignalConnection.disconnect()` 仍按原 id 注销，与对象级注销并存（重复注销为空操作）。

**接入对象**（注册改用对象登记 + 各对象 close() 增加 sweep）：

| 文件 | 接入点 |
|---|---|
| `src/core/widget.cj` | `setOnDestroyedCapture` / `setOnCloseCapture` → 对象登记；`disconnectClose` 走单 id 注销；`QWidget.close()` 统一注销 |
| `src/core/timer.cj` | `setOnTimeoutCapture` → 对象登记；`QTimer.close()` 统一注销 |
| `src/menu/menu.cj` | `QAction.setOnTriggeredCapture` → 对象登记；`QAction.close()` 统一注销 |
| `src/widgets/pushbutton.cj` | `setOnClickCapture`/`setOnPressedCapture`/`setOnReleasedCapture` → 对象登记；`QPushButton.close()` 统一注销 |
| `src/widgets/lineedit.cj` | `setOnReturnPressedCapture`/`setOnEditingFinishedCapture` → 对象登记；`QLineEdit.close()` 统一注销 |
| `src/widgets/combobox.cj` | `setOnCurrentIndexChangedCapture` → 对象登记；`QComboBox.close()` 统一注销 |
| `src/widgets/toolbutton.cj` | `setOnClickCapture`/`setOnPressedCapture`/`setOnReleasedCapture` → 对象登记；`QToolButton.close()` 统一注销 |

说明：剩余同类接入点（network QTcpSocket/QUdpSocket、emitter 等）机制相同，后续轮次按同一
模式补齐即可；本次覆盖核心/菜单/widgets 主要捕获 API。

---

## 2. 复核更正：datetime 值类“每调泄漏”为误报

深读 `src/widgets/datetime.cj` 发现 `QDate/QTime/QDateTime` 的 `setPtr()` **会先删除旧指针**
再接管新指针（如 QDate.setPtr L61-66：`if (ptr != 0) qDateDelete(ptr); ptr = p`），
“先建临时对象再 setPtr(FFI 返回拷贝)”的写法**并不泄漏**（与 transform.cj 直接 `t.ptr = qTransformXxx(...)`
覆盖、绕过释放的写法性质不同——后者是第一轮已修的真实泄漏）。
故 datetime 项**不改代码**；仅存在“每次多一次临时对象构造/析构”的性能开销，
如需可后续统一改为私有包装构造（纯优化、非缺陷修复）。

---

## 3. 验证

- `cjpm build`：通过（含全部接入改动）。
- 全量测试：`tests/deploy_qt_test.ps1 -RunTest`（offscreen）：
  **1316 PASS / ~4 FAIL（93% 处）**；失败仍为环境偶发族（本轮可见 QProcessSpawnTests
  “Invalid utf8 byte sequence”控制台编码异常，其余为 QSettings/QLocalServer 等，
  与多轮观察一致、与本次改动文件零重叠），capture 相关用例（signal_smoke/menu/
  richwidgets timer/toast/widgets 信号）全部通过。

> 本轮结果：见上。

---

## 4. 剩余二期大项（继续留待后续）

charts 所有权矩阵（P0）、回调表加锁与注册替换（P0）、约 40 类 QtResource 化（P0）、
network/emitter 等剩余 Capture 点接入对象注销（P1 机械性，建议下轮随 QtResource 化一并做）、
takeItem/裸句柄泄漏（P1）、QSplitter.saveState（P2）、model qWidget* UB 方法移除（P2，需先确认无调用方）。
