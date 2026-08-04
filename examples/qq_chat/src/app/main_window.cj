package qq_chat.app

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.menu.*
import cjqt6.views.*
import cjqt6.dialogs.*
import std.collection.*
import qq_chat.core.*
import qq_chat.state.*
import qq_chat.ui.*

let onSendClick: VoidCallback = {
    => doSendMessage()
}

let onAddFriendClick: VoidCallback = {
    => showAddFriendDialog()
}

let onShowChangePwdClick: VoidCallback = {
    => showChangePwdDialog()
}

let onDeleteFriendClick: VoidCallback = {
    => doDeleteFriend()
}

let onModifyRemarkClick: VoidCallback = {
    => doModifyRemark()
}

let onClearChatClick: VoidCallback = {
    => doClearChatHistory()
}

let onRecallMsgClick: VoidCallback = {
    => doRecallLastMessage()
}

let onSendImageClick: VoidCallback = {
    => doSendImage()
}

let onSendFileClick: VoidCallback = {
    => doSendFile()
}

let onChangeNameClick: VoidCallback = {
    => doChangeDisplayName()
}

let onChangeAvatarClick: VoidCallback = {
    => doChangeAvatar()
}

let onEmojiClick: VoidCallback = {
    => showEmojiPanel()
}

let onLoadMoreClick: VoidCallback = {
    => loadMoreMessages()
}

let onPollMessages: VoidCallback = {
    => pollNewMessages()
}

let onFriendRowClicked: Int32Callback = {
    row: Int32 => selectFriend(row)
}

let onMinimizeClick: VoidCallback = {
    => if (let Some(fp) <- gFriendPanel) { fp.hide() }
}

let onClosePanelClick: VoidCallback = {
    => doLogout()
}

var gQqMenuPtr: Int64 = 0

let onQqMenuClick: VoidCallback = {
    => if (gQqMenuPtr != 0) { /* QMenu.popup disabled - causes crash */ }
}

