# CJQT6 选择与数值控件模块

本模块包含当前源码中实际支持的选择控件和数值控件 API。

## 选择控件

### QCheckBox - 复选框

```cangjie
import cjqt6.widgets.*

let checkbox = QCheckBox()
checkbox.setText("选项A")
checkbox.setChecked(true)
checkbox.setOnStateChanged({ state: Int32 => println("state=${state}") })
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` / `text(): String` | 设置/获取文本 |
| `setChecked(checked: Bool)` / `isChecked(): Bool` | 设置/获取选中状态 |
| `setCheckState(state: Int32)` / `checkState(): Int32` | 设置/获取三态状态 |
| `setTristate(tristate: Bool)` / `isTristate(): Bool` | 设置/获取三态支持 |
| `setOnStateChanged(callback: Int32Callback)` | 状态变化回调 |
| `disconnectStateChanged()` | 断开状态变化信号 |
| `setOnClicked(callback: Int32Callback)` | 点击回调（带 checked 状态） |
| `setEnabled(enabled: Bool)` / `isEnabled(): Bool` | 启用/禁用状态 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` / `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最小/最大尺寸 |
| `show()` / `hide()` / `resize(width, height)` | 控件显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

**状态常量**:
```cangjie
CheckState.Unchecked
CheckState.PartiallyChecked
CheckState.Checked
```

### QRadioButton - 单选按钮

```cangjie
import cjqt6.widgets.*

let radio1 = QRadioButton()
radio1.setText("选项1")
radio1.setChecked(true)
radio1.setOnToggled({ state: Int32 => println("state=${state}") })
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` / `text(): String` | 设置/获取文本 |
| `setChecked(checked: Bool)` / `isChecked(): Bool` | 设置/获取选中状态 |
| `setOnToggled(callback: Int32Callback)` | 切换回调 |
| `disconnectToggled()` | 断开切换信号 |
| `setEnabled(enabled: Bool)` / `isEnabled(): Bool` | 启用/禁用状态 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` / `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最小/最大尺寸 |
| `show()` / `hide()` / `resize(width, height)` | 控件显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

### QComboBox - 下拉框

```cangjie
import cjqt6.widgets.*

let combo = QComboBox()
combo.addItem("选项1")
combo.addItem("选项2")
combo.setCurrentIndex(0)
combo.setOnCurrentIndexChanged({ index: Int32 => println(index) })
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `addItem(text: String)` | 添加项 |
| `addItems(items: String)` | 批量添加选项（使用换行符分隔） |
| `insertItem(index: Int32, text: String)` | 在指定位置插入选项 |
| `removeItem(index: Int32)` | 移除指定索引的选项 |
| `clear()` | 清空所有项 |
| `count(): Int32` | 获取选项数量 |
| `itemText(index: Int32): String` | 获取指定索引的文本 |
| `setItemText(index: Int32, text: String)` | 设置指定索引的文本 |
| `currentText(): String` | 获取当前文本 |
| `currentIndex(): Int32` | 获取当前索引 |
| `setCurrentIndex(index: Int32)` | 设置当前索引 |
| `setCurrentText(text: String)` | 通过文本设置当前选中项 |
| `findText(text: String): Int32` | 查找文本索引 |
| `setPlaceholderText(text: String)` | 设置占位文本 |
| `setEditable(editable: Bool)` / `isEditable(): Bool` | 设置/获取是否可编辑 |
| `setInsertPolicy(policy: Int32)` / `insertPolicy(): Int32` | 设置/获取插入策略 |
| `setMaxVisibleItems(max: Int32)` / `maxVisibleItems(): Int32` | 设置/获取最大可见项数 |
| `setMaxCount(max: Int32)` / `maxCount(): Int32` | 设置/获取最大条目数 |
| `setFrame(frame: Bool)` / `hasFrame(): Bool` | 设置/获取边框显示 |
| `setDuplicatesEnabled(enabled: Bool)` | 设置是否允许重复项 |
| `setCurrentData(value: Int64)` | 通过用户数据设置当前项 |
| `setCompleter(completerPtr: Int64)` | 设置补全器 |
| `setSizeAdjustPolicy(policy: Int32)` | 设置尺寸自适应策略 |
| `setOnEditTextChanged(callback: CStringCallback)` | 编辑框文本变化回调 |
| `setOnActivated(callback: Int32Callback)` | 用户激活项回调 |
| `setOnHighlighted(callback: Int32Callback)` | 高亮项回调 |
| `setOnCurrentIndexChanged(callback: Int32Callback)` | 索引变化回调 |
| `disconnectCurrentIndexChanged()` | 断开索引变化信号 |
| `setOnCurrentTextChanged(callback: CStringCallback)` | 当前文本变化回调 |
| `disconnectCurrentTextChanged()` | 断开当前文本变化回调 |
| `setEnabled(enabled: Bool)` / `isEnabled(): Bool` | 启用/禁用状态 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` / `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最小/最大尺寸 |
| `show()` / `hide()` / `resize(width, height)` | 控件显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

**策略常量**:
```cangjie
ComboBoxInsertPolicy.NoInsert
ComboBoxInsertPolicy.InsertAtTop
ComboBoxInsertPolicy.InsertAtCurrent
ComboBoxInsertPolicy.InsertAtBottom
ComboBoxInsertPolicy.InsertAfterCurrent
ComboBoxInsertPolicy.InsertBeforeCurrent
ComboBoxInsertPolicy.InsertAlphabetically

