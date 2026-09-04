package cjqt6.gui

import cjqt6.core.*

// ============================================================
// 布局管理 FFI声明
// ============================================================

// QVBoxLayout - 垂直布局
// QVBoxLayout::QVBoxLayout() - 创建垂直布局
foreign func qVBoxLayoutCreate(): Int64
// QVBoxLayout::addWidget() - 添加子部件
foreign func qVBoxLayoutAddWidget(layoutPtr: Int64, widgetPtr: Int64): Unit
// QVBoxLayout::addWidget() - 添加子部件并设置拉伸因子
foreign func qVBoxLayoutAddWidgetStretch(layoutPtr: Int64, widgetPtr: Int64, stretch: Int32): Unit
// QVBoxLayout::addLayout() - 添加子布局
foreign func qVBoxLayoutAddLayout(layoutPtr: Int64, childLayoutPtr: Int64): Unit
// QVBoxLayout::addStretch() - 添加弹性空白
foreign func qVBoxLayoutAddStretch(ptr: Int64): Unit
// QVBoxLayout::setSpacing() - 设置间距
foreign func qVBoxLayoutSetSpacing(ptr: Int64, spacing: Int32): Unit
// QVBoxLayout::setMargin() - 设置边距
foreign func qVBoxLayoutSetMargin(ptr: Int64, margin: Int32): Unit

// QVBoxLayout析构 - 删除布局
foreign func qVBoxLayoutDelete(ptr: Int64): Unit

// QHBoxLayout - 水平布局
// QHBoxLayout::QHBoxLayout() - 创建水平布局
foreign func qHBoxLayoutCreate(): Int64
// QHBoxLayout::addWidget() - 添加子部件
foreign func qHBoxLayoutAddWidget(layoutPtr: Int64, widgetPtr: Int64): Unit
// QHBoxLayout::addWidget() - 添加子部件并设置拉伸因子
foreign func qHBoxLayoutAddWidgetStretch(layoutPtr: Int64, widgetPtr: Int64, stretch: Int32): Unit
// QHBoxLayout::addLayout() - 添加子布局
foreign func qHBoxLayoutAddLayout(layoutPtr: Int64, childLayoutPtr: Int64): Unit
// QHBoxLayout::addStretch() - 添加弹性空白
foreign func qHBoxLayoutAddStretch(ptr: Int64): Unit
// QHBoxLayout::setSpacing() - 设置间距
foreign func qHBoxLayoutSetSpacing(ptr: Int64, spacing: Int32): Unit
// QHBoxLayout::setMargin() - 设置边距
foreign func qHBoxLayoutSetMargin(ptr: Int64, margin: Int32): Unit

// QHBoxLayout析构 - 删除布局
foreign func qHBoxLayoutDelete(ptr: Int64): Unit

// QGridLayout - 网格布局
// QGridLayout::QGridLayout() - 创建网格布局
foreign func qGridLayoutCreate(): Int64
// QGridLayout::addWidget() - 在指定位置添加子部件
foreign func qGridLayoutAddWidget(layoutPtr: Int64, widgetPtr: Int64, row: Int32, col: Int32): Unit
// QGridLayout::addWidget() - 在指定位置添加跨行跨列的子部件
foreign func qGridLayoutAddWidgetSpan(layoutPtr: Int64, widgetPtr: Int64, row: Int32, col: Int32, rowSpan: Int32, colSpan: Int32): Unit
// QGridLayout::setSpacing() - 设置间距
foreign func qGridLayoutSetSpacing(ptr: Int64, spacing: Int32): Unit
// QGridLayout::setMargin() - 设置边距
foreign func qGridLayoutSetMargin(ptr: Int64, margin: Int32): Unit

// QGridLayout析构 - 删除布局
foreign func qGridLayoutDelete(ptr: Int64): Unit

// QWidget布局设置
// QWidget::setLayout() - 设置布局
foreign func qWidgetSetLayout(widgetPtr: Int64, layoutPtr: Int64): Unit

