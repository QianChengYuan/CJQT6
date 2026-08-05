// ============================================================
// QQ局域网聊天 - 图片/文件发送与消息撤回
// 发送：QFileDialog 选文件 -> 读字节 -> base64 分块 -> file_begin/chunk/end
// 撤回：对每个会话记录最后一条已确认消息 ID，点"撤回"发送 recall 帧
// ============================================================
package qq_lan_client.app

import cjqt6.core.*
import cjqt6.dialogs.*
import std.fs.*
import qq_lan_client.core.*
import qq_lan_client.state.*

let onImageClick: VoidCallback = { => pickAndSend(true) }
let onFileClick: VoidCallback = { => pickAndSend(false) }
let onRecallClick: VoidCallback = { => doRecallLast() }

/// 从路径提取文件名
public func extractFileName(path: String): String {
    var lastSlash: Int64 = -1
    var i: Int64 = 0
    while (i < path.size) {
        let ch = path[i]
        if (ch == 47 || ch == 92) { lastSlash = i }  // '/'=47 '\'=92
        i++
    }
    if (lastSlash >= 0 && lastSlash + 1 < path.size) {
        path[(lastSlash + 1)..path.size]
    } else {
        path
    }
}

/// 选择并发送图片/文件
public func pickAndSend(isImage: Bool): Unit {
    if (gCurrentChatId == 0) { return }
    let filter = if (isImage) {
        "图片 (*.png *.jpg *.jpeg *.gif *.bmp)"
    } else {
        "所有文件 (*)"
    }
    let path = QFileDialog.getOpenFileName(0, "选择文件", filter)
    if (path.isEmpty()) { return }

    var data: Array<Byte> = []
    try {
        data = File.readFrom(Path(path))
    } catch (_: Exception) {
        QMessageBox.warning(0, "提示", "读取文件失败")
        return
    }
    let size = data.size
    let maxSize = if (isImage) { 2 * 1024 * 1024 } else { 50 * 1024 * 1024 }
    if (size == 0 || size > maxSize) {
        QMessageBox.warning(0, "提示", "文件大小超出限制（图片2MB / 文件50MB）")
        return
    }

    let name = extractFileName(path)
    let kind = if (isImage) { "image" } else { "file" }
    gSendCounter++
    var selfAccount: Int64 = 0
    if (let Some(s) <- gSelf) { selfAccount = s.account }
    let tid = "${selfAccount}_${gSendCounter}"

    sendRaw("{\"type\":\"file_begin\",\"to\":${gCurrentChatId},\"tid\":\"${tid}\"," +
        "\"name\":\"${escapeJson(name)}\",\"size\":${size},\"kind\":\"${kind}\"}")

    // base64 分块发送
    let CHUNK: Int64 = 48 * 1024
    var off: Int64 = 0
    var seq: Int64 = 0
    while (off < size) {
        let end = if (off + CHUNK < size) { off + CHUNK } else { size }
        let b64 = base64Encode(data[off..end])
        sendRaw("{\"type\":\"file_chunk\",\"to\":${gCurrentChatId},\"tid\":\"${tid}\"," +
            "\"seq\":${seq},\"data\":\"${b64}\"}")
        off = end
        seq++
    }
    sendRaw("{\"type\":\"file_end\",\"to\":${gCurrentChatId},\"tid\":\"${tid}\"}")

    // 本地回显
    let m = ChatMsg()
    if (let Some(s) <- gSelf) { m.fromId = s.id; m.fromName = s.nickname }
    m.kind = kind
    m.fileName = name
    m.fileSize = size
    m.localPath = path
    m.time = nowString()
    m.outgoing = true
    appendHistory(gCurrentChatId, m)
    appendBubble(m)
}

/// 撤回当前会话最后一条已确认消息
public func doRecallLast(): Unit {
    if (gCurrentChatId == 0) { return }
    match (gLastSentId.get(gCurrentChatId)) {
        case Some(msgId) =>
            sendRaw("{\"type\":\"recall\",\"msgId\":${msgId}}")
        case None =>
            QMessageBox.information(0, "提示", "没有可撤回的消息")
    }
}
