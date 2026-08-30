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
    // QApplication 不依赖终结器（终结器已全局禁用）；
    // 程序退出时由 Qt 清理，如需提前释放用 app.delete()
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
| `setStyleSheet(styleSheet: String)` | 设置应用级全局样式表（QSS） |
| `styleSheet(): String` | 获取应用级全局样式表 |

**应用级 QSS**（与控件级 `setStyleSheet` 的区别）：
```cangjie
// 应用级：作用于所有控件，可被控件自身 styleSheet 覆盖
QApp.setStyleSheet("QPushButton { color: red; } QLineEdit { padding: 4px; }")

// 控件级：仅作用于该控件，优先级高于应用级
let btn = QPushButton("登录")
btn.setStyleSheet("background-color: #4CAF50;")
```

---

## QLocale

语言环境（区域）信息封装，基于 Qt 的 `QLocale`。可用于获取语言/地区的本地名称与英文名称，辅助国际化显示。

> **内存管理**：QLocale 持有堆分配的 `QLocale*` 句柄（非 QObject），**不实现** `QtResource` 接口、无终结器，使用完毕后必须显式调用 `close()` 释放。

```cangjie
import cjqt6.core.*

let locale = QLocale("zh_CN")
println(locale.name())                    // "zh_CN"
println(locale.nativeLanguageName())      // "中文"
println(locale.nativeTerritoryName())     // "中国"
println(locale.languageName())            // "Chinese"
println(locale.territoryName())           // "China"
println(locale.language())                // 33 (QLocale::Chinese)
println(locale.territory())               // 43 (QLocale::China)
locale.close()                            // 必须显式释放
```

**构造**:
| 方法 | 说明 |
|------|------|
| `init(name: String)` | 按语言代码创建（如 "zh_CN"、"en_US"） |
| `init()` | 使用系统默认语言环境创建 |

**方法**:
| 方法 | 说明 |
|------|------|
| `name(): String` | 语言环境代码（如 "zh_CN"） |
| `nativeLanguageName(): String` | 本地语言的文字名称（如 "中文"） |
| `nativeTerritoryName(): String` | 本地语言中地区名称（如 "中国"） |
| `languageName(): String` | 英文语言名称（如 "Chinese"） |
| `territoryName(): String` | 英文地区名称（如 "China"） |
| `language(): Int32` | 语言枚举值（QLocale::Language） |
| `territory(): Int32` | 地区枚举值（QLocale::Territory） |
| `close()` | 释放语言环境 |

> **注意**：`close()` 可重复调用，重复释放安全。

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

---

## QThread / QThreadPool / QRunnable

多线程支持：`QThread` 线程、`QRunnable` 任务、`QThreadPool` 线程池。

```cangjie
import cjqt6.core.*

// ---- QThread 线程 ----
let thread = QThread()
thread.setOnStarted({ =>
    println("线程启动")
})
thread.setOnFinished({ =>
    println("线程结束")
})
thread.start()

// 等待线程结束（无限等待）
thread.wait()

// ---- QRunnable + QThreadPool 线程池 ----
let task = QRunnable({ =>
    println("任务执行中...")
})

let pool = QThreadPool.globalInstance()
pool.setMaxThreadCount(4)
pool.start(task)
pool.waitForDone()  // 等待所有任务完成

// 静态工具
QThread.msleep(100)          // 休眠 100ms
let cores = QThread.idealThreadCount()  // CPU 核心数
```

