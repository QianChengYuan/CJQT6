// ============================================================
// QQ聊天 - 数据库管理
// 单机版：账号 / 好友 / 消息全部存本地 SQLite。
// 本类封装所有数据库操作，包括建表、迁移、CRUD。
// ============================================================
package qq_chat.core

import cjqt6.sql.*
import std.collection.*
import std.convert.*

// ============================================================
// DatabaseManager - 所有数据库操作
// 持有 QSqlDatabase 和 QSqlQuery，提供用户/好友/消息的完整 CRUD。
// ============================================================
public class DatabaseManager {
    private var db: QSqlDatabase
    private var query: QSqlQuery

    /// 初始化数据库管理器：建表 → 迁移 → 填充默认数据
    public init(db: QSqlDatabase) {
        this.db = db
        this.query = QSqlQuery(db)
        createTables()
        migrateColumns()
        initDefaultData()
    }

    // ============================================================
    // 建表
    // 若检测到旧版本表结构（无 account 列），则整库重建。
    // ============================================================
    private func createTables(): Unit {
        // 旧库迁移：老版本 users 表用的是 username 列，检测到后重建
        // （演示数据会在 initDefaultData 中重新初始化）
        if (!query.exec("PRAGMA table_info(users)")) {
            println("建表警告: PRAGMA table_info(users) 执行失败")
        }
        var hasAccount = false
        while (query.next()) {
            if (query.valueString(1) == "account") { hasAccount = true }
        }
        if (!hasAccount) {
            // 旧版本表不含 account 列，整库重建
            if (!query.exec("DROP TABLE IF EXISTS users")) {
                println("建表警告: DROP users 失败")
            }
            if (!query.exec("DROP TABLE IF EXISTS friends")) {
                println("建表警告: DROP friends 失败")
            }
            if (!query.exec("DROP TABLE IF EXISTS messages")) {
                println("建表警告: DROP messages 失败")
            }
        }

        // 用户表（account 为账号，5位数字，10000 起）
        if (!query.exec("CREATE TABLE IF NOT EXISTS users (" +
            "id INTEGER PRIMARY KEY, " +
            "account INTEGER UNIQUE NOT NULL, " +
            "password TEXT NOT NULL, " +
            "display_name TEXT NOT NULL, " +
            "create_time TEXT NOT NULL)")) {
            println("建表错误: CREATE TABLE users 失败")
        }

        // 好友关系表（双向各存一行，便于各自查询）
        if (!query.exec("CREATE TABLE IF NOT EXISTS friends (" +
            "id INTEGER PRIMARY KEY, " +
            "user_id INTEGER NOT NULL, " +
            "friend_id INTEGER NOT NULL, " +
            "friend_name TEXT, " +
            "remark TEXT)")) {
            println("建表错误: CREATE TABLE friends 失败")
        }

        // 消息表
        if (!query.exec("CREATE TABLE IF NOT EXISTS messages (" +
            "id INTEGER PRIMARY KEY, " +
            "sender_id INTEGER NOT NULL, " +
            "receiver_id INTEGER NOT NULL, " +
            "content TEXT NOT NULL, " +
            "send_time TEXT NOT NULL)")) {
            println("建表错误: CREATE TABLE messages 失败")
        }
    }

    // ============================================================
    // 列迁移：为旧版本数据库补全新增列
    // 使用 ALTER TABLE ADD COLUMN + DEFAULT 保证旧数据兼容
    // ============================================================
    private func migrateColumns(): Unit {
        // messages 表新增列
        if (!addColumnIfNotExists("messages", "message_type", "TEXT DEFAULT 'text'")) {
            println("迁移警告: messages.message_type 列迁移失败")
        }
        if (!addColumnIfNotExists("messages", "is_recalled", "INTEGER DEFAULT 0")) {
            println("迁移警告: messages.is_recalled 列迁移失败")
        }
        if (!addColumnIfNotExists("messages", "is_read", "INTEGER DEFAULT 0")) {
            println("迁移警告: messages.is_read 列迁移失败")
        }
        // users 表新增列
        if (!addColumnIfNotExists("users", "avatar_path", "TEXT DEFAULT ''")) {
            println("迁移警告: users.avatar_path 列迁移失败")
        }
    }

