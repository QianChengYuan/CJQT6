# CJQT6 修复方案与第一轮修复报告（FIX-REPORT-ROUND1）

> 依据 `AUDIT-REPORT.md`（2026 独立静态审查）制定并实施的第一轮高优先级修复。
> 修复原则：只修“确定且改动可控”的缺陷；不改公共 API 语义；每类修复后经
> `cjpm build` + 桥接库重编 + 全量 `cjpm test` 验证；需要较大重构或行为再评估的
> 项列入“二期方案”（第 3 节），不在本轮冒进实施。

---

## 1. 本轮已实施的修复

### 1.1 仓颉封装层（Cangjie）

| # | 文件 | 修复内容 | 关联审查项 |
|---|---|---|---|
| F1 | `src/core/propertyanimation.cj` | `EasingCurve` 常量整体改按 Qt 官方 `QEasingCurve::Type`（补齐 OutInQuad/Quart/Quint/Expo/Circ/Back/OutInBounce 等全量 0..40），native `static_cast` 直传后曲线语义正确 | AUDIT 高：静默错误曲线 |
| F1t | `src/test/animation_test.cj` | 同步修正 `testEasingCurveConstants` 断言（旧断言把错误值固化，是缺陷能存活的原因） | 同上 |
| F1d | `docs/api/01_core.md` | 缓动常量文档同步官方取值 | 文档一致性 |
| F2 | `src/views/abstractitemmodel.cj` | `ItemDataRole.sizeHintRole()` 11 → 13（Qt 官方 SizeHintRole=13，11=AccessibleTextRole），并补 accessibleText/Description/InitialSortOrder | AUDIT 中：角色错值 |
| F3 | `src/core/widget.cj` | `QWidget.fromPtr/fromPtrOwned`：释放临时构造产生的原生 QWidget（先 untrack 再 delete 再换绑），消除每次调用泄漏 1 个原生控件 | AUDIT 高：fromPtr 泄漏 |
| F4 | `src/resource/scope_manager.cj` | `generateScopeId()` 由“固定返回 0 的时间戳”改为进程内自增计数器，作用域 ID 唯一（修复多作用域互删标记） | AUDIT 高：scopeId 恒 "scope_0" |
| F5 | `src/gui/layout.cj` | 8 处裸 `throw Exception(...)` 改为 `ResourceDisposedException`/`NullPointerException`（与 QtException 族、注释 throws 一致） | AUDIT 中：异常类型不一致 |
| F6 | `src/menu/menu.cj` | `QAction` 增加 `owned` 标志：`init(ptr)` 借用包装 close() 不再删除底层对象（只标记关闭）；owned 删除路径先 `qSignalCleanup` 再 `qActionDelete`（新增 local foreign 声明），修复二次释放/悬垂与信号表残留 | AUDIT 高：QAction 生命周期双缺陷 |
| F7 | `src/paint/transform.cj` | translate/scale/rotate/shear/inverted/multiply 六方法改经私有包装构造直接持有 FFI 返回指针，不再“先建临时 QTransform 再覆盖” → 每次调用不再泄漏原生对象 | AUDIT 高：QTransform 泄漏 |
| F8 | `src/paint/painter.cj` | 为 `QPainter` 补 `close()/delete()`（`owned` 时调 `qPainterDelete`；fromPtr 借用不释放），接入既有 native 导出，消除每次 `QPainter()`/`QPainter(device)` 的原生对象泄漏 | AUDIT 高：QPainter 无释放路径 |

### 1.2 native 桥接层（C++，已重编并部署 releases/windows-x64）

| # | 文件 | 修复内容 | 关联审查项 |
|---|---|---|---|
| N1 | `native/src/multimedia/bridge_videosink.cpp` | `qVideoSinkSubtitleText` 改返回 `cjqt6::dupUtf8/emptyString()`（std::malloc），不再返回临时 QByteArray 悬垂指针与字面量 `""` | AUDIT 高：FFI 返回悬垂 |
| N2 | `native/includes/bridge_string_utils.h` | 头注释同步实际约定（dupUtf8/emptyString + 仓颉 freeBridgeString→qCStringFree；禁止临时缓冲/字面量返回） | 文档误导 |
| N3 | `native/src/widgets/bridge_ext_wcore.cpp` | `qWcoreSignalCleanup` 扩清 QPushButton/QToolButton 的 7 张 ExtSlot 表（pressed/released/toggled/clickedChecked）；`qWcoreSignalRegistered` 同步扩展 | AUDIT 中：cleanup 漏 7 表 |
| N4 | `native/src/widgets/bridge_widgets.cpp` | 声明 `qWcoreSignalCleanup`；`qButtonDelete`/`qToolButtonDelete` 删除前调用，避免表条目残留/地址复用 | AUDIT 中：同上 |
| N5 | `native/src/network/bridge_network.cpp` | `qUdpSocketDelete` 补清 `g_udpReadyReadCbs/g_udpErrorCbs` 及连接句柄（与 disconnect-callbacks 语义一致） | AUDIT 低：UDP 漏清 |
| N6 | `native/src/core/bridge_core.cpp` | `qWidgetDelete` 删除前调用 `qSignalCleanup(ptr)`（内部兜底级联删除/漏调路径），修复统一信号表条目残留 | AUDIT 高：qSignalCleanup 零调用点 |
| N7 | `native/src/gui/bridge_menu.cpp` | `qActionDelete` 删除前调用 `qSignalCleanup(ptr)` | AUDIT 高：QAction 信号表残留 |

