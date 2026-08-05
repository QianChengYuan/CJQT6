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
    public var remark: String = ""
    public var online: Bool = false
    public init() {}
}

/// 一条聊天消息（本地展示用）
public class ChatMsg {
    public var id: Int64 = 0
    public var fromId: Int64 = 0
    public var fromName: String = ""
    public var text: String = ""
    public var time: String = ""
    /// true = 自己发出
    public var outgoing: Bool = false
    /// text / image / file
    public var kind: String = "text"
    /// image/file 消息的文件名
    public var fileName: String = ""
    /// image/file 消息的字节数
    public var fileSize: Int64 = 0
    /// 是否已撤回
    public var recalled: Bool = false
    /// 本地文件路径（发送方为原路径，接收方为 recv 目录）
    public var localPath: String = ""
    public init() {}
}

/// 文件接收缓冲（按 tid 跟踪）
public class RecvTransfer {
    public var buffer: Array<Byte> = []
    public var offset: Int64 = 0
    public var name: String = ""
    public var kind: String = "file"
    public var fromId: Int64 = 0
    public var fromName: String = ""
    public init() {}
}

/// 当前时间字符串（yyyy-MM-dd HH:mm:ss）
public func nowString(): String {
    let str = DateTime.now().toString()
    if (str.size >= 19) { str[0..19] } else { str }
}
