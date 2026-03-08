package CJQT6.widgets

// QComboBox - 下拉框
foreign func qComboBoxCreate(): Int64
foreign func qComboBoxAddItem(ptr: Int64, text: CString): Unit
foreign func qComboBoxCurrentText(ptr: Int64): CString
foreign func qComboBoxSetCurrentIndex(ptr: Int64, index: Int32): Unit
foreign func qComboBoxCurrentIndex(ptr: Int64): Int32
foreign func qComboBoxClear(ptr: Int64): Unit
foreign func qComboBoxDelete(ptr: Int64): Unit

public class QComboBox {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qComboBoxCreate()
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
    
    public func addItem(text: String) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            qComboBoxAddItem(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func currentText(): String {
        unsafe {
            let cstr = qComboBoxCurrentText(ptr)
            let result = cstr.toString()
            // 注意：cstr指向静态缓冲区，不要free
            return result
        }
    }
    
    public func setCurrentIndex(index: Int32) {
        unsafe {
            qComboBoxSetCurrentIndex(ptr, index)
        }
    }
    
    public func currentIndex(): Int32 {
        unsafe {
            qComboBoxCurrentIndex(ptr)
        }
    }
    
    public func clear() {
        unsafe {
            qComboBoxClear(ptr)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qComboBoxDelete(ptr)
            }
            ptr = 0
        }
    }
}