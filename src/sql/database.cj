package cjqt6.sql

import cjqt6.core.*

// QSqlDatabase - 数据库连接
foreign func qSqlDatabaseAddDatabase(`type`: CString, name: CString): Int64
foreign func qSqlDatabaseDatabase(name: CString): Int64
foreign func qSqlDatabaseSetHostName(ptr: Int64, host: CString): Unit
foreign func qSqlDatabaseSetPort(ptr: Int64, port: Int32): Unit
foreign func qSqlDatabaseSetDatabaseName(ptr: Int64, name: CString): Unit
foreign func qSqlDatabaseSetUserName(ptr: Int64, user: CString): Unit
foreign func qSqlDatabaseSetPassword(ptr: Int64, password: CString): Unit
foreign func qSqlDatabaseOpen(ptr: Int64): Bool
foreign func qSqlDatabaseClose(ptr: Int64): Unit
foreign func qSqlDatabaseIsOpen(ptr: Int64): Bool
foreign func qSqlDatabaseLastError(ptr: Int64): CString
foreign func qSqlDatabaseDriverName(ptr: Int64): CString
foreign func qSqlDatabaseRemoveDatabase(name: CString): Unit
foreign func qSqlDatabaseDelete(ptr: Int64): Unit

// QSqlQuery - SQL查询
foreign func qSqlQueryCreate(): Int64
foreign func qSqlQueryCreateWithDb(dbPtr: Int64): Int64
foreign func qSqlQueryExec(ptr: Int64, sql: CString): Bool
foreign func qSqlQueryExecBatch(ptr: Int64): Bool
foreign func qSqlQueryPrepare(ptr: Int64, sql: CString): Bool
foreign func qSqlQueryBindValue(ptr: Int64, placeholder: CString, value: CString): Unit
foreign func qSqlQueryBindValueInt(ptr: Int64, placeholder: CString, value: Int32): Unit
foreign func qSqlQueryBindValueDouble(ptr: Int64, placeholder: CString, value: Float64): Unit
foreign func qSqlQueryNext(ptr: Int64): Bool
foreign func qSqlQueryPrevious(ptr: Int64): Bool
foreign func qSqlQueryFirst(ptr: Int64): Bool
foreign func qSqlQueryLast(ptr: Int64): Bool
foreign func qSqlQueryValueString(ptr: Int64, index: Int32): CString
foreign func qSqlQueryValueInt(ptr: Int64, index: Int32): Int32
foreign func qSqlQueryValueDouble(ptr: Int64, index: Int32): Float64
foreign func qSqlQuerySize(ptr: Int64): Int32
foreign func qSqlQueryNumRowsAffected(ptr: Int64): Int32
foreign func qSqlQueryAt(ptr: Int64): Int32
foreign func qSqlQueryIsValid(ptr: Int64): Bool
foreign func qSqlQueryIsActive(ptr: Int64): Bool
foreign func qSqlQueryIsSelect(ptr: Int64): Bool
foreign func qSqlQueryFinish(ptr: Int64): Unit
foreign func qSqlQueryClear(ptr: Int64): Unit
foreign func qSqlQueryLastError(ptr: Int64): CString
foreign func qSqlQueryDelete(ptr: Int64): Unit

// QSqlRecord FFI
foreign func qSqlQueryRecord(ptr: Int64): Int64
foreign func qSqlRecordCount(ptr: Int64): Int32
foreign func qSqlRecordFieldName(ptr: Int64, index: Int32): CString
foreign func qSqlRecordIndexOf(ptr: Int64, name: CString): Int32
foreign func qSqlRecordIsNull(ptr: Int64, index: Int32): Bool
foreign func qSqlRecordValueString(ptr: Int64, index: Int32): CString
foreign func qSqlRecordValueInt(ptr: Int64, index: Int32): Int32
foreign func qSqlRecordValueDouble(ptr: Int64, index: Int32): Float64
foreign func qSqlRecordField(ptr: Int64, index: Int32): Int64
foreign func qSqlRecordDelete(ptr: Int64): Unit

// QSqlField FFI
foreign func qSqlFieldName(ptr: Int64): CString
foreign func qSqlFieldIsNull(ptr: Int64): Bool
foreign func qSqlFieldIsReadOnly(ptr: Int64): Bool
foreign func qSqlFieldIsAutoValue(ptr: Int64): Bool
foreign func qSqlFieldValueString(ptr: Int64): CString
foreign func qSqlFieldDelete(ptr: Int64): Unit

/// 数据库驱动类型
public class SqlDriver {
    public static func sqlite(): String { "QSQLITE" }
    public static func mysql(): String { "QMYSQL" }
    public static func postgresql(): String { "QPSQL" }
    public static func odbc(): String { "QODBC" }
    public static func oracle(): String { "QOCI" }
}