**QThread 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建线程 |
| `start()` | 启动线程 |
| `quit()` | 退出线程事件循环 |
| `exit()` | 退出线程（带返回码） |
| `wait(): Bool` | 无限等待线程结束 |
| `waitTimeout(timeoutMs: Int32): Bool` | 指定超时等待线程结束 |
| `isRunning(): Bool` | 线程是否运行中 |
| `isFinished(): Bool` | 线程是否已结束 |
| `setPriority(priority: Int32)` / `priority(): Int32` | 设置/获取优先级（ThreadPriority 常量） |
| `setStackSize(stackSize: Int64)` / `stackSize(): Int64` | 设置/获取栈大小 |
| `isInterruptionRequested(): Bool` | 是否请求了中断 |
| `requestInterruption()` | 请求线程中断 |
| `setOnStarted(callback: VoidCallback)` | 线程启动回调 |
| `setOnFinished(callback: VoidCallback)` | 线程结束回调 |
| `disconnectCallbacks()` | 断开全部信号连接 |
| `currentThreadPtr(): Int64` | （静态）获取当前线程指针 |
| `idealThreadCount(): Int64` | （静态）获取理想线程数 |
| `msleep(ms: Int32)` | （静态）休眠指定毫秒 |
| `getPtr(): Int64` / `close()` | 指针与资源释放 |

**QRunnable 方法**:
| 方法 | 说明 |
|------|------|
| `init(callback: VoidCallback)` | 创建可运行任务 |
| `getPtr(): Int64` / `close()` | 指针与资源释放 |

**QThreadPool 方法**:
| 方法 | 说明 |
|------|------|
| `globalInstance(): QThreadPool` | （静态）获取全局线程池 |
| `start(runnable: QRunnable)` | 启动任务 |
| `waitForDone(): Bool` | 无限等待所有任务完成 |
| `waitForDoneTimeout(timeoutMs: Int32): Bool` | 指定超时等待 |
| `activeThreadCount(): Int32` | 活动线程数 |
| `maxThreadCount(): Int32` / `setMaxThreadCount(count: Int32)` | 最大线程数 |
| `expiryTimeout(): Int32` / `setExpiryTimeout(timeout: Int32)` | 线程超时回收时间 |
| `getPtr(): Int64` | 获取指针 |

**优先级常量** (`ThreadPriority`):
```cangjie
ThreadPriority.idle()          // 0
ThreadPriority.lowest()        // 1
ThreadPriority.low()           // 2
ThreadPriority.normal()        // 3
ThreadPriority.high()          // 4
ThreadPriority.highest()       // 5
ThreadPriority.timeCritical()  // 6
ThreadPriority.inherit()       // 7
```

---

## QSettings - 应用配置持久化

以键值对方式读写应用设置，支持分组与多类型取值。

```cangjie
import cjqt6.core.*

// 按应用名创建（写入平台约定的配置位置）
let settings = QSettings("MyApp")
settings.setValue("window/width", "800")
settings.setValue("window/height", "600")
settings.setValue("volume", "70")

// 读取
let width = settings.value("window/width", "0")     // "800"
let vol = settings.valueInt("volume", 0)            // 70
let autoSave = settings.valueBool("autoSave", true) // true（默认值）

// 分组读写
settings.beginGroup("window")
settings.setValue("x", "10")
settings.endGroup()

// 判断与删除
let has = settings.contains("volume")  // true
settings.remove("volume")

// 从 INI 文件创建
let fileSettings = QSettings.fromFile("config.ini")

settings.sync()   // 立即写盘
settings.close()  // 释放资源
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(appName: String)` | 按应用名创建配置存储 |
| `fromFile(fileName: String): QSettings` | （静态）从 INI 文件创建 |
| `setValue(key: String, value: String)` | 写入字符串键值对 |
| `value(key: String, defaultValue: String): String` | 读取字符串值 |
| `valueInt(key: String, defaultValue: Int32): Int32` | 读取整数值 |
| `valueBool(key: String, defaultValue: Bool): Bool` | 读取布尔值 |
| `beginGroup(prefix: String)` / `endGroup()` | 分组读写 |
| `sync()` | 将改动同步写入磁盘 |
| `contains(key: String): Bool` | 键是否存在 |
| `remove(key: String)` | 删除键 |
| `getPtr(): Int64` / `close()` / `delete()` | 指针与资源释放 |

---

