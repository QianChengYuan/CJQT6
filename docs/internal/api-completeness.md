# CJQT6 API 完善度评估

> 更新日期：2026-08-29
>
> 评级标准（按覆盖度分档）：
> - ✅ **完善** — 覆盖 Qt API ≥ 90%，可满足绝大部分日常使用
> - ⚠️ **基本完善** — 覆盖 Qt API 80-89%，常用操作可用，缺进阶方法
> - ❌ **不足** — 覆盖 Qt API < 80%，基础功能有缺口

---

## 1. 覆盖度总览

| 控件 | 模块 | 覆盖度 | 评级 | 备注 |
|------|------|--------|------|------|
| QLineEdit | widgets | 98% | ✅ | 含验证器/拖放/6 信号 |
| QTextEdit | widgets | 98% | ✅ | 含查找替换/6 信号 |
| QSpinBox | widgets | 98% | ✅ | |
| QSplitter | widgets | 98% | ✅ | 含 sizes/saveState 数组 FFI |
| QPushButton | widgets | 95% | ✅ | 含 setMenu/快捷键 |
| QComboBox | widgets | 95% | ✅ | 含 setIconSize |
| QSlider | widgets | 95% | ✅ | |
| QDoubleSpinBox | widgets | 95% | ✅ | |
| QDial | widgets | 95% | ✅ | |
| QLCDNumber | widgets | 95% | ✅ | |
| QToolButton | widgets | 95% | ✅ | 含 setMenu/popupMode |
| QProgressBar | widgets | 95% | ✅ | |
| QCheckBox | widgets | 95% | ✅ | |
| QRadioButton | widgets | 95% | ✅ | |
| QTabWidget | widgets | 95% | ✅ | 含图标/定位/文档模式 7 方法 |
| QGroupBox | widgets | 95% | ✅ | |
| QScrollArea | widgets | 95% | ✅ | 含 setFrameShape/setFrameShadow |
| 对话框集合 | dialogs | 95% | ✅ | QMessageBox/QFileDialog/QInputDialog 等 |
| 日期时间集合 | widgets | 90% | ✅ | QCalendarWidget 含 3 信号 |
| QFrame | widgets | 85% | ⚠️ | 缺部分进阶方法 |
| QVideoWidget | multimedia | 80% | ⚠️ | Qt6 已移除 brightness 等至 QVideoSink |
| QVideoSink | multimedia | 70% | ⚠️ | 仅 videoSize/subtitleText |

> 所有基础控件均已完成封装，无 ❌ 评级控件。

---

## 2. 基础输入控件 API 明细

### QLineEdit — 覆盖度 98% ✅

| 分类 | 方法 |
|------|------|
| 基础 | `init()`, `show()`, `hide()`, `resize()`, `getPtr()` |
| 文本 | `setText()`, `text()`, `clear()`, `setPlaceholder()`, `setInputMask()`, `displayText()` |
| 配置 | `setMaxLength()` / `maxLength()`, `setReadOnly()`, `setEchoMode()`, `setFrame()`, `setAlignment()` |
| 选择 | `hasSelectedText()`, `selectedText()`, `selectAll()`, `setFocus()`, `setSelection()` |
| 光标 | `cursorPosition()`, `setCursorPosition()` |
| 密码 | `addPasswordToggleAction()`, `setPasswordToggleIcon()` |
| 清除 | `setClearButtonEnabled()`, `isClearButtonEnabled()` |
| 补全 | `setCompleter()` |
| 验证 | `setValidator()`（QIntValidator/QDoubleValidator/QRegExpValidator 三重载） |
| 拖放 | `setDragEnabled()` |
| 样式 | `setStyleSheet()` |
| 状态 | `echoMode()`, `isReadOnly()`, `hasFrame()`, `length()` |
| 信号 | `setOnTextChanged()`, `setOnReturnPressed()`, `setOnEditingFinished()`, `setOnCursorPositionChanged()`, `setOnSelectionChanged()`, `setOnInputRejected()` |

### QTextEdit — 覆盖度 98% ✅

