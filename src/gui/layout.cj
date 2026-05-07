package cjqt6.gui

// ============================================================
// 布局管理 FFI声明
// ============================================================

// QVBoxLayout - 垂直布局
foreign func qVBoxLayoutCreate(): Int64
foreign func qVBoxLayoutAddWidget(layoutPtr: Int64, widgetPtr: Int64): Unit
foreign func qVBoxLayoutAddLayout(layoutPtr: Int64, childLayoutPtr: Int64): Unit
foreign func qVBoxLayoutAddStretch(ptr: Int64): Unit
foreign func qVBoxLayoutSetSpacing(ptr: Int64, spacing: Int32): Unit
foreign func qVBoxLayoutSetMargin(ptr: Int64, margin: Int32): Unit
foreign func qVBoxLayoutDelete(ptr: Int64): Unit

// QHBoxLayout - 水平布局
foreign func qHBoxLayoutCreate(): Int64
foreign func qHBoxLayoutAddWidget(layoutPtr: Int64, widgetPtr: Int64): Unit
foreign func qHBoxLayoutAddLayout(layoutPtr: Int64, childLayoutPtr: Int64): Unit
foreign func qHBoxLayoutAddStretch(ptr: Int64): Unit
foreign func qHBoxLayoutSetSpacing(ptr: Int64, spacing: Int32): Unit
foreign func qHBoxLayoutSetMargin(ptr: Int64, margin: Int32): Unit
foreign func qHBoxLayoutDelete(ptr: Int64): Unit

// QGridLayout - 网格布局
foreign func qGridLayoutCreate(): Int64
foreign func qGridLayoutAddWidget(layoutPtr: Int64, widgetPtr: Int64, row: Int32, col: Int32): Unit
foreign func qGridLayoutAddWidgetSpan(layoutPtr: Int64, widgetPtr: Int64, row: Int32, col: Int32, rowSpan: Int32, colSpan: Int32): Unit
foreign func qGridLayoutSetSpacing(ptr: Int64, spacing: Int32): Unit
foreign func qGridLayoutSetMargin(ptr: Int64, margin: Int32): Unit
foreign func qGridLayoutDelete(ptr: Int64): Unit

// QWidget布局设置
foreign func qWidgetSetLayout(widgetPtr: Int64, layoutPtr: Int64): Unit

// ============================================================
// QVBoxLayout - 垂直布局
// ============================================================
public class QVBoxLayout {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qVBoxLayoutCreate()
        }
    }
    
    public func addWidget(widgetPtr: Int64) {
        unsafe {
            qVBoxLayoutAddWidget(ptr, widgetPtr)
        }
    }
    
    public func addLayout(layoutPtr: Int64) {
        unsafe {
            qVBoxLayoutAddLayout(ptr, layoutPtr)
        }
    }
    
    public func addStretch() {
        unsafe {
            qVBoxLayoutAddStretch(ptr)
        }
    }
    
    public func setSpacing(spacing: Int32) {
        unsafe {
            qVBoxLayoutSetSpacing(ptr, spacing)
        }
    }
    
    public func setMargin(margin: Int32) {
        unsafe {
            qVBoxLayoutSetMargin(ptr, margin)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qVBoxLayoutDelete(ptr)
            }
            ptr = 0
        }
    }
}

// ============================================================
// QHBoxLayout - 水平布局
// ============================================================
public class QHBoxLayout {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qHBoxLayoutCreate()
        }
    }
    
    public func addWidget(widgetPtr: Int64) {
        unsafe {
            qHBoxLayoutAddWidget(ptr, widgetPtr)
        }
    }
    
    public func addLayout(layoutPtr: Int64) {
        unsafe {
            qHBoxLayoutAddLayout(ptr, layoutPtr)
        }
    }
    
    public func addStretch() {
        unsafe {
            qHBoxLayoutAddStretch(ptr)
        }
    }
    
    public func setSpacing(spacing: Int32) {
        unsafe {
            qHBoxLayoutSetSpacing(ptr, spacing)
        }
    }
    
    public func setMargin(margin: Int32) {
        unsafe {
            qHBoxLayoutSetMargin(ptr, margin)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qHBoxLayoutDelete(ptr)
            }
            ptr = 0
        }
    }
}

// ============================================================
// QGridLayout - 网格布局
// ============================================================
public class QGridLayout {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qGridLayoutCreate()
        }
    }
    
    public func addWidget(widgetPtr: Int64, row: Int32, col: Int32) {
        unsafe {
            qGridLayoutAddWidget(ptr, widgetPtr, row, col)
        }
    }
    
    public func addWidgetSpan(widgetPtr: Int64, row: Int32, col: Int32, rowSpan: Int32, colSpan: Int32) {
        unsafe {
            qGridLayoutAddWidgetSpan(ptr, widgetPtr, row, col, rowSpan, colSpan)
        }
    }
    
    public func setSpacing(spacing: Int32) {
        unsafe {
            qGridLayoutSetSpacing(ptr, spacing)
        }
    }
    
    public func setMargin(margin: Int32) {
        unsafe {
            qGridLayoutSetMargin(ptr, margin)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qGridLayoutDelete(ptr)
            }
            ptr = 0
        }
    }
}

// ============================================================
// QLayout 接口 - 用于多态布局
// ============================================================
public interface QLayout {
    func getPtr(): Int64
    func delete(): Unit
}