## QShortcut - 快捷键

将按键序列绑定到父控件，触发对应操作。

```cangjie
import cjqt6.core.*

// 为窗口创建快捷键
let shortcut = QShortcut(window)
shortcut.setKey("Ctrl+O")     // 打开文件
shortcut.setEnabled(true)     // 启用
shortcut.setAutoRepeat(false) // 长按不重复

// 结合信号系统使用（QShortcut 自身不携带回调，需配合应用层事件）
shortcut.close()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(parent: QWidget)` | 为父控件创建快捷键 |
| `setKey(keySequence: String)` | 设置按键序列（如 "Ctrl+O"） |
| `setEnabled(enabled: Bool)` | 启用/禁用快捷键 |
| `setAutoRepeat(repeat: Bool)` | 长按时是否自动重复 |
| `getPtr(): Int64` / `close()` / `delete()` | 指针与资源释放 |

---

## QClipboard - 剪贴板

系统剪贴板，提供文本读取、写入、清空与存在性判断（静态方法）。

```cangjie
import cjqt6.core.*

// 写入文本
QClipboard.setText("Hello CJQT6")

// 读取文本
let text = QClipboard.text()     // "Hello CJQT6"

// 是否有文本
let has = QClipboard.hasText()   // true

// 清空
QClipboard.clear()
```

**方法**（全部为静态方法）:
| 方法 | 说明 |
|------|------|
| `text(): String` | 获取剪贴板纯文本 |
| `setText(text: String)` | 写入文本到剪贴板 |
| `hasText(): Bool` | 剪贴板是否包含文本 |
| `clear()` | 清空剪贴板 |

---

## QDesktopServices - 桌面服务

使用系统默认程序打开 URL 或文件（静态方法）。

```cangjie
import cjqt6.core.*

// 打开网页
let ok1 = QDesktopServices.openUrl("https://gitcode.com")

// 打开文件（系统关联程序）
let ok2 = QDesktopServices.openFile("C:/Users/public/readme.txt")
```

**方法**（全部为静态方法）:
| 方法 | 说明 |
|------|------|
| `openUrl(url: String): Bool` | 使用默认浏览器/程序打开 URL |
| `openFile(filePath: String): Bool` | 使用默认关联程序打开文件 |

---

## QFileSystemWatcher - 文件系统监视器

监听指定文件/目录的变化（本封装提供路径的添加与移除管理）。

```cangjie
import cjqt6.core.*

let watcher = QFileSystemWatcher()
watcher.addPath("C:/data/config.ini")   // 监视文件
watcher.addPath("C:/data/logs")         // 监视目录
watcher.removePath("C:/data/logs")      // 取消监视
watcher.close()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建监视器 |
| `addPath(path: String)` | 添加监视路径（文件或目录） |
| `removePath(path: String)` | 移除监视路径 |
| `getPtr(): Int64` / `close()` / `delete()` | 指针与资源释放 |

---

## QScreen - 屏幕信息

主屏幕信息查询：分辨率、DPI、刷新率等（静态方法）。

```cangjie
import cjqt6.core.*

let w = QScreen.primaryWidth()          // 主屏宽度
let h = QScreen.primaryHeight()         // 主屏高度
let dpiX = QScreen.primaryDpiX()        // 逻辑 DPI X
let ratio = QScreen.primaryDevicePixelRatio()  // 缩放比

