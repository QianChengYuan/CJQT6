# CJQT6 独立静态审查报告（AUDIT-REPORT）

> **审查对象**：CJQT6 v1.9.0（仓颉 Qt6 封装库，仓库根 C:\CodeTools\cangjie_git\CJQT6）
> **审查方式**：独立静态代码审查（不依赖 DEFECTS.md 既有结论），未修改任何源代码；仓颉封装层与 C++ 桥接层逐模块审查 + 跨模块交叉核查 + 关键发现逐条回源复核。
> **基准范式**（源自 SKILL.md/AGENTS.md 与 `src/core/resource.cj`、`src/core/widget.cj`）：
> - 每个 Qt 对象封装为实现 `QtResource`（isClosed/close/getPtr/isValid/checkValid）的 class；
> - 创建检查 `ptr==0` 并抛 `CreateFailedException`，创建后 `trackObject(ptr)`；close 幂等、先 `untrackObject` 再 `qSignalCleanup` 后删除、置 `ptr=0/closed=true`；
> - 所有方法入口 `checkValid()`（含 `isObjectAlive` 反向失效兜底）；
> - `~init` 终结器注释禁用；异常统一 QtException 族；FFI 全包 `unsafe{}`；CString 入参 malloc→call→free、返回值立即 `.toString()`+`freeBridgeString`。

---

## 1. 执行摘要

按严重度分级（全部经回源复核，动态可复现项另行标注）：**高约 20 / 中约 45 / 低约 25**（仓颉层与桥接层合并计数，近似值；高频缺陷族以"同型多类"计 1 条核心 + 列出受影响类）。

**最有价值的三类共性结论**：
1. **“QtResource 全覆盖”未达成，范式分层明显**：新范式类（widget 系、menu 六类、dialogs 四实例类、sql 的 QSqlTableModel、multimedia 的 camera 系、qml 引擎/视图/组件）严格符合基准；而一批旧类（core 的 QProcess/QProcessEnvironment/QThread/QRunnable/QThreadPool/QEventWidget/QJson×4/QItemSelectionModel/QUndoStack/QAbstractAnimation、application.cj 的 QApplication/QLocale、gui 全部布局/光标/画板/字体包装、multimedia 的 QMediaPlayer/QAudioOutput/QSoundEffect、network 的 QUdpSocket/QNetworkRequest/QNetworkReply/QNetworkAccessManager、sql 的 QSqlQuery/QSqlRecord/QSqlField、print 三件套、charts 的 QLegend 等）缺接口/守卫/track，或仅有私有 checkValid。后果：try-with-resources、ScopeManager、ResourceContainer 无法统一接管；部分 delete() 后方法以 `ptr=0` 静默穿透 FFI。
2. **`isObjectAlive` 反向失效兜底不普及**：widget/views/qml 引擎类齐全；charts 全 25 类、mediaplayer 系、QSqlDatabase、qml 借用包装（fromPtr 不 track）、menu 的 addMenu/addAction 借用包装等缺失或形同虚设。级联销毁（父 close → 子 native 析构）后再操作旧句柄 = UAF 或 double-free 的最高危路径。
3. **Capture 闭包注册表只在手动 disconnect 时注销**：`SignalConnection.disconnect()` 路径闭合，但大量类把 id 返回给调用方或直接丢弃，close() 不清 Cangjie 侧 `gVoidRegistry`（`callback.cj`），只清 native 侧连接 → 闭包与捕获对象图滞留（慢泄漏），网络/菜单/媒体高频创建对象时无界增长。

**合规亮点（已核实，非缺陷）**：全库无激活 `~init`；CString 入参与返回在全部审查文件中配对正确；CMakeLists 与 native 源码 0 孤儿 0 缺失；native 字符串统一 `dupUtf8/emptyString + qCStringFree` 同堆（有 ASAN 原生测试）；`Layout/Alignment` 等常量对照 Qt 6.10.3 头文件无误。

---

## 2. 审查发现（按模块）

### 2.1 src/core（核心模块）

