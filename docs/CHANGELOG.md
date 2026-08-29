# 更新日志

> **版本号设计原则（语义化版本 SemVer）**：
> - **major**：不兼容的 API 破坏性变更
> - **minor**：新增功能或较大改进（新控件封装、新模块、工程基础设施等）
> - **patch**：Bug 修复或文档调整（不新增公开 API）
> - 每个版本对应一组逻辑相关的 git 提交，按功能里程碑划分而非按日期随意递增
> - 版本号与 git tag 一一对应（`v1.9.0` → tag `v1.9.0`），cjpm.toml `version` 字段同步

## [1.9.1] - 2026-08-29

### 新增

- **QVideoSink 封装**：新增 `bridge_videosink.cpp` + `videosink.cj`，封装 videoSize/subtitleText API，实现 QtResource 接口。关键发现：Qt 6.10.3 的 QVideoSink 已移除 brightness/contrast/hue/saturation 属性，视频调节需通过着色器或帧处理实现。
- **QLineEdit `setValidator` 成员方法**：3 重载（QIntValidator/QDoubleValidator/QRegExpValidator），原有自由函数 `setLineEditValidator` 保留。
- **QLineEdit `setDragEnabled`**：设置是否允许拖放。
- **QTextEdit 信号**：`setOnCursorPositionChanged`/`setOnSelectionChanged`，桥接 `bridge_ext_wtext.cpp` 加 g_teCursorPos/g_teSelection map + connect 函数 + cleanup。
- **QCalendarWidget `setMinimumSize`/`setStyleSheet`**：复用 qWidget 共享 FFI。
- **QVideoWidget QtResource 接口**：实现 `<: QtResource` + `isClosed`/`isValid`/`checkValid`。

### 修复

- **api-completeness.md 过时信息修正**：QScrollArea `setFrameShape`/`setFrameShadow` 实际已实现，从缺失列表移到已有（覆盖度 85%→95%）。

### 测试

- 全量测试 1346 通过 / 0 失败 / 71 跳过（QVideoSink 3 个用例被 `requires_audio` 标签跳过，已单独验证通过）。

### 文档

- 更新 `docs/api/02_widgets_basic.md`：QLineEdit 方法表加 `setValidator`/`setDragEnabled`，QTextEdit 方法表加信号 + `setTabStopDistance`/`setAcceptRichText`/`setPlaceholderText`。
- 更新 `docs/api/13_multimedia.md`：QVideoWidget 方法表加 QtResource 接口方法，新增 QVideoSink 段落。
- 更新 `docs/api-completeness.md`：QLineEdit/QTextEdit 覆盖度 95%→98%，QVideoSink 已完成记录，测试状态更新。

## [1.9.0] - 2026-08-16

### 新增

- **CI/CD 基础设施**：GitHub Actions 双端 CI（Linux ubuntu-24.04 + Windows windows-2022），aqtinstall 固定 Qt 版本、编译 bridge、offscreen 测试 + cjcov 覆盖率上传；SDK 下载改用稳定 objectKey API（无需签名、随版本固定）+ SHA-256 校验。
- **桥接层 C++ 单测集成 CI（P0-3）**：`native/tests/bridge_core_test.cpp` 扩展至 12 套件 / 93 checks（存活表三件套 + 字符串工具 + 级联析构 + 8 线程并发 + 8 个信号回调清理回归套件），CI 双端均加「编译并运行桥接层 C++ 单元测试」步骤（Linux 带 ASAN）。
- **cjpm check 依赖门禁（P0-4）**：CI 双端加「校验依赖可重现构建」步骤执行 `cjpm check`。
- **工程治理基础设施**：覆盖率门禁（`scripts/check-coverage.ps1` 双口径）、发布门禁（`scripts/check-release.ps1` tag 前检查 CHANGELOG/版本号）、API 索引门禁、安全说明（`SECURITY.md`）、封装模板（`docs/wrapper-template.md`）。
- **Qt 版本×平台兼容矩阵（P1-2）**：新增 `docs/qt-version-matrix.md`，含平台 × 锁定版本矩阵（含本机/CI 区分）、ABI 敏感说明（`qt_qFindChild_helper`/`valueChanged(QString)`/`QRegExpValidator`/MinGW 与 MSVC ABI/aqtinstall 6.10+ 解压失败）、版本更换三步指南。
- **性能基线文档（P2-3）**：新增 `docs/performance-baseline.md`，FFI/信号/异步四条高频路径实测基线表（Windows Qt 6.10.3）、解读结论与优化优先级、复跑方法与跨平台记录表、性能 commit 前后对照门禁。

### 修复

- **信号回调清理**：`bridge_signal.cpp` delete 时清理全部 86 个静态信号回调 map，修复控件 connect 偶发失效（wrange + views/wtext/wmisc/wlayout/wnew/wselect/wcore 8 套件回归验证）。
- **跨平台编译修复**：`bridge_core.cpp` 原无条件 `#include <private/qeventdispatcher_win_p.h>` 并使用 `QEventDispatcherWin32`（Windows 专用），Linux 上不存在该头文件导致编译失败；加 `Q_OS_WIN`/`Q_OS_UNIX` 平台守卫，Linux 改用 `QEventDispatcherUNIX` + `qeventdispatcher_unix_p.h`。`CMakeLists.txt` 的 `CorePrivate` 原列为 REQUIRED 组件，但 Ubuntu 22.04 的 Qt 6.4.2 不提供独立 cmake 配置，改为可选（`QUIET`）+ 条件链接 `if(TARGET Qt6::CorePrivate)`。
- **CI Windows Qt 版本降级**：aqtinstall 3.3.0 解压 Qt 6.10.3 报 `Bad7zFile: QtNoLinkTargetHelpers.cmake`（Qt 6.10+ 新增文件，py7zr 不兼容），CI Windows Qt 版本从 6.10.3 降到 6.9.1 后稳定。
- **CI Linux 平台无关用例排除扩展**：原仅排除 `requires_audio`，后续发现 `QMessageBox.information()`/`QMenu.popup()` 在 offscreen 平台模态挂起、`QProcessSpawnTests` 用 `cmd /c`（Windows 专用）、`QPrinterTests.testOutputFormatRoundtrip` 依赖 CUPS 打印系统；分别加 `@Tag[requires_gui_dialog]`/`@Tag[requires_process_spawn]`/`@Tag[requires_printer]` 标签，Linux CI 排除 5 组 `--exclude-tags=requires_gui_dialog,requires_gui_drag,requires_audio,requires_process_spawn,requires_printer` + `--timeout-each=30s`。CI run #21 双端全绿（PASSED 1156/SKIPPED 63/FAILED 0）。
- **`bridge_core.cpp` 编译错误**：补 `thread_local QEventLoop* t_currentLoop = nullptr;` 声明，修复未声明的 `t_currentLoop` 标识符错误。

