# CJQT6 视图控件模块

本模块包含当前源码中已暴露的表格、列表、树形视图控件及数据模型 API。

## 表格控件

### QTableWidget

```cangjie
import cjqt6.views.*

let table = QTableWidget(5, 3)
table.setHorizontalHeaderLabel(0, "姓名")
table.setHorizontalHeaderLabel(1, "年龄")
table.setHorizontalHeaderLabel(2, "城市")
table.setItem(0, 0, "张三")
table.setItem(0, 1, "25")
table.setItem(0, 2, "北京")
table.setSelectionBehavior(SelectRows)
table.setSelectionMode(SingleSelection)
table.setAlternatingRowColors(true)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` / `init(rows: Int32, cols: Int32)` | 创建空表格或指定大小表格 |
| `setRowCount(rows: Int32)` / `rowCount(): Int32` | 设置/获取行数 |
| `setColumnCount(cols: Int32)` / `columnCount(): Int32` | 设置/获取列数 |
| `setHorizontalHeaderLabel(col: Int32, label: String)` / `setVerticalHeaderLabel(row: Int32, label: String)` | 设置横向/纵向表头 |
| `setItem(row: Int32, col: Int32, text: String)` / `itemText(row: Int32, col: Int32): String` | 设置/获取单元格文本 |
| `clear()` / `clearContents()` | 清空表格或仅清除内容 |
| `insertRow(row: Int32)` / `insertColumn(col: Int32)` | 插入行/列 |
| `removeRow(row: Int32)` / `removeColumn(col: Int32)` | 删除行/列 |
| `currentRow(): Int32` / `currentColumn(): Int32` | 获取当前行/列 |
| `setCurrentCell(row: Int32, col: Int32)` | 设置当前单元格 |
| `setSelectionBehavior(behavior: Int32)` / `setSelectionMode(mode: Int32)` | 设置选择行为与模式 |
| `setShowGrid(show: Bool)` / `setSortingEnabled(enabled: Bool)` / `setAlternatingRowColors(enabled: Bool)` | 表格显示与排序/交替颜色 |
| `resizeColumnsToContents()` / `resizeRowsToContents()` | 根据内容自动调整列高宽 |
| `setColumnWidth(col: Int32, width: Int32)` / `setRowHeight(row: Int32, height: Int32)` | 设置列宽/行高 |
| `horizontalHeaderSetStretchLastSection(stretch: Bool)` / `horizontalHeaderSetSectionResizeMode(mode: Int32)` / `horizontalHeaderSetSectionResizeModeColumn(col: Int32, mode: Int32)` | 表头拉伸与调整模式 |
| `verticalHeaderSetStretchLastSection(stretch: Bool)` / `verticalHeaderSetDefaultSectionSize(size: Int32)` | 纵向表头配置 |
| `setWordWrap(v: Int32)` / `isWordWrap(): Int32` | 设置/获取自动换行 |
| `rowAt(y: Int32)` / `columnAt(x: Int32)` | 根据坐标获取行/列 |
| `setCurrentIndex(indexPtr: Int64)` / `currentIndex(): Int64` | 设置/获取当前索引 |
| `setOnCellClicked(callback)` / `setOnCellChanged(callback)` / `setOnCellDoubleClicked(callback)` / `setOnCurrentCellChanged(callback)` / `setOnItemSelectionChanged(callback)` / `setOnItemClicked(callback)` | 相关信号回调 |
| `show()` / `hide()` / `resize(width, height)` / `setMinimumSize(minw, minh)` | 基础控件行为 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

**常量**:
```cangjie
SelectItems
SelectRows
SelectColumns
NoSelection
SingleSelection
MultiSelection
ExtendedSelection
ContiguousSelection
Interactive
Fixed
Stretch
ResizeToContents
```

### QTableWidgetItem

表格单元格项，通过 `QTableWidget.setItem(row, col, item)` 设置到表格中。

```cangjie
import cjqt6.views.*

let table = QTableWidget(2, 2)
let item = QTableWidgetItem("张三")
item.setFlags(ItemFlag.ItemIsSelectable | ItemFlag.ItemIsEnabled)
item.setCheckState(CheckState.Checked)
item.setBackground(200, 230, 255)   // 单元格背景色
item.setData(ItemDataRole.sizeHintRole(), 100)
table.setItem(0, 0, item)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` / `init(text: String)` | 创建空项或带文本项 |
| `fromPtr(ptr: Int64): QTableWidgetItem` | 由表格返回的指针构造（不拥有所有权，不应 delete） |
| `text(): String` / `setText(text: String)` | 获取/设置文本 |
| `setFlags(flags: Int32)` / `flags(): Int32` | 设置/获取项标志（ItemFlag） |
| `setCheckState(state: Int32)` / `checkState(): Int32` | 设置/获取勾选状态（CheckState） |
| `setData(role: Int32, value: Int64)` / `data(role: Int32): Int64` | 设置/获取指定角色数据 |
| `setBackground(r: Int32, g: Int32, b: Int32)` | 设置单元格背景色（RGB） |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

**常量**（ItemFlag 与 CheckState 同 QStandardItem，见下文数据模型章节）。

### QTableView

基于模型/视图架构的表格控件，可绑定 `QStandardItemModel` 数据模型。