| 级别 | 位置 | 问题 | 证据 |
|---|---|---|---|
| 高 | propertyanimation.cj:22-52 + bridge_core.cpp:1488-1490 | `EasingCurve` 常量整体错值：Qt 官方 InCubic=5/InSine=17/InElastic=29…，库内写紧凑编号 InCubic=4/InSine=7/InElastic=14/InBounce=17，native `static_cast<QEasingCurve::Type>(curveType)` 直传 → 除 Linear..InOutQuad(0-3) 外全部静默映射到错误曲线 | `public static let InCubic: Int32 = 4`（官方 4=OutInQuad）；bridge L1490 直转 |
| 高 | thread.cj:59-90 + bridge_thread.cpp:51-75 | QRunnable：native 构造即 `setAutoDelete(true)`，`pool->start` 跑完 Qt 自动 delete；仓颉 close() 仍 `qRunnableDelete(ptr)` → 提交后关闭 = double-free/UAF；类也未 track | thread.cj:83-89 close 直接 qRunnableDelete；bridge_thread.cpp:54 setAutoDelete(true)、L74 `delete runnable` |
| 高 | widget.cj:50-67 | `fromPtr/fromPtrOwned` 先 `QWidget()` 真实 new 原生控件并 track，随后 `untrackObject(w.ptr)` 只注销不 delete → 每次调用泄漏 1 个原生 QWidget（findChild/QUiLoader 高频触发）；qml/views 已改用"私有无参构造+工厂"规避（qml.cj:1066/1226） | widget.cj:52 `untrackObject(w.ptr)` 后换绑；bridge_core.cpp:780-783 new QWidget() |
| 高/中 | process.cj:60-126、132-333 | QProcess/QProcessEnvironment 非 QtResource：无守卫/checkValid/track，init 不查 ptr==0；system() 先 new 临时对象再 delete 再建实例（多余构造析构，67-74）；delete 后方法以 ptr=0 静默调 native（多数被 native `if(env)` 守卫吞掉） | process.cj:67-74、135-144 |
| 高/中 | thread.cj:96-252、258-314 | QThread 未实现 QtResource（checkValid private、无 isClosed/isValid、无 delete 别名）；QThreadPool.globalInstance() 每次对同一全局指针重复 trackObject 且永不 untrack | thread.cj:96、269 |
| 高/中 | widget.cj:441-447 | `setOnDestroyedCapture` 注册闭包返回 Unit，id 丢弃；close() 只清 native，Cangjie `gVoidRegistry` 条目永久残留（捕获对象图被保活） | widget.cj:443 `let id = registerVoidCallback(callback)`；close L219-237 无 unregister |
| 中 | signal.cj:339-358 | `SignalConnection.disconnect()` 兜底 `else { qSignalCleanup(ptr) }` 会一次清空该对象全部信号，误伤同对象其他有效连接 | signal.cj:356-358 |
| 中 | json.cj:286-297、250-254 | QJsonDocument 解析失败 native 返回 0 → checkValid 伪报 "already deleted"（抛 ResourceDisposedException），连 isNull() 都不可查；QJsonArray.at 越界返回 0 同理 | bridge_json.cpp:17-24 |
| 中 | events.cj:219-374 | QEventWidget 非 QtResource：init 不查失败，delete() 后 show/setTitle/setOnXxx 等全部无 checkValid 直接 ptr=0 调 FFI（native 判空静默失效）；类同时持 id 与 ptr（ptr 正确，无 id/ptr 混用） | events.cj:223-246、262-268 |
| 中 | undostack.cj:38-106、112-264 | QUndoCommand/QUndoStack 非 QtResource；push 后栈 clear/上限删除底层对象后 wrapper.text()/setText() 无 pushed 守卫 → UAF（delete() 有 `!pushed` 守卫而 text() 无） | undostack.cj:77-85 vs 99-105 |
| 中 | timer.cj:62-69、emitter.cj:76-86 | capture 闭包仅在用户持有 SignalConnection 并 disconnect 时注销；忽略句柄/直接 close 对象 → 闭包滞留 | timer.cj:64-68；close 116-132 无注销 |
| 中 | dragdrop.cj:281-296、77-197 | QDrag/QMimeData 无释放路径（native qDragDelete 为 no-op，bridge_dragdrop.cpp:215-220）；QMimeData 无 checkValid/closed/track 却为 QObject | dragdrop.cj:281-287 |
| 中/低 | json×4/itemselectionmodel.cj/animation.cj | 只实现私有 checkValid+close，未 `<: QtResource`（缺 public isClosed/isValid）；QParallelAnimationGroup.close() 未先 stop 子动画 | itemselectionmodel.cj:53-65 |
| 低 | application.cj:69-167、200-267 | QApplication/QLocale 非 QtResource；QLocale close 后 name() 等无守卫静默返回 ""（类注释称需显式 close 却无 delete 别名） | application.cj:200-207 |
| 低 | shortcut.cj:14-102 | QShortcut 无 activated 信号连接方法（native 亦无 qShortcutConnect），setKey 后无法触发回调，类注释"结合信号系统"落空 | shortcut.cj:7-11 |
| 低 | uiposter.cj:34-42 | 投递后目标线程事件循环若已退出，闭包永不执行也永不注销（注册表残留一条；正常路径自注销无泄漏） | uiposter.cj:36-39 |

### 2.2 src/gui（布局/图形支撑类）

| 级别 | 位置 | 问题 | 证据 |
|---|---|---|---|
| 高/中 | syntaxhighlighter.cj:48 + bridge_syntax.cpp:55-67 | `setFormat` 颜色三方语义错配：测试传 `color.getPtr()`（QColor 堆指针），native 按 `color&0xFF / >>8 / >>16` 拆 RGB → 颜色=指针低字节垃圾值（高亮错色、静默） | 测试 gui_extra_test.cj:576-577；bridge_syntax.cpp:60-62 |
| 高/中 | layout.cj:69/180/291/435、cursor.cj:75、palette.cj:15、icon.cj:13、font.cj、textdoc.cj、syntaxhighlighter.cj:17 | gui 全部 Qt 包装类未 `<: QtResource`（多继承 QLayout 的也只有 getPtr/delete），checkValid 多为 private、isClosed/isValid 缺失 → 无法进统一资源管理 | layout.cj:69 `class QVBoxLayout <: QLayout`（QLayout 链上无 QtResource） |
| 中 | layout.cj:145/148（同 256/259/353/356/566/569） | checkValid 抛裸 `Exception` 而非 QtException 族（注释却声明 ResourceDisposedException） | layout.cj:145 `throw Exception("QVBoxLayout 已经被释放")` |
| 中 | layout.cj:123-128（同 234-239/331-336/511-516） | `setMargins(Margins)` 只取 `margins.left` 调 qXxxLayoutSetMargin，top/right/bottom 静默丢弃，与"四方向边距"注释相悖 | layout.cj:126 |
| 中 | layout.cj:73-78 等、cursor.cj:87-94、palette.cj:23、icon.cj:25-36、font.cj:46-48 | init 不查 ptr==0、不抛 CreateFailedException（布局还 `trackObject(0)`）；同模块 QTextDocument/QSyntaxHighlighter 却检查 → 不一致 | layout.cj:75-77 |
| 中 | style.cj:123-134 | standardIcon/widgetStandardIcon 每次 new QIcon 只回裸 Int64、无释放入口（bridge_style.cpp:45-46）→ 每次调用泄漏 | style.cj:123-134 |
| 低 | layout.cj:155-170 | 布局 close() 无 owned 标志（未建模 setLayout/addLayout 属主转移），极端边界可能双删 | layout.cj:155-170 |
| 低 | textdoc.cj:231-355 | QTextCursor init 未 track、checkValid 无 isObjectAlive，doc 先 close 后 cursor 操作不可检测 | textdoc.cj:236-240 |
| 低 | style.cj:13 | `qStyleLayoutSpacing` 死声明从未调用 | style.cj:13 |

