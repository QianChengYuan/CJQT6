package CJQT6.widgets

// QRadioButton - 单选按钮
foreign func qRadioButtonCreate(): Int64
foreign func qRadioButtonSetText(ptr: Int64, text: CString): Unit
foreign func qRadioButtonSetChecked(ptr: Int64, checked: Bool): Unit
foreign func qRadioButtonIsChecked(ptr: Int64): Bool
foreign func qRadioButtonDelete(ptr: Int64): Unit

public class QRadioButton {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qRadioButtonCreate()
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
            qRadioButtonSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setChecked(checked: Bool) {
        unsafe {
            qRadioButtonSetChecked(ptr, checked)
        }
    }
    
    public func isChecked(): Bool {
        unsafe {
            qRadioButtonIsChecked(ptr)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qRadioButtonDelete(ptr)
            }
            ptr = 0
        }
    }
}