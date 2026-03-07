package CJQT6.widgets

// ============================================================
// 容器控件 FFI声明
// ============================================================

// QGroupBox - 分组框
foreign func qGroupBoxCreate(): Int64
foreign func qGroupBoxSetTitle(ptr: Int64, title: CString): Unit
foreign func qGroupBoxTitle(ptr: Int64): CString
foreign func qGroupBoxSetCheckable(ptr: Int64, checkable: Bool): Unit
foreign func qGroupBoxIsCheckable(ptr: Int64): Bool
foreign func qGroupBoxSetChecked(ptr: Int64, checked: Bool): Unit
foreign func qGroupBoxIsChecked(ptr: Int64): Bool
foreign func qGroupBoxDelete(ptr: Int64): Unit

// QTabWidget - 标签页
foreign func qTabWidgetCreate(): Int64
foreign func qTabWidgetAddTab(ptr: Int64, widgetPtr: Int64, title: CString): Unit
foreign func qTabWidgetRemoveTab(ptr: Int64, index: Int32): Unit
foreign func qTabWidgetCurrentIndex(ptr: Int64): Int32
foreign func qTabWidgetSetCurrentIndex(ptr: Int64, index: Int32): Unit
foreign func qTabWidgetCount(ptr: Int64): Int32
foreign func qTabWidgetDelete(ptr: Int64): Unit

// QScrollArea - 滚动区域
foreign func qScrollAreaCreate(): Int64
foreign func qScrollAreaSetWidget(ptr: Int64, widgetPtr: Int64): Unit
foreign func qScrollAreaSetWidgetResizable(ptr: Int64, resizable: Bool): Unit
foreign func qScrollAreaWidget(ptr: Int64): Int64
foreign func qScrollAreaDelete(ptr: Int64): Unit

// QFrame - 边框容器
foreign func qFrameCreate(): Int64
foreign func qFrameSetFrameShape(ptr: Int64, shape: Int32): Unit
foreign func qFrameSetFrameShadow(ptr: Int64, shadow: Int32): Unit
foreign func qFrameSetLineWidth(ptr: Int64, width: Int32): Unit
foreign func qFrameDelete(ptr: Int64): Unit

// ============================================================
// QGroupBox - 分组框
// ============================================================
public class QGroupBox {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qGroupBoxCreate()
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
            qGroupBoxSetTitle(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func title(): String {
        unsafe {
            let cstr = qGroupBoxTitle(ptr)
            let result = cstr.toString()
            LibC.free(cstr)
            return result
        }
    }
    
    public func setCheckable(checkable: Bool) {
        unsafe {
            qGroupBoxSetCheckable(ptr, checkable)
        }
    }
    
    public func isCheckable(): Bool {
        unsafe {
            qGroupBoxIsCheckable(ptr)
        }
    }
    
    public func setChecked(checked: Bool) {
        unsafe {
            qGroupBoxSetChecked(ptr, checked)
        }
    }
    
    public func isChecked(): Bool {
        unsafe {
            qGroupBoxIsChecked(ptr)
        }
    }
    
    public func setLayout(layoutPtr: Int64) {
        unsafe {
            qWidgetSetLayout(ptr, layoutPtr)
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
                qGroupBoxDelete(ptr)
            }
            ptr = 0
        }
    }
}

// ============================================================
// QTabWidget - 标签页
// ============================================================
public class QTabWidget {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qTabWidgetCreate()
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
    
    public func addTab(widgetPtr: Int64, title: String) {
        unsafe {
            var cstr = LibC.mallocCString(title)
            qTabWidgetAddTab(ptr, widgetPtr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func removeTab(index: Int32) {
        unsafe {
            qTabWidgetRemoveTab(ptr, index)
        }
    }
    
    public func currentIndex(): Int32 {
        unsafe {
            qTabWidgetCurrentIndex(ptr)
        }
    }
    
    public func setCurrentIndex(index: Int32) {
        unsafe {
            qTabWidgetSetCurrentIndex(ptr, index)
        }
    }
    
    public func count(): Int32 {
        unsafe {
            qTabWidgetCount(ptr)
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
                qTabWidgetDelete(ptr)
            }
            ptr = 0
        }
    }
}

// ============================================================
// QScrollArea - 滚动区域
// ============================================================
public class QScrollArea {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qScrollAreaCreate()
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
    
    public func setWidget(widgetPtr: Int64) {
        unsafe {
            qScrollAreaSetWidget(ptr, widgetPtr)
        }
    }
    
    public func setWidgetResizable(resizable: Bool) {
        unsafe {
            qScrollAreaSetWidgetResizable(ptr, resizable)
        }
    }
    
    public func widget(): Int64 {
        unsafe {
            qScrollAreaWidget(ptr)
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
                qScrollAreaDelete(ptr)
            }
            ptr = 0
        }
    }
}

// ============================================================
// QFrame - 边框容器
// ============================================================

// Frame形状
public const NoFrame: Int32 = 0
public const Box: Int32 = 1
public const Panel: Int32 = 2
public const WinPanel: Int32 = 3
public const HLine: Int32 = 4
public const VLine: Int32 = 5
public const StyledPanel: Int32 = 6

// Frame阴影
public const Plain: Int32 = 16
public const Raised: Int32 = 32
public const Sunken: Int32 = 48

public class QFrame {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qFrameCreate()
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
    
    public func setFrameShape(shape: Int32) {
        unsafe {
            qFrameSetFrameShape(ptr, shape)
        }
    }
    
    public func setFrameShadow(shadow: Int32) {
        unsafe {
            qFrameSetFrameShadow(ptr, shadow)
        }
    }
    
    public func setLineWidth(width: Int32) {
        unsafe {
            qFrameSetLineWidth(ptr, width)
        }
    }
    
    public func setLayout(layoutPtr: Int64) {
        unsafe {
            qWidgetSetLayout(ptr, layoutPtr)
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
                qFrameDelete(ptr)
            }
            ptr = 0
        }
    }
}
