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
foreign func qDockWidgetFeatures(ptr: Int64): Int32
foreign func qDockWidgetAllowedAreas(ptr: Int64): Int32
foreign func qDockWidgetSetVisible(ptr: Int64, visible: Int32): Unit
foreign func qDockWidgetToggleViewAction(ptr: Int64): Int64
foreign func qDockWidgetConnectTopLevelChanged(ptr: Int64, callback: BoolCallback): Unit
foreign func qDockWidgetConnectVisibilityChanged(ptr: Int64, callback: BoolCallback): Unit
foreign func qDockWidgetConnectDockLocationChanged(ptr: Int64, callback: Int32Callback): Unit

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

/// 停靠窗口，可浮动/移动/关闭，停靠到主窗口边缘区域（配合 QMainWindow 使用）
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

    /// 获取停靠窗口特性（DockWidgetFeature 位或值）
    public func features(): Int32 {
        unsafe {
            qDockWidgetFeatures(ptr)
        }
    }

    /// 获取允许的停靠区域（DockWidgetArea 位或值）
    public func allowedAreas(): Int32 {
        unsafe {
            qDockWidgetAllowedAreas(ptr)
        }
    }

    /// 设置可见性
    public func setVisible(visible: Bool) {
        unsafe {
            qDockWidgetSetVisible(ptr, if (visible) { 1 } else { 0 })
        }
    }

    /// 返回切换视图动作指针（QAction*，用于加入工具栏）
    public func toggleViewAction(): Int64 {
        unsafe {
            qDockWidgetToggleViewAction(ptr)
        }
    }

    /// 顶层状态变化回调（是否变为浮动顶层窗口）
    public func setOnTopLevelChanged(callback: BoolCallback) {
        unsafe {
            qDockWidgetConnectTopLevelChanged(ptr, callback)
        }
    }

    /// 可见性变化回调
    public func setOnVisibilityChanged(callback: BoolCallback) {
        unsafe {
            qDockWidgetConnectVisibilityChanged(ptr, callback)
        }
    }

    /// 停靠位置变化回调（DockWidgetArea 值）
    public func setOnDockLocationChanged(callback: Int32Callback) {
        unsafe {
            qDockWidgetConnectDockLocationChanged(ptr, callback)
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
