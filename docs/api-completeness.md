# CJQT6 API 完善度评估

> 更新日期：2026-07-19
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
| 文本 | `setText()`, `text()`, `clear()`, `setPlaceholder()`, `setInputMask()` |
| 配置 | `setMaxLength()` / `maxLength()`, `setReadOnly()`, `setEchoMode()`, `setFrame()`, `setAlignment()` |
| 选择 | `hasSelectedText()`, `selectedText()`, `selectAll()`, `setFocus()` |
| 密码 | `addPasswordToggleAction()`, `setPasswordToggleIcon()` |
| 样式 | `setStyleSheet()` |
| 信号 | `setOnTextChanged()`, `setOnReturnPressed()`, `setOnEditingFinished()` |

**缺失**：`setClearButtonEnabled()`, `setValidator()`, `setDragEnabled()`

### QTextEdit
**覆盖度：90%**

| 分类 | 方法 |
|------|------|
| 文本 | `setText()`, `text()`, `clear()`, `setReadOnly()` |
| 编辑 | `cut()`, `copy()`, `paste()`, `selectAll()`, `canPaste()`, `undo()`, `redo()`, `canUndo()`, `canRedo()` |
| 修改 | `isModified()`, `setModified()` |
| 换行 | `setLineWrapMode()`, `lineWrapMode()` |
| 字体 | `setFontFamily()`, `setFontSize()`, `setFontBold()`, `setFontItalic()` |
| 查找替换 | `find()`, `findNext()`, `findPrev()`, `replace()`, `replaceAll()` |
| 光标 | `lineCount()`, `currentLine()`, `currentColumn()`, `characterCount()`, `goToLine()` |
| 打印 | `print()` |
| 尺寸 | `setMinimumSize()` |

**缺失**：`setTabStopWidth()`, `setAcceptRichText()`, `setPlaceholderText()`，信号（textChanged/cursorPositionChanged），`setStyleSheet()` / `setWidgetStyleSheet()` 命名不统一（两个都有）

### 日期时间 (QDate/QTime/QDateTime/QCalendarWidget/QDateEdit/QTimeEdit/QDateTimeEdit)
**覆盖度：90%**

- QDate/QTime/QDateTime: 创建、读写、格式化、当前值
- QCalendarWidget: 日期选择、范围、网格、导航、星期、选择模式
- QDateEdit/QTimeEdit/QDateTimeEdit: 日期/时间/日期时间编辑，含范围、显示格式、日历弹出、TimeSpec

**缺失**：信号（clicked/activated/selectionChanged），`setMinimumSize`/`setStyleSheet`

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
**覆盖度：80%**

| 已有 | 缺失 |
|------|------|
| `setText()`, `text()`, `setIcon()`, `setIconSize()`, `setStandardIcon()` | `setAutoRepeat()`, `setShortcut()`, `setMenu()` |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | `setMinimumSize()`, `setMaximumSize()` |
| `setCheckable()`, `setChecked()`, `isChecked()` | `setAutoDefault()`, `isDefault()`, `isFlat()` |
| `setDefault()`, `setFlat()` | |
| `setOnClick()`, `disconnectClick()` | |
| `close()`, `isClosed()`, `isValid()`, `checkValid()` (QtResource) | |

### QComboBox
**覆盖度：90%**

| 已有 | 缺失 |
|------|------|
| `addItem()`, `addItems()`, `insertItem()`, `setItemText()` | `setMaxVisibleItems()`, `setMaxCount()` |
| `removeItem()`, `count()`, `itemText()`, `clear()` | `setIconSize()` |
| `currentText()`, `currentIndex()`, `setCurrentIndex()` | |
| `setCurrentText()`, `setPlaceholderText()`, `findText()` | |
| `setEditable()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `setOnCurrentIndexChanged()`, `setOnCurrentTextChanged()` | |

### QSlider
**覆盖度：85%**

| 已有 | 缺失 |
|------|------|
| `setValue()`, `value()`, `setRange()`, `setOrientation()` | `setInvertedAppearance()` |
| `setSingleStep()`, `singleStep()`, `setPageStep()`, `pageStep()` | |
| `setTickPosition()`, `tickPosition()` | |
| `setTickInterval()`, `tickInterval()` | |
| `setInvertedControls()`, `invertedControls()` | |
| `setTracking()`, `hasTracking()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `setOnValueChanged()`, `setOnSliderMoved()` | |
| `setOnSliderPressed()`, `setOnSliderReleased()` | |

### QSpinBox
**覆盖度：85%**