public func buildMainWindow(): Unit {
    if (let Some(fp) <- gFriendPanel) {
        fp.show()
        return
    }

    let panel = QWidget()
    panel.setTitle("QQ")
    panel.setMaximumSize(FRIEND_PANEL_WIDTH, 9999)
    panel.resize(FRIEND_PANEL_WIDTH, CHAT_HEIGHT + 40)
    panel.setStyleSheet("QWidget { background: #FFFFFF; }")

    let mainLayout = QVBoxLayout()
    mainLayout.setMargin(0)
    mainLayout.setSpacing(0)

    // ---- 标题栏 (深蓝渐变) ----
    let titleBar = QWidget()
    titleBar.setStyleSheet(buildFriendPanelTitleBarStyleSheet())
    let titleLayout = QHBoxLayout()
    titleLayout.setMargin(6)
    titleLayout.setSpacing(4)
    let titleText = QLabel()
    if (let Some(u) <- gCurrentUser) {
        titleText.setText("${u.displayName}")
    } else {
        titleText.setText("QQ")
    }
    titleText.setStyleSheet("color: white; font-size: 12px; font-weight: bold;")
    titleLayout.addWidget(titleText.getPtr())
    titleLayout.addStretch()
    let minBtn = QPushButton()
    minBtn.setText("−")
    minBtn.setStyleSheet("QPushButton { color: white; background: transparent; border: none; font-size: 12px; padding: 0 4px; } QPushButton:hover { background: rgba(255,255,255,0.15); }")
    minBtn.setOnClick(onMinimizeClick)
    titleLayout.addWidget(minBtn.getPtr())
    let closeBtn = QPushButton()
    closeBtn.setText("×")
    closeBtn.setStyleSheet("QPushButton { color: white; background: transparent; border: none; font-size: 14px; padding: 0 4px; } QPushButton:hover { background: #C42B1C; }")
    closeBtn.setOnClick(onClosePanelClick)
    titleLayout.addWidget(closeBtn.getPtr())
    titleBar.setLayout(titleLayout.getPtr())
    mainLayout.addWidget(titleBar.getPtr())

    // ---- 个人信息区 ----
    let infoArea = QWidget()
    infoArea.setStyleSheet("QWidget { background: #E8EDF2; border-bottom: 1px solid #D0D7DE; }")
    let infoLayout = QHBoxLayout()
    infoLayout.setMargin(8)
    infoLayout.setSpacing(8)
    if (let Some(u) <- gCurrentUser) {
        let (r, g, b) = colorFromName(u.displayName)
        let bigAvatar = createSquareAvatarPixmap(r, g, b, firstCharOf(u.displayName), BIG_AVATAR_SIZE)
        let avatarLabel = QLabel()
        avatarLabel.setPixmap(bigAvatar.getPtr())
        infoLayout.addWidget(avatarLabel.getPtr())
        bigAvatar.delete()
        let nameInfo = QVBoxLayout()
        nameInfo.setSpacing(0)
        let nameLabel = QLabel()
        nameLabel.setText(u.displayName)
        nameLabel.setStyleSheet("color: #222; font-size: 13px; font-weight: bold;")
        nameInfo.addWidget(nameLabel.getPtr())
        let sigLabel = QLabel()
        sigLabel.setText("")
        sigLabel.setStyleSheet("color: #999; font-size: 11px;")
        nameInfo.addWidget(sigLabel.getPtr())
        infoLayout.addLayout(nameInfo.getPtr())
    }
    infoLayout.addStretch()
    infoArea.setLayout(infoLayout.getPtr())
    mainLayout.addWidget(infoArea.getPtr())

    // ---- 搜索栏 ----
    let searchArea = QWidget()
    searchArea.setStyleSheet("QWidget { background: #F0F2F5; }")
    let searchLayout = QHBoxLayout()
    searchLayout.setMargin(4)
    searchLayout.setSpacing(4)
    let searchEdit = QLineEdit()
    searchEdit.setPlaceholder("搜索好友")
    searchEdit.setStyleSheet("QLineEdit { border: 1px solid #D0D7DE; border-radius: 12px; font-size: 12px; padding: 3px 10px; background: white; } QLineEdit:focus { border: 1px solid #4A90D9; }")
    searchLayout.addWidget(searchEdit.getPtr())
    let findBtn = QPushButton()
    findBtn.setText("查找")
    findBtn.setStyleSheet("QPushButton { border: 1px solid #C0C8D0; background: white; border-radius: 3px; font-size: 11px; padding: 3px 10px; } QPushButton:hover { background: #F5F6F8; }")
    findBtn.setOnClick(onAddFriendClick)
    searchLayout.addWidget(findBtn.getPtr())
    searchArea.setLayout(searchLayout.getPtr())
    mainLayout.addWidget(searchArea.getPtr())

    // ---- 好友列表 ----
    let friendListWidget = QWidget()
    let friendListLayout = QVBoxLayout()
    friendListLayout.setMargin(0)
    friendListLayout.setSpacing(0)

    let friendList = QListWidget()
    friendList.setStyleSheet("QListWidget { border: none; background: white; } QListWidget::item { padding: 6px 8px; border-bottom: 1px solid #F0F2F5; } QListWidget::item:selected { background: #DDE8F6; } QListWidget::item:hover { background: #F5F8FC; }")
    gFriendList = friendList
    friendList.setOnItemClicked(onFriendRowClicked)
    friendListLayout.addWidget(friendList.getPtr())

    friendListWidget.setLayout(friendListLayout.getPtr())
    mainLayout.addWidget(friendListWidget.getPtr(), 1)

    // ---- 底部栏 ----
    let bottomBar = QWidget()
    bottomBar.setStyleSheet("QWidget { background: #F0F2F5; border-top: 1px solid #E0E4E8; }")
    let bottomLayout = QHBoxLayout()
    bottomLayout.setMargin(4)
    bottomLayout.setSpacing(4)

    let msgBoxBtn = QPushButton()
    msgBoxBtn.setText("消息")
    msgBoxBtn.setStyleSheet("QPushButton { border: 1px solid transparent; background: transparent; font-size: 11px; padding: 3px 8px; border-radius: 3px; } QPushButton:hover { background: #E8EDF2; }")
    bottomLayout.addWidget(msgBoxBtn.getPtr())

    bottomLayout.addStretch()

    let qqMenuBtn = QPushButton()
    qqMenuBtn.setText("菜单")
    qqMenuBtn.setStyleSheet("QPushButton { border: 1px solid transparent; background: transparent; font-size: 11px; padding: 3px 8px; border-radius: 3px; } QPushButton:hover { background: #E8EDF2; }")
    let qqMenu = QMenu("QQ菜单")
    let changeNameAction = qqMenu.addAction("修改昵称")
    changeNameAction.setOnTriggered(onChangeNameClick)
    let changeAvatarAction = qqMenu.addAction("修改头像")
    changeAvatarAction.setOnTriggered(onChangeAvatarClick)
    let changePwdAction = qqMenu.addAction("修改密码")
    changePwdAction.setOnTriggered(onShowChangePwdClick)
    qqMenu.addSeparator()
    let logoutAction = qqMenu.addAction("退出登录")
    logoutAction.setOnTriggered(onLogoutClick)
    gQqMenuPtr = qqMenu.getPtr()
    qqMenuBtn.setOnClick(onQqMenuClick)
    bottomLayout.addWidget(qqMenuBtn.getPtr())

    bottomBar.setLayout(bottomLayout.getPtr())
    mainLayout.addWidget(bottomBar.getPtr())

    panel.setLayout(mainLayout.getPtr())
    gFriendPanel = panel

    refreshFriendList()

    let pollTimer = QTimer()
    pollTimer.setInterval(2000)
    pollTimer.setOnTimeout(onPollMessages)
    gPollTimer = pollTimer
    pollTimer.start()

    panel.show()
}

