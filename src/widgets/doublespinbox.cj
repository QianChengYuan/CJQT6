package cjqt6.widgets

import cjqt6.core.*

// QDoubleSpinBox - 双精度旋转框
foreign func qDoubleSpinBoxCreate(): Int64
foreign func qDoubleSpinBoxSetValue(ptr: Int64, value: Float64): Unit
foreign func qDoubleSpinBoxValue(ptr: Int64): Float64
foreign func qDoubleSpinBoxSetRange(ptr: Int64, min: Float64, max: Float64): Unit
foreign func qDoubleSpinBoxSetSingleStep(ptr: Int64, step: Float64): Unit
foreign func qDoubleSpinBoxSetDecimals(ptr: Int64, decimals: Int32): Unit
foreign func qDoubleSpinBoxDecimals(ptr: Int64): Int32
foreign func qDoubleSpinBoxDelete(ptr: Int64): Unit
foreign func qDoubleSpinBoxConnectValueChanged(ptr: Int64, callback: Float64Callback): Unit
foreign func qDoubleSpinBoxDisconnectValueChanged(ptr: Int64): Unit

/// 双精度旋转框部件
public class QDoubleSpinBox {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qDoubleSpinBoxCreate()
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
    
    public func setValue(value: Float64) {
        unsafe {
            qDoubleSpinBoxSetValue(ptr, value)
        }
    }
    
    public func value(): Float64 {
        unsafe {
            return qDoubleSpinBoxValue(ptr)
        }
    }
    
    public func setRange(min: Float64, max: Float64) {
        unsafe {
            qDoubleSpinBoxSetRange(ptr, min, max)
        }
    }
    
    public func setSingleStep(step: Float64) {
        unsafe {
            qDoubleSpinBoxSetSingleStep(ptr, step)
        }
    }
    
    public func setDecimals(decimals: Int32) {
        unsafe {
            qDoubleSpinBoxSetDecimals(ptr, decimals)
        }
    }
    
    public func decimals(): Int32 {
        unsafe {
            return qDoubleSpinBoxDecimals(ptr)
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
    public func setOnValueChanged(callback: Float64Callback) {
        unsafe {
            qDoubleSpinBoxConnectValueChanged(ptr, callback)
        }
    }
    
    /// 断开值变化信号
    public func disconnectValueChanged() {
        unsafe {
            qDoubleSpinBoxDisconnectValueChanged(ptr)
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除旋转框
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qDoubleSpinBoxDelete(ptr)
            }
            ptr = 0
        }
    }
}
