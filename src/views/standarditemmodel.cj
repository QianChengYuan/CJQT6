package cjqt6.views

import cjqt6.core.*

// ============================================================
// QStandardItemModel FFI declarations
// ============================================================

foreign func qStandardItemModelCreate(): Int64
foreign func qStandardItemModelCreateWithSize(rows: Int32, cols: Int32): Int64
foreign func qStandardItemModelSetRowCount(ptr: Int64, rows: Int32): Unit
foreign func qStandardItemModelRowCount(ptr: Int64): Int32
foreign func qStandardItemModelSetColumnCount(ptr: Int64, cols: Int32): Unit
foreign func qStandardItemModelColumnCount(ptr: Int64): Int32
foreign func qStandardItemModelSetItem(ptr: Int64, row: Int32, col: Int32, text: CString): Unit
foreign func qStandardItemModelItemText(ptr: Int64, row: Int32, col: Int32): CString
foreign func qStandardItemModelClear(ptr: Int64): Unit
foreign func qStandardItemModelSetHorizontalHeaderLabel(ptr: Int64, col: Int32, label: CString): Unit
foreign func qStandardItemModelSetVerticalHeaderLabel(ptr: Int64, row: Int32, label: CString): Unit
foreign func qStandardItemModelInsertRow(ptr: Int64, row: Int32): Unit
foreign func qStandardItemModelRemoveRow(ptr: Int64, row: Int32): Unit
foreign func qStandardItemModelInsertColumn(ptr: Int64, col: Int32): Unit
foreign func qStandardItemModelRemoveColumn(ptr: Int64, col: Int32): Unit
foreign func qStandardItemModelSetItemEnabled(ptr: Int64, row: Int32, col: Int32, enabled: Bool): Unit
foreign func qStandardItemModelSetItemCheckable(ptr: Int64, row: Int32, col: Int32, checkable: Bool): Unit
foreign func qStandardItemModelSetItemChecked(ptr: Int64, row: Int32, col: Int32, checked: Bool): Unit
foreign func qStandardItemModelIsItemChecked(ptr: Int64, row: Int32, col: Int32): Int32
foreign func qStandardItemModelDelete(ptr: Int64): Unit

// 补充 API FFI
foreign func qStandardItemModelSetHeaderData(ptr: Int64, section: Int32, orientation: Int32, value: Int64, role: Int32): Int32
foreign func qStandardItemModelSetItemPtr(ptr: Int64, row: Int32, col: Int32, itemPtr: Int64): Unit
foreign func qStandardItemModelItem(ptr: Int64, row: Int32, col: Int32): Int64
foreign func qStandardItemModelSetHorizontalHeaderItem(ptr: Int64, col: Int32, itemPtr: Int64): Unit
foreign func qStandardItemModelSetVerticalHeaderItem(ptr: Int64, row: Int32, itemPtr: Int64): Unit
foreign func qStandardItemModelAppendRow(ptr: Int64, itemPtr: Int64): Unit
foreign func qStandardItemModelInsertRowItem(ptr: Int64, row: Int32, itemPtr: Int64): Unit
foreign func qStandardItemModelFindItems(ptr: Int64, text: CString, flags: Int32): Int32
foreign func qStandardItemModelItemFromIndex(ptr: Int64, indexPtr: Int64): Int64
foreign func qStandardItemModelIndexFromItem(ptr: Int64, itemPtr: Int64): Int64

// QStandardItem 封装 FFI
foreign func qStandardItemCreate(): Int64
foreign func qStandardItemCreateWithText(text: CString): Int64
foreign func qStandardItemDelete(itemPtr: Int64): Unit
foreign func qStandardItemSetText(itemPtr: Int64, text: CString): Unit
foreign func qStandardItemGetText(itemPtr: Int64): CString
foreign func qStandardItemSetFlags(itemPtr: Int64, flags: Int32): Unit
foreign func qStandardItemFlags(itemPtr: Int64): Int32
foreign func qStandardItemSetCheckState(itemPtr: Int64, state: Int32): Unit
foreign func qStandardItemCheckState(itemPtr: Int64): Int32
foreign func qStandardItemSetData(itemPtr: Int64, role: Int32, value: Int64): Unit
foreign func qStandardItemData(itemPtr: Int64, role: Int32): Int64
foreign func qStandardItemSetEditable(itemPtr: Int64, v: Int32): Unit
foreign func qStandardItemIsEditable(itemPtr: Int64): Int32
foreign func qStandardItemAppendRow(itemPtr: Int64, childPtr: Int64): Unit
foreign func qStandardItemSetForeground(itemPtr: Int64, r: Int32, g: Int32, b: Int32): Unit

