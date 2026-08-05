// ============================================================
// QQ局域网聊天 - 服务端数据层
// SQLite 存储：users / friends / messages 三张表。
// 所有用户输入均经 sqlEscape 转义后拼入 SQL。
// ============================================================
package qq_lan_server

import cjqt6.sql.*
import std.collection.*
import std.time.*

// ============================================================
// 数据记录类型
// ============================================================

/// 用户记录
public class UserRec {
    public var id: Int64 = 0
    public var account: Int64 = 0
    public var nickname: String = ""
    public init() {}
}

/// 好友记录（含账号与昵称，供协议下发）
public class FriendRec {
    public var id: Int64 = 0
    public var account: Int64 = 0
    public var nickname: String = ""
    public var remark: String = ""
    public init() {}
}

/// 聊天记录记录（history 帧下发用）
public class HistRec {
    public var id: Int64 = 0
    public var fromId: Int64 = 0
    public var fromName: String = ""
    public var text: String = ""
    public var time: String = ""
    public var kind: String = "text"
    public var recalled: Bool = false
    public init() {}
}

/// 离线消息记录（下发给刚登录的用户）
public class MsgRec {
    public var fromId: Int64 = 0
    public var fromName: String = ""
    public var text: String = ""
    public var time: String = ""
    public init() {}
}

// ============================================================
// 辅助函数
// ============================================================

/// SQL 字符串转义：单引号翻倍，防止注入
public func sqlEscape(s: String): String {
    s.replace("'", "''")
}

/// 当前时间字符串（yyyy-MM-dd HH:mm:ss）
public func nowString(): String {
    let str = DateTime.now().toString()
    if (str.size >= 19) { str[0..19] } else { str }
}

// ============================================================
// ServerDb - 服务端数据库操作
// ============================================================
public class ServerDb {
    private var query: QSqlQuery

    public init(db: QSqlDatabase) {
        this.query = QSqlQuery(db)
        createTables()
        migrateColumns()
    }

    private func createTables(): Unit {
        if (!query.exec("CREATE TABLE IF NOT EXISTS users (" +
            "id INTEGER PRIMARY KEY, " +
            "account INTEGER UNIQUE NOT NULL, " +
            "password TEXT NOT NULL, " +
            "nickname TEXT NOT NULL, " +
            "created_at TEXT NOT NULL)")) {
            println("建表错误: CREATE TABLE users 失败")
        }
        if (!query.exec("CREATE TABLE IF NOT EXISTS friends (" +
            "user_id INTEGER NOT NULL, " +
            "friend_id INTEGER NOT NULL, " +
            "remark TEXT DEFAULT '', " +
            "PRIMARY KEY (user_id, friend_id))")) {
            println("建表错误: CREATE TABLE friends 失败")
        }
        if (!query.exec("CREATE TABLE IF NOT EXISTS messages (" +
            "id INTEGER PRIMARY KEY, " +
            "sender_id INTEGER NOT NULL, " +
            "receiver_id INTEGER NOT NULL, " +
            "content TEXT NOT NULL, " +
            "send_time TEXT NOT NULL, " +
            "is_read INTEGER DEFAULT 0, " +
            "kind TEXT DEFAULT 'text', " +
            "recalled INTEGER DEFAULT 0)")) {
            println("建表错误: CREATE TABLE messages 失败")
        }
    }

    /// 旧库列迁移：v1 库补全 remark / kind / recalled 列
    private func migrateColumns(): Unit {
        addColumnIfNotExists("friends", "remark", "TEXT DEFAULT ''")
        addColumnIfNotExists("messages", "kind", "TEXT DEFAULT 'text'")
        addColumnIfNotExists("messages", "recalled", "INTEGER DEFAULT 0")
    }

    private func addColumnIfNotExists(tableName: String, columnName: String, columnDef: String): Unit {
        if (!query.exec("PRAGMA table_info(${tableName})")) { return }
        var hasColumn = false
        while (query.next()) {
            if (query.valueString(1) == columnName) { hasColumn = true }
        }
        if (!hasColumn) {
            let _ = query.exec("ALTER TABLE ${tableName} ADD COLUMN ${columnName} ${columnDef}")
        }
    }

    // --------------------------------------------------------
    // 用户
    // --------------------------------------------------------

