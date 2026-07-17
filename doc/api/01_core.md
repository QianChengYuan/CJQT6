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

// 安全执行操作
let result = safeExecute(widget, { w =>
    w.setText("Hello")  // 如果 widget 已释放，返回 false
})

// 安全运行代码块
let success = safeRun({ =>
    // 可能抛出异常的代码
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
timer.setTimeout(timerCallback)
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
    timer.setTimeout({ =>
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
| `setTimeout(callback: VoidCallback)` | 设置超时回调 |
| `disconnect()` | 断开信号连接 |
| `delete()` | **必须调用** - 释放资源 |
