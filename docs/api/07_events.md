# CJQT6 事件处理模块

本模块提供基于 Qt 事件系统的轻量封装，当前核心类型是 QEventWidget。它位于 core 包中，使用方式与普通 QWidget 相似，但额外支持鼠标、键盘和绘制事件回调。

```cangjie
import cjqt6.core.*

let widget = QEventWidget()
widget.setOnMouseMove({ x: Int32, y: Int32, buttons: Int32 =>
    println("鼠标移动: (${x}, ${y})，按钮: ${buttons}")
})

widget.setOnKeyPress({ key: Int32, modifiers: Int32, unicode: Int32 =>
    println("按键: ${key}, 修饰键: ${modifiers}, unicode: ${unicode}")
})

widget.show()
```

## QEventWidget

### 常用方法

| 方法 | 说明 |
|------|------|
| `show()` / `hide()` | 显示或隐藏控件 |
| `setTitle(title: String)` | 设置标题 |
| `resize(width, height)` | 调整大小 |
| `setGeometry(x, y, width, height)` | 设置位置和尺寸 |
| `setLayout(layoutPtr: Int64)` | 绑定布局 |
| `getPtr(): Int64` | 获取底层控件指针 |
| `getId(): Int64` | 获取控件唯一 ID |
| `update()` | 触发重绘 |
| `setOnMousePress(callback)` | 鼠标按下回调 |
| `setOnMouseMove(callback)` | 鼠标移动回调 |
| `setOnMouseRelease(callback)` | 鼠标释放回调 |
| `setOnKeyPress(callback)` | 键盘按下回调 |
| `setOnKeyRelease(callback)` | 键盘释放回调 |
| `setOnPaint(callback)` | 绘制事件回调 |
| `clearMousePressCallback()` | 清除鼠标按下回调 |
| `clearMouseMoveCallback()` | 清除鼠标移动回调 |
| `clearMouseReleaseCallback()` | 清除鼠标释放回调 |
| `clearKeyPressCallback()` | 清除键盘按下回调 |
| `clearKeyReleaseCallback()` | 清除键盘释放回调 |
| `clearPaintCallback()` | 清除绘制回调 |
| `clearAllCallbacks()` | 清除所有回调 |
| `delete()` | 释放资源 |

### 释放资源

在释放前建议先清空回调，避免回调仍引用已销毁的对象：

```cangjie
widget.clearAllCallbacks()
widget.delete()
```

## 常量辅助类

### MouseButton

```cangjie
MouseButton.left()    // 左键
MouseButton.right()   // 右键
MouseButton.middle()  // 中键
```

### Modifier

```cangjie
Modifier.shift()    // Shift
Modifier.control()  // Ctrl
Modifier.alt()      // Alt
Modifier.meta()     // Meta

Modifier.hasShift(modifiers)
Modifier.hasControl(modifiers)
Modifier.hasAlt(modifiers)
Modifier.hasMeta(modifiers)
```

### Key

键盘按键常量，全部为静态方法，返回 `Int32`：

| 方法 | 说明 |
|------|------|
| `escape()` | Esc |
| `tab()` | Tab |
| `backspace()` | 退格 |
| `enter()` | 回车（Return） |
| `returnKey()` | 回车（Enter 键码） |
| `insert()` | Insert |
| `delete()` | Delete |
| `pause()` | Pause |
| `print()` | Print |
| `home()` | Home |
| `end()` | End |
| `left()` / `up()` / `right()` / `down()` | 方向键 |
| `pageUp()` / `pageDown()` | 翻页键 |
| `shift()` / `control()` / `meta()` / `alt()` | 修饰键 |
| `capsLock()` / `numLock()` / `scrollLock()` | 锁定键 |
| `space()` | 空格 |
| `f1()` ~ `f12()` | 功能键 F1-F12 |
| `a()` ~ `z()` | 字母键（ASCII 码 65-90） |
| `num0()` ~ `num9()` | 数字键（ASCII 码 48-57） |

```cangjie
Key.escape()
Key.enter()
Key.space()
Key.f1()
Key.a()       // 65
Key.num0()    // 48
```

> 说明：当前实现中的事件回调签名使用 C 回调风格，调用时需要传入与源码保持一致的参数个数。

## 拖放支持

拖放相关类（QMimeData、QDrag）位于 `cjqt6.core` 包，详见 [17_dragdrop.md](./17_dragdrop.md)。