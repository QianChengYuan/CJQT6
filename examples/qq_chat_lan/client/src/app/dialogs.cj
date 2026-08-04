// ============================================================
// QQ局域网聊天 - 对话框（注册 / 添加好友）
// ============================================================
package qq_lan_client.app

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import qq_lan_client.core.*
import qq_lan_client.state.*
import std.convert.*

// --------------------------------------------------------
// 注册对话框
// --------------------------------------------------------
public var gRegisterDialog: ?QWidget = None
public var gRegNickname: ?QLineEdit = None
public var gRegPassword: ?QLineEdit = None
public var gRegStatus: ?QLabel = None

let onRegisterSubmit: VoidCallback = { => doRegister() }
let onRegisterCancel: VoidCallback = { => closeRegisterDialog() }

/// "添加好友"按钮回调（供 main_window.cj 使用；定义在本文件以引用 showAddFriendDialog）
public let onAddFriendClick: VoidCallback = { => showAddFriendDialog() }

/// 打开注册对话框
public func showRegisterDialog(): Unit {
    if (let Some(d) <- gRegisterDialog) {
        d.show()
        return
    }
    let dlg = QWidget()
    dlg.setTitle("注册新账号")
    dlg.setFixedSize(340, 260)
    dlg.setStyleSheet("background: white;")

    let vbox = QVBoxLayout()
    vbox.setMargin(18)
    vbox.setSpacing(10)

    let title = QLabel()
    title.setText("注册新账号")
    title.setStyleSheet("font-size: 16px; font-weight: bold; color: #1A3A5C;")
    vbox.addWidget(title.getPtr())

    let tip = QLabel()
    tip.setText("注册成功后系统自动分配 QQ 号")
    tip.setStyleSheet("color: #888; font-size: 12px;")
    vbox.addWidget(tip.getPtr())

    let nick = QLineEdit()
    nick.setPlaceholder("昵称（1-20 个字符）")
    nick.setStyleSheet("background: #F5F7FA; border: 1px solid #D0D7DE; border-radius: 3px; padding: 6px;")
    gRegNickname = nick
    vbox.addWidget(nick.getPtr())

    let pwd = QLineEdit()
    pwd.setPlaceholder("密码（至少 4 位）")
    pwd.setEchoMode(LineEditEchoMode.Password)
    pwd.setStyleSheet("background: #F5F7FA; border: 1px solid #D0D7DE; border-radius: 3px; padding: 6px;")
    gRegPassword = pwd
    vbox.addWidget(pwd.getPtr())

    let status = QLabel()
    status.setText(" ")
    status.setStyleSheet("color: #E57373; font-size: 12px;")
    gRegStatus = status
    vbox.addWidget(status.getPtr())

    let row = QHBoxLayout()
    let cancelBtn = QPushButton()
    cancelBtn.setText("取消")
    cancelBtn.setStyleSheet("background: transparent; color: #666; border: 1px solid #C5CDD8; border-radius: 3px; padding: 6px 18px;")
    cancelBtn.setOnClick(onRegisterCancel)
    row.addWidget(cancelBtn.getPtr())
    row.addStretch()
    let okBtn = QPushButton()
    okBtn.setText("注册")
    okBtn.setStyleSheet("background: #12B7F5; color: white; border: none; border-radius: 3px; padding: 6px 24px; font-weight: bold;")
    okBtn.setOnClick(onRegisterSubmit)
    row.addWidget(okBtn.getPtr())
    vbox.addLayout(row.getPtr())

    dlg.setLayout(vbox.getPtr())
    gRegisterDialog = dlg
    dlg.show()
}

/// 注册状态提示
public func setRegisterStatus(text: String): Unit {
    if (let Some(l) <- gRegStatus) {
        l.setText(text)
    }
}