    /// 检测表中是否已有指定列，若无则 ALTER TABLE ADD COLUMN。
    /// tableName: 表名, columnName: 列名, columnDef: 列定义（如 "TEXT DEFAULT 'text'"）
    /// 返回 true 表示列已存在或添加成功，false 表示添加失败
    private func addColumnIfNotExists(tableName: String, columnName: String, columnDef: String): Bool {
        query.exec("PRAGMA table_info(${tableName})")
        var hasColumn = false
        while (query.next()) {
            if (query.valueString(1) == columnName) { hasColumn = true }
        }
        if (!hasColumn) {
            return query.exec("ALTER TABLE ${tableName} ADD COLUMN ${columnName} ${columnDef}")
        }
        return true
    }

    // ============================================================
    // 初始化默认数据
    // 仅在 users 表为空时执行，插入4个默认用户及好友关系、演示消息。
    // ============================================================
    private func initDefaultData(): Unit {
        // 检查是否已有用户
        if (!query.exec("SELECT COUNT(*) FROM users")) {
            println("初始化警告: 查询用户数失败")
            return
        }
        if (query.next()) {
            let count = query.valueInt(0)
            if (count > 0) { return }
        }

        let now = getNowString()

        // 默认账号（账号从 10000 开始递增）
        if (!query.exec("INSERT INTO users (id, account, password, display_name, create_time) " +
            "VALUES (1, 10000, 'admin123', '系统管理员', '${now}')")) {
            println("初始化错误: 插入默认用户1失败")
        }
        if (!query.exec("INSERT INTO users (id, account, password, display_name, create_time) " +
            "VALUES (2, 10001, 'user123', '小明', '${now}')")) {
            println("初始化错误: 插入默认用户2失败")
        }
        if (!query.exec("INSERT INTO users (id, account, password, display_name, create_time) " +
            "VALUES (3, 10002, 'user123', '小红', '${now}')")) {
            println("初始化错误: 插入默认用户3失败")
        }
        if (!query.exec("INSERT INTO users (id, account, password, display_name, create_time) " +
            "VALUES (4, 10003, 'user123', '小刚', '${now}')")) {
            println("初始化错误: 插入默认用户4失败")
        }

        // 好友关系：小明(2) <-> 小红(3)、小明(2) <-> 小刚(4)
        // 双向各存一行，便于各自查询好友列表
        if (!query.exec("INSERT INTO friends (id, user_id, friend_id, friend_name, remark) " +
            "VALUES (1, 2, 3, '小红', '小红')")) {
            println("初始化错误: 插入好友关系1失败")
        }
        if (!query.exec("INSERT INTO friends (id, user_id, friend_id, friend_name, remark) " +
            "VALUES (2, 3, 2, '小明', '小明')")) {
            println("初始化错误: 插入好友关系2失败")
        }
        if (!query.exec("INSERT INTO friends (id, user_id, friend_id, friend_name, remark) " +
            "VALUES (3, 2, 4, '小刚', '小刚')")) {
            println("初始化错误: 插入好友关系3失败")
        }
        if (!query.exec("INSERT INTO friends (id, user_id, friend_id, friend_name, remark) " +
            "VALUES (4, 4, 2, '小明', '小明')")) {
            println("初始化错误: 插入好友关系4失败")
        }

        // 演示消息 (小明 <-> 小红)
        if (!query.exec("INSERT INTO messages (id, sender_id, receiver_id, content, send_time) " +
            "VALUES (1, 2, 3, '在吗？', '${now}')")) {
            println("初始化错误: 插入演示消息1失败")
        }
        if (!query.exec("INSERT INTO messages (id, sender_id, receiver_id, content, send_time) " +
            "VALUES (2, 3, 2, '在的，怎么了？', '${now}')")) {
            println("初始化错误: 插入演示消息2失败")
        }
        if (!query.exec("INSERT INTO messages (id, sender_id, receiver_id, content, send_time) " +
            "VALUES (3, 2, 3, '晚上一起吃饭吗？', '${now}')")) {
            println("初始化错误: 插入演示消息3失败")
        }
        if (!query.exec("INSERT INTO messages (id, sender_id, receiver_id, content, send_time) " +
            "VALUES (4, 3, 2, '好呀，老地方见！', '${now}')")) {
            println("初始化错误: 插入演示消息4失败")
        }
    }

    // ============================================================
    // 用户认证
    // ============================================================

