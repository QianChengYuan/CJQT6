// ============================================================
// QQ局域网聊天 - 服务端网络层
// 职责：连接会话管理、JSON-line 协议解析与分发、消息路由、
//       在线状态广播、离线消息暂存。
// 协议（UTF-8 JSON，每行一帧，\n 分隔）：
//   客户端 -> 服务端：register / login / add_friend / chat / ping
//   服务端 -> 客户端：reg_ok / login_ok / chat / presence /
//                     friend_added / ok / pong / error
// ============================================================
package qq_lan_server

import cjqt6.core.*
import cjqt6.network.*
import cjqt6.widgets.*
import std.collection.*

// ============================================================
// 全局状态
// ============================================================

/// 监听端口
public let SERVER_PORT: UInt16 = 9600

/// TCP 服务器实例
public var gServer: ?QTcpServer = None

/// 数据库
public var gDb: ?ServerDb = None

/// 会话表：socket 指针 -> Session
public var gSessions: HashMap<Int64, Session> = HashMap<Int64, Session>()

/// 在线用户表：userId -> socket 指针
public var gUserSession: HashMap<Int64, Int64> = HashMap<Int64, Int64>()

/// 待清理的会话指针队列（断开回调中不直接销毁对象，由定时器统一清理）
public var gClosingQueue: ArrayList<Int64> = ArrayList<Int64>()

/// 服务端窗口控件
public var gLogView: ?QTextEdit = None
public var gStatus: ?QLabel = None

// ============================================================
// 会话
// ============================================================
public class Session {
    public var socket: QTcpSocket
    /// 接收缓冲（按字节暂存，遇到 \n 切成完整 JSON 帧）
    public var buffer: Array<Byte> = []
    /// 登录前为 0
    public var userId: Int64 = 0
    public var account: Int64 = 0
    public var nickname: String = ""
    public var peer: String = ""
    /// 已标记断开，等待定时器清理
    public var closing: Bool = false
    /// 闭包注册表 id（清理时注销）
    public var readyReadId: Int64 = 0
    public var disconnectedId: Int64 = 0

    public init(s: QTcpSocket) {
        this.socket = s
    }
}

// ============================================================
// 日志与状态栏
// ============================================================
public func serverLog(msg: String): Unit {
    if (let Some(v) <- gLogView) {
        v.append("[${nowString()[11..19]}] ${msg}")
    }
    println("[server] ${msg}")
}

/// 刷新状态栏在线人数
public func updateStatus(): Unit {
    var online = 0
    for ((_, sess) in gSessions) {
        if (sess.userId != 0) { online++ }
    }
    if (let Some(l) <- gStatus) {
        l.setText("监听端口: ${SERVER_PORT}        在线用户: ${online}")
    }
}

// ============================================================
// JSON 编解码辅助
// ============================================================

/// JSON 字符串转义
public func escapeJson(s: String): String {
    var r = s
    r = r.replace("\\", "\\\\")
    r = r.replace("\"", "\\\"")
    r = r.replace("\n", "\\n")
    r = r.replace("\r", "\\r")
    r = r.replace("\t", "\\t")
    r
}

/// 从对象取字符串字段（取完即释放 QJsonValue）
public func jstr(obj: QJsonObject, key: String): String {
    let v = obj.value(key)
    let s = if (v.isString()) { v.toString() } else { "" }
    v.close()
    s
}

/// 从对象取整数字段
public func jint(obj: QJsonObject, key: String): Int64 {
    let v = obj.value(key)
    let n = v.toInt(0)
    v.close()
    n
}

/// 发送一帧 JSON（自动追加换行符）
public func sendJson(sess: Session, json: String): Unit {
    if (sess.closing) { return }
    let n = sess.socket.writeString(json + "\n")
    if (n < 0) {
        serverLog("发送失败: ${sess.peer}")
    }
    let _ = sess.socket.flush()
}

public func sendError(sess: Session, op: String, message: String): Unit {
    sendJson(sess, "{\"type\":\"error\",\"op\":\"${op}\",\"message\":\"${escapeJson(message)}\"}")
}