### 2.3 src/dialogs 与 src/menu

| 级别 | 位置 | 问题 | 证据 |
|---|---|---|---|
| 高/中 | menu.cj:239-254 | QAction.close() 缺 `qSignalCleanup(ptr)`（范式 widget.cj:229）；native 删除只清本地 g_actionCallbacks（死路径），统一注册表 g_conns/g_voidIds 中 {ptr,SIG_TRIGGERED} 条目残留 → 慢泄漏 + 指针复用竞态窗口（Qt 会自动断开已毁对象连接，故非直接误派发） | menu.cj:247-250；bridge_menu.cpp:216-222 |
| 高/中 | menu.cj:94-102、239-254 | `QAction(ptr)` 借用包装（注释"不获取所有权"）无 owned 标志、close 无条件 qActionDelete；借用包装又未 trackObject → 原对象被属主删除后 close 仍 delete 悬垂指针 | menu.cj:96-102（无 owned/track）、L249 qActionDelete |
| 中 | menu.cj:196-203 | setOnTriggeredCapture 闭包 id 无对象级注销（返回的 SignalConnection 未保存） | menu.cj:198 |
| 中 | menu.cj:220-236/357-373 | addMenu/addAction 返回的借用包装不 trackObject → 父对象级联析构后 isObjectAlive 保护失效（主使用路径在生命周期保护之外） | menu.cj:289-296（包装 init 无 track） |
| 低 | menu.cj:205-210、12 | disconnect() 只断 CFunc 版；qWidgetDelete foreign 死声明 | menu.cj:12 |
| 低 | dialogs.cj:557-572/665-680/847-862/948-963 | 4 个实例类（QProgressDialog/QWizard/QWizardPage/QErrorMessage）close 缺 qSignalCleanup（当前无信号注册故无实际泄漏，防未来风险） | dialogs.cj:565-568 |
| 低 | dialogs.cj:15（等 6 处） | 注释"桥接层返回 malloc 内存，调用方需 LibC.free"与代码实际 freeBridgeString 不符（误导，直接 LibC.free 会 UCRT 堆损坏） | dialogs.cj:15 vs L94 |
| 低 | dialogs.cj:286-301、341-348 | parseSize 容错过宽（"12x5"→125）；QFontDialog 用 split(",") 解析，字体族名含逗号错位 | dialogs.cj:296-297 |

### 2.4 src/widgets / src/views / src/paint
（子代理全量逐行报告已核收，下为分级精选；FFI/字符串约定三模块整体无缺陷——unsafe、malloc→call→free、toString+freeBridgeString 全部配对）

**src/paint（偏离范式最彻底：0 个 QtResource / 0 次 track）**

| 级别 | 位置 | 问题 | 证据 |
|---|---|---|---|
| 高 | painter.cj:696-792 + bridge_painter.cpp:376 | QPainter **无任何释放路径**：native 已导出 qPainterDelete 但仓颉从未声明/调用（`owned` 字段 L698 声明后从未读取）→ 每次 `QPainter()`/`QPainter(device)` 泄漏原生 QPainter | painter.cj:700-702；bridge_painter.cpp:376 |
| 高 | transform.cj:46-70 | translate/scale/rotate/shear/inverted/multiply 每次调用先 `QTransform()`（内部 `new QTransform`）再覆盖 `t.ptr = qTransformTranslate(...)`（native 又 new 返回）→ 临时原生对象被覆盖泄漏 | transform.cj:47-48；bridge_painter.cpp:1157-1165 |
| 中/低 | painter.cj:7/51-56（QColor）、transform.cj:29 等 12 个持指针类 | 全部未实现 QtResource/closed/checkValid/track；painter.cj:61-62 注释自称"需实现 Resource 接口"而类实际未实现，误导；QColor/QFont/QPixmap/QImage 构造/load/fromName 不查 ptr==0 | painter.cj:51-56、61-62 |
| 低 | painter.cj:696-712 + bridge_painter.cpp:358 | QPainter(device)/qPainterCreate 用 `reinterpret_cast<QPaintDevice*>` 直转：仅 QPixmap/QImage（首基类）偏移正确，若传 QWidget*（QObject 在前）作画布则错位 UB（示例未用，潜在陷阱） | bridge_painter.cpp:358 |

**src/views（17 个持 ptr 类 0 个实现 QtResource，仅 3 个 track）**

| 级别 | 位置 | 问题 | 证据 |
|---|---|---|---|
| 高 | filesystemmodel.cj:52-85、standarditemmodel.cj:102-135 | **model 类（QAbstractItemModel 系非 QWidget）暴露 QWidget FFI**：qWidgetShow/qWidgetResize/qWidgetSetStyleSheet 以 QWidget* 强转调用 → 跨类 UB（疑似从 widget 封装复制残留） | filesystemmodel.cj:55/69/83 |
| 高 | listwidget.cj:92/104-110、treewidget.cj:265/277-283 | QListWidget/QTreeWidget delete() 不幂等（`private let ptr` 不可置 0、无 closed/isObjectAlive 兜底）→ 二次 delete/父级联后再 delete = double-free；7-8 个 setOn 无守卫 | listwidget.cj:104-110 |
| 高 | treewidget.cj:88-259 | QTreeWidgetItem public init() 创建后无任何 delete/owned 手段，从不挂载即永久泄漏 | treewidget.cj:88 |
| 中 | abstractitemmodel.cj:43 | `sizeHintRole()` 返回 11，Qt 官方 **SizeHintRole=13**（11=AccessibleTextRole）→ 数据角色静默错误 | abstractitemmodel.cj:43 |
| 中 | sortfilterproxymodel.cj:187-200、tableview.cj:312-317、standarditemmodel.cj:327-332 | mapToSource/currentIndex/rootIndex 等返回裸句柄且无释放约定（native 每调 new QPersistentModelIndex）→ 调用即泄漏 | sortfilterproxymodel.cj:187-192 |
| 中 | listwidget.cj:321-325、tablewidget.cj:392-396 | takeItem() 返回 fromPtr 借用包装而 native 只 take 不删 → 取出即泄漏且无法合规释放（treewidget 桥接自动 delete，语义不一致） | listwidget.cj:321-325 |
| 中 | tableview.cj:263-268/headerview.cj:385-393、standarditemmodel.cj:268-273/455-462 | header↔view、item↔model 所有权转移后包装仍可 delete（无 owned 标志）→ 二次释放 | headerview.cj:385-393 |
| 中 | 全模块 | 12 持 ptr 类仅 3 个 trackObject（listview.cj:77、abstractitemmodel.cj:86、styleditemdelegate.cj:121），级联析构后 delete 无 alive 兜底；close/delete 命名分裂 | 全模块 grep |

