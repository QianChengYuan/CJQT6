package cjqt6.views

// ============================================================
// QTableWidget - 表格控件 FFI声明
// ============================================================

foreign func qTableWidgetCreate(): Int64
foreign func qTableWidgetCreateWithSize(rows: Int32, cols: Int32): Int64
foreign func qTableWidgetSetRowCount(ptr: Int64, rows: Int32): Unit
foreign func qTableWidgetSetColumnCount(ptr: Int64, cols: Int32): Unit
foreign func qTableWidgetRowCount(ptr: Int64): Int32
foreign func qTableWidgetColumnCount(ptr: Int64): Int32
foreign func qTableWidgetSetHorizontalHeaderLabel(ptr: Int64, col: Int32, label: CString): Unit
foreign func qTableWidgetSetVerticalHeaderLabel(ptr: Int64, row: Int32, label: CString): Unit
foreign func qTableWidgetSetItem(ptr: Int64, row: Int32, col: Int32, text: CString): Unit
foreign func qTableWidgetItemText(ptr: Int64, row: Int32, col: Int32): CString
foreign func qTableWidgetClear(ptr: Int64): Unit
foreign func qTableWidgetClearContents(ptr: Int64): Unit
foreign func qTableWidgetInsertRow(ptr: Int64, row: Int32): Unit
foreign func qTableWidgetInsertColumn(ptr: Int64, col: Int32): Unit
foreign func qTableWidgetRemoveRow(ptr: Int64, row: Int32): Unit
foreign func qTableWidgetRemoveColumn(ptr: Int64, col: Int32): Unit
foreign func qTableWidgetCurrentRow(ptr: Int64): Int32
foreign func qTableWidgetCurrentColumn(ptr: Int64): Int32
foreign func qTableWidgetSetCurrentCell(ptr: Int64, row: Int32, col: Int32): Unit
foreign func qTableWidgetSetSelectionBehavior(ptr: Int64, behavior: Int32): Unit
foreign func qTableWidgetSetSelectionMode(ptr: Int64, mode: Int32): Unit
foreign func qTableWidgetSetShowGrid(ptr: Int64, show: Bool): Unit
foreign func qTableWidgetSetSortingEnabled(ptr: Int64, enabled: Bool): Unit
foreign func qTableWidgetSetAlternatingRowColors(ptr: Int64, enabled: Bool): Unit
foreign func qTableWidgetResizeColumnsToContents(ptr: Int64): Unit
foreign func qTableWidgetResizeRowsToContents(ptr: Int64): Unit
foreign func qTableWidgetSetColumnWidth(ptr: Int64, col: Int32, width: Int32): Unit
foreign func qTableWidgetSetRowHeight(ptr: Int64, row: Int32, height: Int32): Unit
foreign func qTableWidgetHorizontalHeaderSetStretchLastSection(ptr: Int64, stretch: Bool): Unit
foreign func qTableWidgetHorizontalHeaderSetSectionResizeMode(ptr: Int64, mode: Int32): Unit
foreign func qTableWidgetHorizontalHeaderSetSectionResizeModeColumn(ptr: Int64, col: Int32, mode: Int32): Unit
foreign func qTableWidgetVerticalHeaderSetStretchLastSection(ptr: Int64, stretch: Bool): Unit
foreign func qTableWidgetVerticalHeaderSetDefaultSectionSize(ptr: Int64, size: Int32): Unit
foreign func qTableWidgetDelete(ptr: Int64): Unit

// QWidget公共函数
foreign func qWidgetShow(ptr: Int64): Unit
foreign func qWidgetHide(ptr: Int64): Unit
foreign func qWidgetResize(ptr: Int64, width: Int32, height: Int32): Unit
foreign func qWidgetSetMinimumSize(ptr: Int64, minw: Int32, minh: Int32): Unit
foreign func qWidgetSetMaximumSize(ptr: Int64, maxw: Int32, maxh: Int32): Unit
foreign func qWidgetSetStyleSheet(ptr: Int64, styleSheet: CString): Unit

// ============================================================
// 选择行为常量
// ============================================================
public const SelectItems: Int32 = 0       // 选择项
public const SelectRows: Int32 = 1        // 选择行
public const SelectColumns: Int32 = 2     // 选择列

// ============================================================
// 选择模式常量
// ============================================================
public const NoSelection: Int32 = 0           // 不可选择
public const SingleSelection: Int32 = 1       // 单选
public const MultiSelection: Int32 = 2        // 多选
public const ExtendedSelection: Int32 = 3     // 扩展选择
public const ContiguousSelection: Int32 = 4   // 连续选择

// ============================================================
// 表头调整模式常量
// ============================================================
public const Interactive: Int32 = 0       // 用户可调整
public const Fixed: Int32 = 2             // 固定大小
public const Stretch: Int32 = 1           // 自动拉伸填充
public const ResizeToContents: Int32 = 3  // 根据内容调整

