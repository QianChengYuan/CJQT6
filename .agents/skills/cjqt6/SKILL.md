---
name: cjqt6
description: "CJQT6 —— 仓颉(Cangjie)语言的 Qt6 封装库。当用户需要用仓颉开发 Qt6 GUI 应用、使用 cjqt6.* 包（控件/布局/信号槽/绘图/对话框/多媒体/网络/SQL）、构建 FFI 桥接库(cjqt6_bridge)、或处理 Qt 对象内存管理时，应使用此 Skill。"
---

# CJQT6 仓颉 Qt6 封装库 Skill

## 1. 库定位与何时使用

CJQT6 通过 FFI 桥接技术，把 Qt6 的 C++ API 封装成仓颉原生 API 风格（`cjqt6.*` 包），让仓颉开发者像 PyQt/PySide 一样写 GUI。

**触发场景**：
- 用仓颉写桌面 GUI（窗口、按钮、输入、布局、菜单、对话框）
- 使用 `cjqt6.core` / `cjqt6.widgets` / `cjqt6.gui` 等任一子包
- 连接 Qt 信号槽（按钮点击、文本变化、值变化等回调）
- 构建/部署 `cjqt6_bridge` 原生桥接库、解决 `cjpm build` 链接错误
- 排查 Qt 对象内存泄漏 / 悬垂指针 / 终结器崩溃

**当前版本**：1.9.0（2026-08-31）
**远程仓库（权威源）**：`https://gitcode.com/yuan_1992/CJQT6.git`（主页 `https://gitcode.com/yuan_1992/CJQT6`，Issue 反馈同页）
**本机克隆路径**（因机器而异，下文用 `<仓库根>` 指代）：`C:\CodeTools\cangjie_git\CJQT6`
**源码根**：`<仓库根>/src`
**API 文档**：`<仓库根>/docs/api/`（01_core.md ~ 20_charts.md + INDEX.md + README.md，已覆盖全部公开类 100%）

---

## 2. 模块地图（import 什么）

所有类型都在 `cjqt6` 根包下分模块。代码里用 `import cjqt6.<module>.*`：

| 模块 | 包名 | 主要内容 |
|------|------|---------|
| 核心 | `cjqt6.core` | `QApplication`/`QApp`（含全局 QSS `setStyleSheet`/`QLocale`）、`QWidget`、`QUiLoader`（加载 Qt Designer .ui）、`QTimer`、`QThread`/`QThreadPool`、`QSettings`、`QShortcut`、`QPropertyAnimation`、`QUndoStack`、`QJsonValue/Object/Array/Document`、`QItemSelectionModel`、`QFileSystemWatcher`、`QStandardPaths`、`QDesktopServices`、`QClipboard`、`QScreen`、`QProcess`、`QMimeData`/`QDrag`、`SignalEmitter`、`UiPoster`（UI 线程投递）、对象存活表 `trackObject`/`untrackObject`/`isObjectAlive`、`freeBridgeString`、信号常量与回调类型、`QtResource` 接口、异常类 |
| 控件 | `cjqt6.widgets` | `QLabel`、`QPushButton`、`QLineEdit`、`QTextEdit`、`QCheckBox`、`QRadioButton`、`QComboBox`、`QSlider`、`QSpinBox`、`QProgressBar`、`QGroupBox`/`QTabWidget`/`QScrollArea`/`QSplitter`、`QDockWidget`、`QMdiArea`、`QSystemTrayIcon`、`QGraphicsView`/`QGraphicsItem` 系列、日期/时间控件等（39 个文件） |
| 图形/布局 | `cjqt6.gui` | `QVBoxLayout`/`QHBoxLayout`/`QGridLayout`/`QFormLayout`、`Alignment`/`Orientation`/`Margins`、`QCursor`、`QPalette`、`QIcon`、`QFontMetrics`/`QFontInfo`、`QStyleHelper`、`QSyntaxHighlighter`、`QTextDocument`/`QTextCursor` |
| 对话框 | `cjqt6.dialogs` | `QMessageBox`、`QFileDialog`、`QInputDialog`、`QColorDialog`、`QFontDialog`、`QProgressDialog`、`QWizard`/`QWizardPage`、`QErrorMessage` |
| 菜单 | `cjqt6.menu` | `QMainWindow`、`QMenu`/`QMenuBar`、`QToolBar`、`QStatusBar`、`QAction` |
| 绘图 | `cjqt6.paint` | `QPainter`、`QPen`、`QBrush`、`QColor`、`QFont`、`QTransform`、`QPainterPath`、`QPixmap`/`QImage`、渐变、`QFontDatabase` |
| QML | `cjqt6.qml` | `QQmlApplicationEngine`、`QQuickView`/`QQuickWidget`/`QQuickItem` |
| 多媒体 | `cjqt6.multimedia` | `QMediaPlayer`、`QAudioOutput`、`QSoundEffect`、`QCamera`、`QImageCapture`、`QVideoWidget` |
| 网络 | `cjqt6.network` | `QTcpSocket`、`QTcpServer`、`QUdpSocket`、`QHostAddress`、`QNetworkAccessManager`/`QNetworkRequest`/`QNetworkReply`、`QSslSocket`、`QLocalServer`、`QNetworkProxy` |
| 数据库 | `cjqt6.sql` | `QSqlDatabase`、`QSqlQuery`、`QSqlTableModel` |
| 视图 | `cjqt6.views` | `QListView`/`QTableView`/`QTreeView`/`QTableWidget`/`QTreeWidget`/`QListWidget`、`QAbstractItemModel`、`QStandardItemModel`、`QSortFilterProxyModel`、`QFileSystemModel`、`QHeaderView` |
| 打印 | `cjqt6.print` | `QPrinter`、`QPrintDialog`/`QPrintPreviewDialog` |
| 资源 | `cjqt6.resource` | 资源容器、作用域管理器（RAII 辅助）、`ResourceUtils` |
| 图表 | `cjqt6.charts` | `QChart`/`QChartView`、折线/柱状/饼图/散点/面积/样条/百分比/堆叠/箱线/蜡烛图等系列、坐标轴（`QValueAxis`/`QBarCategoryAxis`/`QCategoryAxis`/`QDateTimeAxis`/`QLogValueAxis`）、`QLegend` |

