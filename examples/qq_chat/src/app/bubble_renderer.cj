// ============================================================
// QQ聊天 - 聊天气泡渲染模块
// 使用 HTML + CSS 浮动布局实现左右对齐的聊天气泡，
// 区分发送(右/绿色)和接收(左/白色)方向，
// 支持文本、图片、文件、撤回提示四种气泡类型。
// ============================================================
package qq_chat.app

import qq_chat.core.*

/// 构建聊天气泡 HTML：根据消息方向（发送/接收）生成不同样式的气泡。
/// message: 消息对象, currentUserId: 当前登录用户ID, friendName: 好友显示名
/// 发送气泡：右对齐，背景色 #95EC69（微信绿）
/// 接收气泡：左对齐，背景色 #FFFFFF（白色）带边框
public func buildBubbleHtml(message: Message, currentUserId: Int64, friendName: String): String {
    let isSender = message.senderId == currentUserId
    let senderName = if (isSender) { "我" } else { friendName }
    let timeStr = classicFormatTimestamp(message.sendTime)
    let content = escapeHtml(message.content)

    if (isSender) {
        "<div style='display:flex;justify-content:flex-end;margin:4px 0;'>" +
        "<div style='max-width:70%;background-color:${CLASSIC_SELF_BUBBLE_COLOR};border-radius:8px;" +
        "padding:8px 12px;margin-right:8px;'>" +
        "<div style='font-size:11px;color:#888;margin-bottom:2px;'>${senderName} ${timeStr}</div>" +
        "<div style='font-size:14px;color:#333;word-wrap:break-word;'>${content}</div>" +
        "</div></div>"
    } else {
        // 接收气泡：左对齐，白色背景带边框
        "<div style='display:flex;justify-content:flex-start;margin:4px 0;'>" +
        "<div style='max-width:70%;background-color:#FFFFFF;border:1px solid #E0E0E0;" +
        "border-radius:8px;padding:8px 12px;margin-left:8px;'>" +
        "<div style='font-size:11px;color:#888;margin-bottom:2px;'>${senderName} ${timeStr}</div>" +
        "<div style='font-size:14px;color:#333;word-wrap:break-word;'>${content}</div>" +
        "</div></div>"
    }
}

/// 构建撤回消息提示 HTML：居中灰色斜体提示。
/// senderName: 撤回者的显示名
public func buildRecalledHtml(senderName: String): String {
    "<div style='text-align:center;color:#999;font-size:12px;font-style:italic;margin:8px 0;'>" +
    "${senderName} 撤回了一条消息</div>"
}

/// 构建图片消息气泡 HTML：包含缩略图。
/// message: 消息对象（content 为图片路径）, isSender: 是否为发送方
public func buildImageBubbleHtml(message: Message, isSender: Bool): String {
    let timeStr = classicFormatTimestamp(message.sendTime)
    let imagePath = message.content
    let align = if (isSender) { "flex-end" } else { "flex-start" }
    let bgColor = if (isSender) { CLASSIC_SELF_BUBBLE_COLOR } else { "#FFFFFF" }
    let border = if (isSender) { "" } else { "border:1px solid #E0E0E0;" }
    let margin = if (isSender) { "margin-right:8px;" } else { "margin-left:8px;" }

    "<div style='display:flex;justify-content:${align};margin:4px 0;'>" +
    "<div style='background-color:${bgColor};${border}border-radius:8px;" +
    "padding:8px 12px;${margin}'>" +
    "<div style='font-size:11px;color:#888;margin-bottom:2px;'>${timeStr}</div>" +
    "<img src='file:///${imagePath}' width='200' style='border-radius:4px;'/>" +
    "</div></div>"
}

/// 构建文件消息气泡 HTML：显示文件名和大小提示。
/// message: 消息对象（content 为文件路径）, isSender: 是否为发送方
public func buildFileBubbleHtml(message: Message, isSender: Bool): String {
    let timeStr = classicFormatTimestamp(message.sendTime)
    let filePath = message.content
    let fileName = extractFileName(filePath)
    let align = if (isSender) { "flex-end" } else { "flex-start" }
    let bgColor = if (isSender) { CLASSIC_SELF_BUBBLE_COLOR } else { "#FFFFFF" }
    let border = if (isSender) { "" } else { "border:1px solid #E0E0E0;" }
    let margin = if (isSender) { "margin-right:8px;" } else { "margin-left:8px;" }

    "<div style='display:flex;justify-content:${align};margin:4px 0;'>" +
    "<div style='background-color:${bgColor};${border}border-radius:8px;" +
    "padding:8px 12px;${margin}'>" +
    "<div style='font-size:11px;color:#888;margin-bottom:2px;'>${timeStr}</div>" +
    "<div style='font-size:14px;color:#333;'>&#128206; ${fileName}</div>" +
    "</div></div>"
}

/// HTML 特殊字符转义：防止消息内容中的 < > & " 破坏 HTML 结构。
public func escapeHtml(text: String): String {
    var result = text
    result = result.replace("&", "&amp;")
    result = result.replace("<", "&lt;")
    result = result.replace(">", "&gt;")
    result = result.replace("\"", "&quot;")
    result
}

/// 从文件路径中提取文件名（最后一个 / 或 \ 之后的部分）。
public func extractFileName(path: String): String {
    var lastSlash: Int64 = -1
    var i: Int64 = 0
    while (i < path.size) {
        let ch = path[i]
        if (ch == 47 || ch == 92) {  // '/'=47, '\\'=92
            lastSlash = i
        }
        i++
    }
    if (lastSlash >= 0 && lastSlash + 1 < path.size) {
        path[(lastSlash + 1)..path.size]
    } else {
        path
    }
}