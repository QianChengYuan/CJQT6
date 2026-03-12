package CJQT6.widgets

import CJQT6.core.*

// QLineEdit - 单行文本输入框
foreign func qLineEditCreate(): Int64
foreign func qLineEditSetText(ptr: Int64, text: CString): Unit
foreign func qLineEditText(ptr: Int64): CString
foreign func qLineEditSetPlaceholder(ptr: Int64, text: CString): Unit
foreign func qLineEditSetMaxLength(ptr: Int64, length: Int32): Unit
foreign func qLineEditSetReadOnly(ptr: Int64, readonly: Bool): Unit
foreign func qLineEditSetEchoMode(ptr: Int64, mode: Int32): Unit
foreign func qLineEditClear(ptr: Int64): Unit
foreign func qLineEditConnectTextChanged(ptr: Int64, callback: CStringCallback): Unit
foreign func qLineEditDisconnectTextChanged(ptr: Int64): Unit
foreign func qLineEditDelete(ptr: Int64): Unit

/// 单行文本输入框部件
public class QLineEdit {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qLineEditCreate()
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
            qLineEditSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func text(): String {
        unsafe {
            let cstr = qLineEditText(ptr)
            return cstr.toString()
        }
    }
    
    public func setPlaceholder(text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qLineEditSetPlaceholder(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setMaxLength(length: Int32) {
        unsafe {
            qLineEditSetMaxLength(ptr, length)
        }
    }
    
    public func setReadOnly(readonly: Bool) {
        unsafe {
            qLineEditSetReadOnly(ptr, readonly)
        }
    }
    
    public func setEchoMode(mode: Int32) {
        unsafe {
            qLineEditSetEchoMode(ptr, mode)
        }
    }
    
    public func clear() {
        unsafe {
            qLineEditClear(ptr)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }
    
    /// 设置文本变化回调
    public func setOnTextChanged(callback: CStringCallback) {
        unsafe {
            qLineEditConnectTextChanged(ptr, callback)
        }
    }
    
    /// 断开文本变化信号
    public func disconnectTextChanged() {
        unsafe {
            qLineEditDisconnectTextChanged(ptr)
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除文本框
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qLineEditDelete(ptr)
            }
            ptr = 0
        }
    }
}