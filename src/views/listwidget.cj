package CJQT6.views

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
foreign func qListWidgetSetCheckable(ptr: Int64, row: Int32, checkable: Bool): Unit
foreign func qListWidgetIsChecked(ptr: Int64, row: Int32): Int32
foreign func qListWidgetSetChecked(ptr: Int64, row: Int32, checked: Bool): Unit

// 事件回调
foreign func qListWidgetSetOnItemClicked(ptr: Int64, callback: CFunc<(Int32) -> Unit>): Unit
foreign func qListWidgetSetOnItemDoubleClicked(ptr: Int64, callback: CFunc<(Int32) -> Unit>): Unit
foreign func qListWidgetSetOnCurrentRowChanged(ptr: Int64, callback: CFunc<(Int32) -> Unit>): Unit

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
}
