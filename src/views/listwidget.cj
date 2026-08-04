package cjqt6.views

import cjqt6.paint.*

// ============================================================
// QListWidget FFI声明
// ============================================================

foreign func qListWidgetCreate(): Int64
foreign func qListWidgetDelete(ptr: Int64): Unit

foreign func qListWidgetAddItem(ptr: Int64, text: CString): Int64
foreign func qListWidgetInsertItem(ptr: Int64, row: Int32, text: CString): Unit
foreign func qListWidgetRemoveItem(ptr: Int64, row: Int32): Unit
foreign func qListWidgetClear(ptr: Int64): Unit
foreign func qListWidgetCount(ptr: Int64): Int32

foreign func qListWidgetCurrentRow(ptr: Int64): Int32
foreign func qListWidgetSetCurrentRow(ptr: Int64, row: Int32): Unit
foreign func qListWidgetCurrentItemText(ptr: Int64): CString

foreign func qListWidgetItemText(ptr: Int64, row: Int32): CString
foreign func qListWidgetSetItemText(ptr: Int64, row: Int32, text: CString): Unit

foreign func qListWidgetSetItemData(ptr: Int64, row: Int32, data: Int64): Unit
foreign func qListWidgetGetItemData(ptr: Int64, row: Int32): Int64

foreign func qListWidgetSetSelectionMode(ptr: Int64, mode: Int32): Unit
foreign func qListWidgetSetAlternatingRowColors(ptr: Int64, enable: Bool): Unit
foreign func qListWidgetSetSortingEnabled(ptr: Int64, enable: Bool): Unit

foreign func qListWidgetSetItemIcon(ptr: Int64, row: Int32, iconType: Int32): Unit
foreign func qListWidgetSetItemIconPixmap(ptr: Int64, row: Int32, pixmapPtr: Int64): Unit
foreign func qListWidgetSetCheckable(ptr: Int64, row: Int32, checkable: Bool): Unit
foreign func qListWidgetIsChecked(ptr: Int64, row: Int32): Int32
foreign func qListWidgetSetChecked(ptr: Int64, row: Int32, checked: Bool): Unit

// 事件回调
foreign func qListWidgetSetOnItemClicked(ptr: Int64, callback: CFunc<(Int32) -> Unit>): Unit
foreign func qListWidgetSetOnItemDoubleClicked(ptr: Int64, callback: CFunc<(Int32) -> Unit>): Unit
foreign func qListWidgetSetOnCurrentRowChanged(ptr: Int64, callback: CFunc<(Int32) -> Unit>): Unit