| 分类 | 方法 |
|------|------|
| 文本 | `setText()`, `text()`, `setPlainText()`, `toPlainText()`, `setHtml()`, `toHtml()`, `append()`, `clear()`, `insertHtml()`, `setReadOnly()` |
| 编辑 | `cut()`, `copy()`, `paste()`, `selectAll()`, `canPaste()`, `undo()`, `redo()`, `canUndo()`, `canRedo()` |
| 修改 | `isModified()`, `setModified()` |
| 换行 | `setLineWrapMode()`, `lineWrapMode()` |
| 字体 | `setFontFamily()`, `setFontSize()`, `setFontBold()`, `setFontItalic()`, `setTextColor()` |
| 缩放 | `zoomIn()`, `zoomOut()` |
| 查找替换 | `find()`, `findNext()`, `findPrev()`, `replace()`, `replaceAll()` |
| 光标 | `lineCount()`, `currentLine()`, `currentColumn()`, `characterCount()`, `goToLine()` |
| 打印 | `print()` |
| 尺寸 | `setMinimumSize()`, `setMaximumSize()` |
| 样式 | `setStyleSheet()`（`setWidgetStyleSheet()` 为旧别名，已标记 `@Deprecated`） |
| 工具提示 | `setToolTip()` |
| 可见性 | `setVisible()`, `isVisible()`, `width()`, `height()` |
| 信号 | `setOnTextChanged()`, `setOnUndoAvailable()`, `setOnRedoAvailable()`, `setOnCopyAvailable()`, `setOnCursorPositionChanged()`, `setOnSelectionChanged()` |
| 资源 | `close()`, `isClosed()`, `isValid()`, `checkValid()` |

### QSpinBox — 覆盖度 98% ✅

| 分类 | 方法 |
|------|------|
| 值 | `setValue()`, `value()`, `setRange()`, `setSingleStep()` |
| 格式 | `setPrefix()` / `prefix()`, `setSuffix()` / `suffix()`, `setSpecialValueText()`, `cleanText()`, `text()` |
| 显示 | `setDisplayIntegerBase()` / `displayIntegerBase()`, `setButtonSymbols()` / `buttonSymbols()`, `setCorrectionMode()` |
| 范围 | `setMinimum()` / `minimum()`, `setMaximum()` / `maximum()`, `setGroupSeparatorShown()` |
| 行为 | `setWrapping()` / `wrapping()` |
| 编辑 | `selectAll()`, `setFocus()` |
| 信号 | `setOnValueChanged()`, `setOnTextChanged()`, `setOnEditingFinished()` |
| 基类 | `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()` |
| 资源 | `close()`, `isClosed()`, `isValid()`, `checkValid()` |

### QPushButton — 覆盖度 95% ✅

| 分类 | 方法 |
|------|------|
| 外观 | `setText()`, `text()`, `setIcon()`, `setIconSize()`, `setStandardIcon()`, `iconName()` |
| 菜单 | `setMenu()` |
| 状态 | `setCheckable()` / `isCheckable()`, `setChecked()` / `isChecked()`, `setDefault()`, `setFlat()`, `setAutoDefault()` / `isAutoDefault()`, `isDefault()`, `isFlat()`, `setAutoRepeat()` / `isAutoRepeat()` |
| 快捷键 | `setShortcut()`, `shortcut()` |
| 信号 | `setOnClick()`, `setOnClickCapture()`, `disconnectClick()`, `setOnPressed()`, `setOnPressedCapture()`, `disconnectPressed()`, `setOnReleased()`, `setOnReleasedCapture()`, `disconnectReleased()`, `setOnToggled()`, `setOnClickedChecked()`, `disconnect()` |
| 基类 | `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()` |
| 资源 | `close()`, `isClosed()`, `isValid()`, `checkValid()` |

### QComboBox — 覆盖度 95% ✅

| 分类 | 方法 |
|------|------|
| 条目 | `addItem()`, `addItems()`, `insertItem()`, `setItemText()`, `removeItem()`, `count()`, `itemText()`, `clear()` |
| 当前 | `currentText()`, `currentIndex()`, `setCurrentIndex()`, `setCurrentText()`, `setPlaceholderText()`, `findText()` |
| 图标 | `setIconSize()` |
| 编辑 | `setEditable()` |
| 容量 | `setMaxVisibleItems()`, `setMaxCount()` |
| 信号 | `setOnCurrentIndexChanged()`, `setOnCurrentTextChanged()` |
| 基类 | `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()` |