```cangjie
import cjqt6.views.*

let model = QStandardItemModel(3, 2)
model.setItem(0, 0, "张三")
model.setItem(0, 1, "25")
model.setHorizontalHeaderLabel(0, "姓名")
model.setHorizontalHeaderLabel(1, "年龄")

let table = QTableView()
table.setModel(model)
table.setColumnWidth(0, 120)
table.setRowHeight(0, 30)
table.setShowGrid(true)
table.setSelectionBehavior(SelectionBehavior.SelectRows)
table.setSelectionMode(SelectionMode.Single)
table.setSortingEnabled(true)
table.resizeColumnsToContents()
table.show()
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建表格视图 |
| `setModel(model: QStandardItemModel)` | 绑定标准项模型 |
| `setModel(model: QAbstractItemModel)` | 绑定回调式自定义模型（P1：可配合 `notifyDataChanged`/`notifyLayoutChanged` 做实时局部刷新） |
| `setColumnWidth(col: Int32, width: Int32)` / `setRowHeight(row: Int32, height: Int32)` | 设置列宽/行高 |
| `setShowGrid(show: Bool)` / `isShowGrid(): Bool` | 设置/获取是否显示网格 |
| `setGridStyle(style: Int32)` / `gridStyle(): Int32` | 设置/获取网格线样式 |
| `setSelectionMode(mode: Int32)` / `setSelectionBehavior(behavior: Int32)` | 设置选择模式与行为 |
| `setSortingEnabled(enabled: Bool)` / `isSortingEnabled(): Bool` | 设置/获取是否启用排序 |
| `resizeColumnsToContents()` / `resizeRowsToContents()` / `resizeColumnToContents(col: Int32)` | 根据内容自动调整列宽行高 |
| `horizontalHeaderSetStretchLastSection(stretch: Bool)` | 最后一列自动拉伸 |
| `setEditTriggers(triggers: Int32)` / `editTriggers(): Int32` | 设置/获取编辑触发方式 |
| `setCornerButtonEnabled(enabled: Bool)` / `isCornerButtonEnabled(): Bool` | 设置/获取左上角按钮 |
| `setHorizontalHeader(header: QHeaderView)` / `setVerticalHeader(header: QHeaderView)` | 设置自定义表头 |
| `setWordWrap(wordWrap: Bool)` / `isWordWrap(): Bool` | 设置/获取自动换行 |
| `rowAt(y: Int32): Int32` / `columnAt(x: Int32): Int32` | 根据坐标获取行/列 |
| `setCurrentIndex(index: QModelIndex)` / `currentIndex(): Int64` | 设置/获取当前索引 |
| `setOnClicked(callback)` / `setOnDoubleClicked(callback)` / `setOnActivated(callback)` / `setOnPressed(callback)` | 信号回调（传入 QModelIndex 句柄） |
| `show()` / `hide()` / `resize(width, height)` / `setEnabled(enabled)` / `setStyleSheet(style)` | 基础控件行为 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

**常量**:
```cangjie
SelectionBehavior.SelectItems
SelectionBehavior.SelectRows
SelectionBehavior.SelectColumns

SelectionMode.NoSelection
SelectionMode.Single
SelectionMode.Multi
SelectionMode.Extended
```

---

## 列表控件

### QListWidget

```cangjie
import cjqt6.views.*

let listWidget = QListWidget()
listWidget.addItem("苹果")
listWidget.addItem("香蕉")
listWidget.setAlternatingRowColors(true)
listWidget.setItemCheckable(0, true)
listWidget.setChecked(0, true)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建列表控件 |
| `addItem(text: String): Int64` / `insertItem(row: Int32, text: String)` | 添加/插入项 |
| `removeItem(row: Int32)` / `clear()` / `count(): Int32` | 删除/清空/查询项数 |
| `currentRow(): Int32` / `setCurrentRow(row: Int32)` | 获取/设置当前行 |
| `currentItemText(): String` | 获取当前选中项文本 |
| `itemText(row: Int32): String` / `setItemText(row: Int32, text: String)` | 获取/设置指定行文本 |
| `setItemData(row: Int32, data: Int64)` / `getItemData(row: Int32): Int64` | 设置/获取项用户数据 |
| `setSelectionMode(mode: Int32)` | 设置选择模式 |
| `setAlternatingRowColors(enable: Bool)` / `setSortingEnabled(enable: Bool)` | 设置交替行颜色/排序 |
| `setItemIcon(row: Int32, iconType: Int32)` | 设置项图标 |
| `setItemCheckable(row: Int32, checkable: Bool)` / `isChecked(row: Int32): Bool` / `setChecked(row: Int32, checked: Bool)` | 勾选相关 |
| `setOnItemClicked(callback)` / `setOnItemDoubleClicked(callback)` / `setOnCurrentRowChanged(callback)` | 事件回调 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

**常量**:
```cangjie
ListSelectionMode.NoSelection
ListSelectionMode.SingleSelection
ListSelectionMode.MultiSelection
ListSelectionMode.ExtendedSelection
ListSelectionMode.ContiguousSelection

ListIconType.None
ListIconType.Folder
ListIconType.File
ListIconType.Warning
ListIconType.Information
ListIconType.Critical
```

### QListWidgetItem

列表项，通过 `QListWidget.addItem(text)` 返回或 `insertItem(row, text)` 使用。

```cangjie
import cjqt6.views.*

let listWidget = QListWidget()

// addItem 返回项指针，可通过 fromPtr 包装（不拥有所有权，不应 delete）
let itemPtr = listWidget.addItem("苹果")
let item = QListWidgetItem.fromPtr(itemPtr)
item.setFlags(ItemFlag.ItemIsSelectable | ItemFlag.ItemIsUserCheckable | ItemFlag.ItemIsEnabled)
item.setCheckState(CheckState.Checked)
item.setData(ItemDataRole.sizeHintRole(), 100)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` / `init(text: String)` | 创建空项或带文本项 |
| `fromPtr(ptr: Int64): QListWidgetItem` | 由列表返回的指针构造（不拥有所有权，不应 delete） |
| `text(): String` / `setText(text: String)` | 获取/设置文本 |
| `setFlags(flags: Int32)` / `flags(): Int32` | 设置/获取项标志（ItemFlag） |
| `setCheckState(state: Int32)` / `checkState(): Int32` | 设置/获取勾选状态（CheckState） |
| `setData(role: Int32, value: Int64)` / `data(role: Int32): Int64` | 设置/获取指定角色数据 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