    /// 登录认证：按账号+密码查询用户，成功返回 User，失败返回 None。
    /// 同时查询 avatar_path 字段用于头像显示。
    public func login(account: Int64, password: String): ?User {
        if (!query.exec("SELECT id, account, password, display_name, create_time, " +
            "COALESCE(avatar_path, '') " +
            "FROM users WHERE account = ${account} AND password = '${password}'")) {
            println("登录错误: 查询用户失败")
            return None
        }
        if (query.next()) {
            let user = User()
            user.id = Int64(query.valueInt(0))
            user.account = Int64(query.valueInt(1))
            user.password = query.valueString(2)
            user.displayName = query.valueString(3)
            user.createTime = query.valueString(4)
            user.avatarPath = query.valueString(5)
            return Some(user)
        }
        return None
    }

    // ============================================================
    // 用户管理
    // ============================================================

    /// 注册新用户：账号自动分配（10000 起，新注册 +1），返回新账号；失败返回 0。
    /// 使用 COALESCE(MAX(account), 9999) + 1 确保账号递增且不重复。
    public func addUser(password: String, displayName: String): Int64 {
        let now = getNowString()
        var newAccount: Int64 = 10000
        // 查询当前最大账号并 +1
        if (!query.exec("SELECT COALESCE(MAX(account), 9999) + 1 FROM users")) {
            println("注册错误: 查询最大账号失败")
            return 0
        }
        if (query.next()) { newAccount = Int64(query.valueInt(0)) }
        if (newAccount < 10000) { newAccount = 10000 }
        let sql = "INSERT INTO users (id, account, password, display_name, create_time) " +
            "VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM users), " +
            "${newAccount}, '${password}', '${displayName}', '${now}')"
        if (query.exec(sql)) { return newAccount }
        println("注册错误: 插入新用户失败, 账号=${newAccount}")
        return 0
    }

    /// 修改密码：校验旧密码正确后更新为新密码，成功返回 true。
    /// 先验证 userId + oldPassword 匹配，再执行 UPDATE。
    public func changePassword(userId: Int64, oldPassword: String, newPassword: String): Bool {
        if (!query.exec("SELECT COUNT(*) FROM users WHERE id = ${userId} AND password = '${oldPassword}'")) {
            println("改密错误: 验证旧密码查询失败")
            return false
        }
        if (query.next()) {
            if (query.valueInt(0) > 0) {
                if (!query.exec("UPDATE users SET password = '${newPassword}' WHERE id = ${userId}")) {
                    println("改密错误: UPDATE 执行失败")
                    return false
                }
                return true
            }
        }
        return false
    }

    /// 修改昵称：校验新昵称非空后更新，成功返回 true。
    public func updateDisplayName(userId: Int64, newName: String): Bool {
        if (newName.isEmpty()) { return false }
        if (!query.exec("UPDATE users SET display_name = '${newName}' WHERE id = ${userId}")) {
            println("修改昵称错误: UPDATE 执行失败")
            return false
        }
        return true
    }

    /// 更新头像路径：将用户自定义头像文件路径存入数据库，成功返回 true。
    public func updateAvatarPath(userId: Int64, path: String): Bool {
        if (!query.exec("UPDATE users SET avatar_path = '${path}' WHERE id = ${userId}")) {
            println("更新头像错误: UPDATE 执行失败")
            return false
        }
        return true
    }

    /// 按关键字搜索用户：匹配账号或昵称，返回匹配的用户列表。
    /// keyword 同时匹配 CAST(account AS TEXT) 和 display_name。
    public func searchUsersByKeyword(keyword: String): ArrayList<User> {
        let list = ArrayList<User>()
        if (!query.exec("SELECT id, account, password, display_name, create_time, COALESCE(avatar_path, '') FROM users " +
            "WHERE CAST(account AS TEXT) LIKE '%${keyword}%' OR display_name LIKE '%${keyword}%' ORDER BY id")) {
            println("搜索用户错误: 查询失败")
            return list
        }
        while (query.next()) {
            let u = User()
            u.id = Int64(query.valueInt(0))
            u.account = Int64(query.valueInt(1))
            u.password = query.valueString(2)
            u.displayName = query.valueString(3)
            u.createTime = query.valueString(4)
            u.avatarPath = query.valueString(5)
            list.add(u)
        }
        return list
    }

    // ============================================================
    // 好友管理
    // ============================================================

