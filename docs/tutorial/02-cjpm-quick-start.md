# CJQT6 快速开始

本教程将帮助您在5分钟内创建第一个CJQT6 GUI应用程序。

## 创建第一个窗口

### 1. 新建项目

```bash
cjpm init hello_window
cd hello_window
```

### 2. 配置依赖

编辑 `cjpm.toml`，以本地路径依赖 CJQT6 根包（与仓库示例工程一致）：
```toml
[package]
  name = "hello_window"
  version = "1.0.0"

[dependencies]
  cjqt6 = { path = "../../" }   # 指向 CJQT6 仓库根目录
```

> 说明：CJQT6 当前版本 1.9.0。`link-option` 还需引用本机桥接库路径，可参考 `examples/all_controls_demo/cjpm.toml`。构建前须先编出 `releases/<platform>/` 下的桥接库（见 [构建指南](../guides/build-guide.md)）。

### 3. 编写代码

创建 `main.cj` 文件：

```cangjie
import cjqt6.core.*
import cjqt6.widgets.*

main(): Int32 {
    // 创建Qt应用（必需，且全局唯一）
    let app = QApplication()

    // 创建主窗口
    let window = QWidget()
    window.setTitle("Hello CJQT6")   // QWidget 用 setTitle
    window.resize(400, 300)

    // 显示窗口
    window.show()

    // 运行应用（进入事件循环）
    return app.exec()
}
```

### 4. 构建运行

```bash
cjpm build
cjpm run
```

🎉 恭喜！您已经创建了第一个CJQT6应用程序！

## 添加交互控件

让我们给窗口添加一个按钮：

```cangjie
import cjqt6.core.*
import cjqt6.widgets.*

// 回调函数（顶层定义，CFunc 不能捕获局部变量）
let clickCallback: VoidCallback = { =>
    println("按钮被点击了！")
}

main(): Int32 {
    let app = QApplication()

    let window = QWidget()
    window.setTitle("按钮示例")
    window.resize(400, 300)

    // 创建按钮（无参构造 + setText）
    let button = QPushButton()
    button.setText("点击我")
    button.resize(120, 40)
    button.move(140, 130)

    // 连接点击信号（setOnClick + CFunc 回调）
    button.setOnClick(clickCallback)

    window.show()
    return app.exec()
}
```

## 使用布局管理器

自动布局让控件排列更简单：

```cangjie
import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

main(): Int32 {
    let app = QApplication()

    let window = QWidget()
    window.setTitle("布局示例")
    window.resize(400, 300)

    // 创建垂直布局（无参构造）
    let layout = QVBoxLayout()

    // 添加控件（addWidget 收 Int64 指针，须 .getPtr()）
    let label = QLabel()
    label.setText("欢迎使用CJQT6")
    layout.addWidget(label.getPtr())

    let button1 = QPushButton()
    button1.setText("按钮 1")
    layout.addWidget(button1.getPtr())

    let button2 = QPushButton()
    button2.setText("按钮 2")
    layout.addWidget(button2.getPtr())

    // 把布局设置到窗口
    window.setLayout(layout.getPtr())

    window.show()
    return app.exec()
}
```

## 信号和槽

Qt的核心机制是信号和槽，CJQT6 通过 `setOnXxx` + `CFunc` 回调实现。

> **重要**：CFunc 回调不能捕获局部变量。回调中要访问的控件和状态（如 label、counter）必须存入全局变量。

```cangjie
import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

// 居中对齐常量（Qt::AlignCenter = 0x0084）
let AlignCenter: Int32 = 0x0084

// 全局状态（CFunc 回调不能捕获局部变量）
var gLabel: ?QLabel = None
var gCounter: Int32 = 0

// 增加回调
let incCallback: VoidCallback = { =>
    if (let Some(l) <- gLabel) {
        gCounter = gCounter + 1
        l.setText(gCounter.toString())
    }
}

// 重置回调
let resetCallback: VoidCallback = { =>
    if (let Some(l) <- gLabel) {
        gCounter = 0
        l.setText("0")
    }
}

main(): Int32 {
    let app = QApplication()

    let window = QWidget()
    window.setTitle("信号槽示例")

    let layout = QVBoxLayout()

    // 数字显示
    let label = QLabel()
    label.setText("0")
    label.setAlignment(AlignCenter)
    gLabel = label  // 存入全局变量
    layout.addWidget(label.getPtr())

    // 增加按钮
    let incButton = QPushButton()
    incButton.setText("增加")
    incButton.setOnClick(incCallback)
    layout.addWidget(incButton.getPtr())

    // 重置按钮
    let resetButton = QPushButton()
    resetButton.setText("重置")
    resetButton.setOnClick(resetCallback)
    layout.addWidget(resetButton.getPtr())

    window.setLayout(layout.getPtr())
    window.resize(300, 200)
    window.show()
    return app.exec()
}
```

## 下一步

- 查看 [完整示例](../../examples/) 目录
- 阅读 [API文档](../api/README.md)
- 学习 [更多Qt控件](https://doc.qt.io/qt-6/qtwidgets-index.html)

## 常见问题

**Q: 窗口一闪而过？**

A: 确保最后 `return app.exec()`，这会启动事件循环并阻塞直到窗口关闭。

**Q: 找不到cjqt6模块？**

A: 确认 `cjpm.toml` 中 `cjqt6 = { path = "../../" }` 路径正确，且 CJQT6 根包已 `cjpm build` 成功（含桥接库）。

**Q: 运行时报错找不到Qt6 / 桥接库？**

A: 参考 [构建指南](../guides/build-guide.md) 配置 Qt6 路径并构建 FFI 桥接库，部署到 `releases/<platform>/`。Windows 需设置 `QTDIR` 与 `CJQT6_ROOT` 环境变量。
