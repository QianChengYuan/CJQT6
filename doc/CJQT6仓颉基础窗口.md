# CJQT6 仓颉语言基础窗口示例

## 项目概述

CJQT6 提供了仓颉语言对 Qt6 的封装,让开发者可以使用仓颉语言编写跨平台的GUI应用程序。

## 项目结构

```
CJQT6/
├── src/
│   ├── types.cj              # 仓颉语言基础类型定义
│   ├── core.cj               # 仓颉语言核心模块 (QApplication, QWidget等)
│   └── bridge.cpp            # C++桥接实现
├── examples/
│   ├── hello_window.cj       # Hello World 窗口示例
│   └── window_demo.cj        # 完整窗口示例
└── build/
    └── lib/
        └── libcjqt6_bridge.so  # 桥接库
```

## 功能特性

### 已实现的仓颉语言类

1. **QApplication** - 应用程序类
   - `init()` - 创建应用程序
   - `exec()` - 运行事件循环
   - `quit()` - 退出应用程序

2. **QWidget** - 基础窗口部件
   - `show()` - 显示窗口
   - `hide()` - 隐藏窗口
   - `setTitle(title)` - 设置窗口标题
   - `resize(width, height)` - 调整窗口大小
   - `setGeometry(x, y, width, height)` - 设置窗口位置和大小

3. **QLabel** - 标签控件
   - `setText(text)` - 设置文本
   - `setAlignment(alignment)` - 设置对齐方式

4. **QPushButton** - 按钮控件
   - `setText(text)` - 设置按钮文本
   - `setOnClick(callback)` - 设置点击回调

5. **QTimer** - 定时器
   - `setInterval(interval)` - 设置间隔
   - `start()` - 启动定时器
   - `stop()` - 停止定时器
   - `setTimeout(callback)` - 设置超时回调

### 基础类型

- **Option** - 可选类型,类似 Rust 的 Option
- **Result** - 结果类型,用于错误处理
- **Array** - 数组类型

## 编译和运行

### 1. 编译桥接库

```bash
mkdir build && cd build
cmake ..
make cjqt6_bridge
```

### 2. 编译仓颉代码

```bash
# 编译示例程序
cjc examples/hello_window.cj -L./build/lib -o hello_window

# 运行示例
LD_LIBRARY_PATH=./build/lib ./hello_window
```

## 示例代码

### Hello World 示例

```cj
import CJQT6.core
import CJQT6.types

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("Hello, CJQT6!")
    window.resize(400, 300)
    window.show()
    let result = app.exec()
    window.delete()
    app.delete()
    return result
}
```

### 按钮示例

```cj
import CJQT6.core
import CJQT6.types

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("按钮示例")
    
    let button = QPushButton()
    button.setText("点击我")
    button.setOnClick {
        println("按钮被点击!")
    }
    
    window.show()
    let result = app.exec()
    button.delete()
    window.delete()
    app.delete()
    return result
}
```

## 技术架构

### FFI (Foreign Function Interface)

仓颉语言通过 `foreign` 关键字声明外部函数,调用 C++ 实现的 Qt6 桥接函数:

```cj
// 仓颉语言声明
foreign func qWidgetCreate(): Int64
foreign func qWidgetShow(ptr: Int64)
foreign func qWidgetSetTitle(ptr: Int64, title: String)

// C++ 实现
extern "C" {
    int64_t qWidgetCreate() {
        QWidget* widget = new QWidget();
        return reinterpret_cast<int64_t>(widget);
    }
    
    void qWidgetShow(int64_t ptr) {
        QWidget* widget = reinterpret_cast<QWidget*>(ptr);
        if (widget) {
            widget->show();
        }
    }
}
```

### 内存管理

- 仓颉语言侧持有 C++ 对象指针 (Int64)
- 通过显式的 `delete()` 方法释放 C++ 资源
- 支持对象树管理,父对象销毁时自动清理子对象

### 回调机制

使用 C++ lambda 和 Qt 信号槽机制实现仓颉回调:

```cpp
void qButtonSetOnClick(int64_t ptr, void (*callback)(int64_t)) {
    QPushButton* button = reinterpret_cast<QPushButton*>(ptr);
    g_buttonCallbacks[ptr] = [callback](int64_t) { callback(ptr); };
    QObject::connect(button, &QPushButton::clicked, [ptr]() {
        auto it = g_buttonCallbacks.find(ptr);
        if (it != g_buttonCallbacks.end()) {
            it->second(ptr);
        }
    });
}
```

## 开发计划

### 已完成
- ✓ 基础类型定义
- ✓ QApplication 实现
- ✓ QWidget 基础功能
- ✓ QLabel 控件
- ✓ QPushButton 控件
- ✓ QTimer 定时器
- ✓ C++ 桥接层

### 进行中
- ⏳ 布局系统实现
- ⏳ 更多控件封装

### 计划中
- 📋 QFileDialog 文件对话框
- 📋 QMessageBox 消息对话框
- 📋 QLineEdit 文本输入框
- 📋 QTextEdit 多行文本框
- 📋 QComboBox 下拉框
- 📋 QListWidget 列表控件

## 注意事项

1. **内存管理**: 确保在程序退出前调用 `delete()` 释放资源
2. **回调生命周期**: 回调函数要保持简洁,避免内存泄漏
3. **线程安全**: 当前版本仅支持主线程操作
4. **错误处理**: 桥接层暂不完善,注意空指针检查

## 参考资源

- [Qt6 官方文档](https://doc.qt.io/qt-6/)
- [仓颉语言文档](https://developer.huawei.com/consumer/cn/forum/home)
- [Cangjie-TPC/CJQT](https://gitcode.com/Cangjie-TPC/CJQT) - 参考项目

## 许可证

待定