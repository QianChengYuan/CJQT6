# CJQT6 发展路线规划（Roadmap）

> 更新日期：2026-08-29
> 依据：仓颉 1.1.0 语言实际能力与限制 + 库当前覆盖度基线（v1.9.0）
> 说明：本文档的每个方向都先论证「仓颉能不能做、怎么做」，避免把 Qt 生态习惯直接照搬。

---

## 一、仓颉实际情况盘点（一切方向的可行性依据）

CJQT6 的演进边界由仓颉语言特性决定，先固定几个**不可绕过的事实**：

| 仓颉 1.1.0 事实 | 对库的影响 |
|----------------|-----------|
| 通过 FFI 调 C++，`foreign` 不能带泛型，需逐类型声明 | 每个控件/方法的桥接函数独立编写，封装成本高 |
| `CFunc` 回调**不能捕获局部变量**，只能传顶层 `let` + 全局 `?T` 共享状态 | 信号槽 API 设计受约束；跨线程传数据需额外机制 |
| **无运行时反射**，控件类型必须静态已知 | 无法做 Qt 式的元对象字符串绑定，动态功能受限 |
| GC + 终结器时机不确定 → 库内**禁用终结器**，须显式 `close()` | 内存安全依赖「所有权 + 显式释放」约定 |
| M:N 线程模型，`spawn`/`channel`/`Mutex`/`Future` 原生可用 | QThread 之外还有仓颉原生并发方案可选 |
| 默认参数仅支持命名参数（`p!: T = 默认值`），非命名参数用重载 | API 简洁度受限，常用「单参重载委托多参重载」模式 |
| 无三元、`match` 分支体不能用 `{}`、`Int64` 作 Map 键需位掩码 | 写库代码时的风格约束（已有规范） |
| 支持 `@FastNative`、`@When` 条件编译、宏 | 有条件做性能优化与代码生成 |

**结论**：库的未来方向 = 「最大化 Qt 能力」与「尊重仓颉约束」的交集。凡是要在 C++ 侧派生 `Q_OBJECT` 子类、或依赖 Qt 运行时元对象系统的能力（如动态属性、任意签名自定义信号、委托自绘），在 FFI 下代价高，需要回调桥接或固定信号集兜底——这是判断优先级的主要依据。

---

## 二、现状基线（v1.9.0）

| 维度 | 现状 |
|------|------|
| 覆盖 | 14 子包、142 个 `.cj` 文件、52 个 C++ 桥接 `.cpp`、API 文档 100% |
| 控件 | 38 个 widgets 文件，基础/容器/视图/对话框/菜单/绘图基本齐备 |
| 信号槽 | 基础回调 + `SignalConnection` 断开 + `SignalEmitter`（固定 void/int/double/string 信号 + QueuedConnection 跨线程） |
| 数据/网络 | QJson、QProcess、QThread/QThreadPool、QTcp/Udp/Ssl、QNetworkAccessManager、QSql |
| QML | `QQmlApplicationEngine`/`QQuickView`/`QQuickWidget`/`QQuickItem` + `QUiLoader`（.ui 静态加载） |
| 测试 | `src/test/`（`package cjqt6.test`）41 个测试文件、1417 用例，根目录 `cjpm test` 一键运行 |
| 发布 | Windows/Linux 预编译桥接库分平台分发；Git 依赖安装；无 CI、无 macOS 产物 |

**核心判断**：功能覆盖面已进入「够用但不够稳、不够深」阶段——下一步重心应从「堆控件」转向「提可靠 + 补深度 + 建生态」。

---

## 三、方向一：工程质量与可靠性（最高优先级）

