# CJQT6 控件API使用文档

## 目录

1. [应用程序核心](#应用程序核心)
2. [基础部件](#基础部件)
3. [输入控件](#输入控件)
4. [选择控件](#选择控件)
5. [数值控件](#数值控件)
6. [容器控件](#容器控件)
7. [布局管理](#布局管理)
8. [表格控件](#表格控件)
9. [对话框](#对话框)
10. [信号与槽](#信号与槽)

---

## 应用程序核心

### QApplication

应用程序主类，每个Qt程序必须有且仅有一个实例。

```cangjie
import CJQT6.core.*

main(): Int32 {
    let app = QApplication()
    
    // 创建窗口和控件...
    
    let result = app.exec()  // 进入事件循环
    app.delete()             // 清理资源
    return result
}
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建应用程序实例 |
| `exec(): Int32` | 进入事件循环，返回退出码 |
| `quit()` | 退出应用程序 |
| `delete()` | 释放资源 |

### QWidget

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
| `setTitle(title: String)` | 设置窗口标题 |
| `resize(width: Int32, height: Int32)` | 设置窗口大小 |
| `setGeometry(x, y, width, height)` | 设置位置和大小 |
| `setLayout(layoutPtr: Int64)` | 设置布局 |
| `show()` | 显示窗口 |
| `hide()` | 隐藏窗口 |
| `getPtr(): Int64` | 获取指针（用于布局） |
| `delete()` | 释放资源 |

### QTimer

定时器，用于周期性执行任务。

```cangjie
let timer = QTimer()
timer.setInterval(1000)  // 1秒

let timerCallback: CFunc<(Int64) -> Unit> = { _: Int64 =>
    println("定时器触发！")
}
timer.setTimeout(timerCallback)
timer.start()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setInterval(ms: Int32)` | 设置间隔（毫秒） |
| `start()` | 启动定时器 |
| `stop()` | 停止定时器 |
| `setTimeout(callback: CFunc)` | 设置超时回调 |
| `delete()` | 释放资源 |

---

## 基础部件

### QLabel - 标签

```cangjie
let label = QLabel()
label.setText("文本内容")
label.setAlignment(AlignCenter)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` | 设置文本 |
| `setAlignment(alignment: Int32)` | 设置对齐方式 |

**对齐常量** (CJQT6.gui):
```cangjie
AlignLeft      // 左对齐
AlignRight     // 右对齐
AlignHCenter   // 水平居中
AlignTop       // 顶部对齐
AlignBottom    // 底部对齐
AlignVCenter   // 垂直居中
AlignCenter    // 居中
```

### QPushButton - 按钮

```cangjie
let btn = QPushButton()
btn.setText("点击我")

// 设置点击回调
let callback: CFunc<(Int64) -> Unit> = { _: Int64 =>
    println("按钮被点击！")
}
btn.setOnClick(callback)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` | 设置按钮文本 |
| `setOnClick(callback: CFunc)` | 设置点击回调 |

---

## 输入控件

### QLineEdit - 单行文本输入

```cangjie
let edit = QLineEdit()
edit.setPlaceholder("请输入...")
edit.setMaxLength(100)
edit.setEchoMode(Password)  // 密码模式
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` | 设置文本 |
| `text(): String` | 获取文本 |
| `setPlaceholder(text: String)` | 设置占位文本 |
| `setMaxLength(len: Int32)` | 设置最大长度 |
| `setReadOnly(readonly: Bool)` | 设置只读 |
| `setEchoMode(mode: Int32)` | 设置回显模式 |
| `clear()` | 清空 |
| `setOnTextChanged(callback: CFunc)` | 文本变化回调 |

**回显模式常量**:
```cangjie
Normal      // 正常
NoEcho      // 不显示
Password    // 密码
PasswordEchoOnEdit  // 编辑时显示
```

### QTextEdit - 多行文本编辑

```cangjie
let textEdit = QTextEdit()
textEdit.setText("多行文本\n第二行")
textEdit.setReadOnly(true)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` | 设置文本 |
| `text(): String` | 获取文本 |
| `setReadOnly(readonly: Bool)` | 设置只读 |
| `clear()` | 清空 |

---

## 选择控件

### QCheckBox - 复选框

```cangjie
let checkbox = QCheckBox()
checkbox.setText("选项A")
checkbox.setChecked(true)

if (checkbox.isChecked()) {
    println("已选中")
}
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` | 设置文本 |
| `setChecked(checked: Bool)` | 设置选中状态 |
| `isChecked(): Bool` | 获取选中状态 |

### QRadioButton - 单选按钮

```cangjie
let radio1 = QRadioButton()
radio1.setText("选项1")
radio1.setChecked(true)

let radio2 = QRadioButton()
radio2.setText("选项2")
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` | 设置文本 |
| `setChecked(checked: Bool)` | 设置选中状态 |
| `isChecked(): Bool` | 获取选中状态 |

### QComboBox - 下拉框

```cangjie
let combo = QComboBox()
combo.addItem("选项1")
combo.addItem("选项2")
combo.addItem("选项3")

let currentText = combo.currentText()
let currentIndex = combo.currentIndex()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `addItem(text: String)` | 添加项 |
| `clear()` | 清空所有项 |
| `currentText(): String` | 获取当前文本 |
| `currentIndex(): Int32` | 获取当前索引 |
| `setCurrentIndex(index: Int32)` | 设置当前索引 |

---

## 数值控件

### QSpinBox - 整数旋转框

```cangjie
let spinBox = QSpinBox()
spinBox.setRange(0, 100)
spinBox.setValue(50)
spinBox.setSingleStep(5)

let value = spinBox.value()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setValue(value: Int32)` | 设置值 |
| `value(): Int32` | 获取值 |
| `setRange(min: Int32, max: Int32)` | 设置范围 |
| `setSingleStep(step: Int32)` | 设置步长 |
| `setOnValueChanged(callback: CFunc)` | 值变化回调 |

### QSlider - 滑动条

```cangjie
let slider = QSlider()
slider.setRange(0, 100)
slider.setValue(50)
slider.setOrientation(Horizontal)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setValue(value: Int32)` | 设置值 |
| `value(): Int32` | 获取值 |
| `setRange(min: Int32, max: Int32)` | 设置范围 |
| `setOrientation(orientation: Int32)` | 设置方向 |
| `setOnValueChanged(callback: CFunc)` | 值变化回调 |

**方向常量**:
```cangjie
Horizontal  // 水平
Vertical    // 垂直
```

### QProgressBar - 进度条

```cangjie
let progress = QProgressBar()
progress.setRange(0, 100)
progress.setValue(75)
progress.setTextVisible(true)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setValue(value: Int32)` | 设置值 |
| `value(): Int32` | 获取值 |
| `setRange(min: Int32, max: Int32)` | 设置范围 |
| `setTextVisible(visible: Bool)` | 是否显示文本 |

---

## 容器控件

### QGroupBox - 分组框

```cangjie
let groupBox = QGroupBox()
groupBox.setTitle("分组标题")

let innerLayout = QVBoxLayout()
// 添加控件到innerLayout...
groupBox.setLayout(innerLayout.getPtr())
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setTitle(title: String)` | 设置标题 |
| `setCheckable(checkable: Bool)` | 设置可勾选 |
| `setChecked(checked: Bool)` | 设置勾选状态 |
| `setLayout(layoutPtr: Int64)` | 设置内部布局 |

### QTabWidget - 标签页

```cangjie
let tabWidget = QTabWidget()

let page1 = QWidget()
// 配置page1...
tabWidget.addTab(page1.getPtr(), "标签1")

let page2 = QWidget()
// 配置page2...
tabWidget.addTab(page2.getPtr(), "标签2")
```

**方法**:
| 方法 | 说明 |
|------|------|
| `addTab(widgetPtr: Int64, title: String)` | 添加标签页 |
| `removeTab(index: Int32)` | 移除标签页 |
| `currentIndex(): Int32` | 获取当前索引 |
| `setCurrentIndex(index: Int32)` | 设置当前标签页 |
| `count(): Int32` | 获取标签页数量 |

### QScrollArea - 滚动区域

```cangjie
let scrollArea = QScrollArea()
scrollArea.setWidget(contentWidget.getPtr())
scrollArea.setWidgetResizable(true)
```

### QFrame - 边框容器

```cangjie
let frame = QFrame()
frame.setFrameShape(StyledPanel)
frame.setFrameShadow(Raised)
frame.setLineWidth(2)
```

**边框形状常量**:
```cangjie
NoFrame      // 无边框
Box          // 矩形框
Panel        // 面板
StyledPanel  // 样式面板
HLine        // 水平线
VLine        // 垂直线
```

**边框阴影常量**:
```cangjie
Plain   // 平面
Raised  // 凸起
Sunken  // 凹陷
```

---

## 布局管理

### QVBoxLayout - 垂直布局

```cangjie
let layout = QVBoxLayout()
layout.addWidget(label.getPtr())
layout.addWidget(button.getPtr())
layout.setSpacing(10)
layout.setMargin(20)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `addWidget(ptr: Int64)` | 添加控件 |
| `addLayout(ptr: Int64)` | 添加子布局 |
| `addStretch()` | 添加弹性空间 |
| `setSpacing(spacing: Int32)` | 设置间距 |
| `setMargin(margin: Int32)` | 设置边距 |
| `getPtr(): Int64` | 获取指针 |

### QHBoxLayout - 水平布局

```cangjie
let hLayout = QHBoxLayout()
hLayout.addWidget(btn1.getPtr())
hLayout.addWidget(btn2.getPtr())
hLayout.addStretch()
```

### QGridLayout - 网格布局

```cangjie
let grid = QGridLayout()
grid.addWidget(label1.getPtr(), 0, 0)  // 第0行第0列
grid.addWidget(edit1.getPtr(), 0, 1)   // 第0行第1列
grid.addWidget(label2.getPtr(), 1, 0)  // 第1行第0列
grid.addWidget(edit2.getPtr(), 1, 1)   // 第1行第1列

// 跨行跨列
grid.addWidgetWidgetSpan(bigWidget.getPtr(), 2, 0, 2, 2)  // 从第2行第0列开始，占2行2列
```

**方法**:
| 方法 | 说明 |
|------|------|
| `addWidget(ptr, row, col)` | 添加控件到指定位置 |
| `addWidgetSpan(ptr, row, col, rowSpan, colSpan)` | 跨行跨列添加 |
| `setSpacing(spacing: Int32)` | 设置间距 |
| `setMargin(margin: Int32)` | 设置边距 |

---

## 表格控件

### QTableWidget

```cangjie
import CJQT6.views.*

// 创建表格 (5行3列)
let table = QTableWidget(5, 3)

// 设置表头
table.setHorizontalHeaderLabel(0, "姓名")
table.setHorizontalHeaderLabel(1, "年龄")
table.setHorizontalHeaderLabel(2, "城市")

// 填充数据
table.setItem(0, 0, "张三")
table.setItem(0, 1, "25")
table.setItem(0, 2, "北京")

// 自动填充窗口宽度
table.setAutoFillWidth()

// 设置选择行为
table.setSelectionBehavior(SelectRows)
table.setSelectionMode(SingleSelection)

// 显示交替行颜色
table.setAlternatingRowColors(true)
```

**常用方法**:
| 方法 | 说明 |
|------|------|
| `setRowCount(rows: Int32)` | 设置行数 |
| `setColumnCount(cols: Int32)` | 设置列数 |
| `setHorizontalHeaderLabel(col, label)` | 设置列表头 |
| `setItem(row, col, text)` | 设置单元格内容 |
| `itemText(row, col): String` | 获取单元格内容 |
| `insertRow(row)` | 插入行 |
| `removeRow(row)` | 删除行 |
| `currentRow(): Int32` | 获取当前行 |
| `currentColumn(): Int32` | 获取当前列 |
| `clear()` | 清空表格 |
| `clearContents()` | 清空内容（保留表头） |

**列宽调整模式**:
```cangjie
table.setAutoFillWidth()                    // 所有列自动拉伸填充
table.setHorizontalHeaderStretchLastSection(true)  // 最后一列拉伸
table.setColumnResizeMode(0, Interactive)   // 指定列用户可调整
table.setColumnResizeMode(1, ResizeToContents)     // 指定列根据内容
```

**调整模式常量**:
```cangjie
Interactive        // 用户可调整
Fixed              // 固定大小
Stretch            // 自动拉伸
ResizeToContents   // 根据内容调整
```

**选择行为常量**:
```cangjie
SelectItems    // 选择项
SelectRows     // 选择行
SelectColumns  // 选择列
```

**选择模式常量**:
```cangjie
NoSelection          // 不可选择
SingleSelection      // 单选
MultiSelection       // 多选
ExtendedSelection    // 扩展选择（Ctrl/Shift）
ContiguousSelection  // 连续选择
```

---

## 对话框

### QMessageBox - 消息对话框

```cangjie
import CJQT6.dialogs.*

// 信息提示
QMessageBox.information(0, "提示", "操作成功！")

// 警告
QMessageBox.warning(0, "警告", "请注意！")

// 错误
QMessageBox.critical(0, "错误", "发生错误！")

// 询问
let result = QMessageBox.question(0, "确认", "确定要删除吗？")
if (result) {
    // 用户点击了"是"
}
```

### QFileDialog - 文件对话框

```cangjie
// 打开文件
let filePath = QFileDialog.getOpenFileName(0, "选择文件", "所有文件 (*.*)")
if (filePath.isNotEmpty()) {
    println("选择了: ${filePath}")
}

// 保存文件
let savePath = QFileDialog.getSaveFileName(0, "保存文件", "*.txt")

// 选择目录
let dirPath = QFileDialog.getExistingDirectory(0, "选择目录")
```

---

## 信号与槽

CJQT6使用CFunc回调实现信号槽机制。

### 基本用法

```cangjie
// 定义回调函数
let clickCallback: CFunc<(Int64) -> Unit> = { _: Int64 =>
    println("按钮被点击！")
}

// 连接信号
btn.setOnClick(clickCallback)

// 值变化回调
let valueCallback: CFunc<(Int64) -> Unit> = { _: Int64 =>
    println("值改变了！")
}
spinBox.setOnValueChanged(valueCallback)
```

### 支持信号的控件

| 控件 | 方法 | 信号 |
|------|------|------|
| QPushButton | `setOnClick(callback)` | 点击 |
| QLineEdit | `setOnTextChanged(callback)` | 文本变化 |
| QSpinBox | `setOnValueChanged(callback)` | 值变化 |
| QSlider | `setOnValueChanged(callback)` | 值变化 |
| QTimer | `setTimeout(callback)` | 超时 |

### 回调中访问控件

由于CFunc不能捕获外部变量，如需在回调中访问其他控件，可使用全局变量或重新获取：

```cangjie
// 方式1：使用全局变量
var globalLabel: ?QLabel = None

let callback: CFunc<(Int64) -> Unit> = { _: Int64 =>
    if (let Some(label) <- globalLabel) {
        label.setText("已点击")
    }
}

// 方式2：在回调中查询状态
let spinCallback: CFunc<(Int64) -> Unit> = { _: Int64 =>
    let value = spinBox.value()  // 直接读取控件值
    println("当前值: ${value}")
}
```

---

## 完整示例

```cangjie
package demo

import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.gui.*
import CJQT6.views.*
import CJQT6.dialogs.*

var label: ?QLabel = None
let clickCallback: CFunc<(Int64) -> Unit> = { _: Int64 =>
    if (let Some(l) <- label) {
        l.setText("按钮被点击了！")
    }
}

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("CJQT6 完整示例")
    window.resize(600, 400)
    
    // 主布局
    let mainLayout = QVBoxLayout()
    
    // 标签
    label = QLabel()
    label.setText("欢迎使用CJQT6")
    mainLayout.addWidget(label.getPtr())
    
    // 按钮
    let btn = QPushButton()
    btn.setText("点击我")
    btn.setOnClick(clickCallback)
    mainLayout.addWidget(btn.getPtr())
    
    // 表格
    let table = QTableWidget(3, 2)
    table.setHorizontalHeaderLabel(0, "项目")
    table.setHorizontalHeaderLabel(1, "值")
    table.setItem(0, 0, "名称")
    table.setItem(0, 1, "CJQT6")
    table.setItem(1, 0, "版本")
    table.setItem(1, 1, "1.0.0")
    table.setAutoFillWidth()
    mainLayout.addWidget(table.getPtr())
    
    window.setLayout(mainLayout.getPtr())
    window.show()
    
    let result = app.exec()
    
    table.delete()
    btn.delete()
    label.delete()
    window.delete()
    app.delete()
    
    return result
}
```

---

## 常见问题

### Q: 如何让控件自动填充布局？

A: 使用布局管理器，并添加弹性空间：
```cangjie
let layout = QVBoxLayout()
layout.addWidget(topWidget.getPtr())
layout.addStretch()  // 添加弹性空间
layout.addWidget(bottomWidget.getPtr())
```

### Q: 如何实现控件之间的联动？

A: 使用信号槽机制：
```cangjie
let sliderCallback: CFunc<(Int64) -> Unit> = { _: Int64 =>
    let value = slider.value()
    progressBar.setValue(value)
}
slider.setOnValueChanged(sliderCallback)
```

### Q: 为什么CFunc回调不能访问外部变量？

A: 这是仓颉语言的安全限制。解决方案：
1. 使用全局变量存储需要访问的对象
2. 在回调中重新读取控件状态

### Q: 如何在布局中嵌套布局？

A: 使用`addLayout`方法：
```cangjie
let mainLayout = QVBoxLayout()
let topLayout = QHBoxLayout()
topLayout.addWidget(btn1.getPtr())
topLayout.addWidget(btn2.getPtr())
mainLayout.addLayout(topLayout.getPtr())
```