public func refreshFriendList(): Unit {
    if (let Some(list) <- gFriendList) {
        list.clear()
        gFriendCache.clear()
        if (let Some(db) <- gDb) {
            if (let Some(u) <- gCurrentUser) {
                let friends = db.getFriends(u.id)
                initFriendGroups(friends)
                var row: Int32 = 0
                for (f in friends) {
                    let name = if (f.remark.isEmpty()) {
                        f.friendName
                    } else {
                        f.remark
                    }
                    let unreadCount = db.getUnreadCount(u.id, f.friendId)
                    gUnreadMap[f.friendId] = unreadCount
                    var displayText = "${name} 在线"
                    if (unreadCount > 0) {
                        displayText = "${name} 在线 (${unreadCount})"
                    }
                    list.addItem(displayText)
                    let avatarSize = QScreen.logicalToPhysical(FRIEND_AVATAR_SIZE)
                    let (r, g, b) = colorFromName(name)
                    let pm = createSquareAvatarPixmap(r, g, b, firstCharOf(name), avatarSize)
                    list.setItemIconPixmap(row, pm)
                    pm.delete()
                    gFriendCache.add(f)
                    row++
                }
            }
        }
    }
}

public func selectFriend(row: Int32): Unit {
    if (row >= 0 && Int64(row) < gFriendCache.size) {
        let f = gFriendCache[Int64(row)]
        let newFriendId = f.friendId
        if (let Some(db) <- gDb) {
            if (let Some(u) <- gCurrentUser) {
                db.markMessagesAsRead(u.id, newFriendId)
                gUnreadMap[newFriendId] = 0
                refreshFriendList()
                if (let Some(list) <- gFriendList) {
                    list.setCurrentRow(row)
                }
            }
        }
        if (let Some(cw) <- gChatWindow) {
            if (gCurrentFriendId == newFriendId) {
                cw.show()
                return
            }
            cw.delete()
            gChatWindow = None
        }
        let chatWin = buildChatWindow(newFriendId)
        // 聊天窗口显示在好友面板右侧
        if (let Some(fp) <- gFriendPanel) {
            chatWin.move(fp.x() + fp.width() + 4, fp.y())
            chatWin.resizeDp(CHAT_WIDTH, CHAT_HEIGHT)
        }
        chatWin.show()
    }
}

public func getFriendDisplayName(): String {
    for (f in gFriendCache) {
        if (f.friendId == gCurrentFriendId) {
            return if (f.remark.isEmpty()) {
                f.friendName
            } else {
                f.remark
            }
        }
    }
    return "好友"
}

