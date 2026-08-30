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
│  libcjqt6_bridge.so / cjqt6_bridge.dll  │
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
let button = QPushButton()

1. 调用 QPushButton.init()
2. init() 调用 FFI函数: qButtonCreate()
3. FFI函数创建Qt对象: new QPushButton()
4. 返回Qt对象指针: Int64
5. 仓颉对象保存指针: this.ptr = ptr
```

#### 2. 方法调用流程

```
仓颉侧:
button.setText("New Text")

1. 调用 QPushButton.setText()
2. 用 LibC.mallocCString 把 String 转成 CString
3. setText() 调用 FFI函数: qButtonSetText(this.ptr, cstr)
4. FFI函数调用Qt方法: button->setText(QString::fromUtf8(cstr))
5. 用 LibC.free(cstr) 释放 CString
6. Qt对象状态更新
```

### 数据类型映射

#### 基础类型映射表

| 仓颉类型 | C++类型 | FFI类型 | 说明 |
|---------|--------|---------|------|
| Int64 | long long | Int64 | 整数 / Qt对象指针 |
| Int32 | int | Int32 | 32位整数 |
| Float64 | double | Float64 | 浮点数 |
| Bool | bool | Bool | 布尔值 |
| String | QString | CString | 字符串(需 LibC.mallocCString 转换) |
| Unit | void | Unit | 无返回值 |

> **说明**：CJQT6 中所有 Qt 对象指针统一用 `Int64` 承载（非 `CPointer`），布局 `addWidget`/`addLayout`/`setMenu` 等收的也是 `Int64`（由 `xxx.getPtr()` 取得）。

#### 复合类型映射

| 仓颉类型 | Qt类型 | 处理方式 |
|---------|--------|---------|
| QString | QString | C字符串转换(LibC.mallocCString / CString.toString) |
| QColor | QColor | 指针包装 |
| QWidget | QWidget | 指针包装(Int64) |
| QRect | QRect | 结构体转换 |
| QSize | QSize | 结构体转换 |

### 字符串处理

#### 仓颉String → QString

```cangjie
// 仓颉侧：QWidget.setTitle
public func setTitle(title: String): Unit {
    checkValid()
    unsafe {
        let cstr = LibC.mallocCString(title)
        qWidgetSetTitle(ptr, cstr)
        LibC.free(cstr)
    }
}
```

```cpp
// C++桥接侧
extern "C" void qWidgetSetTitle(void* widget, const char* title) {
    QWidget* w = static_cast<QWidget*>(widget);
    w->setWindowTitle(QString::fromUtf8(title));
}
```

#### QString → 仓颉String

```cangjie
// 仓颉侧：QPushButton.text
public func text(): String {
    checkValid()
    unsafe {
        let cstr = qButtonText(ptr)
        let result = cstr.toString()
        freeBridgeString(cstr)
        return result
    }
}
```

```cpp
// C++桥接侧
extern "C" const char* qButtonText(void* widget) {
    QPushButton* b = static_cast<QPushButton*>(widget);
    // 返回由桥接层分配的字符串，仓颉侧用 freeBridgeString 释放
    return strdup(b->text().toUtf8().data());
}
```

> **注意**：返回侧的 CString 由桥接层分配，仓颉侧需用 `freeBridgeString`（而非 `LibC.free`）释放，避免分配/释放器不匹配。

### 内存管理边界

#### 所有权规则

```
仓颉对象 ──拥有──> Qt指针(Int64) ──指向──> Qt对象

├─ 仓颉对象由仓颉GC管理
├─ Qt对象由Qt父子关系或显式 close()/delete() 管理
└─ 指针(Int64)是连接两者的桥梁
```

#### 对象生命周期

```
创建:
仓颉对象.init() ──创建──> Qt对象

使用:
仓颉对象.method() ──FFI──> Qt对象.method()

销毁(二选一,不可依赖GC):
仓颉对象.close() ──删除──> Qt对象          # 显式释放
    或
Qt父对象销毁 ──自动──> Qt子对象销毁          # 父子关系托管
```

> **重要**：CJQT6 全局禁用终结器 `~init`。GC 时机不确定，依赖终结器会在 Qt 对象仍被使用时提前删除导致崩溃。用完必须显式 `close()`/`delete()`，或交给 Qt 父子关系托管。

## 资源管理策略

### 双重管理问题

CJQT6面临两种内存管理系统:

1. **仓颉GC** - 不确定时机的垃圾回收
2. **Qt父子关系** - 确定性的父子对象管理

### 解决方案: 终结器禁用 + 显式释放

所有 Qt 封装类实现 `QtResource` 接口，持有 `ptr: Int64`，**不定义终结器**，依赖以下两种方式管理生命周期：

- **Qt 父子关系托管**：构造时传入 parent，parent 销毁时子对象自动销毁
- **显式释放**：调用 `close()`（实现 QtResource）或 `delete()` 释放底层对象

```cangjie
public interface QtResource {
    func isClosed(): Bool
    func close(): Unit          // 关闭资源，释放底层Qt对象
    func getPtr(): Int64        // 获取原生指针
    func isValid(): Bool
    func checkValid(): Unit     // 检查有效性，无效时抛出异常
}

