// ============================================================
// QQ聊天 - 全局状态
// 单机版应用的所有全局状态集中于此，
// 供 qq_chat.app / qq_chat.ui / qq_chat 各包共享。
// 注意：跨包访问顶层变量需 public 修饰。
// ============================================================
package qq_chat.state

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.views.*
import cjqt6.menu.*
import std.collection.*
import cjqt6.widgets.*
import qq_chat.core.*

// ============================================================
// 应用级状态
// ============================================================

/// QApplication 实例引用，main() 中创建后赋值
public var gApp: ?QApplication = None

/// 数据库管理器实例，main() 中打开数据库后赋值
public var gDb: ?DatabaseManager = None

/// 当前登录用户信息，登录成功后赋值，退出登录后置 None
public var gCurrentUser: ?User = None

/// 系统缩放因子（高 DPI 支持），main() 中从 QScreen.scaleFactor() 获取
public var gScaleFactor: Float64 = 1.0

// ============================================================
// 窗口状态
// ============================================================

/// 登录窗口引用
public var gLoginWindow: ?QWidget = None

/// 主聊天窗口引用
public var gMainWindow: ?QMainWindow = None

// ============================================================
// 登录界面控件
// ============================================================

/// 登录页状态提示标签
public var gStatusLabel: ?QLabel = None

/// 登录账号输入框
public var gAccountEdit: ?QLineEdit = None

/// 登录密码输入框
public var gPasswordEdit: ?QLineEdit = None

// ============================================================
// 主界面控件
// ============================================================

/// 好友列表控件
public var gFriendList: ?QListWidget = None

/// 聊天记录显示区（QTextEdit，只读）
public var gChatHistory: ?QTextEdit = None

/// 消息输入框
public var gChatInput: ?QLineEdit = None

/// 当前聊天对象的好友 ID（0 表示未选中）
public var gCurrentFriendId: Int64 = 0

/// 好友列表缓存：行号 → Friend 对象，用于根据行号获取好友信息
public var gFriendCache: ArrayList<Friend> = ArrayList<Friend>()

/// 未读消息计数映射：friendId → unreadCount
public var gUnreadMap: HashMap<Int64, Int64> = HashMap<Int64, Int64>()

/// 当前聊天记录页码（分页加载，从1开始）
public var gCurrentPage: Int64 = 1

/// 是否还有更早的消息可加载（分页加载标记）
public var gHasMoreMessages: Bool = true

// ============================================================
// 注册对话框
// ============================================================

/// 注册对话框窗口引用
public var gRegisterDialog: ?QWidget = None

/// 注册密码输入框
public var gRegPassword: ?QLineEdit = None

/// 注册昵称输入框
public var gRegDisplayName: ?QLineEdit = None

// ============================================================
// 修改密码对话框
// ============================================================

/// 修改密码对话框窗口引用
public var gChangePwdDialog: ?QWidget = None

/// 旧密码输入框
public var gOldPwdEdit: ?QLineEdit = None

/// 新密码输入框
public var gNewPwdEdit: ?QLineEdit = None

/// 确认新密码输入框
public var gConfirmPwdEdit: ?QLineEdit = None

// ============================================================
// 添加好友对话框
// ============================================================

/// 添加好友对话框窗口引用
public var gAddFriendDialog: ?QWidget = None

/// 搜索关键字输入框
public var gSearchEdit: ?QLineEdit = None

/// 搜索结果列表控件
public var gSearchResultList: ?QListWidget = None

/// 搜索结果缓存：行号 → User 对象
public var gSearchCache: ArrayList<User> = ArrayList<User>()

// ============================================================
// 表情面板
// ============================================================

/// 表情面板窗口引用
public var gEmojiPanel: ?QWidget = None

// ============================================================
// 消息轮询定时器
// ============================================================

/// 消息轮询定时器引用（每2秒检查新消息，自动刷新未读计数和聊天记录）
public var gPollTimer: ?QTimer = None

// ============================================================
// 经典UI状态
// ============================================================

/// 登录状态（0=在线,1=离开,2=隐身,3=忙碌）
public var gLoginStatus: Int32 = 0

/// 记住密码勾选状态
public var gRememberPwd: Bool = false

/// 自动登录勾选状态
public var gAutoLogin: Bool = false

/// 高级设置区域展开状态
public var gAdvancedSettingsVisible: Bool = false

/// 平板模式开关
public var gFlatMode: Bool = false

/// 消息模式开关
public var gMessageMode: Bool = false

/// 好友分组列表
public var gFriendGroups: ArrayList<FriendGroup> = ArrayList<FriendGroup>()

/// 独立聊天窗口引用
public var gChatWindow: ?QWidget = None

/// 多行输入框引用（替代原gChatInput）
public var gChatInputEdit: ?QTextEdit = None

/// 登录状态下拉框
public var gLoginStatusCombo: ?QComboBox = None

/// 记住密码复选框
public var gRememberPwdCheck: ?QCheckBox = None

/// 自动登录复选框
public var gAutoLoginCheck: ?QCheckBox = None

/// 高级设置面板
public var gAdvancedSettingsPanel: ?QWidget = None

/// 高级设置按钮
public var gAdvancedSettingsBtn: ?QPushButton = None

/// 好友面板窗口引用（经典UI模式下替代gMainWindow）
public var gFriendPanel: ?QWidget = None