public func refreshChatHistory(): Unit {
    if (let Some(edit) <- gChatHistory) {
        edit.clear()
        if (let Some(db) <- gDb) {
            if (let Some(u) <- gCurrentUser) {
                if (gCurrentFriendId > 0) {
                    let pageSize: Int64 = 50
                    let msgs = db.getMessagesPaged(u.id, gCurrentFriendId, gCurrentPage, pageSize)
                    var htmlContent = ""
                    for (m in msgs) {
                        let friendName = getFriendDisplayName()
                        if (m.isRecalled == 1) {
                            let senderName = if (m.senderId == u.id) { "我" } else { friendName }
                            htmlContent = htmlContent + buildRecalledHtml(senderName)
                        } else if (m.messageType == "image") {
                            let isSender = m.senderId == u.id
                            htmlContent = htmlContent + buildImageBubbleHtml(m, isSender)
                        } else if (m.messageType == "file") {
                            let isSender = m.senderId == u.id
                            htmlContent = htmlContent + buildFileBubbleHtml(m, isSender)
                        } else {
                            htmlContent = htmlContent + buildBubbleHtml(m, u.id, friendName)
                        }
                    }
                    edit.setHtml(htmlContent)
                    if (Int64(msgs.size) < pageSize) {
                        gHasMoreMessages = false
                    }
                }
            }
        }
    }
}

public func loadMoreMessages(): Unit {
    if (!gHasMoreMessages) { return }
    if (let Some(edit) <- gChatHistory) {
        if (let Some(db) <- gDb) {
            if (let Some(u) <- gCurrentUser) {
                if (gCurrentFriendId > 0) {
                    gCurrentPage++
                    let pageSize: Int64 = 50
                    let msgs = db.getMessagesPaged(u.id, gCurrentFriendId, gCurrentPage, pageSize)
                    if (msgs.size == 0) {
                        gHasMoreMessages = false
                        return
                    }
                    var prefixHtml = ""
                    for (m in msgs) {
                        let friendName = getFriendDisplayName()
                        if (m.isRecalled == 1) {
                            let senderName = if (m.senderId == u.id) { "我" } else { friendName }
                            prefixHtml = prefixHtml + buildRecalledHtml(senderName)
                        } else if (m.messageType == "image") {
                            let isSender = m.senderId == u.id
                            prefixHtml = prefixHtml + buildImageBubbleHtml(m, isSender)
                        } else if (m.messageType == "file") {
                            let isSender = m.senderId == u.id
                            prefixHtml = prefixHtml + buildFileBubbleHtml(m, isSender)
                        } else {
                            prefixHtml = prefixHtml + buildBubbleHtml(m, u.id, friendName)
                        }
                    }
                    let currentHtml = edit.toHtml()
                    edit.setHtml(prefixHtml + currentHtml)
                    if (Int64(msgs.size) < pageSize) {
                        gHasMoreMessages = false
                    }
                }
            }
        }
    }
}

public func doSendMessage(): Unit {
    if (gCurrentFriendId <= 0) {
        QMessageBox.warning(0, "提示", "请先选择聊天对象")
        return
    }
    if (let Some(input) <- gChatInput) {
        let text = input.text()
        if (text.isEmpty()) {
            return
        }
        if (let Some(db) <- gDb) {
            if (let Some(u) <- gCurrentUser) {
                let msgId = db.addMessage(u.id, gCurrentFriendId, text)
                if (msgId > 0) {
                    input.setText("")
                    refreshChatHistory()
                } else {
                    QMessageBox.warning(0, "错误", "消息发送失败，请重试。")
                }
            }
        }
    }
}

public func pollNewMessages(): Unit {
    if (let Some(db) <- gDb) {
        if (let Some(u) <- gCurrentUser) {
            var hasUnreadChange = false
            for (f in gFriendCache) {
                let newCount = db.getUnreadCount(u.id, f.friendId)
                let oldCount = gUnreadMap.get(f.friendId) ?? 0
                if (newCount != oldCount) {
                    gUnreadMap[f.friendId] = newCount
                    hasUnreadChange = true
                }
            }
            if (hasUnreadChange) {
                let selectedFriendId = gCurrentFriendId
                refreshFriendList()
                if (let Some(list) <- gFriendList) {
                    var row: Int32 = 0
                    for (f in gFriendCache) {
                        if (f.friendId == selectedFriendId) {
                            list.setCurrentRow(row)
                        }
                        row++
                    }
                }
            }
            if (gCurrentFriendId > 0) {
                let unreadForCurrent = db.getUnreadCount(u.id, gCurrentFriendId)
                if (unreadForCurrent > 0) {
                    db.markMessagesAsRead(u.id, gCurrentFriendId)
                    gUnreadMap[gCurrentFriendId] = 0
                    refreshChatHistory()
                }
            }
        }
    }
}