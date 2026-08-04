// ============================================================
// QQ局域网聊天 - 登录窗口
// 输入 QQ 号 / 密码 / 服务器地址，点击登录或注册。
// ============================================================
package qq_lan_client.app

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import std.convert.*
import qq_lan_client.state.*

/// 登录按钮回调
let onLoginClick: VoidCallback = { => doLogin() }

/// 注册链接回调
let onShowRegister: VoidCallback = { => showRegisterDialog() }

/// 回车触发登录
let onLoginReturn: VoidCallback = { => doLogin() }

/// 构建登录窗口并返回
public func buildLoginUI(): QWidget {
    let win = QWidget()
    win.setTitle("QQ局域网聊天 - 登录")
    win.setFixedSize(LOGIN_WIDTH, LOGIN_HEIGHT)
    win.setStyleSheet(loginStyleSheet())

    let vbox = QVBoxLayout()
    vbox.setMargin(20)
    vbox.setSpacing(10)

    // 标题
    let title = QLabel()
    title.setText("QQ 局域网聊天")
    title.setAlignment(Alignment.Center.value)
    title.setStyleSheet("color: white; font-size: 22px; font-weight: bold; background: transparent; border: none;")
    vbox.addWidget(title.getPtr())

    let subtitle = QLabel()
    subtitle.setText("CJQT6 · 局域网即时通讯")
    subtitle.setAlignment(Alignment.Center.value)
    subtitle.setStyleSheet("color: #9FB6CC; font-size: 12px; background: transparent; border: none;")
    vbox.addWidget(subtitle.getPtr())

    vbox.addStretch()

    // 账号
    let account = QLineEdit()
    account.setPlaceholder("QQ 号（如 10000）")
    account.setStyleSheet("background: white; border: 1px solid #B8C7D6; border-radius: 3px; padding: 6px;")
    gAccountEdit = account
    vbox.addWidget(account.getPtr())

    // 密码
    let pwd = QLineEdit()
    pwd.setPlaceholder("密码")
    pwd.setEchoMode(LineEditEchoMode.Password)
    pwd.setStyleSheet("background: white; border: 1px solid #B8C7D6; border-radius: 3px; padding: 6px;")
    pwd.setOnReturnPressed(onLoginReturn)
    gPasswordEdit = pwd
    vbox.addWidget(pwd.getPtr())

    // 服务器地址
    let server = QLineEdit()
    server.setPlaceholder("服务器地址（如 192.168.1.100:9600）")
    server.setText("127.0.0.1:9600")
    server.setStyleSheet("background: white; border: 1px solid #B8C7D6; border-radius: 3px; padding: 6px; color: #333;")
    gServerEdit = server
    vbox.addWidget(server.getPtr())

    // 状态提示
    let status = QLabel()
    status.setText(" ")
    status.setAlignment(Alignment.Center.value)
    status.setStyleSheet("color: #FFD54F; font-size: 12px; background: transparent; border: none;")
    gLoginStatus = status
    vbox.addWidget(status.getPtr())

    // 登录按钮 + 注册链接
    let row = QHBoxLayout()
    let registerLink = QPushButton()
    registerLink.setText("注册账号")
    registerLink.setStyleSheet("color: #9FB6CC; background: transparent; border: none; font-size: 12px;")
    registerLink.setOnClick(onShowRegister)
    row.addWidget(registerLink.getPtr())

    row.addStretch()

    let loginBtn = QPushButton()
    loginBtn.setText("登  录")
    loginBtn.setStyleSheet("background: #12B7F5; color: white; border: none; border-radius: 3px;" +
        "padding: 6px 30px; font-size: 14px; font-weight: bold;")
    loginBtn.setOnClick(onLoginClick)
    row.addWidget(loginBtn.getPtr())
    vbox.addLayout(row.getPtr())

    win.setLayout(vbox.getPtr())
    win
}

/// 设置登录页状态文字
public func setLoginStatus(text: String): Unit {
    if (let Some(l) <- gLoginStatus) {
        l.setText(text)
    }
}

/// 登录流程：校验输入 -> 连接服务器 -> 发送登录帧（由网络层回调驱动后续）
public func doLogin(): Unit {
    var accountText = ""
    var password = ""
    var serverAddr = ""
    if (let Some(e) <- gAccountEdit) { accountText = e.text() }
    if (let Some(e) <- gPasswordEdit) { password = e.text() }
    if (let Some(e) <- gServerEdit) { serverAddr = e.text() }

    if (accountText.isEmpty() || password.isEmpty()) {
        setLoginStatus("请输入 QQ 号和密码")
        return
    }
    let account = Int64.tryParse(accountText)
    match (account) {
        case Some(acc) =>
            let (host, port) = parseServerAddress(serverAddr)
            startLogin(host, port, acc, password)
        case None =>
            setLoginStatus("QQ 号必须是数字")
    }
}
