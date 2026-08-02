# CJQT6 容器与布局模块

本模块包含当前源码中实际支持的容器控件与布局 API。

## 容器控件

### QGroupBox - 分组框

```cangjie
import cjqt6.widgets.*

let groupBox = QGroupBox()
groupBox.setTitle("分组标题")
groupBox.setCheckable(true)
groupBox.setAlignment(0x0004)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `setTitle(title: String)` / `title(): String` | 设置/获取标题 |
| `setCheckable(checkable: Bool)` / `isCheckable(): Bool` | 设置/获取是否可勾选 |
| `setChecked(checked: Bool)` / `isChecked(): Bool` | 设置/获取勾选状态 |
| `setAlignment(alignment: Int32)` / `alignment(): Int32` | 设置/获取对齐方式 |
| `setOnClicked(callback: BoolCallback)` | 点击回调 |
| `setOnToggled(callback: BoolCallback)` | 勾选状态变化回调 |
| `setLayout(layoutPtr: Int64)` | 设置内部布局 |
| `setEnabled(enabled: Bool)` / `isEnabled(): Bool` | 启用/禁用状态 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` / `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最小/最大尺寸 |
| `show()` / `hide()` / `resize(width, height)` | 显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

### QTabWidget - 标签页

```cangjie
import cjqt6.widgets.*

let tabWidget = QTabWidget()
tabWidget.addTab(page1.getPtr(), "标签1")
tabWidget.addTab(page2.getPtr(), "标签2")
tabWidget.setCurrentIndex(0)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `addTab(widgetPtr: Int64, title: String)` | 添加标签页 |
| `insertTab(index: Int32, widgetPtr: Int64, title: String): Int32` | 在指定位置插入标签页 |
| `removeTab(index: Int32)` | 移除标签页 |
| `currentIndex(): Int32` | 获取当前索引 |
| `setCurrentIndex(index: Int32)` | 设置当前标签页 |
| `count(): Int32` | 获取标签页数量 |
| `setTabText(index: Int32, text: String)` / `tabText(index: Int32): String` | 设置/获取指定标签页文本 |
| `setTabToolTip(index: Int32, toolTip: String)` | 设置指定标签页提示 |
| `setTabsClosable(closable: Bool)` | 设置标签页是否可关闭 |
| `setMovable(movable: Bool)` | 设置标签页是否可移动 |
| `clear()` | 清除所有标签页 |
| `setOnCurrentChanged(callback: Int64Callback)` | 当前标签页变化回调 |
| `disconnectCurrentChanged()` | 断开当前标签页变化信号 |
| `setEnabled(enabled: Bool)` / `isEnabled(): Bool` | 启用/禁用状态 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` / `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最小/最大尺寸 |
| `show()` / `hide()` / `resize(width, height)` | 显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

### QScrollArea - 滚动区域

```cangjie
import cjqt6.widgets.*

let scrollArea = QScrollArea()
scrollArea.setWidget(contentWidget.getPtr())
scrollArea.setWidgetResizable(true)
scrollArea.setAlignment(0x0004)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `setWidget(widgetPtr: Int64)` / `widget(): Int64` | 设置/获取内部控件 |
| `setWidgetResizable(resizable: Bool)` / `widgetResizable(): Bool` | 设置/获取是否自动调整子控件尺寸 |
| `setHorizontalScrollBarPolicy(policy: Int32)` | 设置水平滚动条策略 |
| `setVerticalScrollBarPolicy(policy: Int32)` | 设置垂直滚动条策略 |
| `ensureVisible(x: Int32, y: Int32, w: Int32, h: Int32)` | 滚动以确保区域可见 |
| `setAlignment(alignment: Int32)` / `alignment(): Int32` | 设置/获取内容对齐方式 |
| `setEnabled(enabled: Bool)` / `isEnabled(): Bool` | 启用/禁用状态 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` / `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最小/最大尺寸 |
| `show()` / `hide()` / `resize(width, height)` | 显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

**滚动条策略常量** (`ScrollBarPolicy`，对应 Qt::ScrollBarPolicy):
| 常量 | 值 | 说明 |
|------|-----|------|
| `ScrollBarPolicy.ScrollBarAsNeeded` | 0 | 需要时显示 |
| `ScrollBarPolicy.ScrollBarAlwaysOff` | 1 | 始终隐藏 |
| `ScrollBarPolicy.ScrollBarAlwaysOn` | 2 | 始终显示 |

### QFrame - 边框容器

```cangjie
import cjqt6.widgets.*