    /// 添加好友：双向各存一行（A→B 和 B→A），成功返回 true。
    /// 不允许添加自己；不允许重复添加。
    public func addFriend(userId: Int64, friendId: Int64, friendName: String): Bool {
        // 不允许添加自己为好友
        if (userId == friendId) { return false }
        // 检查是否已是好友
        if (!query.exec("SELECT COUNT(*) FROM friends WHERE user_id = ${userId} AND friend_id = ${friendId}")) {
            println("添加好友错误: 查询已有关系失败")
            return false
        }
        if (query.next()) {
            if (query.valueInt(0) > 0) { return false }
        }
        // 获取自己的昵称，作为对方列表里的好友名
        var myName = ""
        if (!query.exec("SELECT display_name FROM users WHERE id = ${userId}")) {
            println("添加好友错误: 查询自己昵称失败")
            return false
        }
        if (query.next()) { myName = query.valueString(0) }
        // 双向各存一行
        if (!query.exec("INSERT INTO friends (id, user_id, friend_id, friend_name, remark) " +
            "VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM friends), " +
            "${userId}, ${friendId}, '${friendName}', '${friendName}')")) {
            println("添加好友错误: 插入正向关系失败")
            return false
        }
        if (!query.exec("INSERT INTO friends (id, user_id, friend_id, friend_name, remark) " +
            "VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM friends), " +
            "${friendId}, ${userId}, '${myName}', '${myName}')")) {
            println("添加好友错误: 插入反向关系失败")
            return false
        }
        return true
    }

    /// 删除好友：双向删除 friends 表中双方记录，成功返回 true。
    /// 注意：不删除 messages 表中的历史消息，便于重新添加后查看。
    public func deleteFriend(userId: Int64, friendId: Int64): Bool {
        // 删除正向记录（userId → friendId）
        if (!query.exec("DELETE FROM friends WHERE user_id = ${userId} AND friend_id = ${friendId}")) {
            println("删除好友错误: 删除正向关系失败")
            return false
        }
        // 删除反向记录（friendId → userId）
        if (!query.exec("DELETE FROM friends WHERE user_id = ${friendId} AND friend_id = ${userId}")) {
            println("删除好友错误: 删除反向关系失败")
            return false
        }
        return true
    }

    /// 修改好友备注：更新 friends 表中 remark 字段，成功返回 true。
    /// 空备注时前端回退显示 friendName。
    public func updateFriendRemark(userId: Int64, friendId: Int64, remark: String): Bool {
        if (!query.exec("UPDATE friends SET remark = '${remark}' " +
            "WHERE user_id = ${userId} AND friend_id = ${friendId}")) {
            println("修改备注错误: UPDATE 执行失败")
            return false
        }
        return true
    }

    /// 获取指定用户的好友列表：LEFT JOIN users 获取最新昵称。
    /// COALESCE(u.display_name, f.friend_name) 优先使用 users 表实时昵称。
    public func getFriends(userId: Int64): ArrayList<Friend> {
        let list = ArrayList<Friend>()
        if (!query.exec("SELECT f.id, f.user_id, f.friend_id, COALESCE(u.display_name, f.friend_name), f.remark " +
            "FROM friends f LEFT JOIN users u ON f.friend_id = u.id " +
            "WHERE f.user_id = ${userId} ORDER BY f.id")) {
            println("获取好友列表错误: 查询失败")
            return list
        }
        while (query.next()) {
            let f = Friend()
            f.id = Int64(query.valueInt(0))
            f.userId = Int64(query.valueInt(1))
            f.friendId = Int64(query.valueInt(2))
            f.friendName = query.valueString(3)
            f.remark = query.valueString(4)
            list.add(f)
        }
        return list
    }

    // ============================================================
    // 消息管理
    // ============================================================

    /// 发送文本消息：插入 messages 表，message_type 默认 'text'，返回新消息 ID；失败返回 0。
    public func addMessage(senderId: Int64, receiverId: Int64, content: String): Int64 {
        let now = getNowString()
        let sql = "INSERT INTO messages (id, sender_id, receiver_id, content, send_time, message_type) " +
            "VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM messages), " +
            "${senderId}, ${receiverId}, '${content}', '${now}', 'text')"
        if (query.exec(sql)) {
            if (!query.exec("SELECT MAX(id) FROM messages")) {
                println("发送消息警告: 查询新消息ID失败")
                return 0
            }
            if (query.next()) { return Int64(query.valueInt(0)) }
        }
        println("发送消息错误: 插入消息失败")
        return 0
    }

