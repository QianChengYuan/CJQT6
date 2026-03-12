package CJQT6.widgets

import CJQT6.core.*

// QPushButton - 按钮
foreign func qButtonCreate(): Int64
foreign func qButtonSetText(ptr: Int64, text: CString): Unit
foreign func qButtonConnectClicked(ptr: Int64, callback: VoidCallback): Unit
foreign func qButtonDisconnectClicked(ptr: Int64): Unit
foreign func qButtonDelete(ptr: Int64): Unit

/// 按钮部件
public class QPushButton {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qButtonCreate()
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
            qButtonSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }
    
    /// 设置点击回调
    public func setOnClick(callback: VoidCallback) {
        unsafe {
            qButtonConnectClicked(ptr, callback)
        }
    }
    
    /// 断开点击信号
    public func disconnectClick() {
        unsafe {
            qButtonDisconnectClicked(ptr)
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除按钮
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qButtonDelete(ptr)
            }
            ptr = 0
        }
    }
}