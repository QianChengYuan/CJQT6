# CJQT6 资源管理指南

本文档详细说明CJQT6项目中的资源管理策略,包括Qt对象生命周期、仓颉GC特性、终结器机制和手动释放规则。

## 目录

- [概述](#概述)
- [Qt对象生命周期](#qt对象生命周期)
- [仓颉GC特性](#仓颉gc特性)
- [终结器机制](#终结器机制)
- [手动释放规则](#手动释放规则)
- [内存泄漏检测](#内存泄漏检测)
- [最佳实践](#最佳实践)

## 概述

CJQT6通过FFI桥接技术连接仓颉语言和Qt6 C++库,这带来了独特的资源管理挑战:

1. **Qt对象**由C++管理,使用QObject父子关系自动管理生命周期
2. **仓颉对象**由仓颉GC管理,GC时机不确定
3. **桥接对象**同时持有Qt指针(Int64)和仓颉引用,需要协调两种内存管理机制

所有 Qt 封装类实现 `QtResource` 接口（`isClosed/close/getPtr:Int64/isValid/checkValid`），持有 `ptr: Int64`。

## Qt对象生命周期

### Qt父子关系

Qt使用父子对象树管理内存。在 CJQT6 中，父子关系通过 `setParent` 或布局 `setLayout` 建立（控件构造均为无参，不通过构造传 parent）：

```cangjie
let parent = QWidget()
let child = QPushButton()
child.setText("按钮")
// 通过 setParent 或加入父对象的布局建立父子关系
// parent 销毁时,自动销毁所有子对象
```

**优点:**
- 自动管理子对象生命周期
- 避免内存泄漏
- 符合Qt惯例

**限制:**
- 仅适用于QObject派生类
- 非QObject对象需要手动管理

### Qt对象类型

| 类型 | 生命周期管理 | 示例 |
|-----|------------|------|
| QObject派生类 | 父子关系自动管理 | QWidget, QPushButton |
| 值类型 | 需手动管理（终结器已禁用） | QColor, QPen, QBrush |
| 非QObject类 | 需手动管理或特殊处理 | QTimer, QMediaPlayer |

## 仓颉GC特性

### GC时机不确定

仓颉GC的触发时机不确定,可能在以下情况发生:

1. 内存压力大时
2. 显式调用GC时
3. 程序退出时

**关键问题:** GC可能在Qt对象仍被使用时触发终结器,导致崩溃。

### 示例场景

```cangjie
let color = QColor(255, 0, 0)  // 创建Qt颜色对象
// ... 使用color
// 若定义了终结器，GC可能在此时触发,调用color的终结器
// 如果Qt仍在使用该颜色对象,会访问已释放内存 -> 崩溃!
// 因此 CJQT6 全局禁用终结器，改由显式 delete()/close() 或 Qt 父子关系管理
```

## 终结器机制

### 终结器状态表

CJQT6 **全局禁用终结器 `~init`**。以下是各类的终结器状态:

#### 核心类 (已禁用终结器)

| 类 | 终结器状态 | 原因 |
|----|----------|------|
| QWidget | ❌ 已禁用 | Qt父子关系管理 |
| QApplication | ❌ 已禁用 | 全局唯一对象，用 delete() 释放 |
| QTimer | ❌ 已禁用 | 可能仍被事件循环使用 |
| QProcess | ❌ 已禁用 | 可能仍运行中 |
| QSettings | ❌ 已禁用 | 可能仍被使用 |

#### 控件类 (已禁用终结器)

| 类 | 终结器状态 | 原因 |
|----|----------|------|
| QLabel | ❌ 已禁用 | Qt父子关系管理 |
| QLineEdit | ❌ 已禁用 | Qt父子关系管理 |
| QPushButton | ❌ 已禁用 | Qt父子关系管理 |
| QTextEdit | ❌ 已禁用 | Qt父子关系管理 |
| QSpinBox | ❌ 已禁用 | Qt父子关系管理 |
| QSlider | ❌ 已禁用 | Qt父子关系管理 |
| QCheckBox | ❌ 已禁用 | Qt父子关系管理 |
| QRadioButton | ❌ 已禁用 | Qt父子关系管理 |
| QComboBox | ❌ 已禁用 | Qt父子关系管理 |

#### 绘图类 (已禁用终结器)

| 类 | 终结器状态 | 原因 |
|----|----------|------|
| QColor | ❌ 已禁用 | GC 时机不确定，须显式 delete() |
| QPen | ❌ 已禁用 | 同上 |
| QBrush | ❌ 已禁用 | 同上 |
| QLinearGradient | ❌ 已禁用 | 同上 |
| QRadialGradient | ❌ 已禁用 | 同上 |
| QConicalGradient | ❌ 已禁用 | 同上 |
| QFont | ❌ 已禁用 | 同上 |
| QPainterPath | ❌ 已禁用 | 同上 |
| QPixmap | ❌ 已禁用 | 同上 |
| QImage | ❌ 已禁用 | 同上 |

#### 多媒体类 (已禁用终结器)

| 类 | 终结器状态 | 原因 |
|----|----------|------|
| QMediaPlayer | ❌ 已禁用 | 可能正在播放 |
| QAudioOutput | ❌ 已禁用 | 可能正在输出 |

### 终结器禁用模式

```cangjie
public class QColor {
    private var ptr: Int64 = 0

    public init(r: Int32, g: Int32, b: Int32) {
        unsafe { ptr = qColorCreateRgb(r, g, b, 255) }
    }

    // 终结器 - 已禁用
    // 原因: 仓颉GC时机不确定,可能导致崩溃
    // 解决方案: 使用短期对象或手动释放
    // ~init() {
    //     if (ptr != 0) {
    //         unsafe { qColorDelete(ptr) }
    //         ptr = 0
    //     }
    // }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qColorDelete(ptr) }
            ptr = 0
        }
    }
}
```

## 手动释放规则

### 必须手动释放的对象

以下对象必须显式调用释放方法:

#### 1. 定时器 (QTimer)

```cangjie
let timer = QTimer()
timer.setInterval(1000)
timer.start()

// 使用完毕后必须停止并释放
timer.stop()
timer.delete()  // 手动释放
```

#### 2. 媒体播放器 (QMediaPlayer)

```cangjie
let player = QMediaPlayer()
player.setSource("music.mp3")
player.play()

// 使用完毕后必须停止并释放
player.stop()
player.delete()  // 手动释放
```

#### 3. 进程对象 (QProcess)

```cangjie
let process = QProcess()
process.start("command")

// 使用完毕后必须终止并释放
process.terminate()
process.waitForFinished()
process.delete()  // 手动释放
```

### 建议手动释放的对象

以下对象建议在合适的时机手动释放:

#### 1. 绘图对象

```cangjie
func paintEvent(event: QPaintEvent) {
    let painter = QPainter(widget)
    let pen = QPen(QColor(255, 0, 0), 2)
    let brush = QBrush(QColor(0, 255, 0))

    painter.setPen(pen)
    painter.setBrush(brush)
    painter.drawRect(10, 10, 100, 100)

    painter.end()  // 结束绘图
    // pen和brush在painter.end()后可安全释放
}
```

#### 2. 颜色和字体对象

```cangjie
func createUI() {
    let label = QLabel()
    label.setText("Hello")
    let color = QColor(255, 0, 0)
    let font = QFont()
    font.setFamily("Arial")
    font.setPointSize(12)

    // 仓颉侧用 String 设置样式表（无 QString 类型）
    label.setStyleSheet("color: red; font-size: 12px;")

    // color和font对象在使用后可释放
    color.delete()
    font.delete()
}
```

### 自动释放的对象

以下对象由Qt父子关系自动管理,无需手动释放:

#### 1. 控件类 (QWidget及其派生类)

```cangjie
let window = QWidget()
let layout = QVBoxLayout()

let label = QLabel()
label.setText("Label")
let button = QPushButton()
button.setText("Button")

// 加入布局（addWidget 收 Int64 指针）
layout.addWidget(label.getPtr())
layout.addWidget(button.getPtr())
window.setLayout(layout.getPtr())  // 布局挂到 window，建立父子关系

window.show()
// window销毁时,自动销毁layout、label和button
```

#### 2. 布局类

```cangjie
let widget = QWidget()
let layout = QVBoxLayout()

let label = QLabel()
let button = QPushButton()
layout.addWidget(label.getPtr())
layout.addWidget(button.getPtr())
widget.setLayout(layout.getPtr())  // widget 为父对象

// widget销毁时,自动销毁layout及其管理的所有控件
```

## 内存泄漏检测

### 常见泄漏场景

#### 1. 未释放绘图对象

```cangjie
// 错误示例
func paintEvent(event: QPaintEvent) {
    let painter = QPainter(widget)
    let color = QColor(255, 0, 0)  // 每次调用创建新对象
    painter.setPen(QPen(color, 2))
    // 未释放color,导致内存泄漏
}

// 正确示例
class MyWidget <: QWidget {
    private let penColor = QColor(255, 0, 0)  // 成员变量复用

    func paintEvent(event: QPaintEvent) {
        let painter = QPainter(this)
        painter.setPen(QPen(penColor, 2))
        painter.end()
    }

    func cleanup() {
        penColor.delete()  // 显式释放
    }
}
```

#### 2. 未停止定时器

```cangjie
// 错误示例
let timer = QTimer()
timer.setInterval(100)
timer.start()
// 程序退出时timer仍在运行,导致资源泄漏

// 正确示例
class MyApp {
    private let timer = QTimer()

    init() {
        timer.setInterval(100)
        timer.start()
    }

    func cleanup() {
        timer.stop()
        timer.delete()
    }
}
```

### 检测方法

#### 1. 使用Qt内存检测工具

```bash
# Linux
valgrind --leak-check=full ./your_app

# Windows
# 使用Visual Studio内存检测工具
```

#### 2. 运行时监控

在关键位置打印对象指针或自定义计数（CJQT6 未提供 `instanceCount` 内建 API，可自行维护计数）：

```cangjie
var gColorCount: Int64 = 0

func createColor(r: Int32, g: Int32, b: Int32): QColor {
    gColorCount = gColorCount + 1
    return QColor(r, g, b)
}

func checkMemory() {
    println("QColor count: ${gColorCount}")
}
```

## 最佳实践

### 1. 使用父子关系管理控件

```cangjie
// 推荐: 通过布局建立父子关系
let window = QWidget()
let layout = QVBoxLayout()
let button = QPushButton()
button.setText("Click")
layout.addWidget(button.getPtr())
window.setLayout(layout.getPtr())  // window 托管 button

// 避免: 无父子关系的独立控件，需手动管理
let button2 = QPushButton()  // 需手动 close/delete
```

### 2. 短期对象立即释放

```cangjie
func drawSomething() {
    let color = QColor(255, 0, 0)
    // 使用color
    useColor(color)

    color.delete()  // 使用完毕立即释放
}
```

### 3. 长期对象使用成员变量

```cangjie
class MyWidget <: QWidget {
    private let bgColor = QColor(240, 240, 240)  // 成员变量
    private let timer = QTimer()

    init() {
        timer.setInterval(1000)
        timer.start()
    }

    func cleanup() {
        timer.stop()
        timer.delete()
        bgColor.delete()
    }
}
```

### 4. 避免在热路径创建对象

```cangjie
// 错误: 每次绘图都创建新对象
func paintEvent(event: QPaintEvent) {
    let pen = QPen(QColor(255, 0, 0), 2)  // 每次创建!
    let painter = QPainter(this)
    painter.setPen(pen)
    // ...
}

// 正确: 复用成员变量
class MyWidget <: QWidget {
    private let pen = QPen(QColor(255, 0, 0), 2)  // 只创建一次

    func paintEvent(event: QPaintEvent) {
        let painter = QPainter(this)
        painter.setPen(pen)
        // ...
    }
}
```

### 5. 使用 try-with-resources（RAII）

实现 `QtResource` 接口的类可用 `try-with-resources` 自动释放（仓颉原生支持）：

```cangjie
// try-with-resources 自动调用 close()
try (color = QColor(255, 0, 0)) {
    useColor(color)
}  // 离开作用域时自动 color.close()
```

> 注意：CJQT6 全局禁用终结器 `~init`，不要依赖 GC 自动清理。`try-with-resources` 是编译期确定性的释放，与 GC 终结器不同，可安全使用。

### 6. 异常安全

```cangjie
func riskyOperation() {
    let resource = QColor(255, 0, 0)
    try {
        // 可能抛出异常的操作
        doSomethingRisky()
        resource.delete()  // 正常路径释放
    } catch (e: Exception) {
        resource.delete()  // 异常路径释放
        throw e
    }
}
```

## 总结

### 资源管理清单

| 类型 | 管理方式 | 释放时机 |
|-----|---------|---------|
| QObject控件 | Qt父子关系 | 父对象销毁时 |
| QTimer | 手动管理 | 停止后立即释放 |
| QMediaPlayer | 手动管理 | 停止后立即释放 |
| 绘图对象 | 短期/成员变量 | 使用后立即/显式释放 |
| 颜色/字体 | 短期/成员变量 | 使用后立即/显式释放 |

### 记住的原则

1. **控件用父子关系** - 让Qt自动管理
2. **定时器要停止释放** - 避免后台运行
3. **绘图对象短期用** - 用完立即释放
4. **成员变量复用** - 避免热路径创建
5. **终结器已禁用** - 必须手动释放或依赖Qt管理，勿依赖 GC

---

*最后更新: 2026-08-29*