    /// 注册新用户：自动分配 QQ 号（10000 起递增），返回账号；失败返回 0
    public func registerUser(nickname: String, password: String): Int64 {
        var newAccount: Int64 = 10000
        if (!query.exec("SELECT COALESCE(MAX(account), 9999) + 1 FROM users")) {
            println("注册错误: 查询最大账号失败")
            return 0
        }
        if (query.next()) { newAccount = Int64(query.valueInt(0)) }
        if (newAccount < 10000) { newAccount = 10000 }
        let sql = "INSERT INTO users (id, account, password, nickname, created_at) " +
            "VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM users), " +
            "${newAccount}, '${sqlEscape(password)}', '${sqlEscape(nickname)}', '${nowString()}')"
        if (query.exec(sql)) { return newAccount }
        println("注册错误: 插入用户失败 account=${newAccount}")
        return 0
    }

    /// 按 QQ 号查找用户
    public func findByAccount(account: Int64): ?UserRec {
        if (!query.exec("SELECT id, account, nickname FROM users WHERE account = ${account}")) {
            return None
        }
        if (query.next()) {
            let u = UserRec()
            u.id = Int64(query.valueInt(0))
            u.account = Int64(query.valueInt(1))
            u.nickname = query.valueString(2)
            return Some(u)
        }
        return None
    }

    /// 按内部 ID 查找用户
    public func findById(id: Int64): ?UserRec {
        if (!query.exec("SELECT id, account, nickname FROM users WHERE id = ${id}")) {
            return None
        }
        if (query.next()) {
            let u = UserRec()
            u.id = Int64(query.valueInt(0))
            u.account = Int64(query.valueInt(1))
            u.nickname = query.valueString(2)
            return Some(u)
        }
        return None
    }

    /// 校验密码
    public func checkPassword(userId: Int64, password: String): Bool {
        if (!query.exec("SELECT COUNT(*) FROM users WHERE id = ${userId} " +
            "AND password = '${sqlEscape(password)}'")) {
            return false
        }
        if (query.next()) { return query.valueInt(0) > 0 }
        return false
    }

    // --------------------------------------------------------
    // 好友
    // --------------------------------------------------------

    /// 是否已是好友
    public func areFriends(a: Int64, b: Int64): Bool {
        if (!query.exec("SELECT COUNT(*) FROM friends WHERE user_id = ${a} AND friend_id = ${b}")) {
            return false
        }
        if (query.next()) { return query.valueInt(0) > 0 }
        return false
    }

    /// 添加好友（双向各存一行），成功返回 true
    public func addFriend(a: Int64, b: Int64): Bool {
        if (a == b) { return false }
        if (areFriends(a, b)) { return false }
        if (!query.exec("INSERT OR IGNORE INTO friends (user_id, friend_id) VALUES (${a}, ${b})")) {
            return false
        }
        if (!query.exec("INSERT OR IGNORE INTO friends (user_id, friend_id) VALUES (${b}, ${a})")) {
            return false
        }
        return true
    }

    /// 获取好友列表（JOIN users 取实时昵称与账号，含备注）
    public func getFriends(userId: Int64): ArrayList<FriendRec> {
        let list = ArrayList<FriendRec>()
        if (!query.exec("SELECT u.id, u.account, u.nickname, COALESCE(f.remark, '') FROM friends f " +
            "JOIN users u ON u.id = f.friend_id " +
            "WHERE f.user_id = ${userId} ORDER BY u.id")) {
            return list
        }
        while (query.next()) {
            let f = FriendRec()
            f.id = Int64(query.valueInt(0))
            f.account = Int64(query.valueInt(1))
            f.nickname = query.valueString(2)
            f.remark = query.valueString(3)
            list.add(f)
        }
        return list
    }

    // --------------------------------------------------------
    // 消息
    // --------------------------------------------------------

    /// 保存消息；isRead=true 表示接收方在线即时送达；kind: text/image/file
    /// 返回新消息 ID（失败返回 0）
    public func saveMessage(fromId: Int64, toId: Int64, text: String, isRead: Bool, kind: String): Int64 {
        let readFlag = if (isRead) { 1 } else { 0 }
        let sql = "INSERT INTO messages (id, sender_id, receiver_id, content, send_time, is_read, kind) " +
            "VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM messages), " +
            "${fromId}, ${toId}, '${sqlEscape(text)}', '${nowString()}', ${readFlag}, '${sqlEscape(kind)}')"
        if (!query.exec(sql)) {
            println("消息保存失败: from=${fromId} to=${toId}")
            return 0
        }
        if (!query.exec("SELECT MAX(id) FROM messages")) { return 0 }
        if (query.next()) { return Int64(query.valueInt(0)) }
        return 0
    }