### 测试

- 补全 13 个 0% 覆盖文件的单元测试，整体覆盖率 70.45%→79.14%。
- 多媒体测试加 `@Tag[requires_audio]`，Linux CI 排除该组避免无音频服务阻塞挂起。

### 构建

- 重编 Linux/Windows 桥接库产物（`releases/linux-x64/libcjqt6_bridge.so` + `releases/windows-x64/cjqt6_bridge.dll`/`.lib`）。

### 文档

- README 重写优化（融合 CTQT6.MD 结构 + 修正过时数据）。
- 测试文档修正 6 处错误 cjpm test 命令（`docs/testing/test-guide.md` + `test-faq.md`）。
- 脚本环境变量统一（`QTDIR`/`CJQT6_ROOT`/`CANGJIE_HOME`），3 个 PowerShell 脚本加 `CANGJIE_HOME` 候选、`run-test.sh` 修 `QT_DIR`→`QTDIR`。
- `docs/internal/CJQT6_优化点清单.md` 更新（P0-1/P0-2/P1-2 等多个条目反映 CI 修复历程）。

---

## [1.8.0] - 2026-08-09

### 新增

- **聊天示例**：`examples/qq_chat` 单机版聊天 + `examples/qq_chat_lan` 局域网聊天（历史同步/撤回/文件传输/表情/账号管理，36 项 e2e 断言），补全 `QTcpServer` 封装并修复桥接层死锁。
- **记事本字体格式智能应用**：字体对话框保留已有格式，修复双入口冲突。
- **音乐播放器歌词同步**：新增歌词同步显示、曲目元数据与深色主题。
- **QML 模块完善**：`QQmlApplicationEngine`/`QQuickView`/`QQuickWidget`/`QQuickWindow`/`QQmlComponent`/`QQmlContext`/`QQuickItem` 封装（QtResource 范式 + 属性与信号），修复相对路径加载。
- **QUiLoader 封装**：支持 Qt Designer `.ui` 文件静态加载（FFI 桥接 + 测试与文档）。
- **反向失效通知**：native 存活表 + `trackObject`/`untrackObject`/`isObjectAlive` 三件套，修复级联析构 double-free 挂起；48 个源文件覆盖，35 个实现 `QtResource` 接口。
- **P1 异步与模型**：`UiPoster` 单例收口跨线程回投（`runOnUiThread`/`post` + 顶层 `runOnUiThread`/`runAsync`），native 侧 `bridge_ui_poster.cpp::qUiPosterPost`（`QMetaObject::invokeMethod` QueuedConnection）；`QAbstractItemModel` 补 `notifyDataChanged`/`notifyLayoutChanged`（局部刷新），`QTableView` 新增 `setModel(QAbstractItemModel)` 重载。
- **国际化**：`QLocale` 封装与 `QApp` 全局 QSS，补充 macOS 一键构建脚本。
- **ui2cj 工具**：无工程自动引导（生成最小可运行工程与 `deploy_qt.ps1`，UTF-8 BOM 兼容 PowerShell 5.1）。
- **P1 bench 工程**：`examples/bench` 基准工程（`std.time.MonoTime` 单调纳秒测时），量化纯 FFI 往返 / 字符串过 FFI / 信号回调吞吐 / 异步路径四条高频路径：Int32 getter≈166ns、setText≈350~790ns、emitVoid 回调≈300ns、runOnUiThread≈2.7µs、QTimer 事件循环派发≈14µs/op。

### 修复

- **桥接字符串返回统一**：走 bridge 自持释放，修复 Windows CRT 堆不匹配崩溃。
- **Qt 6 已移除重载**：移除 `QSpinBox/QDoubleSpinBox::valueChanged(QString)` 桥接尝试（Qt 6.10.3 编译期报错）；文本变化统一走 `setOnTextChanged`。

### 重构

- **native 构建目录统一命名**：`build_windows_x64`，新增 `AGENTS.md`。

### 测试

- 测试源码迁入根包 `src/test/`（`package cjqt6.test`，34 个 `*_test.cj`），根目录 `cjpm test` 直接发现并运行。
- P1 异步模型 12 用例（模型局部刷新通知、UiPoster 跨线程回投 FIFO/线程身份、旋转框 `textChanged`）。

### 构建

- 重编含 QML 桥接的 Linux(WSL)/Windows 桥接库并收窄 releases 发布物。

### 文档

- `docs/roadmap.md`：4.1/4.2/4.3 落地标记与 Qt6 重载结论；P1 里程碑矩阵更新（bench ✅ + 量化数据）。
- `docs/api/01_core.md`：新增 `UiPoster`/`runOnUiThread`/`runAsync` 章节。
- `docs/api/05_views.md`：`QTableView::setModel`、`QAbstractItemModel::notifyDataChanged`/`notifyLayoutChanged`；修正示例中不存在的 `(row*2+col).toInt64()`（仓颉数值转换用 `Int64(...)`）。

## [1.7.0] - 2026-08-02

### 新增

- **P1 批次 12 个控件/工具封装**: 新增 C++ FFI 桥接 + Cangjie 绑定——core 模块 `QItemSelectionModel`（含 `SelectionFlag`）、`QJsonDocument`/`QJsonArray`/`QJsonObject`/`QJsonValue`（含 `JsonType`）、`QThread`/`QThreadPool`/`QRunnable`（含 `ThreadPriority`）、`QSettings`、`QShortcut`、`QPropertyAnimation`；gui 模块 `QCursor`、`QPalette`、`QFont`、`QSyntaxHighlighter`、`QTextDocument`/`QTextCursor`、`QIcon`；multimedia 模块 `QImageCapture`、`QSoundEffect`；network 模块 `QNetworkProxy`、`QLocalServer`、`QNetworkAccessManager`、`QSslSocket`；views 模块 `QAbstractItemModel`；widgets 模块 `QGraphicsItem` 系列 7 个图形项 + `QGraphicsOpacityEffect`/`QGraphicsDropShadowEffect`/`QRubberBand`/`QToolBox`/`QMdiArea`/`QDockWidget`/`QFontComboBox`/`QCompleter`；sql 模块 `QSqlTableModel`；paint 模块 `QFontDatabase`
- **6 个控件封装**: `QAbstractAnimation`/`QParallelAnimationGroup`（含 `AnimationState`/`AnimationDirection`）、`QUndoCommand`/`QUndoStack`、`QStyleHelper`（含 `StandardIcon`/`PixelMetric`）、`QCamera`/`QCameraDevice`/`QMediaDevices`/`QMediaCaptureSession`、`QVideoWidget`、`QSortFilterProxyModel`（含 `SortOrder`/`CaseSensitivity`）
- **宿舍管理系统示例**: `examples/dormitory_manager` 完整 GUI 应用——三角色登录、宿舍楼/房间/学生/宿管/考勤/报修/公告管理，基于 SQLite 数据库
- **全量中文注释补齐**: 103 个 `.cj` 文件均含中文注释，每个 `public class` 上方均有文档注释；补齐 10 个历史遗漏文件 + 15 处类定义注释

