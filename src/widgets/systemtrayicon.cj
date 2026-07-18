package cjqt6.widgets

import cjqt6.core.*

// QSystemTrayIcon - 系统托盘图标
foreign func qSystemTrayIconCreate(parentPtr: Int64): Int64
foreign func qSystemTrayIconDelete(ptr: Int64): Unit
foreign func qSystemTrayIconSetIcon(ptr: Int64, iconPath: CString): Unit
foreign func qSystemTrayIconSetToolTip(ptr: Int64, tip: CString): Unit
foreign func qSystemTrayIconShow(ptr: Int64): Unit
foreign func qSystemTrayIconHide(ptr: Int64): Unit
foreign func qSystemTrayIconIsVisible(ptr: Int64): Bool
foreign func qSystemTrayIconShowMessage(ptr: Int64, title: CString, message: CString, iconType: Int32, duration: Int32): Unit
foreign func qSystemTrayIconSetContextMenu(ptr: Int64, menuPtr: Int64): Unit

/// 托盘消息图标类型
public class MessageIcon {
    public static let Info: Int32 = 0
    public static let Warning: Int32 = 1
    public static let Critical: Int32 = 2
}

/// 系统托盘图标
/// 用于在系统托盘中显示图标、消息气泡和上下文菜单
/// 注意：QSystemTrayIcon 不是 QWidget，没有 show/hide/resize 方法
public class QSystemTrayIcon {
    private var ptr: Int64 = 0

    public init(parent!: Int64 = 0) {
        unsafe {
            ptr = qSystemTrayIconCreate(parent)
        }
    }

    /// 设置图标（从文件路径）
    public func setIcon(iconPath: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(iconPath)
            qSystemTrayIconSetIcon(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置工具提示
    public func setToolTip(tip: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(tip)
            qSystemTrayIconSetToolTip(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 显示托盘图标
    public func show(): Unit { unsafe { qSystemTrayIconShow(ptr) } }

    /// 隐藏托盘图标
    public func hide(): Unit { unsafe { qSystemTrayIconHide(ptr) } }

    /// 托盘图标是否可见
    public func isVisible(): Bool { unsafe { return qSystemTrayIconIsVisible(ptr) } }

    /// 显示消息气泡
    /// title: 标题
    /// message: 消息内容
    /// iconType: 图标类型（0=Info, 1=Warning, 2=Critical）
    /// duration: 显示时长（毫秒，默认10000）
    public func showMessage(title: String, message: String, iconType!: Int32 = MessageIcon.Info, duration!: Int32 = 10000): Unit {
        unsafe {
            let cstrTitle = LibC.mallocCString(title)
            let cstrMsg = LibC.mallocCString(message)
            qSystemTrayIconShowMessage(ptr, cstrTitle, cstrMsg, iconType, duration)
            LibC.free(cstrTitle)
            LibC.free(cstrMsg)
        }
    }

    /// 设置上下文菜单
    /// menuPtr: QMenu 对象指针
    public func setContextMenu(menuPtr: Int64): Unit {
        unsafe { qSystemTrayIconSetContextMenu(ptr, menuPtr) }
    }

    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }

    /// 删除系统托盘图标
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qSystemTrayIconDelete(ptr)
            }
            ptr = 0
        }
    }
}
