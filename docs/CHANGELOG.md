# 更新日志

所有重要的变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
并遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

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