# CJQT6 API 完善度评估

> 更新日期：2026-07-30（第五批 — animation/undostack/style/camera/videowidget/sortfilterproxymodel）
>
> 本文档评估每个控件的封装完整性，按优先级列出待补全的方法。
>
> 评级标准：
> - ✅ **完善** — 覆盖 Qt API 80%+，可满足绝大部分日常使用
> - ⚠️ **基本完善** — 覆盖 Qt API 60-80%，常用操作可用，缺进阶方法
> - ❌ **不足** — 覆盖 Qt API < 60%，基础功能有缺口

---

## 1. 封装非常完善的控件 ✅

### QLineEdit
**覆盖度：95%**

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
| 样式 | `setStyleSheet()` |
| 状态 | `echoMode()`, `isReadOnly()`, `hasFrame()`, `length()` |
| 信号 | `setOnTextChanged()`, `setOnReturnPressed()`, `setOnEditingFinished()`, `setOnCursorPositionChanged()`, `setOnSelectionChanged()`, `setOnInputRejected()` |

**缺失**：`setValidator()`, `setDragEnabled()`

### QTextEdit
**覆盖度：95%**

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
| 样式 | `setStyleSheet()` |
| 工具提示 | `setToolTip()` |
| 可见性 | `setVisible()`, `isVisible()`, `width()`, `height()` |
| 信号 | `setOnTextChanged()`, `setOnUndoAvailable()`, `setOnRedoAvailable()`, `setOnCopyAvailable()` |
| 资源 | `close()`, `isClosed()`, `isValid()`, `checkValid()` |

**缺失**：信号（cursorPositionChanged/selectionChanged）

**已补全**：`setTabStopDistance()`（Qt6）/`setAcceptRichText()`/`setPlaceholderText()`（2026-08-28 任务 5）

**注意**：`setWidgetStyleSheet()` 是 `setStyleSheet()` 的旧别名，已标记 `@Deprecated`。请使用 `setStyleSheet()`。

### 日期时间 (QDate/QTime/QDateTime/QCalendarWidget/QDateEdit/QTimeEdit/QDateTimeEdit)
**覆盖度：90%**

- QDate/QTime/QDateTime: 创建、读写、格式化、当前值
- QCalendarWidget: 日期选择、范围、网格、导航、星期、选择模式
- QDateEdit/QTimeEdit/QDateTimeEdit: 日期/时间/日期时间编辑，含范围、显示格式、日历弹出、TimeSpec

**已补全**：信号 `setOnClicked`/`setOnActivated`/`setOnSelectionChanged`（2026-08-28 任务 2）

**缺失**：`setMinimumSize`/`setStyleSheet`

### 对话框
**覆盖度：95%**

- QMessageBox: information/warning/critical/question
- QFileDialog: getOpenFileName/getSaveFileName/getExistingDirectory/getOpenFileNames
- QInputDialog: getText (含 Ok 状态)/getInt (含 Ok 状态)/getDouble
- QColorDialog: getColor (返回十六进制)
- QFontDialog: getFontName/getFontSize/getFont/getFontWithDefault (解析字体信息)
- QProgressDialog: 创建/值/范围/标签/取消/自动关闭/重置
- QWizard/QWizardPage: 创建/页面/导航/选项
- QErrorMessage: 显示消息/标题

---

## 2. 封装基本完善的控件 ⚠️

### QPushButton
**覆盖度：95%**

| 已有 | 缺失 |
|------|------|
| `setText()`, `text()`, `setIcon()`, `setIconSize()`, `setStandardIcon()`, `iconName()`, `setMenu()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `setCheckable()`, `isCheckable()`, `setChecked()`, `isChecked()` | |
| `setDefault()`, `setFlat()` | |
| `setAutoDefault()`, `isAutoDefault()`, `isDefault()`, `isFlat()` | |
| `setAutoRepeat()`, `isAutoRepeat()` | |
| `setShortcut()`, `shortcut()` | |
| `setOnClick()`, `setOnClickCapture()`, `disconnectClick()` | |
| `setOnPressed()`, `setOnPressedCapture()`, `disconnectPressed()` | |
| `setOnReleased()`, `setOnReleasedCapture()`, `disconnectReleased()` | |
| `setOnToggled()`, `setOnClickedChecked()`, `disconnect()` | |
| `close()`, `isClosed()`, `isValid()`, `checkValid()` (QtResource) | |

### QComboBox
**覆盖度：95%**

| 已有 | 缺失 |
|------|------|
| `addItem()`, `addItems()`, `insertItem()`, `setItemText()` | |
| `removeItem()`, `count()`, `itemText()`, `clear()` | |
| `currentText()`, `currentIndex()`, `setCurrentIndex()` | |
| `setCurrentText()`, `setPlaceholderText()`, `findText()` | |
| `setIconSize()`（2026-08-28 任务 5） | |
| `setEditable()` | |
| `setMaxVisibleItems()`, `setMaxCount()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `setOnCurrentIndexChanged()`, `setOnCurrentTextChanged()` | |

