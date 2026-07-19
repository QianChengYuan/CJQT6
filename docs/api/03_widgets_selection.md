# CJQT6 选择与数值控件模块

本模块包含选择控件和数值控件。

## 选择控件

### QCheckBox - 复选框

```cangjie
let checkbox = QCheckBox()
checkbox.setText("选项A")
checkbox.setChecked(true)

if (checkbox.isChecked()) {
    println("已选中")
}

// 状态变化回调
let stateCallback: Int32Callback = { state: Int32 =>
    println("状态: ${state}")
}
checkbox.setOnStateChanged(stateCallback)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` | 设置文本 |
| `text(): String` | 获取文本 |
| `setChecked(checked: Bool)` | 设置选中状态 |
| `isChecked(): Bool` | 获取选中状态 |
| `setEnabled(enabled: Bool)` | 设置启用/禁用 |
| `isEnabled(): Bool` | 检查是否启用 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` | 设置最小尺寸 |
| `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最大尺寸 |
| `setOnStateChanged(callback: Int32Callback)` | 状态变化回调（0=未选中, 1=部分选中, 2=选中） |
| `disconnectStateChanged()` | 断开状态变化信号 |
| `show()` | 显示控件 |
| `hide()` | 隐藏控件 |
| `resize(width: Int32, height: Int32)` | 调整大小 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

### QRadioButton - 单选按钮

```cangjie
let radio1 = QRadioButton()
radio1.setText("选项1")
radio1.setChecked(true)

let radio2 = QRadioButton()
radio2.setText("选项2")

// 切换回调
let toggleCallback: VoidCallback = { =>
    println("单选按钮切换")
}
radio1.setOnToggled(toggleCallback)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` | 设置文本 |
| `text(): String` | 获取文本 |
| `setChecked(checked: Bool)` | 设置选中状态 |
| `isChecked(): Bool` | 获取选中状态 |
| `setEnabled(enabled: Bool)` | 设置启用/禁用 |
| `isEnabled(): Bool` | 检查是否启用 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` | 设置最小尺寸 |
| `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最大尺寸 |
| `setOnToggled(callback: Int32Callback)` | 切换回调（0=未选中, 1=其他, 2=选中） |
| `disconnectToggled()` | 断开切换信号 |
| `show()` | 显示控件 |
| `hide()` | 隐藏控件 |
| `resize(width: Int32, height: Int32)` | 调整大小 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

### QComboBox - 下拉框

```cangjie
let combo = QComboBox()
combo.addItem("选项1")
combo.addItem("选项2")
combo.addItem("选项3")

let currentText = combo.currentText()
let currentIndex = combo.currentIndex()

// 索引变化回调
let indexCallback: Int32Callback = { index: Int32 =>
    println("选中索引: ${index}")
}
combo.setOnCurrentIndexChanged(indexCallback)
```

**方法**:
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
| `findText(text: String): Int32` | 查找文本的索引（未找到返回-1） |
| `setPlaceholderText(text: String)` | 设置占位文本 |
| `setEditable(editable: Bool)` | 设置是否可编辑 |
| `setEnabled(enabled: Bool)` | 设置启用/禁用 |
| `isEnabled(): Bool` | 检查是否启用 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` | 设置最小尺寸 |
| `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最大尺寸 |
| `setOnCurrentIndexChanged(callback: Int32Callback)` | 索引变化回调 |
| `disconnectCurrentIndexChanged()` | 断开索引变化信号 |
| `setOnCurrentTextChanged(callback: CStringCallback)` | 当前文本变化回调 |
| `disconnectCurrentTextChanged()` | 断开当前文本变化回调 |
| `show()` | 显示控件 |
| `hide()` | 隐藏控件 |
| `resize(width: Int32, height: Int32)` | 调整大小 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

---

## 数值控件

### QSpinBox - 整数旋转框

```cangjie
let spinBox = QSpinBox()
spinBox.setRange(0, 100)
spinBox.setValue(50)
spinBox.setSingleStep(5)

let value = spinBox.value()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setValue(value: Int32)` | 设置值 |
| `value(): Int32` | 获取值 |
| `setRange(min: Int32, max: Int32)` | 设置范围 |
| `setSingleStep(step: Int32)` | 设置步长 |
| `setPrefix(prefix: String)` | 设置前缀（如 "$"） |
| `prefix(): String` | 获取前缀 |
| `setSuffix(suffix: String)` | 设置后缀（如 "cm"） |
| `suffix(): String` | 获取后缀 |
| `setWrapping(wrapping: Bool)` | 设置是否循环（超出范围后回到另一头） |
| `wrapping(): Bool` | 是否循环 |
| `setSpecialValueText(text: String)` | 设置特殊值文本（值为最小值时显示） |
| `cleanText(): String` | 获取纯净文本（无前缀后缀无空白） |
| `setEnabled(enabled: Bool)` | 设置启用/禁用 |
| `isEnabled(): Bool` | 检查是否启用 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` | 设置最小尺寸 |
| `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最大尺寸 |
| `setOnValueChanged(callback: Int32Callback)` | 值变化回调 |
| `disconnectValueChanged()` | 断开值变化信号 |
| `close()` | 释放资源（实现 QtResource） |
| `isClosed(): Bool` | 是否已释放 |
| `isValid(): Bool` | 对象是否有效 |
| `show()` | 显示控件 |
| `hide()` | 隐藏控件 |
| `resize(width: Int32, height: Int32)` | 调整大小 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

### QSlider - 滑动条