let frame = QFrame()
frame.setFrameShape(StyledPanel)
frame.setFrameShadow(Raised)
frame.setLineWidth(2)
frame.setFrameStyle(StyledPanel | Raised)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `setFrameShape(shape: Int32)` / `frameShape(): Int32` | 设置/获取边框形状 |
| `setFrameShadow(shadow: Int32)` / `frameShadow(): Int32` | 设置/获取边框阴影 |
| `setLineWidth(width: Int32)` | 设置线宽 |
| `setFrameStyle(style: Int32)` / `frameStyle(): Int32` | 设置/获取整体边框样式 |
| `setMidLineWidth(width: Int32)` / `midLineWidth(): Int32` | 设置/获取中线宽度 |
| `setFrameRect(x: Int32, y: Int32, w: Int32, h: Int32)` | 设置边框矩形 |
| `setLayout(layoutPtr: Int64)` | 设置内部布局 |
| `setEnabled(enabled: Bool)` / `isEnabled(): Bool` | 启用/禁用状态 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` / `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最小/最大尺寸 |
| `show()` / `hide()` / `resize(width, height)` | 显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

**边框形状常量**:
```cangjie
NoFrame
Box
Panel
WinPanel
HLine
VLine
StyledPanel
```

**边框阴影常量**:
```cangjie
Plain
Raised
Sunken
```

### QSplitter - 分割器

```cangjie
import cjqt6.widgets.*

let splitter = QSplitter.createHorizontal(0)
splitter.addWidget(leftWidget.getPtr())
splitter.addWidget(rightWidget.getPtr())
splitter.setStretchFactor(0, 1)
splitter.setStretchFactor(1, 2)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `createHorizontal(parent: Int64): QSplitter` / `createVertical(parent: Int64): QSplitter` | 创建水平/垂直分割器 |
| `init(parent: Int64)` | 通过父窗口指针创建 |
| `addWidget(widgetPtr: Int64)` | 添加子控件 |
| `count(): Int32` | 获取子控件数量 |
| `setStretchFactor(index: Int32, stretch: Int32)` | 设置拉伸因子 |
| `setHandleWidth(width: Int32)` / `handleWidth(): Int32` | 设置/获取分割条宽度 |
| `setChildrenCollapsible(collapsible: Bool)` / `childrenCollapsible(): Bool` | 设置/获取子控件是否可折叠 |
| `setOrientation(orientation: Int32)` / `orientation(): Int32` | 设置/获取方向 |
| `show()` / `hide()` / `resize(width, height)` | 显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

**方向常量**:
```cangjie
SplitterOrientation.Horizontal
SplitterOrientation.Vertical
```

---

## 布局管理

### QVBoxLayout - 垂直布局

```cangjie
import cjqt6.gui.*

let layout = QVBoxLayout()
layout.addWidget(label.getPtr())
layout.addWidget(button.getPtr(), 1)
layout.addStretch()
layout.setSpacing(10)
layout.setMargin(20)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `addWidget(widgetPtr: Int64)` / `addWidget(widgetPtr: Int64, stretch: Int32)` | 添加控件并可指定拉伸因子 |
| `addLayout(layoutPtr: Int64)` | 添加子布局 |
| `addStretch()` | 添加弹性空间 |
| `setSpacing(spacing: Int32)` | 设置间距 |
| `setMargin(margin: Int32)` | 设置边距 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

