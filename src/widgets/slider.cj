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
foreign func qSliderSetSingleStep(ptr: Int64, step: Int32): Unit
foreign func qSliderSingleStep(ptr: Int64): Int32
foreign func qSliderSetPageStep(ptr: Int64, step: Int32): Unit
foreign func qSliderPageStep(ptr: Int64): Int32
foreign func qSliderSetTickPosition(ptr: Int64, position: Int32): Unit
foreign func qSliderTickPosition(ptr: Int64): Int32
foreign func qSliderSetTickInterval(ptr: Int64, interval: Int32): Unit
foreign func qSliderTickInterval(ptr: Int64): Int32
foreign func qSliderSetInvertedControls(ptr: Int64, inverted: Bool): Unit
foreign func qSliderInvertedControls(ptr: Int64): Bool
foreign func qSliderSetTracking(ptr: Int64, enable: Bool): Unit
foreign func qSliderHasTracking(ptr: Int64): Bool
foreign func qSliderDeleteCleanup(ptr: Int64): Unit
foreign func qSliderSetOnSliderPressed(ptr: Int64, callback: Int64Callback): Unit
foreign func qSliderSetOnSliderReleased(ptr: Int64, callback: Int64Callback): Unit
foreign func qSliderDelete(ptr: Int64): Unit

/// 滑动条方向常量
public const Horizontal: Int32 = 1
public const Vertical: Int32 = 2

/// 刻度位置常量
public const NoTicks: Int32 = 0
public const TicksAbove: Int32 = 1
public const TicksBelow: Int32 = 2
public const TicksLeft: Int32 = 3
public const TicksRight: Int32 = 4
public const TicksBothSides: Int32 = 5

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
    
    /// 设置单步步长
    public func setSingleStep(step: Int32) {
        unsafe {
            qSliderSetSingleStep(ptr, step)
        }
    }
    
    /// 获取单步步长
    public func singleStep(): Int32 {
        unsafe {
            return qSliderSingleStep(ptr)
        }
    }
    
    /// 设置页步步长
    public func setPageStep(step: Int32) {
        unsafe {
            qSliderSetPageStep(ptr, step)
        }
    }
    
    /// 获取页步步长
    public func pageStep(): Int32 {
        unsafe {
            return qSliderPageStep(ptr)
        }
    }
    
    /// 设置刻度位置
    public func setTickPosition(position: Int32) {
        unsafe {
            qSliderSetTickPosition(ptr, position)
        }
    }
    
    /// 获取刻度位置
    public func tickPosition(): Int32 {
        unsafe {
            return qSliderTickPosition(ptr)
        }
    }
    
    /// 设置刻度间隔
    public func setTickInterval(interval: Int32) {
        unsafe {
            qSliderSetTickInterval(ptr, interval)
        }
    }
    
    /// 获取刻度间隔
    public func tickInterval(): Int32 {
        unsafe {
            return qSliderTickInterval(ptr)
        }
    }
    
    /// 设置反向控制
    public func setInvertedControls(inverted: Bool) {
        unsafe {
            qSliderSetInvertedControls(ptr, inverted)
        }
    }
    
    /// 获取反向控制
    public func invertedControls(): Bool {
        unsafe {
            return qSliderInvertedControls(ptr)
        }
    }
    
    /// 设置追踪模式（为true时拖动过程中实时触发valueChanged）
    public func setTracking(enable: Bool) {
        unsafe {
            qSliderSetTracking(ptr, enable)
        }
    }
    
    /// 是否启用追踪模式
    public func hasTracking(): Bool {
        unsafe {
            return qSliderHasTracking(ptr)
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
    
    /// 设置滑块按下回调
    public func setOnSliderPressed(callback: Int64Callback) {
        unsafe {
            qSliderSetOnSliderPressed(ptr, callback)
        }
    }
    
    /// 设置滑块释放回调
    public func setOnSliderReleased(callback: Int64Callback) {
        unsafe {
            qSliderSetOnSliderReleased(ptr, callback)
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
