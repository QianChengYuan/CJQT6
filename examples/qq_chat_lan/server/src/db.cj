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
            "PRIMARY KEY (user_id, friend_id))")) {
            println("建表错误: CREATE TABLE friends 失败")
        }
        if (!query.exec("CREATE TABLE IF NOT EXISTS messages (" +
            "id INTEGER PRIMARY KEY, " +
            "sender_id INTEGER NOT NULL, " +
            "receiver_id INTEGER NOT NULL, " +
            "content TEXT NOT NULL, " +
            "send_time TEXT NOT NULL, " +
            "is_read INTEGER DEFAULT 0)")) {
            println("建表错误: CREATE TABLE messages 失败")
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

    /// 获取好友列表（JOIN users 取实时昵称与账号）
    public func getFriends(userId: Int64): ArrayList<FriendRec> {
        let list = ArrayList<FriendRec>()
        if (!query.exec("SELECT u.id, u.account, u.nickname FROM friends f " +
            "JOIN users u ON u.id = f.friend_id " +
            "WHERE f.user_id = ${userId} ORDER BY u.id")) {
            return list
        }
        while (query.next()) {
            let f = FriendRec()
            f.id = Int64(query.valueInt(0))
            f.account = Int64(query.valueInt(1))
            f.nickname = query.valueString(2)
            list.add(f)
        }
        return list
    }

    // --------------------------------------------------------
    // 消息
    // --------------------------------------------------------

    /// 保存消息；isRead=true 表示接收方在线即时送达
    public func saveMessage(fromId: Int64, toId: Int64, text: String, isRead: Bool): Unit {
        let readFlag = if (isRead) { 1 } else { 0 }
        let sql = "INSERT INTO messages (id, sender_id, receiver_id, content, send_time, is_read) " +
            "VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM messages), " +
            "${fromId}, ${toId}, '${sqlEscape(text)}', '${nowString()}', ${readFlag})"
        if (!query.exec(sql)) {
            println("消息保存失败: from=${fromId} to=${toId}")
        }
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
