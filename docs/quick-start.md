# CJQT6 快速开始

本教程将帮助您在5分钟内创建第一个CJQT6 GUI应用程序。

## 创建第一个窗口

### 1. 新建项目

```bash
cjpm init hello-window
cd hello-window
```

### 2. 配置依赖

编辑 `cjpm.toml`:
```toml
[package]
  name = "hello-window"
  version = "1.0.0"

[dependencies]
  CJQT6 = "1.0.0"
```

### 3. 编写代码

创建 `main.cj` 文件：

```cangjie
import CJQT6.core.*
import CJQT6.widgets.*

main() {
    // 创建Qt应用
    let app = QApplication()
    
    // 创建主窗口
    let window = QWidget()
    window.setWindowTitle("Hello CJQT6")
    window.resize(400, 300)
    
    // 显示窗口
    window.show()
    
    // 运行应用
    app.exec()
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
import CJQT6.core.*
import CJQT6.widgets.*

main() {
    let app = QApplication()
    
    let window = QWidget()
    window.setWindowTitle("按钮示例")
    window.resize(400, 300)
    
    // 创建按钮
    let button = QPushButton("点击我", window)
    button.resize(120, 40)
    button.move(140, 130)
    
    // 连接点击信号
    button.clicked({ => 
        println("按钮被点击了！")
    })
    
    window.show()
    app.exec()
}
```

## 使用布局管理器

自动布局让控件排列更简单：

```cangjie
import CJQT6.core.*
import CJQT6.widgets.*

main() {
    let app = QApplication()
    
    let window = QWidget()
    window.setWindowTitle("布局示例")
    window.resize(400, 300)
    
    // 创建垂直布局
    let layout = QVBoxLayout(window)
    
    // 添加控件
    let label = QLabel("欢迎使用CJQT6")
    layout.addWidget(label)
    
    let button1 = QPushButton("按钮 1")
    layout.addWidget(button1)
    
    let button2 = QPushButton("按钮 2")
    layout.addWidget(button2)
    
    window.show()
    app.exec()
}
```

## 信号和槽

Qt的核心机制是信号和槽，CJQT6完美支持：

```cangjie
import CJQT6.core.*
import CJQT6.widgets.*

main() {
    let app = QApplication()
    
    let window = QWidget()
    window.setWindowTitle("信号槽示例")
    
    let layout = QVBoxLayout(window)
    
    // 数字显示
    let label = QLabel("0")
    label.setAlignment(Qt.AlignmentCenter)
    layout.addWidget(label)
    
    // 增加按钮
    let incButton = QPushButton("增加")
    var counter = 0
    
    incButton.clicked({ => 
        counter = counter + 1
        label.setText(counter.toString())
    })
    layout.addWidget(incButton)
    
    // 重置按钮
    let resetButton = QPushButton("重置")
    resetButton.clicked({ =>
        counter = 0
        label.setText("0")
    })
    layout.addWidget(resetButton)
    
    window.resize(300, 200)
    window.show()
    app.exec()
}
```

## 下一步

- 查看 [完整示例](../examples/) 目录
- 阅读 [API文档](https://your-repo.github.io/CJQT6/api/)
- 学习 [更多Qt控件](https://doc.qt.io/qt-6/qtwidgets-index.html)

## 常见问题

**Q: 窗口一闪而过？**

A: 确保最后调用了 `app.exec()`，这会启动事件循环。

**Q: 找不到CJQT6模块？**

A: 运行 `cjpm install` 安装依赖。

**Q: 运行时报错找不到Qt6？**

A: 参考 [安装指南](./installation.md) 配置Qt6路径。