### 修复

- **C++ 桥接异常安全**: `bridge_signal.cpp` 所有信号回调包裹 `try/catch(...)`，防止 Cangjie 异常穿越 C FFI 边界
- **字符串生命周期**: `string.cpp`/`bridge_widgets.cpp` 中 `const char*` 返回改为 `malloc+memcpy` 堆分配，消除悬垂指针（QLineEdit/QTextEdit/QPlainTextEdit/QTextBrowser/QKeySequenceEdit 等字符串返回统一修复）
- **信号槽死锁**: `bridge_signal.cpp` 中 `std::mutex` 在 DLL 加载时的死锁问题改为 `atomic_flag` 自旋锁；`bridge_core.cpp` 清理调试日志并增加 `qWidgetShow` NULL 检查
- **QPainter 空设备崩溃**: 修复空绘制设备崩溃；修正 `QTabWidget` 信号签名与字体族/样式分隔符
- **枚举值对齐 Qt6**: `ImageCaptureQuality`（VeryLow=0~VeryHigh=4）补齐两个缺失档位；`QItemSelectionModel` 选择标志枚举值与 Qt 一致
- **VC143 运行时库**: 部署新版 `msvcp140.dll`/`vcruntime140.dll` 等 5 个 DLL 到 `releases/windows-x64/`，修复旧版运行时下互斥锁崩溃

### 重构

- **8 个控件类实现 QtResource 接口**: `QWizardPage`/`QWizard`/`QErrorMessage`（`var ptr` + `closed` + `checkValid()`）、`QAction`/`QMenu`（沿用 `ownsPtr` 语义）、`QMenuBar`/`QToolBar`/`QStatusBar`/`QMainWindow`（新增 QtResource 实现）；所有 public 方法增加 `checkValid()` 守卫，`close()` 幂等、`delete()` 兼容旧 API
- **QtResource 第二批/第四批**: `QRadioButton`/`QDial`/`QLCDNumber`/`QToolButton`、`QAction`/`QProgressDialog`/`QTcpSocket`/`QSqlDatabase` 补齐 QtResource 实现与 `CreateFailedException` 空指针检查
- **API 补齐**（`bridge_ext_apicomplete.cpp`）: QSlider `setInvertedAppearance`、QFrame `lineWidth`/`frameWidth`、QDoubleSpinBox `setWrapping`/`setButtonSymbols`/`selectAll`/`setFocus`、QToolButton `text`/`defaultAction`/`setDefaultAction`、QGroupBox `setFlat`/`isFlat`、QSpinBox `selectAll`/`setFocus`、QProgressBar `text`
- **诊断脚本整合**: `check_qt6.cj`/`detect_platform.cj`/`post_install.cj`/`verify_install.cj` 合并为 `tools/cjqt6-diagnose` CJPM 项目

### 构建

- **脚本适配 Cangjie 1.1.0**: `build_bridge.bat`/`rebuild_all.ps1`/`setup-qt-env.ps1`/`update-bridge.ps1` 等动态扫描 Qt6 组件，支持 `-QtDir` 参数透传
- **移除冗余脚本**: 删除 `build-windows-x64.ps1`、`build_bridge.bat`，`rebuild_all.ps1` 改调 `update-bridge.ps1`
- **过期脚本更新**: `run-test.sh`/`build-windows-x64.ps1`/`setup-qt-env.sh` 同步适配；`rebuild_all.ps1` 注释改为中文；修复 `update-bridge.ps1` 管道导致 MSBuild 中文乱码
- **Windows 桥接库更新**: `releases/windows-x64/cjqt6_bridge.dll`/`.lib` 随各批次重新编译

### 文档

- **API 文档全覆盖**: `docs/api/*.md` 与 `src/` 逐类对齐，302 个公开类文档覆盖率达 100%——补齐 QTimer、QTextDocument/QTextCursor/QSyntaxHighlighter、QTextEdit 富文本查找替换、图形特效（QGraphicsOpacityEffect/QGraphicsDropShadowEffect）、通用布局类型（Alignment/Orientation/Margins/Point/Size/Rect）、LabelTextFormat、SpinBoxCorrectionMode/SpinBoxButtonSymbols、QListWidgetItem/QTableWidgetItem、WidgetInfo、ResourceUtils、ScrollBarPolicy、ProcessChannel 等章节
- **文档结构整理**: 删除 `docs/installation.md`，资源管理文档移入 `docs/resource/`，更新 `build-guide` 脚本引用
- **安装方式变更**: 改用 Git 依赖方式安装（`cjpm.toml` 中 `git = "..."`, `tag = "..."`）；示例代码 API 用法修正并添加运行时 PATH 配置说明
- **api-completeness.md / unwrapped-controls-analysis.md**: 反映新增 API 后的覆盖度评估

---

## [1.6.0] - 2026-07-27

### 新增

- **FFI 桥接库分平台发布包**: 新增 `releases/cjqt6-bridge-linux-x64.zip`（`libcjqt6_bridge.so`）和 `releases/cjqt6-bridge-windows-x64.zip`（`cjqt6_bridge.dll` + `cjqt6_bridge.lib`），通过 GitCode Releases 分平台分发
- **Git 依赖安装**: 文档改为推荐 Git 方式安装（`cjpm.toml` 中 `git = "..."`, `tag = "..."`），`docs/installation.md` 更新安装流程（Git 源码 → 下载桥接库 → 项目配置），`docs/PUBLISHING.md` 同步更新分发策略

### 修复

- **QApplication 空指针崩溃**: `bridge_core.cpp` 中 `QApplication` 构造传 `argv=nullptr` 导致 `__fastfail` 栈保护崩溃（`STATUS_FAIL_FAST_FATAL_STACK_BUFFER_OVERRUN`），改为传入合法空参数 `s_argv = {"cjqt6", nullptr}`，并添加 try-catch 异常处理

### 构建

