// ============================================================
// QQ局域网聊天 - 客户端入口
// 模块结构：
//   qq_lan_client.core   - 数据模型 + JSON 协议工具（src/core/）
//   qq_lan_client.state  - 全局状态（src/state/）
//   qq_lan_client.app    - 网络层 + 界面 + 帧分发（src/app/）
// 使用：先启动 qq_lan_server，再运行本程序填写服务器地址登录。
// ============================================================
package qq_lan_client

import cjqt6.core.*
import std.fs.*
import qq_lan_client.state.*
import qq_lan_client.app.*

main(): Int32 {
    let app = QApplication()
    gApp = app

    // 接收文件目录：<当前目录>/recv
    try {
        gRecvDir = canonicalize(Path(".")).join("recv").toString()
    } catch (_: Exception) {
        gRecvDir = "recv"
    }

    // 登录窗口
    let loginPage = buildLoginUI()
    gLoginWindow = loginPage
    loginPage.show()

    let result = app.exec()

    // 退出清理：关闭套接字与各窗口
    closeSocketQuiet()
    closeRegisterDialog()
    closeAddFriendDialog()
    result
}
