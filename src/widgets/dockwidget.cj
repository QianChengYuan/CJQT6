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
public class QDockWidget <: QtWidgetCore {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    public init(title: String, parent!: Int64 = 0) {
        unsafe {
            var cstr = LibC.mallocCString(title)
            ptr = qDockWidgetCreate(cstr)
            LibC.free(cstr)
            if (parent != 0) {
                setWidgetParent(ptr, parent)
            }
        }
        trackObject(ptr)
    }

    public func show(): Unit {
        unsafe {
            qWidgetShow(ptr)
        }
    }

    public func hide(): Unit {
        unsafe {
            qWidgetHide(ptr)
        }
    }

    public func resize(width: Int32, height: Int32): Unit {
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }

    public func setWidget(widgetPtr: Int64): Unit {
        unsafe {
            qDockWidgetSetWidget(ptr, widgetPtr)
        }
    }

    public func widget(): Int64 {
        unsafe {
            qDockWidgetWidget(ptr)
        }
    }

    public func setWindowTitle(title: String): Unit {
        unsafe {
            var cstr = LibC.mallocCString(title)
            qDockWidgetSetWindowTitle(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func setAllowedAreas(areas: Int32): Unit {
        unsafe {
            qDockWidgetSetAllowedAreas(ptr, areas)
        }
    }

    public func setFeatures(features: Int32): Unit {
        unsafe {
            qDockWidgetSetFeatures(ptr, features)
        }
    }

    public func setFloating(floating: Bool): Unit {
        unsafe {
            qDockWidgetSetFloating(ptr, if (floating) {
                1
            } else {
                0
            })
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
    public func setVisible(visible: Bool): Unit {
        unsafe {
            qDockWidgetSetVisible(ptr, if (visible) {
                1
            } else {
                0
            })
        }
    }

    /// 返回切换视图动作指针（QAction*，用于加入工具栏）
    public func toggleViewAction(): Int64 {
        unsafe {
            qDockWidgetToggleViewAction(ptr)
        }
    }

    /// 顶层状态变化回调（是否变为浮动顶层窗口）
    public func setOnTopLevelChanged(callback: BoolCallback): Unit {
        unsafe {
            qDockWidgetConnectTopLevelChanged(ptr, callback)
        }
    }

    /// 可见性变化回调
    public func setOnVisibilityChanged(callback: BoolCallback): Unit {
        unsafe {
            qDockWidgetConnectVisibilityChanged(ptr, callback)
        }
    }

    /// 停靠位置变化回调（DockWidgetArea 值）
    public func setOnDockLocationChanged(callback: Int32Callback): Unit {
        unsafe {
            qDockWidgetConnectDockLocationChanged(ptr, callback)
        }
    }

    public func setLayout(layoutPtr: Int64): Unit {
        unsafe {
            qWidgetSetLayout(ptr, layoutPtr)
        }
    }

    public func getPtr(): Int64 {
        ptr
    }

    /// 是否已关闭
    public func isClosed(): Bool {
        closed
    }

    /// 对象是否仍然可用
    public func isValid(): Bool {
        !closed && ptr != 0 && isObjectAlive(ptr)
    }

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QDockWidget 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QDockWidget 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QDockWidget 底层 Qt 对象已失效")
        }
    }

    /// 关闭资源，释放 Qt 对象（幂等）
    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            unsafe {
                qDockWidgetDelete(ptr)
            }
        }
        closed = true
        ptr = 0
    }

    /// 删除部件（兼容旧 API，等价于 close()）
    public func delete(): Unit {
        close()
    }
}
