package cjqt6.gui

// ============================================================
// 布局管理 FFI声明
// ============================================================

// QVBoxLayout - 垂直布局
foreign func qVBoxLayoutCreate(): Int64
foreign func qVBoxLayoutAddWidget(layoutPtr: Int64, widgetPtr: Int64): Unit
foreign func qVBoxLayoutAddWidgetStretch(layoutPtr: Int64, widgetPtr: Int64, stretch: Int32): Unit
foreign func qVBoxLayoutAddLayout(layoutPtr: Int64, childLayoutPtr: Int64): Unit
foreign func qVBoxLayoutAddStretch(ptr: Int64): Unit
foreign func qVBoxLayoutSetSpacing(ptr: Int64, spacing: Int32): Unit
foreign func qVBoxLayoutSetMargin(ptr: Int64, margin: Int32): Unit
foreign func qVBoxLayoutDelete(ptr: Int64): Unit

// QHBoxLayout - 水平布局
foreign func qHBoxLayoutCreate(): Int64
foreign func qHBoxLayoutAddWidget(layoutPtr: Int64, widgetPtr: Int64): Unit
foreign func qHBoxLayoutAddWidgetStretch(layoutPtr: Int64, widgetPtr: Int64, stretch: Int32): Unit
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
    
    public func addWidget(widgetPtr: Int64, stretch: Int32) {
        unsafe {
            qVBoxLayoutAddWidgetStretch(ptr, widgetPtr, stretch)
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
    
    public func addWidget(widgetPtr: Int64, stretch: Int32) {
        unsafe {
            qHBoxLayoutAddWidgetStretch(ptr, widgetPtr, stretch)
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
// QFormLayout 桥接函数
// ============================================================

foreign func qFormLayoutCreate(): Int64
foreign func qFormLayoutAddRow(ptr: Int64, label: CString, widgetPtr: Int64): Unit
foreign func qFormLayoutAddRowWidget(ptr: Int64, labelWidgetPtr: Int64, fieldWidgetPtr: Int64): Unit
foreign func qFormLayoutAddRowLayout(ptr: Int64, label: CString, layoutPtr: Int64): Unit
foreign func qFormLayoutInsertRow(ptr: Int64, row: Int32, label: CString, widgetPtr: Int64): Unit
foreign func qFormLayoutRemoveRow(ptr: Int64, row: Int32): Unit
foreign func qFormLayoutRowCount(ptr: Int64): Int32
foreign func qFormLayoutSetSpacing(ptr: Int64, spacing: Int32): Unit
foreign func qFormLayoutSetMargin(ptr: Int64, margin: Int32): Unit
foreign func qFormLayoutSetLabelAlignment(ptr: Int64, alignment: Int32): Unit
foreign func qFormLayoutSetFormAlignment(ptr: Int64, alignment: Int32): Unit
foreign func qFormLayoutSetFieldGrowthPolicy(ptr: Int64, policy: Int32): Unit
foreign func qFormLayoutSetRowWrapPolicy(ptr: Int64, policy: Int32): Unit
foreign func qFormLayoutDelete(ptr: Int64): Unit

/// 字段增长策略
public class FieldGrowthPolicy {
    public static let FieldsStayAtSizeHint: Int32 = 0  // 字段保持大小提示
    public static let ExpandingFieldsGrow: Int32 = 1   // 可扩展字段增长
    public static let AllNonFixedFieldsGrow: Int32 = 2 // 所有非固定字段增长
}

/// 行换行策略
public class RowWrapPolicy {
    public static let DontWrapRows: Int32 = 0       // 不换行
    public static let WrapLongRows: Int32 = 1       // 长行换行
    public static let WrapAllRows: Int32 = 2        // 所有行换行
}

/// 表单布局
/// 用于创建标签-控件对的表单布局，每行包含一个标签和一个输入控件
public class QFormLayout {
    private var ptr: Int64 = 0

    public init() {
        unsafe {
            ptr = qFormLayoutCreate()
        }
    }

    /// 添加一行：文本标签 + 控件
    public func addRow(label: String, widgetPtr: Int64): Unit {
        unsafe {
            let cstr = LibC.mallocCString(label)
            qFormLayoutAddRow(ptr, cstr, widgetPtr)
            LibC.free(cstr)
        }
    }

    /// 添加一行：控件标签 + 控件
    public func addRowWidget(labelWidgetPtr: Int64, fieldWidgetPtr: Int64): Unit {
        unsafe {
            qFormLayoutAddRowWidget(ptr, labelWidgetPtr, fieldWidgetPtr)
        }
    }

    /// 添加一行：文本标签 + 子布局
    public func addRowLayout(label: String, layoutPtr: Int64): Unit {
        unsafe {
            let cstr = LibC.mallocCString(label)
            qFormLayoutAddRowLayout(ptr, cstr, layoutPtr)
            LibC.free(cstr)
        }
    }

    /// 在指定位置插入一行
    public func insertRow(row: Int32, label: String, widgetPtr: Int64): Unit {
        unsafe {
            let cstr = LibC.mallocCString(label)
            qFormLayoutInsertRow(ptr, row, cstr, widgetPtr)
            LibC.free(cstr)
        }
    }

    /// 移除指定行
    public func removeRow(row: Int32): Unit {
        unsafe {
            qFormLayoutRemoveRow(ptr, row)
        }
    }

    /// 获取行数
    public func rowCount(): Int32 {
        unsafe {
            return qFormLayoutRowCount(ptr)
        }
    }

    /// 设置间距
    public func setSpacing(spacing: Int32): Unit {
        unsafe {
            qFormLayoutSetSpacing(ptr, spacing)
        }
    }

    /// 设置边距
    public func setMargin(margin: Int32): Unit {
        unsafe {
            qFormLayoutSetMargin(ptr, margin)
        }
    }

    /// 设置标签对齐方式
    public func setLabelAlignment(alignment: Int32): Unit {
        unsafe {
            qFormLayoutSetLabelAlignment(ptr, alignment)
        }
    }

    /// 设置表单对齐方式
    public func setFormAlignment(alignment: Int32): Unit {
        unsafe {
            qFormLayoutSetFormAlignment(ptr, alignment)
        }
    }

    /// 设置字段增长策略
    public func setFieldGrowthPolicy(policy: Int32): Unit {
        unsafe {
            qFormLayoutSetFieldGrowthPolicy(ptr, policy)
        }
    }

    /// 设置行换行策略
    public func setRowWrapPolicy(policy: Int32): Unit {
        unsafe {
            qFormLayoutSetRowWrapPolicy(ptr, policy)
        }
    }

    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }

    /// 删除表单布局
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qFormLayoutDelete(ptr)
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