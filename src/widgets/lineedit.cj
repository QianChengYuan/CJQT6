package CJQT6.widgets

// QLineEdit - 单行文本输入框
foreign func qLineEditCreate(): Int64
foreign func qLineEditSetText(ptr: Int64, text: CString): Unit
foreign func qLineEditText(ptr: Int64): CString
foreign func qLineEditSetPlaceholder(ptr: Int64, text: CString): Unit
foreign func qLineEditSetMaxLength(ptr: Int64, length: Int32): Unit
foreign func qLineEditSetReadOnly(ptr: Int64, readonly: Bool): Unit
foreign func qLineEditSetEchoMode(ptr: Int64, mode: Int32): Unit
foreign func qLineEditClear(ptr: Int64): Unit
foreign func qLineEditSetOnTextChanged(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit
foreign func qLineEditDelete(ptr: Int64): Unit

public class QLineEdit {
    private var ptr: Int64 = 0
    private var onTextChangedHandler: ?() -> Unit = None
    
    public init() {
        unsafe {
            ptr = qLineEditCreate()
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
            qLineEditSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func text(): String {
        unsafe {
            let cstr = qLineEditText(ptr)
            let result = cstr.toString()
            LibC.free(cstr)
            return result
        }
    }
    
    public func setPlaceholder(text: String) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            qLineEditSetPlaceholder(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setMaxLength(length: Int32) {
        unsafe {
            qLineEditSetMaxLength(ptr, length)
        }
    }
    
    public func setReadOnly(readonly: Bool) {
        unsafe {
            qLineEditSetReadOnly(ptr, readonly)
        }
    }
    
    public func setEchoMode(mode: Int32) {
        unsafe {
            qLineEditSetEchoMode(ptr, mode)
        }
    }
    
    public func clear() {
        unsafe {
            qLineEditClear(ptr)
        }
    }
    
    // 设置文本变化回调（CFunc方式）
    public func setOnTextChanged(callback: CFunc<(Int64) -> Unit>) {
        unsafe {
            qLineEditSetOnTextChanged(ptr, callback)
        }
    }
    
    // 触发文本变化事件
    public func emitTextChanged() {
        if (let Some(h) <- onTextChangedHandler) {
            h()
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
                qLineEditDelete(ptr)
            }
            ptr = 0
        }
    }
}