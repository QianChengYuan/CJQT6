// ============================================================
// QQ局域网聊天 - 客户端数据模型
// ============================================================
package qq_lan_client.core

import std.time.*

/// 当前登录用户信息
public class SelfInfo {
    public var id: Int64 = 0
    public var account: Int64 = 0
    public var nickname: String = ""
    public init() {}
}

/// 好友信息（含实时在线状态）
public class FriendInfo {
    public var id: Int64 = 0
    public var account: Int64 = 0
    public var nickname: String = ""
    public var online: Bool = false
    public init() {}
}

/// 一条聊天消息（本地展示用）
public class ChatMsg {
    public var fromId: Int64 = 0
    public var fromName: String = ""
    public var text: String = ""
    public var time: String = ""
    /// true = 自己发出
    public var outgoing: Bool = false
    public init() {}
}

/// 当前时间字符串（yyyy-MM-dd HH:mm:ss）
public func nowString(): String {
    let str = DateTime.now().toString()
    if (str.size >= 19) { str[0..19] } else { str }
}
