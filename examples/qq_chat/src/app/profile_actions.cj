// ============================================================
// QQ聊天 - 个人资料操作模块
// 提供修改昵称、修改头像两个操作的 UI 交互逻辑。
// ============================================================
package qq_chat.app

import cjqt6.core.*
import cjqt6.dialogs.*
import cjqt6.widgets.*
import std.fs.*
import qq_chat.core.*
import qq_chat.state.*
import qq_chat.ui.*

/// 修改当前用户昵称：输入框预填当前昵称 → 校验非空 → 更新数据库 → 同步内存与 UI。
public func doChangeDisplayName(): Unit {
    if (let Some(u) <- gCurrentUser) {
        // 弹出输入框，预填当前昵称
        let (newName, ok) = QInputDialog.getTextWithResult(0, "修改昵称", "请输入新昵称：", u.displayName)
        if (!ok) { return }
        if (newName.isEmpty()) {
            QMessageBox.warning(0, "提示", "昵称不能为空")
            return
        }
        if (let Some(db) <- gDb) {
            if (db.updateDisplayName(u.id, newName)) {
                // 同步更新内存中的用户信息
                u.displayName = newName
                // 同步更新主窗口标题
                if (let Some(mw) <- gMainWindow) {
                    mw.setTitle("QQ聊天 - ${newName}")
                }
                QMessageBox.information(0, "成功", "昵称修改成功")
            } else {
                QMessageBox.warning(0, "错误", "昵称修改失败，请重试。")
            }
        }
    }
}

/// 修改当前用户头像：选择图片文件 → 校验大小(≤2MB) → 复制到 avatars/ 目录 → 更新数据库。
public func doChangeAvatar(): Unit {
    if (let Some(u) <- gCurrentUser) {
        let path = QFileDialog.getOpenFileName(0, "选择头像", "图片文件 (*.png *.jpg *.jpeg *.bmp *.gif);;所有文件 (*)")
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
                QMessageBox.warning(0, "错误", "头像文件过大（限 2MB）")
                return
            }
        } catch (_: Exception) {
            // 文件读取失败，跳过大小检查
        }
        // 构造目标路径：avatars/user_{userId}_{timestamp}.ext
        let now = getNowString()
        let ext = extractFileExt(path)
        let destDir = Path("avatars")
        // 确保 avatars 目录存在
        if (!exists(destDir)) {
            Directory.create(destDir, recursive: true)
        }
        let safeNow = now.replace(" ", "_").replace(":", "")
        let destPath = "avatars/user_${u.id}_${safeNow}.${ext}"
        // 复制文件到 avatars 目录
        copy(Path(path), to: Path(destPath), overwrite: true)
        // 更新数据库中的头像路径
        if (let Some(db) <- gDb) {
            if (db.updateAvatarPath(u.id, destPath)) {
                u.avatarPath = destPath
                // 刷新好友列表
                refreshFriendList()
                QMessageBox.information(0, "成功", "头像修改成功")
            } else {
                QMessageBox.warning(0, "错误", "头像更新失败，请重试。")
            }
        }
    }
}

/// 从文件路径中提取扩展名（最后一个 . 之后的部分）。
public func extractFileExt(path: String): String {
    var lastDot: Int64 = -1
    var i: Int64 = 0
    while (i < path.size) {
        if (path[i] == 46) { lastDot = i }  // '.'=46
        i++
    }
    if (lastDot >= 0 && lastDot + 1 < path.size) {
        path[(lastDot + 1)..path.size]
    } else {
        "png"
    }
}