**src/widgets（约 60 个持 ptr 类仅约 21 个实现 QtResource；约 3/4 为 delete()-only 旧式封装）**

| 级别 | 位置 | 问题 | 证据 |
|---|---|---|---|
| 高 | datetime.cj:282/405/500/588 | QCalendarWidget/QDateEdit/QTimeEdit/QDateTimeEdit（QWidget 派生）完全无 QtResource/close/track，仅裸 delete；10 处 setOn 无仓颉侧清理出口；父级联删除后仓颉无感知 → 悬垂/双删 | datetime.cj:285、393-398 |
| 高 | datetime.cj:12-24/80-91/289-296 等 | QDate/QTime/QDateTime 值类及 selectedDate() 等 getter 采用"先建后覆盖"（QDate() 再 setPtr(返回拷贝)）→ 每调泄漏临时原生对象；返回拷贝需 delete 但无文档 | datetime.cj:20-23；bridge_datetime.cpp:174-178 |
| 高 | graphicsitem.cj:214-216 + graphicsview.cj:395-414/497-513 | item 与 scene 双向 double-free：scene addItem 后场景拥有 item（scene 析构/clear 连带删），wrapper 再 close() = 二次 delete；item 非 QObject 无法 track | graphicsitem.cj:214-216 |
| 高 | plaintextedit.cj:46-56、textbrowser.cj:32-42、keysequenceedit.cj:15-22 | 三控件无 QtResource/守卫/存活跟踪（经 layout.addWidget 后属主为父），删除顺序错误即 double-free；keysequenceedit 注册信号后无断开/清理 API | plaintextedit.cj:46-56 |
| 高 | dockwidget.cj:42-54、systemtrayicon.cj:28-35、mdiarea.cj:44-54、stackedwidget.cj:22-32、toolbox.cj:25-35 | 接受 parent 的五类控件均无 QtResource/track/checkValid；带父构造 delete 无 isObjectAlive 兜底 → 父先析构再 delete 即双删 | dockwidget.cj:42-54 |
| 高 | commandlinkbutton.cj:20-30、fontcombobox.cj:40-45 | 同型：无 QtResource、全文无 throw、带父构造 delete 无存活兜底 | commandlinkbutton.cj:20-30 |
| 中 | mdiarea.cj:74-78/241-248 | QMdiSubWindow 双重所有权：addSubWindow 后归 QMdiArea 管理，delete() 不先 removeSubWindow → mdiArea 子窗口列表悬垂 | mdiarea.cj:241-248 |
| 中 | graphiceffect.cj:26-58/61-127 | QGraphicsOpacityEffect 等安装（setGraphicsEffect）后所有权转归 widget，widget 析构连带删除特效时 wrapper.delete() → 二次删除 | graphiceffect.cj:52-57 |
| 中 | slider.cj:56-58/319-331 | setOnSliderPressed/Released 声明 Int64Callback，但 Qt 信号无参（native bridge_values.cpp:270/284 回传控件指针本身），语义混搭无文档 | slider.cj:319-331 |
| 中 | containers.cj:1198-1221 | QSplitter.createHorizontal/Vertical 走 private init(ptr,_) 不 track/不查 ptr==0，close() 对未注册对象 untrackObject → 语义不一致 | containers.cj:1198-1221 |
| 中 | containers.cj:1340-1351 + bridge_containers.cpp:463-473 | QSplitter.saveState() 固定 4096 缓冲，超长时 native 静默不写不更新 → 未初始化堆内存被当结果返回 | bridge_containers.cpp:468-471 |
| 中 | checkbox.cj:162-165/radiobutton.cj:139-142/spinbox.cj:357-360/combobox.cj:485-490/slider.cj:312-316/lineedit.cj:297-302 | disconnect()/disconnectAll 覆盖远小于注册面（部分注释"断开全部"却漏多个信号） | combobox.cj:485-490 |
| 低 | 多文件 | 约 30 类 init 缺 ptr==0→CreateFailedException（textedit.cj:119-124 等，多数还会 trackObject(0)）；buttongroup 为 widgets 中唯一 close/delete 无信号清理类（native qButtonGroupDelete→qWmiscSignalCleanup 兜底，仓颉侧无清理出口）；graphicsitem/老式控件 delete 后方法仍可无守卫直穿 FFI | textedit.cj:119-124 |

### 2.5 src/multimedia / src/network / src/sql / src/qml / src/print
（子代理报告已核收，重点条目）

