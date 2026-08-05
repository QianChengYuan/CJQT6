// ============================================================
// QQ局域网聊天 - 客户端帧分发
// 处理服务端下发的所有帧类型，驱动界面状态流转。
// ============================================================
package qq_lan_client.app

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.dialogs.*
import std.collection.*
import std.fs.*
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
            } else if (frameType == "chat_ack") {
                onChatAck(obj)
            } else if (frameType == "history") {
                onHistory(obj)
            } else if (frameType == "recall") {
                onRecall(obj)
            } else if (frameType == "file_begin") {
                onFileBegin(obj)
            } else if (frameType == "file_chunk") {
                onFileChunk(obj)
            } else if (frameType == "file_end") {
                onFileEnd(obj)
            } else if (frameType == "nick_changed") {
                onNickChanged(obj)
            } else if (frameType == "friend_deleted") {
                onFriendDeleted(obj)
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
                f.remark = jstr(item, "remark")
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
    m.id = jint(obj, "id")
    m.fromId = jint(obj, "from")
    m.fromName = jstr(obj, "fromName")
    m.text = jstr(obj, "text")
    m.time = jstr(obj, "time")
    m.kind = jstr(obj, "kind")
    if (m.kind.isEmpty()) { m.kind = "text" }
    m.outgoing = false
    appendHistory(m.fromId, m)

    if (isChatOpenFor(m.fromId)) {
        appendBubble(m)
    } else {
        gUnread[m.fromId] = (gUnread.get(m.fromId) ?? 0) + 1
    }
    refreshFriendList()
}

