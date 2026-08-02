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

// Bool 参数回调
public type BoolCallback = CFunc<(Bool) -> Unit>

// 字符串 + Int32 参数回调（如 currentTextChanged(text, index)）
public type CStringInt32Callback = CFunc<(CString, Int32) -> Unit>

// Int32 + Bool 参数回调
public type Int32BoolCallback = CFunc<(Int32, Bool) -> Unit>
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

---

## ConnectionType - 连接类型

映射 Qt::ConnectionType，用于指定信号跨线程时的投递方式：

| 常量 | 值 | 说明 |
|------|------|------|
| `Auto` | 0 | 自动选择（发射与接收同线程走直接调用，跨线程自动排队） |
| `Direct` | 1 | 直接调用（发射线程立即执行槽函数） |
| `Queued` | 2 | 排队投递（槽函数在接收对象所属线程的事件循环中执行） |
| `BlockingQueued` | 3 | 阻塞排队（发射线程阻塞直到槽函数执行完成） |

---

## SignalEmitter - 自定义信号发射器

仓颉无法从 C++ 侧派生 Q_OBJECT 子类，`SignalEmitter` 通过 native 侧固定的
void/int/double/string 四组信号实现「用户自定义信号」，支持指定 `ConnectionType`
实现跨线程 QueuedConnection。

```cangjie
import cjqt6.core.*
import std.sync.Mutex

// 全局缓存（CFunc 回调不能捕获局部变量）
var emitter: ?SignalEmitter = None

// 发射端线程：创建发射器并连接监听
let em = SignalEmitter()
emitter = em

// 连接监听（可指定连接类型）
em.setOnVoid({ =>
    println("收到 void 信号")
})
em.setOnInt({ v: Int32 =>
    println("收到 int 信号: ${v}")
})
em.setOnString({ s: CString =>
    println("收到 string 信号: ${s}")
})

// 发射信号
em.emitVoid()
em.emitInt(42)
em.emitString("hello")
```

**SignalEmitter 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建发射器 |
| `setOnVoid(callback): SignalConnection` | 连接 void 信号（默认 AutoConnection） |
| `setOnVoid(callback, connType): SignalConnection` | 连接 void 信号（指定连接类型） |
| `setOnVoidCapture(callback: () -> Unit): SignalConnection` | 连接 void 信号（闭包捕获版本） |
| `setOnVoidCapture(callback, connType): SignalConnection` | 闭包捕获版本 + 指定连接类型 |
| `emitVoid()` | 发射 void 信号 |
| `disconnectVoid()` | 断开 void 信号 |
| `setOnInt(callback): SignalConnection` | 连接 int 信号 |
| `setOnInt(callback, connType): SignalConnection` | 连接 int 信号（指定连接类型） |
| `emitInt(v: Int32)` | 发射 int 信号 |
| `disconnectInt()` | 断开 int 信号 |
| `setOnDouble(callback): SignalConnection` | 连接 double 信号 |
| `setOnDouble(callback, connType): SignalConnection` | 连接 double 信号（指定连接类型） |
| `emitDouble(v: Float64)` | 发射 double 信号 |
| `disconnectDouble()` | 断开 double 信号 |
| `setOnString(callback): SignalConnection` | 连接 string 信号 |
| `setOnString(callback, connType): SignalConnection` | 连接 string 信号（指定连接类型） |
| `emitString(s: String)` | 发射 string 信号 |
| `disconnectString()` | 断开 string 信号 |
| `disconnect()` | 断开该发射器的全部信号 |
| `getPtr(): Int64` | 获取原生指针 |
| `isClosed(): Bool` | 是否已关闭 |
| `isValid(): Bool` | 是否有效 |
| `close()` / `delete()` | 释放资源 |

> 说明：`setOnXxxCapture` 系列使用闭包捕获注册表机制，回调可以捕获局部变量（见下文「闭包捕获机制」）。

---

## SignalConnection - 信号连接句柄

`setOnXxx` 系列方法均返回 `SignalConnection` 句柄，用于管理和断开连接。
在支持控件内部分信号（如 pressed/released/buttonToggled/clickedChecked）的
路由断开时会自动选择正确的断开函数。

| 方法 | 说明 |
|------|------|
| `disconnect()` | 断开连接 |
| `isConnected(): Bool` | 是否仍处于连接状态 |
| `getPtr(): Int64` | 获取原生指针 |
| `getSignalType(): String` | 获取信号类型标识 |

```cangjie
let conn = button.setOnClick({ =>
    println("clicked")
})

// 需要时断开
if (conn.isConnected()) {
    conn.disconnect()
}
```

---

## 闭包捕获机制（P1c）

传统 `CFunc` 回调不能捕获局部变量，只能通过全局 `?T` 变量中转。为此封装提供了
`Capture` 系列重载（如 `setOnClickCapture`、`setOnVoidCapture`），底层通过注册表
按 id 派发，回调可以自由捕获局部变量：

```cangjie
// CFunc 路径（不能捕获局部变量）
button.setOnClick({ =>
    // 只能访问全局变量
})

// Capture 路径（可以捕获局部变量）
let label = QLabel()
button.setOnClickCapture({ =>
    label.setText("clicked")  // ✅ 允许
})

// 断开时自动注销闭包，避免注册表泄漏
let conn = button.setOnClickCapture({ => ... })
conn.disconnect()
```

> 注意：捕获路径断开连接时会自动从注册表注销闭包。SignalConnection 内部已处理，无需手动调用 `unregisterVoidCallback`。