> 最小示例里通常 import：`cjqt6.core.*`、`cjqt6.widgets.*`、`cjqt6.gui.*`。

---

## 3. 核心设计模式（必读）

### 3.1 封装结构
每个 Qt 对象封装成一个仓颉 class，**持有原生指针 `ptr: Int64`**，对外方法内部 `unsafe` 调用 `foreign func`：
```
public class QLabel <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    public init() { unsafe { ptr = qLabelCreate(); if (ptr == 0) { throw CreateFailedException(...) } } }
    public func setText(text: String): Unit { checkValid(); unsafe { let c = LibC.mallocCString(text); qLabelSetText(ptr, c); LibC.free(c) } }
    public func getPtr(): Int64 { ptr }
}
```
- 取原生指针用 `getPtr(): Int64`（布局/父子关系需要传指针）。
- 构造失败会抛 `CreateFailedException`。

### 3.2 应用生命周期
```
import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

main(): Int32 {
    let app = QApplication()          // 必须最先创建
    let window = QWidget()
    window.setTitle("Hello CJQT6")
    window.resize(400, 300)
    let label = QLabel()
    label.setText("欢迎使用 CJQT6!")
    label.setAlignment(Alignment.Center.value)   // 注意：传 Int32 值
    window.show()
    app.exec()                         // 进入事件循环，阻塞
    0
}
```
- `QApplication` 必须在任何 widget 之前创建。
- 关闭窗口后 `app.exec()` 返回；调用 `QApp.quit()` 可主动退出。

### 3.3 布局（关键约定）
布局类在 `cjqt6.gui`，**`addWidget` / `addLayout` 接收的是原生指针 `Int64`，不是对象本身**：
```
let vbox = QVBoxLayout()
vbox.setSpacing(8)
vbox.setMargin(15)
vbox.addWidget(label.getPtr())         // 传指针！
let hbox = QHBoxLayout()
hbox.addWidget(btn1.getPtr())
vbox.addLayout(hbox.getPtr())          // 嵌套布局也要传指针
window.setLayout(vbox.getPtr())        // QWidget.setLayout(layoutPtr: Int64)
```
- `QGridLayout`：`addWidget(ptr, row, col)` / `addWidget(ptr, row, col, rowSpan, colSpan)`。
- `addStretch()` 占位；`addWidget(ptr, stretch: Int32)` 可设伸缩因子。

### 3.4 对齐方式
对齐在 `cjqt6.gui` 定义为 `Alignment` 结构体（可组合位标志），`setAlignment` 参数类型是 `Int32`，因此要传 `.value`：
```
label.setAlignment(Alignment.Center.value)              // 居中
label.setAlignment((Alignment.Left | Alignment.VCenter).value)  // 组合，用 | 运算符
```
可用常量：`Alignment.Left/Right/HCenter/Top/Bottom/VCenter/Center/TopLeft/...`。

### 3.5 信号与槽（事件回调）
回调类型别名在 `cjqt6.core.signal` 定义为 `CFunc<...>`：
`VoidCallback`(`() -> Unit`)、`Int32Callback`(`(Int32) -> Unit`)、`Int64Callback`、`Float64Callback`、`CStringCallback`(`(CString) -> Unit`)、`Int32Int32Callback`、`Int64Int32Callback`、`BoolCallback`、`CStringInt32Callback`、`Int32BoolCallback`。

**连接模式**：把回调定义成顶层 `let` 绑定（CFunc 不适合捕获复杂环境，建议通过全局 `?T` 变量访问控件状态），再传给 `setOnXxx`：
```
import cjqt6.core.*

var infoLabel: ?QLabel = None

let onButtonClick: VoidCallback = { =>
    if (let Some(l) <- infoLabel) { l.setText("被点击了") }
}
let onTextChanged: CStringCallback = { text: CString =>
    if (let Some(l) <- infoLabel) { l.setText("输入: ${text.toString()}") }
}
let onSliderChanged: Int32Callback = { value: Int32 =>
    if (let Some(l) <- infoLabel) { l.setText("值: ${value}") }
}

main(): Int32 {
    ...
    let btn = QPushButton()
    btn.setText("点我")
    btn.setOnClick(onButtonClick)         // 连接 clicked
    let edit = QLineEdit()
    edit.setOnTextChanged(onTextChanged)  // 连接 textChanged
    let slider = QSlider()
    slider.setOnValueChanged(onSliderChanged)
    0
}
```
各控件常用连接方法（源文件已确认）：
- `QPushButton`：`setOnClick(VoidCallback)` / `disconnectClick()`；可勾选：`setOnClickedChecked(Int32Callback)`、`setOnClickChecked(Int32Callback)`
- `QLineEdit`：`setOnTextChanged(CStringCallback)`、`setOnEditingFinished(VoidCallback)`
- `QSpinBox`：`setOnValueChanged(Int32Callback)`；`QDoubleSpinBox` 用 `Float64Callback`
- `QSlider`：`setOnValueChanged(Int32Callback)`、`setOnSliderMoved(Int32Callback)`
- `QCheckBox`：`setOnStateChanged(Int32Callback)`（state：0=未选，1=半选，2=选中）
- `QRadioButton`：`setOnToggled(Int32Callback)`（checked=1）
- `QComboBox`：`setOnCurrentIndexChanged(Int32Callback)`、`setOnCurrentTextChanged(CStringCallback)`
- `QTimer`(core/timer.cj)：`setOnTimeout(VoidCallback)`
- `QThread`/`QProcess`：`setOnFinished(...)`；`QProcess` 还有 `setOnErrorOccurred(Int32Callback)`
- 视图类（views）：`QListWidget.setOnItemClicked(CFunc<(Int32) -> Unit>)`（传行号）；`QTableWidget`/`QTreeWidget` 的 `setOnItemClicked` 传 `CFunc<(Int64) -> Unit>`（传 item 指针）、`setOnCellChanged(CFunc<(Int32, Int32) -> Unit>)` 等
- 信号常量字符串：`SIGNAL_CLICKED`/`SIGNAL_TEXT_CHANGED`/`SIGNAL_VALUE_CHANGED`/`SIGNAL_TIMEOUT` 等（多数场景直接用上面的 `setOnXxx` 方法即可）

> **`SignalConnection`**（`core/signal.cj`）：部分 `setOnXxx` 方法返回 `SignalConnection` 对象，可调用 `.disconnect()` 手动断开（如 `setOnClickCapture`、`setOnClickedChecked`、`setOnDouble`、`setOnInt` 等带 capture/命名连接的场景）。

> 注意 `CString` 回调：Qt 返回的 CString 由桥接层管理，回调内用 `.toString()` 立即转为仓颉 `String`，不要长期持有 CString。