### 3.1 测试纳入主流程
- 现状：`tests/` 是独立包且被 `.gitignore` 忽略，无法随仓库做回归保障。
- 动作：
  1. 解除 `tests/` 的 gitignore，纳入版本库；
  2. 配置根目录 `cjpm test` 一键运行（文档已给出 `GUITestEnvironment` + 19 个 `*_test.cj` 范式）；
  3. 补「枚举值对齐 Qt」对照测试——历史上多次踩 `ImageCaptureQuality`、`QItemSelectionModel` 等枚举值错位；
  4. 补「悬垂指针/重复 close」测试，验证 `close()` 幂等与 `checkValid()` 守卫。
- **Headless 基线（必做）**：`tests/` 之前被 gitignore 且为独立包，纳入主仓后必须先跑通**无显示环境**基线——CI/无桌面机器上设 `QT_QPA_PLATFORM=offscreen`（Linux 用 `xvfb-run cjpm test`）验证全部用例稳定通过，否则一键 `cjpm test` 会变成噪音源。同时对依赖真实显示/时序的用例显式标注 `# flaky` 并隔离（跳过/单跑），禁止混入主测试集。

**✅ 已完成（2026-08-08）**：测试源码迁入根包 `src/test/`（`package cjqt6.test`，21 文件 / 889 用例），根目录 `cjpm test` 直接发现并运行，`cjpm build` 自动排除 `*_test.cj`；`tests/deploy_qt_test.ps1` 适配根布局（部署到 `target/release/cjqt6`）+ offscreen headless 基线，全量 889/889 通过；`.gitignore` 改为仅忽略构建产物，测试与脚本入库。

### 3.2 桥接层内存安全审计
- 风险点：`CString` 跨 FFI 生命周期、回调触发时仓颉对象已被释放的竞态、`std::mutex`/`atomic_flag` 在 DLL 加载期的死锁。
- 动作：对 `native/src/**/bridge_*.cpp` 做一次「谁分配、谁释放、谁持有」的逐文件核查，统一字符串返回改为 `malloc+memcpy`（1.9.0 已修部分，扩展到全部返回点）。
- **反向失效通知（顺手小改）**：目前仓颉侧 `checkValid()` 是被动守卫——C++ 侧 QObject 已析构、仓颉句柄仍持有旧 `ptr` 时，调用前检查发现不了。在桥接析构里反向通知仓颉句柄置脏（如通过仓颉侧 WeakRef/回调置空），比纯调用前检查更稳，属 P0 内可一并完成的小改。

**✅ 已完成（2026-08-08）**：`native/src/**/bridge_*.cpp` 全部 `const char*` 返回点已统一为独立 `malloc` 分配（`dupUtf8`/`emptyString`），并按「bridge 自持释放」落地：
- 新增导出 `qCStringFree`（`std::free` 同堆释放），仓颉侧新增 `cstring_utils.cj::freeBridgeString` 统一释放 bridge 返回字符串；
- 412 处 `LibC.free` 中针对 bridge 返回串的 153 处替换为 `freeBridgeString`（输入参数 `LibC.mallocCString` 释放保持 `LibC.free`）；
- **附带修复 Windows CRT 堆不匹配崩溃**：`LibC.free` 绑定 `msvcrt`，而 MSVC `/MD` 编译的 bridge 用 UCRT `malloc`，混用触发堆损坏（`0xC0000409`）或挂起（此前 QClipboard/json 测试挂起根因）；桥接层所有返回字符串统一经 `freeBridgeString` 释放后，全量测试 889/889 通过；
- 顺带补齐 7 个文件缺失的 `import cjqt6.core.*`。

**✅ 已完成（2026-08-09）**：`反向失效通知` 落地——桥接层维护 native 存活表（`g_aliveObjs`，`std::atomic_flag` 自旋锁），任何 QObject 被 Qt 级联析构后自动置脏；仓颉侧统一 `trackObject`/`untrackObject`/`isObjectAlive` 三件套：
- 约 49 个封装类（core/widgets/gui/dialogs/menu/qml/multimedia/network/sql/views/print 等）构造时 `trackObject(ptr)`，`close()`/`delete()` 释放前先查 `isObjectAlive(ptr)`——已级联析构则只注销不重复 delete，根除 double-free；
- `isValid()` 升级为 `!closed && ptr != 0 && isObjectAlive(ptr)`，`checkValid()` 对已失效对象抛 `ResourceDisposedException`；
- `QWidget.fromPtr` 采纳外部指针前先 `untrackObject`，避免误销毁；
- 全量测试 894/894 通过（含新增 `reverse_invalidation_test.cj`：级联析构后调用不再崩溃/挂起）。

