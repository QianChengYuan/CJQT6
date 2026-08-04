package qq_chat.app

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.menu.*
import std.convert.*
import qq_chat.core.*
import qq_chat.state.*

let onLoginClick: VoidCallback = {
    => doLogin()
}

let onLogoutClick: VoidCallback = {
    => doLogout()
}

let onRegisterClick: VoidCallback = {
    => showRegisterDialog()
}

let onLoginReturnPressed: VoidCallback = {
    => doLogin()
}

let onAdvancedSettingsClick: VoidCallback = {
    => toggleAdvancedSettings()
}

let onTogglePasswordVisibilityClick: VoidCallback = {
    => togglePasswordVisibility()
}

public func togglePasswordVisibility(): Unit {
    if (let Some(edit) <- gPasswordEdit) {
        if (edit.echoMode() == LineEditEchoMode.Password) {
            edit.setEchoMode(LineEditEchoMode.Normal)
        } else {
            edit.setEchoMode(LineEditEchoMode.Password)
        }
    }
}

public func doLogin(): Unit {
    if (let Some(edit) <- gAccountEdit) {
        if (let Some(pwd) <- gPasswordEdit) {
            let accountStr = edit.text()
            let password = pwd.text()
            if (accountStr.isEmpty() || password.isEmpty()) {
                if (let Some(label) <- gStatusLabel) {
                    label.setVisible(true)
                    label.setText("请输入账号和密码")
                }
                return
            }
            if (let Some(account) <- Int64.tryParse(accountStr)) {
                if (account < 10000) {
                    if (let Some(label) <- gStatusLabel) {
                    label.setVisible(true)
                        label.setText("账号格式不正确，请输入5位数字账号")
                    }
                    return
                }
                if (let Some(db) <- gDb) {
                    let userOpt = db.login(account, password)
                    if (let Some(user) <- userOpt) {
                        gCurrentUser = Some(user)
                        if (let Some(combo) <- gLoginStatusCombo) {
                            gLoginStatus = combo.currentIndex()
                        }
                        if (let Some(lw) <- gLoginWindow) {
                            lw.hide()
                        }
                        buildMainWindow()
                    } else {
                        if (let Some(label) <- gStatusLabel) {
                    label.setVisible(true)
                            label.setText("账号或密码错误")
                        }
                    }
                }
            } else {
                if (let Some(label) <- gStatusLabel) {
                    label.setText("账号格式不正确，请输入5位数字账号")
                }
            }
        }
    }
}

public func doLogout(): Unit {
    if (let Some(timer) <- gPollTimer) {
        timer.stop()
        timer.delete()
        gPollTimer = None
    }
    if (let Some(cw) <- gChatWindow) {
        cw.delete()
        gChatWindow = None
    }
    gCurrentUser = None
    gCurrentFriendId = 0
    gFriendCache.clear()
    gUnreadMap.clear()
    if (let Some(mw) <- gMainWindow) {
        mw.delete();
        gMainWindow = None
    }
    if (let Some(fp) <- gFriendPanel) {
        fp.delete()
        gFriendPanel = None
    }
    closeEmojiPanel()
    if (let Some(edit) <- gAccountEdit) {
        edit.setText("")
    }
    if (let Some(pwd) <- gPasswordEdit) {
        pwd.setText("")
        pwd.setEchoMode(LineEditEchoMode.Password)
    }
    if (let Some(label) <- gStatusLabel) {
        label.setText("")
    }
    if (let Some(lw) <- gLoginWindow) {
        lw.show()
    }
}

public func toggleAdvancedSettings(): Unit {
    gAdvancedSettingsVisible = !gAdvancedSettingsVisible
    if (let Some(panel) <- gAdvancedSettingsPanel) {
        panel.setVisible(gAdvancedSettingsVisible)
    }
    if (let Some(btn) <- gAdvancedSettingsBtn) {
        if (gAdvancedSettingsVisible) {
            btn.setText("高级设置 ↓")
        } else {
            btn.setText("高级设置 →")
        }
    }
    if (let Some(lw) <- gLoginWindow) {
        if (gAdvancedSettingsVisible) {
            lw.setFixedSize(LOGIN_WIDTH, LOGIN_HEIGHT_EXPANDED)
        } else {
            lw.setFixedSize(LOGIN_WIDTH, LOGIN_HEIGHT)
        }
    }
}