- **Linux x86_64 桥接库**: 在 WSL (Ubuntu 24.04) 下用 GCC 13.3 + Qt6 6.4.2 编译通过，完整链接 Core/Gui/Widgets/Qml/Quick/QuickWidgets/Network/Sql/PrintSupport/Multimedia 模块
- **Windows 桥接库更新**: `releases/windows-x64/cjqt6_bridge.dll` 重新编译

### 文档

- **安装指南**: `docs/installation.md` 重写安装说明，Git 源码安装与 Releases 桥接库下载
- **FFI 原生库分发说明**: `docs/PUBLISHING.md` 新增第4节，解释 `cjpm bundle` 不包含 FFI 原生库的原因及双通道分发策略

### 杂项

- **`cjpm.toml`**: 移除 tags 中的冗余标签 "ui"
- **`cjqt6_bridge.def`**: 删除已废弃的模块定义文件

## [1.5.0] - 2026-07-25

### 新增

- **通用信号发射器 `cjfw::SignalEmitter`**：`native/includes/signalemitter.h`（`Q_OBJECT` + `signalVoid/signalInt/signalDouble/signalString`），`bridge_signal.cpp` 内建 `qEmitter*` 桥接；Cangjie 侧 `src/core/emitter.cj` 提供 `SignalEmitter <: QtResource` + `ConnectionType{Auto/Direct/Queued/BlockingQueued}` + `setOnVoid/Int/Double/String`（含 `connType` 重载）+ `setOnVoidCapture` + `emitXxx` + `disconnectXxx` + `disconnect()`。实现自定义信号与 `emit`，并支持跨线程 `QueuedConnection`（以 emitter 自身作 context 投递到 GUI 线程）。
- **P1c 闭包捕获 API**：`src/core/callback.cj` 全局闭包注册表（`HashMap<Int64,()->Unit>`）+ 顶层 `CFunc` 调度器；各控件新增非破坏性 `setOnXxxCapture(callback:()->Unit):SignalConnection`（改名避免与现有 `VoidCallback` 内联 lambda 二义），`SignalConnection.disconnect()` 时注销注册表项。
- **`SignalConnection` 真实句柄返回**：`pushbutton.cj`/`toolbutton.cj` 的 `setOnPressed/Released/Toggled/ClickedChecked`、`timer.cj` 的 `setOnTimeout` 现返回真实 `SignalConnection`（含 `isConnected()` + `disconnect()` 路由）。

### 修复

- **P0 信号索引与断开（核心）**：`bridge_signal.cpp` 由共享 `g_voidCallbacks[ptr]` 改为复合键 `(ptr, signalId)` 索引，保存 `QMetaObject::Connection` 句柄；`disconnect` 真正调用 `QObject::disconnect` 并清回调表（旧版仅清哈希、lambda 泄漏）；连接语义统一为**替换式**（重复 `setOnXxx` 先断旧再连新）。修复共享哈希碰撞/假断开/重复叠加三类 Bug。
- **P1a 按钮扩展信号真断开**：`bridge_ext_wcore.cpp` 按钮 `pressed/released/toggled/clickedChecked` 改为保存 `QMetaObject::Connection`，新增 `qButton/qToolButton DisconnectPressed/Released/Toggled/ClickedChecked`，连接语义为替换式。
- **统一 `disconnect()` 断全部信号**：覆盖 QWidget/QTimer/QComboBox/QCheckBox/QRadioButton/QSlider/QSpinBox/QDoubleSpinBox/QDial/QLineEdit/QPushButton/QToolButton/QTabWidget（QAction 已有），保留 `disconnectXxx()`；native 走 `disconnectByKey` 真断开（含捕获路径）。
- **CString 生命周期**：native `textChanged`/`currentTextChanged` 回调内改为 `std::string s = text.toUtf8().constData(); cb(s.c_str());`，消除 `toUtf8().constData()` 悬垂风险。
- **Cangjie 1.1.0 语法核对**：确认默认参数**仅支持命名参数** `name!: Type = 默认值`；普通参数 `name: Type = 默认值` 非法（改用 arity 重载，保留位置式 `connType: X` 调用）。`spawn` 为关键字表达式 `spawn { => ... }` 而非函数调用。

### 测试

- **`examples/signal_smoke` 无头冒烟测试（offscreen）phase1~8 全 PASS**：替换式连接、真断开（`ΔcountB==0`）、按钮 `pressed` 句柄 `connect→disconnect→重连`（isConnected true→false→true）、P1c 捕获闭包驱动、P2 自定义信号 void/int/double/string 正确派发 + 跨线程 `QueuedConnection` 接收=5（GUI 线程收满后本线程 `QApp.quit()`）。
- **`tests` 包编译**：修复预存 `pen_test.cj`（`QPen(color,5)` 构造不存在）、`lifecycle_test.cj`（`QColor(i,i*2,i*3)` Int64/Int32 不匹配）编译错误，`cjpm test` 现可编译全部测试模块（运行时 `TOTAL:0` 为预存框架发现机制问题，与信号改动无关）。

### 文档

- `docs/internal/SIGNAL-SLOT-REVIEW.md`：全面更新架构现状 / 已修复 / 运行时验证（phase1~8）/ 仍待推进，P0/P1/P2 结论与代码一致。

---

## [1.4.0] - 2026-07-24

### 新增

- **core/common.cj**: 新建公共FFI声明模块，集中管理core包内共享的QWidget基础FFI声明，消除包内重复定义
- **QScreen DPI辅助方法**: `scaleFactor()`、`logicalToPhysical()`、`physicalToLogical()`，支持逻辑像素与物理像素互转
- **QWidget DPI感知方法**: `resizeDp()`、`setMinimumSizeDp()`、`setMaximumSizeDp()`，自动按设备像素比缩放尺寸
- **TickPosition 类**: 刻度位置常量封装（NoTicks/TicksAbove/TicksBelow/TicksLeft/TicksRight/TicksBothSides），替代slider.cj裸露`public const`
- **FrameShape 类**: 边框形状常量封装（NoFrame/Box/Panel/WinPanel/HLine/VLine/StyledPanel），替代containers.cj裸露`public const`
- **FrameShadow 类**: 边框阴影常量封装（Plain/Raised/Sunken），替代containers.cj裸露`public const`
- **4个布局类QLayout接口实现**: QVBoxLayout/QHBoxLayout/QGridLayout/QFormLayout 均实现 `<: QLayout`，添加 `closed` 字段、`checkValid()` 守卫、`setMargins(Margins)` 方法
- **9个控件QtResource实现**: QCheckBox/QProgressBar/QSlider/QComboBox/QGroupBox/QTabWidget/QScrollArea/QFrame/QSplitter 均实现 `<: QtResource`，添加 `closed` 字段、`isClosed()`/`isValid()`/`checkValid()`/`close()` 方法，所有public方法添加 `checkValid()` 守卫