// DPI 换算辅助
let scale = QScreen.scaleFactor()                     // 缩放因子
let phys = QScreen.logicalToPhysical(100)             // 逻辑→物理像素
let logic = QScreen.physicalToLogical(200)            // 物理→逻辑像素
```

**方法**（全部为静态方法）:
| 方法 | 说明 |
|------|------|
| `primaryDpiX(): Float64` | 主屏逻辑 DPI X |
| `primaryDpiY(): Float64` | 主屏逻辑 DPI Y |
| `primaryPhysicalDpiX(): Float64` | 主屏物理 DPI X |
| `primaryPhysicalDpiY(): Float64` | 主屏物理 DPI Y |
| `primaryDevicePixelRatio(): Float64` | 设备像素比 |
| `primaryWidth(): Int32` | 主屏宽度（像素） |
| `primaryHeight(): Int32` | 主屏高度（像素） |
| `primaryRefreshRate(): Float64` | 主屏刷新率 |
| `scaleFactor(): Float64` | DPI 缩放因子（devicePixelRatio 别名） |
| `logicalToPhysical(logical: Int32): Int32` | 逻辑像素转物理像素 |
| `physicalToLogical(physical: Int32): Int32` | 物理像素转逻辑像素 |

---

## QStandardPaths - 标准路径

获取各平台约定的文档/配置/缓存等系统目录（静态方法）。

```cangjie
import cjqt6.core.*

// 获取文档目录
let docs = QStandardPaths.writableLocation(StandardLocationDocuments)

// 获取临时目录
let tmp = QStandardPaths.tempDir()

// 查找文件
let found = QStandardPaths.locate(StandardLocationApplications, "notepad.exe")

// 本地化显示名称
let name = QStandardPaths.displayName(StandardLocationPictures)  // "图片"
```

**方法**（全部为静态方法）:
| 方法 | 说明 |
|------|------|
| `writableLocation(type: Int32): String` | 获取指定类型可写目录 |
| `locate(type: Int32, fileName: String): String` | 在指定位置查找文件 |
| `displayName(type: Int32): String` | 获取本地化显示名称 |
| `tempDir(): String` | 获取系统临时目录 |

**位置类型常量**（`StandardLocation*`）:
```cangjie
StandardLocationDesktop            // 0  桌面
StandardLocationDocuments          // 1  文档
StandardLocationFonts              // 2  字体
StandardLocationApplications       // 3  应用程序
StandardLocationMusic              // 4  音乐
StandardLocationMovies             // 5  影片
StandardLocationPictures           // 6  图片
StandardLocationTemp               // 7  临时目录
StandardLocationHome               // 8  主目录
StandardLocationAppLocalData       // 9  应用本地数据
StandardLocationAppConfig          // 10 应用配置
StandardLocationDownload           // 11 下载
StandardLocationGenericData        // 12 通用数据
StandardLocationRuntime            // 13 运行时数据
StandardLocationConfig             // 14 配置文件
StandardLocationGenericCache       // 15 通用缓存
```

---

## QPropertyAnimation - 属性动画

驱动目标对象的指定数值属性在起止值间随时间变化。

```cangjie
import cjqt6.core.*

// 目标对象指针 + 属性名（数值属性，按 Float64 处理）
let anim = QPropertyAnimation(widget.getPtr(), "pos")
anim.setDuration(1000)            // 1 秒
anim.setStartValue(0.0f64)
anim.setEndValue(300.0f64)
anim.setLoopCount(2)              // 循环 2 次（-1 无限）
anim.setEasingCurve(EasingCurve.InOutQuad)  // 缓动曲线
anim.start()