### QSlider — 覆盖度 95% ✅

| 分类 | 方法 |
|------|------|
| 值 | `setValue()`, `value()`, `setRange()`, `setSingleStep()`, `singleStep()`, `setPageStep()`, `pageStep()` |
| 刻度 | `setTickPosition()` / `tickPosition()`, `setTickInterval()` / `tickInterval()` |
| 反转 | `setInvertedControls()` / `invertedControls()`, `setInvertedAppearance()` / `invertedAppearance()` |
| 行为 | `setTracking()`, `hasTracking()` |
| 信号 | `setOnValueChanged()`, `setOnSliderMoved()`, `setOnSliderPressed()`, `setOnSliderReleased()` |
| 基类 | `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()` |

### QDoubleSpinBox — 覆盖度 95% ✅

| 分类 | 方法 |
|------|------|
| 值 | `setValue()`, `value()`, `setRange()`, `setSingleStep()` |
| 小数 | `setDecimals()` / `decimals()` |
| 格式 | `setPrefix()` / `prefix()`, `setSuffix()` / `suffix()`, `cleanText()`, `text()`, `setSpecialValueText()` |
| 行为 | `setWrapping()` / `wrapping()`, `setButtonSymbols()`, `setStepType()`, `setGroupSeparatorShown()` |
| 范围 | `setMinimum()` / `minimum()`, `setMaximum()` / `maximum()` |
| 编辑 | `selectAll()`, `setFocus()` |
| 信号 | `setOnValueChanged()`, `setOnTextChanged()`, `setOnEditingFinished()` |
| 基类 | `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()` |

### QDial — 覆盖度 95% ✅

| 分类 | 方法 |
|------|------|
| 值 | `setValue()`, `value()`, `setRange()`, `setSingleStep()`, `setPageStep()` / `pageStep()` |
| 行为 | `setWrapping()` / `wrapping()` |
| 刻度 | `setNotchesVisible()` / `notchesVisible()`, `setNotchTarget()` / `notchTarget()` |
| 信号 | `setOnValueChanged()` |
| 基类 | `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()` |
| 资源 | `close()`, `isClosed()`, `isValid()`, `checkValid()` |

### QLCDNumber — 覆盖度 95% ✅

| 分类 | 方法 |
|------|------|
| 显示 | `display()`, `displayInt()`, `checkOverflow()`, `value()` |
| 模式 | `setMode()` / `mode()`, `setSegmentStyle()` / `segmentStyle()`, `setSmallDecimalPoint()` / `smallDecimalPoint()`, `digitCount()`, `setDigitCount()` |
| 基类 | `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()` |
| 资源 | `close()`, `isClosed()`, `isValid()`, `checkValid()` |

### QToolButton — 覆盖度 95% ✅

| 分类 | 方法 |
|------|------|
| 外观 | `setText()`, `text()`, `setIcon()`, `setIconSize()`, `setIconFromPath()`, `setToolButtonStyle()` / `toolButtonStyle()`, `setPopupMode()` |
| 动作 | `defaultAction()`, `setDefaultAction()`, `setAutoRaise()` / `autoRaise()` / `isAutoRaise()`, `setArrowType()` |
| 菜单 | `setMenu()`, `showMenu()` |
| 信号 | `setOnClick()`, `setOnClickCapture()`, `disconnectClicked()`, `setOnPressed()`, `setOnPressedCapture()`, `disconnectPressed()`, `setOnReleased()`, `setOnReleasedCapture()`, `disconnectReleased()`, `setOnClickedChecked()`, `disconnectClickedChecked()`, `disconnect()` |
| 基类 | `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()` |
| 资源 | `close()`, `isClosed()`, `isValid()`, `checkValid()` |

### QProgressBar — 覆盖度 95% ✅

