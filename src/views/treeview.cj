package cjqt6.views

import cjqt6.core.*

// ============================================================
// QTreeView FFI declarations
// ============================================================

foreign func qTreeViewCreate(): Int64
foreign func qTreeViewSetModel(ptr: Int64, modelPtr: Int64): Unit
foreign func qTreeViewExpandAll(ptr: Int64): Unit
foreign func qTreeViewCollapseAll(ptr: Int64): Unit
foreign func qTreeViewSetSelectionMode(ptr: Int64, mode: Int32): Unit
foreign func qTreeViewSetHeaderHidden(ptr: Int64, hidden: Bool): Unit
foreign func qTreeViewDelete(ptr: Int64): Unit

// ============================================================
// QTreeView
// ============================================================
public class QTreeView {
    private var ptr: Int64 = 0

    private func checkValid(): Unit {
        if (ptr == 0) {
            throw ResourceDisposedException("QTreeView already deleted")
        }
    }

    public init() {
        unsafe {
            ptr = qTreeViewCreate()
        }
        if (ptr == 0) {
            throw CreateFailedException("QTreeView create failed")
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
            qTreeViewSetModel(ptr, model.getPtr())
        }
    }

    public func expandAll(): Unit {
        checkValid()
        unsafe {
            qTreeViewExpandAll(ptr)
        }
    }

    public func collapseAll(): Unit {
        checkValid()
        unsafe {
            qTreeViewCollapseAll(ptr)
        }
    }

    public func setSelectionMode(mode: Int32): Unit {
        checkValid()
        unsafe {
            qTreeViewSetSelectionMode(ptr, mode)
        }
    }

    public func setHeaderHidden(hidden: Bool): Unit {
        checkValid()
        unsafe {
            qTreeViewSetHeaderHidden(ptr, hidden)
        }
    }

    public func getPtr(): Int64 {
        ptr
    }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qTreeViewDelete(ptr)
            }
            ptr = 0
        }
    }
}