# CJQT6 SQL 数据库模块

本模块提供 Qt SQL 模块的封装，支持多种数据库的连接和查询操作。

## 模块导入

```cangjie
import cjqt6.sql.*
```

## 支持的数据库驱动（SqlDriver）

| 驱动 | 说明 |
|------|------|
| `SqlDriver.sqlite()` | SQLite 数据库 |
| `SqlDriver.mysql()` | MySQL 数据库 |
| `SqlDriver.postgresql()` | PostgreSQL 数据库 |
| `SqlDriver.odbc()` | ODBC 数据库 |
| `SqlDriver.oracle()` | Oracle 数据库 |

---

## QSqlDatabase - 数据库连接

管理数据库连接，支持添加、获取和移除连接。

```cangjie
// 添加 SQLite 数据库连接
let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "my_connection")
db.setDatabaseName("mydb.sqlite")
// db.setHostName("localhost")
// db.setPort(3306)
// db.setUserName("user")
// db.setPassword("password")

// 打开连接
if (db.open()) {
    println("数据库连接成功")
} else {
    println("连接失败: ${db.lastError()}")
}

// 检查状态
if (db.isOpen()) {
    let driver = db.driverName()
}

// 获取已存在的连接
let existingDb = QSqlDatabase.database("my_connection")

// 移除连接
QSqlDatabase.removeDatabase("my_connection")

// 使用完毕后关闭
db.close()
db.delete()
```

**QSqlDatabase 方法**:
| 方法 | 说明 |
|------|------|
| `addDatabase(driverType, connectionName): QSqlDatabase` | 添加数据库连接（静态方法） |
| `database(connectionName): QSqlDatabase` | 获取已存在的连接（静态方法） |
| `removeDatabase(connectionName)` | 移除数据库连接（静态方法） |
| `setHostName(host: String)` | 设置主机地址 |
| `setPort(port: Int32)` | 设置端口号 |
| `setDatabaseName(name: String)` | 设置数据库名称 |
| `setUserName(user: String)` | 设置用户名 |
| `setPassword(password: String)` | 设置密码 |
| `open(): Bool` | 打开数据库连接 |
| `close()` | 关闭数据库连接 |
| `isOpen(): Bool` | 是否已打开 |
| `lastError(): String` | 获取最后错误信息 |
| `driverName(): String` | 获取驱动名称 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

---

## QSqlQuery - SQL 查询

执行 SQL 语句并处理查询结果，支持参数化查询以防止 SQL 注入。

```cangjie
// 创建查询
let query = QSqlQuery()
// 或绑定到特定数据库
// let query = QSqlQuery(db)

// 执行 SQL
if (query.exec("SELECT * FROM users")) {
    // 遍历结果集
    while (query.next()) {
        let name = query.valueString(0)   // 第0列（字符串）
        let age = query.valueInt(1)       // 第1列（整数）
        let salary = query.valueDouble(2) // 第2列（浮点数）
        println("${name}, ${age}, ${salary}")
    }
}

// 参数化查询（推荐，防 SQL 注入）
query.prepare("INSERT INTO users (name, age) VALUES (?, ?)")
query.bindValue(":name", "Alice")
query.bindValueInt(":age", 25)
if (query.exec("")) {  // 执行预编译的 SQL
    println("插入成功，影响行数: ${query.numRowsAffected()}")
}

// 导航结果集
query.first()     // 跳转到第一条
query.last()      // 跳转到最后一条
query.previous()  // 上一条
query.at()        // 当前索引

// 查询状态
if (query.isActive()) {
    println("查询活跃中")
}
if (query.isSelect()) {
    println("这是一个 SELECT 查询")
}

// 获取查询大小
let size = query.size()

// 完成/清理
query.finish()
query.clear()
query.delete()
```

**QSqlQuery 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建查询 |
| `init(db: QSqlDatabase)` | 绑定到指定数据库的查询 |
| `exec(sql: String): Bool` | 执行 SQL 语句 |
| `execBatch(): Bool` | 批量执行 |
| `prepare(sql: String): Bool` | 预编译 SQL 语句 |
| `bindValue(placeholder, value: String)` | 绑定字符串参数 |
| `bindValueInt(placeholder, value: Int32)` | 绑定整数参数 |
| `bindValueDouble(placeholder, value: Float64)` | 绑定浮点数参数 |
| `next(): Bool` | 移动到下一条记录 |
| `previous(): Bool` | 移动到上一条记录 |
| `first(): Bool` | 移动到第一条记录 |
| `last(): Bool` | 移动到最后一条记录 |
| `valueString(index: Int32): String` | 获取字符串类型字段值 |
| `valueInt(index: Int32): Int32` | 获取整数类型字段值 |
| `valueDouble(index: Int32): Float64` | 获取浮点类型字段值 |
| `size(): Int32` | 获取结果集大小 |
| `numRowsAffected(): Int32` | 获取影响的行数 |
| `at(): Int32` | 获取当前索引 |
| `isValid(): Bool` | 结果集是否有效 |
| `isActive(): Bool` | 查询是否活跃 |
| `isSelect(): Bool` | 是否为 SELECT 查询 |
| `finish()` | 结束查询 |
| `clear()` | 清空查询 |
| `lastError(): String` | 获取最后错误信息 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

---

## 完整示例

```cangjie
import cjqt6.sql.*

main(): Int32 {
    // 创建 SQLite 数据库
    let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "test")
    db.setDatabaseName("test.db")
    
    if (!db.open()) {
        println("打开数据库失败: ${db.lastError()}")
        return -1
    }
    
    // 建表
    let query = QSqlQuery()
    query.exec("CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER
    )")
    
    // 插入数据
    query.prepare("INSERT INTO users (name, age) VALUES (:name, :age)")
    query.bindValue(":name", "Alice")
    query.bindValueInt(":age", 30)
    query.exec("")
    
    // 查询
    query.exec("SELECT * FROM users")
    while (query.next()) {
        let id = query.valueInt(0)
        let name = query.valueString(1)
        let age = query.valueInt(2)
        println("ID: ${id}, Name: ${name}, Age: ${age}")
    }
    
    query.delete()
    db.close()
    db.delete()
    QSqlDatabase.removeDatabase("test")
    
    return 0
}
```