// ============================================================
// QVBoxLayout - 垂直布局
// ============================================================
public class QVBoxLayout <: QLayout {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init() {
        unsafe {
            ptr = qVBoxLayoutCreate()
        }
        trackObject(ptr)
    }
    
    public func addWidget(widgetPtr: Int64): Unit {
        checkValid()
        unsafe {
            qVBoxLayoutAddWidget(ptr, widgetPtr)
        }
    }
    
    public func addWidget(widgetPtr: Int64, stretch: Int32): Unit {
        checkValid()
        unsafe {
            qVBoxLayoutAddWidgetStretch(ptr, widgetPtr, stretch)
        }
    }
    
    public func addLayout(layoutPtr: Int64): Unit {
        checkValid()
        unsafe {
            qVBoxLayoutAddLayout(ptr, layoutPtr)
        }
    }
    
    public func addStretch(): Unit {
        checkValid()
        unsafe {
            qVBoxLayoutAddStretch(ptr)
        }
    }
    
    public func setSpacing(spacing: Int32): Unit {
        checkValid()
        unsafe {
            qVBoxLayoutSetSpacing(ptr, spacing)
        }
    }
    
    public func setMargin(margin: Int32): Unit {
        checkValid()
        unsafe {
            qVBoxLayoutSetMargin(ptr, margin)
        }
    }
    
    /// 设置四方向边距（当四方向边距不同时使用Margins的all字段）
    public func setMargins(margins: Margins): Unit {
        checkValid()
        unsafe {
            qVBoxLayoutSetMargin(ptr, margins.left)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func isClosed(): Bool {
        closed
    }
    
    public func isValid(): Bool {
        !closed && ptr != 0 && isObjectAlive(ptr)
    }
    
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw Exception("QVBoxLayout 已经被释放")
        }
        if (ptr == 0) {
            throw Exception("QVBoxLayout 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QVBoxLayout 底层 Qt 对象已失效")
        }
    }
    
    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            unsafe {
                qVBoxLayoutDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    public func delete(): Unit {
        close()
    }
}

// ============================================================
// QHBoxLayout - 水平布局
// ============================================================
public class QHBoxLayout <: QLayout {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init() {
        unsafe {
            ptr = qHBoxLayoutCreate()
        }
        trackObject(ptr)
    }
    
    public func addWidget(widgetPtr: Int64): Unit {
        checkValid()
        unsafe {
            qHBoxLayoutAddWidget(ptr, widgetPtr)
        }
    }
    
    public func addWidget(widgetPtr: Int64, stretch: Int32): Unit {
        checkValid()
        unsafe {
            qHBoxLayoutAddWidgetStretch(ptr, widgetPtr, stretch)
        }
    }
    
    public func addLayout(layoutPtr: Int64): Unit {
        checkValid()
        unsafe {
            qHBoxLayoutAddLayout(ptr, layoutPtr)
        }
    }
    
    public func addStretch(): Unit {
        checkValid()
        unsafe {
            qHBoxLayoutAddStretch(ptr)
        }
    }
    
    public func setSpacing(spacing: Int32): Unit {
        checkValid()
        unsafe {
            qHBoxLayoutSetSpacing(ptr, spacing)
        }
    }
    
    public func setMargin(margin: Int32): Unit {
        checkValid()
        unsafe {
            qHBoxLayoutSetMargin(ptr, margin)
        }
    }
    
    /// 设置四方向边距（当四方向边距不同时使用Margins的all字段）
    public func setMargins(margins: Margins): Unit {
        checkValid()
        unsafe {
            qHBoxLayoutSetMargin(ptr, margins.left)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func isClosed(): Bool {
        closed
    }
    
    public func isValid(): Bool {
        !closed && ptr != 0 && isObjectAlive(ptr)
    }
    
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw Exception("QHBoxLayout 已经被释放")
        }
        if (ptr == 0) {
            throw Exception("QHBoxLayout 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QHBoxLayout 底层 Qt 对象已失效")
        }
    }
    
    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            unsafe {
                qHBoxLayoutDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    public func delete(): Unit {
        close()
    }
}

// ============================================================
// QGridLayout - 网格布局
// ============================================================
public class QGridLayout <: QLayout {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init() {
        unsafe {
            ptr = qGridLayoutCreate()
        }
        trackObject(ptr)
    }
    
