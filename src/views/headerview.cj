package cjqt6.views

import cjqt6.core.*

// ============================================================
// QHeaderView FFI declarations
// ============================================================

foreign func qHeaderViewCreate(orientation: Int32): Int64
foreign func qHeaderViewSetStretchLastSection(ptr: Int64, stretch: Bool): Unit
foreign func qHeaderViewSetSectionResizeMode(ptr: Int64, mode: Int32): Unit
foreign func qHeaderViewDelete(ptr: Int64): Unit


// ============================================================
// Orientation constants
// ============================================================
public class Orientation {
    public static let Horizontal: Int32 = 1
    public static let Vertical: Int32 = 2
}

// ============================================================
// ResizeMode constants
// ============================================================
public class ResizeMode {
    public static let Interactive: Int32 = 0
    public static let Stretch: Int32 = 1
    public static let Fixed: Int32 = 2
    public static let ResizeToContents: Int32 = 3
}

// ============================================================
// QHeaderView
// ============================================================
public class QHeaderView {
    private var ptr: Int64 = 0

    private func checkValid(): Unit {
        if (ptr == 0) {
            throw ResourceDisposedException("QHeaderView already deleted")
        }
    }

    public init(orientation: Int32) {
        unsafe {
            ptr = qHeaderViewCreate(orientation)
        }
        if (ptr == 0) {
            throw CreateFailedException("QHeaderView create failed")
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

    public func setStretchLastSection(stretch: Bool): Unit {
        checkValid()
        unsafe {
            qHeaderViewSetStretchLastSection(ptr, stretch)
        }
    }

    public func setSectionResizeMode(mode: Int32): Unit {
        checkValid()
        unsafe {
            qHeaderViewSetSectionResizeMode(ptr, mode)
        }
    }

    public func getPtr(): Int64 {
        ptr
    }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qHeaderViewDelete(ptr)
            }
            ptr = 0
        }
    }
}