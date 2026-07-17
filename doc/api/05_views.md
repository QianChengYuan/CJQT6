# CJQT6 视图控件模块

本模块包含表格、列表、树形控件。

## 表格控件

### QTableWidget

```cangjie
import cjqt6.views.*

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
import cjqt6.views.*

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
import cjqt6.views.*

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