/// 提交注册请求
public func doRegister(): Unit {
    var nickname = ""
    var password = ""
    if (let Some(e) <- gRegNickname) { nickname = e.text() }
    if (let Some(e) <- gRegPassword) { password = e.text() }
    if (nickname.isEmpty()) {
        setRegisterStatus("请输入昵称")
        return
    }
    if (password.size < 4) {
        setRegisterStatus("密码至少 4 位")
        return
    }
    if (gConnected) {
        setRegisterStatus("正在注册...")
        sendRaw("{\"type\":\"register\",\"nickname\":\"${escapeJson(nickname)}\",\"password\":\"${escapeJson(password)}\"}")
    } else {
        // 未连接：先连接登录页填写的服务器，连接成功后自动发送注册帧
        var serverAddr = ""
        if (let Some(e) <- gServerEdit) { serverAddr = e.text() }
        let (host, port) = parseServerAddress(serverAddr)
        startRegister(host, port, nickname, password)
    }
}

/// 关闭注册对话框
public func closeRegisterDialog(): Unit {
    if (let Some(d) <- gRegisterDialog) {
        d.hide()
    }
}

// --------------------------------------------------------
// 添加好友对话框
// --------------------------------------------------------
public var gAddFriendDialog: ?QWidget = None
public var gAddAccountEdit: ?QLineEdit = None
public var gAddStatus: ?QLabel = None

let onAddFriendSubmit: VoidCallback = { => doAddFriend() }
let onAddFriendCancel: VoidCallback = { => closeAddFriendDialog() }

/// 打开添加好友对话框
public func showAddFriendDialog(): Unit {
    if (let Some(d) <- gAddFriendDialog) {
        d.show()
        return
    }
    let dlg = QWidget()
    dlg.setTitle("添加好友")
    dlg.setFixedSize(340, 200)
    dlg.setStyleSheet("background: white;")

    let vbox = QVBoxLayout()
    vbox.setMargin(18)
    vbox.setSpacing(10)

    let title = QLabel()
    title.setText("按 QQ 号添加好友")
    title.setStyleSheet("font-size: 16px; font-weight: bold; color: #1A3A5C;")
    vbox.addWidget(title.getPtr())

    let edit = QLineEdit()
    edit.setPlaceholder("输入对方的 QQ 号")
    edit.setStyleSheet("background: #F5F7FA; border: 1px solid #D0D7DE; border-radius: 3px; padding: 6px;")
    gAddAccountEdit = edit
    vbox.addWidget(edit.getPtr())

    let status = QLabel()
    status.setText(" ")
    status.setStyleSheet("color: #E57373; font-size: 12px;")
    gAddStatus = status
    vbox.addWidget(status.getPtr())

    let row = QHBoxLayout()
    let cancelBtn = QPushButton()
    cancelBtn.setText("取消")
    cancelBtn.setStyleSheet("background: transparent; color: #666; border: 1px solid #C5CDD8; border-radius: 3px; padding: 6px 18px;")
    cancelBtn.setOnClick(onAddFriendCancel)
    row.addWidget(cancelBtn.getPtr())
    row.addStretch()
    let okBtn = QPushButton()
    okBtn.setText("添加")
    okBtn.setStyleSheet("background: #12B7F5; color: white; border: none; border-radius: 3px; padding: 6px 24px; font-weight: bold;")
    okBtn.setOnClick(onAddFriendSubmit)
    row.addWidget(okBtn.getPtr())
    vbox.addLayout(row.getPtr())

    dlg.setLayout(vbox.getPtr())
    gAddFriendDialog = dlg
    dlg.show()
}

/// 添加好友状态提示
public func setAddFriendStatus(text: String): Unit {
    if (let Some(l) <- gAddStatus) {
        l.setText(text)
    }
}

/// 提交添加好友请求
public func doAddFriend(): Unit {
    var text = ""
    if (let Some(e) <- gAddAccountEdit) { text = e.text() }
    if (text.isEmpty()) {
        setAddFriendStatus("请输入对方 QQ 号")
        return
    }
    match (Int64.tryParse(text)) {
        case Some(account) =>
            setAddFriendStatus("正在添加...")
            sendRaw("{\"type\":\"add_friend\",\"account\":${account}}")
        case None =>
            setAddFriendStatus("QQ 号必须是数字")
    }
}

/// 关闭添加好友对话框
public func closeAddFriendDialog(): Unit {
    if (let Some(d) <- gAddFriendDialog) {
        d.hide()
    }
    if (let Some(e) <- gAddAccountEdit) {
        e.setText("")
    }
    setAddFriendStatus(" ")
}
