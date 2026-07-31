# CJQT6 核心模块

本模块包含应用程序核心类和资源管理。

## 资源管理

### ⚠️ 终结器已全局禁用

**所有控件类的终结器（`~init`）已全部禁用**，包括 QWidget、QLabel、QPushButton、QTimer 等所有控件。原因如下：

仓颉 GC 可能在对象仍被全局变量或其他引用指向时提前调用终结器，导致 Qt 对象被错误释放并引发崩溃。为此，所有依赖 Qt 原生资源的类**不再提供自动清理**，必须显式释放。

```cangjie
// ❌ 错误：依赖自动释放
main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.show()
    let result = app.exec()
    return result  // window 和 app 资源泄漏！
}

// ✅ 正确：显式释放资源
main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.show()
    let result = app.exec()
    window.delete()
    app.delete()
    return result
}
```

### 手动释放（推荐）

所有 Qt 资源类都应手动调用 `delete()` 释放：

| 类 | 原因 | 释放方法 |
|---|-------|---------|
| **QWidget** 及其子类 | 终结器已禁用 | `delete()` |
| **QApplication** | 终结器已禁用 | `delete()` |
| **QTimer** | 终结器已禁用 | `delete()` |
| **QMediaPlayer** | 终结器已禁用 | `delete()` |
| **QAudioOutput** | 终结器已禁用 | `delete()` |
| **QProcess** | 终结器已禁用 | `delete()` |
| **绘图类** (QColor/QPen/QBrush/QFont/QPixmap等) | 终结器已禁用 | `delete()` |

```cangjie
// 方式1：close() - 实现 QtResource 接口的类
widget.close()

// 方式2：delete() - 所有资源类通用
widget.delete()
app.delete()
```

### try-with-resources 模式

对于实现了 `QtResource` 接口的类（如 QWidget），可以使用 try-with-resources 语句自动调用 `close()`：

```cangjie
try (widget = QWidget()) {
    widget.show()
    // ... 使用 widget ...
}  // 自动调用 close()
```

### QtResource 接口

实现了 QtResource 接口的类支持 `close()` 和 `isClosed()` 方法。

```cangjie
interface QtResource {
    func isClosed(): Bool    // 检查资源是否已释放
    func close(): Unit       // 释放资源
}
```

### 异常处理

```cangjie
import cjqt6.core.*

// 安全执行操作，返回 Option<T>
let result = safeExecute({ =>
    let widget = QWidget()
    widget.setTitle("Hello")
    widget
})

// 安全运行代码块
let success = safeRun({ =>
    let widget = QWidget()
    widget.show()
})
```

**异常类型**：
| 异常 | 说明 |
|------|------|
| `QtException` | 基类异常 |
| `ResourceDisposedException` | 资源已释放 |
| `NullPointerException` | 空指针 |
| `CreateFailedException` | 创建失败 |

---

## QApplication

应用程序主类，每个Qt程序必须有且仅有一个实例。

```cangjie
import cjqt6.core.*

main(): Int32 {
    let app = QApplication()
    
    // 加载Qt内置翻译（中文）
    app.loadQtTranslation("zh_CN")
    
    // 或切换语言
    app.switchLanguage("zh_CN")  // 中文
    // app.switchLanguage("en_US")  // 英文
    
    // 创建窗口和控件...
    
    let result = app.exec()  // 进入事件循环
    // 不需要手动清理，终结器自动处理
    return result
}
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建应用程序实例 |
| `exec(): Int32` | 进入事件循环，返回退出码 |
| `quit()` | 退出应用程序 |
| `loadQtTranslation(locale: String): Bool` | 加载Qt内置翻译文件 |
| `loadAppTranslation(qmFile, directory: String): Bool` | 加载应用程序翻译文件 |
| `setLocale(locale: String)` | 设置语言环境 |
| `locale(): String` | 获取当前语言环境 |
| `systemLocale(): String` | 获取系统语言环境 |
| `switchLanguage(locale: String): Bool` | 切换语言（设置locale并加载Qt翻译） |
| `delete()` | 释放资源 |

> **注意**：QApplication **不实现** `QtResource` 接口，没有 `close()` 方法。请使用 `delete()` 释放资源。

**常用语言代码** (Language类):
```cangjie
Language.chinese()             // "zh_CN" - 简体中文
Language.chineseSimplified()   // "zh_CN" - 简体中文
Language.chineseTraditional()  // "zh_TW" - 繁体中文
Language.english()             // "en_US" - 英语
Language.japanese()            // "ja_JP" - 日语
Language.korean()              // "ko_KR" - 韩语
```

### QApp 静态类

提供静态方法访问应用程序功能。

```cangjie
import cjqt6.core.*