// 加入动画组
let group = QParallelAnimationGroup()
group.addAnimation(anim.getPtr())
group.start()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(target: Int64, propertyName: String)` | 创建属性动画 |
| `setDuration(duration: Int32)` / `duration(): Int32` | 设置/获取时长（毫秒） |
| `setStartValue(value: Float64)` | 设置起始值 |
| `setEndValue(value: Float64)` | 设置结束值 |
| `start()` / `stop()` | 开始/停止 |
| `setLoopCount(count: Int32)` / `loopCount(): Int32` | 循环次数（-1 无限） |
| `setEasingCurve(curveType: Int32)` | 设置缓动曲线 |
| `getPtr(): Int64` / `close()` / `delete()` | 指针与资源释放 |

**缓动曲线常量** (`EasingCurve`):
```cangjie
EasingCurve.Linear       // 0  线性
EasingCurve.InQuad       // 1  二次缓入
EasingCurve.OutQuad      // 2  二次缓出
EasingCurve.InOutQuad    // 3  二次缓入缓出
EasingCurve.InCubic      // 4  三次缓入
EasingCurve.OutCubic     // 5  三次缓出
EasingCurve.InOutCubic   // 6  三次缓入缓出
EasingCurve.InSine       // 7  正弦缓入
EasingCurve.OutSine      // 8  正弦缓出
EasingCurve.InOutSine    // 9  正弦缓入缓出
EasingCurve.InElastic    // 14 弹性缓入
EasingCurve.OutElastic   // 15 弹性缓出
EasingCurve.InOutElastic // 16 弹性缓入缓出
EasingCurve.InBounce     // 17 弹跳缓入
EasingCurve.OutBounce    // 18 弹跳缓出
EasingCurve.InOutBounce  // 19 弹跳缓入缓出
```

---

## QJsonDocument / QJsonObject / QJsonArray / QJsonValue

JSON 编解码支持：从字符串解析、构建、序列化。

```cangjie
import cjqt6.core.*

// ---- 解析 ----
let doc = QJsonDocument("{\"name\":\"CJQT6\",\"version\":1}")
if (doc.isObject()) {
    let obj = doc.object()
    let name = obj.value("name")            // QJsonValue
    println(name.toString())                // "CJQT6"
    let ver = obj.value("version")
    println(ver.toInt(0))                   // 1
}

// ---- 构建 ----
let obj = QJsonObject()
obj.insert("name", QJsonValue.createString("测试"))
obj.insert("count", QJsonValue.createInt(42))
obj.insert("ok", QJsonValue.createBool(true))

let arr = QJsonArray()
arr.append(QJsonValue.createString("a"))
arr.append(QJsonValue.createString("b"))

let doc2 = QJsonDocument("{}")
println(doc2.toJson(2))   // 序列化（2 空格缩进）

obj.close()
arr.close()
doc.close()
```

**JsonType 类型常量**:
```cangjie
JsonType.nullType()      // 0
JsonType.boolType()      // 1
JsonType.doubleType()    // 2
JsonType.stringType()    // 3
JsonType.arrayType()     // 4
JsonType.objectType()    // 5
JsonType.undefinedType() // 6
```

**QJsonDocument 方法**:
| 方法 | 说明 |
|------|------|
| `init(json: String)` | 从 JSON 字符串解析（失败时文档为 Null） |
| `toJson(indent: Int32): String` | 序列化为字符串（0 紧凑，>0 缩进空格数） |
| `isNull(): Bool` | 是否为空文档 |
| `isArray(): Bool` / `isObject(): Bool` | 类型判断 |
| `object(): QJsonObject` | 获取根对象 |
| `array(): QJsonArray` | 获取根数组 |
| `getPtr(): Int64` / `close()` | 指针与资源释放 |

**QJsonObject 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空对象 |
| `insert(key: String, value: QJsonValue)` | 插入/覆盖键值对 |
| `value(key: String): QJsonValue` | 获取键对应值（无则 Null） |
| `contains(key: String): Bool` | 是否包含键 |
| `remove(key: String)` | 移除键 |
| `size(): Int32` / `isEmpty(): Bool` | 大小/空判断 |
| `keyAt(index: Int32): String` | 按索引获取键名 |
| `getPtr(): Int64` / `close()` | 指针与资源释放 |

**QJsonArray 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空数组 |
| `append(value: QJsonValue)` | 追加元素 |
| `at(index: Int32): QJsonValue` | 按索引取值 |
| `size(): Int32` / `isEmpty(): Bool` | 大小/空判断 |
| `removeAt(index: Int32)` | 移除元素 |
| `getPtr(): Int64` / `close()` | 指针与资源释放 |

**QJsonValue 方法**:
| 方法 | 说明 |
|------|------|
| `createNull(): QJsonValue` | （静态）创建 Null 值 |
| `createString(val: String): QJsonValue` | （静态）创建字符串值 |
| `createInt(val: Int64): QJsonValue` | （静态）创建整数值 |
| `createDouble(val: Float64): QJsonValue` | （静态）创建浮点值 |
| `createBool(val: Bool): QJsonValue` | （静态）创建布尔值 |
| `valueType(): Int32` | 获取值类型（JsonType） |
| `toString(): String` | 转为字符串 |
| `toInt(defaultVal: Int64): Int64` | 转为整数 |
| `toDouble(defaultVal: Float64): Float64` | 转为浮点 |
| `toBool(defaultVal: Bool): Bool` | 转为布尔 |
| `toObject(): Int64` / `toArray(): Int64` | 转对象/数组指针 |
| `isNull()` / `isString()` / `isArray()` / `isObject()` / `isBool()` / `isDouble(): Bool` | 类型判断 |
| `getPtr(): Int64` / `close()` | 指针与资源释放 |

---

## QItemSelectionModel - 选择模型

管理模型中的选中项、当前项（常与 QTableView 等视图配合使用）。

```cangjie
import cjqt6.core.*