/// chat_ack：记录本会话最后一条已确认消息 ID（供撤回）
public func onChatAck(obj: QJsonObject): Unit {
    let id = jint(obj, "id")
    let to = jint(obj, "to")
    gLastSentId[to] = id
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
    } else if (op == "recall") {
        // 自己撤回成功：本地标记并重渲染
        let msgId = jint(obj, "msgId")
        markRecalled(gCurrentChatId, msgId)
    } else if (op == "set_remark") {
        let fid = jint(obj, "friend")
        let remark = jstr(obj, "remark")
        for (f in gFriends) {
            if (f.id == fid) { f.remark = remark }
        }
        refreshFriendList()
        closeRemarkDialog()
    } else if (op == "del_friend") {
        let fid = jint(obj, "friend")
        removeFriend(fid)
        closeRemarkDialog()
        QMessageBox.information(0, "删除好友", "已删除好友")
    } else if (op == "change_nick") {
        let nick = jstr(obj, "nickname")
        if (let Some(s) <- gSelf) {
            s.nickname = nick
            if (let Some(l) <- gSelfLabel) {
                l.setText("${nick}  (QQ号 ${s.account})")
            }
        }
        closeProfileDialogs()
    } else if (op == "change_pwd") {
        closeProfileDialogs()
        QMessageBox.information(0, "修改密码", "密码已修改，下次登录请使用新密码")
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

// ============================================================
// v2：历史记录同步
// ============================================================
public func onHistory(obj: QJsonObject): Unit {
    let friendId = jint(obj, "friend")
    var selfId: Int64 = 0
    if (let Some(s) <- gSelf) { selfId = s.id }
    let list = ArrayList<ChatMsg>()
    let mv = obj.value("messages")
    if (mv.isArray()) {
        let arr = QJsonArray(mv.toArray())
        var i: Int32 = 0
        while (i < arr.size()) {
            let itemV = arr.at(i)
            if (itemV.isObject()) {
                let item = QJsonObject(itemV.toObject())
                let m = ChatMsg()
                m.id = jint(item, "id")
                m.fromId = jint(item, "from")
                m.fromName = jstr(item, "fromName")
                m.text = jstr(item, "text")
                m.time = jstr(item, "time")
                m.kind = jstr(item, "kind")
                if (m.kind.isEmpty()) { m.kind = "text" }
                m.recalled = jbool(item, "recalled")
                m.outgoing = (m.fromId == selfId)
                list.add(m)
                item.close()
            }
            itemV.close()
            i++
        }
        arr.close()
    }
    mv.close()
    gHistory[friendId] = list
    if (isChatOpenFor(friendId)) {
        renderHistory(friendId)
    }
}

// ============================================================
// v2：消息撤回
// ============================================================
public func onRecall(obj: QJsonObject): Unit {
    let from = jint(obj, "from")
    let msgId = jint(obj, "msgId")
    markRecalled(from, msgId)
}

/// 在历史缓存中标记某消息已撤回并重渲染
public func markRecalled(friendId: Int64, msgId: Int64): Unit {
    match (gHistory.get(friendId)) {
        case Some(list) =>
            for (m in list) {
                if (m.id == msgId) { m.recalled = true }
            }
        case None => ()
    }
    if (isChatOpenFor(friendId)) {
        renderHistory(friendId)
    }
}

// ============================================================
// v2：文件接收（base64 分块 -> 落盘）
// ============================================================
public func onFileBegin(obj: QJsonObject): Unit {
    let tid = jstr(obj, "tid")
    let size = jint(obj, "size")
    if (size <= 0 || size > 50 * 1024 * 1024) { return }
    let t = RecvTransfer()
    t.buffer = Array<Byte>(size, repeat: 0)
    t.offset = 0
    t.name = jstr(obj, "name")
    t.kind = jstr(obj, "kind")
    t.fromId = jint(obj, "from")
    t.fromName = jstr(obj, "fromName")
    gTransfers[tid] = t
}

public func onFileChunk(obj: QJsonObject): Unit {
    let tid = jstr(obj, "tid")
    let data = jstr(obj, "data")
    match (gTransfers.get(tid)) {
        case Some(t) =>
            let dec = base64Decode(data)
            var i: Int64 = 0
            while (i < dec.size && t.offset < t.buffer.size) {
                t.buffer[t.offset] = dec[i]
                t.offset++
                i++
            }
        case None => ()
    }
}

public func onFileEnd(obj: QJsonObject): Unit {
    let tid = jstr(obj, "tid")
    match (gTransfers.get(tid)) {
        case Some(t) =>
            gTransfers.remove(tid)
            // 落盘
            try { Directory.create(Path(gRecvDir), recursive: true) } catch (_: Exception) { () }
            let fullPath = "${gRecvDir}/${t.fromId}_${t.name}"
            var saved = false
            try {
                let f = File(Path(fullPath), Write)
                f.write(t.buffer)
                f.close()
                saved = true
            } catch (_: Exception) { () }

            let m = ChatMsg()
            m.fromId = t.fromId
            m.fromName = t.fromName
            m.kind = t.kind
            m.fileName = t.name
            m.fileSize = t.buffer.size
            m.localPath = if (saved) { fullPath } else { "" }
            m.time = nowString()
            m.outgoing = false
            appendHistory(t.fromId, m)
            if (isChatOpenFor(t.fromId)) {
                appendBubble(m)
            } else {
                gUnread[t.fromId] = (gUnread.get(t.fromId) ?? 0) + 1
            }
            refreshFriendList()
        case None => ()
    }
}

// ============================================================
// v2：昵称变更 / 好友删除
// ============================================================
public func onNickChanged(obj: QJsonObject): Unit {
    let userId = jint(obj, "userId")
    let nickname = jstr(obj, "nickname")
    for (f in gFriends) {
        if (f.id == userId) { f.nickname = nickname }
    }
    refreshFriendList()
    if (isChatOpenFor(userId)) {
        if (let Some(t) <- gChatTitle) {
            t.setText("与 ${displayNameOf(userId)} 聊天中")
        }
    }
}

public func onFriendDeleted(obj: QJsonObject): Unit {
    let userId = jint(obj, "userId")
    removeFriend(userId)
    QMessageBox.information(0, "好友通知", "对方已将你从好友中删除")
}

/// 从好友列表移除并清理聊天窗口
public func removeFriend(fid: Int64): Unit {
    var idx: Int64 = -1
    var i: Int64 = 0
    for (f in gFriends) {
        if (f.id == fid) { idx = i }
        i++
    }
    if (idx >= 0) {
        let newList = ArrayList<FriendInfo>()
        var j: Int64 = 0
        for (f in gFriends) {
            if (j != idx) { newList.add(f) }
            j++
        }
        gFriends = newList
    }
    if (gCurrentChatId == fid) {
        if (let Some(w) <- gChatWindow) { w.hide() }
        gCurrentChatId = 0
    }
    refreshFriendList()
}
