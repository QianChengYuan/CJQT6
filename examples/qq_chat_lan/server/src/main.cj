// ============================================================
// QQ局域网聊天 - 服务端入口
// 启动流程：打开 SQLite -> 构建服务端窗口 -> QTcpServer 监听 9600
// 运行后局域网内客户端填写本机 IP 即可接入。
// ============================================================
package qq_lan_server

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.dialogs.*
import cjqt6.sql.*
import cjqt6.network.*

/// 清理定时器回调（顶层 CFunc，不捕获变量）
let onCleanupTick: VoidCallback = { => cleanupTick() }

main(): Int32 {
    let app = QApplication()

    // ---- 打开数据库 ----
    let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "qq_lan_server")
    db.setDatabaseName("qq_lan_server.db")
    if (!db.open()) {
        println("服务端错误: 无法打开数据库 qq_lan_server.db")
        return 1
    }
    gDb = ServerDb(db)

    // ---- 构建服务端窗口 ----
    let win = QWidget()
    win.setTitle("QQ局域网聊天 - 服务端")
    win.resize(680, 460)

    let vbox = QVBoxLayout()
    vbox.setMargin(10)
    vbox.setSpacing(8)

    let title = QLabel()
    title.setText("QQ局域网聊天服务端")
    title.setStyleSheet("font-size: 16px; font-weight: bold; color: #1A3A5C;")
    vbox.addWidget(title.getPtr())

    let status = QLabel()
    status.setText("正在启动...")
    status.setStyleSheet("color: #444; padding: 2px 0;")
    gStatus = status
    vbox.addWidget(status.getPtr())

    let logView = QTextEdit()
    logView.setReadOnly(true)
    logView.setStyleSheet("background: #FAFAFA; border: 1px solid #D0D7DE; font-family: Consolas, monospace;")
    gLogView = logView
    vbox.addWidget(logView.getPtr(), 1)

    let tip = QLabel()
    tip.setText("客户端连接方式：服务器地址填写本机局域网 IP（如 192.168.x.x），端口 9600")
    tip.setStyleSheet("color: #888; font-size: 12px;")
    vbox.addWidget(tip.getPtr())

    win.setLayout(vbox.getPtr())
    win.show()

    // ---- 启动 TCP 监听 ----
    let server = QTcpServer()
    if (!server.listen(SERVER_PORT)) {
        QMessageBox.critical(win.getPtr(), "启动失败",
            "监听端口 ${SERVER_PORT} 失败：${server.errorString()}\n请检查端口是否被占用。")
        return 1
    }
    gServer = server
    let _ = server.setOnNewConnectionCapture({ => acceptNewConnections() })
    serverLog("服务端启动，监听 ${server.serverAddress()}:${server.serverPort()}")

    // ---- 会话清理定时器（断开后的套接字统一在此释放）----
    let timer = QTimer()
    timer.setInterval(200)
    timer.setOnTimeout(onCleanupTick)
    timer.start()

    updateStatus()

    let code = app.exec()

    // ---- 退出清理 ----
    timer.stop()
    if (let Some(s) <- gServer) {
        s.close()
    }
    if (let Some(d) <- gDb) {
        d.close()
    }
    db.close()
    db.delete()
    code
}
