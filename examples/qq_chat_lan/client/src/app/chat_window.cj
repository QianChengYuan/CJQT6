// ============================================================
// QQ局域网聊天 - 聊天窗口
// 单窗口会话：标题随好友切换，历史区(气泡HTML) + 输入区。
// ============================================================
package qq_lan_client.app

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import std.collection.*
import qq_lan_client.core.*
import qq_lan_client.state.*

/// 发送按钮回调
let onSendClick: VoidCallback = { => doSend() }

/// 输入框回车发送
let onInputReturn: VoidCallback = { => doSend() }

/// 打开与指定好友的会话（复用同一个聊天窗口）
public func openChatWithFriend(friendId: Int64): Unit {
    // 找到好友信息
    var found = false
    var friendName = ""
    for (f in gFriends) {
        if (f.id == friendId) {
            found = true
            friendName = f.nickname
        }
    }
    if (!found) { return }

    gCurrentChatId = friendId
    // 该好友未读清零
    gUnread[friendId] = 0
    refreshFriendList()

    if (gChatWindow.isNone()) {
        buildChatWindow()
    }
    if (let Some(t) <- gChatTitle) {
        t.setText("与 ${friendName} 聊天中")
    }
    renderHistory(friendId)
    if (let Some(w) <- gChatWindow) {
        w.show()
    }
    if (let Some(e) <- gChatInput) {
        e.setText("")
    }
}

/// 构建聊天窗口骨架（只建一次）
public func buildChatWindow(): Unit {
    let win = QWidget()
    win.setTitle("QQ局域网聊天 - 会话")
    win.resize(CHAT_WIDTH, CHAT_HEIGHT)
    win.setStyleSheet("background: #F5F7FA;")

    let vbox = QVBoxLayout()
    vbox.setMargin(0)
    vbox.setSpacing(0)

    // 标题栏
    let titleBar = QWidget()
    titleBar.setStyleSheet(panelTitleStyleSheet())
    titleBar.setMinimumSize(CHAT_WIDTH, 44)
    titleBar.setMaximumSize(CHAT_WIDTH + 800, 44)
    let titleLayout = QHBoxLayout()
    titleLayout.setMargin(12)
    let title = QLabel()
    title.setText("会话")
    title.setStyleSheet("color: white; font-size: 14px; font-weight: bold; background: transparent; border: none;")
    gChatTitle = title
    titleLayout.addWidget(title.getPtr(), 1)
    titleBar.setLayout(titleLayout.getPtr())
    vbox.addWidget(titleBar.getPtr())

    // 历史记录区
    let history = QTextEdit()
    history.setReadOnly(true)
    history.setStyleSheet("background: #F5F7FA; border: none;")
    gChatHistory = history
    vbox.addWidget(history.getPtr(), 1)

    // 输入区
    let inputBar = QWidget()
    inputBar.setStyleSheet("background: white; border-top: 1px solid #E0E4EA;")
    let inputLayout = QHBoxLayout()
    inputLayout.setMargin(10)
    inputLayout.setSpacing(8)
    let input = QLineEdit()
    input.setPlaceholder("输入消息，回车发送...")
    input.setStyleSheet("background: #F5F7FA; border: 1px solid #E0E4EA; border-radius: 3px; padding: 8px;")
    input.setOnReturnPressed(onInputReturn)
    gChatInput = input
    inputLayout.addWidget(input.getPtr(), 1)

    let sendBtn = QPushButton()
    sendBtn.setText("发送")
    sendBtn.setStyleSheet("background: #12B7F5; color: white; border: none; border-radius: 3px; padding: 8px 24px; font-weight: bold;")
    sendBtn.setOnClick(onSendClick)
    inputLayout.addWidget(sendBtn.getPtr())
    inputBar.setLayout(inputLayout.getPtr())
    vbox.addWidget(inputBar.getPtr())

    win.setLayout(vbox.getPtr())
    gChatWindow = win
}

/// 重新渲染某好友的完整聊天记录
public func renderHistory(friendId: Int64): Unit {
    match (gChatHistory) {
        case Some(view) =>
            var html = ""
            match (gHistory.get(friendId)) {
                case Some(list) =>
                    for (m in list) {
                        let name = if (m.outgoing) { "我" } else { m.fromName }
                        html = html + buildBubbleHtml(m.text, m.time, m.outgoing, name)
                    }
                case None => ()
            }
            if (html.isEmpty()) {
                html = "<div style='text-align:center;color:#999;font-size:12px;margin-top:20px;'>暂无消息，发送第一条吧</div>"
            }
            view.setHtml(html)
        case None => ()
    }
}

/// 追加单条气泡（新消息到达 / 自己发送时）
public func appendBubble(m: ChatMsg): Unit {
    match (gChatHistory) {
        case Some(view) =>
            view.append(buildBubbleHtml(m.text, m.time, m.outgoing, m.fromName))
        case None => ()
    }
}

/// 发送当前输入的消息
public func doSend(): Unit {
    if (gCurrentChatId == 0) { return }
    var text = ""
    if (let Some(e) <- gChatInput) {
        text = e.text()
    }
    if (text.isEmpty()) { return }

    // 发送帧（服务端落库并转发给对方）
    sendRaw("{\"type\":\"chat\",\"to\":${gCurrentChatId},\"text\":\"${escapeJson(text)}\"}")

    // 本地立即回显
    let m = ChatMsg()
    if (let Some(s) <- gSelf) {
        m.fromId = s.id
        m.fromName = s.nickname
    }
    m.text = text
    m.time = nowString()
    m.outgoing = true
    appendHistory(gCurrentChatId, m)
    appendBubble(m)

    if (let Some(e) <- gChatInput) {
        e.setText("")
    }
}