### 3.3 CI / 构建门禁（仓颉实际约束内可行）
- 远端是 GitCode，无 GitHub Actions，但可用 **GitCode CI / 自建脚本门禁**：
  - `update-bridge.ps1` + `cjpm build` + `cjpm test` 串成一条本地一键命令（`rebuild_all.ps1` 已有雏形）；
  - Linux 用 `xvfb-run cjpm test` 跑 GUI 测试。
- 产出：新增 `scripts/verify_all.ps1`（编译桥接 → cjpm build → cjpm test → 冒烟示例）。

**✅ 已完成（2026-08-08）**：`scripts/verify_all.ps1` 已落地（`update-bridge.ps1` → `cjpm build` → `deploy_qt_test.ps1 -RunTest` → 冒烟示例，支持 `-SkipBridge`/`-SkipTest`/`-SkipExample`/`-Example`/`-QtDir`）；测试 headless offscreen 基线随 3.1 一并验证通过。GitCode CI 仍未配置。

---

## 四、方向二：信号槽与异步模型补深

### 4.1 跨线程结果回传 UI 线程（仓颉原生方案）
- 现状：`SignalEmitter` 已支持 `QueuedConnection`，但回调是「顶层 `let` + 全局 `?T`」模式，跨线程传数据不优雅。
- 可行方案（利用仓颉并发原语）：
  - 用仓颉 `spawn` + `channel` 做工作线程，结果通过 **Qt 事件循环侧的 `QTimer`/`SignalEmitter`** 投递回 UI 线程；
  - 封装成 `AsyncTask`/`runOnUiThread` 工具（`cjqt6.core`），内部用 QueuedConnection 保证线程安全；
  - 这比 QThread 内嵌更贴合仓颉习惯，且不增加 C++ 桥接负担。
- **投递载体唯一出口（UiPoster 单例收口）**：仓颉 `spawn` 出的线程**没有 Qt 事件循环**，消息必须经 `QCoreApplication::postEvent`（或 `QTimer::singleShot(0)`）塞进 GUI 线程的事件队列。实现上必须**收口到唯一 `UiPoster` 单例**——所有 `runOnUiThread`/异步回投都只走这一个入口，禁止各模块各自 new QTimer/自建投递路径，否则连接类型、线程亲和、释放时序会散乱失控。
- 约束提醒：C++ 侧回调仍不能捕获仓颉局部变量，桥接层只能转发指针/标量。

**✅ 已完成（2026-08-09）**：`UiPoster` 单例收口落地——仓颉侧新增 `src/core/uiposter.cj`（`UiPoster.runOnUiThread`/`UiPoster.post` + 顶层便捷函数 `runOnUiThread`/`runAsync`），复用 `registerVoidCallback` 闭包注册表按 id 派发，一次性任务执行后自动注销防注册表无界增长；native 侧新增 `bridge_ui_poster.cpp::qUiPosterPost(id)`，经 `QMetaObject::invokeMethod(Qt::QueuedConnection)` 把任务塞进 `QCoreApplication`（GUI 线程）事件队列，另从 `bridge_signal.cpp` 导出 `qGetVoidDispatcher()` 供其按 id 派发。全部回投只走这一入口。新增 `p1_async_model_test.cj` 验证：事件循环内执行、`post` 别名、FIFO 顺序、`runAsync` 的 onDone 确在 GUI 线程执行（对比 `QThread.currentThreadPtr()`）。全量 906/906 通过。

