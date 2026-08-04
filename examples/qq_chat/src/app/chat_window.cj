package qq_chat.app

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.dialogs.*
import qq_chat.core.*
import qq_chat.state.*
import qq_chat.ui.*

let onSendFromChatWindowClick: VoidCallback = {
    => doSendFromChatWindow()
}

let onEmojiFromChatClick: VoidCallback = {
    => showEmojiPanel()
}

let onSendImageFromChatClick: VoidCallback = {
    => doSendImage()
}

let onSendFileFromChatClick: VoidCallback = {
    => doSendFile()
}

let onRecallFromChatClick: VoidCallback = {
    => doRecallLastMessage()
}

let onClearFromChatClick: VoidCallback = {
    => doClearChatHistory()
}

let onLoadMoreFromChatClick: VoidCallback = {
    => loadMoreMessages()
}

public func buildChatWindow(friendId: Int64): QWidget {
    let window = QWidget()
    let friendName = getFriendDisplayName()
    if (let Some(u) <- gCurrentUser) {
        window.setTitle("${friendName}(${friendId}) - 聊天中")
    } else {
        window.setTitle("${friendName} - 聊天中")
    }
    window.resizeDp(CHAT_WIDTH, CHAT_HEIGHT)
    window.setMinimumSizeDp(CHAT_MIN_WIDTH, CHAT_MIN_HEIGHT)

    let mainLayout = QVBoxLayout()
    mainLayout.setMargin(6)
    mainLayout.setSpacing(4)

    // ---- 顶部小工具栏（仅撤回/清空操作按钮） ----
    let toolbar = QWidget()
    toolbar.setStyleSheet("background-color: #E8EDF2; border-bottom: 1px solid #D0D7DE;")
    let toolbarLayout = QHBoxLayout()
    toolbarLayout.setMargin(2)
    toolbarLayout.setSpacing(2)

    let loadMoreBtn = QPushButton()
    loadMoreBtn.setText("↑ 更多")
    loadMoreBtn.setStyleSheet("QPushButton { color: #999; font-size: 11px; border: none; background: transparent; padding: 2px 6px; } QPushButton:hover { color: #666; }")
    loadMoreBtn.setOnClick(onLoadMoreFromChatClick)
    toolbarLayout.addWidget(loadMoreBtn.getPtr())

    toolbarLayout.addStretch()

    let recallBtn = QPushButton()
    recallBtn.setText("撤回")
    recallBtn.setStyleSheet("QPushButton { border: 1px solid #C0C8D0; background: #F5F6F8; font-size: 12px; padding: 2px 10px; border-radius: 3px; } QPushButton:hover { background: #E8EDF2; }")
    recallBtn.setOnClick(onRecallFromChatClick)
    toolbarLayout.addWidget(recallBtn.getPtr())

    let clearBtn = QPushButton()
    clearBtn.setText("清空")
    clearBtn.setStyleSheet("QPushButton { border: 1px solid #C0C8D0; background: #F5F6F8; font-size: 12px; padding: 2px 10px; border-radius: 3px; } QPushButton:hover { background: #E8EDF2; }")
    clearBtn.setOnClick(onClearFromChatClick)
    toolbarLayout.addWidget(clearBtn.getPtr())

    toolbar.setLayout(toolbarLayout.getPtr())
    mainLayout.addWidget(toolbar.getPtr())

    // ---- 聊天记录区 ----
    let chatHistory = QTextEdit()
    chatHistory.setReadOnly(true)
    chatHistory.setStyleSheet("QTextEdit { border: 1px solid #D0D7DE; background: #FAFBFC; }")
    gChatHistory = chatHistory
    mainLayout.addWidget(chatHistory.getPtr(), 1)

    // ---- 文件操作行（聊天框与输入框之间） ----
    let fileActionBar = QWidget()
    fileActionBar.setStyleSheet("background-color: #F5F6F8; border-top: 1px solid #E0E4E8;")
    let fileActionLayout = QHBoxLayout()
    fileActionLayout.setMargin(2)
    fileActionLayout.setSpacing(2)

    let emojiBtn = QPushButton()
    emojiBtn.setText("😊")
    emojiBtn.setStyleSheet("QPushButton { border: 1px solid transparent; background: transparent; font-size: 16px; padding: 3px 8px; } QPushButton:hover { border: 1px solid #C0C8D0; background: #FFFFFF; border-radius: 3px; }")
    emojiBtn.setOnClick(onEmojiFromChatClick)
    fileActionLayout.addWidget(emojiBtn.getPtr())

    let imgBtn = QPushButton()
    imgBtn.setText("🖼")
    imgBtn.setStyleSheet("QPushButton { border: 1px solid transparent; background: transparent; font-size: 16px; padding: 3px 8px; } QPushButton:hover { border: 1px solid #C0C8D0; background: #FFFFFF; border-radius: 3px; }")
    imgBtn.setOnClick(onSendImageFromChatClick)
    fileActionLayout.addWidget(imgBtn.getPtr())

    let fileBtn = QPushButton()
    fileBtn.setText("📁")
    fileBtn.setStyleSheet("QPushButton { border: 1px solid transparent; background: transparent; font-size: 16px; padding: 3px 8px; } QPushButton:hover { border: 1px solid #C0C8D0; background: #FFFFFF; border-radius: 3px; }")
    fileBtn.setOnClick(onSendFileFromChatClick)
    fileActionLayout.addWidget(fileBtn.getPtr())

    fileActionLayout.addStretch()
    fileActionBar.setLayout(fileActionLayout.getPtr())
    mainLayout.addWidget(fileActionBar.getPtr())

    // ---- 输入区 ----
    let inputArea = QVBoxLayout()
    inputArea.setSpacing(4)

    let chatInputEdit = QTextEdit()
    chatInputEdit.setMaximumSize(9999, INPUT_HEIGHT)
    chatInputEdit.setStyleSheet("QTextEdit { border: 1px solid #D0D7DE; background: #FFFFFF; font-size: 13px; padding: 4px; } QTextEdit:focus { border: 1px solid #4A90D9; }")
    gChatInputEdit = chatInputEdit
    inputArea.addWidget(chatInputEdit.getPtr())

    let sendRow = QHBoxLayout()
    sendRow.setSpacing(8)
    sendRow.addStretch()
    let sendBtn = QPushButton()
    sendBtn.setText("发送")
    sendBtn.setStyleSheet("QPushButton { background-color: #4A90D9; color: white; font-size: 13px; font-weight: bold; padding: 8px 32px; border: none; border-radius: 3px; } QPushButton:hover { background-color: #3A7BC8; } QPushButton:pressed { background-color: #2D6AAE; }")
    sendBtn.setOnClick(onSendFromChatWindowClick)
    sendRow.addWidget(sendBtn.getPtr())
    inputArea.addLayout(sendRow.getPtr())

    mainLayout.addLayout(inputArea.getPtr())
    window.setLayout(mainLayout.getPtr())

    gChatWindow = window
    gCurrentFriendId = friendId

    gCurrentPage = 1
    gHasMoreMessages = true
    refreshChatHistory()

    window
}

public func doSendFromChatWindow(): Unit {
    if (gCurrentFriendId <= 0) {
        return
    }
    if (let Some(edit) <- gChatInputEdit) {
        let text = edit.toPlainText()
        if (text.isEmpty()) {
            return
        }
        if (let Some(db) <- gDb) {
            if (let Some(u) <- gCurrentUser) {
                let msgId = db.addMessage(u.id, gCurrentFriendId, text)
                if (msgId > 0) {
                    edit.clear()
                    refreshChatHistory()
                } else {
                    QMessageBox.warning(0, "错误", "消息发送失败，请重试。")
                }
            }
        }
    }
}