### QSlider
**覆盖度：95%**

| 已有 | 缺失 |
|------|------|
| `setValue()`, `value()`, `setRange()`, `setOrientation()` | |
| `setSingleStep()`, `singleStep()`, `setPageStep()`, `pageStep()` | |
| `setTickPosition()`, `tickPosition()` | |
| `setTickInterval()`, `tickInterval()` | |
| `setInvertedControls()`, `invertedControls()` | |
| `setInvertedAppearance()`, `invertedAppearance()` | |
| `setTracking()`, `hasTracking()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `setOnValueChanged()`, `setOnSliderMoved()` | |
| `setOnSliderPressed()`, `setOnSliderReleased()` | |

### QSpinBox
**覆盖度：98%**

| 已有 | 缺失 |
|------|------|
| `setValue()`, `value()`, `setRange()`, `setSingleStep()` | |
| `setPrefix()`, `prefix()`, `setSuffix()`, `suffix()` | |
| `setWrapping()`, `wrapping()` | |
| `setSpecialValueText()`, `cleanText()`, `text()` | |
| `setDisplayIntegerBase()`, `displayIntegerBase()` | |
| `setButtonSymbols()`, `buttonSymbols()` | |
| `setCorrectionMode()` | |
| `setMinimum()`, `minimum()`, `setMaximum()`, `maximum()` | |
| `setGroupSeparatorShown()` | |
| `selectAll()`, `setFocus()` | |
| `setOnValueChanged()`, `setOnTextChanged()`, `setOnEditingFinished()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `close()`, `isClosed()`, `isValid()`, `checkValid()` (QtResource) | |

### QDoubleSpinBox
**覆盖度：95%**

| 已有 | 缺失 |
|------|------|
| `setValue()`, `value()`, `setRange()`, `setSingleStep()` | |
| `setDecimals()` / `decimals()` | |
| `setPrefix()`, `prefix()`, `setSuffix()`, `suffix()` | |
| `cleanText()`, `text()`, `setSpecialValueText()` | |
| `setWrapping()`, `wrapping()` | |
| `setButtonSymbols()` | |
| `selectAll()`, `setFocus()` | |
| `setMinimum()`, `minimum()`, `setMaximum()`, `maximum()` | |
| `setStepType()`, `setGroupSeparatorShown()` | |
| `setOnValueChanged()`, `setOnTextChanged()`, `setOnEditingFinished()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |

### QDial
**覆盖度：95%**

| 已有 | 缺失 |
|------|------|
| `setValue()`, `value()`, `setRange()`, `setSingleStep()` | |
| `setWrapping()`, `wrapping()` | |
| `setNotchesVisible()`, `notchesVisible()` | |
| `setNotchTarget()`, `notchTarget()` | |
| `setPageStep()`, `pageStep()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `setOnValueChanged()` | |
| `close()`, `isClosed()`, `isValid()`, `checkValid()` (QtResource) | |

### QLCDNumber
**覆盖度：95%**

| 已有 | 缺失 |
|------|------|
| `display()`, `displayInt()`, `checkOverflow()`, `value()` | |
| `setMode()`, `mode()` | |
| `setSegmentStyle()`, `segmentStyle()` | |
| `setSmallDecimalPoint()`, `smallDecimalPoint()` | |
| `digitCount()`, `setDigitCount()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `close()`, `isClosed()`, `isValid()`, `checkValid()` (QtResource) | |

### QToolButton
**覆盖度：95%**

| 已有 | 缺失 |
|------|------|
| `setText()`, `text()`, `setIcon()`, `setIconSize()`, `setIconFromPath()` | |
| `setToolButtonStyle()`, `toolButtonStyle()`, `setPopupMode()` | |
| `defaultAction()`, `setDefaultAction()` | |
| `setAutoRaise()` / `autoRaise()` / `isAutoRaise()`, `setArrowType()` | |
| `setMenu()`, `showMenu()` | |
| `setOnClick()`, `setOnClickCapture()`, `disconnectClicked()` | |
| `setOnPressed()`, `setOnPressedCapture()`, `disconnectPressed()` | |
| `setOnReleased()`, `setOnReleasedCapture()`, `disconnectReleased()` | |
| `setOnClickedChecked()`, `disconnectClickedChecked()`, `disconnect()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `close()`, `isClosed()`, `isValid()`, `checkValid()` (QtResource) | |

