// ============================================================
// QQ局域网聊天 - 客户端全局状态
// ============================================================
package qq_lan_client.state

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.views.*
import std.collection.*
import qq_lan_client.core.*

// --------------------------------------------------------
// 应用级
// --------------------------------------------------------

/// QApplication 实例
public var gApp: ?QApplication = None

/// 当前登录用户（未登录为 None）
public var gSelf: ?SelfInfo = None

/// 好友列表（服务端下发 + 本地增量维护）
public var gFriends: ArrayList<FriendInfo> = ArrayList<FriendInfo>()

/// 未读消息计数：friendId -> 条数
public var gUnread: HashMap<Int64, Int64> = HashMap<Int64, Int64>()

/// 聊天记录缓存：friendId -> 消息列表（登录时离线消息 + 会话期间消息）
public var gHistory: HashMap<Int64, ArrayList<ChatMsg>> = HashMap<Int64, ArrayList<ChatMsg>>()

/// 当前聊天窗口打开的好友 ID（0 表示未打开）
public var gCurrentChatId: Int64 = 0

/// 文件接收缓冲表：tid -> RecvTransfer
public var gTransfers: HashMap<String, RecvTransfer> = HashMap<String, RecvTransfer>()

/// 每个好友会话最后一条已确认(ack)的发送消息 ID（撤回用）：friendId -> msgId
public var gLastSentId: HashMap<Int64, Int64> = HashMap<Int64, Int64>()

/// 文件发送计数器（生成 tid）
public var gSendCounter: Int64 = 0

/// 接收文件保存目录（绝对路径）
public var gRecvDir: String = "recv"

// --------------------------------------------------------
// 窗口与控件
// --------------------------------------------------------

/// 登录窗口
public var gLoginWindow: ?QWidget = None

/// 好友面板（主窗口）
public var gMainWindow: ?QWidget = None

/// 聊天窗口
public var gChatWindow: ?QWidget = None

/// 登录页控件
public var gAccountEdit: ?QLineEdit = None
public var gPasswordEdit: ?QLineEdit = None
public var gServerEdit: ?QLineEdit = None
public var gLoginStatus: ?QLabel = None

/// 好友列表控件
public var gFriendList: ?QListWidget = None

/// 主窗口底部状态（登录账号信息）
public var gSelfLabel: ?QLabel = None

/// 聊天窗口控件
public var gChatTitle: ?QLabel = None
public var gChatHistory: ?QTextEdit = None
public var gChatInput: ?QLineEdit = None

/// 表情面板窗口
public var gEmojiPanel: ?QWidget = None

// --------------------------------------------------------
// 好友辅助（仅依赖 state，供 app 各文件共用，避免循环依赖）
// --------------------------------------------------------

/// 当前选中好友的 ID（未选中返回 0）
public func selectedFriendId(): Int64 {
    match (gFriendList) {
        case Some(list) =>
            let row = list.currentRow()
            if (row < 0 || Int64(row) >= gFriends.size) { return 0 }
            gFriends[Int64(row)].id
        case None => 0
    }
}

/// 好友显示名（备注优先）
public func displayNameOf(fid: Int64): String {
    for (f in gFriends) {
        if (f.id == fid) {
            return if (f.remark.isEmpty()) { f.nickname } else { f.remark }
        }
    }
    ""
}
