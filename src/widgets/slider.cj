package CJQT6.widgets

// QSlider - 滑动条
foreign func qSliderCreate(): Int64
foreign func qSliderSetValue(ptr: Int64, value: Int32): Unit
foreign func qSliderValue(ptr: Int64): Int32
foreign func qSliderSetRange(ptr: Int64, min: Int32, max: Int32): Unit
foreign func qSliderSetOrientation(ptr: Int64, orientation: Int32): Unit
foreign func qSliderSetOnValueChanged(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit
foreign func qSliderDelete(ptr: Int64): Unit

// 滑动条方向常量
public const Horizontal: Int32 = 1
public const Vertical: Int32 = 2

public class QSlider {
    private var ptr: Int64 = 0
    private var onValueChangedHandler: ?(Int32) -> Unit = None
    
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
    
    public func setValue(value: Int32) {
        unsafe {
            qSliderSetValue(ptr, value)
        }
    }
    
    public func value(): Int32 {
        unsafe {
            qSliderValue(ptr)
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
    
    // 设置值变化回调（CFunc方式）
    public func setOnValueChanged(callback: CFunc<(Int64) -> Unit>) {
        unsafe {
            qSliderSetOnValueChanged(ptr, callback)
        }
    }
    
    // 连接值变化信号
    public func onValueChanged(handler: (Int32) -> Unit) {
        onValueChangedHandler = Some(handler)
    }
    
    // 触发值变化事件
    public func emitValueChanged() {
        if (let Some(h) <- onValueChangedHandler) {
            h(value())
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSliderDelete(ptr)
            }
            ptr = 0
        }
    }
}
