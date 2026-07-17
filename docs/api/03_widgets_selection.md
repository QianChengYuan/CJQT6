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
| `setChecked(checked: Bool)` | 设置选中状态 |
| `isChecked(): Bool` | 获取选中状态 |
| `setOnStateChanged(callback: Int32Callback)` | 状态变化回调 |
| `disconnect()` | 断开信号连接 |

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
| `setChecked(checked: Bool)` | 设置选中状态 |
| `isChecked(): Bool` | 获取选中状态 |
| `setOnToggled(callback: VoidCallback)` | 切换回调 |
| `disconnect()` | 断开信号连接 |

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
| `clear()` | 清空所有项 |
| `currentText(): String` | 获取当前文本 |
| `currentIndex(): Int32` | 获取当前索引 |
| `setCurrentIndex(index: Int32)` | 设置当前索引 |
| `setOnCurrentIndexChanged(callback: Int32Callback)` | 索引变化回调 |
| `disconnect()` | 断开信号连接 |

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
| `setOnValueChanged(callback: Int32Callback)` | 值变化回调 |
| `disconnect()` | 断开信号连接 |

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
| `setOnValueChanged(callback: Int32Callback)` | 值变化回调 |
| `disconnect()` | 断开信号连接 |

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