    public func addWidget(widgetPtr: Int64, row: Int32, col: Int32): Unit {
        checkValid()
        unsafe {
            qGridLayoutAddWidget(ptr, widgetPtr, row, col)
        }
    }
    
    public func addWidgetSpan(widgetPtr: Int64, row: Int32, col: Int32, rowSpan: Int32, colSpan: Int32): Unit {
        checkValid()
        unsafe {
            qGridLayoutAddWidgetSpan(ptr, widgetPtr, row, col, rowSpan, colSpan)
        }
    }
    
    public func setSpacing(spacing: Int32): Unit {
        checkValid()
        unsafe {
            qGridLayoutSetSpacing(ptr, spacing)
        }
    }
    
    public func setMargin(margin: Int32): Unit {
        checkValid()
        unsafe {
            qGridLayoutSetMargin(ptr, margin)
        }
    }
    
    /// 设置四方向边距（当四方向边距不同时使用Margins的all字段）
    public func setMargins(margins: Margins): Unit {
        checkValid()
        unsafe {
            qGridLayoutSetMargin(ptr, margins.left)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func isClosed(): Bool {
        closed
    }
    
    public func isValid(): Bool {
        !closed && ptr != 0 && isObjectAlive(ptr)
    }
    
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw Exception("QGridLayout 已经被释放")
        }
        if (ptr == 0) {
            throw Exception("QGridLayout 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QGridLayout 底层 Qt 对象已失效")
        }
    }
    
    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            unsafe {
                qGridLayoutDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    public func delete(): Unit {
        close()
    }
}

// ============================================================
// QFormLayout 桥接函数
// ============================================================

// QFormLayout::QFormLayout() - 创建表单布局
foreign func qFormLayoutCreate(): Int64
// QFormLayout::addRow() - 添加一行（文本标签+控件）
foreign func qFormLayoutAddRow(ptr: Int64, label: CString, widgetPtr: Int64): Unit
// QFormLayout::addRow() - 添加一行（控件标签+控件）
foreign func qFormLayoutAddRowWidget(ptr: Int64, labelWidgetPtr: Int64, fieldWidgetPtr: Int64): Unit
// QFormLayout::addRow() - 添加一行（文本标签+子布局）
foreign func qFormLayoutAddRowLayout(ptr: Int64, label: CString, layoutPtr: Int64): Unit
// QFormLayout::insertRow() - 在指定位置插入一行
foreign func qFormLayoutInsertRow(ptr: Int64, row: Int32, label: CString, widgetPtr: Int64): Unit
// QFormLayout::removeRow() - 移除指定行
foreign func qFormLayoutRemoveRow(ptr: Int64, row: Int32): Unit
// QFormLayout::rowCount() - 获取行数
foreign func qFormLayoutRowCount(ptr: Int64): Int32
// QFormLayout::setSpacing() - 设置间距
foreign func qFormLayoutSetSpacing(ptr: Int64, spacing: Int32): Unit
// QFormLayout::setMargin() - 设置边距
foreign func qFormLayoutSetMargin(ptr: Int64, margin: Int32): Unit

// QFormLayout::setLabelAlignment() - 设置标签对齐方式
foreign func qFormLayoutSetLabelAlignment(ptr: Int64, alignment: Int32): Unit
// QFormLayout::setFormAlignment() - 设置表单对齐方式
foreign func qFormLayoutSetFormAlignment(ptr: Int64, alignment: Int32): Unit
// QFormLayout::setFieldGrowthPolicy() - 设置字段增长策略
foreign func qFormLayoutSetFieldGrowthPolicy(ptr: Int64, policy: Int32): Unit
// QFormLayout::setRowWrapPolicy() - 设置行换行策略
foreign func qFormLayoutSetRowWrapPolicy(ptr: Int64, policy: Int32): Unit
// QFormLayout析构 - 删除布局
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
public class QFormLayout <: QLayout {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    public init() {
        unsafe {
            ptr = qFormLayoutCreate()
        }
        trackObject(ptr)
    }

