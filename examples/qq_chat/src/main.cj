// ============================================================
// QQ聊天 - 主入口
// 单机版：登录 / 好友列表 / 消息收发（SQLite 存储）
// 模块结构：
//   qq_chat.core   - 数据模型 + 数据库管理（src/core/）
//   qq_chat.state  - 全局状态（src/state/）
//   qq_chat.ui     - 头像绘制（src/ui/）
//   qq_chat.app    - 界面与业务逻辑（src/app/）
// ============================================================
package qq_chat

import cjqt6.core.*
import cjqt6.sql.*
import qq_chat.core.*
import qq_chat.state.*
import qq_chat.app.*

main(): Int32 {
    let app = QApplication()
    gApp = app

    gScaleFactor = QScreen.scaleFactor()

    let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "qq_chat")
    db.setDatabaseName("qq_chat.db")
    if (!db.open()) {
        return 1
    }
    gDb = DatabaseManager(db)

    let loginPage = buildLoginUI()
    gLoginWindow = loginPage
    loginPage.show()

    let result = app.exec()

    closeEmojiPanel()
    closeRegisterDialog()
    closeChangePwdDialog()
    closeAddFriendDialog()
    if (let Some(d) <- gDb) {
        d.close()
    }
    db.close()
    db.delete()
    return result
}