ComboBoxSizeAdjustPolicy.AdjustToContents
ComboBoxSizeAdjustPolicy.AdjustToContentsOnFirstShow
ComboBoxSizeAdjustPolicy.AdjustToMinimumContentsLengthWithIcon
```

---

## 数值控件

### QSpinBox - 整数旋转框

```cangjie
import cjqt6.widgets.*

let spinBox = QSpinBox()
spinBox.setRange(0, 100)
spinBox.setValue(50)
spinBox.setSingleStep(5)
spinBox.setOnValueChanged({ value: Int32 => println(value) })
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `setValue(value: Int32)` / `value(): Int32` | 设置/获取值 |
| `setRange(min: Int32, max: Int32)` | 设置范围 |
| `setSingleStep(step: Int32)` | 设置步长 |
| `setPrefix(prefix: String)` / `prefix(): String` | 设置/获取前缀 |
| `setSuffix(suffix: String)` / `suffix(): String` | 设置/获取后缀 |
| `setWrapping(wrapping: Bool)` / `wrapping(): Bool` | 设置/获取循环模式 |
| `setSpecialValueText(text: String)` | 设置特殊值文本 |
| `cleanText(): String` | 获取纯净文本 |
| `setEnabled(enabled: Bool)` / `isEnabled(): Bool` | 启用/禁用状态 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` / `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最小/最大尺寸 |
| `setOnValueChanged(callback: Int32Callback)` | 值变化回调 |
| `disconnectValueChanged()` | 断开值变化信号 |
| `show()` / `hide()` / `resize(width, height)` | 控件显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

**纠正模式常量** (`SpinBoxCorrectionMode`，对应 QAbstractSpinBox::CorrectionMode):
| 常量 | 值 | 说明 |
|------|-----|------|
| `SpinBoxCorrectionMode.CorrectToPreviousValue` | 0 | 纠正为上一次有效值 |
| `SpinBoxCorrectionMode.CorrectToNearestValue` | 1 | 纠正为最近的有效值 |

**按钮符号常量** (`SpinBoxButtonSymbols`，对应 QAbstractSpinBox::ButtonSymbols):
| 常量 | 值 | 说明 |
|------|-----|------|
| `SpinBoxButtonSymbols.UpDownArrows` | 0 | 上下箭头 |
| `SpinBoxButtonSymbols.PlusMinus` | 1 | 加号/减号 |
| `SpinBoxButtonSymbols.NoButtons` | 2 | 无按钮 |

### QSlider - 滑动条

