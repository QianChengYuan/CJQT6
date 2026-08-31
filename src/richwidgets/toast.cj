package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.widgets.*

// ============================================================
// Toast - 轻提示
// 纯仓颉组合层：QLabel 显示文案 + QTimer 倒计时自动消失
// ============================================================

/// 轻提示：显示一条短暂消息，倒计时结束后自动消失
public class Toast {
    private let label: QLabel
    private let timer: QTimer
    // 回调连接延迟到 show() 注册：init 阶段成员尚未全部初始化，
    // 闭包内调用 close() 会触发仓颉「成员未完成初始化」编译错误。
    private var conn: ?SignalConnection = None
    private var registered: Bool = false
    private var closed: Bool = false

    /// 创建提示（默认隐藏，调用 show() 后显示并开始倒计时）
    public init(message: String, durationMs: Int32) {
        label = QLabel()
        label.setText(message)
        label.setStyleSheet("background-color:#323232; color:#ffffff; padding:8px 16px; border-radius:4px;")
        timer = QTimer()
        timer.setInterval(durationMs)
    }

    /// 显示并开始倒计时（首次调用时注册自动关闭回调）
    public func show(): Unit {
        if (!registered) {
            conn = Some(timer.setOnTimeoutCapture({=> close()}))
            registered = true
        }
        label.show()
        timer.start()
    }

    /// 立即关闭（幂等；倒计时结束也会自动调用）
    public func close(): Unit {
        if (!closed) {
            timer.stop()
            if (let Some(c) <- conn) {
                c.disconnect()
            }
            label.close()
            timer.close()
            closed = true
        }
    }

    /// 是否已关闭
    public func isClosed(): Bool {
        closed
    }
}
