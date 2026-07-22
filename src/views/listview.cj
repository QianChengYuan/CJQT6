package cjqt6.views

import cjqt6.core.*

// ============================================================
// QListView FFI declarations
// ============================================================

foreign func qListViewCreate(): Int64
foreign func qListViewSetModel(ptr: Int64, modelPtr: Int64): Unit
foreign func qListViewSetSelectionMode(ptr: Int64, mode: Int32): Unit
foreign func qListViewDelete(ptr: Int64): Unit


// ============================================================
// QListView
// ============================================================
public class QListView {
    private var ptr: Int64 = 0

    private func checkValid(): Unit {
        if (ptr == 0) {
            throw ResourceDisposedException("QListView already deleted")
        }
    }

    public init() {
        unsafe {
            ptr = qListViewCreate()
        }
        if (ptr == 0) {
            throw CreateFailedException("QListView create failed")
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
            qListViewSetModel(ptr, model.getPtr())
        }
    }

    public func setSelectionMode(mode: Int32): Unit {
        checkValid()
        unsafe {
            qListViewSetSelectionMode(ptr, mode)
        }
    }

    public func getPtr(): Int64 {
        ptr
    }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qListViewDelete(ptr)
            }
            ptr = 0
        }
    }
}