### QProgressBar
**覆盖度：95%**

| 已有 | 缺失 |
|------|------|
| `setValue()` / `value()`, `setRange()` | |
| `setMinimum()` / `minimum()`, `setMaximum()` / `maximum()` | |
| `setFormat()` / `format()`, `text()` | |
| `setTextVisible()` / `isTextVisible()` | |
| `setOrientation()`, `setInvertedAppearance()` / `invertedAppearance()`, `reset()` | |
| `setAlignment()`, `setTextDirection()` / `textDirection()` | |
| `setOnValueChanged()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `close()`, `isClosed()`, `isValid()`, `checkValid()` (QtResource) | |

### QCheckBox
**覆盖度：95%**

| 已有 | 缺失 |
|------|------|
| `setText()`, `text()` | |
| `setChecked()` / `isChecked()` | |
| `setTristate()` / `isTristate()` | |
| `checkState()`, `setCheckState()` | |
| `setOnStateChanged()`, `setOnClicked()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `close()`, `isClosed()`, `isValid()`, `checkValid()` (QtResource) | |

### QRadioButton
**覆盖度：95%**

| 已有 | 缺失 |
|------|------|
| `setText()`, `text()` | |
| `setChecked()` / `isChecked()` | |
| `setAutoExclusive()` / `isAutoExclusive()` | |
| `setOnToggled()`, `setOnClicked()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `close()`, `isClosed()`, `isValid()`, `checkValid()` (QtResource) | |

### QTabWidget
**覆盖度：95%**

| 已有 | 缺失 |
|------|------|
| `addTab()`, `removeTab()`, `insertTab()`, `count()` | |
| `currentIndex()`, `setCurrentIndex()` | |
| `setTabText()`, `tabText()`, `setTabToolTip()` | |
| `setTabsClosable()`, `setMovable()`, `clear()` | |
| `setTabIcon()`, `setIconSize()`（2026-08-28 任务 3） | |
| `setTabPosition()`, `setDocumentMode()`, `setElideMode()`（2026-08-28 任务 3） | |
| `setTabShape()`, `setUsesScrollButtons()`（2026-08-28 任务 3） | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `setOnCurrentChanged()` | |

### QGroupBox
**覆盖度：95%**

| 已有 | 缺失 |
|------|------|
| `setTitle()` / `title()` | |
| `setCheckable()` / `isCheckable()` | |
| `setAlignment()` / `alignment()` | |
| `setChecked()` / `isChecked()` | |
| `setFlat()` / `isFlat()` | |
| `setLayout()` | |
| `setOnClicked()`, `setOnToggled()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `close()`, `isClosed()`, `isValid()`, `checkValid()` (QtResource) | |

### QSplitter
**覆盖度：98%**

| 已有 | 缺失 |
|------|------|
| `addWidget()`, `insertWidget()`, `replaceWidget()`, `count()` | |
| `setStretchFactor()`, `setHandleWidth()` / `handleWidth()` | |
| `setOrientation()` / `orientation()` | |
| `setChildrenCollapsible()` / `childrenCollapsible()` | |
| `setSizes()` / `sizes()`（2026-08-28 任务 4，数组 FFI） | |
| `saveState()` / `restoreState()`（2026-08-28 任务 4，字节流 FFI） | |
| `setOpaqueResize()`（2026-08-28 任务 4） | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |

### QFrame
**覆盖度：85%**

| 已有 | 缺失 |
|------|------|
| `setFrameShape()`, `frameShape()`, `setFrameShadow()`, `frameShadow()` | |
| `setLineWidth()`, `lineWidth()`, `frameWidth()` | |
| `setMidLineWidth()`, `midLineWidth()` | |
| `setFrameStyle()`, `frameStyle()` | |
| `setFrameRect()` | |
| `setLayout()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `close()`, `isClosed()`, `isValid()`, `checkValid()` (QtResource) | |

### QScrollArea
**覆盖度：85%**

| 已有 | 缺失 |
|------|------|
| `setWidget()`, `widget()`, `takeWidget()` | `setFrameShape()`, `setFrameShadow()` |
| `setWidgetResizable()`, `widgetResizable()` | |
| `setAlignment()`, `alignment()` | |
| `setHorizontalScrollBarPolicy()`, `setVerticalScrollBarPolicy()` | |
| `ensureVisible()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `close()`, `isClosed()`, `isValid()`, `checkValid()` (QtResource) | |

