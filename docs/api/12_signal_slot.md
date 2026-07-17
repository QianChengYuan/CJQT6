# CJQT6 信号与槽模块

CJQT6使用CFunc回调实现信号槽机制。

## 回调类型

```cangjie
// 无参数回调
public type VoidCallback = CFunc<() -> Unit>

// Int32参数回调
public type Int32Callback = CFunc<(Int32) -> Unit>

// CString参数回调
public type CStringCallback = CFunc<(CString) -> Unit>

// Float64参数回调
public type Float64Callback = CFunc<(Float64) -> Unit>
```

---

## 重要说明：CFunc 的限制

**CFunc 闭包不能捕获局部变量**，只能：
- 使用全局变量
- 使用参数

因此，如果需要在回调中访问其他控件，必须使用全局变量：

```cangjie
// ❌ 错误：不能捕获局部变量
main(): Int32 {
    let label = QLabel()
    let callback: VoidCallback = { =>
        label.setText("clicked")  // 编译错误！
    }
}

// ✅ 正确：使用全局变量
var globalLabel: ?QLabel = None

let callback: VoidCallback = { =>
    if (let Some(label) <- globalLabel) {
        label.setText("clicked")
    }
}

main(): Int32 {
    let app = QApplication()
    let label = QLabel()
    globalLabel = label  // 保存到全局变量
    // ...
}
```

---

## 基本用法

```cangjie
// 按钮点击回调
let clickCallback: VoidCallback = { =>
    println("按钮被点击！")
}
btn.setOnClick(clickCallback)

// 滑块值变化回调
let valueCallback: Int32Callback = { value: Int32 =>
    println("值改变了: ${value}")
}
slider.setOnValueChanged(valueCallback)

// 文本变化回调
let textCallback: CStringCallback = { text: CString =>
    println("文本: ${text}")
}
lineEdit.setOnTextChanged(textCallback)
```

---

## 支持信号的控件

| 控件 | 方法 | 回调类型 | 说明 |
|------|------|----------|------|
| QWidget | `setOnDestroyed(callback)` | VoidCallback | 控件销毁 |
| QPushButton | `setOnClick(callback)` | VoidCallback | 点击 |
| QLineEdit | `setOnTextChanged(callback)` | CStringCallback | 文本变化 |
| QLineEdit | `setOnReturnPressed(callback)` | VoidCallback | 回车键按下 |
| QLineEdit | `setOnEditingFinished(callback)` | VoidCallback | 编辑完成（失焦或回车） |
| QSpinBox | `setOnValueChanged(callback)` | Int32Callback | 值变化 |
| QSlider | `setOnValueChanged(callback)` | Int32Callback | 值变化（释放时） |
| QSlider | `setOnSliderMoved(callback)` | Int32Callback | 滑块拖动中 |
| QCheckBox | `setOnStateChanged(callback)` | Int32Callback | 状态变化 |
| QRadioButton | `setOnToggled(callback)` | VoidCallback | 切换 |
| QComboBox | `setOnCurrentIndexChanged(callback)` | Int32Callback | 索引变化 |
| QComboBox | `setOnCurrentTextChanged(callback)` | CStringCallback | 文本变化 |
| QAction | `setOnTriggered(callback)` | VoidCallback | 触发 |
| QTimer | `setTimeout(callback)` | VoidCallback | 超时 |

---

## 断开信号连接

所有支持信号的控件都提供了对应的 `disconnect*()` 方法：

```cangjie
// QLineEdit
lineEdit.disconnectTextChanged()
lineEdit.disconnectReturnPressed()
lineEdit.disconnectEditingFinished()

// QComboBox
comboBox.disconnectCurrentIndexChanged()
comboBox.disconnectCurrentTextChanged()

// 其他控件
button.disconnectClick()
slider.disconnectValueChanged()
checkBox.disconnectStateChanged()
radioButton.disconnectToggled()
timer.disconnect()
```

---

## 回调中访问控件

由于CFunc不能捕获外部变量，如需在回调中访问其他控件，可使用全局变量：

```cangjie
// 使用全局变量
var globalLabel: ?QLabel = None

let callback: VoidCallback = { =>
    if (let Some(label) <- globalLabel) {
        label.setText("已点击")
    }
}
```

---

## 定时器示例

```cangjie
let timer = QTimer()
timer.setInterval(1000)  // 1秒

let timerCallback: VoidCallback = { =>
    println("定时器触发！")
}
timer.setTimeout(timerCallback)
timer.start()

// 停止并断开连接
timer.stop()
timer.disconnect()
```