// 静态退出应用
QApp.quit()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `quit()` | 静态方法退出应用程序 |

---

## QWidget

基础窗口部件，所有控件的基类。

```cangjie
let window = QWidget()
window.setTitle("窗口标题")
window.resize(800, 600)
window.setLayout(layout.getPtr())
window.show()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建窗口部件 |
| `show()` | 显示窗口 |
| `hide()` | 隐藏窗口 |
| `setTitle(title: String)` | 设置窗口标题 |
| `resize(width: Int32, height: Int32)` | 设置窗口大小 |
| `setGeometry(x, y, width, height)` | 设置位置和大小 |
| `setLayout(layoutPtr: Int64)` | 设置布局 |
| `setStyleSheet(styleSheet: String)` | 设置样式表 |
| `styleSheet(): String` | 获取样式表 |
| `setEnabled(enabled: Bool)` | 设置启用状态 |
| `isEnabled(): Bool` | 是否启用 |
| `setVisible(visible: Bool)` | 设置可见性 |
| `isVisible(): Bool` | 是否可见 |
| `setToolTip(toolTip: String)` | 设置工具提示 |
| `setMinimumSize(width: Int32, height: Int32)` | 设置最小尺寸 |
| `setMaximumSize(width: Int32, height: Int32)` | 设置最大尺寸 |
| `width(): Int32` | 获取宽度 |
| `height(): Int32` | 获取高度 |
| `update()` | 更新窗口 |
| `repaint()` | 重绘窗口 |
| `getPtr(): Int64` | 获取指针（用于布局） |
| `close()` | 释放资源（实现 QtResource 接口） |
| `delete()` | 释放资源 |
| `isClosed(): Bool` | 检查是否已释放 |
| `isValid(): Bool` | 检查对象是否有效 |
| `setOnDestroyed(callback: VoidCallback)` | 设置控件销毁回调 |
| `disconnectDestroyed()` | 断开控件销毁信号 |

---

## QTimer

定时器，用于周期性执行任务。

**⚠️ 重要：必须手动调用 delete()**

QTimer 的终结器已被禁用。仓颉运行时可能在不正确的时机调用终结器（例如对象仍被全局变量引用时），导致 Qt 对象被提前删除并引发崩溃。

```cangjie
let timer = QTimer()
timer.setInterval(1000)  // 1秒

let timerCallback: VoidCallback = { =>
    println("定时器触发！")
}
timer.setOnTimeout(timerCallback)
timer.start()

// 使用完毕后必须手动释放
timer.delete()
```

**完整示例**：
```cangjie
var gTimer: ?QTimer = None

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.resize(400, 300)
    
    let timer = QTimer()
    timer.setInterval(1000)
    timer.setOnTimeout({ =>
        println("定时器触发！")
    })
    timer.start()
    gTimer = timer  // 保存到全局变量
    
    window.show()
    let result = app.exec()
    
    // 手动释放资源
    timer.delete()
    window.delete()
    app.delete()
    
    return result
}
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setInterval(ms: Int32)` | 设置间隔（毫秒） |
| `start()` | 启动定时器 |
| `stop()` | 停止定时器 |
| `setOnTimeout(callback: VoidCallback)` | 设置超时回调 |
| `disconnectTimeout()` | 断开超时信号连接 |
| `delete()` | **必须调用** - 释放资源 |

---

## QAbstractAnimation / QParallelAnimationGroup

动画基础类与并行动画组。

```cangjie
import cjqt6.core.*

// 创建并行动画组
let group = QParallelAnimationGroup()

// 添加属性动画
let anim = QPropertyAnimation(targetPtr, "pos")
anim.setDuration(1000)
anim.setStartValue(0.0f64)
anim.setEndValue(100.0f64)
group.addAnimation(anim.getPtr())

