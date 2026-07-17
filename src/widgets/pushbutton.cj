package cjqt6.widgets

import cjqt6.core.*

// QPushButton - 按钮
foreign func qButtonCreate(): Int64
foreign func qButtonSetText(ptr: Int64, text: CString): Unit
foreign func qButtonConnectClicked(ptr: Int64, callback: VoidCallback): Unit
foreign func qButtonDisconnectClicked(ptr: Int64): Unit
foreign func qButtonSetIcon(ptr: Int64, iconPath: CString): Unit
foreign func qButtonSetIconSize(ptr: Int64, width: Int32, height: Int32): Unit
foreign func qButtonSetStandardIcon(ptr: Int64, iconType: Int32): Unit
foreign func qButtonSetCheckable(ptr: Int64, checkable: Bool): Unit
foreign func qButtonSetChecked(ptr: Int64, checked: Bool): Unit
foreign func qButtonIsChecked(ptr: Int64): Bool
foreign func qButtonSetDefault(ptr: Int64, isDefault: Bool): Unit
foreign func qButtonSetFlat(ptr: Int64, flat: Bool): Unit
foreign func qButtonDelete(ptr: Int64): Unit

/// 标准图标类型枚举
public class StandardIcon {
    public static let Open: Int32 = 0
    public static let Save: Int32 = 1
    public static let Close: Int32 = 2
    public static let Apply: Int32 = 3
    public static let Cancel: Int32 = 4
    public static let Help: Int32 = 5
    public static let File: Int32 = 6
    public static let Folder: Int32 = 7
    public static let NewFolder: Int32 = 8
    public static let Link: Int32 = 9
    public static let Reload: Int32 = 10
    public static let Stop: Int32 = 11
    public static let MediaPlay: Int32 = 12
    public static let MediaPause: Int32 = 13
    public static let MediaStop: Int32 = 14
    public static let MediaForward: Int32 = 15
    public static let MediaBackward: Int32 = 16
    public static let MediaSkipForward: Int32 = 17
    public static let MediaSkipBackward: Int32 = 18
    public static let ArrowUp: Int32 = 19
    public static let ArrowDown: Int32 = 20
    public static let ArrowLeft: Int32 = 21
    public static let ArrowRight: Int32 = 22
    public static let Yes: Int32 = 23
    public static let No: Int32 = 24
}

/// 按钮部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QPushButton <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    /// 创建按钮
    public init() {
        unsafe {
            ptr = qButtonCreate()
            if (ptr == 0) {
                throw CreateFailedException("QPushButton 创建失败")
            }
        }
    }
    
    /// 显示按钮
    public func show(): Unit {
        checkValid()
        unsafe {
            qWidgetShow(ptr)
        }
    }
    
    /// 隐藏按钮
    public func hide(): Unit {
        checkValid()
        unsafe {
            qWidgetHide(ptr)
        }
    }
    
    /// 设置按钮文本
    public func setText(text: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            qButtonSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置按钮图标（从文件路径）
    /// 支持格式：PNG, JPG, SVG, ICO 等
    public func setIcon(iconPath: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(iconPath)
            qButtonSetIcon(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置按钮图标大小
    public func setIconSize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qButtonSetIconSize(ptr, width, height)
        }
    }
    
    /// 设置按钮使用 Qt 标准图标
    /// 使用 StandardIcon 类中的常量
    public func setStandardIcon(iconType: Int32): Unit {
        checkValid()
        unsafe {
            qButtonSetStandardIcon(ptr, iconType)
        }
    }
    
    /// 调整按钮大小
    public func resize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }
    
    /// 设置样式表
    public func setStyleSheet(style: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置点击回调
    public func setOnClick(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qButtonConnectClicked(ptr, callback)
        }
    }
    
    /// 断开点击信号
    public func disconnectClick(): Unit {
        if (ptr != 0) {
            unsafe {
                qButtonDisconnectClicked(ptr)
            }
        }
    }
    
    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 是否已关闭
    public func isClosed(): Bool {
        return closed
    }
    
    /// 检查对象有效性
    public func isValid(): Bool {
        return !closed && ptr != 0
    }
    
    /// 检查有效性，无效时抛出异常
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QPushButton 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QPushButton 指针为空")
        }
    }
    
    /// 关闭资源，释放Qt对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qButtonDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除按钮（兼容旧API）
    public func delete(): Unit {
        close()
    }
    
    /// 终结器 - 已禁用
    /// 注意：仓颉 GC 调用终结器的时机不确定，可能在 Qt 对象仍被使用时提前删除导致崩溃
    /// 请在不需要时显式调用 delete() 或 close() 释放资源
    // ~init() {
    //     if (!closed && ptr != 0) {
    //         unsafe {
    //             qSignalCleanup(ptr)
    //             qButtonDelete(ptr)
    //         }
    //         closed = true
    //         ptr = 0
    //     }
    // }
}