### QHBoxLayout - 水平布局

```cangjie
import cjqt6.gui.*

let hLayout = QHBoxLayout()
hLayout.addWidget(btn1.getPtr())
hLayout.addWidget(btn2.getPtr(), 1)
hLayout.addStretch()
```

### QGridLayout - 网格布局

```cangjie
import cjqt6.gui.*

let grid = QGridLayout()
grid.addWidget(label1.getPtr(), 0, 0)
grid.addWidget(edit1.getPtr(), 0, 1)
grid.addWidgetSpan(bigWidget.getPtr(), 1, 0, 2, 2)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `addWidget(widgetPtr: Int64, row: Int32, col: Int32)` | 添加控件到指定位置 |
| `addWidgetSpan(widgetPtr: Int64, row: Int32, col: Int32, rowSpan: Int32, colSpan: Int32)` | 跨行跨列添加 |
| `setSpacing(spacing: Int32)` | 设置间距 |
| `setMargin(margin: Int32)` | 设置边距 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

### QFormLayout - 表单布局

标签-控件成对排列，适合设置界面。

```cangjie
import cjqt6.gui.*

let form = QFormLayout()
form.addRow("用户名:", editName.getPtr())
form.addRow("密码:", editPwd.getPtr())
form.addRow("备注:", textarea.getPtr())
form.insertRow(1, "邮箱:", editEmail.getPtr())   // 插入到第 1 行
form.removeRow(2)                                // 移除第 2 行

// 对齐与策略
form.setLabelAlignment(Alignment.Right.value)
form.setFieldGrowthPolicy(FieldGrowthPolicy.ExpandingFieldsGrow)
form.setRowWrapPolicy(RowWrapPolicy.WrapLongRows)

window.setLayout(form.getPtr())
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `addRow(label: String, widgetPtr: Int64)` | 添加一行（文本标签+控件） |
| `addRowWidget(labelWidgetPtr: Int64, fieldWidgetPtr: Int64)` | 添加一行（控件标签+控件） |
| `addRowLayout(label: String, layoutPtr: Int64)` | 添加一行（文本标签+子布局） |
| `insertRow(row: Int32, label: String, widgetPtr: Int64)` | 在指定位置插入一行 |
| `removeRow(row: Int32)` | 移除指定行 |
| `rowCount(): Int32` | 获取行数 |
| `setSpacing(spacing: Int32)` / `setMargin(margin: Int32)` | 间距/边距 |
| `setLabelAlignment(alignment: Int32)` | 设置标签对齐 |
| `setFormAlignment(alignment: Int32)` | 设置表单对齐 |
| `setFieldGrowthPolicy(policy: Int32)` | 设置字段增长策略 |
| `setRowWrapPolicy(policy: Int32)` | 设置行换行策略 |
| `getPtr(): Int64` / `close()` / `delete()` | 指针与资源释放 |

**策略常量**:
```cangjie
// 字段增长策略
FieldGrowthPolicy.FieldsStayAtSizeHint     // 0 字段保持大小提示
FieldGrowthPolicy.ExpandingFieldsGrow      // 1 可扩展字段增长
FieldGrowthPolicy.AllNonFixedFieldsGrow    // 2 所有非固定字段增长

// 行换行策略
RowWrapPolicy.DontWrapRows    // 0 不换行
RowWrapPolicy.WrapLongRows    // 1 长行换行
RowWrapPolicy.WrapAllRows     // 2 所有行换行
```

---

## 多页面容器

### QStackedWidget - 堆叠窗口

管理多个子页面，一次只显示一个，常用于多页切换界面。

