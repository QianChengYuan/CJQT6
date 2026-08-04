package qq_chat.app

public let LOGIN_BG_GRADIENT_TOP = "#1A3A5C"
public let LOGIN_BG_GRADIENT_BOTTOM = "#0D2137"
public let XP_BORDER_COLOR = "#B8C7D6"
public let XP_BORDER_RADIUS = "4px"
public let CLASSIC_SELF_BUBBLE_COLOR = "#C0DEFF"
public let CLASSIC_OTHER_BUBBLE_BG = "#FFFFFF"
public let CLASSIC_OTHER_BUBBLE_BORDER = "#E0E0E0"
public let OFFLINE_NAME_COLOR = "#999999"
public let AVATAR_BORDER_COLOR = "#CCCCCC"
public let TOOLBAR_BG_COLOR = "#F0F0F0"
public let LOGIN_BTN_COLOR = "#1A3A5C"
public let SIGNATURE_COLOR = "#AAAAAA"
public let GROUP_HEADER_GRADIENT_TOP = "#1E4D7A"
public let GROUP_HEADER_GRADIENT_BOTTOM = "#0D3A5C"

public let LOGIN_WIDTH: Int32 = 380
public let LOGIN_HEIGHT: Int32 = 300
public let LOGIN_HEIGHT_EXPANDED: Int32 = 420
public let PENGUIN_LOGO_SIZE: Int32 = 64
public let PENGUIN_SMALL_SIZE: Int32 = 24
public let KEYBOARD_ICON_SIZE: Int32 = 16
public let FRIEND_PANEL_WIDTH: Int32 = 300
public let BIG_AVATAR_SIZE: Int32 = 48
public let FRIEND_AVATAR_SIZE: Int32 = 32
public let CHAT_WIDTH: Int32 = 560
public let CHAT_HEIGHT: Int32 = 480
public let CHAT_MIN_WIDTH: Int32 = 400
public let CHAT_MIN_HEIGHT: Int32 = 300
public let INPUT_HEIGHT: Int32 = 80

public func buildLoginWindowStyleSheet(): String {
    "QWidget { background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 ${LOGIN_BG_GRADIENT_TOP}, stop:1 ${LOGIN_BG_GRADIENT_BOTTOM}); border: 1px solid ${XP_BORDER_COLOR}; border-radius: ${XP_BORDER_RADIUS}; }"
}

public func buildGroupHeaderStyleSheet(): String {
    "QWidget { background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 ${GROUP_HEADER_GRADIENT_TOP}, stop:1 ${GROUP_HEADER_GRADIENT_BOTTOM}); padding: 4px; }"
}

public func buildChatToolBarStyleSheet(): String {
    "QToolBar { background: ${TOOLBAR_BG_COLOR}; spacing: 4px; padding: 2px; border: none; }"
}

public func buildFriendPanelTitleBarStyleSheet(): String {
    "QWidget { background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 ${GROUP_HEADER_GRADIENT_TOP}, stop:1 ${GROUP_HEADER_GRADIENT_BOTTOM}); }"
}