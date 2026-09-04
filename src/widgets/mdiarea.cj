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
foreign func qMdiAreaSubWindowCount(ptr: Int64): Int32
foreign func qMdiAreaSetActiveSubWindow(ptr: Int64, subWinPtr: Int64): Unit
foreign func qMdiAreaViewMode(ptr: Int64): Int32
foreign func qMdiAreaSetActivationOrder(ptr: Int64, order: Int32): Unit
foreign func qMdiAreaActivationOrder(ptr: Int64): Int32
foreign func qMdiAreaSetBackground(ptr: Int64, path: CString): Unit
foreign func qMdiAreaConnectSubWindowActivated(ptr: Int64, callback: Int64Callback): Unit

// QMdiSubWindow
foreign func qMdiSubWindowSetWidget(ptr: Int64, widgetPtr: Int64): Unit
foreign func qMdiSubWindowWidget(ptr: Int64): Int64
foreign func qMdiSubWindowDelete(ptr: Int64): Unit
foreign func qMdiSubWindowShowShaded(ptr: Int64): Unit
foreign func qMdiSubWindowIsShaded(ptr: Int64): Int32

// QMdiArea ViewMode
public class MdiAreaViewMode {
    public static let SubWindowView: Int32 = 0
    public static let TabbedView: Int32 = 1
}

// QMdiArea 激活顺序（对应 QMdiArea::WindowOrder）
public class MdiAreaActivationOrder {
    public static let CreationOrder: Int32 = 0
    public static let StackingOrder: Int32 = 1
    public static let ActivationHistoryOrder: Int32 = 2
}

/// 多文档界面区域，管理多个子窗口的平铺/层叠/排列
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

    public func addSubWindow(widgetPtr: Int64): Int64 {
        unsafe {
            qMdiAreaAddSubWindow(ptr, widgetPtr)
        }
    }

    public func removeSubWindow(subWinPtr: Int64): Unit {
        unsafe {
            qMdiAreaRemoveSubWindow(ptr, subWinPtr)
        }
    }

    public func currentSubWindow(): Int64 {
        unsafe {
            qMdiAreaCurrentSubWindow(ptr)
        }
    }

    public func cascadeSubWindows(): Unit {
        unsafe {
            qMdiAreaCascadeSubWindows(ptr)
        }
    }

    public func tileSubWindows(): Unit {
        unsafe {
            qMdiAreaTileSubWindows(ptr)
        }
    }

    public func closeAllSubWindows(): Unit {
        unsafe {
            qMdiAreaCloseAllSubWindows(ptr)
        }
    }

    public func setViewMode(mode: Int32): Unit {
        unsafe {
            qMdiAreaSetViewMode(ptr, mode)
        }
    }

    /// 获取视图模式
    public func viewMode(): Int32 {
        unsafe {
            qMdiAreaViewMode(ptr)
        }
    }

    /// 获取当前子窗口数量
    public func subWindowCount(): Int32 {
        unsafe {
            qMdiAreaSubWindowCount(ptr)
        }
    }

    /// 设置当前激活的子窗口
    public func setActiveSubWindow(subWinPtr: Int64): Unit {
        unsafe {
            qMdiAreaSetActiveSubWindow(ptr, subWinPtr)
        }
    }

    /// 设置子窗口激活顺序
    public func setActivationOrder(order: Int32): Unit {
        unsafe {
            qMdiAreaSetActivationOrder(ptr, order)
        }
    }

    /// 获取子窗口激活顺序
    public func activationOrder(): Int32 {
        unsafe {
            qMdiAreaActivationOrder(ptr)
        }
    }

    /// 设置背景（按图片文件路径作为纹理笔刷）
    public func setBackground(path: String): Unit {
        unsafe {
            withCString(path) { c => qMdiAreaSetBackground(ptr, c) }
        }
    }

    /// 子窗口激活回调（子窗口指针，未激活时为 0）
    public func setOnSubWindowActivated(callback: Int64Callback): Unit {
        unsafe {
            qMdiAreaConnectSubWindowActivated(ptr, callback)
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

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qMdiAreaDelete(ptr)
            }
            ptr = 0
        }
    }
}

/// 多文档界面子窗口，由 QMdiArea 管理，可包含任意内容控件
public class QMdiSubWindow {
    private var ptr: Int64 = 0

    public init(ptr: Int64) {
        this.ptr = ptr
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
            qMdiSubWindowSetWidget(ptr, widgetPtr)
        }
    }

    public func widget(): Int64 {
        unsafe {
            qMdiSubWindowWidget(ptr)
        }
    }

    /// 以折叠（阴影）状态显示
    public func showShaded(): Unit {
        unsafe {
            qMdiSubWindowShowShaded(ptr)
        }
    }

    /// 是否处于折叠（阴影）状态
    public func isShaded(): Bool {
        unsafe {
            qMdiSubWindowIsShaded(ptr) != 0
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qMdiSubWindowDelete(ptr)
            }
            ptr = 0
        }
    }
}