**相关列表方法**（QListWidget 侧）:
| 方法 | 说明 |
|------|------|
| `addItem(text: String): Int64` | 添加项并返回项指针（可用 `fromPtr` 包装） |
| `takeItem(row: Int32): QListWidgetItem` | 移除指定行项（拥有所有权，用后 `delete()`） |

**常量**（ItemFlag 与 CheckState 同 QStandardItem，见下文数据模型章节）。

### QListView

基于模型/视图架构的列表控件，可绑定 `QStandardItemModel` 数据模型，支持图标模式、自动换行等特性。

```cangjie
import cjqt6.views.*

let model = QStandardItemModel(4, 1)
model.setItem(0, 0, "苹果")
model.setItem(1, 0, "香蕉")
model.setItem(2, 0, "橙子")

let listView = QListView()
listView.setModel(model)
listView.setSelectionMode(SelectionMode.Single)
listView.setEditTriggers(EditTrigger.NoEditTriggers)
listView.setWordWrap(true)
listView.setUniformItemSizes(true)
listView.show()
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建列表视图 |
| `setModel(model: QStandardItemModel)` | 绑定数据模型 |
| `setSelectionMode(mode: Int32)` / `selectionMode(): Int32` | 设置/获取选择模式 |
| `setEditTriggers(triggers: Int32)` / `editTriggers(): Int32` | 设置/获取编辑触发方式 |
| `setViewMode(mode: Int32)` / `viewMode(): Int32` | 设置/获取视图模式（列表/图标） |
| `setMovement(movement: Int32)` / `movement(): Int32` | 设置/获取项移动方式 |
| `setFlow(flow: Int32)` / `flow(): Int32` | 设置/获取排列方向 |
| `setWrapping(wrapping: Bool)` / `isWrapping(): Bool` | 设置/获取是否换行排列 |
| `setSpacing(spacing: Int32)` / `spacing(): Int32` | 设置/获取项间距 |
| `setResizeMode(mode: Int32)` / `resizeMode(): Int32` | 设置/获取调整大小模式 |
| `setWordWrap(wordWrap: Bool)` / `isWordWrap(): Bool` | 设置/获取自动换行 |
| `setUniformItemSizes(uniform: Bool)` / `uniformItemSizes(): Bool` | 设置/获取统一项尺寸 |
| `setCurrentIndex(index: QModelIndex)` / `setCurrentIndex(indexPtr: Int64)` / `currentIndex(): Int64` | 设置/获取当前索引 |
| `setRootIndex(index: QModelIndex)` / `setRootIndex(indexPtr: Int64)` / `rootIndex(): Int64` | 设置/获取根索引 |
| `setOnClicked(callback)` / `setOnDoubleClicked(callback)` / `setOnActivated(callback)` / `setOnPressed(callback)` | 信号回调（传入 QModelIndex 句柄） |
| `show()` / `hide()` / `resize(width, height)` / `setEnabled(enabled)` / `setStyleSheet(style)` | 基础控件行为 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

**常量**:
```cangjie
SelectionMode.NoSelection
SelectionMode.Single
SelectionMode.Multi
SelectionMode.Extended

EditTrigger.NoEditTriggers
EditTrigger.CurrentChanged
EditTrigger.DoubleClicked
EditTrigger.SelectedClicked
EditTrigger.EditKeyPressed
EditTrigger.AnyKeyPressed
EditTrigger.AllEditTriggers
```

---

## 树形控件

### QTreeWidget

```cangjie
import cjqt6.views.*

let treeWidget = QTreeWidget()
treeWidget.setColumnCount(3)
treeWidget.setHeaderLabel(0, "名称")
treeWidget.setHeaderLabel(1, "类型")
treeWidget.setHeaderLabel(2, "大小")

let root = treeWidget.addTopLevelItem("项目文件夹")
root.setText(1, "文件夹")
root.setText(2, "-")

let child = root.addChild("src")
child.setText(1, "文件夹")

let file = child.addChild("main.cj")
file.setText(1, "源码")
file.setText(2, "2KB")

treeWidget.expandAll()
```

**QTreeWidget 当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建树控件 |
| `setColumnCount(columns: Int32)` / `columnCount(): Int32` | 设置/获取列数 |
| `setHeaderLabel(column: Int32, label: String)` / `setHeaderHidden(hidden: Bool)` | 设置表头标签/隐藏表头 |
| `addTopLevelItem(text: String): QTreeWidgetItem` / `insertTopLevelItem(index: Int32, item: QTreeWidgetItem)` | 添加/插入顶级项 |
| `takeTopLevelItem(index: Int32)` / `topLevelItemCount(): Int32` / `topLevelItem(index: Int32): QTreeWidgetItem` | 删除/计数/获取顶级项 |
| `currentItem(): ?QTreeWidgetItem` / `setCurrentItem(item: QTreeWidgetItem)` | 获取/设置当前选中项 |
| `expandItem(item: QTreeWidgetItem)` / `collapseItem(item: QTreeWidgetItem)` / `expandAll()` / `collapseAll()` | 展开/折叠项 |
| `setSelectionMode(mode: Int32)` | 设置选择模式 |
| `setOnItemClicked(callback)` / `setOnItemDoubleClicked(callback)` / `setOnItemExpanded(callback)` / `setOnItemCollapsed(callback)` / `setOnCurrentItemChanged(callback)` | 事件回调 |
| `setOnItemClickedWithColumn(callback)` / `setOnItemDoubleClickedWithColumn(callback)` / `setOnItemChanged(callback)` | 带列号的事件回调 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

### QTreeWidgetItem

```cangjie
let item = QTreeWidgetItem("节点名称")
item.setText(1, "附加信息")
let child = item.addChild("子节点")
let parent = item.parent()
item.setData(0, 12345)
let data = item.getData(0)
```

**QTreeWidgetItem 当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` / `init(text: String)` | 创建空项或带文本项 |
| `setText(column: Int32, text: String)` / `text(column: Int32): String` | 设置/获取列文本 |
| `addChild(text: String): QTreeWidgetItem` / `addChildItem(child: QTreeWidgetItem)` | 添加子项 |
| `childCount(): Int32` / `child(index: Int32): QTreeWidgetItem` / `takeChild(index: Int32)` | 子项计数/获取/移除 |
| `parent(): ?QTreeWidgetItem` | 获取父项 |
| `setData(column: Int32, data: Int64)` / `getData(column: Int32): Int64` | 设置/获取用户数据 |
| `setExpanded(expanded: Bool)` / `isExpanded(): Bool` | 设置/获取展开状态 |
| `setCheckState(column: Int32, state: Int32)` / `checkState(column: Int32): Int32` | 设置/获取勾选状态 |
| `setSelected(selected: Bool)` / `isSelected(): Bool` | 设置/获取是否选中 |
| `setHidden(hidden: Bool)` / `isHidden(): Bool` | 设置/获取是否隐藏 |
| `getPtr(): Int64` | 获取内部指针 |