### 3.7 跨线程与 UI 更新（UiPoster）
工作线程不能直接碰 UI。用 `cjqt6.core` 的 `UiPoster`（桥接层单例）把回调投递到 UI 线程执行：
```
UiPoster.runOnUiThread({ => label.setText("后台完成") })
```
回调可以捕获局部变量（它不是 `CFunc`，由桥接层在 UI 线程代为执行）。

### 3.8 对象存活表（反向失效通知）
桥接层维护 native 存活表：Qt 对象在 C++ 侧被析构（如父对象级联析构）时会反向标记失效。仓颉侧可查询：
```
trackObject(ptr)      // 封装类内部注册
untrackObject(ptr)    // close 时注销
isObjectAlive(ptr)    // 查询指针是否仍有效，级联析构场景防悬垂/double-free
```
（均在 `src/core/cstring_utils.cj` 导出。）

### 3.9 其他常用入口
- 全局 QSS：`QApp.setStyleSheet("QPushButton { color: red; }")` / `QApp.styleSheet()`。
- 加载 Qt Designer `.ui` 文件：`QUiLoader`（`src/core/widget.cj` 同目录，见 `src/test/uiloader_test.cj`）。
- 字符串返回释放：桥接字符串返回统一走 bridge 自持释放（修复 Windows CRT 堆不匹配崩溃），仓颉侧用完调 `freeBridgeString(c)`（见 `src/core/cstring_utils.cj`）。
- 信号连接稳定性：桥接层在对象 `delete` 时清理全部 86 个静态信号回调 map，避免控件复用指针时 connect 偶发失效——若回调"偶发不触发"，先确认桥接库是最新重编的。

### 3.6 对话框
`cjqt6.dialogs`：
```
let path = QFileDialog.getOpenFileName(parentPtr, "打开文件", "文本文件 (*.txt);;所有文件 (*)")
let ok = QMessageBox.question(parentPtr, "确认", "保存吗？")   // 返回 Bool
QMessageBox.critical(parentPtr, "错误", "出错了")
QMessageBox.information(parentPtr, "提示", "完成")
```
`parentPtr` 传父窗口 `getPtr()`，没有则传 `0`。

---

## 4. 内存管理（最重要，坑最多）

- 所有 Qt 封装类实现 `QtResource` 接口：`isClosed()`、`close()`、`getPtr()`、`isValid()`、`checkValid()`。
- **必须显式释放**：用完调用 `close()`（或兼容别名 `delete()`）释放底层 Qt 对象。**不要依赖 GC / 终结器**——源码中终结器（`~init`）已被刻意注释禁用，因为 GC 回收时机不确定，可能在 Qt 对象仍被使用时删除导致崩溃。
- 释放后再次调用方法会抛 `ResourceDisposedException`（`checkValid()` 守卫）。
- 可用 `cjqt6.resource` 下的作用域管理器做 RAII 风格自动释放（详见 `src/resource/`）。
- 跨函数传递 Qt 对象时用 `getPtr()` 拿原生指针；持有对象引用时保证其生命周期覆盖使用期。

---

## 5. 构建与运行（Windows 为主，用户本机环境）

仓颉编译器 1.1.0、Qt6(>=6.2)、CMake(>=3.16)。两步：**先构建 C++ 桥接库，再 `cjpm build`**。