```cangjie
import cjqt6.widgets.*

let stack = QStackedWidget()

// 添加页面，返回索引
let idx1 = stack.addWidget(page1.getPtr())
let idx2 = stack.addWidget(page2.getPtr())

// 切换页面
stack.setCurrentIndex(1)
let current = stack.currentIndex()

stack.setOnCurrentChanged({ index: Int32 =>
    println("切到页面 ${index}")
})

stack.delete()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(parent!: Int64 = 0)` | 创建堆叠窗口（可指定父控件） |
| `addWidget(widgetPtr: Int64): Int32` | 添加页面，返回索引 |
| `insertWidget(index: Int32, widgetPtr: Int64): Int32` | 指定位置插入页面 |
| `removeWidget(widgetPtr: Int64)` | 移除页面（不释放控件） |
| `setCurrentIndex(index: Int32)` / `currentIndex(): Int32` | 设置/获取当前页索引 |
| `setCurrentWidget(widgetPtr: Int64)` | 设置当前显示的子部件 |
| `currentWidget(): Int64` / `widget(index: Int32): Int64` | 获取子部件指针 |
| `count(): Int32` | 页面总数 |
| `setOnCurrentChanged(callback: Int32Callback)` | 页面切换回调 |
| `setOnWidgetRemoved(callback: Int32Callback)` | 页面移除回调 |
| `show()` / `hide()` / `resize(width, height)` | 显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 指针与资源释放 |

### QMdiArea / QMdiSubWindow - 多文档区域

管理多个子窗口，支持层叠/平铺/页签等视图模式，适合多文档应用。

```cangjie
import cjqt6.widgets.*

let mdi = QMdiArea()

// 添加子窗口
let subPtr = mdi.addSubWindow(editor1.getPtr())

// 排列子窗口
mdi.cascadeSubWindows()   // 层叠
mdi.tileSubWindows()      // 平铺

// 视图模式
mdi.setViewMode(MdiAreaViewMode.TabbedView)   // 页签模式

// 子窗口操作
let current = mdi.currentSubWindow()
mdi.setActiveSubWindow(subPtr)
mdi.closeAllSubWindows()

mdi.setOnSubWindowActivated({ subWin: Int64 =>
    println("激活子窗口")
})

mdi.delete()
```

**视图模式与激活顺序常量**:
```cangjie
MdiAreaViewMode.SubWindowView   // 0 子窗口模式
MdiAreaViewMode.TabbedView      // 1 页签模式

MdiAreaActivationOrder.CreationOrder         // 0 创建顺序
MdiAreaActivationOrder.StackingOrder         // 1 堆叠顺序
MdiAreaActivationOrder.ActivationHistoryOrder // 2 激活历史顺序
```

**QMdiArea 方法**:
| 方法 | 说明 |
|------|------|
| `init(parent!: Int64 = 0)` | 创建多文档区域 |
| `addSubWindow(widgetPtr: Int64): Int64` | 添加子窗口，返回指针 |
| `removeSubWindow(subWinPtr: Int64)` | 移除子窗口 |
| `currentSubWindow(): Int64` | 当前子窗口指针 |
| `setActiveSubWindow(subWinPtr: Int64)` | 设置激活子窗口 |
| `cascadeSubWindows()` / `tileSubWindows()` | 层叠/平铺排列 |
| `closeAllSubWindows()` | 关闭全部子窗口 |
| `setViewMode(mode: Int32)` / `viewMode(): Int32` | 设置/获取视图模式 |
| `setActivationOrder(order: Int32)` / `activationOrder(): Int32` | 设置/获取激活顺序 |
| `subWindowCount(): Int32` | 子窗口数量 |
| `setBackground(path: String)` | 设置背景图片 |
| `setOnSubWindowActivated(callback: Int64Callback)` | 子窗口激活回调 |
| `setLayout(layoutPtr: Int64)` | 设置布局 |
| `show()` / `hide()` / `resize(width, height)` | 显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 指针与资源释放 |

**QMdiSubWindow 方法**（由 `addSubWindow` 返回的指针包装）:
| 方法 | 说明 |
|------|------|
| `init(ptr: Int64)` | 用原生指针创建包装 |
| `setWidget(widgetPtr: Int64)` / `widget(): Int64` | 设置/获取内容控件 |
| `showShaded()` / `isShaded(): Bool` | 折叠（阴影）显示 |
| `show()` / `hide()` / `resize(width, height)` | 显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 指针与资源释放 |