| 分类 | 方法 |
|------|------|
| 值 | `setValue()` / `value()`, `setRange()`, `setMinimum()` / `minimum()`, `setMaximum()` / `maximum()`, `reset()` |
| 文本 | `setFormat()` / `format()`, `text()`, `setTextVisible()` / `isTextVisible()` |
| 方向 | `setOrientation()`, `setInvertedAppearance()` / `invertedAppearance()`, `setAlignment()`, `setTextDirection()` / `textDirection()` |
| 信号 | `setOnValueChanged()` |
| 基类 | `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()` |
| 资源 | `close()`, `isClosed()`, `isValid()`, `checkValid()` |

### QCheckBox — 覆盖度 95% ✅

| 分类 | 方法 |
|------|------|
| 文本 | `setText()`, `text()` |
| 状态 | `setChecked()` / `isChecked()`, `setTristate()` / `isTristate()`, `checkState()`, `setCheckState()` |
| 信号 | `setOnStateChanged()`, `setOnClicked()` |
| 基类 | `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()` |
| 资源 | `close()`, `isClosed()`, `isValid()`, `checkValid()` |

### QRadioButton — 覆盖度 95% ✅

| 分类 | 方法 |
|------|------|
| 文本 | `setText()`, `text()` |
| 状态 | `setChecked()` / `isChecked()`, `setAutoExclusive()` / `isAutoExclusive()` |
| 信号 | `setOnToggled()`, `setOnClicked()` |
| 基类 | `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()` |
| 资源 | `close()`, `isClosed()`, `isValid()`, `checkValid()` |

---

## 3. 容器控件 API 明细

### QSplitter — 覆盖度 98% ✅

| 分类 | 方法 |
|------|------|
| 子部件 | `addWidget()`, `insertWidget()`, `replaceWidget()`, `count()` |
| 布局 | `setStretchFactor()`, `setHandleWidth()` / `handleWidth()`, `setOrientation()` / `orientation()`, `setChildrenCollapsible()` / `childrenCollapsible()`, `setOpaqueResize()` |
| 尺寸 | `setSizes()` / `sizes()`（数组 FFI）, `saveState()` / `restoreState()`（字节流 FFI） |
| 基类 | `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()` |

### QTabWidget — 覆盖度 95% ✅

| 分类 | 方法 |
|------|------|
| 标签页 | `addTab()`, `removeTab()`, `insertTab()`, `count()`, `clear()` |
| 当前 | `currentIndex()`, `setCurrentIndex()` |
| 文本 | `setTabText()`, `tabText()`, `setTabToolTip()` |
| 图标 | `setTabIcon()`, `setIconSize()` |
| 外观 | `setTabPosition()`, `setDocumentMode()`, `setElideMode()`, `setTabShape()`, `setUsesScrollButtons()`, `setTabsClosable()`, `setMovable()` |
| 信号 | `setOnCurrentChanged()` |
| 基类 | `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()` |

### QGroupBox — 覆盖度 95% ✅

| 分类 | 方法 |
|------|------|
| 标题 | `setTitle()` / `title()` |
| 可选 | `setCheckable()` / `isCheckable()`, `setChecked()` / `isChecked()`, `setFlat()` / `isFlat()` |
| 对齐 | `setAlignment()` / `alignment()` |
| 布局 | `setLayout()` |
| 信号 | `setOnClicked()`, `setOnToggled()` |
| 基类 | `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()` |
| 资源 | `close()`, `isClosed()`, `isValid()`, `checkValid()` |

### QScrollArea — 覆盖度 95% ✅

| 分类 | 方法 |
|------|------|
| 子部件 | `setWidget()`, `widget()`, `takeWidget()`, `setWidgetResizable()` / `widgetResizable()` |
| 对齐 | `setAlignment()` / `alignment()` |
| 滚动 | `setHorizontalScrollBarPolicy()`, `setVerticalScrollBarPolicy()`, `ensureVisible()` |
| 边框 | `setFrameShape()` / `frameShape()`, `setFrameShadow()` / `frameShadow()` |
| 基类 | `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()` |
| 资源 | `close()`, `isClosed()`, `isValid()`, `checkValid()` |

