package CJQT6.widgets

// QPushButton - 按钮
foreign func qButtonCreate(): Int64
foreign func qButtonSetText(ptr: Int64, text: CString): Unit
foreign func qButtonSetOnClick(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit
foreign func qButtonDelete(ptr: Int64): Unit

public class QPushButton {
    private var ptr: Int64 = 0
    private var onClickHandler: ?() -> Unit = None
    
    public init() {
        unsafe {
            ptr = qButtonCreate()
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
            qButtonSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }
    
    // 设置点击回调（CFunc方式）
    public func setOnClick(callback: CFunc<(Int64) -> Unit>) {
        unsafe {
            qButtonSetOnClick(ptr, callback)
        }
    }
    
    // 连接点击信号（闭包方式）
    public func onClick(handler: () -> Unit) {
        onClickHandler = Some(handler)
        // 使用CFunc包装
        unsafe {
            qButtonSetOnClick(ptr, { _: Int64 => 
                // 注意：CFunc不能捕获外部变量，这里需要使用全局变量或其他方式
            })
        }
    }
    
    // 触发点击事件（内部调用）
    public func emitClick() {
        if (let Some(h) <- onClickHandler) {
            h()
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qButtonDelete(ptr)
            }
            ptr = 0
        }
    }
}