---

## 3. 封装不足的控件 ❌

*（所有基础控件均已完成基本封装，暂无评级为 ❌ 的控件）*

---

## 4. 跨控件共性问题

### 4.1 QWidget 基类方法覆盖情况

以下表格反映当前各控件暴露 `setEnabled`/`isEnabled`、`setStyleSheet`、`setMinimumSize`/`setMaximumSize` 的状况：

| 控件 | `setEnabled`/`isEnabled` | `setStyleSheet` | `setMinimumSize`/`setMaximumSize` |
|------|------------------------|-----------------|----------------------------------|
| QLabel | ✅ | ✅ | ✅（已补齐） |
| QPushButton | ✅ | ✅ | ✅（已补齐） |
| QCheckBox | ✅ | ✅ | ✅ |
| QRadioButton | ✅ | ✅ | ✅ |
| QComboBox | ✅ | ✅ | ✅ |
| QSpinBox | ✅ | ✅ | ✅ |
| QDoubleSpinBox | ✅ | ✅ | ✅ |
| QSlider | ✅ | ✅ | ✅ |
| QDial | ✅ | ✅ | ✅ |
| QProgressBar | ✅ | ✅ | ✅ |
| QLCDNumber | ✅ | ✅ | ✅ |
| QToolButton | ✅ | ✅ | ✅ |
| QTextEdit | ✅（已补齐） | ✅（命名已统一） | ✅ |
| QGroupBox | ✅ | ✅ | ✅ |
| QTabWidget | ✅ | ✅ | ✅ |
| QScrollArea | ✅ | ✅ | ✅ |
| QFrame | ✅ | ✅ | ✅ |
| QSplitter | ✅（已补齐） | ✅（已补齐） | ✅（已补齐） |

**说明**：以上 18 个基础控件均已覆盖 QWidget 基类常用方法，无需额外补齐。

### 4.2 `setStyleSheet` 命名不统一
- 大部分控件：`setStyleSheet(style: String)`
- QTextEdit：同时存在 `setStyleSheet()` 和 `setWidgetStyleSheet()` 两个方法（`setWidgetStyleSheet` 为旧别名，已标记 `@Deprecated[message: "..."]`）✅

### 4.3 QtResource 实现情况
实现了 QtResource（checkValid/close/isClosed）的控件：
- ✅ **容器类**：QGroupBox, QTabWidget, QScrollArea, QFrame, QSplitter
- ✅ **控件类**：QWidget, QLabel, QPushButton, QSpinBox, QCheckBox, QProgressBar, QSlider, QComboBox, QTextEdit, QRadioButton, QDial, QLCDNumber, QToolButton
- ✅ **扩展控件类**：QAction, QProgressDialog, QTcpSocket, QSqlDatabase

**说明**：2026-07 审查后已完成全部基础控件的 QtResource 接口实现。2026-07-30 第四批补齐扩展控件（QAction/QProgressDialog/QTcpSocket/QSqlDatabase）。所有提及控件均支持 try-with-resources 自动释放。

---

## 5. 完善优先级

### 5.1 当前待完成

当前所有已知常用控件均已完成封装，暂无待完成任务。

> 后续按需补充：QAbstractAnimation 子类化支持、QVideoWidget 亮度/对比度/色调/饱和度（需 QVideoSink）、QSplitter `insertWidget`/`replaceWidget`/`setSizes`/`sizes` 等进阶方法。

### 5.2 已完成记录