```cangjie
import cjqt6.widgets.*

let slider = QSlider()
slider.setRange(0, 100)
slider.setValue(50)
slider.setOrientation(Horizontal)
slider.setTickPosition(TicksBelow)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `setValue(value: Int32)` / `value(): Int32` | 设置/获取值 |
| `setRange(min: Int32, max: Int32)` | 设置范围 |
| `setOrientation(orientation: Int32)` | 设置方向 |
| `setSingleStep(step: Int32)` / `singleStep(): Int32` | 设置/获取单步步长 |
| `setPageStep(step: Int32)` / `pageStep(): Int32` | 设置/获取页步步长 |
| `setTickPosition(position: Int32)` / `tickPosition(): Int32` | 设置/获取刻度位置 |
| `setTickInterval(interval: Int32)` / `tickInterval(): Int32` | 设置/获取刻度间隔 |
| `setInvertedControls(inverted: Bool)` / `invertedControls(): Bool` | 设置/获取反向控制 |
| `setTracking(enable: Bool)` / `hasTracking(): Bool` | 设置/获取追踪模式 |
| `setOnValueChanged(callback: Int32Callback)` | 值变化回调 |
| `disconnectValueChanged()` | 断开值变化信号 |
| `setOnSliderMoved(callback: Int32Callback)` | 滑块拖动回调 |
| `disconnectSliderMoved()` | 断开滑块拖动信号 |
| `setOnSliderPressed(callback: Int64Callback)` | 滑块按下回调 |
| `setOnSliderReleased(callback: Int64Callback)` | 滑块释放回调 |
| `setEnabled(enabled: Bool)` / `isEnabled(): Bool` | 启用/禁用状态 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` / `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最小/最大尺寸 |
| `show()` / `hide()` / `resize(width, height)` | 控件显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

**方向与刻度常量**:
```cangjie
Horizontal
Vertical
NoTicks
TicksAbove
TicksBelow
TicksLeft
TicksRight
TicksBothSides
```

### QDoubleSpinBox - 浮点旋转框

双精度数值输入控件，支持小数位、前缀/后缀、范围与步长控制。

```cangjie
import cjqt6.widgets.*

let spinBox = QDoubleSpinBox()
spinBox.setRange(0.0, 100.0)
spinBox.setDecimals(2)            // 两位小数
spinBox.setValue(50.5)
spinBox.setSingleStep(0.5)
spinBox.setPrefix("$")            // 前缀
spinBox.setSuffix(" 元")          // 后缀
spinBox.setWrapping(true)         // 循环
spinBox.setGroupSeparatorShown(true)  // 千位分隔符
spinBox.setOnValueChanged({ value: Float64 => println(value) })
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setValue(value: Float64)` / `value(): Float64` | 设置/获取值 |
| `setRange(min: Float64, max: Float64)` | 设置范围 |
| `setSingleStep(step: Float64)` | 设置步长 |
| `setDecimals(decimals: Int32)` / `decimals(): Int32` | 设置/获取小数位数 |
| `setPrefix(prefix: String)` / `prefix(): String` | 设置/获取前缀 |
| `setSuffix(suffix: String)` / `suffix(): String` | 设置/获取后缀 |
| `setSpecialValueText(text: String)` | 设置特殊值文本（最小值时显示） |
| `setMinimum(value: Float64)` / `minimum(): Float64` | 设置/获取最小值 |
| `setMaximum(value: Float64)` / `maximum(): Float64` | 设置/获取最大值 |
| `setStepType(stepType: Int32)` | 设置步长类型（DoubleSpinBoxStepType） |
| `setGroupSeparatorShown(shown: Bool)` | 设置千位分隔符 |
| `setWrapping(wrap: Bool)` / `wrapping(): Bool` | 设置/获取循环 |
| `setButtonSymbols(symbols: Int32)` | 设置按钮符号（SpinBoxButtonSymbols） |
| `cleanText(): String` | 获取纯净文本（无前后缀） |
| `text(): String` | 获取完整文本 |
| `selectAll()` / `setFocus()` | 全选/聚焦 |
| `setOnValueChanged(callback: Float64Callback)` | 值变化回调 |
| `setOnTextChanged(callback: CStringCallback)` | 文本变化回调 |
| `setOnEditingFinished(callback: VoidCallback)` | 编辑结束回调 |
| `disconnectValueChanged()` / `disconnect()` | 断开信号 |
| `setEnabled(enabled: Bool)` / `isEnabled(): Bool` | 启用/禁用 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` / `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最小/最大尺寸 |
| `show()` / `hide()` / `resize(width, height)` | 显示与尺寸 |
| `getPtr(): Int64` / `close()` / `delete()` | 指针与资源释放 |

**步长类型常量**:
```cangjie
DoubleSpinBoxStepType.DefaultStepType            // 0 固定步长
DoubleSpinBoxStepType.AdaptiveDecimalStepType    // 1 自适应小数步长
```

### QDial - 旋钮控件

圆形旋钮，常用于音量、亮度等连续值调节。

```cangjie
import cjqt6.widgets.*