public class QPushButton <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    public init() {
        unsafe {
            ptr = qButtonCreate()
            if (ptr == 0) {
                throw CreateFailedException("QPushButton 创建失败")
            }
        }
        trackObject(ptr)
    }

    // 终结器已禁用：不定义 ~init
    // 用完须显式 close()，或交给 Qt 父子关系托管
}
```

### 特殊情况处理

#### 必须手动释放的对象

某些对象无法依赖Qt父子关系,必须手动管理:

| 对象类型 | 原因 | 处理方式 |
|---------|------|---------|
| QTimer | 可能仍在事件循环中 | 调用stop()后close() |
| QMediaPlayer | 可能正在播放 | 调用stop()后close() |
| QColor/QPen等 | 可能被Qt引用 | 短期使用或手动close() |

### 最佳实践

参见 [资源管理指南](../resource/resource-management.md)

## 信号槽实现

### Qt信号槽机制

Qt使用信号槽实现事件驱动编程:

```cpp
// C++ Qt
QObject::connect(button, &QPushButton::clicked,
                 [](){ qDebug() << "Clicked!"; });
```

### CJQT6实现方案

使用 `CFunc` 回调类型 + `setOnXxx` 注册函数实现仓颉侧的信号槽：

#### 1. 定义回调类型（集中在 signal.cj）

```cangjie
// src/core/signal.cj
public type VoidCallback = CFunc<() -> Unit>
public type Int32Callback = CFunc<(Int32) -> Unit>
public type CStringCallback = CFunc<(CString) -> Unit>
public type Int64Callback = CFunc<(Int64) -> Unit>
public type BoolCallback = CFunc<(Bool) -> Unit>
```

#### 2. 桥接层注册回调

```cpp
// C++桥接层
extern "C" void qButtonConnectClicked(void* button, void (*callback)()) {
    QPushButton* btn = static_cast<QPushButton*>(button);
    QObject::connect(btn, &QPushButton::clicked, [callback]() {
        callback();
    });
}
```

#### 3. 仓颉侧注册函数

```cangjie
// src/widgets/pushbutton.cj
public func setOnClicked(callback: VoidCallback): Unit {
    checkValid()
    unsafe {
        qButtonConnectClicked(ptr, callback)
    }
}
```

#### 4. 使用示例

```cangjie
let button = QPushButton()
button.setOnClicked(cFunc() {
    println("Button clicked!")
})
```

> **约束**：`CFunc` 回调不能捕获局部变量。需要共享状态时，用顶层 `let` 绑定 + 全局 `?T` 变量传递。

### 回调类型定义

| 信号 | 回调类型 | 参数 |
|-----|---------|------|
| clicked | VoidCallback | 无 |
| textChanged | CStringCallback | 新文本(CString) |
| valueChanged | Int32Callback | 新值 |
| toggled | Int32Callback | 是否选中 |

## 模块划分

### 核心模块 (src/core)

| 文件 | 功能 | 主要类 |
|-----|------|-------|
| application.cj | 应用管理 | QApplication |
| widget.cj | 窗口基类 | QWidget |
| resource.cj | 资源管理 | QtResource, QtException |
| signal.cj | 信号槽 | VoidCallback 等回调类型 |
| timer.cj | 定时器 | QTimer |
| events.cj | 事件系统 | QEvent |
| process.cj | 进程管理 | QProcess |
| emitter.cj | 信号发射器 | SignalEmitter |
| callback.cj | 回调调度 | 回调注册/分发 |
| animation.cj | 动画 | QPropertyAnimation |
| settings.cj | 配置 | QSettings |
| shortcut.cj | 快捷键 | QShortcut |
| clipboard.cj | 剪贴板 | QClipboard |
| screen.cj | 屏幕 | QScreen |
| json.cj | JSON | QJsonObject |
| thread.cj | 线程 | QThread |
| undostack.cj | 撤销栈 | QUndoStack |
| filewatcher.cj | 文件监视 | QFileSystemWatcher |
| standardpaths.cj | 标准路径 | QStandardPaths |
| gui_test_env.cj | 测试环境 | GUITestEnvironment |
| common.cj | 公共声明 | 公共 FFI |
| cstring_utils.cj | 字符串工具 | freeBridgeString 等 |
| 其他 | dragdrop/uiposter/itemselectionmodel/propertyanimation/desktopservices | … |

### 控件模块 (src/widgets)

| 文件 | 功能 | 主要类 |
|-----|------|-------|
| common.cj | 通用控件 | 公共声明 |
| label.cj | 文本标签 | QLabel |
| pushbutton.cj | 按钮 | QPushButton |
| lineedit.cj | 单行输入 | QLineEdit |
| textedit.cj | 多行文本 | QTextEdit |
| plaintextedit.cj | 纯文本编辑 | QPlainTextEdit |
| textbrowser.cj | 文本浏览 | QTextBrowser |
| checkbox.cj | 复选框 | QCheckBox |
| radiobutton.cj | 单选按钮 | QRadioButton |
| spinbox.cj | 数值框 | QSpinBox |
| doublespinbox.cj | 双精度数值框 | QDoubleSpinBox |
| slider.cj | 滑块 | QSlider |
| combobox.cj | 下拉框 | QComboBox |
| progressbar.cj | 进度条 | QProgressBar |
| validators.cj | 验证器 | QValidator |
| containers.cj | 容器 | QGroupBox/QFrame 等 |
| toolbutton.cj | 工具按钮 | QToolButton |
| toolbox.cj | 工具箱 | QToolBox |
| dial.cj | 旋钮 | QDial |
| scrollbar.cj | 滚动条 | QScrollBar |
| stackedwidget.cj | 堆叠窗口 | QStackedWidget |
| datetime.cj | 日期时间 | QDateTimeEdit |
| graphicsview.cj | 图形视图 | QGraphicsView |
| graphicsitem.cj | 图形项 | QGraphicsItem |
| graphiceffect.cj | 图形效果 | QGraphicsEffect |
| fontcombobox.cj | 字体下拉框 | QFontComboBox |
| completer.cj | 补全器 | QCompleter |
| systemtrayicon.cj | 系统托盘 | QSystemTrayIcon |
| splashscreen.cj | 启动画面 | QSplashScreen |
| uiloader.cj | UI加载器 | QUiLoader |
| 其他 | commandlinkbutton/dialogbuttonbox/dockwidget/lcdnumber/mdiarea/rubberband/sizegrip/buttongroup/keysequenceedit | … |

### GUI模块 (src/gui)

| 文件 | 功能 | 主要类 |
|-----|------|-------|
| types.cj | 基础类型 | QColor, QSize, QRect |
| layout.cj | 布局管理 | QVBoxLayout, QHBoxLayout, QGridLayout |
| font.cj | 字体 | QFont |
| icon.cj | 图标 | QIcon |
| cursor.cj | 光标 | QCursor |
| palette.cj | 调色板 | QPalette |
| style.cj | 样式 | QStyle |
| textdoc.cj | 文档 | QTextDocument |
| syntaxhighlighter.cj | 语法高亮 | QSyntaxHighlighter |

### 其他模块

| 模块 | 路径 | 主要内容 |
|------|------|---------|
| 对话框 | src/dialogs | QMessageBox/QFileDialog 等对话框 |
| 菜单 | src/menu | QMenuBar/QMenu/QAction |
| 绘图 | src/paint | QPainter/QPen/QBrush/QImage |
| 多媒体 | src/multimedia | QMediaPlayer/QCamera/QAudioOutput 等 |
| 视图 | src/views | QTreeView/QListView/QTableView |
| 网络 | src/network | QTcpSocket/QNetworkAccessManager 等 |
| SQL | src/sql | QSqlDatabase/QSqlQuery |
| QML | src/qml | QQmlApplicationEngine |
| 打印 | src/print | QPrinter/QPrintDialog |
| 资源 | src/resource | 资源管理辅助 |
| 图表 | src/charts | QtCharts 封装 |

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
│   ├─ ptr: Int64 (8字节)
│   ├─ closed: Bool
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
// native/src/widgets/bridge_new_widget.cpp
extern "C" void* qNewWidgetCreate(const char* text, void* parent) {
    QWidget* p = static_cast<QWidget*>(parent);
    NewWidget* w = new NewWidget(QString::fromUtf8(text), p);
    return w;
}

extern "C" void qNewWidgetSetText(void* widget, const char* text) {
    NewWidget* w = static_cast<NewWidget*>(widget);
    w->setText(QString::fromUtf8(text));
}

extern "C" void qNewWidgetDelete(void* widget) {
    delete static_cast<NewWidget*>(widget);
}
```

