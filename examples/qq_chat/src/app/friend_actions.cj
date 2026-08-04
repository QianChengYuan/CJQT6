// ============================================================
// QQ聊天 - 好友操作模块
// 提供删除好友、修改好友备注两个操作的 UI 交互逻辑。
// 操作前校验当前是否选中好友，操作后刷新好友列表。
// ============================================================
package qq_chat.app

import cjqt6.core.*
import cjqt6.dialogs.*
import cjqt6.views.*
import qq_chat.core.*
import qq_chat.state.*

/// 删除当前选中的好友：确认弹窗 → 双向删除好友关系 → 刷新列表。
/// 未选中好友时提示"请先选择好友"。
public func doDeleteFriend(): Unit {
    // 校验：当前是否选中了好友
    if (gCurrentFriendId <= 0) {
        QMessageBox.warning(0, "提示", "请先在左侧选择要操作的好友")
        return
    }
    // 获取好友显示名
    let friendName = getFriendDisplayName()
    // 确认弹窗
    let confirmed = QMessageBox.question(0, "确认删除", "确定要删除好友「${friendName}」吗？\n删除后可重新添加，历史消息保留。")
    if (!confirmed) { return }
    // 执行删除
    if (let Some(db) <- gDb) {
        if (let Some(u) <- gCurrentUser) {
            if (db.deleteFriend(u.id, gCurrentFriendId)) {
                // 删除成功，清空当前选中并刷新列表
                gCurrentFriendId = 0
                refreshFriendList()
                // 清空聊天记录区
                if (let Some(edit) <- gChatHistory) {
                    edit.clear()
                }
                QMessageBox.information(0, "成功", "已删除好友「${friendName}」")
            } else {
                QMessageBox.warning(0, "错误", "删除失败，请重试。")
            }
        }
    }
}

/// 修改当前选中好友的备注：输入框获取新备注 → 更新数据库 → 刷新列表。
/// 未选中好友时提示；空备注表示清除备注，回退显示昵称。
public func doModifyRemark(): Unit {
    // 校验：当前是否选中了好友
    if (gCurrentFriendId <= 0) {
        QMessageBox.warning(0, "提示", "请先在左侧选择要操作的好友")
        return
    }
    // 获取当前备注作为预填值
    var currentRemark = ""
    for (f in gFriendCache) {
        if (f.friendId == gCurrentFriendId) {
            currentRemark = f.remark
        }
    }
    // 弹出输入框获取新备注（使用 getTextWithResult 区分取消和空输入）
    let (newRemark, ok) = QInputDialog.getTextWithResult(0, "修改备注", "请输入新备注（留空则清除备注）：", currentRemark)
    if (!ok) { return }
    // 执行修改
    if (let Some(db) <- gDb) {
        if (let Some(u) <- gCurrentUser) {
            if (db.updateFriendRemark(u.id, gCurrentFriendId, newRemark)) {
                refreshFriendList()
            } else {
                QMessageBox.warning(0, "错误", "备注修改失败，请重试。")
            }
        }
    }
}