### 5.1 构建 FFI 桥接库（cjqt6_bridge）
```powershell
# 方式1（推荐）：一键脚本，自动探测 Qt 路径
.\scripts\update-bridge.ps1              # 自动用 $env:QTDIR 或常见路径
.\scripts\update-bridge.ps1 -QtDir "C:\Qt\6.10.3\msvc2022_64"   # 手动指定

# 方式2：手动步骤
# 设置 Qt6 路径（替换为实际路径）
$env:QTDIR = "C:\Qt\6.10.3\msvc2022_64"

# 构建（MSVC 2022 x64）
New-Item -ItemType Directory -Force -Path native\build_windows_x64
cd native\build_windows_x64
cmake ..\.. -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="$env:QTDIR"
cmake --build . --config Release
cd ..\..

# 部署桥接库到 releases/（cjpm build 链接用）
Copy-Item native\build_windows_x64\bin\cjqt6_bridge.dll releases\windows-x64\ -Force
Copy-Item native\build_windows_x64\lib\cjqt6_bridge.lib releases\windows-x64\ -Force
```
> ⚠️ **增量构建陷阱**：`native\build_windows_x64` 有 CMake 缓存时，`cmake --build` 可能判定"已是最新"跳过实际链接（产物时间戳不变）。**需要确保重新编译时**用：
> ```powershell
> cmake --build native\build_windows_x64 --config Release --clean-first
> # 或删除缓存目录后重来：
> Remove-Item -Recurse -Force native\build_windows_x64
> ```
>
> **Linux（含 WSL）**：在仓库根目录执行
> ```bash
> bash scripts/build-linux-x64.sh        # 自动探测 /usr/lib/qt6 等，产物部署到 releases/linux-x64/
> # 手动方式：
> mkdir -p native/build-linux-x64 && cd native/build-linux-x64
> cmake ../.. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/usr/lib/qt6
> make -j$(nproc)
> cp lib/libcjqt6_bridge.so ../../releases/linux-x64/
> ```

### 5.2 构建仓颉项目
```powershell
cjpm build
```
- `cjpm.toml` 已配置各平台 `link-option`：Windows 用 `releases/windows-x64/cjqt6_bridge.lib`（MSVC）/ `.dll`（MinGW），Linux 用 `-Lreleases/linux-x64 -lcjqt6_bridge`。
- 常见链接错误 `cannot find -lcjqt6_bridge` → 桥接库没构建/没部署到 `releases/`，回到 5.1。
- 全量重建脚本：`.\scripts\rebuild_all.ps1`（先桥接库后 cjpm + 可选示例，`-Example dormitory_manager` 指定示例，`-SkipExample` 跳过）。
- **工程治理门禁**（提交前建议跑）：
  - `.\scripts\verify_all.ps1` — 一键全量门禁（构建+测试，自动注入 `CJQT6_ROOT`）。
  - `.\scripts\run-test.ps1` / `run-test.sh` — 跑根包测试。
  - `.\scripts\check-coverage.ps1` — 覆盖率门禁（当前基线约 79%）。
  - `.\scripts\check-release.ps1` — 发布物检查；`.\scripts\gen-api-index.ps1` — 重新生成 `docs/api/INDEX.md`。
  - `.\scripts\build-native-tests.ps1/.sh` — 桥接层 C++ 单测（CI 也跑）。
- **配套工具**（`tools/` 下独立 cjpm 工程）：
  - `tools/ui2cj` — Qt Designer `.ui` 文件转仓颉代码（无工程时自动生成最小可运行工程）；入口脚本 `scripts/gen-ui.ps1`。
  - `tools/cjqt6-diagnose` — 环境诊断。

### 5.3 运行（需要 Qt6 运行时 DLL）
```powershell
# 方式1：配置 Qt 环境
.\scripts\setup-qt-env.ps1
cjpm run

# 方式2：手动把 Qt6 bin 加入 PATH
$env:PATH = "C:\Qt\6.10.3\msvc2022_64\bin;$env:PATH"
cjpm run

# 方式3：windeployqt 把 Qt DLL 复制到 exe 目录（发布用）
C:\Qt\6.10.3\msvc2022_64\bin\windeployqt.exe examples\notepad\target\release\bin\main.exe
```
- 运行示例：`cd examples/notepad && cjpm run`。
- 完整错误诊断见 `docs/guides/build-guide.md`。

---

## 6. 仓颉 1.1.0 与 FFI 相关约束（写 CJQT6 代码必须遵守）

- **`unsafe` 块**：所有 `foreign func` 调用必须包在 `unsafe { }` 内（库内方法已包好，用户自定义 FFI 时要自己包）。
- **字符串与 CString**：传给 FFI 的字符串用 `LibC.mallocCString(s)` 分配，用完 `LibC.free(c)`；用 `.toString()` 把 FFI 返回的 `CString` 转仓颉字符串。**不要让 CString 长期存活/逃逸**。
- **无三元运算符**：用 `if/else` 表达式替代。
- **默认参数仅支持命名参数**：`p!: T = 默认值` 才可带默认值；非命名参数无默认值——库中可选参数用重载实现（如 `addWidget(ptr)` 与 `addWidget(ptr, stretch)`）。
- **`match` 分支体不能使用 `{}` 包裹**：`case x =>` 后可直接跟 1~N 行 exprs（每行一个表达式，各占一行），分支值取最后一行表达式的值。
- **`Int64` 作哈希键**：若用 `Int64`(如 `ptr`) 当 Map key，需 `& 0x3FFFFFFF` 位掩码。
- **`ArrayList`**：用 `.add()` 添加、`.size` 取长度（不是 `push`/`length`）。
- **`open class` 构造器内不能用 `this`**。
- **无运行时反射**：不能用字符串动态调用方法，控件类型需静态已知。