public func isUserOnline(userId: Int64): Bool {
    match (gUserSession.get(userId)) {
        case Some(_) => true
        case None => false
    }
}

/// 构建某用户的好友 JSON 项（含在线状态）
public func friendItemJson(f: FriendRec): String {
    "{\"id\":${f.id},\"account\":${f.account},\"nickname\":\"${escapeJson(f.nickname)}\",\"online\":${isUserOnline(f.id)}}"
}

/// 构建用户信息 JSON 项（结构同好友项）
public func userItemJson(u: UserRec): String {
    "{\"id\":${u.id},\"account\":${u.account},\"nickname\":\"${escapeJson(u.nickname)}\",\"online\":${isUserOnline(u.id)}}"
}

/// 向所有已登录会话广播在线状态变化（跳过当事人）
public func broadcastPresence(userId: Int64, online: Bool): Unit {
    let frame = "{\"type\":\"presence\",\"userId\":${userId},\"online\":${online}}"
    for ((_, sess) in gSessions) {
        if (sess.userId != 0 && sess.userId != userId) {
            sendJson(sess, frame)
        }
    }
}

// ============================================================
// 连接接入
// ============================================================

/// 接受所有待处理连接，为每个连接注册闭包回调
public func acceptNewConnections(): Unit {
    if (let Some(srv) <- gServer) {
        while (srv.hasPendingConnections()) {
            match (srv.nextPendingConnection()) {
                case Some(sock) =>
                    let sess = Session(sock)
                    sess.peer = "${sock.peerAddress()}:${sock.peerPort()}"
                    let ptr = sock.getPtr()
                    gSessions[ptr] = sess
                    // 闭包捕获 ptr，回调内即可定位来源会话
                    sess.readyReadId = sock.setOnReadyReadCapture({ => onSessionData(ptr) })
                    sess.disconnectedId = sock.setOnDisconnectedCapture({ => onSessionClosed(ptr) })
                    serverLog("新连接: ${sess.peer}")
                case None => ()
            }
        }
        updateStatus()
    }
}

/// 套接字数据到达：追加缓冲并逐帧处理
public func onSessionData(ptr: Int64): Unit {
    match (gSessions.get(ptr)) {
        case Some(sess) =>
            if (sess.closing) { return }
            let chunk = sess.socket.readAll()
            if (chunk.size > 0) {
                sess.buffer = sess.buffer.concat(chunk)
            }
            // 防止异常数据撑爆内存：单帧上限 1MB
            if (sess.buffer.size > 1024 * 1024) {
                serverLog("帧过大，断开连接: ${sess.peer}")
                sess.closing = true
                gClosingQueue.add(ptr)
                return
            }
            // 按 \n 切帧
            var start: Int64 = 0
            var i: Int64 = 0
            while (i < sess.buffer.size) {
                if (sess.buffer[i] == 10u8) {
                    let lineBytes = sess.buffer[start..i]
                    let line = String.fromUtf8(lineBytes)
                    start = i + 1
                    if (!line.isEmpty()) {
                        handleFrame(sess, line)
                    }
                }
                i++
            }
            if (start > 0) {
                if (start < sess.buffer.size) {
                    sess.buffer = sess.buffer[start..sess.buffer.size]
                } else {
                    sess.buffer = []
                }
            }
        case None => ()
    }
}

/// 连接断开：标记后交给清理定时器处理（不在信号回调内销毁对象）
public func onSessionClosed(ptr: Int64): Unit {
    match (gSessions.get(ptr)) {
        case Some(sess) =>
            if (!sess.closing) {
                sess.closing = true
                gClosingQueue.add(ptr)
            }
        case None => ()
    }
}

/// 定时器回调：清理已断开的会话
public func cleanupTick(): Unit {
    if (gClosingQueue.size == 0) { return }
    let queue = gClosingQueue
    gClosingQueue = ArrayList<Int64>()
    for (ptr in queue) {
        finalizeSession(ptr)
    }
    updateStatus()
}

