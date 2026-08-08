package cjqt6.sql

import cjqt6.core.*

// ============================================================
// QSqlTableModel - SQL 表格数据模型
// ============================================================

foreign func qSqlTableModelCreate(parentPtr: Int64, dbName: CString): Int64
foreign func qSqlTableModelDelete(ptr: Int64): Unit
foreign func qSqlTableModelSetTable(ptr: Int64, tableName: CString): Unit
foreign func qSqlTableModelTableName(ptr: Int64): CString
foreign func qSqlTableModelSelect(ptr: Int64): Bool
foreign func qSqlTableModelRowCount(ptr: Int64): Int32
foreign func qSqlTableModelColumnCount(ptr: Int64): Int32
foreign func qSqlTableModelSetFilter(ptr: Int64, filter: CString): Unit
foreign func qSqlTableModelFilter(ptr: Int64): CString
foreign func qSqlTableModelSetSort(ptr: Int64, col: Int32, order: Int32): Unit
foreign func qSqlTableModelSetEditStrategy(ptr: Int64, strategy: Int32): Unit
foreign func qSqlTableModelEditStrategy(ptr: Int64): Int32
foreign func qSqlTableModelData(ptr: Int64, row: Int32, col: Int32): CString
foreign func qSqlTableModelSetData(ptr: Int64, row: Int32, col: Int32, value: CString): Bool
foreign func qSqlTableModelHeaderData(ptr: Int64, section: Int32): CString
foreign func qSqlTableModelInsertRow(ptr: Int64, row: Int32): Bool
foreign func qSqlTableModelRemoveRow(ptr: Int64, row: Int32): Bool
foreign func qSqlTableModelSubmitAll(ptr: Int64): Bool
foreign func qSqlTableModelRevertAll(ptr: Int64): Unit
foreign func qSqlTableModelDatabaseError(ptr: Int64): CString
foreign func qSqlTableModelClearTable(ptr: Int64): Unit
foreign func qSqlTableModelFetchMore(ptr: Int64): Unit
foreign func qSqlTableModelCanFetchMore(ptr: Int64): Bool

/// 编辑策略（与 QSqlTableModel::EditStrategy 枚举对应）
public class EditStrategy {
    /// 字段变更时立即提交（OnFieldChange）
    public static func onFieldChange(): Int32 { 0 }
    /// 行变更时提交（OnRowChange）
    public static func onRowChange(): Int32 { 1 }
    /// 手动调用 submitAll 时提交（OnManualSubmit）
    public static func onManualSubmit(): Int32 { 2 }
}

/// SQL 表格数据模型，将数据库表映射为可编辑的表格数据（常与 QTableView 配合）
public class QSqlTableModel {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) { throw ResourceDisposedException("QSqlTableModel already deleted") }
    }

    /// 创建模型，dbName 为数据库连接名（空串使用默认连接）
    public init(dbName: String) {
        unsafe {
            let cstr = LibC.mallocCString(dbName)
            ptr = qSqlTableModelCreate(0, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置要映射的数据库表名
    public func setTable(tableName: String): Unit {
        checkValid()
        unsafe { let c = LibC.mallocCString(tableName); qSqlTableModelSetTable(ptr, c); LibC.free(c) }
    }

    /// 获取当前映射的表名
    public func tableName(): String { checkValid(); unsafe { let cstr = qSqlTableModelTableName(ptr); let result = cstr.toString(); freeBridgeString(cstr); result } }
    /// 执行查询填充模型数据，返回是否成功
    public func select(): Bool { checkValid(); unsafe { qSqlTableModelSelect(ptr) } }
    /// 数据行数
    public func rowCount(): Int32 { checkValid(); unsafe { qSqlTableModelRowCount(ptr) } }
    /// 数据列数
    public func columnCount(): Int32 { checkValid(); unsafe { qSqlTableModelColumnCount(ptr) } }

    /// 设置查询过滤条件（SQL WHERE 子句，如 "age > 18"）
    public func setFilter(filter: String): Unit {
        checkValid()
        unsafe { let c = LibC.mallocCString(filter); qSqlTableModelSetFilter(ptr, c); LibC.free(c) }
    }

    /// 获取当前过滤条件
    public func filter(): String { checkValid(); unsafe { let cstr = qSqlTableModelFilter(ptr); let result = cstr.toString(); freeBridgeString(cstr); result } }

    /// 设置排序规则，order 为 Qt::SortOrder（0 升序、1 降序）
    public func setSort(col: Int32, order: Int32): Unit { checkValid(); unsafe { qSqlTableModelSetSort(ptr, col, order) } }

    /// 设置编辑策略（EditStrategy 常量）
    public func setEditStrategy(strategy: Int32): Unit { checkValid(); unsafe { qSqlTableModelSetEditStrategy(ptr, strategy) } }

    /// 获取当前编辑策略（EditStrategy 常量）
    public func editStrategy(): Int32 { checkValid(); unsafe { qSqlTableModelEditStrategy(ptr) } }

    /// 获取指定单元格的文本
    public func data(row: Int32, col: Int32): String {
        checkValid(); unsafe { let cstr = qSqlTableModelData(ptr, row, col); let result = cstr.toString(); freeBridgeString(cstr); result }
    }

    /// 设置指定单元格的值，返回是否成功
    public func setData(row: Int32, col: Int32, value: String): Bool {
        checkValid()
        unsafe { let c = LibC.mallocCString(value); let r = qSqlTableModelSetData(ptr, row, col, c); LibC.free(c); r }
    }

    /// 获取表头文本
    public func headerData(section: Int32): String {
        checkValid(); unsafe { let cstr = qSqlTableModelHeaderData(ptr, section); let result = cstr.toString(); freeBridgeString(cstr); result }
    }

    /// 插入一行（row 为插入位置），返回是否成功
    public func insertRow(row: Int32): Bool { checkValid(); unsafe { qSqlTableModelInsertRow(ptr, row) } }
    /// 删除一行，返回是否成功
    public func removeRow(row: Int32): Bool { checkValid(); unsafe { qSqlTableModelRemoveRow(ptr, row) } }
    /// 提交所有未提交的更改到数据库，返回是否成功
    public func submitAll(): Bool { checkValid(); unsafe { qSqlTableModelSubmitAll(ptr) } }
    /// 回滚所有未提交的更改
    public func revertAll(): Unit { checkValid(); unsafe { qSqlTableModelRevertAll(ptr) } }
    /// 获取最近一次数据库操作的错误信息
    public func databaseError(): String { checkValid(); unsafe { let cstr = qSqlTableModelDatabaseError(ptr); let result = cstr.toString(); freeBridgeString(cstr); result } }
    /// 清空表格数据（删除所有行）
    public func clearTable(): Unit { checkValid(); unsafe { qSqlTableModelClearTable(ptr) } }
    /// 获取更多数据（用于分页加载）
    public func fetchMore(): Unit { checkValid(); unsafe { qSqlTableModelFetchMore(ptr) } }
    /// 是否还有更多数据可获取
    public func canFetchMore(): Bool { checkValid(); unsafe { qSqlTableModelCanFetchMore(ptr) } }

    /// 获取底层指针
    public func getPtr(): Int64 { ptr }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) { unsafe { qSqlTableModelDelete(ptr) }; ptr = 0; closed = true }
    }
}
