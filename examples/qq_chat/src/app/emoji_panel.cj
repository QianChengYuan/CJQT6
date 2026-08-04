// ============================================================
// QQ聊天 - 表情面板模块
// 提供常用表情选择面板，点击表情后插入到消息输入框光标位置。
// 面板使用 QGridLayout 布局，5 列排列，内置 20+ 常用 emoji。
// ============================================================
package qq_chat.app

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import qq_chat.state.*

/// 内置常用表情列表（20 个）
let EMOJI_LIST: Array<String> = [
    "😀", "😂", "🥰", "😎", "🤔",
    "👍", "👎", "❤", "🎉", "🔥",
    "😊", "😢", "😡", "🥺", "😴",
    "🙏", "💪", "✌", "🤝", "👋"
]

/// 表情按钮点击回调列表（顶层 let，避免 CFunc 捕获问题）
let onEmoji0: VoidCallback = { => insertEmoji(EMOJI_LIST[0]) }
let onEmoji1: VoidCallback = { => insertEmoji(EMOJI_LIST[1]) }
let onEmoji2: VoidCallback = { => insertEmoji(EMOJI_LIST[2]) }
let onEmoji3: VoidCallback = { => insertEmoji(EMOJI_LIST[3]) }
let onEmoji4: VoidCallback = { => insertEmoji(EMOJI_LIST[4]) }
let onEmoji5: VoidCallback = { => insertEmoji(EMOJI_LIST[5]) }
let onEmoji6: VoidCallback = { => insertEmoji(EMOJI_LIST[6]) }
let onEmoji7: VoidCallback = { => insertEmoji(EMOJI_LIST[7]) }
let onEmoji8: VoidCallback = { => insertEmoji(EMOJI_LIST[8]) }
let onEmoji9: VoidCallback = { => insertEmoji(EMOJI_LIST[9]) }
let onEmoji10: VoidCallback = { => insertEmoji(EMOJI_LIST[10]) }
let onEmoji11: VoidCallback = { => insertEmoji(EMOJI_LIST[11]) }
let onEmoji12: VoidCallback = { => insertEmoji(EMOJI_LIST[12]) }
let onEmoji13: VoidCallback = { => insertEmoji(EMOJI_LIST[13]) }
let onEmoji14: VoidCallback = { => insertEmoji(EMOJI_LIST[14]) }
let onEmoji15: VoidCallback = { => insertEmoji(EMOJI_LIST[15]) }
let onEmoji16: VoidCallback = { => insertEmoji(EMOJI_LIST[16]) }
let onEmoji17: VoidCallback = { => insertEmoji(EMOJI_LIST[17]) }
let onEmoji18: VoidCallback = { => insertEmoji(EMOJI_LIST[18]) }
let onEmoji19: VoidCallback = { => insertEmoji(EMOJI_LIST[19]) }

/// 表情回调数组
let EMOJI_CALLBACKS: Array<VoidCallback> = [
    onEmoji0, onEmoji1, onEmoji2, onEmoji3, onEmoji4,
    onEmoji5, onEmoji6, onEmoji7, onEmoji8, onEmoji9,
    onEmoji10, onEmoji11, onEmoji12, onEmoji13, onEmoji14,
    onEmoji15, onEmoji16, onEmoji17, onEmoji18, onEmoji19
]

/// 显示表情面板：创建弹窗 + 网格布局 + 表情按钮。
/// 防止重复创建：若 gEmojiPanel 非 None 则置前而非新建。
public func showEmojiPanel(): Unit {
    if (let Some(panel) <- gEmojiPanel) {
        panel.show()
        return
    }

    let panel = QWidget()
    panel.setTitle("选择表情")
    panel.resize(280, 180)
    gEmojiPanel = panel

    let layout = QGridLayout()
    layout.setMargin(8)
    layout.setSpacing(4)

    // 按行排列表情按钮，每行5个
    var row: Int32 = 0
    var col: Int32 = 0
    var idx: Int32 = 0
    while (Int64(idx) < EMOJI_LIST.size && Int64(idx) < EMOJI_CALLBACKS.size) {
        let emoji = EMOJI_LIST[Int64(idx)]
        let btn = QPushButton()
        btn.setText(emoji)
        btn.setStyleSheet("font-size: 20px; border: none; padding: 4px;")
        btn.setOnClick(EMOJI_CALLBACKS[Int64(idx)])
        layout.addWidget(btn.getPtr(), row, col)
        col++
        if (col >= 5) {
            col = 0
            row++
        }
        idx++
    }

    panel.setLayout(layout.getPtr())
    panel.show()
}

/// 将表情文本插入到消息输入框当前光标位置。
public func insertEmoji(emoji: String): Unit {
    if (let Some(input) <- gChatInput) {
        let currentText = input.text()
        input.setText(currentText + emoji)
    }
}

/// 关闭表情面板并释放资源。
public func closeEmojiPanel(): Unit {
    if (let Some(panel) <- gEmojiPanel) {
        panel.hide()
        panel.delete()
        gEmojiPanel = None
    }
}