### QToolBox - 工具箱

以选项卡方式组织多个页面（类似分页容器）。

```cangjie
import cjqt6.widgets.*

let toolbox = QToolBox()
toolbox.addItem(page1.getPtr(), "常规")     // 返回索引
toolbox.addItem(page2.getPtr(), "高级")
toolbox.setCurrentIndex(1)

// 项操作
toolbox.setItemText(0, "基础")
toolbox.setItemToolTip(1, "高级设置")
toolbox.setItemEnabled(1, false)
toolbox.setItemIcon(0, "icon.png")

toolbox.setOnCurrentChanged({ index: Int32 =>
    println("当前页 ${index}")
})

toolbox.delete()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(parent!: Int64 = 0)` | 创建工具箱 |
| `addItem(widgetPtr: Int64, title: String): Int32` | 添加页，返回索引 |
| `insertItem(index: Int32, widgetPtr: Int64, title: String): Int32` | 指定位置插入页 |
| `removeItem(index: Int32)` | 移除页 |
| `count(): Int32` | 页总数 |
| `currentIndex(): Int32` / `setCurrentIndex(index: Int32)` | 当前页 |
| `setCurrentWidget(widgetPtr: Int64)` | 设置当前显示子部件 |
| `setItemText(index: Int32, text: String)` / `itemText(index: Int32): String` | 页文本 |
| `setItemToolTip(index: Int32, toolTip: String)` | 页工具提示 |
| `setItemEnabled(index: Int32, enabled: Bool)` / `isItemEnabled(index: Int32): Bool` | 页启用状态 |
| `setItemIcon(index: Int32, path: String)` | 页图标（文件路径） |
| `indexOf(widgetPtr: Int64): Int32` | 查找子部件索引 |
| `setOnCurrentChanged(callback: Int32Callback)` | 当前页切换回调 |
| `setLayout(layoutPtr: Int64)` | 设置布局 |
| `setMinimumSize(minw: Int32, minh: Int32)` | 设置最小尺寸 |
| `show()` / `hide()` / `resize(width, height)` | 显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 指针与资源释放 |

### QDockWidget - 停靠窗口

可浮动/移动/关闭，停靠到主窗口边缘区域（配合 `QMainWindow.addDockWidget` 使用）。

```cangjie
import cjqt6.widgets.*

let dock = QDockWidget("文件浏览器")
dock.setWidget(treeView.getPtr())
dock.setAllowedAreas(DockWidgetArea.Left | DockWidgetArea.Right)
dock.setFeatures(DockWidgetFeature.Closable | DockWidgetFeature.Movable | DockWidgetFeature.Floatable)
dock.setFloating(true)

dock.setOnTopLevelChanged({ floating: Bool =>
    println("浮动状态变化: ${floating}")
})
dock.setOnDockLocationChanged({ area: Int32 =>
    println("停靠位置: ${area}")
})

dock.show()
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init(title: String, parent!: Int64 = 0)` | 创建停靠窗口（可指定父窗口） |
| `setWidget(widgetPtr: Int64)` / `widget(): Int64` | 设置/获取内容控件 |
| `setWindowTitle(title: String)` | 设置标题 |
| `setAllowedAreas(areas: Int32)` / `allowedAreas(): Int32` | 设置/获取允许停靠区域 |
| `setFeatures(features: Int32)` / `features(): Int32` | 设置/获取停靠窗口特性 |
| `setFloating(floating: Bool)` / `isFloating(): Bool` | 设置/获取浮动状态 |
| `setVisible(visible: Bool)` | 设置可见性 |
| `toggleViewAction(): Int64` | 获取切换视图动作指针（可加入工具栏） |
| `setOnTopLevelChanged(callback: BoolCallback)` | 顶层状态变化回调 |
| `setOnVisibilityChanged(callback: BoolCallback)` | 可见性变化回调 |
| `setOnDockLocationChanged(callback: Int32Callback)` | 停靠位置变化回调 |
| `setLayout(layoutPtr: Int64)` | 设置内部布局 |
| `show()` / `hide()` / `resize(width, height)` | 显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 指针与资源释放 |