### 修复

- **QLabel.close() 缺失 qSignalCleanup**: 资源释放时未断开信号连接，可能导致悬空回调崩溃
- **QTextEdit.delete() 缺失 qSignalCleanup**: 同上，且 `ptr` 声明为 `let` 导致无法置零，现已改为 `var`
- **QTabWidget.delete() 缺失 qSignalCleanup**: 资源释放时未断开信号连接
- **QSplitter.delete() 缺失 qSignalCleanup**: 同上，且删除后未将 `ptr` 置零

### 变更

- **Alignment去重**: 删除 `lineedit.cj` 中重复的 `Alignment` 类定义，统一使用 `gui/types.cj` 中的 `Alignment` 结构体
- **裸露常量封装**: `slider.cj` 中 `Horizontal/Vertical/NoTicks/TicksAbove` 等6个 `public const` 替换为 `TickPosition` 类静态常量；`containers.cj` 中 `NoFrame/Box/Panel` 等10个 `public const` 替换为 `FrameShape`/`FrameShadow` 类静态常量
- **core/widget.cj FFI精简**: 移除与 `common.cj` 重复的FFI声明，仅保留控件专属FFI

### 补全

- **QLabel**: 补全 `setToolTip()`、`setVisible()`、`isVisible()`、`setEnabled()`、`isEnabled()`、`setMinimumSize()`、`setMaximumSize()`、`width()`、`height()` 共9个方法
- **QTextEdit**: 补全 `setEnabled()`、`isEnabled()`、`setToolTip()`、`setVisible()`、`isVisible()`、`setMaximumSize()`、`width()`、`height()` 共8个方法，并添加 `QtResource` 实现
- **QFrame**: 补全 `setToolTip()` 方法

### 文档

- 为 `core/common.cj`、`core/widget.cj`、`widgets/common.cj` 中所有FFI声明添加 `// QClassName::methodName() - 中文功能说明` 注释
- 为 `gui/types.cj` 中 `TickPosition`/`FrameShape`/`FrameShadow` 类及常量添加中文文档注释
- 为 `checkbox.cj`/`progressbar.cj`/`slider.cj`/`combobox.cj`/`containers.cj`/`textedit.cj`/`layout.cj` 中所有FFI声明添加中文注释
- 更新全部14篇API文档

---

## [1.3.0] - 2026-07-23

### 新增

- **API 补全（全部 37 widgets + 9 views）**: 补齐大量此前缺失的 Qt 方法 / 属性 / 信号，覆盖 PushButton / ToolButton / CheckBox / RadioButton / Label / LineEdit / TextEdit / PlainTextEdit / TextBrowser / ComboBox / FontComboBox / Completer / KeySequenceEdit / Slider / SpinBox / DoubleSpinBox / Dial / LCDNumber / ProgressBar / CommandLinkButton / DialogButtonBox / ScrollBar / SplashScreen / SizeGrip / RubberBand / DateTimeEdit / GraphicEffect / GraphicsView / SystemTrayIcon / ButtonGroup，以及 Model/View（QListView / QTableView / QTreeView / QFileSystemModel / QHeaderView + QListWidgetItem / QTableWidgetItem / QStandardItem / QModelIndex）。
- **新增 FFI 桥接文件（8 个，避免并发改动共享 bridge）**: `bridge_ext_new.cpp`（8 个新控件）、`bridge_ext_wcore.cpp`、`bridge_ext_wtext.cpp`、`bridge_ext_wselect.cpp`、`bridge_ext_wrange.cpp`、`bridge_ext_wlayout.cpp`、`bridge_ext_wmisc.cpp`、`bridge_ext_views.cpp`，均已注册进 `CMakeLists.txt`。
- **回调类型**: `src/core/signal.cj` 新增 `Int32Int32Callback` / `BoolCallback` / `CStringInt32Callback` / `Int32BoolCallback` / `Int64Int32Callback`，供各控件信号复用。

### 修复

- **Qt 6.10.3 API 适配**: `QRegExpValidator` 在 Qt 6 已移除 → 改用 `QRegularExpressionValidator`；`QComboBox::setCurrentData` 本机不存在 → 改为 `findData()` + `setCurrentIndex()` 等价实现；`QListWidgetItem` / `QTableWidgetItem::setData` 参数顺序修正为 `(role, value)`。
- **QAbstractSlider protected 成员**: `repeatAction()` / `setRepeatAction()` 位于 protected 段，新增 `QScrollBarAccess` 子类经 `this` 访问；枚举 `RepeatAction` → `SliderAction`。
- **QRubberBand::setShape 不存在**: 改为 no-op（shape 仅构造时可指定），`setShape()` 调用保持链接兼容但不生效。
- **Cangjie 1.1.0 默认参数**: 删除 6 处 `name: Type = 默认值` 非法写法（zoomIn / zoomOut / setRenderHint / showMessage）。
- **链接顺序**: `scripts/rebuild_all.ps1` 将 bridge 重建（纯 C++）前置到 `cjpm build` 子包之前，避免子包链接时旧 DLL 缺新符号。

### 改进

- 全部 37 widgets + 9 views 的 API 广度与易用性显著提升；`examples/all_controls_demo` 第 8 页「新控件 v1.2.0」集成展示新增控件与 Model/View。

---

## [1.2.1] - 2026-07-22

### 修复

- **FFI 桥接库 (Windows) — Qt 6.10.3 加载兼容性**: 移除对 Qt 内部符号 `qt_qFindChild_helper` 的 import。`native/src/qml/bridge_qml.cpp` 中 `QQuickItem*` 的查找由 `QObject::findChild<>()` 改为手动递归遍历 `QObject::children()` + `qobject_cast<QQuickItem*>` + `objectName()` 匹配。Qt 6.10.3 运行时已不再导出该符号，旧 bridge DLL 在加载时会报"无法定位程序输入点 qt_qFindChild_helper"。
  - ⚠️ **修复后必须全量重编 bridge**: 仅删除 `cjqt6_bridge.dll` 只会触发 MSBuild 的增量 *relink*，不会重编已打补丁的 `bridge_qml.cpp`（stale 的 `.obj` 会被原样打进 DLL）。须删除整个 `native/build_windows/cjqt6_bridge.dir` 后再重新 cmake/msbuild。`scripts/build_bridge.bat` 已内置此强制全量重编。
- **示例运行时部署**: 新增 `examples/all_controls_demo/deploy_qt.ps1`，将 Qt6 运行时、平台插件(`qwindows`)、MSVC CRT(`vcruntime140`/`msvcp140`)、cjqt6 子包依赖 DLL 及原生 bridge DLL 一并拷入 `target/release/bin`，使示例运行时自包含，`cjpm run` 不再依赖 PATH 注入。

