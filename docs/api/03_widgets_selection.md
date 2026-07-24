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
