package CJQT6.widgets

import CJQT6.core.*

// QRadioButton - 单选按钮
foreign func qRadioButtonCreate(): Int64
foreign func qRadioButtonSetText(ptr: Int64, text: CString): Unit
foreign func qRadioButtonSetChecked(ptr: Int64, checked: Bool): Unit
foreign func qRadioButtonIsChecked(ptr: Int64): Bool
foreign func qRadioButtonConnectToggled(ptr: Int64, callback: Int32Callback): Unit
foreign func qRadioButtonDisconnectToggled(ptr: Int64): Unit
foreign func qRadioButtonDelete(ptr: Int64): Unit

/// 单选按钮部件
public class QRadioButton {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qRadioButtonCreate()
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
    
    public func setText(text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qRadioButtonSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setChecked(checked: Bool) {
        unsafe {
            qRadioButtonSetChecked(ptr, checked)
        }
    }
    
    public func isChecked(): Bool {
        unsafe {
            return qRadioButtonIsChecked(ptr)
        }
    }
    
    /// 设置切换回调
    public func setOnToggled(callback: Int32Callback) {
        unsafe {
            qRadioButtonConnectToggled(ptr, callback)
        }
    }
    
    /// 断开切换信号
    public func disconnectToggled() {
        unsafe {
            qRadioButtonDisconnectToggled(ptr)
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除单选按钮
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qRadioButtonDelete(ptr)
            }
            ptr = 0
        }
    }
}