    /// 获取两人之间的聊天记录（最近 limit 条，正序返回）
    public func getHistory(userId: Int64, friendId: Int64, limit: Int64): ArrayList<HistRec> {
        let list = ArrayList<HistRec>()
        if (!query.exec("SELECT m.id, m.sender_id, u.nickname, m.content, m.send_time, " +
            "COALESCE(m.kind, 'text'), COALESCE(m.recalled, 0) " +
            "FROM messages m JOIN users u ON u.id = m.sender_id " +
            "WHERE (m.sender_id = ${userId} AND m.receiver_id = ${friendId}) " +
            "OR (m.sender_id = ${friendId} AND m.receiver_id = ${userId}) " +
            "ORDER BY m.id DESC LIMIT ${limit}")) {
            return list
        }
        let temp = ArrayList<HistRec>()
        while (query.next()) {
            let h = HistRec()
            h.id = Int64(query.valueInt(0))
            h.fromId = Int64(query.valueInt(1))
            h.fromName = query.valueString(2)
            h.text = query.valueString(3)
            h.time = query.valueString(4)
            h.kind = query.valueString(5)
            h.recalled = query.valueInt(6) == 1
            temp.add(h)
        }
        // 倒序查询，反转为正序
        var i = temp.size - 1
        while (i >= 0) {
            list.add(temp[i])
            i--
        }
        return list
    }

    /// 查询单条消息信息（撤回校验用），返回 (senderId, receiverId, sendTime, recalled)
    public func getMessageInfo(msgId: Int64): ?(Int64, Int64, String, Bool) {
        if (!query.exec("SELECT sender_id, receiver_id, send_time, COALESCE(recalled, 0) " +
            "FROM messages WHERE id = ${msgId}")) {
            return None
        }
        if (query.next()) {
            return Some((Int64(query.valueInt(0)), Int64(query.valueInt(1)),
                query.valueString(2), query.valueInt(3) == 1))
        }
        return None
    }

    /// 标记消息撤回
    public func setRecalled(msgId: Int64): Bool {
        query.exec("UPDATE messages SET recalled = 1 WHERE id = ${msgId}")
    }

    // --------------------------------------------------------
    // 账号与好友管理
    // --------------------------------------------------------

    /// 修改昵称
    public func updateNickname(userId: Int64, nickname: String): Bool {
        if (nickname.isEmpty() || nickname.size > 60) { return false }
        query.exec("UPDATE users SET nickname = '${sqlEscape(nickname)}' WHERE id = ${userId}")
    }

    /// 修改密码（调用方已校验旧密码）
    public func updatePassword(userId: Int64, newPassword: String): Bool {
        if (newPassword.size < 4 || newPassword.size > 96) { return false }
        query.exec("UPDATE users SET password = '${sqlEscape(newPassword)}' WHERE id = ${userId}")
    }

    /// 设置好友备注（仅自己一侧）
    public func setRemark(userId: Int64, friendId: Int64, remark: String): Bool {
        if (remark.size > 60) { return false }
        if (!query.exec("UPDATE friends SET remark = '${sqlEscape(remark)}' " +
            "WHERE user_id = ${userId} AND friend_id = ${friendId}")) {
            return false
        }
        true
    }

    /// 删除好友（双向）
    public func deleteFriend(a: Int64, b: Int64): Bool {
        if (!query.exec("DELETE FROM friends WHERE (user_id = ${a} AND friend_id = ${b}) " +
            "OR (user_id = ${b} AND friend_id = ${a})")) {
            return false
        }
        true
    }

    /// 取出并标记已读某用户的全部未读消息
    public func popUnread(userId: Int64): ArrayList<MsgRec> {
        let list = ArrayList<MsgRec>()
        if (!query.exec("SELECT m.sender_id, u.nickname, m.content, m.send_time " +
            "FROM messages m JOIN users u ON u.id = m.sender_id " +
            "WHERE m.receiver_id = ${userId} AND m.is_read = 0 ORDER BY m.id")) {
            return list
        }
        while (query.next()) {
            let m = MsgRec()
            m.fromId = Int64(query.valueInt(0))
            m.fromName = query.valueString(1)
            m.text = query.valueString(2)
            m.time = query.valueString(3)
            list.add(m)
        }
        if (list.size > 0) {
            if (!query.exec("UPDATE messages SET is_read = 1 WHERE receiver_id = ${userId} AND is_read = 0")) {
                println("标记已读失败: user=${userId}")
            }
        }
        return list
    }

    /// 释放查询资源
    public func close(): Unit {
        query.finish()
        query.delete()
    }
}