### 新增

- **Examples: all_controls_demo 第 8 页「新控件 v1.2.0」**: 集成展示 v1.2.0 新增的全部控件——QCommandLinkButton、QDialogButtonBox、QScrollBar、QSplashScreen、QSizeGrip、QRubberBand、QIntValidator/QDoubleValidator，以及 Model/View（QStandardItemModel + QListView / QTableView / QTreeView / QFileSystemModel / QHeaderView）。
- **构建脚本**: 新增 `scripts/rebuild_all.ps1`（一键清理 → `cjpm build` 子包 → 重编 bridge → `cjpm build` 示例 → 自包含部署）与 `scripts/build_bridge.bat`（MSVC + 当前 Qt 一键重编 bridge，自动探测 `vcvars64.bat` 与 Qt 路径，强制全量重编避免 stale 对象）。

### 文档

- `docs/build-guide.md` — 新增「一键重建脚本」章节，说明 `rebuild_all.ps1` / `build_bridge.bat` / `deploy_qt.ps1` 用法，并记录 Qt 6.10.3 bridge 重编与 `.bat` 须纯 ASCII（避免 GBK 代码页下中文注释导致 cmd 乱码）的坑。

---

## [1.2.0] - 2026-07-22

### Added

- **Widgets: QDialogButtonBox** - Dialog standard button box (OK/Cancel/Yes/No) with Accepted/Rejected signals
- **Widgets: QCommandLinkButton** - Vista-style command link button with title + description
- **Widgets: QScrollBar** - Standalone scrollbar (horizontal/vertical), value changed callback
- **Widgets: QSplashScreen** - Splash screen with pixmap and message display
- **Widgets: QSizeGrip** - Window resize grip corner widget
- **Widgets: QRubberBand** - Rubber band selection rectangle (Line/Rectangle shapes)
- **Widgets: Input Validators** - QIntValidator, QDoubleValidator with QLineEdit binding
- **Model/View Architecture** - QStandardItemModel, QListView, QTableView, QTreeView, QFileSystemModel, QHeaderView
- **Views: bridge_modelview.cpp** - C++ FFI bridge for all Model/View classes
- **Examples: widgets_demo_full** - Modular 5-tab demo (Basic/Selectors/Containers/New Widgets/Model-View)

### Changed

- **cjpm.toml** - DLL direct linking instead of .dll.a import library for Windows targets
- **views/tablewidget.cj** - Added qWidgetSetEnabled/qSignalCleanup FFI declarations


所有重要的变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
并遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.1.1] - 2026-07-20

### 变更

- **构建工具链**: Windows 编译工具链从 MinGW 切换为 MSVC 2022 (Qt 6.10.3 msvc2022_64)
- **FFI 桥接库**: `native/build_windows/` 构建输出改为 MSVC 风格的 `cjqt6_bridge.dll` + `.lib` (移除了 MinGW `lib` 前缀命名)
- **`cjpm.toml`**: 添加 `compile-option = "-L releases/windows-x64 -lcjqt6_bridge"` 使链接标志传播到所有子包
- **构建目录规范**: 统一使用平台专属构建目录名：`native/build_linux/`、`native/build_windows/`、`native/build_macos/`

### 修复

- **cjc 链接标志传播**: `link-option` 仅在主包生效，子包`--output-type=dylib` 链接失败。改用 `compile-option` 传递 `-L`/`-l`，所有 14 个子包编译通过
- **Windows 运行时**: MinGW 构建的 `libcjqt6_bridge.dll` 与 MSVC Cangjie 运行时 ABI 不兼容，切换后 DLL 加载正常

### 清理

- 删除旧 MinGW 构建目录 `build/`
- 删除 `native/.qt/` (CMake 过期产物)
- 移动根目录 `build_linux/` → `native/build_linux/`
- 重命名 `native/build/` → `native/build_windows/`
- 清理 `releases/windows-x64/` 中旧的 MinGW DLL (`libcjqt6_bridge.dll`)
- 文档中所有 MinGW 引用更新为 MSVC 或标记为交叉编译专用
- 全面清理 10+ 个文件中 `native/build/` 的旧路径引用，统一为平台专属目录

### 文档

- README.md — Windows 构建命令改为 MSVC 2022，DLL 命名更新
- releases/README.md — 重写（修复 GBK 编码损坏），更新为 MSVC 路径
- docs/build-guide.md — 所有 Windows 构建步骤更新为 MSVC 2022，构建目录路径统一
- docs/cross-compile.md — MSVC 设为首选，MinGW 降为备选
- scripts/setup-qt-env.ps1/sh — Qt 路径更新为 MSVC 2022
- scripts/update-bridge.ps1 — 构建目录和 DLL 命名与 MSVC 同步
- scripts/build-windows-x64.ps1 — 构建输出和 releases 同步更新
- docs/tutorial/01-quick-start.md — 构建目录路径更新
- docs/unwrapped-controls-analysis.md — 构建目录路径更新

## [1.1.0] - 2026-07-19

### 新增

