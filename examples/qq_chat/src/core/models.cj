// ============================================================
// QQ聊天 - 数据模型定义
// 本模块定义用户(User)、好友关系(Friend)、消息(Message)三个核心数据类，
// 以及时间格式化辅助函数。所有字段均为 var 以便数据库查询结果回填。
// ============================================================
package qq_chat.core

import std.time.*
import std.convert.*
import std.collection.*

// ============================================================
// 用户模型
// 对应数据库 users 表，存储账号、密码、昵称、头像路径等信息。
// ============================================================
public class User {
    /// 用户主键 ID（自增）
    public var id: Int64 = 0
    /// 账号（5位数字，10000 起自动分配）
    public var account: Int64 = 0
    /// 登录密码
    public var password: String = ""
    /// 显示昵称
    public var displayName: String = ""
    /// 注册时间（yyyy-MM-dd HH:mm:ss 格式）
    public var createTime: String = ""
    /// 自定义头像文件路径（空串表示使用默认生成的圆形头像）
    public var avatarPath: String = ""

    public init() {}
}

// ============================================================
// 好友关系模型
// 对应数据库 friends 表，双向各存一行（A→B 和 B→A 各一条记录），
// 便于各自查询自己的好友列表。
// ============================================================
public class Friend {
    /// 好友关系主键 ID（自增）
    public var id: Int64 = 0
    /// 所属用户 ID（即"谁的好友列表"）
    public var userId: Int64 = 0
    /// 好友用户 ID
    public var friendId: Int64 = 0
    /// 好友昵称（冗余存储，从 users.display_name 同步）
    public var friendName: String = ""
    /// 好友备注名（用户自定义，空串时回退显示 friendName）
    public var remark: String = ""

    public init() {}
}

// ============================================================
// 消息模型
// 对应数据库 messages 表，支持文本/图片/文件三种消息类型，
// 以及撤回标记和已读标记。
// ============================================================
public class Message {
    /// 消息主键 ID（自增）
    public var id: Int64 = 0
    /// 发送者用户 ID
    public var senderId: Int64 = 0
    /// 接收者用户 ID
    public var receiverId: Int64 = 0
    /// 消息内容（文本消息为文字，图片/文件消息为文件路径）
    public var content: String = ""
    /// 发送时间（yyyy-MM-dd HH:mm:ss 格式）
    public var sendTime: String = ""
    /// 消息类型："text"=文本, "image"=图片, "file"=文件
    public var messageType: String = "text"
    /// 撤回标记：0=正常, 1=已撤回
    public var isRecalled: Int64 = 0
    /// 已读标记：0=未读, 1=已读
    public var isRead: Int64 = 0

    public init() {}
}

// ============================================================
// 辅助函数
// ============================================================

/// 获取当前时间字符串，格式为 yyyy-MM-dd HH:mm:ss。
/// 截取 DateTime.toString() 前19个字符以确保格式统一。
public func getNowString(): String {
    let now = DateTime.now()
    let str = now.toString()
    // DateTime.toString() 可能含毫秒或时区后缀，截取前19字符保留到秒
    return if (str.size >= 19) {
        str[0..19]
    } else {
        str
    }
}

/// 格式化时间戳为友好显示格式。
/// 规则：今天→"今天 HH:mm"，昨天→"昨天 HH:mm"，
/// 今年→"MM-dd HH:mm"，往年→"yyyy-MM-dd HH:mm"。
/// 解析失败时回退返回原始 sendTime 字符串。
public func formatTimestamp(sendTime: String): String {
    // sendTime 格式为 "yyyy-MM-dd HH:mm:ss"，至少19字符
    if (sendTime.size < 19) {
        return sendTime
    }
    let datePart = sendTime[0..10]  // "yyyy-MM-dd"
    let timePart = sendTime[11..16] // "HH:mm"
    // 获取今天的日期部分
    let nowStr = getNowString()
    if (nowStr.size < 10) {
        return sendTime
    }
    let todayDate = nowStr[0..10]
    // 比较日期
    if (datePart == todayDate) {
        return "今天 ${timePart}"
    }
    // 计算昨天的日期：解析年月日并减1天
    let yearStr = datePart[0..4]
    let monthStr = datePart[5..7]
    let dayStr = datePart[8..10]
    let nowYearStr = todayDate[0..4]
    let nowMonthStr = todayDate[5..7]
    let nowDayStr = todayDate[8..10]
    // 尝试解析为整数
    if (let Some(year) <- Int64.tryParse(yearStr)) {
        if (let Some(month) <- Int64.tryParse(monthStr)) {
            if (let Some(day) <- Int64.tryParse(dayStr)) {
                if (let Some(nowYear) <- Int64.tryParse(nowYearStr)) {
                    if (let Some(nowMonth) <- Int64.tryParse(nowMonthStr)) {
                        if (let Some(nowDay) <- Int64.tryParse(nowDayStr)) {
                            // 计算消息日期与今天的天数差（简化：仅同月内比较）
                            if (year == nowYear && month == nowMonth) {
                                let dayDiff = nowDay - day
                                if (dayDiff == 1) {
                                    return "昨天 ${timePart}"
                                }
                                if (dayDiff == 0) {
                                    return "今天 ${timePart}"
                                }
                            }
                            // 今年但非今昨
                            if (year == nowYear) {
                                return "${monthStr}-${dayStr} ${timePart}"
                            }
                            // 往年
                            return "${datePart} ${timePart}"
                        }
                    }
                }
            }
        }
    }
    // 解析失败，回退返回原始字符串
    return sendTime
}

// ============================================================
// 好友分组模型
// ============================================================

public class FriendGroup {
    public var groupId: Int64 = 0
    public var name: String = ""
    public var friends: ArrayList<Friend> = ArrayList<Friend>()
    public var expanded: Bool = true

    public init() {}
}

/// 经典完整时间戳格式化：直接返回原始 sendTime 字符串
public func classicFormatTimestamp(sendTime: String): String {
    return sendTime
}
