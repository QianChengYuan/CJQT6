# CJQT6 快速入门教程

欢迎来到CJQT6快速入门教程! 本教程将带你在15分钟内创建第一个仓颉Qt6 GUI应用。

## 目标

通过本教程,你将学会:

- 创建基本的Qt窗口
- 添加常用控件(标签、按钮、输入框)
- 使用布局管理器
- 处理按钮点击事件
- 运行和调试应用

## 前置要求

- 已安装仓颉编译器 (>= 0.50.0)
- 已安装Qt6 (>= 6.2)
- 已构建CJQT6库

### 环境检查

运行以下命令检查环境:

```bash
# 检查仓颉编译器
cjpm --version

# 检查Qt6
qmake6 --version  # Linux/macOS
# 或检查环境变量QTDIR
```

## 第一步: 环境准备 (2分钟)

### 1.1 确认CJQT6已构建

```bash
cd CJQT6

# 检查FFI桥接库是否存在
ls native/build/lib/libCJQT6_bridge.so  # Linux
ls native/build/lib/CJQT6_bridge.dll    # Windows

# 如果不存在,先构建
cd native/build
cmake ..
make
cd ../..
```

### 1.2 创建示例项目

```bash
# 在examples目录下创建新示例
mkdir examples/my_first_app
cd examples/my_first_app
```

## 第二步: 第一个窗口 (3分钟)

创建文件 `main.cj`:

```cangjie
import CJQT6.core.*
import CJQT6.widgets.*

main() {
    // 1. 创建Qt应用对象(必需)
    let app = QApplication()
    
    // 2. 创建主窗口
    let window = QWidget()
    window.setWindowTitle("我的第一个CJQT6应用")
    window.resize(400, 300)
    
    // 3. 显示窗口
    window.show()
    
    // 4. 启动事件循环
    app.exec()
}
```

### 运行第一个窗口

```bash
cjpm run
```

如果一切正常,你将看到一个400x300的空白窗口!

## 第三步: 添加控件 (5分钟)

让我们在窗口中添加一些控件:

```cangjie
import CJQT6.core.*
import CJQT6.widgets.*

main() {
    let app = QApplication()
    
    // 创建主窗口
    let window = QWidget()
    window.setWindowTitle("我的第一个CJQT6应用")
    window.resize(400, 300)
    
    // 创建控件
    // 1. 标签 - 显示文本
    let label = QLabel("欢迎来到CJQT6!", window)
    label.setAlignment(QtAlignment.AlignCenter)
    
    // 2. 输入框 - 用户输入
    let input = QLineEdit(window)
    input.setPlaceholderText("请输入你的名字")
    
    // 3. 按钮 - 用户点击
    let button = QPushButton("确定", window)
    
    // 设置控件位置(绝对定位)
    label.move(100, 50)
    input.move(100, 120)
    button.move(150, 180)
    
    // 设置控件大小
    label.resize(200, 30)
    input.resize(200, 30)
    button.resize(100, 30)
    
    window.show()
    app.exec()
}
```

运行后,你将看到包含标签、输入框和按钮的窗口。

## 第四步: 使用布局管理器 (3分钟)

绝对定位不够灵活,让我们使用布局管理器:

```cangjie
import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.gui.*

main() {
    let app = QApplication()
    
    let window = QWidget()
    window.setWindowTitle("我的第一个CJQT6应用")
    window.resize(400, 300)
    
    // 创建垂直布局
    let layout = QVBoxLayout(window)
    
    // 创建控件
    let label = QLabel("欢迎来到CJQT6!")
    label.setAlignment(QtAlignment.AlignCenter)
    
    let input = QLineEdit()
    input.setPlaceholderText("请输入你的名字")
    
    let button = QPushButton("确定")
    
    // 将控件添加到布局
    layout.addWidget(label)
    layout.addWidget(input)
    layout.addWidget(button)
    
    // 添加弹簧(空白区域)
    layout.addStretch()
    
    window.show()
    app.exec()
}
```

现在控件会自动排列,窗口大小改变时也会自动调整!

## 第五步: 处理事件 (2分钟)

