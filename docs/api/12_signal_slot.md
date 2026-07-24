# CJQT6 信号与槽模块

CJQT6 当前通过 CFunc 回调为一部分 QWidget/Qt 对象接入信号槽能力，实际可用的 API 以源码中的封装为准。

## 回调类型

```cangjie
// 无参数回调
public type VoidCallback = CFunc<() -> Unit>

// Int32 参数回调
public type Int32Callback = CFunc<(Int32) -> Unit>

// Int64 参数回调
public type Int64Callback = CFunc<(Int64) -> Unit>

// Float64 参数回调
public type Float64Callback = CFunc<(Float64) -> Unit>

// CString 参数回调
public type CStringCallback = CFunc<(CString) -> Unit>

// 双 Int32 参数回调
public type Int32Int32Callback = CFunc<(Int32, Int32) -> Unit>

// Int64 + Int32 参数回调
public type Int64Int32Callback = CFunc<(Int64, Int32) -> Unit>
```

---

## 重要说明：CFunc 的限制

CFunc 闭包不能捕获局部变量，只能使用全局变量或参数。因此如果要在回调里访问其它控件，通常需要把对象保存到全局变量中：

```cangjie
// ❌ 错误：不能捕获局部变量
main(): Int32 {
    let label = QLabel()
    let callback: VoidCallback = { =>
        label.setText("clicked")  // 编译错误
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
    globalLabel = label
    // ...
}
```

---

## 基本用法

```cangjie
// 按钮点击回调
let clickCallback: VoidCallback = { =>
    println("按钮被点击")
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
| QWidget | `setOnDestroyed(callback)` | `VoidCallback` | 控件销毁 |
| QPushButton | `setOnClick(callback)` | `VoidCallback` | 点击 |
| QToolButton | `setOnClick(callback)` | `VoidCallback` | 点击 |
| QLineEdit | `setOnTextChanged(callback)` | `CStringCallback` | 文本变化 |
| QLineEdit | `setOnReturnPressed(callback)` | `VoidCallback` | 回车键按下 |
| QLineEdit | `setOnEditingFinished(callback)` | `VoidCallback` | 编辑完成（失焦或回车） |
| QSpinBox | `setOnValueChanged(callback)` | `Int32Callback` | 值变化 |
| QDoubleSpinBox | `setOnValueChanged(callback)` | `Float64Callback` | 值变化 |
| QSlider | `setOnValueChanged(callback)` | `Int32Callback` | 值变化 |
| QSlider | `setOnSliderMoved(callback)` | `Int32Callback` | 滑块拖动中 |
| QCheckBox | `setOnStateChanged(callback)` | `Int32Callback` | 状态变化 |
| QRadioButton | `setOnToggled(callback)` | `Int32Callback` | 切换 |
| QComboBox | `setOnCurrentIndexChanged(callback)` | `Int32Callback` | 索引变化 |
| QComboBox | `setOnCurrentTextChanged(callback)` | `CStringCallback` | 文本变化 |
| QAction | `setOnTriggered(callback)` | `VoidCallback` | 触发 |
| QTimer | `setOnTimeout(callback)` | `VoidCallback` | 超时 |

---

## 断开信号连接

当前封装提供的断开方法名与对应的连接方法基本一致：

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
timer.disconnectTimeout()
```

> QToolButton 的断开方法是 `disconnectClicked()`，QAction 的断开方法是 `disconnect()`。

---

## 定时器示例

```cangjie
let timer = QTimer()
timer.setInterval(1000)  // 1 秒

let timerCallback: VoidCallback = { =>
    println("定时器触发")
}
timer.setOnTimeout(timerCallback)
timer.start()

// 停止并断开连接
timer.stop()
timer.disconnectTimeout()
```