**C++ 桥接层**
- `qCheckBoxCreate/SetText/Text/SetChecked/IsChecked/ConnectStateChanged/DisconnectStateChanged` — QCheckBox 完整 FFI
- `qRadioButtonCreate/SetText/Text/SetChecked/IsChecked/ConnectToggled/DisconnectToggled` — QRadioButton 完整 FFI
- `qComboBoxAddItems/InsertItem/SetItemText/SetCurrentText/FindText/SetPlaceholderText` — QComboBox 批量/搜索/占位文本 FFI
- `qComboBoxConnectCurrentTextChanged/DisconnectCurrentTextChanged` — QComboBox 文本变化信号
- `qSpinBoxSetPrefix/Prefix/SetSuffix/Suffix/SetWrapping/Wrapping/SetSpecialValueText/CleanText` — QSpinBox 格式化 FFI
- `qSliderSetSingleStep/SingleStep/SetPageStep/PageStep/SetTickPosition/TickPosition` — QSlider 步长/刻度 FFI
- `qSliderSetTickInterval/TickInterval/SetInvertedControls/InvertedControls/SetTracking/HasTracking` — QSlider 进阶属性 FFI
- `qSliderConnectSliderMoved/DisconnectSliderMoved/SetOnSliderPressed/SetOnSliderReleased` — QSlider 拖动/按下/释放信号
- `qSliderDeleteCleanup` — QSlider 清理辅助
- `qDialCreate/SetValue/Value/SetRange/SetSingleStep/SetWrapping/Wrapping/SetNotchesVisible/NotchesVisible/ConnectValueChanged/DisconnectValueChanged` — QDial 完整 FFI
- `qDoubleSpinBoxCreate/SetValue/Value/SetRange/SetSingleStep/SetDecimals/Decimals/ConnectValueChanged/DisconnectValueChanged` — QDoubleSpinBox 完整 FFI
- `qProgressBarCreate/SetValue/Value/SetRange/SetTextVisible/SetFormat/Format/SetOrientation/SetInvertedAppearance/Reset` — QProgressBar 完整 FFI
- `qLCDNumberCreate/CreateWithDigits/Display/DisplayInt/SetMode/Mode/SetSegmentStyle/SegmentStyle/SetSmallDecimalPoint/SmallDecimalPoint/DigitCount/SetDigitCount/CheckOverflow` — QLCDNumber 完整 FFI
- `qToolButtonCreate/SetText/SetIcon/SetIconSize/SetToolButtonStyle/SetPopupMode/SetAutoRaise/AutoRaise/SetArrowType/SetMenu/ShowMenu/ConnectClicked/DisconnectClicked` — QToolButton 完整 FFI
- `qFrameCreate/SetFrameShape/SetFrameShadow/SetLineWidth` — QFrame 容器 FFI
- `qScrollAreaCreate/SetWidget/SetWidgetResizable/Widget` — QScrollArea FFI
- `qTabWidgetSetTabText/TabText/SetTabToolTip/InsertTab/SetTabsClosable/SetMovable/Clear/ConnectCurrentChanged/DisconnectCurrentChanged` — QTabWidget 进阶 FFI
- `qGroupBoxSetTitle/Title/SetCheckable/IsCheckable/SetChecked/IsChecked` — QGroupBox 完整 FFI
- `qSplitterCreate/CreateHorizontal/CreateVertical/AddWidget/Count/Widget/SetStretchFactor/SetHandleWidth/HandleWidth/SetChildrenCollapsible/ChildrenCollapsible/SetOrientation/Orientation` — QSplitter 完整 FFI

**仓颉公开 API — 新控件类**
- `QCheckBox` — 复选框（含 text/setText/setChecked/isChecked/setEnabled/isEnabled/setStyleSheet/setMinimumSize/setMaximumSize/setOnStateChanged）
- `QRadioButton` — 单选按钮（含 text/setText/setChecked/isChecked/setEnabled/isEnabled/setStyleSheet/setMinimumSize/setMaximumSize/setOnToggled）
- `QDial` — 旋钮控件（含 value/setRange/setSingleStep/setWrapping/setNotchesVisible/setOnValueChanged）
- `QDoubleSpinBox` — 双精度旋转框（含 value/setRange/setSingleStep/setDecimals/setOnValueChanged）
- `QProgressBar` — 进度条（含 value/setRange/setFormat/setTextVisible/setOrientation/setInvertedAppearance/reset）
- `QLCDNumber` — LCD数字显示（含 display/displayInt/setMode/setSegmentStyle/digitCount/checkOverflow）
- `QToolButton` — 工具按钮（含 setIcon/setToolButtonStyle/setPopupMode/setAutoRaise/setArrowType/setMenu/setOnClick）
- `QGroupBox` — 分组框（含 setTitle/title/setCheckable/isCheckable/setChecked/isChecked/setLayout）
- `QTabWidget` — 标签页（含 addTab/removeTab/insertTab/setTabText/tabText/setTabToolTip/setTabsClosable/setMovable/clear/setOnCurrentChanged）
- `QScrollArea` — 滚动区域（含 setWidget/setWidgetResizable/widget）
- `QFrame` — 边框容器（含 setFrameShape/setFrameShadow/setLineWidth/setLayout）
- `QSplitter` — 分割器（含 createHorizontal/createVertical/addWidget/setStretchFactor/setHandleWidth/setChildrenCollapsible/setOrientation）

**仓颉公开 API — 已有控件补齐方法**
- `QCheckBox` — 新增 `text()`, `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()`
- `QRadioButton` — 新增 `text()`, `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()`
- `QComboBox` — 新增 `addItems()`, `insertItem()`, `setItemText()`, `setCurrentText()`, `findText()`, `setPlaceholderText()`, `count()`, `itemText()`, `setEditable()`, `removeItem()`, `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()`, `setOnCurrentTextChanged()`
- `QSpinBox` — 新增 `setPrefix()`, `prefix()`, `setSuffix()`, `suffix()`, `setWrapping()`, `wrapping()`, `setSpecialValueText()`, `cleanText()`, `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()`, QtResource (`close()`/`isClosed()`/`isValid()`/`checkValid()`)
- `QSlider` — 新增 `setSingleStep()`, `singleStep()`, `setPageStep()`, `pageStep()`, `setTickPosition()`, `tickPosition()`, `setTickInterval()`, `tickInterval()`, `setInvertedControls()`, `invertedControls()`, `setTracking()`, `hasTracking()`, `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()`, `setOnSliderMoved()`, `setOnSliderPressed()`, `setOnSliderReleased()`
- `QProgressBar` — 新增 `setFormat()`, `format()`, `setOrientation()`, `setInvertedAppearance()`, `reset()`, `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()`
- `QTabWidget` — 新增 `setTabText()`, `tabText()`, `setTabToolTip()`, `insertTab()`, `setTabsClosable()`, `setMovable()`, `clear()`, `setOnCurrentChanged()`, `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()`
- `QGroupBox` — 新增 `title()`, `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()`
- `QScrollArea` — 新增 `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()`
- `QFrame` — 新增 `setLayout()`, `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()`
- `QToolButton` — 新增 `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()`
- `QLCDNumber` — 新增 `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()`
- `QPushButton` — 新增 `text()`, `setCheckable()`, `setChecked()`, `isChecked()`, `setDefault()`, `setFlat()`, `setEnabled()`, `isEnabled()`, `setStyleSheet()`, QtResource (`close()`/`isClosed()`/`isValid()`/`checkValid()`)

**新模块文件**
- `src/widgets/` — checkbox.cj, radiobutton.cj, combobox.cj (扩展), spinbox.cj (重写), doublespinbox.cj, slider.cj (扩展), progressbar.cj, dial.cj, lcdnumber.cj, toolbutton.cj, containers.cj (分组框/标签页/滚动区域/边框/分割器), textedit.cj

### 修复
- **cjpm.toml link-option 平台隔离**: 将默认 `link-option = "releases/windows-x64/libcjqt6_bridge.dll.a"` 移入 `[target.x86_64-pc-windows-msvc]` 平台作用域，消除 Linux 构建时错误链接 Windows 库的问题
- **Linux (WSL) cjpm build 恢复**: 修复后 Linux x86_64 在 WSL Ubuntu 24.04 上 `cjpm build` 通过，全部 13 个包编译成功

### 改进
- 所有基础控件现已统一补齐 `setEnabled/isEnabled`、`setStyleSheet`、`setMinimumSize/setMaximumSize`
- 构建系统: cjpm.toml 链接方式改为直接路径 (releases/windows-x64/libcjqt6_bridge.dll.a)
- 构建系统: cjpm.toml 平台特定链接选项迁移到 `[target.xxx]` 分段，Windows 和 Linux 各自独立
- 发布目录 releases/ 加入 cjpm include 列表，确保 DLL 随包分发
- 原生桥接层: cmake --clean-first 重建所有 bridge 源文件
- **Linux x86_64 原生桥接库**: 在 WSL Ubuntu 24.04 / GCC 13.3 编译 `libcjqt6_bridge.so` (1.16 MB) 并部署到 `releases/linux-x64/`

### 文档
- 更新 api-completeness.md 反映新增 API 后的覆盖度评估
- 更新 03_widgets_selection.md、04_containers_layout.md、16_misc_widgets.md、02_widgets_basic.md 补齐新增方法

---

## [1.0.2] - 2026-07-18

### 新增

**C++ 桥接层**
- `qVBoxLayoutAddWidgetStretch` / `qHBoxLayoutAddWidgetStretch` — 布局 addWidget 支持 stretch 权重参数
- `qWidgetSetEnabled` / `qWidgetIsEnabled` — 控件启用/禁用
- `qWidgetSetMinimumSize` / `qWidgetSetMaximumSize` — 控件最小/最大尺寸约束
- `qWidgetSetVisible` / `qWidgetIsVisible` — 控件可见性控制
- `qWidgetSetToolTip` — 控件工具提示
- `qWidgetSetStyleSheet` — 控件级样式表

**仓颉公开 API**
- `QVBoxLayout.addWidget(ptr, stretch)` / `QHBoxLayout.addWidget(ptr, stretch)` — 带权重的 addWidget 重载
- `QLabel.setStyleSheet()` — 标签样式表
- `QPushButton.setEnabled()` / `isEnabled()` — 按钮开关控制
- `QTabWidget.setMinimumSize()` / `QTextEdit.setMinimumSize()` / `QPlainTextEdit.setMinimumSize()`
- `QTextBrowser.setMinimumSize()` / `QToolBox.setMinimumSize()` / `QFontComboBox.getPtr()`
- `QTableView` / `QListWidget` / `QTreeWidget` — 补充 setMinimumSize/setMaximumSize/setStyleSheet

**新模块文件**
- `src/core/` — clipboard, desktopservices, filewatcher, propertyanimation, screen, settings, shortcut, standardpaths
- `src/widgets/` — buttongroup, completer, dockwidget, fontcombobox, graphiceffect, graphicsview, keysequenceedit, mdiarea, plaintextedit, stackedwidget, systemtrayicon, textbrowser, toolbox
- `src/multimedia/soundeffect.cj`
- `src/paint/fontdb.cj`

**示例程序**
- `examples/all_controls_demo/` — 全控件演示示例（7 分类页面 + 侧边栏导航），覆盖基础控件、文本输入、数值控件、选择控件、容器布局、高级控件、对话框

### 改进
- 布局系统支持 stretch 权重，解决状态栏占窗口一半高度的问题
- Linux x86_64 bridge 在 WSL Ubuntu 24.04 / Qt 6.4.2 / GCC 13.3 编译验证通过
- `.gitignore` 排除 `build_linux/`，保留 releases/ 下 .so/.dll/.dll.a

### 已知问题
- QML 模块 `load/loadData()` 在仓颉运行时卡住（2026-03-20 已记录）
- `cjpm run` 在新终端需要手动设 PATH 或重启终端

---

## [1.0.1] - 2026-07-17

### 新增

**C++ 桥接层**
- `qWidgetSetParent` — 设置控件父窗口，支持绝对坐标独立布局
- `qWidgetMove`、`qWidgetX`、`qWidgetY` — 控件位置查询与移动
- `qWidgetSetFixedSize` — 固定控件尺寸
- `qWidgetSetWindowIcon` — 窗口图标设置
- `qLabelText` — QLabel 文本获取
- `qLabelSetWordWrap`、`qLabelWordWrap` — QLabel 自动换行
- `qButtonSetCheckable`、`qButtonSetChecked`、`qButtonIsChecked` — QPushButton 开关模式
- `qButtonSetDefault`、`qButtonSetFlat` — QPushButton 外观选项
- `qComboBoxCount`、`qComboBoxItemText` — QComboBox 列表查询
- `qComboBoxSetEditable`、`qComboBoxRemoveItem` — QComboBox 编辑与删除

**仓颉公开 API**
- `QWidget.setGeometry()` / `move()` / `x()` / `y()` / `setFixedSize()` / `setWindowIcon()`
- `setWidgetGeometry()` / `setWidgetParent()` — 对任意控件设置几何与父窗口
- `QLabel.text()` / `setWordWrap()` / `wordWrap()`
- `QPushButton.setCheckable()` / `setChecked()` / `isChecked()` / `setDefault()` / `setFlat()`
- `QComboBox.count()` / `itemText()` / `setEditable()` / `removeItem()`

**工具链**
- `scripts/update-bridge.ps1` — 一键重编译 bridge 并同步到 releases 目录
- 用户 PATH 环境变量支持

### 改进
- README 中 Qt/DLL 路径改为 `/path/to/` 通用占位符
- `Alignment` 冲突问题解决

### 已知问题
- QML 模块 `load/loadData()` 在仓颉运行时卡住（2026-03-20 已记录）
- `cjpm run` 在新终端需要手动设 PATH 或重启终端
- 缺少 `setFont` 等高级属性方法（下一版本计划）

---

## [1.0.0] - 2026-05-07

### 新增

- 支持 Linux x86_64、Windows x86_64、macOS x86_64/arm64 多平台
- 15 个模块：core、widgets、gui、dialogs、menu、views、paint、process、qml、multimedia、sql、print、resource、network
- 100+ 控件/类封装
- Qt6 信号槽机制（12 对 connect/disconnect，5 种回调类型）
- 资源管理接口（QtResource + try-with-resources + 异常层级）
- 11 个可编译示例程序（计算器、记事本、绘图、音乐播放器、贪吃蛇、坦克大战等）

---

## 版本说明

- **主版本号 (MAJOR)**: 不兼容的 API 变更
- **次版本号 (MINOR)**: 向后兼容的功能新增
- **修订号 (PATCH)**: 向后兼容的问题修复