**勾选状态常量**:
```cangjie
CheckState.Unchecked
CheckState.PartiallyChecked
CheckState.Checked
```

---

### QTreeView

基于模型/视图架构的树形控件，可绑定 `QStandardItemModel` 数据模型。

```cangjie
import cjqt6.views.*

let model = QStandardItemModel()
model.setColumnCount(2)
model.setHorizontalHeaderLabel(0, "名称")
model.setHorizontalHeaderLabel(1, "类型")

let treeView = QTreeView()
treeView.setModel(model)
treeView.expandAll()
treeView.setHeaderHidden(false)
treeView.setAnimated(true)
treeView.setUniformRowHeights(true)
treeView.show()
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建树形视图 |
| `setModel(model: QStandardItemModel)` | 绑定数据模型 |
| `expandAll()` / `collapseAll()` | 展开/折叠全部 |
| `expand(index: QModelIndex)` / `collapse(index: QModelIndex)` / `isExpanded(index: QModelIndex): Bool` | 展开/折叠/查询指定索引 |
| `setSelectionMode(mode: Int32)` | 设置选择模式 |
| `setHeaderHidden(hidden: Bool)` / `isHeaderHidden(): Bool` | 设置/获取表头隐藏 |
| `setEditTriggers(triggers: Int32)` / `editTriggers(): Int32` | 设置/获取编辑触发方式 |
| `isSortingEnabled(): Bool` | 是否启用排序 |
| `setAnimated(animated: Bool)` / `isAnimated(): Bool` | 设置/获取动画效果 |
| `setUniformRowHeights(uniform: Bool)` / `uniformRowHeights(): Bool` | 设置/获取统一行高 |
| `setItemsExpandable(expandable: Bool)` / `itemsExpandable(): Bool` | 设置/获取项可展开 |
| `setRootIsDecorated(decorated: Bool)` / `rootIsDecorated(): Bool` | 设置/获取根节点装饰 |
| `setExpandsOnDoubleClick(expands: Bool)` / `expandsOnDoubleClick(): Bool` | 设置/获取双击展开 |
| `setColumnWidth(col: Int32, width: Int32)` | 设置列宽 |
| `setHeader(header: QHeaderView)` | 设置自定义表头 |
| `setCurrentIndex(index: QModelIndex)` / `currentIndex(): Int64` | 设置/获取当前索引 |
| `setRootIndex(index: QModelIndex)` / `rootIndex(): Int64` | 设置/获取根索引 |
| `setOnClicked(callback)` / `setOnDoubleClicked(callback)` / `setOnActivated(callback)` | 点击/双击/激活回调（传入 QModelIndex 句柄） |
| `setOnExpanded(callback)` / `setOnCollapsed(callback)` | 展开/折叠回调（传入 QModelIndex 句柄） |
| `show()` / `hide()` / `resize(width, height)` / `setEnabled(enabled)` / `setStyleSheet(style)` | 基础控件行为 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

**常量**（选择模式与编辑触发同 QListView，见上文）:
```cangjie
SelectionMode.NoSelection
SelectionMode.Single
SelectionMode.Multi
SelectionMode.Extended
EditTrigger.NoEditTriggers
EditTrigger.DoubleClicked
EditTrigger.AllEditTriggers
```

---

### QHeaderView

表头视图控件，可单独创建后通过 `QTableView.setHorizontalHeader()` / `QTreeView.setHeader()` 绑定。

```cangjie
import cjqt6.views.*

let header = QHeaderView(Orientation.Horizontal)
header.setStretchLastSection(true)
header.setSectionResizeMode(ResizeMode.Stretch)
header.setSectionResizeMode(0, ResizeMode.Fixed)
header.setSectionsClickable(true)
header.setSortIndicatorShown(true)

let table = QTableView()
table.setHorizontalHeader(header)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init(orientation: Int32)` | 创建表头（Horizontal/Vertical） |
| `setStretchLastSection(stretch: Bool)` / `isStretchLastSection(): Bool` | 设置/获取末节拉伸 |
| `setSectionResizeMode(mode: Int32)` / `setSectionResizeMode(index: Int32, mode: Int32)` | 设置全部/指定节调整模式 |
| `setVisible(visible: Bool)` | 设置可见性 |
| `setDefaultSectionSize(size: Int32)` / `defaultSectionSize(): Int32` | 设置/获取默认节尺寸 |
| `setMinimumSectionSize(size: Int32)` / `minimumSectionSize(): Int32` | 设置/获取最小节尺寸 |
| `setSortIndicatorShown(shown: Bool)` / `isSortIndicatorShown(): Bool` | 设置/获取排序指示器 |
| `setSectionsClickable(clickable: Bool)` / `isSectionsClickable(): Bool` | 设置/获取节可点击 |
| `setHighlightSections(highlight: Bool)` / `isHighlightSections(): Bool` | 设置/获取节高亮 |
| `setCascadingSectionResizes(cascading: Bool)` / `isCascadingSectionResizes(): Bool` | 设置/获取级联调整 |
| `resizeSection(index: Int32, size: Int32)` / `sectionSize(index: Int32): Int32` | 调整/获取指定节尺寸 |
| `setSectionHidden(index: Int32, hidden: Bool)` / `isSectionHidden(index: Int32): Bool` | 设置/获取节隐藏 |
| `count(): Int32` / `length(): Int32` | 节数量/总长度 |
| `logicalIndex(visual: Int32): Int32` / `visualIndex(logical: Int32): Int32` | 视觉/逻辑索引互转 |
| `setOffset(offset: Int32)` / `offset(): Int32` | 设置/获取偏移 |
| `moveSection(from: Int32, to: Int32)` / `swapSections(one: Int32, two: Int32)` | 移动/交换节 |
| `setDefaultAlignment(alignment: Int32)` | 设置默认对齐方式 |
| `setOnSectionClicked(callback: Int32Callback)` / `setOnSectionDoubleClicked(callback: Int32Callback)` / `setOnSectionHandleDoubleClicked(callback: Int32Callback)` | 节点击相关回调（传节索引） |
| `setOnSectionResized(callback: CFunc<(Int32, Int32, Int32) -> Unit>)` / `setOnSectionMoved(callback: CFunc<(Int32, Int32, Int32) -> Unit>)` | 节尺寸变化/移动回调（传逻辑索引、旧值、新值） |
| `setOnSortIndicatorChanged(callback: Int32Int32Callback)` | 排序指示器变化回调（传节索引、顺序） |
| `show()` / `hide()` / `resize(width, height)` / `setEnabled(enabled)` / `setStyleSheet(style)` | 基础控件行为 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

**常量**:
```cangjie
Orientation.Horizontal
Orientation.Vertical

ResizeMode.Interactive
ResizeMode.Stretch
ResizeMode.Fixed
ResizeMode.ResizeToContents
```

---

## QSortFilterProxyModel — 排序过滤代理模型

为视图提供排序和过滤功能。

```cangjie
import cjqt6.views.*

// 创建代理模型
let proxyModel = QSortFilterProxyModel()

// 设置源模型（如 QStandardItemModel 的指针）
proxyModel.setSourceModel(sourceModelPtr)

// 设置过滤器
proxyModel.setFilterRegularExpression("关键词")
proxyModel.setFilterKeyColumn(0)      // 按第0列过滤
proxyModel.setFilterCaseSensitivity(CaseSensitivity.insensitive())  // 不区分大小写

// 设置排序
proxyModel.sort(0, SortOrder.ascending())   // 按第0列升序排序
proxyModel.setDynamicSortFilter(true)        // 自动排序

// 刷新过滤器
proxyModel.invalidate()

// 映射索引
let sourceIndex = proxyModel.mapToSource(proxyRow, proxyCol)

proxyModel.delete()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建代理模型 |
| `setSourceModel(modelPtr: Int64)` | 设置源模型 |
| `setFilterRegularExpression(pattern: String)` | 设置正则表达式过滤器 |
| `setFilterFixedString(pattern: String)` | 设置固定字符串过滤器 |
| `setFilterWildcard(pattern: String)` | 设置通配符过滤器 |
| `setFilterKeyColumn(col: Int32)` | 设置过滤的列 |
| `filterKeyColumn(): Int32` | 获取过滤的列 |
| `setFilterRole(role: Int32)` | 设置过滤角色 |
| `filterRole(): Int32` | 获取过滤角色 |
| `setSortRole(role: Int32)` | 设置排序角色 |
| `sortRole(): Int32` | 获取排序角色 |
| `setDynamicSortFilter(enable: Bool)` | 设置动态排序 |
| `dynamicSortFilter(): Bool` | 是否动态排序 |
| `sort(column: Int32, order: Int32)` | 执行排序 |
| `sortOrder(): Int32` | 获取排序顺序 |
| `mapToSource(proxyRow: Int32, proxyCol: Int32): Int64` | 映射到源模型索引 |
| `mapFromSource(sourceRow: Int32, sourceCol: Int32, sourceModelPtr: Int64): Int64` | 从源模型映射 |
| `setFilterCaseSensitivity(cs: Int32)` | 设置过滤大小写敏感 |
| `filterCaseSensitivity(): Int32` | 获取过滤大小写敏感 |
| `invalidate()` | 刷新过滤器 |
| `rowCount(): Int32` | 获取行数 |
| `columnCount(): Int32` | 获取列数 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

**排序顺序常量** (`SortOrder`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `SortOrder.ascending()` | 0 | 升序 |
| `SortOrder.descending()` | 1 | 降序 |

**大小写敏感常量** (`CaseSensitivity`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `CaseSensitivity.insensitive()` | 0 | 不区分大小写 |
| `CaseSensitivity.sensitive()` | 1 | 区分大小写 |

---

## 数据模型

### QStandardItemModel — 标准项模型

通用二维表格数据模型，可绑定到 QTableView / QListView / QTreeView。

```cangjie
import cjqt6.views.*

let model = QStandardItemModel(3, 2)
model.setItem(0, 0, "张三")
model.setItem(0, 1, "25")
model.setHorizontalHeaderLabel(0, "姓名")
model.setHorizontalHeaderLabel(1, "年龄")

let item = QStandardItem("李四")
item.setForeground(255, 0, 0)
item.setCheckState(CheckState.Checked)
model.appendRow(item)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` / `init(rows: Int32, cols: Int32)` | 创建空模型或指定大小模型 |
| `setRowCount(rows: Int32)` / `rowCount(): Int32` | 设置/获取行数 |
| `setColumnCount(cols: Int32)` / `columnCount(): Int32` | 设置/获取列数 |
| `setItem(row: Int32, col: Int32, text: String)` / `itemText(row: Int32, col: Int32): String` | 设置/获取单元格文本 |
| `setItem(row: Int32, col: Int32, item: QStandardItem)` / `item(row: Int32, col: Int32): QStandardItem` | 设置/获取单元格项 |
| `setHorizontalHeaderLabel(col: Int32, label: String)` / `setVerticalHeaderLabel(row: Int32, label: String)` | 设置横向/纵向表头文本 |
| `setHorizontalHeaderItem(col: Int32, item: QStandardItem)` / `setVerticalHeaderItem(row: Int32, item: QStandardItem)` | 设置表头项 |
| `setHeaderData(section: Int32, orientation: Int32, value: Int64, role: Int32): Bool` | 设置表头数据 |
| `insertRow(row: Int32)` / `insertRow(row: Int32, item: QStandardItem)` / `appendRow(item: QStandardItem)` | 插入/追加行 |
| `removeRow(row: Int32)` / `insertColumn(col: Int32)` / `removeColumn(col: Int32)` | 删除行/插入删除列 |
| `setItemEnabled(row: Int32, col: Int32, enabled: Bool)` | 设置项可用性 |
| `setItemCheckable(row: Int32, col: Int32, checkable: Bool)` / `setItemChecked(row: Int32, col: Int32, checked: Bool)` / `isItemChecked(row: Int32, col: Int32): Bool` | 项勾选相关 |
| `findItems(text: String, flags: Int32): Int32` | 查找匹配项数量 |
| `itemFromIndex(index: QModelIndex): QStandardItem` | 由索引获取项 |
| `indexFromItem(item: QStandardItem): Int64` | 由项获取索引句柄 |
| `clear()` | 清空模型 |
| `show()` / `hide()` / `resize(width, height)` / `setEnabled(enabled)` / `setStyleSheet(style)` | 基础控件行为 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

### QStandardItem — 标准项

```cangjie
let item = QStandardItem("名称")
item.setText("新名称")
item.setForeground(255, 0, 0)
item.setFlags(ItemFlag.ItemIsSelectable | ItemFlag.ItemIsEnabled)
item.setCheckState(CheckState.Checked)
item.setData(ItemDataRole.sizeHintRole(), 100)
let child = QStandardItem("子项")
item.appendRow(child)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` / `init(text: String)` | 创建空项或带文本项 |
| `fromPtr(ptr: Int64): QStandardItem` | 由模型返回的指针构造（不拥有所有权） |
| `text(): String` / `setText(text: String)` | 获取/设置文本 |
| `setFlags(flags: Int32)` / `flags(): Int32` | 设置/获取项标志 |
| `setCheckState(state: Int32)` / `checkState(): Int32` | 设置/获取勾选状态 |
| `setData(role: Int32, value: Int64)` / `data(role: Int32): Int64` | 设置/获取指定角色数据 |
| `setEditable(editable: Bool)` / `isEditable(): Bool` | 设置/获取是否可编辑 |
| `appendRow(child: QStandardItem)` | 添加子项 |
| `setForeground(r: Int32, g: Int32, b: Int32)` | 设置前景色（RGB） |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

**通用常量**:
```cangjie
SelectionMode.NoSelection
SelectionMode.Single
SelectionMode.Multi
SelectionMode.Extended

ItemFlag.NoItemFlags
ItemFlag.ItemIsSelectable
ItemFlag.ItemIsEditable
ItemFlag.ItemIsDragEnabled
ItemFlag.ItemIsDropEnabled
ItemFlag.ItemIsUserCheckable
ItemFlag.ItemIsEnabled
ItemFlag.ItemIsTristate

CheckState.Unchecked
CheckState.PartiallyChecked
CheckState.Checked
```

---

### QAbstractItemModel — 回调式自定义模型

基于回调机制的自定义模型基类。注册各虚方法回调后，将 `getPtr()` 设置到视图控件即可驱动视图显示。

```cangjie
import cjqt6.views.*

let model = QAbstractItemModel()

// 行数/列数回调 (modelPtr, parentPtr) -> 数量
model.setOnRowCount(CFunc<(Int64, Int64) -> Int32> { _, _ => 3 })
model.setOnColumnCount(CFunc<(Int64, Int64) -> Int32> { _, _ => 2 })

// 索引回调 (modelPtr, row, col, parentPtr) -> 内部ID（非零，供 dataChanged 建索引）
model.setOnIndex(CFunc<(Int64, Int32, Int32, Int64) -> Int64> { _, row, col, _ => Int64(row * 2 + col + 1) })

// 数据回调 (modelPtr, indexPtr, role) -> 字符串指针或0
model.setOnData(CFunc<(Int64, Int64, Int32) -> Int64> { _, _, _ => 0 })

// 表头回调 (modelPtr, section, orientation, role) -> 字符串指针或0
model.setOnHeaderData(CFunc<(Int64, Int32, Int32, Int32) -> Int64> { _, _, _, _ => 0 })

// P1：自定义模型可直接传给 QTableView.setModel(model) 驱动实时数据表
let table = QTableView()
table.setModel(model)

// 数据变化时通知视图刷新
// - 局部刷新：只更新 (0,0) 到 (2,1) 围成的矩形区域，避免整表 reset
model.notifyDataChanged(0, 0, 2, 1)
// - 布局变化（行/列顺序调整等）通知视图重排
model.notifyLayoutChanged()
// - 全量重置
model.beginResetModel()
// ... 更新内部数据 ...
model.endResetModel()
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建自定义模型 |
| `setOnRowCount(callback: CFunc<(Int64, Int64) -> Int32>)` | 设置行数回调 |
| `setOnColumnCount(callback: CFunc<(Int64, Int64) -> Int32>)` | 设置列数回调 |
| `setOnIndex(callback: CFunc<(Int64, Int32, Int32, Int64) -> Int64>)` | 设置索引回调 |
| `setOnParent(callback: CFunc<(Int64, Int64) -> Int64>)` | 设置父项回调 |
| `setOnData(callback: CFunc<(Int64, Int64, Int32) -> Int64>)` | 设置数据回调 |
| `setOnHeaderData(callback: CFunc<(Int64, Int32, Int32, Int32) -> Int64>)` | 设置表头数据回调 |
| `setOnFlags(callback: CFunc<(Int64, Int64) -> Int32>)` | 设置项标志回调 |
| `beginResetModel()` / `endResetModel()` | 模型重置通知 |
| `beginInsertRows(first: Int32, last: Int32)` / `endInsertRows()` | 插入行通知 |
| `beginRemoveRows(first: Int32, last: Int32)` / `endRemoveRows()` | 移除行通知 |
| `notifyDataChanged(topLeftRow: Int32, topLeftCol: Int32, bottomRightRow: Int32, bottomRightCol: Int32)` | 局部数据更新通知（P1：视图只刷新该矩形区域，避免整表 reset） |
| `notifyLayoutChanged()` | 布局变化通知（P1：行/列顺序调整后让视图重排） |
| `getPtr(): Int64` / `close()` | 获取指针与释放资源 |

**数据角色常量** (`ItemDataRole`，均为函数调用形式):
| 常量 | 值 | 说明 |
|------|-----|------|
| `ItemDataRole.displayRole()` | 0 | 显示文本 |
| `ItemDataRole.decorationRole()` | 1 | 装饰（图标） |
| `ItemDataRole.editRole()` | 2 | 编辑数据 |
| `ItemDataRole.toolTipRole()` | 3 | 提示文本 |
| `ItemDataRole.statusTipRole()` | 4 | 状态栏提示 |
| `ItemDataRole.whatsThisRole()` | 5 | "这是什么"帮助 |
| `ItemDataRole.fontRole()` | 6 | 字体 |
| `ItemDataRole.textAlignmentRole()` | 7 | 文本对齐 |
| `ItemDataRole.backgroundRole()` | 8 | 背景画刷 |
| `ItemDataRole.foregroundRole()` | 9 | 前景画刷 |
| `ItemDataRole.checkStateRole()` | 10 | 勾选状态 |
| `ItemDataRole.sizeHintRole()` | 11 | 尺寸提示 |

---

### QStyledItemDelegate — 自绘委托（回调式）

自定义单元格绘制（`paint`）与尺寸（`sizeHint`）的委托。注册回调后，将 `getPtr()` 通过视图的 `setItemDelegate` 挂载到 QTableView / QListView / QTreeView。

```cangjie
import cjqt6.views.*
import cjqt6.paint.*

// CFunc 回调不捕获局部变量，用全局变量共享委托引用
var gDelegate: ?QStyledItemDelegate = None

// 自绘回调：(delegatePtr) -> Unit，绘制上下文经 getter 读取（仅回调内有效）
let paintCb: DelegatePaintCallback = { delegatePtr =>
    if (let Some(d) <- gDelegate) {
        // 借自 Qt 的 QPainter，勿对其 delete()/end()
        let painter = QPainter.fromPtr(d.getPainterPtr())
        let x = d.getRectX()
        let y = d.getRectY()
        let w = d.getRectW()
        let h = d.getRectH()
        // 自由绘制：示例绘制单元格文本（也可用 drawRect/setPenColor 等画背景/边框）
        painter.drawText(x + 4, y + 20, "第${d.getRow()}行")
    }
}

// 尺寸回调：(delegatePtr) -> Int64，返回 makeSizeHintValue(w, h)
let sizeHintCb: DelegateSizeHintCallback = { _ =>
    makeSizeHintValue(120, 36)
}

// 挂载使用
let view = QTableView()
let model = QStandardItemModel(4, 2)
view.setModel(model)

let delegate = QStyledItemDelegate()
delegate.setOnPaint(paintCb)
delegate.setOnSizeHint(sizeHintCb)
gDelegate = Some(delegate)
view.setItemDelegate(delegate)   // 挂载后视图接管委托所有权，delegate 无需手动 close()
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建自绘委托 |
| `setOnPaint(callback: DelegatePaintCallback)` | 注册自绘回调；注册后该委托的单元格绘制完全由回调接管 |
| `setOnSizeHint(callback: DelegateSizeHintCallback)` | 注册自定义尺寸回调；返回 0 表示使用默认尺寸 |
| `getPainterPtr(): Int64` | 当前 QPainter 指针（**仅 paint 回调内有效**，用 `QPainter.fromPtr` 包装绘制） |
| `getRectX()` / `getRectY()` / `getRectW()` / `getRectH(): Int32` | 当前单元格绘制矩形（**仅回调内有效**） |
| `getState(): Int32` | 当前绘制状态位标志（见 PaintState，**仅回调内有效**） |
| `getRow(): Int32` / `getCol(): Int32` | 当前单元格行/列号（**仅回调内有效**） |
| `setOnCreateEditor(callback: DelegateCreateEditorCallback)` | 注册创建编辑器回调；双击单元格时调用，返回编辑器 widget 指针（0 表示不编辑） |
| `setOnSetEditorData(callback: DelegateSetEditorDataCallback)` | 注册设置编辑器数据回调；编辑器打开后从 model 取数据填入编辑器 |
| `setOnSetModelData(callback: DelegateSetModelDataCallback)` | 注册设置模型数据回调；编辑完成时从编辑器取数据写回 model |
| `getParentPtr(): Int64` | 父 widget 指针（**仅 createEditor 回调内有效**，用于创建编辑器时指定父对象） |
| `getEditorPtr(): Int64` | 当前编辑器指针（**仅 setEditorData/setModelData 回调内有效**） |
| `getModelPtr(): Int64` | 当前 model 指针（**仅 setModelData 回调内有效**） |
| `getPtr(): Int64` / `close()` | 获取指针与释放资源 |

**回调类型别名**:
```cangjie
DelegatePaintCallback = CFunc<(Int64) -> Unit>      // 自绘回调，入参为委托指针
DelegateSizeHintCallback = CFunc<(Int64) -> Int64>  // 尺寸回调，返回打包尺寸
DelegateCreateEditorCallback = CFunc<(Int64) -> Int64>  // 创建编辑器，返回编辑器 widget 指针（0=不编辑）
DelegateSetEditorDataCallback = CFunc<(Int64) -> Unit>   // 从 model 取数据填入编辑器
DelegateSetModelDataCallback = CFunc<(Int64) -> Unit>    // 从编辑器取数据写回 model
```

**绘制状态常量** (`PaintState`，均为函数调用形式，值对齐 Qt6 `QStyle::StateFlag`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `PaintState.selected()` | 0x8000 | 被选中（State_Selected） |
| `PaintState.mouseOver()` | 0x2000 | 鼠标悬浮（State_MouseOver） |
| `PaintState.hasFocus()` | 0x0100 | 拥有焦点（State_HasFocus） |
| `PaintState.active()` | 0x10000 | 激活状态（State_Active） |
| `PaintState.has(state, flag)` | Bool | 判断是否包含某状态位 |

**尺寸打包函数**:
```cangjie
makeSizeHintValue(width: Int32, height: Int32): Int64  // 高 32 位 = 高度，低 32 位 = 宽度
```

**注意事项**:
- 绘制上下文 getter（`getPainterPtr()` / `getRect*()` / `getState()` / `getRow()` / `getCol()`）**仅在回调执行期间有效**，退出回调后为脏数据，勿在回调外读取。
- 挂载到视图后（`setItemDelegate`），视图接管委托所有权并在视图析构时级联释放；此时 `close()` 仅标记关闭、不主动删除，避免 double-free。未挂载的委托由 `close()` 显式释放。
- `QPainter.fromPtr` 包装的 painter 借自 Qt，**不要调用 `delete()`/`end()`**，其生命周期由 Qt 管理。
- 编辑委托（`createEditor`/`setEditorData`/`setModelData`）为可选覆盖：未注册回调时走 `QStyledItemDelegate` 默认实现（创建 QLineEdit、自动读写 model 数据）。注册回调后完全由仓颉侧接管，可用于自定义编辑器（如 QComboBox/QSpinBox）。
- `createEditor` 回调返回的编辑器 widget 所有权归视图，视图在编辑结束时自动释放，**勿在仓颉侧重复 `close()`**。
- 编辑上下文 getter（`getParentPtr()`/`getEditorPtr()`/`getModelPtr()`）**仅在对应编辑回调内有效**，回调外为脏数据。

---

### QFileSystemModel — 文件系统模型

直接读取本地文件系统目录结构，可绑定到 QTreeView / QListView 显示文件目录树。

```cangjie
import cjqt6.views.*

let fsModel = QFileSystemModel()
fsModel.setRootPath("C:/")
fsModel.setNameFilters(["*.cj", "*.md"])
fsModel.setReadOnly(true)

// 获取目录索引句柄
let indexPtr = fsModel.index("C:/")
if (indexPtr != 0) {
    let index = QModelIndex(indexPtr)
    println(fsModel.fileName(index))
    println(fsModel.isDir(index))
    index.delete()
}

// 注意：当前源码中视图的 setModel() 仅接受 QStandardItemModel 类型，
// 文件系统模型需自行封装转换后使用
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建文件系统模型 |
| `setRootPath(path: String)` / `rootPath(): String` | 设置/获取根路径 |
| `index(path: String): Int64` | 由路径获取索引句柄（包装为 QModelIndex 使用） |
| `setNameFilters(filters: Array<String>)` | 设置文件名过滤器 |
| `setFilter(filter: Int32)` | 设置过滤选项 |
| `setReadOnly(readOnly: Bool)` / `isReadOnly(): Bool` | 设置/获取只读 |
| `setNameFilterDisables(disables: Bool)` | 设置过滤器是否禁用不匹配文件 |
| `setResolveSymlinks(resolve: Bool)` / `isResolveSymlinks(): Bool` | 设置/获取解析符号链接 |
| `filePath(index: QModelIndex): String` | 获取索引对应完整路径 |
| `fileName(index: QModelIndex): String` | 获取索引对应文件名 |
| `isDir(index: QModelIndex): Bool` | 判断索引是否为目录 |
| `setOnDirectoryLoaded(callback: CStringCallback)` | 目录加载完成回调 |
| `setOnRootPathChanged(callback: CStringCallback)` | 根路径变化回调 |
| `show()` / `hide()` / `resize(width, height)` / `setEnabled(enabled)` / `setStyleSheet(style)` | 基础控件行为 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

---

### QModelIndex — 索引句柄

封装由 C++ 侧以 `QPersistentModelIndex*` 堆分配的索引，用于视图与模型之间定位数据项。

```cangjie
// 视图信号回调中接收索引句柄
let table = QTableView()
table.setOnClicked(Int64Callback { indexPtr =>
    let index = QModelIndex(indexPtr)
    println("row=" + index.row() + " col=" + index.column())
    // 回调内索引由 C++ 侧释放，不要调用 delete()
})

// currentIndex()/rootIndex() 返回的句柄需手动释放
let indexPtr = table.currentIndex()
let index = QModelIndex(indexPtr)
if (index.isValid()) {
    // 使用 index...
}
index.delete()
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init(ptr: Int64)` | 由句柄包装索引 |
| `row(): Int32` | 获取行号 |
| `column(): Int32` | 获取列号 |
| `isValid(): Bool` | 索引是否有效 |
| `delete()` | 释放句柄（仅用于 currentIndex()/rootIndex() 等返回的句柄） |

**注意事项**:
- 信号回调内传入的索引句柄仅在回调期间有效，离开回调后由 C++ 侧释放，**不要再次 delete()**
- `currentIndex()` / `rootIndex()` 返回的句柄需调用 `delete()` 释放