let dial = QDial()
dial.setRange(0, 100)
dial.setValue(50)
dial.setNotchesVisible(true)      // 显示刻度
dial.setNotchTarget(10.0)         // 刻度间距（像素）
dial.setPageStep(10)              // 翻页步长
dial.setWrapping(true)            // 循环
dial.setOnValueChanged({ value: Int32 => println(value) })
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setValue(value: Int32)` / `value(): Int32` | 设置/获取值 |
| `setRange(min: Int32, max: Int32)` | 设置范围 |
| `setSingleStep(step: Int32)` | 设置步长 |
| `setWrapping(wrapping: Bool)` / `wrapping(): Bool` | 设置/获取循环 |
| `setNotchesVisible(visible: Bool)` / `notchesVisible(): Bool` | 设置/获取刻度可见 |
| `setNotchTarget(target: Float64)` / `notchTarget(): Float64` | 设置/获取刻度间距 |
| `setPageStep(step: Int32)` / `pageStep(): Int32` | 设置/获取翻页步长 |
| `setOnValueChanged(callback: Int32Callback)` | 值变化回调 |
| `disconnectValueChanged()` / `disconnect()` | 断开信号 |
| `setEnabled(enabled: Bool)` / `isEnabled(): Bool` | 启用/禁用 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` / `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最小/最大尺寸 |
| `show()` / `hide()` / `resize(width, height)` | 显示与尺寸 |
| `getPtr(): Int64` / `close()` / `delete()` | 指针与资源释放 |

---

## 按钮分组

### QButtonGroup - 按钮分组

管理一组按钮的互斥行为，常用于多个 QRadioButton 的分组。

```cangjie
import cjqt6.widgets.*

let group = QButtonGroup()
group.setExclusive(true)                    // 互斥（默认 true）

group.addButton(radio1.getPtr(), 1)         // 添加按钮并指定 ID
group.addButton(radio2.getPtr(), 2)
group.addButton(radio3.getPtr(), 3)

let checkedId = group.checkedId()           // 当前选中按钮 ID（无则 -1）
let btnPtr = group.checkedButton()          // 当前选中按钮指针
let btnPtr2 = group.button(2)               // 按 ID 获取按钮

group.setOnIdClicked({ id: Int32 =>
    println("点击了 ID=${id}")
})
group.setOnButtonToggled({ btn: Int64, checked: Int32 =>
    println("按钮切换 checked=${checked}")
})

group.delete()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建按钮分组 |
| `addButton(btnPtr: Int64, id: Int32)` | 添加按钮并指定 ID |
| `removeButton(btnPtr: Int64)` | 移除按钮 |
| `setExclusive(exclusive: Bool)` / `isExclusive(): Bool` | 设置/获取互斥 |
| `checkedId(): Int32` | 当前选中按钮 ID（无则 -1） |
| `checkedButton(): Int64` | 当前选中按钮指针 |
| `button(id: Int32): Int64` | 按 ID 获取按钮指针 |
| `setId(btnPtr: Int64, id: Int32)` | 设置按钮 ID |
| `id(btnPtr: Int64): Int32` | 获取按钮 ID |
| `buttonsCount(): Int32` | 按钮数量 |
| `setOnButtonClicked(callback: Int64Callback)` | 点击回调（按钮指针） |
| `setOnButtonPressed(callback: Int64Callback)` | 按下回调（按钮指针） |
| `setOnButtonReleased(callback: Int64Callback)` | 释放回调（按钮指针） |
| `setOnButtonToggled(callback: Int64Int32Callback)` | 切换回调（指针, 选中状态） |
| `setOnIdClicked(callback: Int32Callback)` | ID 点击回调 |
| `getPtr(): Int64` / `delete()` | 指针与资源释放 |