// 创建选择模型（modelPtr 为数据模型指针）
let selModel = QItemSelectionModel(model.getPtr())
selModel.setCurrentIndex(0, 0, SelectionFlag.clearAndSelect())

// 查询选择状态
let selected = selModel.isSelected(0, 0)     // 指定单元格
let rowSel = selModel.isRowSelected(1)       // 指定行
let any = selModel.hasSelection()            // 是否有选中项

// 选中行操作
let count = selModel.selectedRowsCount()
let row = selModel.selectedRowAt(0)

selModel.clearSelection()  // 清除选中（保留当前项）
selModel.clear()           // 全部清除
selModel.close()
```

**SelectionFlag 选择标志常量**:
```cangjie
SelectionFlag.noUpdate()      // 0  不更新选择
SelectionFlag.clear()         // 1  清除现有选择
SelectionFlag.select()        // 2  选择指定索引
SelectionFlag.deselect()      // 4  取消选择
SelectionFlag.toggle()        // 8  切换选择状态
SelectionFlag.current()       // 16 设置为当前索引
SelectionFlag.rows()          // 32 选择整行
SelectionFlag.columns()       // 64 选择整列
SelectionFlag.clearAndSelect()// 3  清除后选择
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(modelPtr: Int64)` | 创建选择模型 |
| `currentIndexRow(): Int32` / `currentIndexCol(): Int32` | 当前项行/列 |
| `setCurrentIndex(row: Int32, col: Int32, command: Int32)` | 设置当前索引 |
| `isSelected(row: Int32, col: Int32): Bool` | 单元格是否选中 |
| `isRowSelected(row: Int32): Bool` | 行是否选中 |
| `hasSelection(): Bool` | 是否有选中项 |
| `clearSelection()` | 清除选中项（保留当前项） |
| `clear()` | 清除全部 |
| `model(): Int64` | 获取关联模型指针 |
| `select(row: Int32, col: Int32, command: Int32)` | 选择单元格 |
| `selectedRowsCount(): Int32` | 选中行数量 |
| `selectedRowAt(index: Int32): Int32` | 按索引获取选中行号 |
| `getPtr(): Int64` / `close()` | 指针与资源释放 |

---

## SignalEmitter - 自定义信号发射器

支持 void/int/double/string 四种参数信号，可指定连接类型（含跨线程 QueuedConnection）。

```cangjie
import cjqt6.core.*

// 创建发射器
let emitter = SignalEmitter()

// 连接信号（支持闭包捕获版本）
emitter.setOnVoid({ =>
    println("收到 void 信号")
})
emitter.setOnInt({ value: Int32 =>
    println("收到 int 信号: ${value}")
})
emitter.setOnString({ text: CString =>
    println("收到 string 信号: ${text.toString()}")
})