| 级别 | 位置 | 问题 | 证据 |
|---|---|---|---|
| 高 | mediaplayer.cj:68/102、soundeffect.cj:35 | QAudioOutput/QMediaPlayer/QSoundEffect 未实现 QtResource：无 closed/checkValid、方法无守卫、创建不查 ptr==0、不 trackObject（同模块 camera/videowidget 已合规 → 范式分裂） | mediaplayer.cj:68-98 |
| 高 | imagecapture.cj:59-62 | init 缺判空、`trackObject(ptr)` 先于 ptr==0 检查（native qTrackObject 对 0 直接 return，实际后果是后续方法抛"已删除"而非 CreateFailed） | imagecapture.cj:59-62 vs camera.cj:109-115 |
| 中 | tcp_socket.cj:354-396、tcp_server.cj:176-184 | Capture 闭包注册返回裸 id，close()/disconnectCallbacks() 从不 unregisterVoidCallback → 每个 socket 永久残留闭包（高频短连接内存无限增长） | tcp_socket.cj:353-357、429-446 |
| 中 | bridge_network.cpp:1109-1173 | id 版连接重复注册不替换旧 QMetaObject::Connection（CFunc 版 365-387 已做替换式）→ 一次信号重复派发 + 旧闭包残留 | bridge_network.cpp readyRead connect |
| 中 | udp_socket.cj:75-79 vs 221-235 | close() 语义是"关底层 socket"（不 untrack 不释放），真正释放是 delete()；类非 QtResource、方法无守卫 | udp_socket.cj:75-79 |
| 中 | network_access.cj:61/154/287 | QNetworkRequest/QNetworkReply/QNetworkAccessManager 有 close 但未 `<: QtResource`（无 isClosed/isValid）→ 无法进 ScopeManager | network_access.cj:61 |
| 中 | database.cj:240-393（QSqlQuery）、398-492（QSqlRecord）、497-561（QSqlField） | 半 QtResource：无接口（缺 isClosed/isValid）、QSqlQuery 无 closed/checkValid，delete() 后方法以 ptr=0 静默返回 false（native 有 if(query) 守卫）而非抛异常 | database.cj:251-258 |
| 中 | database.cj:222-231 | QSqlDatabase.close() 无 isObjectAlive/untrack；removeDatabase 后旧包装操作悬垂无警示（QSqlDatabase 非 QObject，本不适用 destroyed 机制，但异常语义缺失） | database.cj:222-231 |
| 低 | database.cj:86-107 | addDatabase/database 静态工厂不查返回 0（native bridge_sql.cpp:22-29 无效驱动确实返回 0）→ 后续抛 NullPointer 而非 CreateFailed | database.cj:86-96 |
| 高/中 | qml.cj:1240-1245、1069-1074 | QQuickItem/QQmlContext.fromPtr 借用包装不 trackObject，而 checkValid 调 isObjectAlive → 未注册恒 true，引擎/视图 close 级联删根对象后借用包装方法调用 = 真 UAF（守卫形同虚设） | qml.cj:1260-1270 vs 1240-1245 |
| 中 | qml.cj:1273-1291 | owned 子项 setParentItem 挂父后被父先删，close 仍 qQuickItemDelete → 双释放（无 isObjectAlive 二段兜底） | qml.cj:1273-1289 |
| 中 | printer.cj:92-315 | QPrinter/QPrintDialog/QPrintPreviewDialog 非 QtResource；对话框持 QPrinter 指针无失效守卫，先 delete 打印机再 exec 对话框 → native 悬垂 | printer.cj:268-315 |
| 低 | qml.cj:130 | qQuickItemFreeString 死代码（实际用 freeBridgeString） | qml.cj:130 |

### 2.6 src/resource / src/charts / src/richwidgets

| 级别 | 位置 | 问题 | 证据 |
|---|---|---|---|
| 高 | scope_manager.cj:307-318 | `generateScopeId()` 依赖 `currentTimeMillis()`（固定返回 0）→ 所有 ScopeManager scopeId 恒为 "scope_0"；多作用域并存时 Registry.unregisterScope 互删对方标记（"防重复管理"失效） | scope_manager.cj:316-318 |
| 中 | scope_registry.cj:21/76-88、scope_manager.cj:33 | HashMap 以 Int64(ptr) 为键未 `& 0x3FFFFFFF`（AGENTS 硬约束）；指针高位对齐哈希分布差 | scope_registry.cj:21 |
| 中 | scope_manager.cj:243-254 | close() 在 config.autoRelease=false 时不清理注册表（不 unregisterScope/清 mark）→ 控件永远标记为已管理，其他作用域无法接管 | scope_manager.cj:243-254 |
| 中 | chart.cj:252-259（chartview/lineseries 等 25 类同型） | close()/checkValid() 全模块无 isObjectAlive：view 级联删 chart/series 后，旧包装方法调用=UAF、close=双释放（ScopeManager 同登记 view+chart 即复现） | chart.cj:252-259 |
| 中 | legend.cj:56-180 | QLegend 非拥有包装无 close/未 track，chart 删除后图例包装无失效提示 | legend.cj:56 |
| 低 | toast.cj:41-51 | 在 QTimer::timeout 派发栈内直接 close 发信对象（非 deleteLater），Qt 边缘 UB | toast.cj:41-51 |
| — | richwidgets 其余 19 文件 | 委托式 QtResource（内部叶子控件承担所有权），范式干净，通过 | avatar.cj:67-81 |

### 2.7 native C++ 桥接层（native/src，56 个 .cpp 全量报告已核收；行号均经回源复核）

