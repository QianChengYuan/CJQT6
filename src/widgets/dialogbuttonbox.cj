package cjqt6.widgets

import cjqt6.core.*

// QDialogButtonBox 桥接函数
foreign func qDialogButtonBoxCreate(): Int64
foreign func qDialogButtonBoxAddButton(ptr: Int64, text: CString, role: Int32): Unit
foreign func qDialogButtonBoxSetStandardButtons(ptr: Int64, buttons: Int32): Unit
foreign func qDialogButtonBoxConnectAccepted(ptr: Int64, callback: VoidCallback): Unit
foreign func qDialogButtonBoxConnectRejected(ptr: Int64, callback: VoidCallback): Unit
foreign func qDialogButtonBoxDelete(ptr: Int64): Unit

/// 标准按钮组合辅助函数
public func makeStandardButtons(buttons: Array<Int32>): Int32 {
    var result: Int32 = Int32(0)
    for (button in buttons) {
        result = result | button
    }
    return result
}

/// 对话框标准按钮组部件
public class QDialogButtonBox {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qDialogButtonBoxCreate()
        }
    }
    
    public func show() {
        unsafe { qWidgetShow(ptr) }
    }
    
    public func hide() {
        unsafe { qWidgetHide(ptr) }
    }
    
    public func resize(width: Int32, height: Int32) {
        unsafe { qWidgetResize(ptr, width, height) }
    }
    
    /// 添加自定义按钮：text=按钮文字, role=按钮角色(ButtonRole枚举值)
    public func addButton(text: String, role: Int32) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qDialogButtonBoxAddButton(ptr, cstr, role)
            LibC.free(cstr)
        }
    }
    
    /// 设置标准按钮组合（使用 makeStandardButtons 组合 StandardButtons 值）
    public func setStandardButtons(buttons: Int32) {
        unsafe { qDialogButtonBoxSetStandardButtons(ptr, buttons) }
    }
    
    /// 设置接受信号回调
    public func setOnAccepted(callback: VoidCallback) {
        unsafe { qDialogButtonBoxConnectAccepted(ptr, callback) }
    }
    
    /// 设置拒绝信号回调
    public func setOnRejected(callback: VoidCallback) {
        unsafe { qDialogButtonBoxConnectRejected(ptr, callback) }
    }
    
    /// 设置启用/禁用
    public func setEnabled(enabled: Bool) {
        unsafe { qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 }) }
    }
    
    /// 设置样式表
    public func setStyleSheet(style: String) {
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除部件
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qDialogButtonBoxDelete(ptr)
            }
            ptr = 0
        }
    }
}

// ============================================================
// StandardButtons - 标准按钮常量
// ============================================================
public class StandardButtons {
    public static let Ok: Int32 = 0x00000400
    public static let Open: Int32 = 0x00002000
    public static let Save: Int32 = 0x00000800
    public static let Cancel: Int32 = 0x00400000
    public static let Close: Int32 = 0x00200000
    public static let Discard: Int32 = 0x00800000
    public static let Apply: Int32 = 0x02000000
    public static let Reset: Int32 = 0x04000000
    public static let RestoreDefaults: Int32 = 0x08000000
    public static let Help: Int32 = 0x01000000
    public static let SaveAll: Int32 = 0x00001000
    public static let Yes: Int32 = 0x00004000
    public static let YesToAll: Int32 = 0x00008000
    public static let No: Int32 = 0x00010000
    public static let NoToAll: Int32 = 0x00020000
    public static let Abort: Int32 = 0x00040000
    public static let Retry: Int32 = 0x00080000
    public static let Ignore: Int32 = 0x00100000
    public static let NoButton: Int32 = 0x00000000
}

// ============================================================
// ButtonRole - 按钮角色枚举值
// ============================================================
public class ButtonRole {
    public static let InvalidRole: Int32 = -1
    public static let AcceptRole: Int32 = 0
    public static let RejectRole: Int32 = 1
    public static let DestructiveRole: Int32 = 2
    public static let ActionRole: Int32 = 3
    public static let HelpRole: Int32 = 4
    public static let YesRole: Int32 = 5
    public static let NoRole: Int32 = 6
    public static let ApplyRole: Int32 = 8
    public static let ResetRole: Int32 = 7
}
