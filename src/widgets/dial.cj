package cjqt6.widgets

import cjqt6.core.*

// QDial - 旋钮控件
foreign func qDialCreate(): Int64
foreign func qDialSetValue(ptr: Int64, value: Int32): Unit
foreign func qDialValue(ptr: Int64): Int32
foreign func qDialSetRange(ptr: Int64, min: Int32, max: Int32): Unit
foreign func qDialSetSingleStep(ptr: Int64, step: Int32): Unit
foreign func qDialSetWrapping(ptr: Int64, wrapping: Bool): Unit
foreign func qDialWrapping(ptr: Int64): Bool
foreign func qDialSetNotchesVisible(ptr: Int64, visible: Bool): Unit
foreign func qDialNotchesVisible(ptr: Int64): Bool
foreign func qDialDelete(ptr: Int64): Unit
foreign func qDialConnectValueChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qDialDisconnectValueChanged(ptr: Int64): Unit

/// 旋钮控件部件
public class QDial {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qDialCreate()
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
    
    public func setValue(value: Int32) {
        unsafe {
            qDialSetValue(ptr, value)
        }
    }
    
    public func value(): Int32 {
        unsafe {
            return qDialValue(ptr)
        }
    }
    
    public func setRange(min: Int32, max: Int32) {
        unsafe {
            qDialSetRange(ptr, min, max)
        }
    }
    
    public func setSingleStep(step: Int32) {
        unsafe {
            qDialSetSingleStep(ptr, step)
        }
    }
    
    /// 设置是否循环
    public func setWrapping(wrapping: Bool) {
        unsafe {
            qDialSetWrapping(ptr, wrapping)
        }
    }
    
    /// 获取是否循环
    public func wrapping(): Bool {
        unsafe {
            return qDialWrapping(ptr)
        }
    }
    
    /// 设置刻度是否可见
    public func setNotchesVisible(visible: Bool) {
        unsafe {
            qDialSetNotchesVisible(ptr, visible)
        }
    }
    
    /// 获取刻度是否可见
    public func notchesVisible(): Bool {
        unsafe {
            return qDialNotchesVisible(ptr)
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
    
    /// 设置值变化回调
    public func setOnValueChanged(callback: Int32Callback) {
        unsafe {
            qDialConnectValueChanged(ptr, callback)
        }
    }
    
    /// 断开值变化信号
    public func disconnectValueChanged() {
        unsafe {
            qDialDisconnectValueChanged(ptr)
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除旋钮
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qDialDelete(ptr)
            }
            ptr = 0
        }
    }
}