    /// 发送图片消息：message_type='image'，content 为图片文件路径。
    public func addImageMessage(senderId: Int64, receiverId: Int64, imagePath: String): Int64 {
        let now = getNowString()
        let sql = "INSERT INTO messages (id, sender_id, receiver_id, content, send_time, message_type) " +
            "VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM messages), " +
            "${senderId}, ${receiverId}, '${imagePath}', '${now}', 'image')"
        if (query.exec(sql)) {
            if (!query.exec("SELECT MAX(id) FROM messages")) {
                println("发送图片消息警告: 查询新消息ID失败")
                return 0
            }
            if (query.next()) { return Int64(query.valueInt(0)) }
        }
        println("发送图片消息错误: 插入失败")
        return 0
    }

    /// 发送文件消息：message_type='file'，content 为文件路径。
    public func addFileMessage(senderId: Int64, receiverId: Int64, filePath: String): Int64 {
        let now = getNowString()
        let sql = "INSERT INTO messages (id, sender_id, receiver_id, content, send_time, message_type) " +
            "VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM messages), " +
            "${senderId}, ${receiverId}, '${filePath}', '${now}', 'file')"
        if (query.exec(sql)) {
            if (!query.exec("SELECT MAX(id) FROM messages")) {
                println("发送文件消息警告: 查询新消息ID失败")
                return 0
            }
            if (query.next()) { return Int64(query.valueInt(0)) }
        }
        println("发送文件消息错误: 插入失败")
        return 0
    }

    /// 获取两个用户之间的全部消息（按时间排序）。
    /// 查询包含 messageType、isRecalled、isRead 字段。
    public func getMessages(userId: Int64, friendId: Int64): ArrayList<Message> {
        let list = ArrayList<Message>()
        if (!query.exec("SELECT id, sender_id, receiver_id, content, send_time, " +
            "COALESCE(message_type, 'text'), COALESCE(is_recalled, 0), COALESCE(is_read, 0) " +
            "FROM messages " +
            "WHERE (sender_id = ${userId} AND receiver_id = ${friendId}) " +
            "OR (sender_id = ${friendId} AND receiver_id = ${userId}) " +
            "ORDER BY send_time, id")) {
            println("获取消息错误: 查询失败")
            return list
        }
        while (query.next()) {
            let m = Message()
            m.id = Int64(query.valueInt(0))
            m.senderId = Int64(query.valueInt(1))
            m.receiverId = Int64(query.valueInt(2))
            m.content = query.valueString(3)
            m.sendTime = query.valueString(4)
            m.messageType = query.valueString(5)
            m.isRecalled = Int64(query.valueInt(6))
            m.isRead = Int64(query.valueInt(7))
            list.add(m)
        }
        return list
    }

    /// 分页获取消息：按发送时间倒序分页，结果逆序返回（最早在前）。
    /// page: 页码(从1开始), pageSize: 每页条数
    public func getMessagesPaged(userId: Int64, friendId: Int64, page: Int64, pageSize: Int64): ArrayList<Message> {
        let list = ArrayList<Message>()
        let offset = (page - 1) * pageSize
        if (!query.exec("SELECT id, sender_id, receiver_id, content, send_time, " +
            "COALESCE(message_type, 'text'), COALESCE(is_recalled, 0), COALESCE(is_read, 0) " +
            "FROM messages " +
            "WHERE (sender_id = ${userId} AND receiver_id = ${friendId}) " +
            "OR (sender_id = ${friendId} AND receiver_id = ${userId}) " +
            "ORDER BY send_time DESC, id DESC " +
            "LIMIT ${pageSize} OFFSET ${offset}")) {
            println("分页获取消息错误: 查询失败")
            return list
        }
        // 逆序收集（倒序查询后需要反转为正序显示）
        let temp = ArrayList<Message>()
        while (query.next()) {
            let m = Message()
            m.id = Int64(query.valueInt(0))
            m.senderId = Int64(query.valueInt(1))
            m.receiverId = Int64(query.valueInt(2))
            m.content = query.valueString(3)
            m.sendTime = query.valueString(4)
            m.messageType = query.valueString(5)
            m.isRecalled = Int64(query.valueInt(6))
            m.isRead = Int64(query.valueInt(7))
            temp.add(m)
        }
        // 逆序：将倒序结果反转为正序（最早消息在前）
        var i = temp.size - 1
        while (i >= 0) {
            list.add(temp[i])
            i--
        }
        return list
    }

