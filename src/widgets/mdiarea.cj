package cjqt6.widgets

import cjqt6.core.*

// QMdiArea - 多文档区域
foreign func qMdiAreaCreate(): Int64
foreign func qMdiAreaDelete(ptr: Int64): Unit
foreign func qMdiAreaAddSubWindow(ptr: Int64, widgetPtr: Int64): Int64
foreign func qMdiAreaRemoveSubWindow(ptr: Int64, subWinPtr: Int64): Unit
foreign func qMdiAreaCurrentSubWindow(ptr: Int64): Int64
foreign func qMdiAreaCascadeSubWindows(ptr: Int64): Unit
foreign func qMdiAreaTileSubWindows(ptr: Int64): Unit
foreign func qMdiAreaCloseAllSubWindows(ptr: Int64): Unit
foreign func qMdiAreaSetViewMode(ptr: Int64, mode: Int32): Unit

// QMdiSubWindow
foreign func qMdiSubWindowSetWidget(ptr: Int64, widgetPtr: Int64): Unit
foreign func qMdiSubWindowWidget(ptr: Int64): Int64
foreign func qMdiSubWindowDelete(ptr: Int64): Unit

// QMdiArea ViewMode
public class MdiAreaViewMode {
    public static let SubWindowView: Int32 = 0
    public static let TabbedView: Int32 = 1
}

public class QMdiArea {
    private var ptr: Int64 = 0

    public init(parent!: Int64 = 0) {
        unsafe {
            ptr = qMdiAreaCreate()
            if (parent != 0) {
                setWidgetParent(ptr, parent)
            }
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

    public func addSubWindow(widgetPtr: Int64): Int64 {
        unsafe {
            qMdiAreaAddSubWindow(ptr, widgetPtr)
        }
    }

    public func removeSubWindow(subWinPtr: Int64) {
        unsafe {
            qMdiAreaRemoveSubWindow(ptr, subWinPtr)
        }
    }

    public func currentSubWindow(): Int64 {
        unsafe {
            qMdiAreaCurrentSubWindow(ptr)
        }
    }

    public func cascadeSubWindows() {
        unsafe {
            qMdiAreaCascadeSubWindows(ptr)
        }
    }

    public func tileSubWindows() {
        unsafe {
            qMdiAreaTileSubWindows(ptr)
        }
    }

    public func closeAllSubWindows() {
        unsafe {
            qMdiAreaCloseAllSubWindows(ptr)
        }
    }

    public func setViewMode(mode: Int32) {
        unsafe {
            qMdiAreaSetViewMode(ptr, mode)
        }
    }

    public func setLayout(layoutPtr: Int64) {
        unsafe {
            qWidgetSetLayout(ptr, layoutPtr)
        }
    }

    public func getPtr(): Int64 {
        ptr
    }

    public func delete() {
        if (ptr != 0) {
            unsafe {
                qMdiAreaDelete(ptr)
            }
            ptr = 0
        }
    }
}

public class QMdiSubWindow {
    private var ptr: Int64 = 0

    public init(ptr: Int64) {
        this.ptr = ptr
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

    public func setWidget(widgetPtr: Int64) {
        unsafe {
            qMdiSubWindowSetWidget(ptr, widgetPtr)
        }
    }

    public func widget(): Int64 {
        unsafe {
            qMdiSubWindowWidget(ptr)
        }
    }

    public func getPtr(): Int64 {
        ptr
    }

    public func delete() {
        if (ptr != 0) {
            unsafe {
                qMdiSubWindowDelete(ptr)
            }
            ptr = 0
        }
    }
}