// 控制动画组
group.start()
group.pause()
group.resume()
group.stop()

// 获取状态
let state = group.state()
if (state == AnimationState.running()) {
    println("动画正在运行")
}

// 设置循环次数（0=无限循环）
group.setLoopCount(3)

group.close()
```

**QAbstractAnimation 方法**:
| 方法 | 说明 |
|------|------|
| `start()` | 开始动画 |
| `stop()` | 停止动画 |
| `pause()` | 暂停动画 |
| `resume()` | 恢复动画 |
| `state(): Int32` | 获取动画状态 |
| `duration(): Int64` | 获取动画时长 |
| `setLoopCount(count: Int32)` | 设置循环次数（0=无限） |
| `loopCount(): Int32` | 获取循环次数 |
| `currentTime(): Int32` | 获取当前时间 |
| `setCurrentTime(ms: Int32)` | 设置当前时间 |
| `currentLoop(): Int32` | 获取当前循环 |
| `setDirection(direction: Int32)` | 设置播放方向 |
| `direction(): Int32` | 获取播放方向 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

**QParallelAnimationGroup 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建并行动画组 |
| `addAnimation(animPtr: Int64)` | 添加动画 |
| `removeAnimation(animPtr: Int64)` | 移除动画 |
| `animationCount(): Int32` | 获取动画数量 |
| `start()` / `stop()` / `pause()` / `resume()` | 控制动画组 |
| `state(): Int32` / `duration(): Int64` | 查询状态 |
| `setLoopCount(count: Int32)` / `loopCount(): Int32` | 循环控制 |
| `setDirection(direction: Int32)` / `direction(): Int32` | 方向控制 |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

**状态常量** (`AnimationState`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `AnimationState.stopped()` | 0 | 已停止 |
| `AnimationState.paused()` | 1 | 已暂停 |
| `AnimationState.running()` | 2 | 运行中 |

**方向常量** (`AnimationDirection`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `AnimationDirection.forward()` | 0 | 正向播放 |
| `AnimationDirection.backward()` | 1 | 反向播放 |

---

## QUndoCommand / QUndoStack

撤销/重做框架。

```cangjie
import cjqt6.core.*

// 创建撤销栈
let undoStack = QUndoStack()

// 创建撤销命令
// undoCallback: 撤销回调 (userData)
// redoCallback: 重做回调 (userData)
// userData: 用户数据
// text: 命令描述
let cmd = QUndoCommand(
    { userData => println("撤销: ${userData}") },
    { userData => println("重做: ${userData}") },
    42,
    "操作描述"
)

// 压入撤销栈
undoStack.push(cmd)

// 撤销/重做
undoStack.undo()
undoStack.redo()

// 查询状态
println("可撤销: ${undoStack.canUndo()}")
println("可重做: ${undoStack.canRedo()}")
println("撤销描述: ${undoStack.undoText()}")

// 批量操作
undoStack.beginMacro("批量操作")
// ... 执行多个命令 ...
undoStack.endMacro()

// 清空撤销栈
undoStack.clear()
undoStack.close()
```

**QUndoCommand 方法**:
| 方法 | 说明 |
|------|------|
| `init(undoCallback, redoCallback, userData, text)` | 创建撤销命令 |
| `setText(text: String)` | 设置命令描述 |
| `text(): String` | 获取命令描述 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源（未压入栈时） |

**QUndoStack 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建撤销栈 |
| `push(cmd: QUndoCommand)` | 压入命令 |
| `undo()` | 撤销 |
| `redo()` | 重做 |
| `canUndo(): Bool` | 是否可撤销 |
| `canRedo(): Bool` | 是否可重做 |
| `undoText(): String` | 获取撤销描述 |
| `redoText(): String` | 获取重做描述 |
| `count(): Int32` | 获取命令数 |
| `index(): Int32` | 获取当前索引 |
| `clear()` | 清空栈 |
| `setUndoLimit(limit: Int32)` | 设置撤销限制 |
| `undoLimit(): Int32` | 获取撤销限制 |
| `setClean()` | 标记为干净 |
| `isClean(): Bool` | 是否干净 |
| `beginMacro(text: String)` | 开始宏命令 |
| `endMacro()` | 结束宏命令 |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |
