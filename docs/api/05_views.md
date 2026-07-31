# CJQT6 视图控件模块

本模块包含当前源码中已暴露的表格、列表、树形控件 API。

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