### 4.2 重载信号消歧与命名连接
- 现状：部分 `setOnXxx` 已返回 `SignalConnection` 支持手动断开。
- 动作：对同一信号多参数重载（如 clicked/clicked(bool)）提供显式命名方法，避免歧义。

**✅ 已有/结论（2026-08-09）**：clicked/clicked(bool) 类重载早已以显式命名方法提供（`setOnPressed`/`setOnPressedChecked`、`SIGNAL_CLICKED`/`SIGNAL_CLICKED_CHECKED`），4.2 无需新增。注意：**Qt6 已移除 `QSpinBox::valueChanged(QString)` / `QDoubleSpinBox::valueChanged(QString)` 重载**（验证于 Qt 6.10.3 头文件，编译期即报错），旋转框的文本变化信号统一走 `textChanged(const QString&)`——库早已提供 `setOnTextChanged`（`CStringCallback`，含前缀/后缀完整文本），与 `setOnValueChanged`（数值）并存互不覆盖，已由 P1 测试覆盖。

### 4.3 模型动态化（dataChanged / 增量更新）【P1-a，优先落地】
- 现状：`QAbstractItemModel` 已用回调桥接（`beginResetModel`/`beginInsertRows` 等已导出），但**缺 `dataChanged`、`layoutChanged`**，实时刷新的表格只能整表 reset。
- 动作：桥接层补 `qAbstractItemModelDataChanged` / `layoutChanged` 导出 + 仓颉方法，支撑实时数据表（如日志、行情、聊天列表）。
- **优先级上调半档（P1-a）**：实时表（日志/行情/聊天列表）是上位机/工控场景的高频刚需，比 QtCharts 更早产生"上手即感知"的价值。P1 内部应把本子项排在 `runOnUiThread` 同批最先落地。

**✅ 已完成（2026-08-09）**：`bridge_abstractmodel.cpp` 新增 `qAbstractItemModelDataChanged(topLeftRow, topLeftCol, bottomRightRow, bottomRightCol)` 与 `qAbstractItemModelLayoutChanged()` 导出——dataChanged 的 topLeft/bottomRight 索引复用回调模型 `m_indexCb` 生成内部 id（`createIndex(row,col,(void*)id)`），保证视图刷新重新取数的 internalPointer 与初次 `index()` 一致；layoutChanged 固定带 `NoLayoutChangeHint`。仓颉侧 `QAbstractItemModel` 新增 `notifyDataChanged`/`notifyLayoutChanged`；`QTableView` 新增 `setModel(QAbstractItemModel)` 重载（与 `QStandardItemModel` 版并存），自定义实时表可直接挂载并局部刷新。P1 测试覆盖：回调索引调用、无 index 回调安全跳过、close 后抛 `ResourceDisposedException`、视图挂载后局部刷新不崩溃。

---

## 五、方向三：控件/模块补全（按需，低优先级）

原则：**不再批量铺控件**，只补「业务示例带出来的高频缺口」。

| 缺口 | 仓颉可行性 | 优先级 |
|------|-----------|--------|
| ✅ `QStyledItemDelegate` 自绘委托（已落地 `styleditemdelegate.cj` + 测试） | 需派生 QObject 子类，只能回调桥接（类似 QAbstractItemModel 方案），可行但成本高 | 中 |
| ✅ QtCharts（已落地 `src/charts/` + 测试） | 纯 FFI 可封装，无 Q_OBJECT 派生需求 | 中 |
| QSS（`setStyleSheet`）全量支持 | 纯 FFI，已有雏形，补细节即可 | 高 |
| ⚠️ 国际化 `QTranslator`/`QLocale`（`QApplication.loadQtTranslation` 已有，缺独立 `QTranslator` 类） | 纯 FFI，`QApplication` 已含翻译相关 API | 中 |
| ✅ `QCalendarWidget` 信号（2026-08-28 任务 2 已补 clicked/activated/selectionChanged） | 控件已有，补 clicked/activated/selectionChanged | 中 |
| `QPlainTextEdit` 高亮渲染细化 | 已有 `QSyntaxHighlighter`，补事件信号 | 低 |
| `QToolTip`/`QStatusTip`、`QTabWidget` 拖拽 | 纯 FFI，低难度 | 低 |

