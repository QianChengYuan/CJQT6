package CJQT6.widgets

import CJQT6.core.*

// QCheckBox - 复选框
foreign func qCheckBoxCreate(): Int64
foreign func qCheckBoxSetText(ptr: Int64, text: CString): Unit
foreign func qCheckBoxSetChecked(ptr: Int64, checked: Bool): Unit
foreign func qCheckBoxIsChecked(ptr: Int64): Bool
foreign func qCheckBoxConnectStateChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qCheckBoxDisconnectStateChanged(ptr: Int64): Unit
foreign func qCheckBoxDelete(ptr: Int64): Unit

/// 复选框部件
public class QCheckBox {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qCheckBoxCreate()
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
    
    public func setText(text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qCheckBoxSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setChecked(checked: Bool) {
        unsafe {
            qCheckBoxSetChecked(ptr, checked)
        }
    }
    
    public func isChecked(): Bool {
        unsafe {
            return qCheckBoxIsChecked(ptr)
        }
    }
    
    /// 设置状态变化回调
    public func setOnStateChanged(callback: Int32Callback) {
        unsafe {
            qCheckBoxConnectStateChanged(ptr, callback)
        }
    }
    
    /// 断开状态变化信号
    public func disconnectStateChanged() {
        unsafe {
            qCheckBoxDisconnectStateChanged(ptr)
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除复选框
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qCheckBoxDelete(ptr)
            }
            ptr = 0
        }
    }
}