| 级别 | 位置 | 问题 | 证据 |
|---|---|---|---|
| 高 | bridge_chart.cpp 全套 | charts **所有权矩阵双删**：Qt 语义中 ~QChart 级联删 series/axis、QChartView::setChart 转移所有权、removeAllSeries 即删、createDefaultAxes 先删旧轴；桥接仍暴露全套子对象独立 delete（qLineSeriesDelete:132、qValueAxisDelete:159、qBarSetDelete:394、qPieSliceDelete:982 等）且无 remove/detach/isMounted 防护 → add/append/挂 view 后再单独 delete 子对象 = 双删/悬垂 | bridge_chart.cpp:58-60、118-122 + 文件头注释 8-12 |
| 高 | bridge_signal.cpp:965 + bridge_core.cpp:840-845 | `qSignalCleanup` 在 native **零调用点**；qWidgetDelete（最常见的级联删除入口）与各 qXxxDelete 不清统一信号表 g_conns/g_voidIds → 依赖仓颉 wrapper close() 先行调用（契约脆弱：任何级联删除/漏调路径都让 std::function+连接句柄条目永久驻留） | bridge_signal.cpp:965-984；bridge_core.cpp:840-845 |
| 高 | bridge_videosink.cpp:67-75 | **FFI 返回悬垂指针**：`tmp.toUtf8().constData()` 的临时 QByteArray 在 return 结束即析构；null 分支返回字面量 `""`，若仓颉 freeBridgeString 释放 → 崩溃（违反"永不返回静态缓冲/字面量"约定） | bridge_videosink.cpp:70-74 |
| 高 | bridge_process.cpp:14-29 | process **12 组静态全局表零锁**（无 atomic_flag/spinlock，21-23 注释自称"与 bridge_signal 一致"实为没有）→ 跨线程 SetOn/delete 与信号派发数据竞争 | bridge_process.cpp:14-29 |
| 高 | bridge_list.cpp:18-20/37-43、bridge_tree.cpp:19-23/40-46 | views legacy **8 张文件级 static 回调 map 无任何 erase 路径**：qViewsSignalCleanup（bridge_ext_views.cpp:1601-1638，36/36 覆盖 ext_views 自身）清不到这两族 → 每次注册对象销毁后条目残留（慢泄漏 + 指针复用误派发窗口） | bridge_list.cpp:18-20（全文件 0 处 .erase） |
| 高 | bridge_events.cpp:16-24/112-118/139-150 | 事件 6 表 + g_eventWidgets 无锁；resolveEventWidget 对已析构对象回退 reinterpret 后解引用 → delete/SetOn/Clear 悬垂读+双删；EventWidget 析构只 erase widget 表不清 6 张回调表 | bridge_events.cpp:112-118 |
| 中 | 多模块 SetOn/Connect | **回调注册无替换/去重 → 重复派发**：bridge_list.cpp:257-296、bridge_tree.cpp:374-437、bridge_values.cpp:119-131/252-312、bridge_multimedia.cpp:234-271、bridge_network.cpp:1109-1173(id 版)、bridge_containers.cpp:258-260（disconnect 只 erase map 不断 Qt 连接） | 见各文件 |
| 中 | 多模块回调表 | 回调表无锁（除 core signal/存活表/thread/ui_poster 与 network×2 外）：widgets 各文件、views 44 表、gui（bridge_font.cpp:8、bridge_menu.cpp:17）、multimedia、bridge_core.cpp:68-69/882-915 跨 TU g_buttonCallbacks/g_timerCallbacks | 全局容器盘点 |
| 中 | bridge_network.cpp:936-946 | SSL peerVerify 回调**持锁直接调仓颉回调**（其余派发均拷出锁外）→ 回调内重入（delete/disconnect 再取锁）自死锁 | bridge_network.cpp:939-943 |
| 中 | bridge_layout.cpp:68-73/129-134/175-180/278-283、bridge_dialogs.cpp:354-459 | 布局 addLayout/setLayout 与 wizard addPage 所有权转移后 qXxxDelete 直接 delete 无 detach → 父先删、子 wrapper 后 close = double-free（靠"先子后父"纪律+存活表兜底） | bridge_layout.cpp:68-73 |
| 中 | bridge_abstractmodel.cpp:64-114 | CjAbstractItemModel：parent() 硬编码 createIndex(0,0,parentId)（丢父 row/col）；data()/headerData() 把回调返回的任意非 0 int64 当 const char* 解引用 → 数值返回即野读 | bridge_abstractmodel.cpp:69/97/109 |
| 中 | bridge_qml.cpp:809-813、183-188 | qQmlContextCreate(parent=0) 非法（QQmlContext 公开构造必须给父）→ 崩溃/UB；rootContext 归 engine 所有却暴露独立 delete 路径 → 与 engine 级联析构双删 | bridge_qml.cpp:809-813 |
| 中 | bridge_sql.cpp:440-534、114-116 | QSqlTableModel 段 21 处无 null 守卫直接解引用（ptr=0 即崩）；removeDatabase 时序契约（须先删全部 query/model）无强制 → "connection still in use" 累积 | bridge_sql.cpp:451-533 |
| 中 | bridge_syntax.cpp:26-31、bridge_print.cpp:318-331 | highlightBlock 同步回调内若 close 高亮器 = "delete this 未出栈" UB；printPreview paintRequested lambda 裸捕获 textEdit 指针（先删 textEdit 再回调 = UAF） | bridge_syntax.cpp:26-31 |
| 中 | bridge_print.cpp:278-298 | QPrintDialog/QPrintPreviewDialog 空 printer 分支暴露 Qt 内部自建 printer 指针，上层 delete 与 dialog 析构双删 | bridge_print.cpp:278-298 |
| 中 | bridge_painter.cpp:470-475/753-759、bridge_multimedia.cpp:98-117 | device 先于 active QPainter 被删 → 后续 draw UAF（无 QPointer/有效性检查）；先删 QAudioOutput 再对 player setVolume 悬垂解引用 | bridge_painter.cpp:470-475 |
| 中 | bridge_datetime.cpp:160-165/356-360/439-443/510-514、bridge_graphicsitem.cpp:33-107 | 多处无判空直接 reinterpret_cast 解引用（与带判空重复版实现不一致） | bridge_datetime.cpp:163 |
| 低 | bridge_network.cpp:618-627/194、bridge_network_access.cpp:194 | delete 漏清/错键：qUdpSocketDelete 漏清 UDP 表；QNAM delete 用 manager 键 remove reply 键（永不命中） | bridge_network.cpp:618-627 |
| 低 | 多文件 | 全局杂项：g_subclassedWindows 只增不删（bridge_core.cpp:237）；ui_poster ctx 从不释放；g_jsonKeyList 死代码；widgets.cpp:46 extern 悬空声明；bridge_widgets.cpp 674 个 U+FFFD 乱码注释（GBK 转换损坏） | bridge_core.cpp:237 |
| 中/低 | bridge_ext_wmisc.cpp:54-56 等、bridge_ext_wselect.cpp:109-111、bridge_ext_wtext.cpp:469-471、bridge_ext_views.cpp:1202-1204/1217-1219 | 回调派发反复用**函数级/文件级 `static QString`** 作跨回调传参缓冲，`toUtf8().constData()` 无实际保活且同类型多实例/重入时共享覆盖——安全全靠"回调内即时 toString"契约 | bridge_ext_wmisc.cpp:54-56 |
| 低 | bridge_ext_* 8 文件头注释 | 文件头注释仍写"static 缓冲区 + toUtf8().constData()"，实际 getter 已统一 dupUtf8（malloc）+ 仓颉 qCStringFree —— 陈旧误导注释（views 侧已更新） | bridge_ext_wcore.cpp:8 |
| 低 | 全局 11 处空 catch | bridge_signal 5 + bridge_events 6 处 `catch(...){}` 静默吞错无日志；其余 44 文件 0 try/catch（qml 4 处带 qCritical 日志为正面样本） | bridge_events.cpp:51 等 |
| 低 | bridge_process.cpp:126/144、bridge_dialogs.cpp:131 | qint64 pid static_cast<int> 截断；qInputDialogGetIntWithOk 的 ok 出参无空守卫 | bridge_process.cpp:126 |
| 中 | bridge_ext_wcore.cpp:97-100/198-200、bridge_widgets.cpp:259-266/350-355 | qWcoreSignalCleanup **只 erase 2 个 map**，漏清 g_btnPressed/g_btnReleased/g_btnToggled/g_btnClickedChecked 等共 7 个 ExtSlot map（含 QMetaObject::Connection+std::function）；qButtonDelete/qToolButtonDelete 不调它 → 连过 pressed/released/toggled 的按钮删除后条目永久驻留 | bridge_ext_wcore.cpp:97-100 |
| 中 | bridge_ext_new.cpp:110/117 | `static_cast<QScrollBarAccess*>(bar)` 把实际 `new QScrollBar` 的对象下转型到未构造的 accessor 子类（形式 UB，现无数据成员恰好可工作） | bridge_ext_new.cpp:110-117 |
| 中 | ext 六文件（wselect/wmisc/wtext/wrange/wlayout/new） | connect 句柄普遍不保存：清理只 erase map 不断 Qt 连接；无单信号断开接口；重复 setOnXxx 被 "find==end 去重守卫" 静默忽略（用户以为换了回调实际未生效） | bridge_ext_wselect.cpp:109-111 等 |
| 中 | ext 各文件级联析构盲区 | cleanup 只在显式 qXxxDelete 触发；父对象 Qt 级联销毁子控件时子 map 条目无清理 → 陈旧条目 + 地址复用后去重守卫使 connect 静默跳过（"回调不触发"风险源，与 core qWidgetDelete 级联空洞同族） | bridge_ext_wcore.cpp 等 |
| 低 | bridge_ext_new.cpp:220-225 | qRubberBandSetShape 为 no-op 静默接口；bridge_ext_apicomplete.cpp:130-140 qWidgetSelectAll 只 cast QAbstractSpinBox 却注释称覆盖 QLineEdit/QTextEdit → 其它控件静默无操作 | bridge_ext_new.cpp:220-225 |
| 低 | bridge_ext_wlayout.cpp:43-44/242-244 | bool 型回调（clicked/toggled/topLevelChanged）与其它文件 int32 风格混用（0/1 字节 ABI，勿当 int32 用） | bridge_ext_wlayout.cpp:43-44 |
| 低 | bridge_ext_wmisc.cpp:373 | cleanup 注释漏写 qCalendarWidgetDelete（实际调用存在）——纯注释缺陷 | bridge_ext_wmisc.cpp:373 |

