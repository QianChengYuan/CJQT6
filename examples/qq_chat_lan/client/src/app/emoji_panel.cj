// ============================================================
// QQ局域网聊天 - 表情面板
// 点击表情插入到聊天输入框末尾。5 列网格布局。
// ============================================================
package qq_lan_client.app

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import qq_lan_client.state.*

/// 内置常用表情（20 个）
let EMOJI_LIST: Array<String> = [
    "😀", "😂", "🥰", "^_^", "🤔",
    "👍", "❤", "🎉", "😊", "😢",
    "🥺", "😴", "🙏", "💪", "✌",
    "😀", "😂", "🥰", "😎", "🤔"
]

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

let EMOJI_CALLBACKS: Array<VoidCallback> = [
    onEmoji0, onEmoji1, onEmoji2, onEmoji3, onEmoji4,
    onEmoji5, onEmoji6, onEmoji7, onEmoji8, onEmoji9,
    onEmoji10, onEmoji11, onEmoji12, onEmoji13, onEmoji14,
    onEmoji15, onEmoji16, onEmoji17, onEmoji18, onEmoji19
]

/// 工具栏"表情"按钮回调：打开表情面板
let onEmojiClick: VoidCallback = { => showEmojiPanel() }

/// 显示表情面板（复用同一窗口）
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

    var row: Int32 = 0
    var col: Int32 = 0
    var idx: Int32 = 0
    while (Int64(idx) < EMOJI_LIST.size && Int64(idx) < EMOJI_CALLBACKS.size) {
        let btn = QPushButton()
        btn.setText(EMOJI_LIST[Int64(idx)])
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

/// 将表情追加到输入框，并关闭表情面板
public func insertEmoji(emoji: String): Unit {
    if (let Some(input) <- gChatInput) {
        input.setText(input.text() + emoji)
    }
    closeEmojiPanel()
}

/// 关闭表情面板
public func closeEmojiPanel(): Unit {
    if (let Some(panel) <- gEmojiPanel) {
        panel.hide()
    }
}