| 完成时间 | 任务 | 说明 |
|----------|------|------|
| 2026-07-30 | QAction 补齐 QtResource | 实现 QtResource + checkValid 守卫 + CreateFailedException |
| 2026-07-30 | QProgressDialog 补齐 QtResource | 实现 QtResource + checkValid 守卫，添加 import cjqt6.core.* |
| 2026-07-30 | QTcpSocket 补齐 QtResource | 实现 QtResource；`close()` 改为资源清理，旧 close → `abort()`；`isValid()` 重命名为 `isSocketValid()` |
| 2026-07-30 | QSqlDatabase 补齐 QtResource | 实现 QtResource；`close()` 改为资源清理，旧 close → `closeDatabase()` |
| 2026-07-30 | QPushButton `setMinimumSize`/`setMaximumSize` | 纯仓颉包装，复用 qWidgetSetMinimumSize/qWidgetSetMaximumSize |
| 2026-07-30 | QTextEdit `setWidgetStyleSheet` 标记 @Deprecated[message: "..."] | 统一命名，消除不一致 |
| 2026-07-30 | QSplitter `setEnabled`/`isEnabled`/`setStyleSheet`/`setMinimumSize`/`setMaximumSize` | 纯仓颉包装，复用 qWidget* FFI |
| 2026-07-30 | QRadioButton 补齐 QtResource | 实现 close/isClosed/isValid/checkValid |
| 2026-07-30 | QDial 补齐 QtResource | 实现 close/isClosed/isValid/checkValid |
| 2026-07-30 | QLCDNumber 补齐 QtResource | 实现 close/isClosed/isValid/checkValid |
| 2026-07-30 | QToolButton 补齐 QtResource | 实现 close/isClosed/isValid/checkValid |
| 2026-07-30 | QSlider `setInvertedAppearance`/`invertedAppearance` | C++ 桥接 + 仓颉包装 |
| 2026-07-30 | QDoubleSpinBox `setWrapping`/`wrapping`/`setButtonSymbols`/`selectAll`/`setFocus` | C++ 桥接 + 仓颉包装 |
| 2026-07-30 | QFrame `lineWidth`/`frameWidth` getter | C++ 桥接 + 仓颉包装 |
| 2026-07-30 | QToolButton `text()`/`defaultAction`/`setDefaultAction` | C++ 桥接 + 仓颉包装 |
| 2026-07-30 | QSpinBox `selectAll`/`setFocus` | C++ 桥接 + 仓颉包装 |
| 2026-07-30 | QProgressBar `text()` getter | C++ 桥接 + 仓颉包装 |
| 2026-07-30 | QGroupBox `setFlat`/`isFlat` | C++ 桥接 + 仓颉包装 |
| 2026-07 （质量治理） | 9 个控件 QtResource | 2026-07 质量治理提交（ba6d2d4） |
| 2026-07 （质量治理） | QLabel `setMinimumSize`/`setMaximumSize` | 2026-07 质量治理已补齐 |
| 2026-07 （质量治理） | QTextEdit `setEnabled`/`isEnabled` | 2026-07 质量治理已补齐 |
| 2026-07 （质量治理） | QScrollArea 滚动策略 + `ensureVisible` | 已实现 |
| 2026-07 （质量治理） | QGroupBox `setAlignment`/`alignment` | 已实现 |
| 2026-07 审查后更新 | QLineEdit 扩展方法（`setClearButtonEnabled`/光标/选择/补全/信号等） | 已完成实现但未更新文档，本次审查已更正 |
| 2026-07 审查后更新 | QPushButton 补齐信号方法（`setShortcut`/`setAutoDefault`/信号等） | 已完成实现但未更新文档，本次审查已更正 |
| 2026-07 审查后更新 | QDoubleSpinBox 补齐格式化方法（`setPrefix`/`setSuffix`/`cleanText`等） | 已完成实现但未更新文档，本次审查已更正 |
| 2026-07 审查后更新 | QDial `setNotchTarget`/`setPageStep` | 已完成实现但未更新文档，本次审查已更正 |
| 2026-07 审查后更新 | QProgressBar 补齐方法（`setMinimum`/`setMaximum`/`setAlignment`等） | 已完成实现但未更新文档，本次审查已更正 |
| 2026-07 审查后更新 | QCheckBox `setTristate`/`checkState`/`setOnClicked` | 已完成实现但未更新文档，本次审查已更正 |
| 2026-07 审查后更新 | QRadioButton `setAutoExclusive`/`setOnClicked` | 已完成实现但未更新文档，本次审查已更正 |
| 2026-07 审查后更新 | QFrame `frameShape`/`frameShadow`/`setMidLineWidth`/`setFrameRect` | 已完成实现但未更新文档，本次审查已更正 |
| 2026-07 审查后更新 | QScrollArea `takeWidget`/`widgetResizable`/`setAlignment` | 已完成实现但未更新文档，本次审查已更正 |
| 2026-07 审查后更新 | QToolButton `setIconFromPath`/`toolButtonStyle`/信号等 | 已完成实现但未更新文档，本次审查已更正 |
| 2026-07 审查后更新 | QGroupBox `setOnClicked`/`setOnToggled` | 已完成实现但未更新文档，本次审查已更正 |
| 2026-07 审查后更新 | QLCDNumber `setStyleSheet` | 已完成实现但未更新文档，本次审查已更正 |
| 2026-07 审查后更新 | QSpinBox 补齐方法（`setDisplayIntegerBase`/`setButtonSymbols`/`setCorrectionMode`/`setGroupSeparatorShown`等） | 已完成实现但未更新文档，本次审查已更正 |