---

## 六、方向四：开发体验与生态

### 6.1 Designer → 仓颉代码流水线
- 现状：`QUiLoader` 已能静态加载 `.ui`，`ui2cj` 示例验证了可行性，但缺「一键生成仓颉代码」的脚手架。
- 可行方案：
  - 写一个仓颉工具（解析 `.ui` XML → 生成 `import cjqt6.*` 的布局+信号连接代码）；
  - 依赖仓颉 `std.json`/`std.ast` 或直接字符串处理即可，无需 C++。
- 意义：大幅降低新手上手门槛，是「生态放大器」。

**✅ 已完成（2026-08-10）**：纯仓颉工具 `tools/ui2cj` 落地（零第三方依赖，自研轻量 XML 解析器），示例验证 `examples/ui2cj_demo`、`examples/ui2cj_demo2`：
- **无工程自动引导**：`.ui` 所在目录向上查找 `cjpm.toml`——命中普通工程直接复用其包名并输出 `src/main.cj`；无工程时自动生成最小可运行工程（`cjpm.toml` 相对依赖 `..\..` + `src/main.cj`），命中库自身工程（包名 `cjqt6`，仓库根）视为无工程继续向上；
- **顺带生成 `deploy_qt.ps1`**：一键部署 Qt6 运行时 DLL + platforms/styles/imageformats 插件 + MSVC 运行库 + cjqt6 依赖 + bridge，脚本前置 UTF-8 BOM，兼容 Windows PowerShell 5.1（无 BOM 时中文按 ANSI 解析会吞行尾引号报语法错）；
- 布局变量名优先取 .ui 布局元素真实 `name` 属性（如 `verticalLayout_4`），缺失才派生；
- 运行：`cd tools/ui2cj && cjpm run -- <form.ui>`，配套 `scripts/gen-ui.ps1` 一键脚本与 `docs/internal/ui2cj-design.md` 设计文档。

### 6.2 发布与安装链路
- 现状：Git 依赖安装（`git = ...` + `tag`）已是主推方式，`releases/` 分平台预编译。
- 动作：
  1. 补 macOS 桥接库与构建脚本（当前只有 windows-x64 / linux-x64）。**注意**：macOS 的 app bundle / rpath / codesign 与 linuxdeployqt 思路完全不同，`windeployqt` 经验不能直接平移；若人力紧，优先出「社区贡献指引」而非官方保证产物；
  2. 补 `windeployqt`/`linuxdeployqt` 打包模板到示例（`deploy_qt.ps1` 已存在，文档化推广）。

**✅ 已完成（2026-08-10）**：macOS 一键构建脚本落地——`scripts/build-macos-x64.sh`（Intel）与 `scripts/build-macos-arm64.sh`（Apple Silicon）自动探测 Homebrew Qt 路径并部署到 `releases/macos-x64/`、`releases/macos-arm64/`，`scripts/build-all-platforms.sh` 统一入口自动检测当前平台；`releases/macos-*/README.md` 已随产物入库。`deploy_qt.ps1` 打包模板已随 `ui2cj` 引导工程自动生成并推广。

### 6.3 教程与最佳实践沉淀
- 现状：`docs/tutorial/` 只有 2 篇快速入门。
- 动作：补「信号槽与跨线程」「内存管理最佳实践」「自定义模型/绘图」「发布打包」4 篇进阶教程，把踩过的坑（AGENTS.md 已知坑清单）转成教学材料。

---

## 七、方向五：性能（含仓颉加速手段）