// 补充 API FFI
foreign func qListWidgetAddItems(ptr: Int64, items: CString): Unit
foreign func qListWidgetItem(ptr: Int64, row: Int32): Int64
foreign func qListWidgetTakeItem(ptr: Int64, row: Int32): Int64
foreign func qListWidgetRemoveItemWidget(ptr: Int64, itemPtr: Int64): Unit
foreign func qListWidgetSetCurrentItem(ptr: Int64, itemPtr: Int64): Unit
foreign func qListWidgetSetViewMode(ptr: Int64, v: Int32): Unit
foreign func qListWidgetConnectItemClicked(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit
foreign func qListWidgetConnectItemDoubleClicked(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit
foreign func qListWidgetConnectItemSelectionChanged(ptr: Int64, callback: CFunc<() -> Unit>): Unit
foreign func qListWidgetConnectCurrentItemChanged(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit

// QListWidgetItem 封装 FFI
foreign func qListWidgetItemCreate(): Int64
foreign func qListWidgetItemCreateWithText(text: CString): Int64
foreign func qListWidgetItemDelete(itemPtr: Int64): Unit
foreign func qListWidgetItemSetText(itemPtr: Int64, text: CString): Unit
foreign func qListWidgetItemGetText(itemPtr: Int64): CString
foreign func qListWidgetItemSetFlags(itemPtr: Int64, flags: Int32): Unit
foreign func qListWidgetItemFlags(itemPtr: Int64): Int32
foreign func qListWidgetItemSetCheckState(itemPtr: Int64, state: Int32): Unit
foreign func qListWidgetItemCheckState(itemPtr: Int64): Int32
foreign func qListWidgetItemSetData(itemPtr: Int64, role: Int32, value: Int64): Unit
foreign func qListWidgetItemData(itemPtr: Int64, role: Int32): Int64

// 选择模式常量
public class ListSelectionMode {
    public static let NoSelection: Int32 = 0        // 不可选择
    public static let SingleSelection: Int32 = 1    // 单选
    public static let MultiSelection: Int32 = 2     // 多选
    public static let ExtendedSelection: Int32 = 3  // 扩展选择 (Ctrl/Shift)
    public static let ContiguousSelection: Int32 = 4 // 连续选择
}

// 图标类型常量
public class ListIconType {
    public static let None: Int32 = 0       // 无图标
    public static let Folder: Int32 = 1     // 文件夹图标
    public static let File: Int32 = 2       // 文件图标
    public static let Warning: Int32 = 3    // 警告图标
    public static let Information: Int32 = 4 // 信息图标
    public static let Critical: Int32 = 5   // 错误图标
}

// ============================================================
// QListWidget - 列表部件
// ============================================================
public class QListWidget {
    private let ptr: Int64
    
    public init() {
        unsafe {
            ptr = qListWidgetCreate()
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qListWidgetDelete(ptr)
            }
        }
    }
    
    // ========== 项操作 ==========
    
    // 添加项，返回项索引
    public func addItem(text: String): Int64 {
        unsafe {
            var cstr = LibC.mallocCString(text)
            let itemPtr = qListWidgetAddItem(ptr, cstr)
            LibC.free(cstr)
            return itemPtr
        }
    }
    
    // 在指定位置插入项
    public func insertItem(row: Int32, text: String) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            qListWidgetInsertItem(ptr, row, cstr)
            LibC.free(cstr)
        }
    }
    
    // 移除指定行的项
    public func removeItem(row: Int32) {
        unsafe {
            qListWidgetRemoveItem(ptr, row)
        }
    }
    
    // 清空所有项
    public func clear() {
        unsafe {
            qListWidgetClear(ptr)
        }
    }
    
    // 获取项数量
    public func count(): Int32 {
        unsafe {
            qListWidgetCount(ptr)
        }
    }
    
    // ========== 当前选中 ==========
    
    // 获取当前选中行 (-1表示无选中)
    public func currentRow(): Int32 {
        unsafe {
            qListWidgetCurrentRow(ptr)
        }
    }
    
    // 设置当前选中行
    public func setCurrentRow(row: Int32) {
        unsafe {
            qListWidgetSetCurrentRow(ptr, row)
        }
    }
    
    // 获取当前选中项的文本
    public func currentItemText(): String {
        unsafe {
            let cstr = qListWidgetCurrentItemText(ptr)
            return cstr.toString()
        }
    }
    
    // ========== 项文本 ==========
    
    // 获取指定行的文本
    public func itemText(row: Int32): String {
        unsafe {
            let cstr = qListWidgetItemText(ptr, row)
            return cstr.toString()
        }
    }
    
    // 设置指定行的文本
    public func setItemText(row: Int32, text: String) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            qListWidgetSetItemText(ptr, row, cstr)
            LibC.free(cstr)
        }
    }
    
    // ========== 项数据 ==========
    
    // 设置项的用户数据
    public func setItemData(row: Int32, data: Int64) {
        unsafe {
            qListWidgetSetItemData(ptr, row, data)
        }
    }
    
    // 获取项的用户数据
    public func getItemData(row: Int32): Int64 {
        unsafe {
            qListWidgetGetItemData(ptr, row)
        }
    }
    
    // ========== 外观设置 ==========
    
    // 设置选择模式
    public func setSelectionMode(mode: Int32) {
        unsafe {
            qListWidgetSetSelectionMode(ptr, mode)
        }
    }
    
    // 设置交替行颜色
    public func setAlternatingRowColors(enable: Bool) {
        unsafe {
            qListWidgetSetAlternatingRowColors(ptr, enable)
        }
    }
    
    // 设置是否可排序
    public func setSortingEnabled(enable: Bool) {
        unsafe {
            qListWidgetSetSortingEnabled(ptr, enable)
        }
    }
    
    // ========== 图标 ==========
    
    // 设置项图标
    public func setItemIcon(row: Int32, iconType: Int32) {
        unsafe {
            qListWidgetSetItemIcon(ptr, row, iconType)
        }
    }

    // 设置自定义图像图标（pixmap），支持任意用户自定义图像
    public func setItemIconPixmap(row: Int32, pixmap: QPixmap) {
        unsafe {
            qListWidgetSetItemIconPixmap(ptr, row, pixmap.getPtr())
        }
    }
    
    // ========== 勾选 ==========
    
    // 设置项是否可勾选
    public func setItemCheckable(row: Int32, checkable: Bool) {
        unsafe {
            qListWidgetSetCheckable(ptr, row, checkable)
        }
    }
    
    // 获取项是否被勾选
    public func isChecked(row: Int32): Bool {
        unsafe {
            qListWidgetIsChecked(ptr, row) == 1
        }
    }
    
    // 设置项勾选状态
    public func setChecked(row: Int32, checked: Bool) {
        unsafe {
            qListWidgetSetChecked(ptr, row, checked)
        }
    }
    
    // ========== 事件回调 ==========
    
    // 设置项点击回调
    public func setOnItemClicked(callback: CFunc<(Int32) -> Unit>) {
        unsafe {
            qListWidgetSetOnItemClicked(ptr, callback)
        }
    }
    
    // 设置项双击回调
    public func setOnItemDoubleClicked(callback: CFunc<(Int32) -> Unit>) {
        unsafe {
            qListWidgetSetOnItemDoubleClicked(ptr, callback)
        }
    }
    
    // 设置当前行变化回调
    public func setOnCurrentRowChanged(callback: CFunc<(Int32) -> Unit>) {
        unsafe {
            qListWidgetSetOnCurrentRowChanged(ptr, callback)
        }
    }
    
    // ========== 批量项 API ==========

    public func addItems(items: Array<String>) {
        unsafe {
            var joined = ""
            for (i in 0..items.size) {
                if (i > 0) { joined += "\n" }
                joined += items[i]
            }
            let cstr = LibC.mallocCString(joined)
            qListWidgetAddItems(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func item(row: Int32): QListWidgetItem {
        unsafe {
            return QListWidgetItem.fromPtr(qListWidgetItem(ptr, row))
        }
    }

    public func takeItem(row: Int32): QListWidgetItem {
        unsafe {
            return QListWidgetItem.fromPtr(qListWidgetTakeItem(ptr, row))
        }
    }

    public func removeItemWidget(item: QListWidgetItem) {
        unsafe {
            qListWidgetRemoveItemWidget(ptr, item.getPtr())
        }
    }

    public func setCurrentItem(item: QListWidgetItem) {
        unsafe {
            qListWidgetSetCurrentItem(ptr, item.getPtr())
        }
    }

    public func setViewMode(mode: Int32) {
        unsafe {
            qListWidgetSetViewMode(ptr, mode)
        }
    }

    // 项指针形式点击回调（区别于已有的行号形式 setOnItemClicked）
    public func setOnItemClickedItem(callback: CFunc<(Int64) -> Unit>) {
        unsafe {
            qListWidgetConnectItemClicked(ptr, callback)
        }
    }

    public func setOnItemDoubleClickedItem(callback: CFunc<(Int64) -> Unit>) {
        unsafe {
            qListWidgetConnectItemDoubleClicked(ptr, callback)
        }
    }

    public func setOnItemSelectionChanged(callback: CFunc<() -> Unit>) {
        unsafe {
            qListWidgetConnectItemSelectionChanged(ptr, callback)
        }
    }

    public func setOnCurrentItemChanged(callback: CFunc<(Int64) -> Unit>) {
        unsafe {
            qListWidgetConnectCurrentItemChanged(ptr, callback)
        }
    }

    // ========== 继承自QWidget的方法 ==========
    
    public func show() {
        unsafe {
            qWidgetShow(ptr)
        }
    }
    
    public func hide() {
        unsafe {
            qWidgetHide(ptr)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }

    public func setMinimumSize(minw: Int32, minh: Int32) {
        unsafe {
            qWidgetSetMinimumSize(ptr, minw, minh)
        }
    }

    public func setMaximumSize(maxw: Int32, maxh: Int32) {
        unsafe {
            qWidgetSetMaximumSize(ptr, maxw, maxh)
        }
    }

    public func setStyleSheet(style: String) {
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
}

// 项标志（对应 Qt::ItemFlag 标志位，可位或组合）
public class ItemFlag {
    public static let NoItemFlags: Int32 = 0
    public static let ItemIsSelectable: Int32 = 1
    public static let ItemIsEditable: Int32 = 2
    public static let ItemIsDragEnabled: Int32 = 4
    public static let ItemIsDropEnabled: Int32 = 8
    public static let ItemIsUserCheckable: Int32 = 16
    public static let ItemIsEnabled: Int32 = 32
    public static let ItemIsTristate: Int32 = 64
}

// ============================================================
// QListWidgetItem 最小封装
// ============================================================
public class QListWidgetItem {
    private var ptr: Int64 = 0

    public init() {
        unsafe {
            ptr = qListWidgetItemCreate()
        }
    }

    public init(text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            ptr = qListWidgetItemCreateWithText(cstr)
            LibC.free(cstr)
        }
    }

    private init(ptr: Int64) {
        this.ptr = ptr
    }

    // 从控件返回的指针构造（不拥有所有权，调用方不应 delete）
    public static func fromPtr(ptr: Int64): QListWidgetItem {
        QListWidgetItem(ptr)
    }

    public func getPtr(): Int64 {
        ptr
    }

    public func text(): String {
        unsafe {
            let cstr = qListWidgetItemGetText(ptr)
            return cstr.toString()
        }
    }

    public func setText(text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qListWidgetItemSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func setFlags(flags: Int32): Unit {
        unsafe {
            qListWidgetItemSetFlags(ptr, flags)
        }
    }

    public func flags(): Int32 {
        unsafe {
            qListWidgetItemFlags(ptr)
        }
    }

    public func setCheckState(state: Int32): Unit {
        unsafe {
            qListWidgetItemSetCheckState(ptr, state)
        }
    }

    public func checkState(): Int32 {
        unsafe {
            qListWidgetItemCheckState(ptr)
        }
    }

    public func setData(role: Int32, value: Int64): Unit {
        unsafe {
            qListWidgetItemSetData(ptr, role, value)
        }
    }

    public func data(role: Int32): Int64 {
        unsafe {
            qListWidgetItemData(ptr, role)
        }
    }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qListWidgetItemDelete(ptr)
            }
            ptr = 0
        }
    }
}
