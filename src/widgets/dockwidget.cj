package cjqt6.widgets

import cjqt6.core.*

// QDockWidget - 停靠窗口
foreign func qDockWidgetCreate(title: CString): Int64
foreign func qDockWidgetDelete(ptr: Int64): Unit
foreign func qDockWidgetSetWidget(ptr: Int64, widgetPtr: Int64): Unit
foreign func qDockWidgetWidget(ptr: Int64): Int64
foreign func qDockWidgetSetWindowTitle(ptr: Int64, title: CString): Unit
foreign func qDockWidgetSetAllowedAreas(ptr: Int64, areas: Int32): Unit
foreign func qDockWidgetSetFeatures(ptr: Int64, features: Int32): Unit
foreign func qDockWidgetSetFloating(ptr: Int64, floating: Int32): Unit
foreign func qDockWidgetIsFloating(ptr: Int64): Int32

// DockWidgetArea
public class DockWidgetArea {
    public static let Left: Int32 = 1
    public static let Right: Int32 = 2
    public static let Top: Int32 = 4
    public static let Bottom: Int32 = 8
    public static let All: Int32 = 15
}

// DockWidgetFeature
public class DockWidgetFeature {
    public static let Closable: Int32 = 1
    public static let Movable: Int32 = 2
    public static let Floatable: Int32 = 4
    public static let AllFeatures: Int32 = 7
    public static let NoFeature: Int32 = 0
}

public class QDockWidget {
    private var ptr: Int64 = 0

    public init(title: String, parent!: Int64 = 0) {
        unsafe {
            var cstr = LibC.mallocCString(title)
            ptr = qDockWidgetCreate(cstr)
            LibC.free(cstr)
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

    public func setWidget(widgetPtr: Int64) {
        unsafe {
            qDockWidgetSetWidget(ptr, widgetPtr)
        }
    }

    public func widget(): Int64 {
        unsafe {
            qDockWidgetWidget(ptr)
        }
    }

    public func setWindowTitle(title: String) {
        unsafe {
            var cstr = LibC.mallocCString(title)
            qDockWidgetSetWindowTitle(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func setAllowedAreas(areas: Int32) {
        unsafe {
            qDockWidgetSetAllowedAreas(ptr, areas)
        }
    }

    public func setFeatures(features: Int32) {
        unsafe {
            qDockWidgetSetFeatures(ptr, features)
        }
    }

    public func setFloating(floating: Bool) {
        unsafe {
            qDockWidgetSetFloating(ptr, if (floating) { 1 } else { 0 })
        }
    }

    public func isFloating(): Bool {
        unsafe {
            qDockWidgetIsFloating(ptr) == 1
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
                qDockWidgetDelete(ptr)
            }
            ptr = 0
        }
    }
}
