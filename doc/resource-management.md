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
3. **桥接对象**同时持有Qt指针和仓颉引用,需要协调两种内存管理机制

## Qt对象生命周期

### Qt父子关系

Qt使用父子对象树管理内存:

```cangjie
let parent = QWidget()
let child = QPushButton(parent)  // parent成为child的父对象
// parent销毁时,自动销毁所有子对象
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
| 值类型 | 需手动管理或禁用终结器 | QColor, QPen, QBrush |
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
// GC可能在此时触发,调用color的终结器
// 如果Qt仍在使用该颜色对象,会访问已释放内存 -> 崩溃!
```

## 终结器机制

### 终结器状态表

以下是CJQT6中各类的终结器启用状态:

#### 核心类 (已禁用终结器)

| 类 | 终结器状态 | 原因 |
|----|----------|------|
| QWidget | ❌ 已禁用 | Qt父子关系管理 |
| QApplication | ❌ 已禁用 | 全局唯一对象 |
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

#### 绘图类 (待禁用终结器) ⚠️

| 类 | 终结器状态 | 风险等级 |
|----|----------|---------|
| QColor | ❌ 需禁用 | 🔴 高 |
| QPen | ❌ 需禁用 | 🔴 高 |
| QBrush | ❌ 需禁用 | 🔴 高 |
| QLinearGradient | ❌ 需禁用 | 🔴 高 |
| QRadialGradient | ❌ 需禁用 | 🔴 高 |
| QConicalGradient | ❌ 需禁用 | 🔴 高 |
| QFont | ❌ 需禁用 | 🔴 高 |
| QPainterPath | ❌ 需禁用 | 🔴 高 |
| QPixmap | ❌ 需禁用 | 🔴 高 |
| QImage | ❌ 需禁用 | 🔴 高 |

#### 多媒体类 (已禁用终结器)

| 类 | 终结器状态 | 原因 |
|----|----------|------|
| QMediaPlayer | ❌ 已禁用 | 可能正在播放 |
| QAudioOutput | ❌ 已禁用 | 可能正在输出 |

### 终结器禁用模式

```cangjie
public class QColor {
    private var ptr: CPointer = 0
    
    public init(r: Int64, g: Int64, b: Int64) {
        ptr = unsafe { qColorNew(r, g, b) }
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
    
    public func delete() {
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
    let label = QLabel("Hello")
    let color = QColor(255, 0, 0)
    let font = QFont("Arial", 12)
    
    let style = QString("color: red; font-size: 12px;")
    label.setStyleSheet(style)
    
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
let layout = QVBoxLayout(window)

let label = QLabel("Label", window)  // window为父对象
let button = QPushButton("Button", window)  // window为父对象

layout.addWidget(label)
layout.addWidget(button)

window.show()
// window销毁时,自动销毁label和button
```

#### 2. 布局类

```cangjie
let widget = QWidget()
let layout = QVBoxLayout(widget)  // widget为父对象

layout.addWidget(QLabel("Label"))
layout.addWidget(QPushButton("Button"))

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
        penColor.delete()  // 析构时释放
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

```cangjie
// 在关键位置打印对象计数
func checkMemory() {
    println("QColor count: ${QColor.instanceCount}")
    println("QTimer count: ${QTimer.instanceCount}")
}
```

## 最佳实践

### 1. 使用父子关系管理控件

```cangjie
// 推荐: 使用父子关系
let window = QWidget()
let button = QPushButton("Click", window)  // window为父对象

// 避免: 无父子关系的控件
let button2 = QPushButton()  // 需手动管理
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

### 5. 使用RAII模式

```cangjie
class ScopedTimer {
    private let timer: QTimer
    
    init(interval: Int64) {
        timer = QTimer()
        timer.setInterval(interval)
        timer.start()
    }
    
    ~init() {
        timer.stop()
        timer.delete()
    }
}

// 使用
func doWork() {
    let scoped = ScopedTimer(1000)
    // timer自动管理
}  // 离开作用域时自动清理
```

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
| 绘图对象 | 短期/成员变量 | 使用后立即/析构时 |
| 颜色/字体 | 短期/成员变量 | 使用后立即/析构时 |

### 记住的原则

1. **控件用父子关系** - 让Qt自动管理
2. **定时器要停止释放** - 避免后台运行
3. **绘图对象短期用** - 用完立即释放
4. **成员变量复用** - 避免热路径创建
5. **终结器已禁用** - 必须手动释放或依赖Qt管理

---

*最后更新: 2026-05-06*
*基于CODE_REVIEW.md第七轮审查报告*
