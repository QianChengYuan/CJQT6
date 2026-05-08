package cjqt6.widgets

import cjqt6.core.*

// QSlider - 滑动条
foreign func qSliderCreate(): Int64
foreign func qSliderSetValue(ptr: Int64, value: Int32): Unit
foreign func qSliderValue(ptr: Int64): Int32
foreign func qSliderSetRange(ptr: Int64, min: Int32, max: Int32): Unit
foreign func qSliderSetOrientation(ptr: Int64, orientation: Int32): Unit
foreign func qSliderConnectValueChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qSliderDisconnectValueChanged(ptr: Int64): Unit
foreign func qSliderConnectSliderMoved(ptr: Int64, callback: Int32Callback): Unit
foreign func qSliderDisconnectSliderMoved(ptr: Int64): Unit
foreign func qSliderDelete(ptr: Int64): Unit

/// 滑动条方向常量
public const Horizontal: Int32 = 1
public const Vertical: Int32 = 2

/// 滑动条部件
public class QSlider {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qSliderCreate()
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
            qSliderSetValue(ptr, value)
        }
    }
    
    public func value(): Int32 {
        unsafe {
            return qSliderValue(ptr)
        }
    }
    
    public func setRange(min: Int32, max: Int32) {
        unsafe {
            qSliderSetRange(ptr, min, max)
        }
    }
    
    public func setOrientation(orientation: Int32) {
        unsafe {
            qSliderSetOrientation(ptr, orientation)
        }
    }
    
    /// 设置值变化回调
    public func setOnValueChanged(callback: Int32Callback) {
        unsafe {
            qSliderConnectValueChanged(ptr, callback)
        }
    }
    
    /// 断开值变化信号
    public func disconnectValueChanged() {
        unsafe {
            qSliderDisconnectValueChanged(ptr)
        }
    }
    
    /// 设置滑块拖动回调（拖动过程中实时触发）
    public func setOnSliderMoved(callback: Int32Callback) {
        unsafe {
            qSliderConnectSliderMoved(ptr, callback)
        }
    }
    
    /// 断开滑块拖动信号
    public func disconnectSliderMoved() {
        unsafe {
            qSliderDisconnectSliderMoved(ptr)
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除滑动条
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qSliderDelete(ptr)
            }
            ptr = 0
        }
    }
}