让我们添加按钮点击事件处理:

```cangjie
import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.gui.*

main() {
    let app = QApplication()
    
    let window = QWidget()
    window.setWindowTitle("我的第一个CJQT6应用")
    window.resize(400, 300)
    
    let layout = QVBoxLayout(window)
    
    let label = QLabel("欢迎来到CJQT6!")
    label.setAlignment(QtAlignment.AlignCenter)
    
    let input = QLineEdit()
    input.setPlaceholderText("请输入你的名字")
    
    let button = QPushButton("确定")
    
    // 连接按钮点击信号
    button.clicked.connect(func() {
        let name = input.text()
        if (name.isEmpty()) {
            label.setText("请先输入你的名字!")
        } else {
            label.setText("你好, " + name + "!")
        }
    })
    
    layout.addWidget(label)
    layout.addWidget(input)
    layout.addWidget(button)
    layout.addStretch()
    
    window.show()
    app.exec()
}
```

现在点击按钮后,标签会显示问候信息!

## 完整示例代码

```cangjie
import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.gui.*

main() {
    // 创建应用
    let app = QApplication()
    
    // 创建主窗口
    let window = QWidget()
    window.setWindowTitle("我的第一个CJQT6应用")
    window.resize(400, 300)
    
    // 创建布局
    let layout = QVBoxLayout(window)
    
    // 创建控件
    let titleLabel = QLabel("欢迎使用CJQT6")
    titleLabel.setAlignment(QtAlignment.AlignCenter)
    
    let nameLabel = QLabel("请输入你的名字:")
    
    let nameInput = QLineEdit()
    nameInput.setPlaceholderText("在这里输入...")
    
    let greetButton = QPushButton("打招呼")
    
    let resultLabel = QLabel("")
    resultLabel.setAlignment(QtAlignment.AlignCenter)
    
    // 连接事件
    greetButton.clicked.connect(func() {
        let name = nameInput.text()
        if (name.isEmpty()) {
            resultLabel.setText("请先输入名字!")
        } else {
            resultLabel.setText("你好, " + name + "! 欢迎学习CJQT6!")
        }
    })
    
    // 添加控件到布局
    layout.addWidget(titleLabel)
    layout.addWidget(nameLabel)
    layout.addWidget(nameInput)
    layout.addWidget(greetButton)
    layout.addWidget(resultLabel)
    layout.addStretch()
    
    // 显示窗口
    window.show()
    
    // 启动事件循环
    app.exec()
}
```

## 下一步

恭喜! 你已经完成了CJQT6快速入门教程。接下来你可以:

### 学习更多控件

- [基础控件教程](./02-basic-widgets.md) - 学习所有常用控件
- [布局管理教程](./03-layout.md) - 深入学习布局系统
- [事件处理教程](./04-events.md) - 掌握事件驱动编程

### 查看示例程序

```bash
# 运行其他示例
cd examples

# 控件演示
cjpm run --example widgets_demo

# 计算器
cjpm run --example calculator

# 记事本
cjpm run --example notepad
```

### 阅读更多文档

- [API参考文档](../api/) - 完整的API说明
- [资源管理指南](../resource-management.md) - 内存管理最佳实践
- [架构设计](../architecture.md) - 了解CJQT6内部实现

## 常见问题

### Q: 窗口不显示?

检查:
1. 是否调用了 `window.show()`
2. 是否调用了 `app.exec()`
3. FFI桥接库是否正确构建

### Q: 中文显示乱码?

确保源文件使用UTF-8编码保存。

### Q: 运行时崩溃?

检查:
1. Qt6是否正确安装
2. 环境变量是否设置正确
3. 参考资源管理指南,确保正确管理对象生命周期

### Q: 如何调试?

```bash
# 使用仓颉调试器
cjdb ./your_program
```

## 总结

在本教程中,你学会了:

✅ 创建Qt应用和窗口
✅ 添加标签、按钮、输入框
✅ 使用布局管理器
✅ 连接和处理事件
✅ 运行完整的应用

继续学习,构建更复杂的GUI应用!

---

*下一步: [基础控件教程](./02-basic-widgets.md)*
