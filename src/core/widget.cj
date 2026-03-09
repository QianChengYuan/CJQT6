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

// QWidget 样式表和扩展功能
foreign func qWidgetSetStyleSheet(ptr: Int64, styleSheet: CString): Unit
foreign func qWidgetStyleSheet(ptr: Int64): CString
foreign func qWidgetSetEnabled(ptr: Int64, enabled: Int32): Unit
foreign func qWidgetIsEnabled(ptr: Int64): Int32
foreign func qWidgetSetVisible(ptr: Int64, visible: Int32): Unit
foreign func qWidgetIsVisible(ptr: Int64): Int32
foreign func qWidgetSetToolTip(ptr: Int64, toolTip: CString): Unit
foreign func qWidgetSetMinimumSize(ptr: Int64, width: Int32, height: Int32): Unit
foreign func qWidgetSetMaximumSize(ptr: Int64, width: Int32, height: Int32): Unit
foreign func qWidgetWidth(ptr: Int64): Int32
foreign func qWidgetHeight(ptr: Int64): Int32
foreign func qWidgetUpdate(ptr: Int64): Unit
foreign func qWidgetRepaint(ptr: Int64): Unit

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
    
    // ========== 样式表和扩展功能 ==========
    
    public func setStyleSheet(styleSheet: String) {
        unsafe {
            var cstr = LibC.mallocCString(styleSheet)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func styleSheet(): String {
        unsafe {
            let cstr = qWidgetStyleSheet(ptr)
            cstr.toString()
        }
    }
    
    public func setEnabled(enabled: Bool) {
        unsafe {
            qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }
    
    public func isEnabled(): Bool {
        unsafe {
            qWidgetIsEnabled(ptr) == 1
        }
    }
    
    public func setVisible(visible: Bool) {
        unsafe {
            qWidgetSetVisible(ptr, if (visible) { 1 } else { 0 })
        }
    }
    
    public func isVisible(): Bool {
        unsafe {
            qWidgetIsVisible(ptr) == 1
        }
    }
    
    public func setToolTip(toolTip: String) {
        unsafe {
            var cstr = LibC.mallocCString(toolTip)
            qWidgetSetToolTip(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setMinimumSize(width: Int32, height: Int32) {
        unsafe {
            qWidgetSetMinimumSize(ptr, width, height)
        }
    }
    
    public func setMaximumSize(width: Int32, height: Int32) {
        unsafe {
            qWidgetSetMaximumSize(ptr, width, height)
        }
    }
    
    public func width(): Int32 {
        unsafe {
            qWidgetWidth(ptr)
        }
    }
    
    public func height(): Int32 {
        unsafe {
            qWidgetHeight(ptr)
        }
    }
    
    public func update() {
        unsafe {
            qWidgetUpdate(ptr)
        }
    }
    
    public func repaint() {
        unsafe {
            qWidgetRepaint(ptr)
        }
    }
}