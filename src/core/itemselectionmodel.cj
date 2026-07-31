package cjqt6.core

// ============================================================
// QItemSelectionModel - 选择模型封装
// ============================================================

foreign func qItemSelectionModelCreate(modelPtr: Int64): Int64
foreign func qItemSelectionModelDelete(ptr: Int64): Unit
foreign func qItemSelectionModelCurrentIndexRow(ptr: Int64): Int32
foreign func qItemSelectionModelCurrentIndexCol(ptr: Int64): Int32
foreign func qItemSelectionModelSetCurrentIndex(ptr: Int64, row: Int32, col: Int32, command: Int32): Unit
foreign func qItemSelectionModelIsSelected(ptr: Int64, row: Int32, col: Int32): Bool
foreign func qItemSelectionModelIsRowSelected(ptr: Int64, row: Int32): Bool
foreign func qItemSelectionModelHasSelection(ptr: Int64): Bool
foreign func qItemSelectionModelClearSelection(ptr: Int64): Unit
foreign func qItemSelectionModelClear(ptr: Int64): Unit
foreign func qItemSelectionModelModel(ptr: Int64): Int64
foreign func qItemSelectionModelSelect(ptr: Int64, row: Int32, col: Int32, command: Int32): Unit
foreign func qItemSelectionModelSelectedRowsCount(ptr: Int64): Int32
foreign func qItemSelectionModelSelectedRowAt(ptr: Int64, index: Int32): Int32

// ============================================================
// SelectionFlag - 选择行为标志
// ============================================================

/// 选择行为标志（与 Qt 的 QItemSelectionModel::SelectionFlag 对应）
public class SelectionFlag {
    /// 不更新选择
    public static func noUpdate(): Int32 { 0 }
    /// 选择指定索引
    public static func select(): Int32 { 1 }
    /// 取消选择指定索引
    public static func deselect(): Int32 { 2 }
    /// 切换指定索引的选择状态
    public static func toggle(): Int32 { 4 }
    /// 将指定索引设置为当前索引
    public static func current(): Int32 { 16 }
    /// 选择整行
    public static func rows(): Int32 { 32 }
    /// 选择整列
    public static func columns(): Int32 { 64 }
    /// 清除现有选择后选择指定索引
    public static func clearAndSelect(): Int32 { 49 }
}

// ============================================================
// QItemSelectionModel - 选择模型
// ============================================================

/// 项目选择模型，管理模型中的选中项、当前项（常与 QTableView 等视图配合使用）
public class QItemSelectionModel {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QItemSelectionModel already deleted")
        }
    }

    /// 创建选择模型，modelPtr 为关联的数据模型指针（QAbstractItemModel）
    public init(modelPtr: Int64) {
        unsafe {
            ptr = qItemSelectionModelCreate(modelPtr)
            if (ptr == 0) { throw CreateFailedException("QItemSelectionModel create failed") }
        }
    }

    /// 获取当前项的行号
    public func currentIndexRow(): Int32 {
        checkValid(); unsafe { qItemSelectionModelCurrentIndexRow(ptr) }
    }

    /// 获取当前项的列号
    public func currentIndexCol(): Int32 {
        checkValid(); unsafe { qItemSelectionModelCurrentIndexCol(ptr) }
    }

    /// 设置当前索引，command 为 SelectionFlag 常量
    public func setCurrentIndex(row: Int32, col: Int32, command: Int32): Unit {
        checkValid(); unsafe { qItemSelectionModelSetCurrentIndex(ptr, row, col, command) }
    }

    /// 指定单元格是否被选中
    public func isSelected(row: Int32, col: Int32): Bool {
        checkValid(); unsafe { qItemSelectionModelIsSelected(ptr, row, col) }
    }

    /// 指定行是否被选中
    public func isRowSelected(row: Int32): Bool {
        checkValid(); unsafe { qItemSelectionModelIsRowSelected(ptr, row) }
    }

    /// 是否存在选中项
    public func hasSelection(): Bool {
        checkValid(); unsafe { qItemSelectionModelHasSelection(ptr) }
    }

    /// 清除所有选中项（保留当前项）
    public func clearSelection(): Unit {
        checkValid(); unsafe { qItemSelectionModelClearSelection(ptr) }
    }

    /// 清除所有选中项和当前项
    public func clear(): Unit {
        checkValid(); unsafe { qItemSelectionModelClear(ptr) }
    }

    /// 获取关联的数据模型指针
    public func model(): Int64 {
        checkValid(); unsafe { qItemSelectionModelModel(ptr) }
    }

    /// 选择指定单元格，command 为 SelectionFlag 常量
    public func select(row: Int32, col: Int32, command: Int32): Unit {
        checkValid(); unsafe { qItemSelectionModelSelect(ptr, row, col, command) }
    }

    /// 选中的行数量
    public func selectedRowsCount(): Int32 {
        checkValid(); unsafe { qItemSelectionModelSelectedRowsCount(ptr) }
    }

    /// 按索引获取选中行的行号
    public func selectedRowAt(index: Int32): Int32 {
        checkValid(); unsafe { qItemSelectionModelSelectedRowAt(ptr, index) }
    }

    /// 获取底层指针
    public func getPtr(): Int64 { ptr }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe { qItemSelectionModelDelete(ptr) }
            ptr = 0; closed = true
        }
    }
}
