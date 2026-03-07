package CJQT6.core

// QWidget - 基础窗口部件
foreign func qWidgetCreate(): Int64
foreign func qWidgetShow(ptr: Int64): Unit
foreign func qWidgetHide(ptr: Int64): Unit
foreign func qWidgetSetTitle(ptr: Int64, title: CString): Unit
foreign func qWidgetResize(ptr: Int64, width: Int32, height: Int32): Unit
foreign func qWidgetSetGeometry(ptr: Int64, x: Int32, y: Int32, width: Int32, height: Int32): Unit
foreign func qWidgetSetLayout(widgetPtr: Int64, layoutPtr: Int64): Unit
foreign func qWidgetDelete(ptr: Int64): Unit

public class QWidget {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qWidgetCreate()
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
    
    public func setTitle(title: String) {
        unsafe {
            var cstr = LibC.mallocCString(title)
            qWidgetSetTitle(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }
    
    public func setGeometry(x: Int32, y: Int32, width: Int32, height: Int32) {
        unsafe {
            qWidgetSetGeometry(ptr, x, y, width, height)
        }
    }
    
    public func setLayout(layoutPtr: Int64) {
        unsafe {
            qWidgetSetLayout(ptr, layoutPtr)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qWidgetDelete(ptr)
            }
            ptr = 0
        }
    }
}