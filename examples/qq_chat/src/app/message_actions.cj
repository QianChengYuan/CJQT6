// ============================================================
// QQ聊天 - 消息操作模块
// 提供清空聊天记录、撤回消息、发送图片、发送文件等操作的 UI 交互逻辑。
// ============================================================
package qq_chat.app

import cjqt6.core.*
import cjqt6.dialogs.*
import cjqt6.views.*
import std.fs.*
import qq_chat.core.*
import qq_chat.state.*

/// 清空当前会话的聊天记录：确认弹窗 → 删除数据库消息 → 刷新聊天区。
public func doClearChatHistory(): Unit {
    if (gCurrentFriendId <= 0) {
        QMessageBox.warning(0, "提示", "请先选择聊天对象")
        return
    }
    let friendName = getFriendDisplayName()
    let confirmed = QMessageBox.question(0, "确认清空", "确定要清空与「${friendName}」的聊天记录吗？\n此操作不可恢复。")
    if (!confirmed) { return }
    if (let Some(db) <- gDb) {
        if (let Some(u) <- gCurrentUser) {
            if (db.clearMessages(u.id, gCurrentFriendId)) {
                refreshChatHistory()
                QMessageBox.information(0, "成功", "聊天记录已清空")
            } else {
                QMessageBox.warning(0, "错误", "清空失败，请重试。")
            }
        }
    }
}

/// 撤回最后一条自己发送的消息：查找最后一条 → 校验时间 → 标记撤回 → 刷新。
public func doRecallLastMessage(): Unit {
    if (gCurrentFriendId <= 0) {
        QMessageBox.warning(0, "提示", "请先选择聊天对象")
        return
    }
    if (let Some(db) <- gDb) {
        if (let Some(u) <- gCurrentUser) {
            let msgs = db.getMessages(u.id, gCurrentFriendId)
            var lastMyMsgId: Int64 = 0
            for (m in msgs) {
                if (m.senderId == u.id && m.isRecalled == 0) {
                    lastMyMsgId = m.id
                }
            }
            if (lastMyMsgId <= 0) {
                QMessageBox.warning(0, "提示", "没有可撤回的消息")
                return
            }
            if (db.recallMessage(lastMyMsgId, u.id)) {
                refreshChatHistory()
            } else {
                QMessageBox.warning(0, "提示", "撤回失败：仅支持撤回2分钟内自己发送的消息")
            }
        }
    }
}

/// 发送图片消息：打开文件选择对话框 → 校验大小(≤2MB) → 存库 → 刷新聊天区。
public func doSendImage(): Unit {
    if (gCurrentFriendId <= 0) {
        QMessageBox.warning(0, "提示", "请先选择聊天对象")
        return
    }
    let path = QFileDialog.getOpenFileName(0, "选择图片", "图片文件 (*.png *.jpg *.jpeg *.bmp *.gif *.webp);;所有文件 (*)")
    if (path.isEmpty()) { return }
    if (!exists(Path(path))) {
        QMessageBox.warning(0, "错误", "文件不存在")
        return
    }
    // 校验文件大小 ≤ 2MB
    try (f = File(Path(path), Read)) {
        let fileInfo = f.info
        let fileSize = fileInfo.size
        if (fileSize > 2 * 1024 * 1024) {
            QMessageBox.warning(0, "错误", "图片文件过大（限 2MB）")
            return
        }
    } catch (_: Exception) {
        // 文件读取失败，跳过大小检查
    }
    // 发送图片消息
    if (let Some(db) <- gDb) {
        if (let Some(u) <- gCurrentUser) {
            let msgId = db.addImageMessage(u.id, gCurrentFriendId, path)
            if (msgId > 0) {
                refreshChatHistory()
            } else {
                QMessageBox.warning(0, "错误", "图片发送失败")
            }
        }
    }
}

/// 发送文件消息：打开文件选择对话框 → 校验大小(≤50MB) → 存库 → 刷新聊天区。
public func doSendFile(): Unit {
    if (gCurrentFriendId <= 0) {
        QMessageBox.warning(0, "提示", "请先选择聊天对象")
        return
    }
    let path = QFileDialog.getOpenFileName(0, "选择文件", "所有文件 (*)")
    if (path.isEmpty()) { return }
    if (!exists(Path(path))) {
        QMessageBox.warning(0, "错误", "文件不存在")
        return
    }
    // 校验文件大小 ≤ 50MB
    try (f = File(Path(path), Read)) {
        let fileInfo = f.info
        let fileSize = fileInfo.size
        if (fileSize > 50 * 1024 * 1024) {
            QMessageBox.warning(0, "错误", "文件过大（限 50MB）")
            return
        }
    } catch (_: Exception) {
        // 文件读取失败，跳过大小检查
    }
    if (let Some(db) <- gDb) {
        if (let Some(u) <- gCurrentUser) {
            let msgId = db.addFileMessage(u.id, gCurrentFriendId, path)
            if (msgId > 0) {
                refreshChatHistory()
            } else {
                QMessageBox.warning(0, "错误", "文件发送失败")
            }
        }
    }
}
