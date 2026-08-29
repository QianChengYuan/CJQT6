# CJQT6 架构设计文档

本文档详细介绍CJQT6的系统架构、设计决策和实现原理。

## 目录

- [设计目标](#设计目标)
- [架构概览](#架构概览)
- [FFI桥接机制](#ffi桥接机制)
- [资源管理策略](#资源管理策略)
- [信号槽实现](#信号槽实现)
- [模块划分](#模块划分)
- [性能考量](#性能考量)

## 设计目标

### 核心目标

1. **原生API风格** - 提供符合仓颉语言习惯的API
2. **类型安全** - 编译时类型检查,避免运行时错误
3. **完整封装** - 覆盖Qt6主要功能模块
4. **高效桥接** - 最小化FFI调用开销
5. **易用性** - 降低学习曲线,快速上手

### 设计原则

- **最小惊讶原则** - API行为符合直觉
- **零成本抽象** - 不引入额外性能开销
- **安全优先** - 内存安全和类型安全
- **渐进增强** - 从简单到复杂,逐步学习

## 架构概览

### 系统层次图

```
┌─────────────────────────────────────────┐
│         仓颉应用层 (用户代码)            │
└────────────────┬────────────────────────┘
                 │ 调用
┌────────────────▼────────────────────────┐
│      CJQT6封装层 (仓颉代码)              │
│  ┌──────────┐  ┌──────────┐  ┌────────┐│
│  │ widgets  │  │   gui    │  │  core  ││
│  └──────────┘  └──────────┘  └────────┘│
└────────────────┬────────────────────────┘
                 │ FFI调用
┌────────────────▼────────────────────────┐
│      FFI桥接层 (C++动态库)               │
│  libCJQT6_bridge.so / CJQT6_bridge.dll  │
└────────────────┬────────────────────────┘
                 │ Qt C++ API
┌────────────────▼────────────────────────┐
│         Qt6 C++层 (Qt框架)               │
│  QtCore, QtWidgets, QtGui, QtMultimedia │
└─────────────────────────────────────────┘
```

### 数据流

```
仓颉对象 ──创建──> FFI桥接对象 ──包装──> Qt C++对象
    │                                      │
    │ 调用方法                              │ Qt操作
    │                                      │
    └───FFI函数调用───> C++桥接函数 ───调用──>┘
```

## FFI桥接机制

### 调用流程

#### 1. 对象创建流程

```
仓颉侧:
let button = QPushButton("Click")

1. 调用 QPushButton.init()
2. init() 调用 FFI函数: pushButtonNew(text)
3. FFI函数创建Qt对象: new QPushButton(text)
4. 返回Qt对象指针: CPointer
5. 仓颉对象保存指针: this.ptr = pointer
```

#### 2. 方法调用流程

```
仓颉侧:
button.setText("New Text")

1. 调用 QPushButton.setText()
2. setText() 调用 FFI函数: pushButtonSetText(this.ptr, text)
3. FFI函数调用Qt方法: button->setText(text)
4. Qt对象状态更新
```

### 数据类型映射

#### 基础类型映射表

| 仓颉类型 | C++类型 | FFI类型 | 说明 |
|---------|--------|---------|------|
| Int64 | long long | Int64 | 整数 |
| Float64 | double | Float64 | 浮点数 |
| Bool | bool | Bool | 布尔值 |
| String | QString | CPointer | 字符串(需转换) |
| CPointer | void* | CPointer | 原始指针 |
| Unit | void | Unit | 无返回值 |

#### 复合类型映射

| 仓颉类型 | Qt类型 | 处理方式 |
|---------|--------|---------|
| QString | QString | C字符串转换 |
| QColor | QColor | 指针包装 |
| QWidget | QWidget | 指针包装 |
| QRect | QRect | 结构体转换 |
| QSize | QSize | 结构体转换 |

### 字符串处理

#### 仓颉String → QString

```cangjie
// 仓颉侧
func setTitle(title: String) {
    unsafe { 
        widgetSetTitle(this.ptr, title.cStr()) 
    }
}
```

```cpp
// C++桥接侧
extern "C" void widgetSetTitle(void* widget, const char* title) {
    QWidget* w = static_cast<QWidget*>(widget);
    w->setTitle(QString::fromUtf8(title));
}
```

#### QString → 仓颉String

```cangjie
// 仓颉侧
func getTitle(): String {
    unsafe {
        let cstr = widgetGetTitle(this.ptr)
        return String.fromCStr(cstr)
    }
}
```

```cpp
// C++桥接侧
extern "C" const char* widgetGetTitle(void* widget) {
    QWidget* w = static_cast<QWidget*>(widget);
    return w->title().toUtf8().data();
}
```

### 内存管理边界

#### 所有权规则

```
仓颉对象 ──拥有──> Qt指针 ──指向──> Qt对象

├─ 仓颉对象由仓颉GC管理
├─ Qt对象由Qt或CJQT6管理
└─ 指针是连接两者的桥梁
```

#### 对象生命周期

```
创建:
仓颉对象.init() ──创建──> Qt对象

使用:
仓颉对象.method() ──FFI──> Qt对象.method()

销毁:
仓颉对象.~init() ──删除──> Qt对象
    或
Qt父对象销毁 ──自动──> Qt子对象销毁
```

## 资源管理策略

### 双重管理问题

CJQT6面临两种内存管理系统:

1. **仓颉GC** - 不确定时机的垃圾回收
2. **Qt父子关系** - 确定性的父子对象管理

### 解决方案: 终结器禁用

大多数Qt类禁用终结器,依赖Qt的父子关系管理:

```cangjie
public class QPushButton <: QWidget {
    private var ptr: CPointer = 0
    
    public init(text: String, parent: QWidget = null) {
        let parentPtr = parent != null ? parent.ptr : 0
        ptr = unsafe { pushButtonNew(text.cStr(), parentPtr) }
        // Qt自动管理: parent销毁时,此对象也会销毁
    }
    
    // 终结器已禁用
    // ~init() { ... }  // 不定义终结器
}
```

### 特殊情况处理

#### 必须手动释放的对象

某些对象无法依赖Qt父子关系,必须手动管理:

| 对象类型 | 原因 | 处理方式 |
|---------|------|---------|
| QTimer | 可能仍在事件循环中 | 调用stop()后delete() |
| QMediaPlayer | 可能正在播放 | 调用stop()后delete() |
| QColor/QPen等 | 可能被Qt引用 | 短期使用或手动delete() |

### 最佳实践

参见 [资源管理指南](./resource-management.md)

## 信号槽实现

### Qt信号槽机制

Qt使用信号槽实现事件驱动编程:

```cpp
// C++ Qt
QObject::connect(button, &QPushButton::clicked, 
                 [](){ qDebug() << "Clicked!"; });
```

### CJQT6实现方案

使用CFunc回调实现仓颉侧的信号槽:

#### 1. 定义回调类型

```cangjie
// 定义回调函数类型
public type ButtonClickedCallback = CFunc<(CPointer)>
public type LineEditTextChangedCallback = CFunc<(CPointer, CPointer)>
```

#### 2. 桥接层注册回调

```cpp
// C++桥接层
extern "C" void pushButtonConnectClicked(
    void* button, 
    void (*callback)(void*)
) {
    QPushButton* btn = static_cast<QPushButton*>(button);
    QObject::connect(btn, &QPushButton::clicked, [callback, button]() {
        callback(button);
    });
}
```

#### 3. 仓颉侧信号类

```cangjie
public class Signal<T> {
    private var ptr: CPointer = 0
    private var callbacks: ArrayList<T> = ArrayList<T>()
    
    public func connect(callback: T) {
        callbacks.add(callback)
        // 注册到Qt
    }
    
    public func emit(args: ...) {
        // 触发所有回调
        for (cb in callbacks) {
            cb(args)
        }
    }
}
```

#### 4. 使用示例

```cangjie
let button = QPushButton("Click")
button.clicked.connect(func() {
    println("Button clicked!")
})
```

### 回调类型定义

| 信号 | 回调类型 | 参数 |
|-----|---------|------|
| clicked | CFunc<(CPointer)> | 无 |
| textChanged | CFunc<(CPointer, CPointer)> | 新文本 |
| valueChanged | CFunc<(CPointer, Int64)> | 新值 |

## 模块划分

### 核心模块 (src/core)

| 文件 | 功能 | 主要类 |
|-----|------|-------|
| application.cj | 应用管理 | QApplication |
| widget.cj | 窗口基类 | QWidget |
| timer.cj | 定时器 | QTimer |
| signal.cj | 信号槽 | Signal, Slot |
| events.cj | 事件系统 | QEvent |
| process.cj | 进程管理 | QProcess |

### 控件模块 (src/widgets)

| 文件 | 功能 | 主要类 |
|-----|------|-------|
| common.cj | 通用控件 | - |
| label.cj | 文本标签 | QLabel |
| pushbutton.cj | 按钮 | QPushButton |
| lineedit.cj | 单行输入 | QLineEdit |
| textedit.cj | 多行文本 | QTextEdit |
| checkbox.cj | 复选框 | QCheckBox |
| radiobutton.cj | 单选按钮 | QRadioButton |
| spinbox.cj | 数值框 | QSpinBox |
| slider.cj | 滑块 | QSlider |
| combobox.cj | 下拉框 | QComboBox |
| progressbar.cj | 进度条 | QProgressBar |

### GUI模块 (src/gui)

| 文件 | 功能 | 主要类 |
|-----|------|-------|
| types.cj | 基础类型 | QColor, QSize, QRect |
| layout.cj | 布局管理 | QVBoxLayout, QHBoxLayout, QGridLayout |

### 绘图模块 (src/paint)

| 文件 | 功能 | 主要类 |
|-----|------|-------|
| painter.cj | 绘图系统 | QPainter, QPen, QBrush, QImage |

### 多媒体模块

| 类 | 功能 |
|----|------|
| QMediaPlayer | 媒体播放 |
| QAudioOutput | 音频输出 |

## 性能考量

### FFI调用开销

每次FFI调用都有一定开销,优化策略:

#### 1. 批量操作

```cangjie
// 避免: 多次FFI调用
widget.setProperty1(a)
widget.setProperty2(b)
widget.setProperty3(c)

// 推荐: 一次性设置
widget.setProperties(a, b, c)
```

#### 2. 缓存Qt值

```cangjie
// 避免: 重复获取
for (i in 0..1000) {
    let width = widget.width()  // 每次FFI调用
    use(width)
}

// 推荐: 缓存
let width = widget.width()
for (i in 0..1000) {
    use(width)
}
```

#### 3. 减少对象创建

```cangjie
// 避免: 频繁创建临时对象
func paintEvent() {
    let color = QColor(255, 0, 0)  // 每次创建!
    painter.setPen(QPen(color, 2))
}

// 推荐: 复用对象
class MyWidget {
    private let pen = QPen(QColor(255, 0, 0), 2)
    func paintEvent() {
        painter.setPen(pen)
    }
}
```

### 内存布局

```
仓颉对象 (仓颉堆)
├─ vtable
├─ 字段
│   ├─ ptr: CPointer (8字节)
│   └─ 其他字段
└─ ...

Qt对象 (C++堆)
├─ vtable
├─ QObject基类
│   ├─ parent
│   ├─ children
│   └─ ...
└─ 派生类字段
```

### 线程安全

- Qt要求GUI操作在主线程
- 仓颉线程与Qt线程不共享对象
- 使用信号槽跨线程通信

## 扩展机制

### 添加新控件

#### 1. C++桥接层

```cpp
// native/src/widgets/new_widget.cpp
extern "C" void* newWidgetNew(const char* text, void* parent) {
    QWidget* p = static_cast<QWidget*>(parent);
    NewWidget* w = new NewWidget(QString::fromUtf8(text), p);
    return w;
}

extern "C" void newWidgetSetText(void* widget, const char* text) {
    NewWidget* w = static_cast<NewWidget*>(widget);
    w->setText(QString::fromUtf8(text));
}
```

#### 2. 仓颉封装层

```cangjie
// src/widgets/new_widget.cj
public class NewWidget <: QWidget {
    private var ptr: CPointer = 0
    
    public init(text: String, parent: QWidget = null) {
        let parentPtr = parent != null ? parent.ptr : 0
        ptr = unsafe { newWidgetNew(text.cStr(), parentPtr) }
    }
    
    public func setText(text: String) {
        unsafe { newWidgetSetText(ptr, text.cStr()) }
    }
}
```

#### 3. 构建集成

```cmake
# native/CMakeLists.txt
SOURCES += src/widgets/new_widget.cpp
```

## 未来展望

### 计划增强

1. **QML集成** - 完善QML支持
2. **样式系统** - QSS样式表支持
3. **高DPI支持** - 自适应缩放
4. **无障碍** - 辅助功能
5. **国际化** - 多语言支持

### 性能优化

1. **对象池** - 复用常用对象
2. **延迟加载** - 按需加载模块
3. **批量FFI** - 减少调用次数

---

*最后更新: 2026-05-06*
