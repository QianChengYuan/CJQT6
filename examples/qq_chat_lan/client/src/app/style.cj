// ============================================================
// QQ局域网聊天 - 客户端样式与头像、气泡
// 视觉沿用 qq_chat 经典 QQ 风格：深蓝登录背景、浅蓝发送气泡。
// ============================================================
package qq_lan_client.app

import cjqt6.paint.*
import cjqt6.gui.*

// --------------------------------------------------------
// 样式常量
// --------------------------------------------------------
public let LOGIN_BG_TOP = "#1A3A5C"
public let LOGIN_BG_BOTTOM = "#0D2137"
public let SELF_BUBBLE_COLOR = "#C0DEFF"
public let PANEL_TITLE_TOP = "#1E4D7A"
public let PANEL_TITLE_BOTTOM = "#0D3A5C"
public let MAIN_BG = "#F5F7FA"

public let LOGIN_WIDTH: Int32 = 400
public let LOGIN_HEIGHT: Int32 = 330
public let MAIN_WIDTH: Int32 = 320
public let MAIN_HEIGHT: Int32 = 560
public let CHAT_WIDTH: Int32 = 560
public let CHAT_HEIGHT: Int32 = 480
public let AVATAR_SIZE: Int32 = 32
public let BIG_AVATAR_SIZE: Int32 = 48

public func loginStyleSheet(): String {
    "QWidget { background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 ${LOGIN_BG_TOP}, stop:1 ${LOGIN_BG_BOTTOM}); }"
}

public func panelTitleStyleSheet(): String {
    "QWidget { background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 ${PANEL_TITLE_TOP}, stop:1 ${PANEL_TITLE_BOTTOM}); }"
}

// --------------------------------------------------------
// 头像绘制（移植自 qq_chat/ui/avatar.cj）
// --------------------------------------------------------

/// 生成圆形头像，返回 QPixmap（调用方负责 delete 释放）
public func createAvatarPixmap(r: Int32, g: Int32, b: Int32, text: String, size: Int32): QPixmap {
    let pm = QPixmap.withSize(size, size)
    let bg = QColor(r, g, b)
    pm.fill(bg)
    let painter = QPainter(pm.getPtr())
    let white = QColor(255, 255, 255)
    painter.setPenColor(white)
    painter.drawCircle(size / 2, size / 2, size / 2 - 2)
    painter.drawTextRect(0, 0, size, size, Alignment.Center.value, text)
    painter.end()
    bg.delete()
    white.delete()
    pm
}

/// 根据名字生成稳定的头像颜色（同名字同颜色）
public func colorFromName(name: String): (Int32, Int32, Int32) {
    var h: Int64 = 0
    for (c in name) {
        h = (h * 31 + Int64(UInt32(c))) & 0xFFFF
    }
    let palette: Array<(Int32, Int32, Int32)> = [
        (240, 74, 90), (54, 162, 235), (255, 159, 67), (104, 129, 224),
        (38, 194, 129), (255, 214, 79), (166, 92, 255), (0, 188, 212)
    ]
    let idx = h % palette.size
    palette[idx]
}

/// 取字符串首字符（空串返回 "?"）
public func firstCharOf(s: String): String {
    if (s.size > 0) { s[0].toString() } else { "?" }
}

// --------------------------------------------------------
// 聊天气泡 HTML（文本消息）
// --------------------------------------------------------

/// HTML 特殊字符转义
public func escapeHtml(text: String): String {
    var result = text
    result = result.replace("&", "&amp;")
    result = result.replace("<", "&lt;")
    result = result.replace(">", "&gt;")
    result = result.replace("\"", "&quot;")
    result
}

/// 构建聊天气泡 HTML
/// outgoing=true 时右对齐浅蓝气泡（我），否则左对齐白色气泡（对方）
public func buildBubbleHtml(text: String, time: String, outgoing: Bool, senderName: String): String {
    let content = escapeHtml(text)
    if (outgoing) {
        "<div style='display:flex;justify-content:flex-end;margin:4px 0;'>" +
        "<div style='max-width:70%;background-color:${SELF_BUBBLE_COLOR};border-radius:8px;" +
        "padding:8px 12px;margin-right:8px;'>" +
        "<div style='font-size:11px;color:#666;margin-bottom:2px;'>我 ${time}</div>" +
        "<div style='font-size:14px;color:#333;word-wrap:break-word;'>${content}</div>" +
        "</div></div>"
    } else {
        "<div style='display:flex;justify-content:flex-start;margin:4px 0;'>" +
        "<div style='max-width:70%;background-color:#FFFFFF;border:1px solid #E0E0E0;" +
        "border-radius:8px;padding:8px 12px;margin-left:8px;'>" +
        "<div style='font-size:11px;color:#888;margin-bottom:2px;'>${escapeHtml(senderName)} ${time}</div>" +
        "<div style='font-size:14px;color:#333;word-wrap:break-word;'>${content}</div>" +
        "</div></div>"
    }
}