    /// 清空两个用户之间的聊天记录，成功返回 true。
    public func clearMessages(userId: Int64, friendId: Int64): Bool {
        if (!query.exec("DELETE FROM messages " +
            "WHERE (sender_id = ${userId} AND receiver_id = ${friendId}) " +
            "OR (sender_id = ${friendId} AND receiver_id = ${userId})")) {
            println("清空消息错误: DELETE 执行失败")
            return false
        }
        return true
    }

    /// 撤回消息：校验发送者是自己且发送时间距今 ≤ 2分钟，满足则标记 is_recalled=1。
    /// 成功返回 true；超时或非自己消息返回 false。
    public func recallMessage(messageId: Int64, userId: Int64): Bool {
        // 先查询消息的发送者和发送时间
        if (!query.exec("SELECT sender_id, send_time FROM messages WHERE id = ${messageId}")) {
            println("撤回消息错误: 查询消息失败")
            return false
        }
        if (!query.next()) { return false }
        let senderId = Int64(query.valueInt(0))
        // 校验：只能撤回自己发送的消息
        if (senderId != userId) { return false }
        // 校验：发送时间距今不超过2分钟（简化判断：比较时间字符串）
        let sendTime = query.valueString(1)
        let nowStr = getNowString()
        // 简化时间差判断：比较年月日时分秒差值
        if (!isWithinMinutes(sendTime, nowStr, 2)) { return false }
        // 标记撤回
        if (!query.exec("UPDATE messages SET is_recalled = 1 WHERE id = ${messageId}")) {
            println("撤回消息错误: UPDATE 执行失败")
            return false
        }
        return true
    }

    /// 删除单条消息，成功返回 true。
    public func deleteMessage(messageId: Int64): Bool {
        if (!query.exec("DELETE FROM messages WHERE id = ${messageId}")) {
            println("删除消息错误: DELETE 执行失败")
            return false
        }
        return true
    }

    /// 获取指定好友发给当前用户的未读消息数。
    /// 查询 is_read=0 且 sender_id=friendId 的消息条数。
    public func getUnreadCount(userId: Int64, friendId: Int64): Int64 {
        if (!query.exec("SELECT COUNT(*) FROM messages " +
            "WHERE is_read = 0 AND sender_id = ${friendId} AND receiver_id = ${userId}")) {
            println("未读计数错误: 查询失败")
            return 0
        }
        if (query.next()) { return Int64(query.valueInt(0)) }
        return 0
    }

    /// 将指定好友发给当前用户的消息全部标记为已读。
    public func markMessagesAsRead(userId: Int64, friendId: Int64): Unit {
        if (!query.exec("UPDATE messages SET is_read = 1 " +
            "WHERE receiver_id = ${userId} AND sender_id = ${friendId} AND is_read = 0")) {
            println("标记已读错误: UPDATE 执行失败")
        }
    }

    // ============================================================
    // 辅助函数
    // ============================================================

    /// 判断 time1 与 time2 的时间差是否在 maxMinutes 分钟内。
    /// 简化实现：逐段比较 yyyy-MM-dd HH:mm:ss 字符串。
    private func isWithinMinutes(time1: String, time2: String, maxMinutes: Int64): Bool {
        if (time1.size < 16 || time2.size < 16) { return false }
        // 比较到分钟级别：yyyy-MM-dd HH:mm
        let t1 = time1[0..16]
        let t2 = time2[0..16]
        // 同年同月同日同时同分 → 肯定在2分钟内
        if (t1 == t2) { return true }
        // 解析分钟差（简化：仅比较同一天内的分钟数）
        let day1 = time1[0..10]
        let day2 = time2[0..10]
        if (day1 != day2) { return false }
        // 解析小时和分钟
        if (let Some(h1) <- Int64.tryParse(time1[11..13])) {
            if (let Some(m1) <- Int64.tryParse(time1[14..16])) {
                if (let Some(h2) <- Int64.tryParse(time2[11..13])) {
                    if (let Some(m2) <- Int64.tryParse(time2[14..16])) {
                        let totalMin1 = h1 * 60 + m1
                        let totalMin2 = h2 * 60 + m2
                        let diff = if (totalMin2 > totalMin1) {
                            totalMin2 - totalMin1
                        } else {
                            totalMin1 - totalMin2
                        }
                        return diff <= maxMinutes
                    }
                }
            }
        }
        return false
    }

    // ============================================================
    // 清理
    // ============================================================

    /// 关闭数据库管理器：释放 QSqlQuery 资源。
    public func close(): Unit {
        query.finish()
        query.delete()
    }
}