> **B 组核验结论（合格项）**：wlayout 9 map、wmisc 17 map、wtext 17 map、wselect 4 map、wrange 5 map、new 6 map 均被各自 cleanup 全覆盖；对应 qXxxDelete 均先 cleanup 后 delete；ptr 守卫完整；字符串返回统一 dupUtf8/emptyString；8 文件空 catch 均为 0。至此 native 56/56 文件审查全部收齐。

**桥接层总体结论**：锁定规范（atomic_flag 自旋锁 + "锁内拷副本、锁外调回调"）已在 core(signal/存活表/thread/ui_poster) 与 network×2 落地；但 process/events/widgets/views/gui/multimedia 的全局回调表无锁——单线程场景安全，一旦使用库自带的 QThread/UiPoster/异步网络并发即数据竞争。回调清理设计整体良好（qViewsSignalCleanup 36/36、qWmiscSignalCleanup 17 表全覆盖、多数 qXxxDelete 先 erase 后 delete），缺口集中在：core 信号表须仓颉先行 qSignalCleanup（native 删除路径零调用）、views legacy 8 表漏删、个别 delete 漏清/错键、大量 SetOn 无替换导致重复 connect。字符串分配契约（dupUtf8/emptyString + qCStringFree）自洽，唯一违规为 videosink 悬垂返回。悬垂回调/裸 this 捕获类问题基本不存在（lambda 均值捕获 key/ptr）——本轮最干净的维度。

---

## 3. 跨模块共性与构建/文档

### 3.1 跨模块共性
1. QtResource 契约覆盖率不足（见执行摘要），影响 try-with-resources/ScopeManager 统一管理。
2. 借用指针（fromPtr/addXxx 包装）普遍不 trackObject → isObjectAlive 保护失效，与"级联析构防悬垂"设计目标矛盾（widget.cj fromPtr、menu addMenu/addAction、qml fromPtr、views item fromPtr、charts QLegend）。
3. capture 闭包注册/注销只在显式 disconnect 闭合（widget/timer/emitter/menu/network）。
4. CString 约定全库正确（亮点）。