    /// 添加一行：文本标签 + 控件
    public func addRow(label: String, widgetPtr: Int64): Unit {
        checkValid()
        unsafe {
            withCString(label) { c => qFormLayoutAddRow(ptr, c, widgetPtr) }
        }
    }

    /// 添加一行：控件标签 + 控件
    public func addRowWidget(labelWidgetPtr: Int64, fieldWidgetPtr: Int64): Unit {
        checkValid()
        unsafe {
            qFormLayoutAddRowWidget(ptr, labelWidgetPtr, fieldWidgetPtr)
        }
    }

    /// 添加一行：文本标签 + 子布局
    public func addRowLayout(label: String, layoutPtr: Int64): Unit {
        checkValid()
        unsafe {
            withCString(label) { c => qFormLayoutAddRowLayout(ptr, c, layoutPtr) }
        }
    }

    /// 在指定位置插入一行
    public func insertRow(row: Int32, label: String, widgetPtr: Int64): Unit {
        checkValid()
        unsafe {
            withCString(label) { c => qFormLayoutInsertRow(ptr, row, c, widgetPtr) }
        }
    }

    /// 移除指定行
    public func removeRow(row: Int32): Unit {
        checkValid()
        unsafe {
            qFormLayoutRemoveRow(ptr, row)
        }
    }

    /// 获取行数
    public func rowCount(): Int32 {
        checkValid()
        unsafe {
            return qFormLayoutRowCount(ptr)
        }
    }

    /// 设置间距
    public func setSpacing(spacing: Int32): Unit {
        checkValid()
        unsafe {
            qFormLayoutSetSpacing(ptr, spacing)
        }
    }

    /// 设置边距
    public func setMargin(margin: Int32): Unit {
        checkValid()
        unsafe {
            qFormLayoutSetMargin(ptr, margin)
        }
    }

    /// 设置四方向边距（当四方向边距不同时使用Margins的all字段）
    public func setMargins(margins: Margins): Unit {
        checkValid()
        unsafe {
            qFormLayoutSetMargin(ptr, margins.left)
        }
    }

    /// 设置标签对齐方式
    public func setLabelAlignment(alignment: Int32): Unit {
        checkValid()
        unsafe {
            qFormLayoutSetLabelAlignment(ptr, alignment)
        }
    }

    /// 设置表单对齐方式
    public func setFormAlignment(alignment: Int32): Unit {
        checkValid()
        unsafe {
            qFormLayoutSetFormAlignment(ptr, alignment)
        }
    }

    /// 设置字段增长策略
    public func setFieldGrowthPolicy(policy: Int32): Unit {
        checkValid()
        unsafe {
            qFormLayoutSetFieldGrowthPolicy(ptr, policy)
        }
    }

    /// 设置行换行策略
    public func setRowWrapPolicy(policy: Int32): Unit {
        checkValid()
        unsafe {
            qFormLayoutSetRowWrapPolicy(ptr, policy)
        }
    }

    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }

    public func isClosed(): Bool {
        closed
    }
    
    public func isValid(): Bool {
        !closed && ptr != 0 && isObjectAlive(ptr)
    }
    
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw Exception("QFormLayout 已经被释放")
        }
        if (ptr == 0) {
            throw Exception("QFormLayout 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QFormLayout 底层 Qt 对象已失效")
        }
    }
    
    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            unsafe {
                qFormLayoutDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }

    /// 删除表单布局（兼容旧API）
    public func delete(): Unit {
        close()
    }
}

// ============================================================
// QLayout 接口 - 用于多态布局
// ============================================================
public interface QLayout {
    func getPtr(): Int64
    func delete(): Unit
}