// ============================================================
// SelectionMode constants
// ============================================================
public class SelectionMode {
    public static let NoSelection: Int32 = 0
    public static let Single: Int32 = 1
    public static let Multi: Int32 = 2
    public static let Extended: Int32 = 3
}

// ============================================================
// QStandardItemModel
// ============================================================
public class QStandardItemModel {
    private var ptr: Int64 = 0

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0) {
            throw ResourceDisposedException("QStandardItemModel already deleted")
        }
    }

    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qStandardItemModelCreate()
        }
        if (ptr == 0) {
            throw CreateFailedException("QStandardItemModel create failed")
        }
    }

    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init(rows: Int32, cols: Int32) {
        unsafe {
            ptr = qStandardItemModelCreateWithSize(rows, cols)
        }
        if (ptr == 0) {
            throw CreateFailedException("QStandardItemModel create failed")
        }
    }

    public func show(): Unit {
        checkValid()
        unsafe {
            qWidgetShow(ptr)
        }
    }

    public func hide(): Unit {
        checkValid()
        unsafe {
            qWidgetHide(ptr)
        }
    }

    public func resize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }

    public func setEnabled(enabled: Bool): Unit {
        checkValid()
        unsafe {
            qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }

    public func setStyleSheet(style: String): Unit {
        checkValid()
        unsafe {
            withCString(style) { c => qWidgetSetStyleSheet(ptr, c) }
        }
    }

    public func setRowCount(rows: Int32): Unit {
        checkValid()
        unsafe {
            qStandardItemModelSetRowCount(ptr, rows)
        }
    }

    public func rowCount(): Int32 {
        checkValid()
        unsafe {
            qStandardItemModelRowCount(ptr)
        }
    }

    public func setColumnCount(cols: Int32): Unit {
        checkValid()
        unsafe {
            qStandardItemModelSetColumnCount(ptr, cols)
        }
    }

    public func columnCount(): Int32 {
        checkValid()
        unsafe {
            qStandardItemModelColumnCount(ptr)
        }
    }

    public func setItem(row: Int32, col: Int32, text: String): Unit {
        checkValid()
        unsafe {
            withCString(text) { c => qStandardItemModelSetItem(ptr, row, col, c) }
        }
    }

    public func itemText(row: Int32, col: Int32): String {
        checkValid()
        unsafe {
            let cstr = qStandardItemModelItemText(ptr, row, col)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    public func clear(): Unit {
        checkValid()
        unsafe {
            qStandardItemModelClear(ptr)
        }
    }

    public func setHorizontalHeaderLabel(col: Int32, label: String): Unit {
        checkValid()
        unsafe {
            withCString(label) { c => qStandardItemModelSetHorizontalHeaderLabel(ptr, col, c) }
        }
    }

    public func setVerticalHeaderLabel(row: Int32, label: String): Unit {
        checkValid()
        unsafe {
            withCString(label) { c => qStandardItemModelSetVerticalHeaderLabel(ptr, row, c) }
        }
    }

    public func insertRow(row: Int32): Unit {
        checkValid()
        unsafe {
            qStandardItemModelInsertRow(ptr, row)
        }
    }

    public func removeRow(row: Int32): Unit {
        checkValid()
        unsafe {
            qStandardItemModelRemoveRow(ptr, row)
        }
    }

    public func insertColumn(col: Int32): Unit {
        checkValid()
        unsafe {
            qStandardItemModelInsertColumn(ptr, col)
        }
    }

    public func removeColumn(col: Int32): Unit {
        checkValid()
        unsafe {
            qStandardItemModelRemoveColumn(ptr, col)
        }
    }

    public func setItemEnabled(row: Int32, col: Int32, enabled: Bool): Unit {
        checkValid()
        unsafe {
            qStandardItemModelSetItemEnabled(ptr, row, col, enabled)
        }
    }

    public func setItemCheckable(row: Int32, col: Int32, checkable: Bool): Unit {
        checkValid()
        unsafe {
            qStandardItemModelSetItemCheckable(ptr, row, col, checkable)
        }
    }

    public func setItemChecked(row: Int32, col: Int32, checked: Bool): Unit {
        checkValid()
        unsafe {
            qStandardItemModelSetItemChecked(ptr, row, col, checked)
        }
    }

    public func isItemChecked(row: Int32, col: Int32): Bool {
        checkValid()
        unsafe {
            qStandardItemModelIsItemChecked(ptr, row, col) == 1
        }
    }

    // ========== 项 / 表头 API ==========

    public func setHeaderData(section: Int32, orientation: Int32, value: Int64, role: Int32): Bool {
        checkValid()
        unsafe {
            qStandardItemModelSetHeaderData(ptr, section, orientation, value, role) != 0
        }
    }

    public func setItem(row: Int32, col: Int32, item: QStandardItem): Unit {
        checkValid()
        unsafe {
            qStandardItemModelSetItemPtr(ptr, row, col, item.getPtr())
        }
    }

    public func item(row: Int32, col: Int32): QStandardItem {
        checkValid()
        unsafe {
            return QStandardItem.fromPtr(qStandardItemModelItem(ptr, row, col))
        }
    }

    public func setHorizontalHeaderItem(col: Int32, item: QStandardItem): Unit {
        checkValid()
        unsafe {
            qStandardItemModelSetHorizontalHeaderItem(ptr, col, item.getPtr())
        }
    }

    public func setVerticalHeaderItem(row: Int32, item: QStandardItem): Unit {
        checkValid()
        unsafe {
            qStandardItemModelSetVerticalHeaderItem(ptr, row, item.getPtr())
        }
    }

    public func appendRow(item: QStandardItem): Unit {
        checkValid()
        unsafe {
            qStandardItemModelAppendRow(ptr, item.getPtr())
        }
    }

    public func insertRow(row: Int32, item: QStandardItem): Unit {
        checkValid()
        unsafe {
            qStandardItemModelInsertRowItem(ptr, row, item.getPtr())
        }
    }

    public func findItems(text: String, flags: Int32): Int32 {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            let result = qStandardItemModelFindItems(ptr, cstr, flags)
            LibC.free(cstr)
            return result
        }
    }

    public func itemFromIndex(index: QModelIndex): QStandardItem {
        checkValid()
        unsafe {
            return QStandardItem.fromPtr(qStandardItemModelItemFromIndex(ptr, index.ptr))
        }
    }

    public func indexFromItem(item: QStandardItem): Int64 {
        checkValid()
        unsafe {
            return qStandardItemModelIndexFromItem(ptr, item.getPtr())
        }
    }

    public func getPtr(): Int64 {
        ptr
    }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qStandardItemModelDelete(ptr)
            }
            ptr = 0
        }
    }
}