/// 真正释放会话：注销闭包、断开信号、关闭套接字、广播离线
public func finalizeSession(ptr: Int64): Unit {
    match (gSessions.get(ptr)) {
        case Some(sess) =>
            gSessions.remove(ptr)
            if (sess.userId != 0) {
                gUserSession.remove(sess.userId)
                serverLog("用户离线: ${sess.nickname}(${sess.account})")
                broadcastPresence(sess.userId, false)
            } else {
                serverLog("连接关闭: ${sess.peer}")
            }
            if (sess.readyReadId != 0) { unregisterVoidCallback(sess.readyReadId) }
            if (sess.disconnectedId != 0) { unregisterVoidCallback(sess.disconnectedId) }
            sess.socket.disconnectCallbacks()
            sess.socket.close()
        case None => ()
    }
}

// ============================================================
// 协议帧处理
// ============================================================
public func handleFrame(sess: Session, line: String): Unit {
    let doc = QJsonDocument(line)
    if (doc.getPtr() == 0) {
        serverLog("JSON 解析失败: ${sess.peer}")
        return
    }
    if (!doc.isObject()) {
        doc.close()
        return
    }
    let obj = doc.object()
    let frameType = jstr(obj, "type")
    var account: Int64 = 0
    var password = ""
    var nickname = ""
    var to: Int64 = 0
    var text = ""
    if (frameType == "register") {
        nickname = jstr(obj, "nickname")
        password = jstr(obj, "password")
    } else if (frameType == "login") {
        account = jint(obj, "account")
        password = jstr(obj, "password")
    } else if (frameType == "add_friend") {
        account = jint(obj, "account")
    } else if (frameType == "chat") {
        to = jint(obj, "to")
        text = jstr(obj, "text")
    }
    obj.close()
    doc.close()

    if (frameType == "register") {
        doRegister(sess, nickname, password)
    } else if (frameType == "login") {
        doLogin(sess, account, password)
    } else if (frameType == "add_friend") {
        doAddFriend(sess, account)
    } else if (frameType == "chat") {
        doChat(sess, to, text)
    } else if (frameType == "ping") {
        sendJson(sess, "{\"type\":\"pong\"}")
    } else {
        sendError(sess, frameType, "未知协议类型")
    }
}

// ============================================================
// 业务处理
// ============================================================

/// 注册：分配 QQ 号
public func doRegister(sess: Session, nickname: String, password: String): Unit {
    if (nickname.isEmpty() || nickname.size > 60) {
        sendError(sess, "register", "昵称需在 1-20 个字符内")
        return
    }
    if (password.size < 4 || password.size > 96) {
        sendError(sess, "register", "密码长度需在 4-32 个字符内")
        return
    }
    if (let Some(db) <- gDb) {
        let account = db.registerUser(nickname, password)
        if (account == 0) {
            sendError(sess, "register", "注册失败，请重试")
            return
        }
        serverLog("新用户注册: ${nickname} -> 账号 ${account}")
        sendJson(sess, "{\"type\":\"reg_ok\",\"account\":${account}}")
    }
}

