package cjqt6.widgets

import cjqt6.core.*

// QRadioButton - 单选按钮
foreign func qRadioButtonCreate(): Int64
foreign func qRadioButtonSetText(ptr: Int64, text: CString): Unit
foreign func qRadioButtonText(ptr: Int64): CString
foreign func qRadioButtonSetChecked(ptr: Int64, checked: Bool): Unit
foreign func qRadioButtonIsChecked(ptr: Int64): Bool
foreign func qRadioButtonConnectToggled(ptr: Int64, callback: Int32Callback): Unit
foreign func qRadioButtonDisconnectToggled(ptr: Int64): Unit
foreign func qRadioButtonDelete(ptr: Int64): Unit
foreign func qRadioButtonSetAutoExclusive(ptr: Int64, v: Int32): Unit
foreign func qRadioButtonIsAutoExclusive(ptr: Int64): Int32
foreign func qRadioButtonConnectClicked(ptr: Int64, callback: Int32Callback): Unit

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
    
    public func text(): String {
        unsafe {
            let cstr = qRadioButtonText(ptr)
            return cstr.toString()
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
    
    /// 设置启用/禁用
    public func setEnabled(enabled: Bool) {
        unsafe {
            qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }
    
    /// 检查是否启用
    public func isEnabled(): Bool {
        unsafe {
            qWidgetIsEnabled(ptr) == 1
        }
    }
    
    /// 设置样式表
    public func setStyleSheet(style: String) {
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置最小尺寸
    public func setMinimumSize(minw: Int32, minh: Int32) {
        unsafe {
            qWidgetSetMinimumSize(ptr, minw, minh)
        }
    }
    
    /// 设置最大尺寸
    public func setMaximumSize(maxw: Int32, maxh: Int32) {
        unsafe {
            qWidgetSetMaximumSize(ptr, maxw, maxh)
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
    
    /// 断开该单选按钮的全部信号（toggled）
    public func disconnect(): Unit {
        disconnectToggled()
    }
    
    /// 设置是否自动互斥（同父容器内自动排他）
    public func setAutoExclusive(autoExclusive: Bool) {
        unsafe {
            qRadioButtonSetAutoExclusive(ptr, if (autoExclusive) { 1 } else { 0 })
        }
    }
    
    /// 是否自动互斥
    public func isAutoExclusive(): Bool {
        unsafe {
            return qRadioButtonIsAutoExclusive(ptr) != 0
        }
    }
    
    /// 点击回调（带 checked 状态，0/1）
    public func setOnClicked(callback: Int32Callback) {
        unsafe {
            qRadioButtonConnectClicked(ptr, callback)
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