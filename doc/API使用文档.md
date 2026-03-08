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
9. [列表控件](#列表控件)
10. [树形控件](#树形控件)
11. [菜单与工具栏](#菜单与工具栏)
12. [对话框](#对话框)
13. [事件处理](#事件处理)
14. [信号与槽](#信号与槽)

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

## 列表控件

### QListWidget

列表控件，用于显示一系列可选择的项。

```cangjie
import CJQT6.views.*

let listWidget = QListWidget()
listWidget.setAlternatingRowColors(true)

// 添加项
listWidget.addItem("苹果")
listWidget.addItem("香蕉")
listWidget.addItem("橙子")

// 设置可勾选
listWidget.setItemCheckable(0, true)
listWidget.setChecked(0, true)

// 获取当前选中
let row = listWidget.currentRow()
let text = listWidget.currentItemText()
```

**常用方法**:
| 方法 | 说明 |
|------|------|
| `addItem(text: String)` | 添加项 |
| `insertItem(row: Int32, text: String)` | 在指定位置插入项 |
| `removeItem(row: Int32)` | 移除指定行 |
| `clear()` | 清空所有项 |
| `count(): Int32` | 获取项数量 |
| `currentRow(): Int32` | 获取当前选中行（-1表示无选中） |
| `setCurrentRow(row: Int32)` | 设置当前选中行 |
| `currentItemText(): String` | 获取当前选中项文本 |
| `itemText(row: Int32): String` | 获取指定行文本 |
| `setItemText(row: Int32, text: String)` | 设置指定行文本 |
| `setItemData(row: Int32, data: Int64)` | 设置项用户数据 |
| `getItemData(row: Int32): Int64` | 获取项用户数据 |

**勾选相关**:
| 方法 | 说明 |
|------|------|
| `setItemCheckable(row: Int32, checkable: Bool)` | 设置项是否可勾选 |
| `isChecked(row: Int32): Bool` | 获取项是否被勾选 |
| `setChecked(row: Int32, checked: Bool)` | 设置项勾选状态 |

**外观设置**:
| 方法 | 说明 |
|------|------|
| `setSelectionMode(mode: Int32)` | 设置选择模式 |
| `setAlternatingRowColors(enable: Bool)` | 设置交替行颜色 |
| `setSortingEnabled(enable: Bool)` | 设置是否可排序 |
| `setItemIcon(row: Int32, iconType: Int32)` | 设置项图标 |

**选择模式常量** (ListSelectionMode):
```cangjie
NoSelection          // 不可选择
SingleSelection      // 单选
MultiSelection       // 多选
ExtendedSelection    // 扩展选择（Ctrl/Shift）
ContiguousSelection  // 连续选择
```

**图标类型常量** (ListIconType):
```cangjie
None         // 无图标
Folder       // 文件夹图标
File         // 文件图标
Warning      // 警告图标
Information  // 信息图标
Critical     // 错误图标
```

---

## 树形控件

### QTreeWidget

树形控件，用于显示层次结构数据。

```cangjie
import CJQT6.views.*

let treeWidget = QTreeWidget()
treeWidget.setColumnCount(3)
treeWidget.setHeaderLabel(0, "名称")
treeWidget.setHeaderLabel(1, "类型")
treeWidget.setHeaderLabel(2, "大小")

// 添加顶级项
let root = treeWidget.addTopLevelItem("项目文件夹")
root.setText(1, "文件夹")
root.setText(2, "-")

// 添加子项
let child = root.addChild("src")
child.setText(1, "文件夹")

let file = child.addChild("main.cj")
file.setText(1, "源码")
file.setText(2, "2KB")

// 展开所有
treeWidget.expandAll()
```

**QTreeWidget 方法**:
| 方法 | 说明 |
|------|------|
| `setColumnCount(columns: Int32)` | 设置列数 |
| `setHeaderLabel(column: Int32, label: String)` | 设置表头标签 |
| `setHeaderHidden(hidden: Bool)` | 隐藏/显示表头 |
| `addTopLevelItem(text: String): QTreeWidgetItem` | 添加顶级项 |
| `insertTopLevelItem(index: Int32, item: QTreeWidgetItem)` | 插入顶级项 |
| `takeTopLevelItem(index: Int32)` | 移除顶级项 |
| `topLevelItemCount(): Int32` | 获取顶级项数量 |
| `topLevelItem(index: Int32): QTreeWidgetItem` | 获取顶级项 |
| `currentItem(): ?QTreeWidgetItem` | 获取当前选中项 |
| `setCurrentItem(item: QTreeWidgetItem)` | 设置当前选中项 |
| `expandItem(item: QTreeWidgetItem)` | 展开项 |
| `collapseItem(item: QTreeWidgetItem)` | 折叠项 |
| `expandAll()` | 展开所有 |
| `collapseAll()` | 折叠所有 |
| `clear()` | 清空 |

### QTreeWidgetItem

树形项，表示树中的一个节点。

```cangjie
// 创建项
let item = QTreeWidgetItem("节点名称")
item.setText(1, "附加信息")

// 添加子项
let child = item.addChild("子节点")

// 获取父项
let parent = item.parent()

// 用户数据
item.setData(0, 12345)
let data = item.getData(0)
```

**QTreeWidgetItem 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空项 |
| `init(text: String)` | 创建带文本的项 |
| `setText(column: Int32, text: String)` | 设置列文本 |
| `text(column: Int32): String` | 获取列文本 |
| `addChild(text: String): QTreeWidgetItem` | 添加子项并返回 |
| `addChildItem(child: QTreeWidgetItem)` | 添加子项对象 |
| `childCount(): Int32` | 获取子项数量 |
| `child(index: Int32): QTreeWidgetItem` | 获取子项 |
| `takeChild(index: Int32)` | 移除子项 |
| `parent(): ?QTreeWidgetItem` | 获取父项 |
| `setData(column: Int32, data: Int64)` | 设置用户数据 |
| `getData(column: Int32): Int64` | 获取用户数据 |
| `setExpanded(expanded: Bool)` | 设置展开状态 |
| `isExpanded(): Bool` | 是否展开 |
| `setSelected(selected: Bool)` | 设置选中状态 |
| `isSelected(): Bool` | 是否选中 |
| `setHidden(hidden: Bool)` | 设置隐藏状态 |
| `isHidden(): Bool` | 是否隐藏 |
| `setCheckState(column: Int32, state: Int32)` | 设置勾选状态 |
| `checkState(column: Int32): Int32` | 获取勾选状态 |

**勾选状态常量** (CheckState):
```cangjie
Unchecked          // 未勾选
PartiallyChecked   // 部分勾选
Checked            // 已勾选
```

---

## 菜单与工具栏

### QMainWindow

主窗口，提供菜单栏、工具栏、状态栏的标准布局。

```cangjie
import CJQT6.menu.*

let window = QMainWindow()
window.setWindowTitle("主窗口")
window.resize(800, 600)

// 设置中心控件
window.setCentralWidget(textEdit.getPtr())

// 设置菜单栏
window.setMenuBar(menuBar.getPtr())

// 设置状态栏
window.setStatusBar(statusBar.getPtr())

// 添加工具栏
window.addToolBar(toolBar.getPtr())
```

**QMainWindow 方法**:
| 方法 | 说明 |
|------|------|
| `setWindowTitle(title: String)` | 设置窗口标题 |
| `setCentralWidget(ptr: Int64)` | 设置中心控件 |
| `setMenuBar(ptr: Int64)` | 设置菜单栏 |
| `setStatusBar(ptr: Int64)` | 设置状态栏 |
| `addToolBar(ptr: Int64)` | 添加工具栏 |
| `resize(width: Int32, height: Int32)` | 设置大小 |
| `show()` | 显示窗口 |

### QMenuBar

菜单栏，包含多个菜单。

```cangjie
let menuBar = QMenuBar()

// 添加菜单
let fileMenu = menuBar.addMenu("文件(&F)")
let editMenu = menuBar.addMenu("编辑(&E)")
let helpMenu = menuBar.addMenu("帮助(&H)")
```

### QMenu

菜单，包含多个菜单项。

```cangjie
let fileMenu = QMenu("文件(&F)")

// 添加动作
let newAction = QAction("新建(&N)")
newAction.setShortcut("Ctrl+N")
fileMenu.addActionPtr(newAction.getPtr())

// 添加分隔符
fileMenu.addSeparator()

// 添加子菜单
let recentMenu = fileMenu.addMenu("最近文件")
```

**QMenu 方法**:
| 方法 | 说明 |
|------|------|
| `init(title: String)` | 创建菜单 |
| `addActionPtr(ptr: Int64)` | 添加动作 |
| `addSeparator()` | 添加分隔符 |
| `addMenu(title: String): QMenu` | 添加子菜单 |
| `clear()` | 清空菜单 |

### QAction

菜单动作，表示一个菜单项或工具栏按钮。

```cangjie
let openAction = QAction("打开(&O)...")
openAction.setShortcut("Ctrl+O")
openAction.setOnTriggered({ _: Int64 =>
    // 打���文件逻辑
})
```

**QAction 方法**:
| 方法 | 说明 |
|------|------|
| `init(text: String)` | 创建动作 |
| `setText(text: String)` | 设置文本 |
| `setShortcut(key: String)` | 设置快捷键 |
| `setCheckable(checkable: Bool)` | 设置可勾选 |
| `setChecked(checked: Bool)` | 设置勾选状态 |
| `isEnabled(): Bool` | 是否启用 |
| `setEnabled(enabled: Bool)` | 设置启用状态 |
| `setOnTriggered(callback: CFunc)` | 设置触发回调 |
| `getPtr(): Int64` | 获取指针 |

### QToolBar

工具栏，包含快捷操作按钮。

```cangjie
let toolBar = QToolBar()
toolBar.addAction(newAction.getPtr())
toolBar.addAction(openAction.getPtr())
toolBar.addSeparator()
toolBar.addAction(saveAction.getPtr())
```

### QStatusBar

状态栏，显示状态信息。

```cangjie
let statusBar = QStatusBar()
statusBar.showMessage("就绪")
window.setStatusBar(statusBar.getPtr())
```

**QStatusBar 方法**:
| 方法 | 说明 |
|------|------|
| `showMessage(text: String)` | 显示临时消息 |
| `showMessage(text: String, timeout: Int32)` | 显示消息指定毫秒 |
| `clearMessage()` | 清除消息 |

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

### QInputDialog - 输入对话框

```cangjie
// 获取文本输入
let name = QInputDialog.getText(0, "输入姓名", "请输入姓名:", "")
if (name.size > 0) {
    println("输入了: ${name}")
}

// 获取整数输入 (返回Int32最小值表示取消)
let age = QInputDialog.getInt(0, "输入年龄", "请输入年龄:", 18, 0, 150)

// 获取浮点数输入 (返回NaN表示取消)
let price = QInputDialog.getDouble(0, "输入价格", "请输入价格:", 0.0, 0.0, 10000.0)
```

**QInputDialog 方法**:
| 方法 | 说明 |
|------|------|
| `getText(parent, title, label, defaultText): String` | 获取文本输入 |
| `getInt(parent, title, label, value, min, max): Int32` | 获取整数输入 |
| `getDouble(parent, title, label, value, min, max): Float64` | 获取浮点数输入 |

### QColorDialog - 颜色对话框

```cangjie
// 获取颜色 (返回十六进制字符串如 "#FF0000"，空字符串表示取消)
let color = QColorDialog.getColor(0, "选择颜色")
if (color.size > 0) {
    println("选择了颜色: ${color}")
}
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
| QAction | `setOnTriggered(callback)` | 触发 |
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