public func buildLoginUI(): QWidget {
    let window = QWidget()
    window.setTitle("QQ用户登录")
    window.setFixedSize(LOGIN_WIDTH, LOGIN_HEIGHT)
    window.setStyleSheet(buildLoginWindowStyleSheet())

    let layout = QVBoxLayout()
    layout.setMargin(0)
    layout.setSpacing(0)

    // ---- 顶部标题区 ----
    let header = QWidget()
    header.setStyleSheet("background: transparent;")
    let headerLayout = QHBoxLayout()
    headerLayout.setMargin(12)
    headerLayout.setSpacing(8)

    let logoLabel = QLabel()
    let logoOpt = loadPenguinLogo(PENGUIN_LOGO_SIZE)
    if (let Some(logo) <- logoOpt) {
        logoLabel.setPixmap(logo.getPtr())
    } else {
        logoLabel.setText("🐧")
        logoLabel.setStyleSheet("font-size: 32px;")
    }
    headerLayout.addWidget(logoLabel.getPtr())

    let headerTextCol = QVBoxLayout()
    headerTextCol.setSpacing(0)
    let qqTitle = QLabel()
    qqTitle.setText("QQ2005")
    qqTitle.setStyleSheet("color: white; font-size: 22px; font-weight: bold;")
    headerTextCol.addWidget(qqTitle.getPtr())
    let qqSubtitle = QLabel()
    qqSubtitle.setText("用户登录")
    qqSubtitle.setStyleSheet("color: #AAC0D8; font-size: 12px;")
    headerTextCol.addWidget(qqSubtitle.getPtr())
    headerLayout.addLayout(headerTextCol.getPtr())
    headerLayout.addStretch()
    header.setLayout(headerLayout.getPtr())
    layout.addWidget(header.getPtr())

    // ---- 表单区域 ----
    let formArea = QVBoxLayout()
    formArea.setMargin(16)
    formArea.setSpacing(10)

    // 输入框样式：白色底、深色边框、易于看到
    let inputStyle = "QLineEdit { background: white; border: 2px solid #6B90C8; border-radius: 3px; font-size: 13px; padding: 6px 8px; } QLineEdit:focus { border: 2px solid #4A90D9; }"

    // QQ 号码行
    let accountRow = QHBoxLayout()
    accountRow.setSpacing(6)
    let accountIcon = QLabel()
    let sp1Opt = loadPenguinSmall(PENGUIN_SMALL_SIZE)
    if (let Some(sp) <- sp1Opt) {
        accountIcon.setPixmap(sp.getPtr())
    } else {
        accountIcon.setText("🐧")
    }
    accountRow.addWidget(accountIcon.getPtr())
    let accountEdit = QLineEdit()
    accountEdit.setPlaceholder("QQ号码")
    accountEdit.setStyleSheet(inputStyle)
    accountEdit.setAlignment((Alignment.Left | Alignment.VCenter).value)
    accountEdit.setOnReturnPressed(onLoginReturnPressed)
    gAccountEdit = accountEdit
    accountRow.addWidget(accountEdit.getPtr())
    formArea.addLayout(accountRow.getPtr())

    // QQ 密码行
    let pwdRow = QHBoxLayout()
    pwdRow.setSpacing(6)
    let pwdIcon = QLabel()
    let sp2Opt = loadPenguinSmall(PENGUIN_SMALL_SIZE)
    if (let Some(sp) <- sp2Opt) {
        pwdIcon.setPixmap(sp.getPtr())
    } else {
        pwdIcon.setText("🔒")
    }
    pwdRow.addWidget(pwdIcon.getPtr())
    let pwdEdit = QLineEdit()
    pwdEdit.setPlaceholder("QQ密码")
    pwdEdit.setEchoMode(LineEditEchoMode.Password)
    pwdEdit.setStyleSheet(inputStyle)
    pwdEdit.setOnReturnPressed(onLoginReturnPressed)
    gPasswordEdit = pwdEdit
    pwdRow.addWidget(pwdEdit.getPtr())
    // 小眼睛查看密码
    let eyeBtn = QPushButton()
    eyeBtn.setText("👁")
    eyeBtn.setStyleSheet("QPushButton { border: 1px solid #6B90C8; border-radius: 3px; background: #FFFFFF; font-size: 14px; padding: 4px 8px; } QPushButton:hover { background: #E8EDF2; }")
    eyeBtn.setOnClick(onTogglePasswordVisibilityClick)
    pwdRow.addWidget(eyeBtn.getPtr())
    formArea.addLayout(pwdRow.getPtr())

    // 申请号码 链接
    let applyLink = createLink("申请号码", onRegisterClick)
    applyLink.setStyleSheet("QPushButton { color: #60A0D0; border: none; background: transparent; font-size: 11px; padding: 0; text-align: left; } QPushButton:hover { color: #80C0F0; text-decoration: underline; }")
    formArea.addWidget(applyLink.getPtr())

    // 状态下拉
    let statusCombo = QComboBox()
    statusCombo.addItem("在线")
    statusCombo.addItem("离开")
    statusCombo.addItem("隐身")
    statusCombo.addItem("忙碌")
    statusCombo.setStyleSheet("QComboBox { background: white; border: 2px solid #6B90C8; border-radius: 3px; font-size: 12px; padding: 4px 6px; min-height: 22px; }")
    gLoginStatusCombo = statusCombo
    formArea.addWidget(statusCombo.getPtr())

    // 记住密码 + 自动登录
    let checkRow = QHBoxLayout()
    checkRow.setSpacing(16)
    let rememberCheck = QCheckBox()
    rememberCheck.setText("记住密码")
    rememberCheck.setStyleSheet("QCheckBox { color: white; font-size: 12px; spacing: 4px; } QCheckBox::indicator { width: 14px; height: 14px; background: white; border: 1px solid #7A9CC6; border-radius: 2px; } QCheckBox::indicator:checked { background: #4A90D9; }")
    gRememberPwdCheck = rememberCheck
    checkRow.addWidget(rememberCheck.getPtr())
    let autoLoginCheck = QCheckBox()
    autoLoginCheck.setText("自动登录")
    autoLoginCheck.setStyleSheet("QCheckBox { color: white; font-size: 12px; spacing: 4px; } QCheckBox::indicator { width: 14px; height: 14px; background: white; border: 1px solid #7A9CC6; border-radius: 2px; } QCheckBox::indicator:checked { background: #4A90D9; }")
    gAutoLoginCheck = autoLoginCheck
    checkRow.addWidget(autoLoginCheck.getPtr())
    checkRow.addStretch()
    formArea.addLayout(checkRow.getPtr())

    layout.addLayout(formArea.getPtr())

    // ---- 底部按钮区 ----
    let bottomArea = QVBoxLayout()
    bottomArea.setMargin(8)
    bottomArea.setSpacing(4)

    let advBtn = QPushButton()
    advBtn.setText("高级设置 →")
    advBtn.setStyleSheet("QPushButton { color: rgba(255,255,255,0.7); background: transparent; border: none; font-size: 11px; text-align: left; padding: 2px 0; } QPushButton:hover { color: white; }")
    advBtn.setOnClick(onAdvancedSettingsClick)
    gAdvancedSettingsBtn = advBtn
    bottomArea.addWidget(advBtn.getPtr())

    let advPanel = QWidget()
    let advLayout = QVBoxLayout()
    advLayout.setMargin(0)
    advLayout.setSpacing(4)
    let serverRow = QHBoxLayout()
    serverRow.setSpacing(4)
    let serverLabel = QLabel()
    serverLabel.setText("服务器:")
    serverLabel.setStyleSheet("color: rgba(255,255,255,0.7); font-size: 11px;")
    serverRow.addWidget(serverLabel.getPtr())
    let serverEdit = QLineEdit()
    serverEdit.setText("127.0.0.1")
    serverEdit.setStyleSheet("QLineEdit { background: white; border: 2px solid #6B90C8; border-radius: 2px; font-size: 11px; padding: 2px 4px; }")
    serverRow.addWidget(serverEdit.getPtr())
    advLayout.addLayout(serverRow.getPtr())
    let proxyRow = QHBoxLayout()
    proxyRow.setSpacing(4)
    let proxyLabel = QLabel()
    proxyLabel.setText("代理:")
    proxyLabel.setStyleSheet("color: rgba(255,255,255,0.7); font-size: 11px;")
    proxyRow.addWidget(proxyLabel.getPtr())
    let proxyEdit = QLineEdit()
    proxyEdit.setStyleSheet("QLineEdit { background: white; border: 2px solid #6B90C8; border-radius: 2px; font-size: 11px; padding: 2px 4px; }")
    proxyRow.addWidget(proxyEdit.getPtr())
    advLayout.addLayout(proxyRow.getPtr())
    advPanel.setLayout(advLayout.getPtr())
    advPanel.setVisible(false)
    gAdvancedSettingsPanel = advPanel
    bottomArea.addWidget(advPanel.getPtr())

    let loginBtn = QPushButton()
    loginBtn.setText("登 录")
    loginBtn.setStyleSheet("QPushButton { background-color: #2E6CB5; color: white; font-size: 14px; font-weight: bold; padding: 8px; border: 1px solid #1A4D8C; border-radius: 3px; } QPushButton:hover { background-color: #3478C8; } QPushButton:pressed { background-color: #255DA0; }")
    loginBtn.setOnClick(onLoginClick)
    bottomArea.addWidget(loginBtn.getPtr())

    // 状态标签——默认隐藏，只有出错时才显示
    let status = QLabel()
    status.setAlignment(Alignment.Center.value)
    status.setStyleSheet("color: #FF6B6B; font-size: 12px; padding: 2px;")
    status.setVisible(false)
    gStatusLabel = status
    bottomArea.addWidget(status.getPtr())

    layout.addLayout(bottomArea.getPtr())

    window.setLayout(layout.getPtr())
    return window
}
