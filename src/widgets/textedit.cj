package CJQT6.widgets

// QTextEdit - 多行文本编辑框
foreign func qTextEditCreate(): Int64
foreign func qTextEditSetText(ptr: Int64, text: CString): Unit
foreign func qTextEditText(ptr: Int64): CString
foreign func qTextEditSetReadOnly(ptr: Int64, readonly: Bool): Unit
foreign func qTextEditClear(ptr: Int64): Unit
foreign func qTextEditDelete(ptr: Int64): Unit

public class QTextEdit {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qTextEditCreate()
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
            qTextEditSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func text(): String {
        unsafe {
            let cstr = qTextEditText(ptr)
            let result = cstr.toString()
            LibC.free(cstr)
            return result
        }
    }
    
    public func setReadOnly(readonly: Bool) {
        unsafe {
            qTextEditSetReadOnly(ptr, readonly)
        }
    }
    
    public func clear() {
        unsafe {
            qTextEditClear(ptr)
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
                qTextEditDelete(ptr)
            }
            ptr = 0
        }
    }
}