// ============================================================
// QStandardItem 最小封装（复用 listwidget.cj 的 ItemFlag、treewidget.cj 的 CheckState）
// ============================================================
public class QStandardItem {
    private var ptr: Int64 = 0

    public init() {
        unsafe {
            ptr = qStandardItemCreate()
        }
    }

    public init(text: String) {
        unsafe {
            withCString(text) { c => ptr = qStandardItemCreateWithText(c) }
        }
    }

    private init(ptr: Int64) {
        this.ptr = ptr
    }

    // 从模型返回的指针构造（不拥有所有权，调用方不应 delete）
    public static func fromPtr(ptr: Int64): QStandardItem {
        QStandardItem(ptr)
    }

    public func getPtr(): Int64 {
        ptr
    }

    public func text(): String {
        unsafe {
            let cstr = qStandardItemGetText(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    public func setText(text: String): Unit {
        unsafe {
            withCString(text) { c => qStandardItemSetText(ptr, c) }
        }
    }

    public func setFlags(flags: Int32): Unit {
        unsafe {
            qStandardItemSetFlags(ptr, flags)
        }
    }

    public func flags(): Int32 {
        unsafe {
            qStandardItemFlags(ptr)
        }
    }

    public func setCheckState(state: Int32): Unit {
        unsafe {
            qStandardItemSetCheckState(ptr, state)
        }
    }

    public func checkState(): Int32 {
        unsafe {
            qStandardItemCheckState(ptr)
        }
    }

    public func setData(role: Int32, value: Int64): Unit {
        unsafe {
            qStandardItemSetData(ptr, role, value)
        }
    }

    public func data(role: Int32): Int64 {
        unsafe {
            qStandardItemData(ptr, role)
        }
    }

    public func setEditable(editable: Bool): Unit {
        unsafe {
            qStandardItemSetEditable(ptr, if (editable) { 1 } else { 0 })
        }
    }

    public func isEditable(): Bool {
        unsafe {
            qStandardItemIsEditable(ptr) != 0
        }
    }

    public func appendRow(child: QStandardItem): Unit {
        unsafe {
            qStandardItemAppendRow(ptr, child.getPtr())
        }
    }

    public func setForeground(r: Int32, g: Int32, b: Int32): Unit {
        unsafe {
            qStandardItemSetForeground(ptr, r, g, b)
        }
    }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qStandardItemDelete(ptr)
            }
            ptr = 0
        }
    }
}
