package CJQT6.widgets

// QSpinBox - 整数旋转框
foreign func qSpinBoxCreate(): Int64
foreign func qSpinBoxSetValue(ptr: Int64, value: Int32): Unit
foreign func qSpinBoxValue(ptr: Int64): Int32
foreign func qSpinBoxSetRange(ptr: Int64, min: Int32, max: Int32): Unit
foreign func qSpinBoxSetSingleStep(ptr: Int64, step: Int32): Unit
foreign func qSpinBoxSetOnValueChanged(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit
foreign func qSpinBoxDelete(ptr: Int64): Unit

public class QSpinBox {
    private var ptr: Int64 = 0
    private var onValueChangedHandler: ?(Int32) -> Unit = None
    
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
            qSpinBoxValue(ptr)
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
    
    // 设置值变化回调（CFunc方式）
    public func setOnValueChanged(callback: CFunc<(Int64) -> Unit>) {
        unsafe {
            qSpinBoxSetOnValueChanged(ptr, callback)
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
                qSpinBoxDelete(ptr)
            }
            ptr = 0
        }
    }
}
