package CJQT6.widgets

// QProgressBar - 进度条
foreign func qProgressBarCreate(): Int64
foreign func qProgressBarSetValue(ptr: Int64, value: Int32): Unit
foreign func qProgressBarValue(ptr: Int64): Int32
foreign func qProgressBarSetRange(ptr: Int64, min: Int32, max: Int32): Unit
foreign func qProgressBarSetTextVisible(ptr: Int64, visible: Bool): Unit
foreign func qProgressBarDelete(ptr: Int64): Unit

public class QProgressBar {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qProgressBarCreate()
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
            qProgressBarSetValue(ptr, value)
        }
    }
    
    public func value(): Int32 {
        unsafe {
            qProgressBarValue(ptr)
        }
    }
    
    public func setRange(min: Int32, max: Int32) {
        unsafe {
            qProgressBarSetRange(ptr, min, max)
        }
    }
    
    public func setTextVisible(visible: Bool) {
        unsafe {
            qProgressBarSetTextVisible(ptr, visible)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qProgressBarDelete(ptr)
            }
            ptr = 0
        }
    }
}