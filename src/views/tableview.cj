package cjqt6.views

import cjqt6.core.*

// ============================================================
// QTableView FFI declarations
// ============================================================

foreign func qTableViewCreate(): Int64
foreign func qTableViewSetModel(ptr: Int64, modelPtr: Int64): Unit
foreign func qTableViewSetColumnWidth(ptr: Int64, col: Int32, width: Int32): Unit
foreign func qTableViewSetRowHeight(ptr: Int64, row: Int32, height: Int32): Unit
foreign func qTableViewSetShowGrid(ptr: Int64, show: Bool): Unit
foreign func qTableViewSetSelectionMode(ptr: Int64, mode: Int32): Unit
foreign func qTableViewSetSelectionBehavior(ptr: Int64, behavior: Int32): Unit
foreign func qTableViewSetSortingEnabled(ptr: Int64, enabled: Bool): Unit
foreign func qTableViewResizeColumnsToContents(ptr: Int64): Unit
foreign func qTableViewResizeRowsToContents(ptr: Int64): Unit
foreign func qTableViewHorizontalHeaderSetStretchLastSection(ptr: Int64, stretch: Bool): Unit
foreign func qTableViewDelete(ptr: Int64): Unit

// ============================================================
// SelectionBehavior constants
// ============================================================
public class SelectionBehavior {
    public static let SelectItems: Int32 = 0
    public static let SelectRows: Int32 = 1
    public static let SelectColumns: Int32 = 2
}

// ============================================================
// QTableView
// ============================================================
public class QTableView {
    private var ptr: Int64 = 0

    private func checkValid(): Unit {
        if (ptr == 0) {
            throw ResourceDisposedException("QTableView already deleted")
        }
    }

    public init() {
        unsafe {
            ptr = qTableViewCreate()
        }
        if (ptr == 0) {
            throw CreateFailedException("QTableView create failed")
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

    public func setModel(model: QStandardItemModel): Unit {
        checkValid()
        unsafe {
            qTableViewSetModel(ptr, model.getPtr())
        }
    }

    public func setColumnWidth(col: Int32, width: Int32): Unit {
        checkValid()
        unsafe {
            qTableViewSetColumnWidth(ptr, col, width)
        }
    }

    public func setRowHeight(row: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qTableViewSetRowHeight(ptr, row, height)
        }
    }

    public func setShowGrid(show: Bool): Unit {
        checkValid()
        unsafe {
            qTableViewSetShowGrid(ptr, show)
        }
    }

    public func setSelectionMode(mode: Int32): Unit {
        checkValid()
        unsafe {
            qTableViewSetSelectionMode(ptr, mode)
        }
    }

    public func setSelectionBehavior(behavior: Int32): Unit {
        checkValid()
        unsafe {
            qTableViewSetSelectionBehavior(ptr, behavior)
        }
    }

    public func setSortingEnabled(enabled: Bool): Unit {
        checkValid()
        unsafe {
            qTableViewSetSortingEnabled(ptr, enabled)
        }
    }

    public func resizeColumnsToContents(): Unit {
        checkValid()
        unsafe {
            qTableViewResizeColumnsToContents(ptr)
        }
    }

    public func resizeRowsToContents(): Unit {
        checkValid()
        unsafe {
            qTableViewResizeRowsToContents(ptr)
        }
    }

    public func horizontalHeaderSetStretchLastSection(stretch: Bool): Unit {
        checkValid()
        unsafe {
            qTableViewHorizontalHeaderSetStretchLastSection(ptr, stretch)
        }
    }

    public func getPtr(): Int64 {
        ptr
    }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qTableViewDelete(ptr)
            }
            ptr = 0
        }
    }
}