// ============================================================
// QTableWidget - 表格控件
// ============================================================
public class QTableWidget {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qTableWidgetCreate()
        }
    }
    
    public init(rows: Int32, cols: Int32) {
        unsafe {
            ptr = qTableWidgetCreateWithSize(rows, cols)
        }
    }
    
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

    /// 设置最小尺寸
    public func setMinimumSize(minw: Int32, minh: Int32) {
        unsafe {
            qWidgetSetMinimumSize(ptr, minw, minh)
        }
    }
    
    // 设置行列数
    public func setRowCount(rows: Int32) {
        unsafe {
            qTableWidgetSetRowCount(ptr, rows)
        }
    }
    
    public func setColumnCount(cols: Int32) {
        unsafe {
            qTableWidgetSetColumnCount(ptr, cols)
        }
    }
    
    public func rowCount(): Int32 {
        unsafe {
            qTableWidgetRowCount(ptr)
        }
    }
    
    public func columnCount(): Int32 {
        unsafe {
            qTableWidgetColumnCount(ptr)
        }
    }
    
    // 设置表头
    public func setHorizontalHeaderLabel(col: Int32, label: String) {
        unsafe {
            var cstr = LibC.mallocCString(label)
            qTableWidgetSetHorizontalHeaderLabel(ptr, col, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setVerticalHeaderLabel(row: Int32, label: String) {
        unsafe {
            var cstr = LibC.mallocCString(label)
            qTableWidgetSetVerticalHeaderLabel(ptr, row, cstr)
            LibC.free(cstr)
        }
    }
    
    // 设置单元格内容
    public func setItem(row: Int32, col: Int32, text: String) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            qTableWidgetSetItem(ptr, row, col, cstr)
            LibC.free(cstr)
        }
    }
    
    // 获取单元格内容
    public func itemText(row: Int32, col: Int32): String {
        unsafe {
            let cstr = qTableWidgetItemText(ptr, row, col)
            let result = cstr.toString()
            // 注意：cstr指向静态缓冲区，不要free
            return result
        }
    }
    
    // 清空
    public func clear() {
        unsafe {
            qTableWidgetClear(ptr)
        }
    }
    
    public func clearContents() {
        unsafe {
            qTableWidgetClearContents(ptr)
        }
    }
    
    // 插入行列
    public func insertRow(row: Int32) {
        unsafe {
            qTableWidgetInsertRow(ptr, row)
        }
    }
    
    public func insertColumn(col: Int32) {
        unsafe {
            qTableWidgetInsertColumn(ptr, col)
        }
    }
    
    // 删除行列
    public func removeRow(row: Int32) {
        unsafe {
            qTableWidgetRemoveRow(ptr, row)
        }
    }
    
    public func removeColumn(col: Int32) {
        unsafe {
            qTableWidgetRemoveColumn(ptr, col)
        }
    }
    
    // 当前选中
    public func currentRow(): Int32 {
        unsafe {
            qTableWidgetCurrentRow(ptr)
        }
    }
    
    public func currentColumn(): Int32 {
        unsafe {
            qTableWidgetCurrentColumn(ptr)
        }
    }
    
    public func setCurrentCell(row: Int32, col: Int32) {
        unsafe {
            qTableWidgetSetCurrentCell(ptr, row, col)
        }
    }
    
    // 选择设置
    public func setSelectionBehavior(behavior: Int32) {
        unsafe {
            qTableWidgetSetSelectionBehavior(ptr, behavior)
        }
    }
    
    public func setSelectionMode(mode: Int32) {
        unsafe {
            qTableWidgetSetSelectionMode(ptr, mode)
        }
    }
    
    // 显示设置
    public func setShowGrid(show: Bool) {
        unsafe {
            qTableWidgetSetShowGrid(ptr, show)
        }
    }
    
    public func setSortingEnabled(enabled: Bool) {
        unsafe {
            qTableWidgetSetSortingEnabled(ptr, enabled)
        }
    }
    
    public func setAlternatingRowColors(enabled: Bool) {
        unsafe {
            qTableWidgetSetAlternatingRowColors(ptr, enabled)
        }
    }
    
    // 调整大小
    public func resizeColumnsToContents() {
        unsafe {
            qTableWidgetResizeColumnsToContents(ptr)
        }
    }
    
    public func resizeRowsToContents() {
        unsafe {
            qTableWidgetResizeRowsToContents(ptr)
        }
    }
    
    public func setColumnWidth(col: Int32, width: Int32) {
        unsafe {
            qTableWidgetSetColumnWidth(ptr, col, width)
        }
    }
    
    public func setRowHeight(row: Int32, height: Int32) {
        unsafe {
            qTableWidgetSetRowHeight(ptr, row, height)
        }
    }
    
    // 水平表头设置
    public func setHorizontalHeaderStretchLastSection(stretch: Bool) {
        unsafe {
            qTableWidgetHorizontalHeaderSetStretchLastSection(ptr, stretch)
        }
    }
    
    // 设置所有列的调整模式
    public func setHorizontalHeaderSectionResizeMode(mode: Int32) {
        unsafe {
            qTableWidgetHorizontalHeaderSetSectionResizeMode(ptr, mode)
        }
    }
    
    // 设置指定列的调整模式
    public func setColumnResizeMode(col: Int32, mode: Int32) {
        unsafe {
            qTableWidgetHorizontalHeaderSetSectionResizeModeColumn(ptr, col, mode)
        }
    }
    
    // 自动填充宽度（所有列平均分配）
    public func setAutoFillWidth() {
        unsafe {
            qTableWidgetHorizontalHeaderSetSectionResizeMode(ptr, Stretch)
        }
    }
    
    // 垂直表头设置
    public func setVerticalHeaderStretchLastSection(stretch: Bool) {
        unsafe {
            qTableWidgetVerticalHeaderSetStretchLastSection(ptr, stretch)
        }
    }
    
    public func setDefaultRowHeight(height: Int32) {
        unsafe {
            qTableWidgetVerticalHeaderSetDefaultSectionSize(ptr, height)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qTableWidgetDelete(ptr)
            }
            ptr = 0
        }
    }
}