/// 登录：校验账号密码，下发好友列表与离线消息，广播上线
public func doLogin(sess: Session, account: Int64, password: String): Unit {
    if (sess.userId != 0) {
        sendError(sess, "login", "请勿重复登录")
        return
    }
    if (let Some(db) <- gDb) {
        match (db.findByAccount(account)) {
            case Some(u) =>
                if (!db.checkPassword(u.id, password)) {
                    sendError(sess, "login", "账号或密码错误")
                    return
                }
                if (isUserOnline(u.id)) {
                    sendError(sess, "login", "该账号已在线")
                    return
                }
                sess.userId = u.id
                sess.account = u.account
                sess.nickname = u.nickname
                gUserSession[u.id] = sess.socket.getPtr()

                // 好友列表（含在线状态）
                let friends = db.getFriends(u.id)
                var friendsJson = ""
                var first = true
                for (f in friends) {
                    let item = friendItemJson(f)
                    friendsJson = if (first) { item } else { "${friendsJson},${item}" }
                    first = false
                }

                // 离线消息（取出即标记已读）
                let unread = db.popUnread(u.id)
                var msgsJson = ""
                first = true
                for (m in unread) {
                    let item = "{\"from\":${m.fromId},\"fromName\":\"${escapeJson(m.fromName)}\",\"text\":\"${escapeJson(m.text)}\",\"time\":\"${m.time}\"}"
                    msgsJson = if (first) { item } else { "${msgsJson},${item}" }
                    first = false
                }

                let json = "{\"type\":\"login_ok\",\"id\":${u.id},\"account\":${u.account}," +
                    "\"nickname\":\"${escapeJson(u.nickname)}\"," +
                    "\"friends\":[${friendsJson}],\"messages\":[${msgsJson}]}"
                sendJson(sess, json)
                serverLog("用户登录: ${u.nickname}(${u.account}) 来自 ${sess.peer}")
                broadcastPresence(u.id, true)
                updateStatus()
            case None =>
                sendError(sess, "login", "账号或密码错误")
        }
    }
}

/// 添加好友：双向建立关系，通知双方
public func doAddFriend(sess: Session, account: Int64): Unit {
    if (sess.userId == 0) {
        sendError(sess, "add_friend", "未登录")
        return
    }
    if (let Some(db) <- gDb) {
        match (db.findByAccount(account)) {
            case Some(target) =>
                if (target.id == sess.userId) {
                    sendError(sess, "add_friend", "不能添加自己为好友")
                    return
                }
                if (db.areFriends(sess.userId, target.id)) {
                    sendError(sess, "add_friend", "对方已经是你的好友")
                    return
                }
                if (!db.addFriend(sess.userId, target.id)) {
                    sendError(sess, "add_friend", "添加失败，请重试")
                    return
                }
                serverLog("添加好友: ${sess.nickname}(${sess.account}) <-> ${target.nickname}(${target.account})")
                // 通知请求方
                sendJson(sess, "{\"type\":\"ok\",\"op\":\"add_friend\",\"friend\":${userItemJson(target)}}")
                // 通知目标方（若在线）
                if (isUserOnline(target.id)) {
                    match (db.findById(sess.userId)) {
                        case Some(me) =>
                            let frame = "{\"type\":\"friend_added\",\"friend\":${userItemJson(me)}}"
                            forwardToUser(target.id, frame)
                        case None => ()
                    }
                }
            case None =>
                sendError(sess, "add_friend", "账号不存在")
        }
    }
}

/// 聊天消息：入库 + 在线转发 / 离线暂存
public func doChat(sess: Session, to: Int64, text: String): Unit {
    if (sess.userId == 0) {
        sendError(sess, "chat", "未登录")
        return
    }
    if (text.isEmpty()) { return }
    if (text.size > 6000) {
        sendError(sess, "chat", "消息过长")
        return
    }
    if (let Some(db) <- gDb) {
        if (!db.areFriends(sess.userId, to)) {
            sendError(sess, "chat", "对方不是你的好友")
            return
        }
        let online = isUserOnline(to)
        db.saveMessage(sess.userId, to, text, online)
        let time = nowString()
        let frame = "{\"type\":\"chat\",\"from\":${sess.userId}," +
            "\"fromName\":\"${escapeJson(sess.nickname)}\"," +
            "\"text\":\"${escapeJson(text)}\",\"time\":\"${time}\"}"
        if (online) {
            forwardToUser(to, frame)
        } else {
            serverLog("离线消息暂存: ${sess.nickname} -> 用户${to}")
        }
    }
}

/// 把帧转发给指定在线用户
public func forwardToUser(userId: Int64, frame: String): Unit {
    match (gUserSession.get(userId)) {
        case Some(ptr) =>
            match (gSessions.get(ptr)) {
                case Some(sess) => sendJson(sess, frame)
                case None => ()
            }
        case None => ()
    }
}
