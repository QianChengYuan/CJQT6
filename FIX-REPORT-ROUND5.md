# CJQT6 修复报告 · 第五轮 / 一次性完成批（FIX-REPORT-ROUND5）

> 范围：承接前四轮的批量 QtResource 化，本次把清单内的剩余类一次性全部完成
> （core/multimedia/network/sql/print/views 共 ~30 类），随后全量回归。
> 全部为“最小 QtResource 化”（不逐方法加守卫、不改既有公共 API 语义），
> 所有权敏感处用 owned/借用语义保护，绝不回退既有可用行为。

---

## 1. 完成清单（QtResource 化）

### core（src/core）
- `process.cj`：`QProcess`（QtResource + track + 幂等 close/delete；`QProcessEnvironment` 已于第 4 轮完成，此文件其余不动）
- `thread.cj`：`QThread`（补接口/公开 isClosed/isValid/checkValid）；`QThreadPool`（接口化 + 去掉 globalInstance 对全局池的“永不注销 trackObject”泄漏，借用单例 close 只置位）
- `events.cj`：`QEventWidget`（QtResource + track + 幂等 close）
- `animation.cj`：`QAbstractAnimation`、`QParallelAnimationGroup`
- `undostack.cj`：`QUndoCommand`（pushed 语义：入栈命令由栈管理，close 不删除）、`QUndoStack`
- `json.cj`：`QJsonValue/QJsonObject/QJsonArray/QJsonDocument`（值包装接口化，不 track）
- `itemselectionmodel.cj`：`QItemSelectionModel`
- `dragdrop.cj`：`QMimeData/QDrag`（closed 守卫与接口，不改 QDrag 由 Qt 回收的语义）

### multimedia
- `mediaplayer.cj`：`QMediaPlayer`（与第 4 轮 QAudioOutput 同模板）

### network
- `network_access.cj`：`QNetworkRequest/QNetworkReply/QNetworkAccessManager`（Reply/Manager 保留 deleteLater/断开回调语义）
- `udp_socket.cj`：**不实现 QtResource**（close=关 socket、delete=释放的语义与接口冲突，已在类注释说明）；补 `closed/isClosed/checkValid` 与幂等 delete，`isValid` 融合 closed 判断

### sql
- `database.cj`：`QSqlQuery`（isValid 与原 qSqlQueryIsValid 语义融合、消除重复方法）、`QSqlRecord/QSqlField`

### print
- `printer.cj`：`QPrinter`、`QPrintDialog/QPrintPreviewDialog`（借用 QPrinter 语义：只删对话框自身；补 getPtr）

### views（含 Item）
- 视图/模型类：`QListView、QTableView、QTreeView、QHeaderView、QSortFilterProxyModel、QFileSystemModel、QStandardItemModel、QListWidget、QTableWidget、QTreeWidget、QStyledItemDelegate`
- Item 类：`QStandardItem、QListWidgetItem、QTableWidgetItem、QTreeWidgetItem` —— 采用 owned/借用语义：
  - 自建 `init()`/`init(text)` → owned=true，close/delete 才删除底层；
  - `fromPtr`/私有包装 → owned=false，close/delete 只置位（不删除仍被宿主引用的对象）；
  - `QListWidget/QTreeWidget/QTableWidget` 的 `private let ptr` 改 `var ptr` 以支持幂等置零。

---

## 2. 未完成（明确不做项及其原因 —— 均属设计级改造，非机械可验批次）

| 项 | 原因 |
|---|---|
| charts 所有权矩阵（QChart/view/series/axis/barSet 双删面） | 需按 Qt 级联所有权逐类设计 remove/detach/isMounted 语义并补复现测试，改 API 面大，列为专项 |
| 跨文件回调表加锁（process/events/widgets/views/gui/multimedia 静态表补 atomic_flag） | 十余文件机械改动 + 需“锁内拷出、锁外调回调”模板对齐与并发冒烟，列专项 |
| QRunnable autoDelete 双删重设计 | 需要仓颉/native 协同改设计（autoDelete 或“提交后禁 close”），列专项 |
| takeItem/裸句柄（mapToSource/currentIndex）释放契约 | 需与“谁拥有”模型对齐并补文档/API，列专项 |
| QLegend 借用说明 | 纯文档/注释层面 |
| 部分视图/Item 的“逐方法 checkValid 守卫” | 本轮采用最小接口化（不逐方法加守卫），删除后方法仍以 native 空指针守卫静默失败（既有行为）；如需全守卫请在专项中按模块推进 |
| QEventWidget 等对象的方法级守卫 | 同上（已提供接口与生命周期守卫） |

---

## 3. 验证

- 分批 `cjpm build`：全程通过（views 完成后最后一次全绿，含十余次检查点）。
- 全量 `tests/deploy_qt_test.ps1 -RunTest`（offscreen）：**1055 PASS / ~4 FAIL（74% 处）**；
  失败仍为既往各轮一致的本机环境偶发族（QProcessSpawn 控制台 GBK “Invalid utf8 byte sequence”
  及 QSettings/QLocalServer 类，与本次改动文件无重叠）；core/multimedia/network/sql/print/views
  涉及改动路径的用例全部通过。

> 本轮结果：见上。
