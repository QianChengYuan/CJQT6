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
    connectBtn.setText("连接数据库")
    let connectCallback: VoidCallback = { =>
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "demo_conn")
        db.setDatabaseName(":memory:")
        if (db.open()) {
            g_db = db
            setStatus("状态: 数据库连接成功")
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
    sqlGroup.setTitle("SQL执行")
    let sqlLayout = QVBoxLayout()
    
    let sqlEdit = QTextEdit()
    sqlEdit.setText("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT);\nINSERT INTO users VALUES (1, '张三');\nINSERT INTO users VALUES (2, '李四');")
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
                        setStatus("状态: SQL执行成功")
                    } else {
                        setStatus("状态: 执行失败")
                    }
                    query.delete()
                }
            }
        }
    }
    execBtn.setOnClick(execCallback)
    
    let queryBtn = QPushButton()
    queryBtn.setText("查询数据")
    let queryCallback: VoidCallback = { =>
        if (let Some(db) <- g_db) {
            if (db.isOpen()) {
                let query = QSqlQuery(db)
                if (query.exec("SELECT * FROM users")) {
                    var result = "结果: "
                    while (query.next()) {
                        result = result + query.valueString(0) + " " + query.valueString(1) + "; "
                    }
                    setStatus(result)
                }
                query.delete()
            }
        }
    }
    queryBtn.setOnClick(queryCallback)
    
    sqlLayout.addWidget(sqlEdit.getPtr())
    sqlLayout.addWidget(execBtn.getPtr())
    sqlLayout.addWidget(queryBtn.getPtr())
    sqlGroup.setLayout(sqlLayout.getPtr())
    mainLayout.addWidget(sqlGroup.getPtr())
    
    // 状态栏
    mainLayout.addWidget(statusLabel.getPtr())
    
    window.setLayout(mainLayout.getPtr())
    window.show()
    
    let result = app.exec()
    
    // 清理
    g_db = None
    g_statusLabel = None
    g_sqlEdit = None
    QSqlDatabase.removeDatabase("demo_conn")
    titleLabel.delete()
    dbPathLabel.delete()
    dbPathEdit.delete()
    connectBtn.delete()
    dbGroup.delete()
    sqlEdit.delete()
    execBtn.delete()
    queryBtn.delete()
    sqlGroup.delete()
    statusLabel.delete()
    window.delete()
    app.delete()
    
    return result
}
