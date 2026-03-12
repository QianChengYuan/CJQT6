package CJQT6.widgets

import CJQT6.core.*

// QSpinBox - 整数旋转框
foreign func qSpinBoxCreate(): Int64
foreign func qSpinBoxSetValue(ptr: Int64, value: Int32): Unit
foreign func qSpinBoxValue(ptr: Int64): Int32
foreign func qSpinBoxSetRange(ptr: Int64, min: Int32, max: Int32): Unit
foreign func qSpinBoxSetSingleStep(ptr: Int64, step: Int32): Unit
foreign func qSpinBoxConnectValueChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qSpinBoxDisconnectValueChanged(ptr: Int64): Unit
foreign func qSpinBoxDelete(ptr: Int64): Unit

/// 整数旋转框部件
public class QSpinBox {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qSpinBoxCreate()
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
    
    public func setValue(value: Int32) {
        unsafe {
            qSpinBoxSetValue(ptr, value)
        }
    }
    
    public func value(): Int32 {
        unsafe {
            return qSpinBoxValue(ptr)
        }
    }
    
    public func setRange(min: Int32, max: Int32) {
        unsafe {
            qSpinBoxSetRange(ptr, min, max)
        }
    }
    
    public func setSingleStep(step: Int32) {
        unsafe {
            qSpinBoxSetSingleStep(ptr, step)
        }
    }
    
    /// 设置值变化回调
    public func setOnValueChanged(callback: Int32Callback) {
        unsafe {
            qSpinBoxConnectValueChanged(ptr, callback)
        }
    }
    
    /// 断开值变化信号
    public func disconnectValueChanged() {
        unsafe {
            qSpinBoxDisconnectValueChanged(ptr)
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
                qSpinBoxDelete(ptr)
            }
            ptr = 0
        }
    }
}
