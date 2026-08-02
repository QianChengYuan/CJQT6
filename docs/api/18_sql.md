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
| `closeDatabase()` | 仅关闭连接（不释放数据库对象） |
| `close()` | 关闭连接并释放资源 |
| `isOpen(): Bool` | 是否已打开 |
| `isClosed(): Bool` / `isValid(): Bool` | 状态查询（是否已释放 / 是否有效） |
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
| `record(): QSqlRecord` | 获取当前查询的记录元数据（字段集合） |
| `lastError(): String` | 获取最后错误信息 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

---

## QSqlRecord - 数据库记录

表示一条查询结果的字段集合（元数据），通过 `QSqlQuery.record()` 获取。注意：**不可直接构造**，只能由查询产生。

```cangjie
let record = query.record()
println("字段数: ${record.count()}")
println("第0字段名: ${record.fieldName(0)}")
println("字段 \"name\" 的索引: ${record.indexOf("name")}")

// 读取字段值
if (!record.isNull(0)) {
    let v = record.valueString(0)
}

// 获取字段对象
let field = record.field(0)
record.close()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `count(): Int32` | 获取字段数量 |
| `fieldName(index: Int32): String` | 获取字段名 |
| `indexOf(name: String): Int32` | 根据字段名查找索引（找不到返回 -1） |
| `isNull(index: Int32): Bool` | 字段是否为空 |
| `valueString(index: Int32): String` | 获取字符串值 |
| `valueInt(index: Int32): Int32` | 获取整数值 |
| `valueDouble(index: Int32): Float64` | 获取浮点值 |
| `field(index: Int32): QSqlField` | 获取字段对象 |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

---

## QSqlField - 数据库字段

单个字段的描述信息（名称、只读性、自增性、值）。通过 `QSqlRecord.field(index)` 获取，**不可直接构造**。

```cangjie
let field = record.field(0)
println("字段名: ${field.name()}")
println("只读: ${field.isReadOnly()}")
println("自增: ${field.isAutoValue()}")
if (!field.isNull()) {
    println("值: ${field.valueString()}")
}
field.close()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `name(): String` | 获取字段名 |
| `isNull(): Bool` | 字段是否为空 |
| `isReadOnly(): Bool` | 是否只读 |
| `isAutoValue(): Bool` | 是否自动递增 |
| `valueString(): String` | 获取字符串值 |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

---

## QSqlTableModel - SQL 表格数据模型

将数据库表映射为可编辑的表格数据模型，常与 `QTableView` 配合显示。实现资源管理，支持 try-with-resources。

```cangjie
let model = QSqlTableModel("my_connection")  // 空串 "" 使用默认连接
model.setTable("users")
model.setFilter("age > 18")
model.setSort(1, 0)            // 按第1列升序（0=升序, 1=降序）
model.setEditStrategy(EditStrategy.onManualSubmit())

if (model.select()) {
    println("行数: ${model.rowCount()}，列数: ${model.columnCount()}")
    // 读取单元格
    let name = model.data(0, 1)
    // 修改单元格后提交
    if (model.setData(0, 2, "30") && model.submitAll()) {
        println("提交成功")
    }
}

// 插入/删除行
model.insertRow(model.rowCount())
model.removeRow(0)
model.revertAll()  // 回滚未提交更改
model.close()
```

**QSqlTableModel 方法**:
| 方法 | 说明 |
|------|------|
| `init(dbName: String)` | 创建模型（dbName 为连接名，空串用默认连接） |
| `setTable(tableName)` / `tableName(): String` | 设置/获取映射的表名 |
| `select(): Bool` | 执行查询填充模型数据 |
| `rowCount(): Int32` / `columnCount(): Int32` | 数据行数 / 列数 |
| `setFilter(filter)` / `filter(): String` | 设置/获取过滤条件（SQL WHERE 子句） |
| `setSort(col, order)` | 设置排序（order: 0 升序, 1 降序） |
| `setEditStrategy(strategy)` / `editStrategy(): Int32` | 设置/获取编辑策略 |
| `data(row, col): String` | 获取指定单元格文本 |
| `setData(row, col, value): Bool` | 设置单元格值 |
| `headerData(section): String` | 获取表头文本 |
| `insertRow(row): Bool` | 插入一行（row 为插入位置） |
| `removeRow(row): Bool` | 删除一行 |
| `submitAll(): Bool` | 提交所有未提交更改到数据库 |
| `revertAll()` | 回滚所有未提交更改 |
| `databaseError(): String` | 获取最近一次数据库操作错误信息 |
| `clearTable()` | 清空表格数据（删除所有行） |
| `fetchMore()` / `canFetchMore(): Bool` | 分页加载更多数据 / 是否还有更多 |
| `getPtr(): Int64` | 获取指针 |
| `close()` / `delete()` | 释放资源 |

**编辑策略常量** (`EditStrategy`，对应 Qt `QSqlTableModel::EditStrategy`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `EditStrategy.onFieldChange()` | 0 | 字段变更时立即提交 |
| `EditStrategy.onRowChange()` | 1 | 行变更时提交 |
| `EditStrategy.onManualSubmit()` | 2 | 手动调用 submitAll 时提交 |

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
