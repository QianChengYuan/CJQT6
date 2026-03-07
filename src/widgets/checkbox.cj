package CJQT6.widgets

// QCheckBox - 复选框
foreign func qCheckBoxCreate(): Int64
foreign func qCheckBoxSetText(ptr: Int64, text: CString): Unit
foreign func qCheckBoxSetChecked(ptr: Int64, checked: Bool): Unit
foreign func qCheckBoxIsChecked(ptr: Int64): Bool
foreign func qCheckBoxDelete(ptr: Int64): Unit

public class QCheckBox {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qCheckBoxCreate()
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
            qCheckBoxSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setChecked(checked: Bool) {
        unsafe {
            qCheckBoxSetChecked(ptr, checked)
        }
    }
    
    public func isChecked(): Bool {
        unsafe {
            qCheckBoxIsChecked(ptr)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qCheckBoxDelete(ptr)
            }
            ptr = 0
        }
    }
}