---

## 2. 验证

- `cjpm build`：通过（含全部仓颉改动，2 次）。
- 桥接库：`scripts/update-bridge.ps1`（Qt 6.10.3 MSVC 2022）重编通过并部署 `releases/windows-x64/cjqt6_bridge.dll/.lib`。
- 全量测试：`tests/deploy_qt_test.ps1 -RunTest`（offscreen）跑两轮：
  - 结果 ~1405 PASS / ~75 SKIP / 2-4 FAIL。
  - **失败用例在两轮间不固定**（QSettings.testRemove、QLocalServer.testListenAndClose、QProcessSpawn.testExecuteCommand 等），属本机环境偶发问题（QLocalServer/QSettings/进程 spawn 与 Windows 控制台/注册表相关；unittest worker 亦报 “Invalid utf8 byte sequence” 的控制台编码异常），与本次改动文件零重叠（见 git diff 清单：未触及 settings/localserver/process/splitter/print 相关代码）。
  - **本次改动覆盖路径全部通过**：animation_test（EasingCurve 常量断言已更新为官方值并通过）、menu/scope/layout/views 相关测试均通过。

---

## 3. 二期修复方案（本轮不实施，原因：需跨文件重构 / 行为再评估 / 需动态复现后再动）

| 优先级 | 项 | 内容与方案 | 暂不实施原因 |
|---|---|---|---|
| P0 | charts 所有权矩阵 | QChart/View/series/axis/barSet/slice 建立显式所有权矩阵：只允许“删 view（无 view 删 chart）”或先 remove/detach 再删子对象；提供 isMounted/remove 查询；Cangjie close 补 isObjectAlive 兜底 | 改 API 面大且需逐类设计 remove 语义；需先补复现测试（ScopeManager 同登记 view+chart 的崩溃用例） |
| P0 | 回调表加锁与注册替换 | 按 CallbackSpinLock 给 process/events/widgets/views/gui/multimedia 全部静态表补 atomic_flag；所有 SetOn/Connect 统一“句柄入表 + 先断旧连接” | 涉及十余文件大规模机械改动；锁粒度需与“锁内拷出、锁外调回调”模板对齐，需专门一轮 + 并发冒烟测试 |
| P0 | 批量 QtResource 化（约 40 旧式类） | QProcess/QThread/QRunnable/QThreadPool/QEventWidget/QUdpSocket/mediaplayer 三件套/datetime 四控件/dockwidget 五容器/plaintextedit 等补 QtResource 五方法 + track/checkValid/close 幂等 | 每类需按 QWidget 样板逐个改造并回归；一次全做风险高，宜按模块分批 |
| P1 | capture 闭包 close 级注销 | 类内记录注册 id / 建立 ptr→[id] 表，close 时统一 unregisterVoidCallback | 需梳理每类 connect 返回路径，防止重复注销 |
| P1 | datetime 值类 getter 泄漏 | QDate/QTime/QDateTime selectedDate() 等“先建后覆盖”模式改私有包装构造 | 同 QTransform 修复手法，但涉及值类 API 面广；需确认返回拷贝的 delete 义务文档 |
| P1 | takeItem/裸句柄泄漏 | views takeItem/mapToSource/currentIndex 返回 owned 包装或统一释放契约 | 涉及模型/视图所有权约定与文档；需与“谁拥有”设计对齐 |
| P2 | QSplitter.saveState 未初始化内存读取 | native 失败/截断标记 + 仓颉侧校验 actualLen | 需先确认调用方当前 buffer 语义（测试覆盖薄弱） |
| P2 | model 上 qWidget* UB | filesystemmodel/standarditemmodel 删除 show/resize/setStyleSheet 等 QWidget-only 方法 | 疑似复制残留；删除属 API 破坏，需先确认无调用方 |

---

## 4. 过程说明

- 全程只读之外仅改动上述源码/文档文件；未触碰公共 API 签名（EasingCurve 新增常量、QPainter 新增 close/delete、QTransform 行为不变，均向后兼容）。
- QAction 借用包装语义变化属缺陷修复（此前借用包装 close 会误删仍被引用的动作）。
- 建议后续把 AUDIT-REPORT.md + 本文件转成 GitCode Issues 逐条跟踪。