> **2026-07-30 全量源码审查**：通过逐文件比对源文件，修正了大量「缺失」列表中已实现但未更新的 API。本次审查涉及的源文件包括：lineedit.cj, textedit.cj, pushbutton.cj, spinbox.cj, doublespinbox.cj, dial.cj, lcdnumber.cj, toolbutton.cj, progressbar.cj, checkbox.cj, radiobutton.cj, containers.cj (QGroupBox/QTabWidget/QScrollArea/QFrame/QSplitter), slider.cj, combobox.cj。
>
> **2026-07-30 第二批补齐**：完成 QPushButton `setMinimumSize`/`setMaximumSize`、QTextEdit `setWidgetStyleSheet` `@Deprecated`、QSplitter 基础 QWidget 方法、以及 QRadioButton/QDial/QLCDNumber/QToolButton 的 QtResource 接口实现。至此所有基础控件均已对齐 QtResource 模式和 QWidget 基类方法。
>
> **2026-07-30 第三批补齐（API 补全）**：一次性完成 QSlider `setInvertedAppearance`、QFrame `lineWidth`/`frameWidth`、QDoubleSpinBox `setWrapping`/`wrapping`/`setButtonSymbols`/`selectAll`/`setFocus`、QToolButton `text()`/`defaultAction`/`setDefaultAction`、QGroupBox `setFlat`/`isFlat`、QSpinBox `selectAll`/`setFocus`、QProgressBar `text()` 共 16 个方法的桥接与封装。统一新建 `bridge_ext_apicomplete.cpp` 集中管理新增 FFI，Cangjie 层对应 6 个文件同步更新。构建验证通过。
>
> **2026-07-30 第四批补齐（扩展控件 QtResource）**：完成 QAction、QProgressDialog、QTcpSocket、QSqlDatabase 四个扩展控件的 QtResource 接口实现。其中 QTcpSocket 原 `close()` 语义为「关闭 TCP 连接」，调整为资源清理（关闭连接 + 销毁对象），旧操作保留为 `abort()`；`isValid()` 重命名为 `isSocketValid()` 以消除与 `QtResource.isValid()` 的语义冲突。QSqlDatabase 原 `close()` 语义为「关闭数据库连接」，调整为资源清理，旧操作保留为 `closeDatabase()`。统一添加 `import cjqt6.core.*` 到各包，添加 `checkValid()` 守卫和 `CreateFailedException` 空指针检查。`cjpm build` 通过。
>
> **2026-07-30 第五批（新增六个控件封装）**：完成 QAbstractAnimation/QParallelAnimationGroup（core）、QUndoCommand/QUndoStack（core）、QStyleHelper（gui）、QCameraDevice/QCamera/QMediaCaptureSession/QMediaDevices（multimedia）、QVideoWidget（multimedia）、QSortFilterProxyModel（views）共 6 组控件的 C++ FFI 桥接 + Cangjie 绑定。同时修复 CMakeLists.txt 添加 MultimediaWidgets 可选依赖。`cjpm build` 通过。

### 测试状态（2026-07-30 最终确认）
| 指标 | 数值 |
|------|------|
| 总用例数 | 279 |
| 通过 | **279** ✅ |
| 失败 | **0** ✅ |
| 错误 | 0 |

**全量测试通过** — 含 12 个信号测试（SignalAdvancedTests[4]、QSignalLifecycleTests[5]、SignalSlotTests[3]）和全部 QtResource `testOperationsAfterClose` 用例。之前记录的 5 个信号预存失败为 **陈旧测试二进制** 所致，`cjpm build` 重建后 279/279 全部通过。

**本批次修复验证（第二批）**：全部 4 个 QtResource `testOperationsAfterClose` 测试用例（QRadioButton/QDial/QLCDNumber/QToolButton）均已通过。

**本批次修复验证（第三批）**：C++ 桥接编译通过（`bridge_ext_apicomplete.cpp`），仓颉侧 `cjpm build` 通过，新增 16 个 public 方法。
