package cjqt6.widgets

import cjqt6.core.*

// QComboBox - 下拉框
foreign func qComboBoxCreate(): Int64
foreign func qComboBoxAddItem(ptr: Int64, text: CString): Unit
foreign func qComboBoxCurrentText(ptr: Int64): CString
foreign func qComboBoxSetCurrentIndex(ptr: Int64, index: Int32): Unit
foreign func qComboBoxCurrentIndex(ptr: Int64): Int32
foreign func qComboBoxClear(ptr: Int64): Unit
foreign func qComboBoxConnectCurrentIndexChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qComboBoxDisconnectCurrentIndexChanged(ptr: Int64): Unit
foreign func qComboBoxDelete(ptr: Int64): Unit

/// 下拉框部件
public class QComboBox {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qComboBoxCreate()
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
    
    public func addItem(text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qComboBoxAddItem(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func currentText(): String {
        unsafe {
            let cstr = qComboBoxCurrentText(ptr)
            return cstr.toString()
        }
    }
    
    public func setCurrentIndex(index: Int32) {
        unsafe {
            qComboBoxSetCurrentIndex(ptr, index)
        }
    }
    
    public func currentIndex(): Int32 {
        unsafe {
            return qComboBoxCurrentIndex(ptr)
        }
    }
    
    public func clear() {
        unsafe {
            qComboBoxClear(ptr)
        }
    }
    
    /// 设置当前索引变化回调
    public func setOnCurrentIndexChanged(callback: Int32Callback) {
        unsafe {
            qComboBoxConnectCurrentIndexChanged(ptr, callback)
        }
    }
    
    /// 断开索引变化信号
    public func disconnectCurrentIndexChanged() {
        unsafe {
            qComboBoxDisconnectCurrentIndexChanged(ptr)
        }
    }
    
    /// 设置当前文本变化回调
    public func setOnCurrentTextChanged(callback: CStringCallback) {
        checkValid()
        unsafe {
            qComboBoxConnectCurrentTextChanged(ptr, callback)
        }
    }
    
    /// 断开当前文本变化回调
    public func disconnectCurrentTextChanged() {
        unsafe {
            qComboBoxDisconnectCurrentTextChanged(ptr)
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除下拉框
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qComboBoxDelete(ptr)
            }
            ptr = 0
        }
    }
}