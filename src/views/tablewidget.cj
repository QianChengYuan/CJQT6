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
foreign func qWidgetSetEnabled(ptr: Int64, enabled: Int32): Unit
foreign func qSignalCleanup(ptr: Int64): Unit

// 补充 API FFI（项/网格/索引/信号）
foreign func qTableWidgetItem(ptr: Int64, row: Int32, col: Int32): Int64
foreign func qTableWidgetTakeItem(ptr: Int64, row: Int32, col: Int32): Int64
foreign func qTableWidgetSetItemPtr(ptr: Int64, row: Int32, col: Int32, itemPtr: Int64): Unit
foreign func qTableWidgetSetHorizontalHeaderItem(ptr: Int64, col: Int32, itemPtr: Int64): Unit
foreign func qTableWidgetSetVerticalHeaderItem(ptr: Int64, row: Int32, itemPtr: Int64): Unit
foreign func qTableWidgetSetHorizontalHeaderLabels(ptr: Int64, labels: CString): Unit
foreign func qTableWidgetSelectedRanges(ptr: Int64): Int32
foreign func qTableWidgetFindItems(ptr: Int64, text: CString, flags: Int32): Int32
foreign func qTableWidgetSetEditTriggers(ptr: Int64, v: Int32): Unit
foreign func qTableWidgetEditTriggers(ptr: Int64): Int32
foreign func qTableWidgetSetGridStyle(ptr: Int64, v: Int32): Unit
foreign func qTableWidgetGridStyle(ptr: Int64): Int32
foreign func qTableWidgetSetCornerButtonEnabled(ptr: Int64, v: Int32): Unit
foreign func qTableWidgetIsCornerButtonEnabled(ptr: Int64): Int32
foreign func qTableWidgetIsSortingEnabled(ptr: Int64): Int32
foreign func qTableWidgetResizeColumnToContents(ptr: Int64, col: Int32): Unit
foreign func qTableWidgetSetHorizontalHeader(ptr: Int64, headerPtr: Int64): Unit
foreign func qTableWidgetSetVerticalHeader(ptr: Int64, headerPtr: Int64): Unit
foreign func qTableWidgetSetWordWrap(ptr: Int64, v: Int32): Unit
foreign func qTableWidgetIsWordWrap(ptr: Int64): Int32
foreign func qTableWidgetRowAt(ptr: Int64, y: Int32): Int32
foreign func qTableWidgetColumnAt(ptr: Int64, x: Int32): Int32
foreign func qTableWidgetSetCurrentIndex(ptr: Int64, indexPtr: Int64): Unit
foreign func qTableWidgetCurrentIndex(ptr: Int64): Int64
foreign func qTableWidgetConnectCellClicked(ptr: Int64, callback: CFunc<(Int32, Int32) -> Unit>): Unit
foreign func qTableWidgetConnectCellChanged(ptr: Int64, callback: CFunc<(Int32, Int32) -> Unit>): Unit
foreign func qTableWidgetConnectCellDoubleClicked(ptr: Int64, callback: CFunc<(Int32, Int32) -> Unit>): Unit
foreign func qTableWidgetConnectCurrentCellChanged(ptr: Int64, callback: CFunc<(Int32, Int32) -> Unit>): Unit
foreign func qTableWidgetConnectItemSelectionChanged(ptr: Int64, callback: CFunc<() -> Unit>): Unit
foreign func qTableWidgetConnectItemClicked(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit

// QTableWidgetItem 封装 FFI
foreign func qTableWidgetItemCreate(): Int64
foreign func qTableWidgetItemCreateWithText(text: CString): Int64
foreign func qTableWidgetItemDelete(itemPtr: Int64): Unit
foreign func qTableWidgetItemSetText(itemPtr: Int64, text: CString): Unit
foreign func qTableWidgetItemGetText(itemPtr: Int64): CString
foreign func qTableWidgetItemSetFlags(itemPtr: Int64, flags: Int32): Unit
foreign func qTableWidgetItemFlags(itemPtr: Int64): Int32
foreign func qTableWidgetItemSetCheckState(itemPtr: Int64, state: Int32): Unit
foreign func qTableWidgetItemCheckState(itemPtr: Int64): Int32
foreign func qTableWidgetItemSetData(itemPtr: Int64, role: Int32, value: Int64): Unit
foreign func qTableWidgetItemData(itemPtr: Int64, role: Int32): Int64
foreign func qTableWidgetItemSetBackground(itemPtr: Int64, r: Int32, g: Int32, b: Int32): Unit

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
    
    // ========== 单元格项 API ==========

    public func item(row: Int32, col: Int32): QTableWidgetItem {
        unsafe {
            return QTableWidgetItem.fromPtr(qTableWidgetItem(ptr, row, col))
        }
    }

    public func takeItem(row: Int32, col: Int32): QTableWidgetItem {
        unsafe {
            return QTableWidgetItem.fromPtr(qTableWidgetTakeItem(ptr, row, col))
        }
    }

    public func setItem(row: Int32, col: Int32, item: QTableWidgetItem) {
        unsafe {
            qTableWidgetSetItemPtr(ptr, row, col, item.getPtr())
        }
    }

    public func setHorizontalHeaderItem(col: Int32, item: QTableWidgetItem) {
        unsafe {
            qTableWidgetSetHorizontalHeaderItem(ptr, col, item.getPtr())
        }
    }

    public func setVerticalHeaderItem(row: Int32, item: QTableWidgetItem) {
        unsafe {
            qTableWidgetSetVerticalHeaderItem(ptr, row, item.getPtr())
        }
    }

    public func setHorizontalHeaderLabels(labels: Array<String>) {
        unsafe {
            var joined = ""
            for (i in 0..labels.size) {
                if (i > 0) { joined += "\n" }
                joined += labels[i]
            }
            let cstr = LibC.mallocCString(joined)
            qTableWidgetSetHorizontalHeaderLabels(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func selectedRanges(): Int32 {
        unsafe {
            qTableWidgetSelectedRanges(ptr)
        }
    }

    public func findItems(text: String, flags: Int32): Int32 {
        unsafe {
            let cstr = LibC.mallocCString(text)
            let result = qTableWidgetFindItems(ptr, cstr, flags)
            LibC.free(cstr)
            return result
        }
    }

    // ========== 编辑/网格/布局 ==========

    public func setEditTriggers(triggers: Int32): Unit {
        unsafe {
            qTableWidgetSetEditTriggers(ptr, triggers)
        }
    }

    public func editTriggers(): Int32 {
        unsafe {
            qTableWidgetEditTriggers(ptr)
        }
    }

    public func setGridStyle(style: Int32): Unit {
        unsafe {
            qTableWidgetSetGridStyle(ptr, style)
        }
    }

    public func gridStyle(): Int32 {
        unsafe {
            qTableWidgetGridStyle(ptr)
        }
    }

    public func setCornerButtonEnabled(enabled: Bool): Unit {
        unsafe {
            qTableWidgetSetCornerButtonEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }

    public func isCornerButtonEnabled(): Bool {
        unsafe {
            qTableWidgetIsCornerButtonEnabled(ptr) != 0
        }
    }

    public func isSortingEnabled(): Bool {
        unsafe {
            qTableWidgetIsSortingEnabled(ptr) != 0
        }
    }

    public func resizeColumnToContents(col: Int32): Unit {
        unsafe {
            qTableWidgetResizeColumnToContents(ptr, col)
        }
    }

    public func setHorizontalHeader(header: QHeaderView): Unit {
        unsafe {
            qTableWidgetSetHorizontalHeader(ptr, header.getPtr())
        }
    }

    public func setVerticalHeader(header: QHeaderView): Unit {
        unsafe {
            qTableWidgetSetVerticalHeader(ptr, header.getPtr())
        }
    }

    public func setWordWrap(wordWrap: Bool): Unit {
        unsafe {
            qTableWidgetSetWordWrap(ptr, if (wordWrap) { 1 } else { 0 })
        }
    }

    public func isWordWrap(): Bool {
        unsafe {
            qTableWidgetIsWordWrap(ptr) != 0
        }
    }

    public func rowAt(y: Int32): Int32 {
        unsafe {
            qTableWidgetRowAt(ptr, y)
        }
    }

    public func columnAt(x: Int32): Int32 {
        unsafe {
            qTableWidgetColumnAt(ptr, x)
        }
    }

    public func setCurrentIndex(index: QModelIndex): Unit {
        unsafe {
            qTableWidgetSetCurrentIndex(ptr, index.ptr)
        }
    }

    public func currentIndex(): Int64 {
        unsafe {
            qTableWidgetCurrentIndex(ptr)
        }
    }

    // ========== 信号 ==========

    public func setOnCellClicked(callback: CFunc<(Int32, Int32) -> Unit>) {
        unsafe {
            qTableWidgetConnectCellClicked(ptr, callback)
        }
    }

    public func setOnCellChanged(callback: CFunc<(Int32, Int32) -> Unit>) {
        unsafe {
            qTableWidgetConnectCellChanged(ptr, callback)
        }
    }

    public func setOnCellDoubleClicked(callback: CFunc<(Int32, Int32) -> Unit>) {
        unsafe {
            qTableWidgetConnectCellDoubleClicked(ptr, callback)
        }
    }

    public func setOnCurrentCellChanged(callback: CFunc<(Int32, Int32) -> Unit>) {
        unsafe {
            qTableWidgetConnectCurrentCellChanged(ptr, callback)
        }
    }

    public func setOnItemSelectionChanged(callback: CFunc<() -> Unit>) {
        unsafe {
            qTableWidgetConnectItemSelectionChanged(ptr, callback)
        }
    }

    public func setOnItemClicked(callback: CFunc<(Int64) -> Unit>) {
        unsafe {
            qTableWidgetConnectItemClicked(ptr, callback)
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

// ============================================================
// QTableWidgetItem 最小封装（复用 listwidget.cj 的 ItemFlag、treewidget.cj 的 CheckState）
// ============================================================
public class QTableWidgetItem {
    private var ptr: Int64 = 0

    public init() {
        unsafe {
            ptr = qTableWidgetItemCreate()
        }
    }

    public init(text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            ptr = qTableWidgetItemCreateWithText(cstr)
            LibC.free(cstr)
        }
    }

    private init(ptr: Int64) {
        this.ptr = ptr
    }

    // 从控件返回的指针构造（不拥有所有权，调用方不应 delete）
    public static func fromPtr(ptr: Int64): QTableWidgetItem {
        QTableWidgetItem(ptr)
    }

    public func getPtr(): Int64 {
        ptr
    }

    public func text(): String {
        unsafe {
            let cstr = qTableWidgetItemGetText(ptr)
            return cstr.toString()
        }
    }

    public func setText(text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qTableWidgetItemSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func setFlags(flags: Int32): Unit {
        unsafe {
            qTableWidgetItemSetFlags(ptr, flags)
        }
    }

    public func flags(): Int32 {
        unsafe {
            qTableWidgetItemFlags(ptr)
        }
    }

    public func setCheckState(state: Int32): Unit {
        unsafe {
            qTableWidgetItemSetCheckState(ptr, state)
        }
    }

    public func checkState(): Int32 {
        unsafe {
            qTableWidgetItemCheckState(ptr)
        }
    }

    public func setData(role: Int32, value: Int64): Unit {
        unsafe {
            qTableWidgetItemSetData(ptr, role, value)
        }
    }

    public func data(role: Int32): Int64 {
        unsafe {
            qTableWidgetItemData(ptr, role)
        }
    }

    public func setBackground(r: Int32, g: Int32, b: Int32): Unit {
        unsafe {
            qTableWidgetItemSetBackground(ptr, r, g, b)
        }
    }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qTableWidgetItemDelete(ptr)
            }
            ptr = 0
        }
    }
}