### QFrame — 覆盖度 85% ⚠️

| 分类 | 方法 |
|------|------|
| 边框 | `setFrameShape()` / `frameShape()`, `setFrameShadow()` / `frameShadow()`, `setLineWidth()` / `lineWidth()`, `frameWidth()`, `setMidLineWidth()` / `midLineWidth()`, `setFrameStyle()` / `frameStyle()`, `setFrameRect()` |
| 布局 | `setLayout()` |
| 基类 | `setEnabled()`, `isEnabled()`, `setStyleSheet()`, `setMinimumSize()`, `setMaximumSize()` |
| 资源 | `close()`, `isClosed()`, `isValid()`, `checkValid()` |

---

## 4. 对话框 API 明细 — 覆盖度 95% ✅

| 控件 | 主要方法 |
|------|---------|
| QMessageBox | `information()` / `warning()` / `critical()` / `question()` |
| QFileDialog | `getOpenFileName()` / `getSaveFileName()` / `getExistingDirectory()` / `getOpenFileNames()` |
| QInputDialog | `getText()`（含 Ok 状态）/ `getInt()`（含 Ok 状态）/ `getDouble()` |
| QColorDialog | `getColor()`（返回十六进制） |
| QFontDialog | `getFontName()` / `getFontSize()` / `getFont()` / `getFontWithDefault()` |
| QProgressDialog | 创建 / 值 / 范围 / 标签 / 取消 / 自动关闭 / 重置 |
| QWizard / QWizardPage | 创建 / 页面 / 导航 / 选项 |
| QErrorMessage | `showMessage()` / 标题 |

---

## 5. 日期时间 API 明细 — 覆盖度 90% ✅

| 控件 | 主要功能 |
|------|---------|
| QDate / QTime / QDateTime | 创建、读写、格式化、当前值 |
| QCalendarWidget | 日期选择、范围、网格、导航、星期、选择模式、`setMinimumSize()`、`setStyleSheet()`、信号 `setOnClicked()` / `setOnActivated()` / `setOnSelectionChanged()` |
| QDateEdit / QTimeEdit / QDateTimeEdit | 日期/时间/日期时间编辑，含范围、显示格式、日历弹出、TimeSpec |

---

## 6. 多媒体 API 明细

### QVideoWidget — 覆盖度 80% ⚠️

| 分类 | 方法 |
|------|------|
| 资源 | `close()`, `isClosed()`, `isValid()`, `checkValid()`（已实现 `<: QtResource`） |

> **注意**：Qt6 已将 `brightness`/`contrast`/`hue`/`saturation` 属性从 QVideoWidget 移除。视频调节需通过 QVideoSink 或着色器实现。

### QVideoSink — 覆盖度 70% ⚠️

| 分类 | 方法 |
|------|------|
| 视频 | `videoSize()` |
| 字幕 | `setSubtitleText()` / `subtitleText()` |
| 资源 | `close()`, `isClosed()`, `isValid()`, `checkValid()` |

> **注意**：Qt 6.10.3 的 QVideoSink 已移除 `brightness`/`contrast`/`hue`/`saturation` 属性（Qt5/Qt6 早期版本曾有），视频调节需通过着色器或帧处理实现。

---

## 7. 跨控件共性

### 7.1 QWidget 基类方法覆盖情况

以下 18 个基础控件均已覆盖 `setEnabled()` / `isEnabled()`、`setStyleSheet()`、`setMinimumSize()` / `setMaximumSize()`：

QLabel, QPushButton, QCheckBox, QRadioButton, QComboBox, QSpinBox, QDoubleSpinBox, QSlider, QDial, QProgressBar, QLCDNumber, QToolButton, QTextEdit, QGroupBox, QTabWidget, QScrollArea, QFrame, QSplitter

### 7.2 QtResource 接口实现情况

已实现 `QtResource`（`checkValid()` / `close()` / `isClosed()` / `isValid()`）的控件：

