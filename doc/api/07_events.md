# CJQT6 事件处理模块

本模块包含事件处理相关的类和方法。

## QEventWidget - 事件窗口

QEventWidget 是支持鼠标、键盘等事件的窗口部件。

```cangjie
import CJQT6.gui.*

let eventWidget = QEventWidget()

// 设置鼠标移动回调
eventWidget.setOnMouseMove({ x: Int32, y: Int32 =>
    println("鼠标移动: (${x}, ${y})")
})

// 设置鼠标按下回调
eventWidget.setOnMousePress({ x: Int32, y: Int32, button: Int32 =>
    println("鼠标按下: (${x}, ${y}), 按钮: ${button}")
})

// 设置键盘按下回调
eventWidget.setOnKeyPress({ key: Int32, modifiers: Int32 =>
    println("按键: ${key}, 修饰键: ${modifiers}")
})
```

**事件回调方法**:
| 方法 | 说明 |
|------|------|
| `setOnMouseMove(callback)` | 鼠标移动回调 |
| `setOnMousePress(callback)` | 鼠标按下回调 |
| `setOnMouseRelease(callback)` | 鼠标释放回调 |
| `setOnMouseDoubleClick(callback)` | 鼠标双击回调 |
| `setOnMouseEnter(callback)` | 鼠标进入回调 |
| `setOnMouseLeave(callback)` | 鼠标离开回调 |
| `setOnKeyPress(callback)` | 键盘按下回调 |
| `setOnKeyRelease(callback)` | 键盘释放回调 |
| `setOnResize(callback)` | 窗口大小变化回调 |
| `setOnPaint(callback)` | 绘图事件回调 |

**回调清除方法**:
| 方法 | 说明 |
|------|------|
| `clearMouseMoveCallback()` | 清除鼠标移动回调 |
| `clearMousePressCallback()` | 清除鼠标按下回调 |
| `clearMouseReleaseCallback()` | 清除鼠标释放回调 |
| `clearMouseDoubleClickCallback()` | 清除鼠标双击回调 |
| `clearMouseEnterCallback()` | 清除鼠标进入回调 |
| `clearMouseLeaveCallback()` | 清除鼠标离开回调 |
| `clearKeyPressCallback()` | 清除键盘按下回调 |
| `clearKeyReleaseCallback()` | 清除键盘释放回调 |
| `clearResizeCallback()` | 清除大小变化回调 |
| `clearPaintCallback()` | 清除绘图事件回调 |
| `clearAllCallbacks()` | **清除所有回调** |

**鼠标按钮常量**:
```cangjie
MouseButton.LeftButton    // 左键
MouseButton.RightButton   // 右键
MouseButton.MiddleButton  // 中键
```

**键盘修饰键常量**:
```cangjie
Modifier.NoModifier      // 无修饰
Modifier.ShiftModifier   // Shift
Modifier.ControlModifier // Ctrl
Modifier.AltModifier     // Alt
```

**重要：释放资源前清除回调**

在调用 `delete()` 释放 QEventWidget 前，应清除所有回调，避免悬空指针：

```cangjie
// 正确的资源释放顺序
eventWidget.clearAllCallbacks()  // 先清除回调
eventWidget.delete()             // 再释放资源
```
