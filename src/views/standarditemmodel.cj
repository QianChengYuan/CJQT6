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

    private func checkValid(): Unit {
        if (ptr == 0) {
            throw ResourceDisposedException("QStandardItemModel already deleted")
        }
    }

    public init() {
        unsafe {
            ptr = qStandardItemModelCreate()
        }
        if (ptr == 0) {
            throw CreateFailedException("QStandardItemModel create failed")
        }
    }

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
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
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
            let cstr = LibC.mallocCString(text)
            qStandardItemModelSetItem(ptr, row, col, cstr)
            LibC.free(cstr)
        }
    }

    public func itemText(row: Int32, col: Int32): String {
        checkValid()
        unsafe {
            let cstr = qStandardItemModelItemText(ptr, row, col)
            return cstr.toString()
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
            let cstr = LibC.mallocCString(label)
            qStandardItemModelSetHorizontalHeaderLabel(ptr, col, cstr)
            LibC.free(cstr)
        }
    }

    public func setVerticalHeaderLabel(row: Int32, label: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(label)
            qStandardItemModelSetVerticalHeaderLabel(ptr, row, cstr)
            LibC.free(cstr)
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