### 3.2 构建系统
- CMakeLists 与 native/src 56 个 .cpp：**0 孤儿、0 缺失**。
- scripts 硬编码本机路径：`run-test.ps1` L58/L152、`verify_all.ps1` L55/L106、`rebuild_all.ps1` L36 的 `C:\CodeTools\cangjie\cangjie_1.1.0\tools\bin\{cjpm,cjcov}.exe` 回退路径不可移植。
- cjpm.toml 平台目标：`aarch64-unknown-linux-gnu` 链接 `releases/linux-arm64`（目录不存在）；`x86_64-apple-darwin` 链接 `macos-x64`（仅 147B README）——与 releases/README.md 声称的结构不符。
- Windows `${CJQT6_ROOT}` 依赖已有全部官方脚本自动注入 + 文档化（设计使然，裸跑需自设）。

### 3.3 文档一致性（含 DEFECTS.md/AGENTS/SKILL 与实物）
- AGENTS/SKILL 说测试 41 个 → 实际 **48** 个 `*_test.cj`；说示例 25 个 → 实际 **20** 个；说 @Expect 约 2443 → 实测 **2309**。
- AGENTS 说 macos-arm64/x64 "仅占位 README" → 实际 macos-arm64 已有 1.7MB dylib。
- SKILL/AGENTS 模块地图均缺 richwidgets（20 文件包 cjqt6.richwidgets，docs/api 亦未覆盖）。
- SKILL L182 "86 个静态信号回调 map"与现行统一 ConnKey 注册表实现不符（文档过时）。
- dialogs.cj 顶部"调用方需 LibC.free"注释与 freeBridgeString 实际约定相悖（误导）。
- examples 教学缺口：notepad 47 个 `let…=Q` 仅 4 处 `.delete()`（打印临时对象）；all_controls_demo/calculator/hello_cjqt6/paint_app/tank_battle 等 close=0，未示范显式释放。

---

## 4. 修复优先级（建议）

**P0（先修，含崩溃/UB/UAF/双删/数据错误）**
1. **charts 所有权矩阵**：series/axis/barSet/slice/set 挂 chart/view 后禁止独立 delete（或提供 remove/detach/isMounted 后再删）——chart.cj 系 close 无 isObjectAlive + bridge_chart.cpp 全套子 delete 与 Qt 级联所有权冲突（双删/悬垂面最大）。
2. **native 删除路径统一清表**：qSignalCleanup 并入 qWidgetDelete/各 qXxxDelete（级联删除入口），补 views legacy 8 表（bridge_list/tree）erase、修 qUdpSocketDelete 漏清与 QNAM delete 错键。
3. **回调表加锁与注册替换语义**：按 CallbackSpinLock 模式补 process/events/widgets/views/gui/multimedia 各表 atomic_flag；所有 SetOn/Connect 引入"句柄入表+先断旧连接"（消除重复注册重复派发）；修 SSL peerVerify 持锁调回调。
4. **bridge_videosink.cpp:70-74 悬垂返回**改 dupUtf8/emptyString（仓颉侧同步 freeBridgeString）；顺带 core 11 处空 catch 补日志。
5. 仓颉层修复：QWidget.fromPtr/fromPtrOwned 临时对象泄漏（widget.cj:50-67）；menu QAction close 补 qSignalCleanup + owned 标志；qml owned 子项 close 兜底；views model 类 qWidget* UB（filesystemmodel/standarditemmodel）。
6. propertyanimation.cj EasingCurve 常量按 Qt 官方枚举（静默错曲线）；syntaxhighlighter setFormat 颜色统一语义；abstractitemmodel.cj sizeHintRole 11→13。
7. QRunnable autoDelete 双删：提交池后禁止 close 或 native 关闭 autoDelete（thread.cj:83-89 + bridge_thread.cpp:54）。

**P1（泄漏/生命周期）**
8. paint：QPainter 接 qPainterDelete/close、QTransform 六方法改私有 fromPtr 包装（transform.cj:46-70）；datetime 值类 getter"先建后覆盖"泄漏 + 四控件 QtResource 化。
9. widgets/views 旧式类批量 QtResource 化（约 40 个 delete()-only 类，优先带父构造五容器 dockwidget/mdiarea/stackedwidget/toolbox/systemtrayicon、plaintextedit/textbrowser/keysequenceedit、graphicsitem/scene、graphiceffect、listwidget/treewidget/tablewidget delete 幂等化）。
10. Capture 注册表 close 级统一注销（类内记录 id / ptr→[id] 表，close sweep）——widget/timer/emitter/menu/network。
11. mediaplayer 三件套 + process/thread 系 QtResource 化（判空+track+checkValid）。
12. takeItem/裸句柄（mapToSource、currentIndex 等）提供释放契约或 owned 包装；QSplitter.saveState 未初始化内存读取修复。
13. scope_manager generateScopeId 用真实时间/递增计数。

**P2（一致性/健壮性/文档）**
14. layout/gui 包装类补 QtResource 与异常族统一；setMargins 补四方向；QJsonDocument 解析失败抛 CreateFailedException。
15. run-test/verify_all/rebuild_all 去除硬编码路径；AGENTS/SKILL/dialogs/string.cpp 注释与实物同步；richwidgets 补进模块地图与 api 文档；bridge_widgets.cpp 乱码注释修复。

---

## 5. 声明
- 本报告仅基于静态审查（未构建/未运行测试），行号基于当前工作区源码；动态可复现项（如 charts 双释放、QRunnable 双删）建议用 ScopeManager 同登记 + close 序列在测试中验证后再改。
- 严重度评估基于"典型使用会触发"的推定；凡触发前提是用户违反 Qt 线程亲和或文档明示禁忌的，均已注明。
- 报告撰写过程：4 组并行子代理（core/gui/dialogs/menu、widgets/views/paint、multimedia/network/sql/qml/print/resource/charts/richwidgets、native 全量）+ 父代理逐条回源复核与跨模块交叉核查。