| 手段 | 说明 | 优先级 |
|------|------|--------|
| `@FastNative` 注解 | 对高频 `foreign` 调用标注减少 FFI 开销。**先 bench 再标**：高频 getter 收益可能不明显，热点更可能在事件分发/字符串转换，标注前用 P1 建的 bench 工程量化 | 中 |
| 信号槽延迟基准 | ✅ P1 已建 `examples/bench` 并出数据（2026-08-09）：Direct emit 回调≈300ns、runOnUiThread≈2.7µs、QTimer(interval=0) 事件循环派发≈14µs/op —— 事件循环往返是量级性热点，P3 优化应瞄准减少事件队列往返/批量桥接，而非标注 getter | 中 |
| 批量桥接减少往返 | 如 QPainter 连续绘图改为「一次调用传数组」模式 | 低 |

---

## 八、优先级矩阵与里程碑建议

| 阶段 | 主题 | 主要产出 | 估算工作类型 |
|------|------|---------|-------------|
| **P0（近期）** | 工程质量 | 测试入库+`cjpm test` 一键化（含 headless 基线，`# flaky` 隔离）✅；桥接字符串审计 ✅；反向失效通知 ✅；`verify_all.ps1` ✅ | 主要仓颉+脚本，少量 C++ |
| **P1（中期）** | 异步与模型 | `runOnUiThread` 工具（`UiPoster` 单例收口）✅；QAbstractItemModel 补 `dataChanged`/`layoutChanged`（**P1-a 优先**）✅ + `QTableView::setModel(QAbstractItemModel)`；重载信号消歧 ✅（Qt6 已移除旋转框 valueChanged(QString)，文本走既有 `setOnTextChanged`）；bench 工程建基 ✅（`examples/bench`：Int32 getter≈166ns、setText≈350~790ns、emitVoid≈300ns、runOnUiThread≈2.7µs、QTimer 事件循环派发≈14µs/op，为 P3 `@FastNative` 标注提供依据） | 仓颉 + C++ 桥接 |
| **P2（中期）** | 开发体验 | Designer→代码生成器 ✅（纯仓颉 `tools/ui2cj`：自研 XML 解析 + 无工程自动引导生成最小可运行工程 + `deploy_qt.ps1`（UTF-8 BOM 兼容 PS5.1），已随 `examples/ui2cj_demo`/`ui2cj_demo2` 编译运行验证）；QSS/翻译完善 ✅（应用级 QSS `QApp.setStyleSheet/styleSheet` + `QLocale` 封装）；macOS 构建链 ✅（`build-macos-x64.sh`/`build-macos-arm64.sh` 一键构建并部署 `releases/macos-*`，`build-all-platforms.sh` 自动检测平台） | 仓颉 + CMake |
| **P3（长期）** | 深度与性能 | QtCharts、自绘委托、`@FastNative` 优化（依据 P1 bench 结论标注，高频 getter 未必是热点）、进阶教程 | C++ + 仓颉 + 文档 |

---

## 九、反方向清单（不建议做）

| 方向 | 原因 |
|------|------|
| 批量铺完 Qt 全部控件 | 边际价值低，维护 52 个桥接文件成本高；不如把已有控件做深 |
| 用 QML 作为主 UI 路线 | 仓颉无运行时反射 + QML 引擎在 FFI 下调试成本高，widgets 路线更稳 |
| 反射/字符串绑定做动态属性系统 | 仓颉无运行时反射，只能静态路由，做出来的体验劣于直接写码 |
| 全面依赖 C++ 子类派生（Q_OBJECT） | FFI 下只能回调桥接，复杂度爆炸，仅限个别高价值场景 |
| 终结器方案替代显式 close | GC 时机不确定，1.9.0 已证实会崩溃，方向不可逆 |

---

*关联文档：`docs/guides/architecture.md`（架构）、`docs/internal/api-completeness.md`（覆盖度）、`docs/internal/unwrapped-controls-analysis.md`（控件清单）、`docs/CHANGELOG.md`（演进史）、`docs/CONTRIBUTING.md`（新增控件流程）。*
