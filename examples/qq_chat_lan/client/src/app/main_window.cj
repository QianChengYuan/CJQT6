// ============================================================
// QQ局域网聊天 - 好友面板（主窗口）
// 顶部：头像 + 昵称 + QQ 号
// 中部：好友列表（在线状态 / 未读提示，双击打开聊天窗口）
// 底部：添加好友 / 退出登录
// ============================================================
package qq_lan_client.app

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.views.*
import std.collection.*
import qq_lan_client.core.*
import qq_lan_client.state.*

/// 好友列表双击回调（CFunc：row -> 打开会话）
let onFriendDoubleClicked: Int32Callback = { row: Int32 => openChatByRow(row) }

/// 退出登录按钮
let onLogoutClick: VoidCallback = { => doLogout() }

/// 构建好友面板
public func buildMainWindow(): Unit {
    let win = QWidget()
    win.setTitle("QQ局域网聊天")
    win.resize(MAIN_WIDTH, MAIN_HEIGHT)
    win.setStyleSheet("background: ${MAIN_BG};")

    let vbox = QVBoxLayout()
    vbox.setMargin(0)
    vbox.setSpacing(0)

    // ---- 标题栏（渐变蓝）----
    let titleBar = QWidget()
    titleBar.setStyleSheet(panelTitleStyleSheet())
    titleBar.setMinimumSize(MAIN_WIDTH, 84)
    titleBar.setMaximumSize(MAIN_WIDTH + 400, 84)
    let titleLayout = QHBoxLayout()
    titleLayout.setMargin(12)
    titleLayout.setSpacing(10)

    // 自己的头像
    var selfName = "我"
    if (let Some(s) <- gSelf) { selfName = s.nickname }
    let (ar, ag, ab) = colorFromName(selfName)
    let selfAvatar = createAvatarPixmap(ar, ag, ab, firstCharOf(selfName), BIG_AVATAR_SIZE)
    let avatarLabel = QLabel()
    avatarLabel.setPixmap(selfAvatar.getPtr())
    avatarLabel.setStyleSheet("background: transparent; border: none;")
    titleLayout.addWidget(avatarLabel.getPtr())
    selfAvatar.delete()

    let infoBox = QVBoxLayout()
    infoBox.setSpacing(2)
    let nameLabel = QLabel()
    nameLabel.setText(selfName)
    nameLabel.setStyleSheet("color: white; font-size: 15px; font-weight: bold; background: transparent; border: none;")
    infoBox.addWidget(nameLabel.getPtr())
    let selfLabel = QLabel()
    selfLabel.setText(" ")
    selfLabel.setStyleSheet("color: #B8D4EE; font-size: 12px; background: transparent; border: none;")
    gSelfLabel = selfLabel
    infoBox.addWidget(selfLabel.getPtr())
    titleLayout.addLayout(infoBox.getPtr())
    titleBar.setLayout(titleLayout.getPtr())
    vbox.addWidget(titleBar.getPtr())

    // ---- 好友列表 ----
    let list = QListWidget()
    list.setStyleSheet("QListWidget { background: white; border: none; font-size: 13px; }" +
        "QListWidget::item { padding: 8px 6px; border-bottom: 1px solid #F0F2F5; }" +
        "QListWidget::item:selected { background: #E8F3FF; color: #333; }")
    list.setOnItemDoubleClicked(onFriendDoubleClicked)
    gFriendList = list
    vbox.addWidget(list.getPtr(), 1)

    // ---- 底部操作行 ----
    let bottomBar = QWidget()
    bottomBar.setStyleSheet("background: #EBEEF2; border-top: 1px solid #D8DEE6;")
    bottomBar.setMinimumSize(MAIN_WIDTH, 44)
    bottomBar.setMaximumSize(MAIN_WIDTH + 400, 44)
    let bottomLayout = QHBoxLayout()
    bottomLayout.setMargin(8)
    bottomLayout.setSpacing(8)

    let addBtn = QPushButton()
    addBtn.setText("＋ 添加好友")
    addBtn.setStyleSheet("background: #12B7F5; color: white; border: none; border-radius: 3px; padding: 6px 12px;")
    addBtn.setOnClick(onAddFriendClick)
    bottomLayout.addWidget(addBtn.getPtr())

    bottomLayout.addStretch()

    let logoutBtn = QPushButton()
    logoutBtn.setText("退出登录")
    logoutBtn.setStyleSheet("background: transparent; color: #666; border: 1px solid #C5CDD8; border-radius: 3px; padding: 6px 12px;")
    logoutBtn.setOnClick(onLogoutClick)
    bottomLayout.addWidget(logoutBtn.getPtr())

    bottomBar.setLayout(bottomLayout.getPtr())
    vbox.addWidget(bottomBar.getPtr())

    win.setLayout(vbox.getPtr())
    gMainWindow = win
}

/// 刷新好友列表（全量重建：头像 + 在线状态 + 未读角标）
public func refreshFriendList(): Unit {
    match (gFriendList) {
        case Some(list) =>
            list.clear()
            var row: Int32 = 0
            for (f in gFriends) {
                let unread = gUnread.get(f.id) ?? 0
                var text = "${f.nickname}"
                text = if (f.online) { "${text} · 在线" } else { "${text} · 离线" }
                if (unread > 0) {
                    text = "${text} [${unread}条未读]"
                }
                let _ = list.addItem(text)
                let (r, g, b) = colorFromName(f.nickname)
                let pm = createAvatarPixmap(r, g, b, firstCharOf(f.nickname), AVATAR_SIZE)
                list.setItemIconPixmap(row, pm)
                pm.delete()
                row++
            }
        case None => ()
    }
}

/// 双击某行打开会话
public func openChatByRow(row: Int32): Unit {
    if (row < 0 || Int64(row) >= gFriends.size) { return }
    let f = gFriends[Int64(row)]
    openChatWithFriend(f.id)
}

/// 退出登录
public func doLogout(): Unit {
    logoutAndClose()
    if (let Some(w) <- gChatWindow) { w.hide() }
    if (let Some(w) <- gMainWindow) { w.hide() }
    gCurrentChatId = 0
    gSelf = None
    if (let Some(w) <- gLoginWindow) {
        w.show()
    }
    setLoginStatus("已退出登录")
}
