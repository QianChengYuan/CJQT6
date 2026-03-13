package database_demo

import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.gui.*
import CJQT6.sql.*

var g_db: ?QSqlDatabase = None
var g_statusLabel: ?QLabel = None
var g_sqlEdit: ?QTextEdit = None
var g_dbPathEdit: ?QLineEdit = None
var g_hostEdit: ?QLineEdit = None
var g_portEdit: ?QLineEdit = None
var g_userEdit: ?QLineEdit = None
var g_passEdit: ?QLineEdit = None
var g_dbNameEdit: ?QLineEdit = None
var g_dbTypeCombo: ?QComboBox = None

func setStatus(msg: String): Unit {
    if (let Some(label) <- g_statusLabel) {
        label.setText(msg)
    }
    println(msg)
}

func closeConnection(): Unit {
    if (let Some(db) <- g_db) {
        db.close()
        g_db = None
    }
    QSqlDatabase.removeDatabase("demo_conn")
}

// 执行单条SQL
func execSingleSql(db: QSqlDatabase, sql: String): Bool {
    let query = QSqlQuery(db)
    let result = query.exec(sql)
    query.finish()
    query.delete()
    return result
}

// 初始化SQLite数据库
func initSqliteDatabase(db: QSqlDatabase): Unit {
    if (!execSingleSql(db, "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)")) {
        setStatus("创建表失败")
        return
    }
    
    let checkQuery = QSqlQuery(db)
    if (checkQuery.exec("SELECT COUNT(*) FROM users")) {
        if (checkQuery.next() && checkQuery.valueInt(0) == 0) {
            execSingleSql(db, "INSERT INTO users VALUES (1, '张三')")
            execSingleSql(db, "INSERT INTO users VALUES (2, '李四')")
            execSingleSql(db, "INSERT INTO users VALUES (3, '王五')")
            setStatus("SQLite初始化成功，已创建users表并插入示例数据")
        } else {
            setStatus("SQLite连接成功，users表已存在")
        }
        checkQuery.delete()
    } else {
        checkQuery.delete()
        setStatus("SQLite连接成功")
    }
}

// 初始化MySQL数据库
func initMysqlDatabase(db: QSqlDatabase): Unit {
    let query = QSqlQuery(db)
    
    // 创建表
    if (!query.exec("CREATE TABLE IF NOT EXISTS users (id INT PRIMARY KEY, name VARCHAR(100))")) {
        setStatus("创建表失败: ${query.lastError()}")
        query.delete()
        return
    }
    query.finish()
    
    // 检查是否有数据
    if (query.exec("SELECT COUNT(*) FROM users")) {
        if (query.next() && query.valueInt(0) == 0) {
            query.finish()
            execSingleSql(db, "INSERT INTO users VALUES (1, '张三')")
            execSingleSql(db, "INSERT INTO users VALUES (2, '李四')")
            execSingleSql(db, "INSERT INTO users VALUES (3, '王五')")
            setStatus("MySQL初始化成功，已创建users表并插入示例数据")
        } else {
            setStatus("MySQL连接成功，users表已存在")
        }
    }
    query.delete()
}

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("数据库演示 - SQLite/MySQL")
    window.resize(700, 600)
    
    let mainLayout = QVBoxLayout()
    
    // 标题
    let titleLabel = QLabel()
    titleLabel.setText("QSqlDatabase + QSqlQuery 演示 (支持SQLite/MySQL)")
    mainLayout.addWidget(titleLabel.getPtr())
    
    // 数据库类型选择
    let typeGroup = QGroupBox()
    typeGroup.setTitle("数据库类型")
    let typeLayout = QHBoxLayout()
    
    let dbTypeCombo = QComboBox()
    dbTypeCombo.addItem("SQLite")
    dbTypeCombo.addItem("MySQL")
    g_dbTypeCombo = dbTypeCombo
    
    typeLayout.addWidget(dbTypeCombo.getPtr())
    typeGroup.setLayout(typeLayout.getPtr())
    mainLayout.addWidget(typeGroup.getPtr())
    
    // 数据库连接
    let dbGroup = QGroupBox()
    dbGroup.setTitle("数据库连接")
    let dbLayout = QVBoxLayout()
    
    // SQLite配置
    let sqliteLayout = QHBoxLayout()
    let dbPathLabel = QLabel()
    dbPathLabel.setText("SQLite路径:")
    let dbPathEdit = QLineEdit()
    dbPathEdit.setPlaceholder("demo.db 或 /path/to/db.sqlite")
    g_dbPathEdit = dbPathEdit
    sqliteLayout.addWidget(dbPathLabel.getPtr())
    sqliteLayout.addWidget(dbPathEdit.getPtr())
    dbLayout.addLayout(sqliteLayout.getPtr())
    
    // MySQL配置
    let mysqlLayout1 = QHBoxLayout()
    let hostLabel = QLabel()
    hostLabel.setText("主机:")
    let hostEdit = QLineEdit()
    hostEdit.setPlaceholder("localhost")
    g_hostEdit = hostEdit
    let portLabel = QLabel()
    portLabel.setText("端口:")
    let portEdit = QLineEdit()
    portEdit.setPlaceholder("3306")
    g_portEdit = portEdit
    mysqlLayout1.addWidget(hostLabel.getPtr())
    mysqlLayout1.addWidget(hostEdit.getPtr())
    mysqlLayout1.addWidget(portLabel.getPtr())
    mysqlLayout1.addWidget(portEdit.getPtr())
    dbLayout.addLayout(mysqlLayout1.getPtr())
    
    let mysqlLayout2 = QHBoxLayout()
    let userLabel = QLabel()
    userLabel.setText("用户名:")
    let userEdit = QLineEdit()
    userEdit.setPlaceholder("root")
    g_userEdit = userEdit
    let passLabel = QLabel()
    passLabel.setText("密码:")
    let passEdit = QLineEdit()
    passEdit.setPlaceholder("password")
    g_passEdit = passEdit
    mysqlLayout2.addWidget(userLabel.getPtr())
    mysqlLayout2.addWidget(userEdit.getPtr())
    mysqlLayout2.addWidget(passLabel.getPtr())
    mysqlLayout2.addWidget(passEdit.getPtr())
    dbLayout.addLayout(mysqlLayout2.getPtr())
    
    let mysqlLayout3 = QHBoxLayout()
    let dbNameLabel = QLabel()
    dbNameLabel.setText("数据库名:")
    let dbNameEdit = QLineEdit()
    dbNameEdit.setPlaceholder("testdb")
    g_dbNameEdit = dbNameEdit
    mysqlLayout3.addWidget(dbNameLabel.getPtr())
    mysqlLayout3.addWidget(dbNameEdit.getPtr())
    dbLayout.addLayout(mysqlLayout3.getPtr())
    
    let statusLabel = QLabel()
    statusLabel.setText("状态: 就绪")
    g_statusLabel = statusLabel
    
    let connectBtn = QPushButton()
    connectBtn.setText("连接数据库")
    let connectCallback: VoidCallback = { =>
        closeConnection()
        
        // 获取数据库类型
        var dbType: Int32 = 0
        if (let Some(combo) <- g_dbTypeCombo) {
            dbType = combo.currentIndex()
        }
        
        if (dbType == 0) {
            // SQLite
            var dbPath = "demo.db"
            if (let Some(edit) <- g_dbPathEdit) {
                let inputPath = edit.text()
                if (inputPath.size > 0) {
                    dbPath = inputPath
                }
            }
            
            let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "demo_conn")
            db.setDatabaseName(dbPath)
            if (db.open()) {
                g_db = db
                initSqliteDatabase(db)
            } else {
                setStatus("SQLite连接失败: ${db.lastError()}")
            }
        } else {
            // MySQL
            var host = "localhost"
            var port: Int32 = 3306
            var user = "root"
            var pass = ""
            var dbName = "testdb"
            
            if (let Some(edit) <- g_hostEdit) {
                let h = edit.text()
                if (h.size > 0) { host = h }
            }
            if (let Some(edit) <- g_portEdit) {
                let p = edit.text()
                if (p.size > 0) { 
                    // 简单解析端口
                    port = 3306
                    println("端口输入: ${p}")
                }
            }
            if (let Some(edit) <- g_userEdit) {
                let u = edit.text()
                if (u.size > 0) { user = u }
            }
            if (let Some(edit) <- g_passEdit) {
                pass = edit.text()
            }
            if (let Some(edit) <- g_dbNameEdit) {
                let n = edit.text()
                if (n.size > 0) { dbName = n }
            }
            
            let db = QSqlDatabase.addDatabase(SqlDriver.mysql(), "demo_conn")
            db.setHostName(host)
            db.setPort(port)
            db.setDatabaseName(dbName)
            db.setUserName(user)
            db.setPassword(pass)
            
            if (db.open()) {
                g_db = db
                initMysqlDatabase(db)
            } else {
                setStatus("MySQL连接失败: ${db.lastError()}")
            }
        }
    }
    connectBtn.setOnClick(connectCallback)
    
    dbLayout.addWidget(connectBtn.getPtr())
    dbGroup.setLayout(dbLayout.getPtr())
    mainLayout.addWidget(dbGroup.getPtr())
    
    // SQL执行
    let sqlGroup = QGroupBox()
    sqlGroup.setTitle("SQL执行 (单条语句)")
    let sqlLayout = QVBoxLayout()
    
    let sqlEdit = QTextEdit()
    sqlEdit.setText("SELECT * FROM users")
    g_sqlEdit = sqlEdit
    
    let execBtn = QPushButton()
    execBtn.setText("执行SQL")
    let execCallback: VoidCallback = { =>
        if (let Some(db) <- g_db) {
            if (db.isOpen()) {
                if (let Some(edit) <- g_sqlEdit) {
                    let sql = edit.text()
                    let query = QSqlQuery(db)
                    if (query.exec(sql)) {
                        if (sql.startsWith("SELECT") || sql.startsWith("select")) {
                            var result = "结果: "
                            var count = 0
                            while (query.next()) {
                                count++
                                result = result + "[" + query.valueString(0) + ", " + query.valueString(1) + "] "
                            }
                            if (count == 0) {
                                setStatus("查询成功，无数据")
                            } else {
                                setStatus("查询成功，${count} 行: ${result}")
                            }
                        } else {
                            setStatus("SQL执行成功，影响 ${query.numRowsAffected()} 行")
                        }
                    } else {
                        setStatus("执行失败: ${query.lastError()}")
                    }
                    query.finish()
                    query.delete()
                }
            } else {
                setStatus("数据库未打开")
            }
        } else {
            setStatus("请先连接数据库")
        }
    }
    execBtn.setOnClick(execCallback)
    
    sqlLayout.addWidget(sqlEdit.getPtr())
    sqlLayout.addWidget(execBtn.getPtr())
    sqlGroup.setLayout(sqlLayout.getPtr())
    mainLayout.addWidget(sqlGroup.getPtr())
    
    // 状态栏
    mainLayout.addWidget(statusLabel.getPtr())
    
    window.setLayout(mainLayout.getPtr())
    window.show()
    
    let result = app.exec()
    
    // 清理
    closeConnection()
    g_statusLabel = None
    g_sqlEdit = None
    g_dbPathEdit = None
    g_hostEdit = None
    g_portEdit = None
    g_userEdit = None
    g_passEdit = None
    g_dbNameEdit = None
    g_dbTypeCombo = None
    titleLabel.delete()
    dbTypeCombo.delete()
    typeGroup.delete()
    dbPathLabel.delete()
    dbPathEdit.delete()
    hostLabel.delete()
    hostEdit.delete()
    portLabel.delete()
    portEdit.delete()
    userLabel.delete()
    userEdit.delete()
    passLabel.delete()
    passEdit.delete()
    dbNameLabel.delete()
    dbNameEdit.delete()
    connectBtn.delete()
    dbGroup.delete()
    sqlEdit.delete()
    execBtn.delete()
    sqlGroup.delete()
    statusLabel.delete()
    window.delete()
    app.delete()
    
    return result
}