---

## 7. 常见陷阱速查

| 现象 | 原因 / 解决 |
|------|------------|
| 程序崩溃 / 双击无反应 | 没部署 Qt6 DLL 到运行时 PATH，或没 `windeployqt`；先 `setup-qt-env.ps1` |
| `cannot find -lcjqt6_bridge` | 桥接库未构建或未拷到 `releases/` → 重做 5.1 |
| 桥接库改了代码但运行没变化 | 增量构建跳过链接 → 用 `cmake --build . --clean-first` 或删 `native\build_windows_x64` 重来 |
| 回调不触发 | 信号连接方法名写错（用 `setOnClick` 而非 `connect`）；`CFunc` 闭包捕获问题 → 改顶层 `let` + 全局 `?T` 变量；桥接库非最新（旧版 delete 不清回调 map，控件指针复用时偶发失效）→ `--clean-first` 重编 |
| 级联析构崩溃 / double-free | 父对象析构连带删除子对象，仓颉侧再 `close()`；用 `isObjectAlive(ptr)` 先检查，封装类已内置 track/untrack |
| 控件不显示 / 布局错乱 | `addWidget` 忘了 `.getPtr()`；窗口没 `setLayout`；没 `window.show()` |
| 文本对齐无效 | `setAlignment` 要传 `Alignment.Center.value`（Int32），不是 `Alignment.Center` 对象 |
| 悬垂指针崩溃 | 父控件 `close()` 后子控件指针失效；Qt 对象别依赖 GC，显式 `close()` 且保证使用期 |
| `ResourceDisposedException` | 对已 `close()` 的对象再调用方法 |

---

## 8. 深入查阅指引（按需 Read 这些源码/文档）

- 信号机制与回调类型：`src/core/signal.cj`（含 `SignalConnection`）、`src/core/emitter.cj`
- 资源管理接口与异常：`src/core/resource.cj`；对象存活表与桥接字符串释放：`src/core/cstring_utils.cj`
- UI 线程投递：`src/core/uiposter.cj`；Qt Designer 加载：`src/test/uiloader_test.cj`
- TCP 服务器（多客户端聊天范式）：`src/network/tcp_server.cj`、`examples/qq_chat_lan/`
- 控件实现范式（任选）：`src/widgets/label.cj`、`pushbutton.cj`、`lineedit.cj`、`slider.cj`
- 布局实现：`src/gui/layout.cj`、类型定义 `src/gui/types.cj`
- 图形/文本：`src/gui/textdoc.cj`（QTextDocument/QTextCursor）、`src/gui/syntaxhighlighter.cj`
- 线程：`src/core/thread.cj`（QThread/QThreadPool）、进程：`src/core/process.cj`、设置：`src/core/settings.cj`
- 网络：`src/network/`（tcp_socket/udp_socket/network_access/ssl_socket/localserver）
- 多媒体：`src/multimedia/`（mediaplayer/camera/imagecapture/videowidget）
- 完整示例：`examples/all_controls_demo/src/main.cj`（控件+信号全集）、`examples/notepad/src/main.cj`（菜单/对话框/打印完整 App）、`examples/dormitory_manager/src/main.cj`（宿舍管理完整业务 App）
- API 文档：`docs/api/01_core.md`、`02_widgets_basic.md`、`04_containers_layout.md`、`05_views.md`、`12_signal_slot.md`、`15_examples_faq.md`
- 资源管理指南：`docs/resource/scope-manager-guide.md`、`docs/resource/resource-utils-guide.md`
- 构建细节：`docs/guides/build-guide.md`、`README.md`、`cjpm.toml`

> 写新控件/排查问题时，先 Read 同模块已有 `.cj` 文件作为范式（foreign 声明 + 封装 class + `checkValid` 守卫 + `close` 释放），保持风格一致。
