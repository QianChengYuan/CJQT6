# CJQT6 容器与布局模块

本模块包含容器控件和布局管理。

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
| `title(): String` | 获取标题 |
| `setCheckable(checkable: Bool)` | 设置可勾选 |
| `isCheckable(): Bool` | 是否可勾选 |
| `setChecked(checked: Bool)` | 设置勾选状态 |
| `isChecked(): Bool` | 是否已勾选 |
| `setLayout(layoutPtr: Int64)` | 设置内部布局 |
| `setEnabled(enabled: Bool)` | 设置启用/禁用 |
| `isEnabled(): Bool` | 检查是否启用 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` | 设置最小尺寸 |
| `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最大尺寸 |
| `show()` | 显示控件 |
| `hide()` | 隐藏控件 |
| `resize(width: Int32, height: Int32)` | 调整大小 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

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
| `insertTab(index: Int32, widgetPtr: Int64, title: String): Int32` | 在指定位置插入标签页 |
| `removeTab(index: Int32)` | 移除标签页 |
| `currentIndex(): Int32` | 获取当前索引 |
| `setCurrentIndex(index: Int32)` | 设置当前标签页 |
| `count(): Int32` | 获取标签页数量 |
| `setTabText(index: Int32, text: String)` | 设置指定标签页的文本 |
| `tabText(index: Int32): String` | 获取指定标签页的文本 |
| `setTabToolTip(index: Int32, toolTip: String)` | 设置指定标签页的工具提示 |
| `setTabsClosable(closable: Bool)` | 设置标签页是否可关闭 |
| `setMovable(movable: Bool)` | 设置标签页是否可移动 |
| `clear()` | 清除所有标签页 |
| `setEnabled(enabled: Bool)` | 设置启用/禁用 |
| `isEnabled(): Bool` | 检查是否启用 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` | 设置最小尺寸 |
| `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最大尺寸 |
| `setOnCurrentChanged(callback: Int64Callback)` | 当前标签页变化回调 |
| `disconnectCurrentChanged()` | 断开当前标签页变化信号 |
| `show()` | 显示控件 |
| `hide()` | 隐藏控件 |
| `resize(width: Int32, height: Int32)` | 调整大小 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

### QScrollArea - 滚动区域

```cangjie
let scrollArea = QScrollArea()
scrollArea.setWidget(contentWidget.getPtr())
scrollArea.setWidgetResizable(true)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setWidget(widgetPtr: Int64)` | 设置要滚动的子控件 |
| `setWidgetResizable(resizable: Bool)` | 设置子控件是否可自动调整大小 |
| `widget(): Int64` | 获取子控件指针 |
| `setEnabled(enabled: Bool)` | 设置启用/禁用 |
| `isEnabled(): Bool` | 检查是否启用 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` | 设置最小尺寸 |
| `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最大尺寸 |
| `show()` | 显示控件 |
| `hide()` | 隐藏控件 |
| `resize(width: Int32, height: Int32)` | 调整大小 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

### QFrame - 边框容器

```cangjie
let frame = QFrame()
frame.setFrameShape(StyledPanel)
frame.setFrameShadow(Raised)
frame.setLineWidth(2)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setFrameShape(shape: Int32)` | 设置边框形状 |
| `setFrameShadow(shadow: Int32)` | 设置边框阴影 |
| `setLineWidth(width: Int32)` | 设置线宽 |
| `setLayout(layoutPtr: Int64)` | 设置内部布局 |
| `setEnabled(enabled: Bool)` | 设置启用/禁用 |
| `isEnabled(): Bool` | 检查是否启用 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` | 设置最小尺寸 |
| `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最大尺寸 |
| `show()` | 显示控件 |
| `hide()` | 隐藏控件 |
| `resize(width: Int32, height: Int32)` | 调整大小 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

**边框形状常量**:
```cangjie
NoFrame      // 无边框 (0)
Box          // 矩形框 (1)
Panel        // 面板 (2)
WinPanel     // 窗口面板 (3)
HLine        // 水平线 (4)
VLine        // 垂直线 (5)
StyledPanel  // 样式面板 (6)
```

**边框阴影常量**:
```cangjie
Plain   // 平面 (16)
Raised  // 凸起 (32)
Sunken  // 凹陷 (48)
```

### QSplitter - 分割器

可拖拽分割的子控件区域。支持水平和垂直两种方向。

```cangjie
// 水平分割器
let splitter = QSplitter.createHorizontal(0)
splitter.addWidget(leftWidget.getPtr())
splitter.addWidget(rightWidget.getPtr())
splitter.setStretchFactor(0, 1)  // 左侧拉伸因子
splitter.setStretchFactor(1, 2)  // 右侧拉伸因子

// 垂直分割器
let vSplitter = QSplitter.createVertical(0)
vSplitter.addWidget(topWidget.getPtr())
vSplitter.addWidget(bottomWidget.getPtr())
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(parent: Int64)` | 创建分割器 |
| `createHorizontal(parent: Int64): QSplitter` | 创建水平分割器（静态方法） |
| `createVertical(parent: Int64): QSplitter` | 创建垂直分割器（静态方法） |
| `addWidget(widgetPtr: Int64)` | 添加子控件 |
| `count(): Int32` | 获取子控件数量 |
| `setStretchFactor(index: Int32, stretch: Int32)` | 设置拉伸因子 |
| `setHandleWidth(width: Int32)` | 设置分割条宽度 |
| `handleWidth(): Int32` | 获取分割条宽度 |
| `setChildrenCollapsible(collapsible: Bool)` | 设置子控件是否可折叠 |
| `childrenCollapsible(): Bool` | 子控件是否可折叠 |
| `setOrientation(orientation: Int32)` | 设置方向 |
| `orientation(): Int32` | 获取方向 |
| `show()` | 显示分割器 |
| `hide()` | 隐藏分割器 |
| `resize(width: Int32, height: Int32)` | 调整大小 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

**方向常量** (`SplitterOrientation`):
```cangjie
SplitterOrientation.Horizontal  // 水平（默认）
SplitterOrientation.Vertical    // 垂直
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
grid.addWidgetSpan(bigWidget.getPtr(), 2, 0, 2, 2)  // 从第2行第0列开始，占2行2列
```

**方法**:
| 方法 | 说明 |
|------|------|
| `addWidget(ptr, row, col)` | 添加控件到指定位置 |
| `addWidgetSpan(ptr, row, col, rowSpan, colSpan)` | 跨行跨列添加 |
| `setSpacing(spacing: Int32)` | 设置间距 |
| `setMargin(margin: Int32)` | 设置边距 |
