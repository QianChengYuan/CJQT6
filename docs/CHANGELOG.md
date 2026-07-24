# 更新日志
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
- 首次发布到仓颉中心仓
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