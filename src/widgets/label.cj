package CJQT6.widgets

// QLabel - 标签
foreign func qLabelCreate(): Int64
foreign func qLabelSetText(ptr: Int64, text: CString): Unit
foreign func qLabelSetAlignment(ptr: Int64, alignment: Int32): Unit
foreign func qLabelSetPixmap(ptr: Int64, pixmapPtr: Int64): Unit
foreign func qLabelDelete(ptr: Int64): Unit

public class QLabel {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qLabelCreate()
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
    
    public func setText(text: String) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            qLabelSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setAlignment(alignment: Int32) {
        unsafe {
            qLabelSetAlignment(ptr, alignment)
        }
    }
    
    public func setPixmap(pixmapPtr: Int64) {
        unsafe {
            qLabelSetPixmap(ptr, pixmapPtr)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qLabelDelete(ptr)
            }
            ptr = 0
        }
    }
}