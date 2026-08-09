package cjqt6.views

import cjqt6.core.*

// ============================================================
// QTableView FFI declarations
// ============================================================

foreign func qTableViewCreate(): Int64
foreign func qTableViewSetModel(ptr: Int64, modelPtr: Int64): Unit
foreign func qTableViewSetColumnWidth(ptr: Int64, col: Int32, width: Int32): Unit
foreign func qTableViewSetRowHeight(ptr: Int64, row: Int32, height: Int32): Unit
foreign func qTableViewSetShowGrid(ptr: Int64, show: Int32): Unit
foreign func qTableViewSetSelectionMode(ptr: Int64, mode: Int32): Unit
foreign func qTableViewSetSelectionBehavior(ptr: Int64, behavior: Int32): Unit
foreign func qTableViewSetSortingEnabled(ptr: Int64, enabled: Int32): Unit
foreign func qTableViewResizeColumnsToContents(ptr: Int64): Unit
foreign func qTableViewResizeRowsToContents(ptr: Int64): Unit
foreign func qTableViewHorizontalHeaderSetStretchLastSection(ptr: Int64, stretch: Int32): Unit
foreign func qTableViewDelete(ptr: Int64): Unit

// 补充 API FFI（编辑/网格/布局/索引/信号）
foreign func qTableViewSetEditTriggers(ptr: Int64, v: Int32): Unit
foreign func qTableViewEditTriggers(ptr: Int64): Int32
foreign func qTableViewIsShowGrid(ptr: Int64): Int32
foreign func qTableViewSetGridStyle(ptr: Int64, v: Int32): Unit
foreign func qTableViewGridStyle(ptr: Int64): Int32
foreign func qTableViewSetCornerButtonEnabled(ptr: Int64, v: Int32): Unit
foreign func qTableViewIsCornerButtonEnabled(ptr: Int64): Int32
foreign func qTableViewIsSortingEnabled(ptr: Int64): Int32
foreign func qTableViewResizeColumnToContents(ptr: Int64, col: Int32): Unit
foreign func qTableViewSetHorizontalHeader(ptr: Int64, headerPtr: Int64): Unit
foreign func qTableViewSetVerticalHeader(ptr: Int64, headerPtr: Int64): Unit
foreign func qTableViewSetWordWrap(ptr: Int64, v: Int32): Unit
foreign func qTableViewIsWordWrap(ptr: Int64): Int32
foreign func qTableViewRowAt(ptr: Int64, y: Int32): Int32
foreign func qTableViewColumnAt(ptr: Int64, x: Int32): Int32
foreign func qTableViewSetCurrentIndex(ptr: Int64, indexPtr: Int64): Unit
foreign func qTableViewCurrentIndex(ptr: Int64): Int64
foreign func qTableViewConnectClicked(ptr: Int64, callback: Int64Callback): Unit
foreign func qTableViewConnectDoubleClicked(ptr: Int64, callback: Int64Callback): Unit
foreign func qTableViewConnectActivated(ptr: Int64, callback: Int64Callback): Unit
foreign func qTableViewConnectPressed(ptr: Int64, callback: Int64Callback): Unit

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

    /// 设置自定义回调模型（QAbstractItemModel，P1 实时数据表）
    /// 配合 notifyDataChanged/notifyLayoutChanged 实现局部刷新，避免整表 reset
    public func setModel(model: QAbstractItemModel): Unit {
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
            qTableViewSetShowGrid(ptr, if (show) { 1 } else { 0 })
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
            qTableViewSetSortingEnabled(ptr, if (enabled) { 1 } else { 0 })
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
            qTableViewHorizontalHeaderSetStretchLastSection(ptr, if (stretch) { 1 } else { 0 })
        }
    }

    public func setEditTriggers(triggers: Int32): Unit {
        checkValid()
        unsafe {
            qTableViewSetEditTriggers(ptr, triggers)
        }
    }

    public func editTriggers(): Int32 {
        checkValid()
        unsafe {
            qTableViewEditTriggers(ptr)
        }
    }

    public func isShowGrid(): Bool {
        checkValid()
        unsafe {
            qTableViewIsShowGrid(ptr) != 0
        }
    }

    public func setGridStyle(style: Int32): Unit {
        checkValid()
        unsafe {
            qTableViewSetGridStyle(ptr, style)
        }
    }

    public func gridStyle(): Int32 {
        checkValid()
        unsafe {
            qTableViewGridStyle(ptr)
        }
    }

    public func setCornerButtonEnabled(enabled: Bool): Unit {
        checkValid()
        unsafe {
            qTableViewSetCornerButtonEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }

    public func isCornerButtonEnabled(): Bool {
        checkValid()
        unsafe {
            qTableViewIsCornerButtonEnabled(ptr) != 0
        }
    }

    public func isSortingEnabled(): Bool {
        checkValid()
        unsafe {
            qTableViewIsSortingEnabled(ptr) != 0
        }
    }

    public func resizeColumnToContents(col: Int32): Unit {
        checkValid()
        unsafe {
            qTableViewResizeColumnToContents(ptr, col)
        }
    }

    public func setHorizontalHeader(header: QHeaderView): Unit {
        checkValid()
        unsafe {
            qTableViewSetHorizontalHeader(ptr, header.getPtr())
        }
    }

    public func setVerticalHeader(header: QHeaderView): Unit {
        checkValid()
        unsafe {
            qTableViewSetVerticalHeader(ptr, header.getPtr())
        }
    }

    public func setWordWrap(wordWrap: Bool): Unit {
        checkValid()
        unsafe {
            qTableViewSetWordWrap(ptr, if (wordWrap) { 1 } else { 0 })
        }
    }

    public func isWordWrap(): Bool {
        checkValid()
        unsafe {
            qTableViewIsWordWrap(ptr) != 0
        }
    }

    public func rowAt(y: Int32): Int32 {
        checkValid()
        unsafe {
            qTableViewRowAt(ptr, y)
        }
    }

    public func columnAt(x: Int32): Int32 {
        checkValid()
        unsafe {
            qTableViewColumnAt(ptr, x)
        }
    }

    public func setCurrentIndex(index: QModelIndex): Unit {
        checkValid()
        unsafe {
            qTableViewSetCurrentIndex(ptr, index.ptr)
        }
    }

    public func currentIndex(): Int64 {
        checkValid()
        unsafe {
            qTableViewCurrentIndex(ptr)
        }
    }

    public func setOnClicked(callback: Int64Callback): Unit {
        checkValid()
        unsafe {
            qTableViewConnectClicked(ptr, callback)
        }
    }

    public func setOnDoubleClicked(callback: Int64Callback): Unit {
        checkValid()
        unsafe {
            qTableViewConnectDoubleClicked(ptr, callback)
        }
    }

    public func setOnActivated(callback: Int64Callback): Unit {
        checkValid()
        unsafe {
            qTableViewConnectActivated(ptr, callback)
        }
    }

    public func setOnPressed(callback: Int64Callback): Unit {
        checkValid()
        unsafe {
            qTableViewConnectPressed(ptr, callback)
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