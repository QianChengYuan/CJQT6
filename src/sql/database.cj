package CJQT6.sql

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

/// 数据库驱动类型
public class SqlDriver {
    public static func sqlite(): String { "QSQLITE" }
    public static func mysql(): String { "QMYSQL" }
    public static func postgresql(): String { "QPSQL" }
    public static func odbc(): String { "QODBC" }
    public static func oracle(): String { "QOCI" }
}

/// SQL数据库连接
public class QSqlDatabase {
    private var ptr: Int64 = 0
    
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
        unsafe {
            var cstr = LibC.mallocCString(host)
            qSqlDatabaseSetHostName(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setPort(port: Int32): Unit {
        unsafe { qSqlDatabaseSetPort(ptr, port) }
    }
    
    public func setDatabaseName(name: String): Unit {
        unsafe {
            var cstr = LibC.mallocCString(name)
            qSqlDatabaseSetDatabaseName(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setUserName(user: String): Unit {
        unsafe {
            var cstr = LibC.mallocCString(user)
            qSqlDatabaseSetUserName(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setPassword(password: String): Unit {
        unsafe {
            var cstr = LibC.mallocCString(password)
            qSqlDatabaseSetPassword(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func open(): Bool {
        unsafe { qSqlDatabaseOpen(ptr) }
    }
    
    public func close(): Unit {
        unsafe { qSqlDatabaseClose(ptr) }
    }
    
    public func isOpen(): Bool {
        unsafe { qSqlDatabaseIsOpen(ptr) }
    }
    
    public func lastError(): String {
        unsafe {
            let cstr = qSqlDatabaseLastError(ptr)
            return cstr.toString()
        }
    }
    
    public func driverName(): String {
        unsafe {
            let cstr = qSqlDatabaseDriverName(ptr)
            return cstr.toString()
        }
    }
    
    public func getPtr(): Int64 { ptr }
    
    public func delete() {
        if (ptr != 0) {
            unsafe { qSqlDatabaseDelete(ptr) }
            ptr = 0
        }
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
            return cstr.toString()
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
            return cstr.toString()
        }
    }
    
    public func getPtr(): Int64 { ptr }
    
    public func delete() {
        if (ptr != 0) {
            unsafe { qSqlQueryDelete(ptr) }
            ptr = 0
        }
    }
}