```cangjie
let slider = QSlider()
slider.setRange(0, 100)
slider.setValue(50)
slider.setOrientation(Horizontal)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setValue(value: Int32)` | 设置值 |
| `value(): Int32` | 获取值 |
| `setRange(min: Int32, max: Int32)` | 设置范围 |
| `setOrientation(orientation: Int32)` | 设置方向 |
| `setSingleStep(step: Int32)` | 设置单步步长 |
| `singleStep(): Int32` | 获取单步步长 |
| `setPageStep(step: Int32)` | 设置页步步长（点击轨道时） |
| `pageStep(): Int32` | 获取页步步长 |
| `setTickPosition(position: Int32)` | 设置刻度位置 |
| `tickPosition(): Int32` | 获取刻度位置 |
| `setTickInterval(interval: Int32)` | 设置刻度间隔 |
| `tickInterval(): Int32` | 获取刻度间隔 |
| `setInvertedControls(inverted: Bool)` | 设置反向控制 |
| `invertedControls(): Bool` | 是否反向控制 |
| `setTracking(enable: Bool)` | 设置追踪模式（拖动时实时触发 valueChanged） |
| `hasTracking(): Bool` | 是否启用追踪模式 |
| `setEnabled(enabled: Bool)` | 设置启用/禁用 |
| `isEnabled(): Bool` | 检查是否启用 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` | 设置最小尺寸 |
| `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最大尺寸 |
| `setOnValueChanged(callback: Int32Callback)` | 值变化回调 |
| `disconnectValueChanged()` | 断开值变化信号 |
| `setOnSliderMoved(callback: Int32Callback)` | 滑块拖动回调（拖动过程中实时触发） |
| `disconnectSliderMoved()` | 断开滑块拖动信号 |
| `setOnSliderPressed(callback: Int64Callback)` | 滑块按下回调 |
| `setOnSliderReleased(callback: Int64Callback)` | 滑块释放回调 |
| `show()` | 显示控件 |
| `hide()` | 隐藏控件 |
| `resize(width: Int32, height: Int32)` | 调整大小 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

**方向常量**:
```cangjie
Horizontal  // 水平
Vertical    // 垂直
```

### QProgressBar - 进度条

```cangjie
let progress = QProgressBar()
progress.setRange(0, 100)
progress.setValue(75)
progress.setTextVisible(true)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setValue(value: Int32)` | 设置值 |
| `value(): Int32` | 获取值 |
| `setRange(min: Int32, max: Int32)` | 设置范围 |
| `setTextVisible(visible: Bool)` | 是否显示文本 |
| `setFormat(format: String)` | 设置显示格式（如 `"%p%"` 显示百分比，`"%v"` 显示实际值） |
| `format(): String` | 获取显示格式 |
| `setOrientation(orientation: Int32)` | 设置方向 |
| `setInvertedAppearance(invert: Bool)` | 设置反向外观 |
| `reset()` | 重置进度条 |
| `setEnabled(enabled: Bool)` | 设置启用/禁用 |
| `isEnabled(): Bool` | 检查是否启用 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` | 设置最小尺寸 |
| `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最大尺寸 |
| `show()` | 显示控件 |
| `hide()` | 隐藏控件 |
| `resize(width: Int32, height: Int32)` | 调整大小 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

### QDial - 旋钮控件

用于在圆形范围内选择数值，类似音量旋钮。

```cangjie
let dial = QDial()
dial.setRange(0, 100)
dial.setValue(50)
dial.setSingleStep(5)
dial.setWrapping(true)       // 允许循环旋转
dial.setNotchesVisible(true) // 显示刻度
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建旋钮 |
| `setValue(value: Int32)` | 设置值 |
| `value(): Int32` | 获取值 |
| `setRange(min: Int32, max: Int32)` | 设置范围 |
| `setSingleStep(step: Int32)` | 设置步长 |
| `setWrapping(wrapping: Bool)` | 设置是否循环 |
| `wrapping(): Bool` | 获取是否循环 |
| `setNotchesVisible(visible: Bool)` | 设置刻度是否可见 |
| `notchesVisible(): Bool` | 获取刻度是否可见 |
| `setOnValueChanged(callback: Int32Callback)` | 值变化回调 |
| `disconnectValueChanged()` | 断开值变化信号 |
| `show()` | 显示控件 |
| `hide()` | 隐藏控件 |
| `resize(width: Int32, height: Int32)` | 调整大小 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

### QDoubleSpinBox - 双精度旋转框

与 QSpinBox 类似，但支持浮点数值。

```cangjie
let doubleSpin = QDoubleSpinBox()
doubleSpin.setRange(0.0, 100.0)
doubleSpin.setValue(50.5)
doubleSpin.setSingleStep(0.5)
doubleSpin.setDecimals(2)  // 保留2位小数
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建双精度旋转框 |
| `setValue(value: Float64)` | 设置值 |
| `value(): Float64` | 获取值 |
| `setRange(min: Float64, max: Float64)` | 设置范围 |
| `setSingleStep(step: Float64)` | 设置步长 |
| `setDecimals(decimals: Int32)` | 设置小数位数 |
| `decimals(): Int32` | 获取小数位数 |
| `setOnValueChanged(callback: Float64Callback)` | 值变化回调 |
| `disconnectValueChanged()` | 断开值变化信号 |
| `show()` | 显示控件 |
| `hide()` | 隐藏控件 |
| `resize(width: Int32, height: Int32)` | 调整大小 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |
