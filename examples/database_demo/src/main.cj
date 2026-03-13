package database_demo

import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.gui.*
import CJQT6.sql.*

var g_db: ?QSqlDatabase = None
var g_statusLabel: ?QLabel = None
var g_sqlEdit: ?QTextEdit = None

func setStatus(msg: String): Unit {
    if (let Some(label) <- g_statusLabel) {
        label.setText(msg)
    }
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

// 初始化数据库表和数据
func initDatabase(db: QSqlDatabase): Unit {
    // 创建表
    if (!execSingleSql(db, "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)")) {
        setStatus("创建表失败")
        return
    }
    
    // 插入数据
    execSingleSql(db, "INSERT OR REPLACE INTO users VALUES (1, '张三')")
    execSingleSql(db, "INSERT OR REPLACE INTO users VALUES (2, '李四')")
    execSingleSql(db, "INSERT OR REPLACE INTO users VALUES (3, '王五')")
    
    setStatus("数据库初始化成功，已创建users表并插入示例数据")
}

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("数据库演示 - SQLite")
    window.resize(600, 500)
    
    let mainLayout = QVBoxLayout()
    
    // 标题
    let titleLabel = QLabel()
    titleLabel.setText("QSqlDatabase + QSqlQuery 演示")
    mainLayout.addWidget(titleLabel.getPtr())
    
    // 数据库连接
    let dbGroup = QGroupBox()
    dbGroup.setTitle("数据库连接")
    let dbLayout = QVBoxLayout()
    
    let dbPathLabel = QLabel()
    dbPathLabel.setText("SQLite数据库路径 (留空使用内存数据库):")
    let dbPathEdit = QLineEdit()
    dbPathEdit.setPlaceholder(":memory: 或 /path/to/db.sqlite")
    
    let statusLabel = QLabel()
    statusLabel.setText("状态: 就绪")
    g_statusLabel = statusLabel
    
    let connectBtn = QPushButton()
    connectBtn.setText("连接数据库并初始化")
    let connectCallback: VoidCallback = { =>
        // 先关闭旧连接
        closeConnection()
        
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "demo_conn")
        db.setDatabaseName(":memory:")
        if (db.open()) {
            g_db = db
            initDatabase(db)
        } else {
            setStatus("状态: 连接失败")
        }
    }
    connectBtn.setOnClick(connectCallback)
    
    dbLayout.addWidget(dbPathLabel.getPtr())
    dbLayout.addWidget(dbPathEdit.getPtr())
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
                        // 如果是SELECT，显示结果
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
    titleLabel.delete()
    dbPathLabel.delete()
    dbPathEdit.delete()
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
