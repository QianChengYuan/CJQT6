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
