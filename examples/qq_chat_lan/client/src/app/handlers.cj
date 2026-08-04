// ============================================================
// QQ局域网聊天 - 客户端帧分发
// 处理服务端下发的所有帧类型，驱动界面状态流转。
// ============================================================
package qq_lan_client.app

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.dialogs.*
import std.collection.*
import qq_lan_client.core.*
import qq_lan_client.state.*

/// 处理一帧 JSON 行
public func handleFrame(line: String): Unit {
    match (parseFrame(line)) {
        case Some(obj) =>
            let frameType = jstr(obj, "type")
            if (frameType == "login_ok") {
                onLoginOk(obj)
            } else if (frameType == "chat") {
                onChatFrame(obj)
            } else if (frameType == "presence") {
                onPresence(obj)
            } else if (frameType == "friend_added") {
                onFriendAdded(obj)
            } else if (frameType == "ok") {
                onOkFrame(obj)
            } else if (frameType == "reg_ok") {
                onRegOk(obj)
            } else if (frameType == "error") {
                onErrorFrame(obj)
            }
            // pong 忽略
            obj.close()
        case None => ()
    }
}

// ============================================================
// login_ok：填充资料/好友/离线消息，进入主界面
// ============================================================
public func onLoginOk(obj: QJsonObject): Unit {
    let self = SelfInfo()
    self.id = jint(obj, "id")
    self.account = jint(obj, "account")
    self.nickname = jstr(obj, "nickname")
    gSelf = self
    gLoggedIn = true

    // 好友列表
    gFriends.clear()
    let fv = obj.value("friends")
    if (fv.isArray()) {
        let arr = QJsonArray(fv.toArray())
        var i: Int32 = 0
        while (i < arr.size()) {
            let itemV = arr.at(i)
            if (itemV.isObject()) {
                let item = QJsonObject(itemV.toObject())
                let f = FriendInfo()
                f.id = jint(item, "id")
                f.account = jint(item, "account")
                f.nickname = jstr(item, "nickname")
                f.online = jbool(item, "online")
                gFriends.add(f)
                item.close()
            }
            itemV.close()
            i++
        }
        arr.close()
    }
    fv.close()

    // 离线消息 -> 历史缓存 + 未读计数
    gHistory.clear()
    gUnread.clear()
    let mv = obj.value("messages")
    if (mv.isArray()) {
        let arr = QJsonArray(mv.toArray())
        var i: Int32 = 0
        while (i < arr.size()) {
            let itemV = arr.at(i)
            if (itemV.isObject()) {
                let item = QJsonObject(itemV.toObject())
                let m = ChatMsg()
                m.fromId = jint(item, "from")
                m.fromName = jstr(item, "fromName")
                m.text = jstr(item, "text")
                m.time = jstr(item, "time")
                m.outgoing = false
                appendHistory(m.fromId, m)
                gUnread[m.fromId] = (gUnread.get(m.fromId) ?? 0) + 1
                item.close()
            }
            itemV.close()
            i++
        }
        arr.close()
    }
    mv.close()

    // 界面切换：登录窗 -> 好友面板
    if (let Some(w) <- gLoginWindow) { w.hide() }
    if (gMainWindow.isNone()) {
        buildMainWindow()
    }
    if (let Some(l) <- gSelfLabel) {
        l.setText("${self.nickname}  (QQ号 ${self.account})")
    }
    refreshFriendList()
    if (let Some(w) <- gMainWindow) { w.show() }
}

/// 追加消息到历史缓存
public func appendHistory(friendId: Int64, msg: ChatMsg): Unit {
    match (gHistory.get(friendId)) {
        case Some(list) => list.add(msg)
        case None =>
            let list = ArrayList<ChatMsg>()
            list.add(msg)
            gHistory[friendId] = list
    }
}

// ============================================================
// chat：接收聊天消息
// ============================================================
public func onChatFrame(obj: QJsonObject): Unit {
    let m = ChatMsg()
    m.fromId = jint(obj, "from")
    m.fromName = jstr(obj, "fromName")
    m.text = jstr(obj, "text")
    m.time = jstr(obj, "time")
    m.outgoing = false
    appendHistory(m.fromId, m)

    if (isChatOpenFor(m.fromId)) {
        appendBubble(m)
    } else {
        gUnread[m.fromId] = (gUnread.get(m.fromId) ?? 0) + 1
    }
    refreshFriendList()
}

/// 聊天窗口是否正打开着指定好友的会话
public func isChatOpenFor(friendId: Int64): Bool {
    if (gCurrentChatId != friendId) { return false }
    match (gChatWindow) {
        case Some(w) => w.isVisible()
        case None => false
    }
}

// ============================================================
// presence：好友上下线
// ============================================================
public func onPresence(obj: QJsonObject): Unit {
    let userId = jint(obj, "userId")
    let online = jbool(obj, "online")
    for (f in gFriends) {
        if (f.id == userId) {
            f.online = online
        }
    }
    refreshFriendList()
}

// ============================================================
// friend_added / ok(add_friend)：新增好友
// ============================================================
public func onFriendAdded(obj: QJsonObject): Unit {
    let name = addFriendFromFrame(obj)
    refreshFriendList()
    if (!name.isEmpty()) {
        QMessageBox.information(0, "好友通知", "${name} 添加你为好友")
    }
}

public func onOkFrame(obj: QJsonObject): Unit {
    let op = jstr(obj, "op")
    if (op == "add_friend") {
        let name = addFriendFromFrame(obj)
        closeAddFriendDialog()
        refreshFriendList()
        if (!name.isEmpty()) {
            QMessageBox.information(0, "添加好友", "成功添加 ${name} 为好友")
        }
    }
}

/// 从帧的 friend 字段解析并加入好友列表，返回昵称（去重）
public func addFriendFromFrame(obj: QJsonObject): String {
    var name = ""
    let fv = obj.value("friend")
    if (fv.isObject()) {
        let item = QJsonObject(fv.toObject())
        let fid = jint(item, "id")
        if (!hasFriend(fid)) {
            let f = FriendInfo()
            f.id = fid
            f.account = jint(item, "account")
            f.nickname = jstr(item, "nickname")
            f.online = jbool(item, "online")
            gFriends.add(f)
            name = f.nickname
        }
        item.close()
    }
    fv.close()
    name
}

public func hasFriend(friendId: Int64): Bool {
    for (f in gFriends) {
        if (f.id == friendId) { return true }
    }
    false
}

// ============================================================
// reg_ok / error
// ============================================================
public func onRegOk(obj: QJsonObject): Unit {
    let account = jint(obj, "account")
    closeRegisterDialog()
    QMessageBox.information(0, "注册成功", "你的 QQ 号是 ${account}\n请牢记账号，用它登录。")
}

public func onErrorFrame(obj: QJsonObject): Unit {
    let op = jstr(obj, "op")
    let message = jstr(obj, "message")
    if (op == "login") {
        setLoginStatus(message)
    } else if (op == "register") {
        setRegisterStatus(message)
    } else if (op == "add_friend") {
        setAddFriendStatus(message)
    } else {
        QMessageBox.warning(0, "提示", message)
    }
}

// ============================================================
// 断开连接：回到登录页
// ============================================================
public func handleLoggedOut(reason: String): Unit {
    if (let Some(w) <- gChatWindow) { w.hide() }
    if (let Some(w) <- gMainWindow) { w.hide() }
    gCurrentChatId = 0
    if (let Some(w) <- gLoginWindow) {
        w.show()
    }
    setLoginStatus(reason)
}