#### 2. 仓颉封装层

```cangjie
// src/widgets/new_widget.cj
package cjqt6.widgets

import cjqt6.core.*

foreign func qNewWidgetCreate(text: CString, parent: Int64): Int64
foreign func qNewWidgetSetText(ptr: Int64, text: CString): Unit
foreign func qNewWidgetDelete(ptr: Int64): Unit

public class NewWidget <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    public init(text: String, parent!: Int64 = 0) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            ptr = qNewWidgetCreate(cstr, parent)
            LibC.free(cstr)
            if (ptr == 0) {
                throw CreateFailedException("NewWidget 创建失败")
            }
        }
        trackObject(ptr)
    }

    public func setText(text: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            qNewWidgetSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func close(): Unit {
        if (!closed) {
            unsafe { qNewWidgetDelete(ptr) }
            closed = true
        }
    }

    public func getPtr(): Int64 { ptr }
    public func isClosed(): Bool { closed }
    public func isValid(): Bool { ptr != 0 && !closed }
    public func checkValid(): Unit {
        if (!isValid()) { throw ResourceDisposedException("NewWidget 已释放") }
    }
}
```

#### 3. 构建集成

```cmake
# native/CMakeLists.txt
SOURCES += src/widgets/bridge_new_widget.cpp
```

> 完整流程见 [CONTRIBUTING.md](../CONTRIBUTING.md) 与项目根 `AGENTS.md`。

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

*最后更新: 2026-08-29*