/// SQL数据库连接
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QSqlDatabase <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    private init() {}
    
    /// 添加数据库连接
    public static func addDatabase(driverType: String, connectionName: String): QSqlDatabase {
        let db = QSqlDatabase()
        unsafe {
            var typeStr = LibC.mallocCString(driverType)
            var nameStr = LibC.mallocCString(connectionName)
            db.ptr = qSqlDatabaseAddDatabase(typeStr, nameStr)
            LibC.free(typeStr)
            LibC.free(nameStr)
        }
        return db
    }
    
    /// 获取已存在的数据库连接
    public static func database(connectionName: String): QSqlDatabase {
        let db = QSqlDatabase()
        unsafe {
            var nameStr = LibC.mallocCString(connectionName)
            db.ptr = qSqlDatabaseDatabase(nameStr)
            LibC.free(nameStr)
        }
        return db
    }
    
    /// 移除数据库连接
    public static func removeDatabase(connectionName: String): Unit {
        unsafe {
            var nameStr = LibC.mallocCString(connectionName)
            qSqlDatabaseRemoveDatabase(nameStr)
            LibC.free(nameStr)
        }
    }
    
    public func setHostName(host: String): Unit {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(host)
            qSqlDatabaseSetHostName(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setPort(port: Int32): Unit {
        checkValid()
        unsafe { qSqlDatabaseSetPort(ptr, port) }
    }
    
    public func setDatabaseName(name: String): Unit {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(name)
            qSqlDatabaseSetDatabaseName(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setUserName(user: String): Unit {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(user)
            qSqlDatabaseSetUserName(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setPassword(password: String): Unit {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(password)
            qSqlDatabaseSetPassword(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 打开数据库连接
    public func open(): Bool {
        checkValid()
        unsafe { qSqlDatabaseOpen(ptr) }
    }
    
    /// 关闭数据库连接（如仍需使用数据库对象，调用 closeDatabase 仅关闭连接）
    public func closeDatabase(): Unit {
        checkValid()
        unsafe { qSqlDatabaseClose(ptr) }
    }
    
    /// 检查数据库连接是否已打开
    public func isOpen(): Bool {
        checkValid()
        unsafe { qSqlDatabaseIsOpen(ptr) }
    }
    
    public func lastError(): String {
        checkValid()
        unsafe {
            let cstr = qSqlDatabaseLastError(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    public func driverName(): String {
        checkValid()
        unsafe {
            let cstr = qSqlDatabaseDriverName(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    public func getPtr(): Int64 { ptr }
    
    /// 是否已关闭（资源已释放）
    public func isClosed(): Bool {
        return closed
    }
    
    /// 检查对象有效性（未关闭且指针有效）
    public func isValid(): Bool {
        return !closed && ptr != 0
    }
    
    /// 检查有效性，无效时抛出异常
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QSqlDatabase 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QSqlDatabase 指针为空")
        }
    }
    
    /// 关闭资源，释放Qt对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qSqlDatabaseClose(ptr)
                qSqlDatabaseDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除数据库连接（兼容旧API）
    public func delete(): Unit {
        close()
    }
}

/// SQL查询
public class QSqlQuery {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe { ptr = qSqlQueryCreate() }
    }
    
    public init(db: QSqlDatabase) {
        unsafe { ptr = qSqlQueryCreateWithDb(db.getPtr()) }
    }
    
    public func exec(sql: String): Bool {
        unsafe {
            var cstr = LibC.mallocCString(sql)
            let result = qSqlQueryExec(ptr, cstr)
            LibC.free(cstr)
            return result
        }
    }
    
    public func execBatch(): Bool {
        unsafe { qSqlQueryExecBatch(ptr) }
    }
    
    public func prepare(sql: String): Bool {
        unsafe {
            var cstr = LibC.mallocCString(sql)
            let result = qSqlQueryPrepare(ptr, cstr)
            LibC.free(cstr)
            return result
        }
    }
    
    public func bindValue(placeholder: String, value: String): Unit {
        unsafe {
            var pstr = LibC.mallocCString(placeholder)
            var vstr = LibC.mallocCString(value)
            qSqlQueryBindValue(ptr, pstr, vstr)
            LibC.free(pstr)
            LibC.free(vstr)
        }
    }
    
    public func bindValueInt(placeholder: String, value: Int32): Unit {
        unsafe {
            var pstr = LibC.mallocCString(placeholder)
            qSqlQueryBindValueInt(ptr, pstr, value)
            LibC.free(pstr)
        }
    }
    
    public func bindValueDouble(placeholder: String, value: Float64): Unit {
        unsafe {
            var pstr = LibC.mallocCString(placeholder)
            qSqlQueryBindValueDouble(ptr, pstr, value)
            LibC.free(pstr)
        }
    }
    
    public func next(): Bool {
        unsafe { qSqlQueryNext(ptr) }
    }
    
    public func previous(): Bool {
        unsafe { qSqlQueryPrevious(ptr) }
    }
    
    public func first(): Bool {
        unsafe { qSqlQueryFirst(ptr) }
    }
    
    public func last(): Bool {
        unsafe { qSqlQueryLast(ptr) }
    }
    
    public func valueString(index: Int32): String {
        unsafe {
            let cstr = qSqlQueryValueString(ptr, index)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    public func valueInt(index: Int32): Int32 {
        unsafe { qSqlQueryValueInt(ptr, index) }
    }
    
    public func valueDouble(index: Int32): Float64 {
        unsafe { qSqlQueryValueDouble(ptr, index) }
    }
    
    public func size(): Int32 {
        unsafe { qSqlQuerySize(ptr) }
    }
    
    public func numRowsAffected(): Int32 {
        unsafe { qSqlQueryNumRowsAffected(ptr) }
    }
    
    public func at(): Int32 {
        unsafe { qSqlQueryAt(ptr) }
    }
    
    public func isValid(): Bool {
        unsafe { qSqlQueryIsValid(ptr) }
    }
    
    public func isActive(): Bool {
        unsafe { qSqlQueryIsActive(ptr) }
    }
    
    public func isSelect(): Bool {
        unsafe { qSqlQueryIsSelect(ptr) }
    }
    
    public func finish(): Unit {
        unsafe { qSqlQueryFinish(ptr) }
    }
    
    public func clear(): Unit {
        unsafe { qSqlQueryClear(ptr) }
    }
    
    public func lastError(): String {
        unsafe {
            let cstr = qSqlQueryLastError(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    /// 获取当前查询的记录元数据
    public func record(): QSqlRecord {
        unsafe {
            let recordPtr = qSqlQueryRecord(ptr)
            if (recordPtr == 0) {
                throw CreateFailedException("QSqlRecord create failed")
            }
            return QSqlRecord(recordPtr)
        }
    }
    
    public func getPtr(): Int64 { ptr }
    
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qSqlQueryDelete(ptr) }
            ptr = 0
        }
    }
}

// ============================================================
// QSqlRecord - 数据库记录（字段集合）
// ============================================================
public class QSqlRecord {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    internal init(p: Int64) {
        ptr = p
    }

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QSqlRecord already deleted")
        }
    }

    /// 获取字段数量
    public func count(): Int32 {
        checkValid()
        unsafe { qSqlRecordCount(ptr) }
    }

    /// 获取字段名
    public func fieldName(index: Int32): String {
        checkValid()
        unsafe {
            let cstr = qSqlRecordFieldName(ptr, index)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 根据字段名查找索引
    public func indexOf(name: String): Int32 {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(name)
            let result = qSqlRecordIndexOf(ptr, cstr)
            LibC.free(cstr)
            return result
        }
    }

    /// 检查字段是否为空
    public func isNull(index: Int32): Bool {
        checkValid()
        unsafe { qSqlRecordIsNull(ptr, index) }
    }

    /// 获取字符串值
    public func valueString(index: Int32): String {
        checkValid()
        unsafe {
            let cstr = qSqlRecordValueString(ptr, index)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 获取整数值
    public func valueInt(index: Int32): Int32 {
        checkValid()
        unsafe { qSqlRecordValueInt(ptr, index) }
    }

    /// 获取浮点值
    public func valueDouble(index: Int32): Float64 {
        checkValid()
        unsafe { qSqlRecordValueDouble(ptr, index) }
    }

    /// 获取字段对象
    public func field(index: Int32): QSqlField {
        checkValid()
        unsafe {
            let fieldPtr = qSqlRecordField(ptr, index)
            if (fieldPtr == 0) {
                throw CreateFailedException("QSqlField create failed")
            }
            return QSqlField(fieldPtr)
        }
    }

    public func getPtr(): Int64 { ptr }

    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe { qSqlRecordDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}

// ============================================================
// QSqlField - 数据库字段
// ============================================================
public class QSqlField {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    internal init(p: Int64) {
        ptr = p
    }

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QSqlField already deleted")
        }
    }

    /// 获取字段名
    public func name(): String {
        checkValid()
        unsafe {
            let cstr = qSqlFieldName(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 字段是否为空
    public func isNull(): Bool {
        checkValid()
        unsafe { qSqlFieldIsNull(ptr) }
    }

    /// 是否只读
    public func isReadOnly(): Bool {
        checkValid()
        unsafe { qSqlFieldIsReadOnly(ptr) }
    }

    /// 是否自动递增
    public func isAutoValue(): Bool {
        checkValid()
        unsafe { qSqlFieldIsAutoValue(ptr) }
    }

    /// 获取字符串值
    public func valueString(): String {
        checkValid()
        unsafe {
            let cstr = qSqlFieldValueString(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    public func getPtr(): Int64 { ptr }

    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe { qSqlFieldDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