| 已有 | 缺失 |
|------|------|
| `setValue()`, `value()`, `setRange()`, `setSingleStep()` | `setDisplayIntegerBase()` |
| `setPrefix()`, `prefix()`, `setSuffix()`, `suffix()` | `setButtonSymbols()` |
| `setWrapping()`, `wrapping()` | `selectAll()`, `setFocus()` |
| `setSpecialValueText()`, `cleanText()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `setOnValueChanged()` | |
| `close()`, `isClosed()`, `isValid()`, `checkValid()` (QtResource) | |

### QDoubleSpinBox
**覆盖度：70%**

| 已有 | 缺失 |
|------|------|
| `setValue()`, `value()`, `setRange()`, `setSingleStep()` | **`setPrefix()`**, `setSuffix()` |
| `setDecimals()` / `decimals()` | **`setWrapping()`**, `wrapping()` |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | `cleanText()`, `setSpecialValueText()` |
| `setMinimumSize()`, `setMaximumSize()` | `setDisplayIntegerBase()`, `setButtonSymbols()` |
| `setOnValueChanged()` | `selectAll()`, `setFocus()` |

### QDial
**覆盖度：80%**

| 已有 | 缺失 |
|------|------|
| `setValue()`, `value()`, `setRange()`, `setSingleStep()` | `setNotchTarget()` |
| `setWrapping()`, `wrapping()` | `setPageStep()` |
| `setNotchesVisible()`, `notchesVisible()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `setOnValueChanged()` | |

### QLCDNumber
**覆盖度：85%**

| 已有 | 缺失 |
|------|------|
| `display()`, `displayInt()`, `checkOverflow()` | `setStyleSheet()` 已在源文件中有，文档待补齐 |
| `setMode()`, `mode()` | |
| `setSegmentStyle()`, `segmentStyle()` | |
| `setSmallDecimalPoint()`, `smallDecimalPoint()` | |
| `digitCount()`, `setDigitCount()` | |
| `setEnabled()`, `isEnabled()` | |
| `setMinimumSize()`, `setMaximumSize()` | |

### QToolButton
**覆盖度：80%**

| 已有 | 缺失 |
|------|------|
| `setText()`, `setIcon()`, `setIconSize()` | **`text()` getter** |
| `setToolButtonStyle()`, `setPopupMode()` | `defaultAction()`, `setDefaultAction()` |
| `setAutoRaise()` / `autoRaise()`, `setArrowType()` | |
| `setMenu()`, `showMenu()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `setOnClick()`, `disconnectClicked()` | |

### QProgressBar
**覆盖度：80%**

| 已有 | 缺失 |
|------|------|
| `setValue()` / `value()`, `setRange()` | `setMinimum()` / `setMaximum()`（直接用 setRange 替代） |
| `setFormat()` / `format()`, `setTextVisible()` | `text()` getter |
| `setOrientation()`, `setInvertedAppearance()`, `reset()` | `setAlignment()` |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |

### QCheckBox
**覆盖度：85%**

| 已有 | 缺失 |
|------|------|
| `setText()`, `text()` | **`setTristate()`**, `isTristate()` |
| `setChecked()` / `isChecked()` | `checkState()`, `setCheckState()` |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `setOnStateChanged()` | |

### QRadioButton
**覆盖度：80%**

| 已有 | 缺失 |
|------|------|
| `setText()`, `text()` | `autoExclusive()` |
| `setChecked()` / `isChecked()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `setOnToggled()` | |

### QTabWidget
**覆盖度：80%**

| 已有 | 缺失 |
|------|------|
| `addTab()`, `removeTab()`, `insertTab()`, `count()` | `setTabIcon()`, `setIconSize()` |
| `currentIndex()`, `setCurrentIndex()` | `setDocumentMode()`, `setElideMode()` |
| `setTabText()`, `tabText()`, `setTabToolTip()` | `setTabPosition()`, `setTabShape()` |
| `setTabsClosable()`, `setMovable()`, `clear()` | `setUsesScrollButtons()` |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |
| `setOnCurrentChanged()` | |

### QGroupBox
**覆盖度：75%**

| 已有 | 缺失 |
|------|------|
| `setTitle()` / `title()` | `setAlignment()` / `alignment()` |
| `setCheckable()` / `isCheckable()` | `setFlat()` / `isFlat()` |
| `setChecked()` / `isChecked()` | |
| `setLayout()` | |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |

### QSplitter
**覆盖度：75%**

| 已有 | 缺失 |
|------|------|
| `addWidget()`, `count()` | `insertWidget()`, `replaceWidget()` |
| `setStretchFactor()`, `setHandleWidth()` | `setSizes()` / `sizes()` |
| `setOrientation()` / `orientation()` | `restoreState()` / `saveState()` |
| `setChildrenCollapsible()` / `childrenCollapsible()` | `setOpaqueResize()` |
| `handleWidth()` | |

### QFrame
**覆盖度：60%**

| 已有 | 缺失 |
|------|------|
| `setFrameShape()`, `setFrameShadow()`, `setLineWidth()` | **`frameShape()`**, `frameShadow()`, `lineWidth()` getter |
| `setLayout()` | **`frameWidth()`** |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | |
| `setMinimumSize()`, `setMaximumSize()` | |

### QScrollArea
**覆盖度：60%**

| 已有 | 缺失 |
|------|------|
| `setWidget()`, `setWidgetResizable()`, `widget()` | **`setAlignment()`**, `alignment()` |
| `setEnabled()`, `isEnabled()`, `setStyleSheet()` | `setFrameShape()`, `setFrameShadow()` |
| `setMinimumSize()`, `setMaximumSize()` | `setHorizontalScrollBarPolicy()`, `setVerticalScrollBarPolicy()` |
| | `ensureVisible()`, `ensureWidgetVisible()` |

---

## 3. 封装不足的控件 ❌

*（所有基础控件均已完成基本封装，暂无评级为 ❌ 的控件）*

---

## 4. 跨控件共性问题

### 4.1 QWidget 基类方法覆盖情况

以下表格反映当前各控件暴露 `setEnabled`/`isEnabled`、`setStyleSheet`、`setMinimumSize`/`setMaximumSize` 的状况：

| 控件 | `setEnabled`/`isEnabled` | `setStyleSheet` | `setMinimumSize`/`setMaximumSize` |
|------|------------------------|-----------------|----------------------------------|
| QLabel | ✅ | ✅ | ❌ |
| QPushButton | ✅ | ✅ | ❌ |
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
| QTextEdit | ❌ | ✅（命名不统一） | ✅ |
| QGroupBox | ✅ | ✅ | ✅ |
| QTabWidget | ✅ | ✅ | ✅ |
| QScrollArea | ✅ | ✅ | ✅ |
| QFrame | ✅ | ✅ | ✅ |
| QSplitter | ❌ | ❌ | ❌ |

**待补齐**：
- QLabel — `setMinimumSize`/`setMaximumSize`
- QPushButton — `setMinimumSize`/`setMaximumSize`
- QTextEdit — `setEnabled`/`isEnabled`
- QSplitter — `setEnabled`/`isEnabled`, `setStyleSheet`, `setMinimumSize`/`setMaximumSize`

### 4.2 `setStyleSheet` 命名不统一
- 大部分控件：`setStyleSheet(style: String)`
- QTextEdit：同时存在 `setStyleSheet()` 和 `setWidgetStyleSheet()` 两个方法 ❌

### 4.3 QtResource 实现不一致
实现了 QtResource（checkValid/close/isClosed）的控件：
- ✅ QWidget, QLabel, QPushButton, QSpinBox
- ❌ QTextEdit, QComboBox, QCheckBox, QRadioButton, QSlider, QProgressBar, QDial, QLCDNumber, QToolButton, QTabWidget, QGroupBox, QScrollArea, QFrame, QSplitter

---

## 5. 完善优先级

| 优先级 | 任务 | 原因 |
|--------|------|------|
| P0 🔥 | QLabel/QPushButton 补齐 `setMinimumSize`/`setMaximumSize` | 最常用基础控件 |
| P0 🔥 | QTextEdit 补齐 `setEnabled`/`isEnabled`，统一 `setStyleSheet` 命名 | 消除不一致 |
| P0 🔥 | QSplitter 补齐 `setEnabled`/`isEnabled`、`setStyleSheet`、`setMinimumSize`/`setMaximumSize` | 容器控件基础功能 |
| P1 | QComboBox 补齐 `setIconSize` | 下拉框图标配置 |
| P1 | QTabWidget 补齐 `setTabIcon`、`setIconSize` | 标签页图标常用 |
| P1 | QSlider 补齐 `setInvertedAppearance` | Qt 原生方法遗漏 |
| P2 | QDoubleSpinBox 补齐 `setPrefix`/`setSuffix`/`setWrapping`/`cleanText` | 数据显示格式化 |
| P2 | QFrame 补齐 getter 方法 | 对称性改进 |
| P2 | QScrollArea 补齐滚动策略和 `ensureVisible` | 滚动区域进阶功能 |
| P3 | QtResource 统一实现 | 结构性改进，不影响日常使用 |
