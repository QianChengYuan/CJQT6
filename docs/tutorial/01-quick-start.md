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

- 已安装仓颉编译器 (>= 1.1.0)
- 已安装Qt6 (>= 6.2)
- 已构建CJQT6库（含 FFI 桥接库，见 [构建指南](../guides/build-guide.md)）

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
ls releases/linux-x64/libcjqt6_bridge.so    # Linux
dir releases\windows-x64\cjqt6_bridge.dll   # Windows

# 如果不存在,先构建桥接库（见构建指南）
# Windows: powershell -File scripts\update-bridge.ps1
# Linux:   bash scripts/build-linux-x64.sh
# 然后: cjpm build
```

### 1.2 创建示例项目

```bash
# 在examples目录下创建新示例
mkdir examples/my_first_app
cd examples/my_first_app
# 并配置 cjpm.toml（参考 examples/all_controls_demo/cjpm.toml）
```

## 第二步: 第一个窗口 (3分钟)

创建文件 `main.cj`:

```cangjie
import cjqt6.core.*
import cjqt6.widgets.*

main(): Int32 {
    // 1. 创建Qt应用对象(必需，且全局唯一)
    let app = QApplication()

    // 2. 创建主窗口
    let window = QWidget()
    window.setTitle("我的第一个CJQT6应用")  // QWidget 用 setTitle
    window.resize(400, 300)

    // 3. 显示窗口
    window.show()

    // 4. 启动事件循环
    return app.exec()
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
import cjqt6.core.*
import cjqt6.widgets.*

// 居中对齐常量（Qt::AlignCenter = 0x0084）
let AlignCenter: Int32 = 0x0084

main(): Int32 {
    let app = QApplication()

    // 创建主窗口
    let window = QWidget()
    window.setTitle("我的第一个CJQT6应用")
    window.resize(400, 300)

    // 创建控件（构造均为无参，文本用 setText 单独设置）
    // 1. 标签 - 显示文本
    let label = QLabel()
    label.setText("欢迎来到CJQT6!")
    label.setAlignment(AlignCenter)

    // 2. 输入框 - 用户输入
    let input = QLineEdit()
    input.setPlaceholderText("请输入你的名字")

    // 3. 按钮 - 用户点击
    let button = QPushButton()
    button.setText("确定")

    // 设置控件位置(绝对定位)
    label.move(100, 50)
    input.move(100, 120)
    button.move(150, 180)

    // 设置控件大小
    label.resize(200, 30)
    input.resize(200, 30)
    button.resize(100, 30)

    window.show()
    return app.exec()
}
```

运行后,你将看到包含标签、输入框和按钮的窗口。

## 第四步: 使用布局管理器 (3分钟)

绝对定位不够灵活,让我们使用布局管理器:

```cangjie
import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

let AlignCenter: Int32 = 0x0084

main(): Int32 {
    let app = QApplication()

    let window = QWidget()
    window.setTitle("我的第一个CJQT6应用")
    window.resize(400, 300)

    // 创建垂直布局（无参构造）
    let layout = QVBoxLayout()

    // 创建控件
    let label = QLabel()
    label.setText("欢迎来到CJQT6!")
    label.setAlignment(AlignCenter)

    let input = QLineEdit()
    input.setPlaceholderText("请输入你的名字")

    let button = QPushButton()
    button.setText("确定")

    // 将控件添加到布局（addWidget 收 Int64 指针，须 .getPtr()）
    layout.addWidget(label.getPtr())
    layout.addWidget(input.getPtr())
    layout.addWidget(button.getPtr())

    // 添加弹簧(空白区域)
    layout.addStretch()

    // 把布局设置到窗口
    window.setLayout(layout.getPtr())

    window.show()
    return app.exec()
}
```

现在控件会自动排列,窗口大小改变时也会自动调整!

## 第五步: 处理事件 (2分钟)

让我们添加按钮点击事件处理。

> **重要**：CJQT6 用 `setOnClick` + `CFunc` 回调实现信号槽，且 **CFunc 回调不能捕获局部变量**。需要在回调中访问的控件（如 input/label）必须存入全局变量。

```cangjie
import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

let AlignCenter: Int32 = 0x0084

// 全局变量：回调中需要访问的控件（CFunc 不能捕获局部变量）
var gLabel: ?QLabel = None
var gInput: ?QLineEdit = None

// 回调函数（顶层定义，通过全局变量访问控件）
let clickCallback: VoidCallback = { =>
    if (let Some(l) <- gLabel) {
        if (let Some(i) <- gInput) {
            let name = i.text()
            if (name.isEmpty()) {
                l.setText("请先输入你的名字!")
            } else {
                l.setText("你好, " + name + "!")
            }
        }
    }
}

main(): Int32 {
    let app = QApplication()

    let window = QWidget()
    window.setTitle("我的第一个CJQT6应用")
    window.resize(400, 300)

    let layout = QVBoxLayout()

    let label = QLabel()
    label.setText("欢迎来到CJQT6!")
    label.setAlignment(AlignCenter)
    gLabel = label  // 存入全局变量

    let input = QLineEdit()
    input.setPlaceholderText("请输入你的名字")
    gInput = input  // 存入全局变量

    let button = QPushButton()
    button.setText("确定")

    // 连接按钮点击信号（setOnClick + CFunc 回调）
    button.setOnClick(clickCallback)

    layout.addWidget(label.getPtr())
    layout.addWidget(input.getPtr())
    layout.addWidget(button.getPtr())
    layout.addStretch()

    window.setLayout(layout.getPtr())
    window.show()
    return app.exec()
}
```

现在点击按钮后,标签会显示问候信息!

## 完整示例代码

```cangjie
import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

let AlignCenter: Int32 = 0x0084

// 全局变量（CFunc 回调不能捕获局部变量）
var gResultLabel: ?QLabel = None
var gNameInput: ?QLineEdit = None

let greetCallback: VoidCallback = { =>
    if (let Some(rl) <- gResultLabel) {
        if (let Some(ni) <- gNameInput) {
            let name = ni.text()
            if (name.isEmpty()) {
                rl.setText("请先输入名字!")
            } else {
                rl.setText("你好, " + name + "! 欢迎学习CJQT6!")
            }
        }
    }
}

main(): Int32 {
    // 创建应用
    let app = QApplication()

    // 创建主窗口
    let window = QWidget()
    window.setTitle("我的第一个CJQT6应用")
    window.resize(400, 300)

    // 创建布局
    let layout = QVBoxLayout()

    // 创建控件
    let titleLabel = QLabel()
    titleLabel.setText("欢迎使用CJQT6")
    titleLabel.setAlignment(AlignCenter)

    let nameLabel = QLabel()
    nameLabel.setText("请输入你的名字:")

    let nameInput = QLineEdit()
    nameInput.setPlaceholderText("在这里输入...")
    gNameInput = nameInput

    let greetButton = QPushButton()
    greetButton.setText("打招呼")

    let resultLabel = QLabel()
    resultLabel.setText("")
    resultLabel.setAlignment(AlignCenter)
    gResultLabel = resultLabel

    // 连接事件
    greetButton.setOnClick(greetCallback)

    // 添加控件到布局
    layout.addWidget(titleLabel.getPtr())
    layout.addWidget(nameLabel.getPtr())
    layout.addWidget(nameInput.getPtr())
    layout.addWidget(greetButton.getPtr())
    layout.addWidget(resultLabel.getPtr())
    layout.addStretch()

    // 把布局设置到窗口
    window.setLayout(layout.getPtr())

    // 显示窗口
    window.show()

    // 启动事件循环
    return app.exec()
}
```

## 下一步

恭喜! 你已经完成了CJQT6快速入门教程。接下来你可以:

### 学习更多控件

- [基础控件 API](../api/02_widgets_basic.md) - QLabel、QPushButton、QLineEdit 等
- [布局管理 API](../api/04_containers_layout.md) - QVBoxLayout、QHBoxLayout、QGridLayout
- [信号与槽](../api/12_signal_slot.md) - 回调机制与信号连接

### 查看示例程序

```bash
# 进入示例目录运行（cjpm 不支持 --example，须 cd 到示例工程）
cd examples/all_controls_demo
cjpm run          # 控件演示

cd ../calculator
cjpm run          # 计算器

cd ../notepad
cjpm run          # 记事本
```

### 阅读更多文档

- [API 参考文档](../api/) - 完整的API说明
- [资源管理指南](../resource/resource-management.md) - 内存管理最佳实践
- [架构设计](../guides/architecture.md) - 了解CJQT6内部实现

## 常见问题

### Q: 窗口不显示?

检查:
1. 是否调用了 `window.show()`
2. 是否调用了 `app.exec()`（并 return 其结果）
3. FFI桥接库是否正确构建并部署到 `releases/`

### Q: 中文显示乱码?

确保源文件使用UTF-8编码保存。

### Q: 运行时崩溃?

检查:
1. Qt6是否正确安装
2. 环境变量是否设置正确（Windows 需设置 CJQT6_ROOT、QTDIR）
3. 参考资源管理指南,确保正确管理对象生命周期（终结器已禁用，须显式 close/delete）

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

*下一步: [基础控件 API](../api/02_widgets_basic.md)*