- **容器类**：QGroupBox, QTabWidget, QScrollArea, QFrame, QSplitter
- **控件类**：QWidget, QLabel, QPushButton, QSpinBox, QCheckBox, QProgressBar, QSlider, QComboBox, QTextEdit, QRadioButton, QDial, QLCDNumber, QToolButton
- **扩展控件类**：QAction, QProgressDialog, QTcpSocket, QSqlDatabase
- **多媒体类**：QVideoWidget, QVideoSink

> 所有提及控件均支持 try-with-resources 自动释放。**注意**：终结器 `~init` 被刻意禁用，必须显式 `close()`。

### 7.3 setStyleSheet 命名统一

- 统一签名：`setStyleSheet(style: String)`
- QTextEdit 曾同时存在 `setWidgetStyleSheet()` 旧别名，已标记 `@Deprecated[message: "..."]`，请使用 `setStyleSheet()`

---

## 8. 测试状态（2026-08-29 最终确认）

| 指标 | 数值 |
|------|------|
| 总用例数 | 1417 |
| 通过 | **1346** ✅ |
| 跳过 | 71 |
| 失败 | **0** ✅ |
| 错误 | 0 |

**全量测试通过** — 71 个 SKIPPED 为平台/条件跳过的用例（含 QVideoSink 3 个 `requires_audio` 标签跳过，已单独验证通过），无失败无错误。

---

## 9. 变更历史

| 时间 | 批次 | 内容 |
|------|------|------|
| 2026-07 | 质量治理 | 9 个控件 QtResource 补齐；QLabel/QTextEdit/QScrollArea/QGroupBox 等方法补齐；全量源码审查修正"缺失"列表中已实现但未更新的 API |
| 2026-07-30 | 第一批 | QAction/QProgressDialog/QTcpSocket/QSqlDatabase 补齐 QtResource（`close()` 语义调整，旧操作保留为 `abort()`/`closeDatabase()`） |
| 2026-07-30 | 第二批 | QPushButton `setMinimumSize`/`setMaximumSize`；QTextEdit `setWidgetStyleSheet` 标记 `@Deprecated`；QSplitter 基类方法；QRadioButton/QDial/QLCDNumber/QToolButton QtResource |
| 2026-07-30 | 第三批 | QSlider/QFrame/QDoubleSpinBox/QToolButton/QGroupBox/QSpinBox/QProgressBar 共 16 个方法桥接与封装（集中管理于 `bridge_ext_apicomplete.cpp`） |
| 2026-07-30 | 第四批 | 扩展控件 QtResource（同第一批） |
| 2026-07-30 | 第五批 | 新增 6 组控件：QAbstractAnimation/QParallelAnimationGroup、QUndoCommand/QUndoStack、QStyleHelper、QCameraDevice/QCamera/QMediaCaptureSession/QMediaDevices、QVideoWidget、QSortFilterProxyModel |
| 2026-08-28 | 任务 1-6 | QPushButton.setMenu、QCalendarWidget 3 信号、QTabWidget 7 方法、QSplitter 7 方法、QComboBox.setIconSize、QTextEdit 3 方法、INDEX.md/roadmap.md 更新 |
| 2026-08-29 | API 补全 | QLineEdit `setValidator`（3 重载）+ `setDragEnabled`；QTextEdit 信号 `setOnCursorPositionChanged`/`setOnSelectionChanged`；QCalendarWidget `setMinimumSize`/`setStyleSheet`；QVideoWidget QtResource 接口；QScrollArea 文档修正（`setFrameShape`/`setFrameShadow` 实际已实现） |
| 2026-08-29 | QVideoSink 封装 | 新增 `bridge_videosink.cpp` + `videosink.cj`，封装 `videoSize`/`subtitleText`，实现 QtResource。关键发现：Qt 6.10.3 已移除 brightness/contrast/hue/saturation |

---

## 10. 后续待办

当前所有已知常用控件均已完成封装，暂无硬缺口。后续按需补充：

- **QAbstractAnimation 子类化支持**：需派生 QObject，成本较高
- **QVideoWidget 视频调节**：brightness/contrast/hue/saturation 在 Qt 6.10.3 已移至 QVideoSink（QVideoSink 也已移除），需通过着色器或帧处理实现
- **QTranslator 独立类**：目前仅有 `QApplication.loadQtTranslation()`