// 发射信号
emitter.emitVoid()
emitter.emitInt(42)
emitter.emitString("hello")

// 跨线程连接（QueuedConnection 投递到接收线程）
emitter.setOnInt({ value: Int32 => println("${value}") }, ConnectionType.Queued)

emitter.disconnect()  // 断开全部信号
emitter.close()
```

**ConnectionType 连接类型常量**:
```cangjie
ConnectionType.Auto           // 0 自动
ConnectionType.Direct         // 1 直接调用
ConnectionType.Queued         // 2 队列投递（跨线程）
ConnectionType.BlockingQueued // 3 阻塞队列投递
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建发射器 |
| `setOnVoid(callback: VoidCallback): SignalConnection` | 连接 void 信号 |
| `setOnVoid(callback: VoidCallback, connType: Int32): SignalConnection` | 指定连接类型 |
| `setOnVoidCapture(callback: () -> Unit): SignalConnection` | 闭包捕获版 |
| `setOnInt(callback: Int32Callback): SignalConnection` | 连接 int 信号 |
| `setOnDouble(callback: Float64Callback): SignalConnection` | 连接 double 信号 |
| `setOnString(callback: CStringCallback): SignalConnection` | 连接 string 信号 |
| `emitVoid()` / `emitInt(v: Int32)` / `emitDouble(v: Float64)` / `emitString(s: String)` | 发射信号 |
| `disconnectVoid()` / `disconnectInt()` / `disconnectDouble()` / `disconnectString()` | 断开单个信号 |
| `disconnect()` | 断开全部信号 |
| `getPtr(): Int64` / `close()` / `delete()` | 指针与资源释放 |

---

## UiPoster / runOnUiThread / runAsync - 跨线程回投 UI 线程（P1）

仓颉 `spawn` 出的工作线程**没有 Qt 事件循环**，直接操作控件线程不安全。本组 API 收口所有「回投 UI 线程」的投递路径：闭包经 `registerVoidCallback` 注册表拿到 id，native 侧 `qUiPosterPost` 用 `QMetaObject::invokeMethod(Qt::QueuedConnection)` 塞进 `QCoreApplication`（GUI 线程）事件队列，GUI 线程事件循环取出后按 id 派发。

> **约束（roadmap 4.1）**：所有 `runOnUiThread` / 异步回投都必须走本入口，禁止各模块各自 `new QTimer` / 自建投递路径。回调在事件循环中异步执行（即使调用方就在 GUI 线程，也是排队执行，语义同 `QTimer::singleShot(0)`）。一次性任务执行后自动从注册表注销。

```cangjie
import cjqt6.core.*

// 1. 把闭包投递到 GUI 线程事件队列（异步，先进先出）
runOnUiThread({ =>
    label.setText("刷新完成")
})

// 2. 后台执行耗时任务，完成后自动回投 GUI 线程
runAsync({
    // 工作线程：耗时计算 / IO（没有 Qt 事件循环，勿操作控件）
    let result = heavyCompute()
}, {
    // GUI 线程：安全操作控件
    statusLabel.setText("完成: ${result}")
})
```

**方法**:
| 方法 | 说明 |
|------|------|
| `UiPoster.runOnUiThread(callback: () -> Unit)` | 把闭包投递到 GUI 线程事件队列（异步） |
| `UiPoster.post(callback: () -> Unit)` | `runOnUiThread` 别名 |
| `runOnUiThread(callback: () -> Unit)` | 顶层便捷函数（等价于 `UiPoster.runOnUiThread`） |
| `runAsync(work: () -> Unit, onDone: () -> Unit)` | `spawn` 后台执行 `work`，完成后在 GUI 线程执行 `onDone` |

> 事件循环通过 `app.exec()` / `GUITestEnvironment.exec()` 驱动；GUI 线程测试中可用 `QApp.quit()` 退出。