**常量**:
```cangjie
DockWidgetArea.Left
DockWidgetArea.Right
DockWidgetArea.Top
DockWidgetArea.Bottom
DockWidgetArea.All

DockWidgetFeature.Closable
DockWidgetFeature.Movable
DockWidgetFeature.Floatable
DockWidgetFeature.AllFeatures
DockWidgetFeature.NoFeature
```

---

## 通用布局类型（gui 模块）

以下类型定义于 `cjqt6.gui`，用于布局与控件对齐等场景。

### Alignment - 对齐方式

可组合的标志结构体，通过 `|` 位或组合，用 `value` 字段传入需要 `Int32` 的 API。

```cangjie
import cjqt6.gui.*

let center = Alignment.Center          // 完全居中
let topLeft = Alignment.TopLeft        // 左上
let custom = Alignment.Left | Alignment.VCenter  // 位或组合
if (custom.isHCenter()) { }            // 是否水平居中
label.setAlignment(Alignment.Center.value)  // 传 Int32 给控件
```

**常量**:
| 常量 | 值 | 说明 |
|------|-----|------|
| `Alignment.Left` | 0x0001 | 左对齐 |
| `Alignment.Right` | 0x0002 | 右对齐 |
| `Alignment.HCenter` | 0x0004 | 水平居中 |
| `Alignment.Top` | 0x0020 | 顶部对齐 |
| `Alignment.Bottom` | 0x0040 | 底部对齐 |
| `Alignment.VCenter` | 0x0080 | 垂直居中 |
| `Alignment.Center` | 0x0084 | 完全居中（HCenter \| VCenter） |
| `Alignment.TopLeft` | 0x0021 | 左上 |
| `Alignment.TopRight` | 0x0022 | 右上 |
| `Alignment.BottomLeft` | 0x0041 | 左下 |
| `Alignment.BottomRight` | 0x0042 | 右下 |
| `Alignment.Default` | 0x0081 | 默认（Left \| VCenter） |

**方法**:
| 方法 | 说明 |
|------|------|
| `init(v: Int32)` | 构造 |
| `\|(other: Alignment): Alignment` | 位或组合标志 |
| `has(flag: Alignment): Bool` | 是否包含某标志 |
| `isHCenter(): Bool` / `isVCenter(): Bool` / `isCenter(): Bool` | 居中判断 |
| `value: Int32` | 原始整数值（传给需要 Int32 的 API） |

### Orientation - 方向枚举

```cangjie
let o = Orientation.Horizontal
let v = Orientation.Vertical
println(o.value())  // 1
println(Orientation.fromValue(2))  // Vertical
```

| 成员 | `value()` | 说明 |
|------|-----------|------|
| `Horizontal` | 1 | 水平 |
| `Vertical` | 2 | 垂直 |

### Margins / Point / Size / Rect - 布局几何结构体

```cangjie
let margins = Margins(4, 4, 4, 4)   // 或 Margins(all: 8)
let point = Point(10, 20)
let size = Size(100, 50)
let rect = Rect(0, 0, 100, 50)
println(rect.right())   // x + width
println(rect.center())  // Point 中心点
```

| 类型 | 字段 | 说明 |
|------|------|------|
| `Margins` | `left/top/right/bottom: Int32` | 布局边距；`init(all: Int32)` 统一设置 |
| `Point` | `x/y: Int32` | 点坐标 |
| `Size` | `width/height: Int32` | 尺寸 |
| `Rect` | `x/y/width/height: Int32` | 矩形；含 `left()/top()/right()/bottom()/center(): Point` |
