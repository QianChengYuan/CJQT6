package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.widgets.*

// ============================================================
// Toast - 轻提示
// 纯仓颉组合层：QLabel 显示文案 + QTimer 倒计时自动消失
// ============================================================

/// 轻提示：显示一条短暂消息，倒计时结束后自动消失
///
/// **线程要求**：Toast 会创建并显示一个**顶层窗口**（裸 `QLabel`），因此 `show()`
/// 必须在 `QApplication` 所属线程调用（非 GUI 线程抛 `GuiThreadViolationException`）。
///
/// **销毁不再要求同线程**（P1-5 根治）：桥接层所有 `qXxxDelete` 统一走
/// `cjqt6SafeDelete`，非对象所属线程的删除改为 `deleteLater()` 排队到对象所属线程
/// 执行，不再同步触发 `QWindow::close()` 的 flush 等待（见 `native/includes/bridge_delete.h`）。
/// 因此 `close()` 可在任意线程调用。
public class Toast {
    private let label: QLabel
    private let timer: QTimer
    // 回调连接延迟到 show() 注册：init 阶段成员尚未全部初始化，
    // 闭包内调用 close() 会触发仓颉「成员未完成初始化」编译错误。
    private var conn: ?SignalConnection = None
    private var registered: Bool = false
    private var closed: Bool = false
    // 连接与计时器是否已释放。释放动作**只能在回调之外**发生（见 P1-5）：
    // 在自己的 timeout 回调里 disconnect() / 删除自身 QTimer，会让正在派发的
    // 事件源在自己的回调执行期间被销毁（悬垂），表现为用例挂起。
    private var released: Bool = false

    /// 创建提示（默认隐藏，调用 show() 后显示并开始倒计时）
    public init(message: String, durationMs: Int32) {
        label = QLabel()
        label.setText(message)
        label.setStyleSheet("background-color:#323232; color:#ffffff; padding:8px 16px; border-radius:4px;")
        timer = QTimer()
        timer.setInterval(durationMs)
    }

    /// 显示并开始倒计时（首次调用时注册自动关闭回调）
    /// throws: GuiThreadViolationException 在非 QApplication 所属线程调用时抛出
    ///   （顶层窗口的创建/显示必须在 app 所属线程；销毁路径已由桥接层兜底，见 P1-5）
    public func show(): Unit {
        checkGuiThread("Toast.show")
        if (closed || released) {
            // 底层 label/timer 已释放，实例不可复用
            return
        }
        if (!registered) {
            // 回调只做最小工作（见 handleTimeout）：不得 disconnect()，也不得关闭自身 QTimer
            conn = Some(timer.setOnTimeoutCapture({=> handleTimeout()}))
            registered = true
        }
        label.show()
        timer.start()
    }

    /// 倒计时到点：停表 + 关闭标签 + 置标志。
    /// **不得**在此调用 `close()` / `disconnect()` / `timer.close()`——
    /// 那会在自己的回调内销毁正在派发的事件源（P1-5）。
    /// 关闭顶层窗口本身是安全的：桥接层按线程归属决定「立即 delete」或「deleteLater」。
    private func handleTimeout(): Unit {
        if (!closed) {
            timer.stop()
            label.close()
            closed = true
        }
    }

    /// 立即关闭（幂等；倒计时结束也会自动调用）。
    /// 释放动作由**回调之外**的调用触发；回调内已置 `closed` 时，这里仍会完成释放。
    /// **可在任意线程调用**：对象销毁已由桥接层按线程归属兜底（P1-5 根治）。
    public func close(): Unit {
        if (!closed) {
            timer.stop()
            label.close()
            closed = true
        }
        release()
    }

    /// 释放连接与计时器（幂等）。**只能在回调之外调用**（P1-5）
    private func release(): Unit {
        if (released) {
            return
        }
        released = true
        if (let Some(c) <- conn) {
            c.disconnect()
            conn = None
        }
        timer.close()
    }

    /// 是否已关闭
    public func isClosed(): Bool {
        closed
    }

    // ============================================================
    // 静态便捷入口（见 docs/internal/cjmonitor-findings.md P1-4）
    // 此前 Toast 只能「构造 + 实例 show()」，告警/提示场景必须由调用方
    // 自行持实例与做节流。以下入口把「持有最近实例」与「同内容时间窗去重」
    // 收进组件层，不引入任何新依赖（去重窗口用一个独立 QTimer 承载）。
    // ============================================================

    /// 最近一次通过静态入口显示的提示（保持引用，避免倒计时期间被回收）
    private static var latest: ?Toast = None

    /// 去重窗口内已显示过的文案（空串表示窗口已过期）
    private static var lastMessage: String = ""

    /// 去重窗口计时器
    private static var dedupTimer: ?QTimer = None

    /// 显示一条普通提示
    public static func info(message: String, durationMs!: Int32 = 2000): Unit {
        showStatic(message, durationMs)
    }

    /// 显示一条警告提示
    public static func warning(message: String, durationMs!: Int32 = 2000): Unit {
        showStatic(message, durationMs)
    }

    /// 显示一条成功提示
    public static func success(message: String, durationMs!: Int32 = 2000): Unit {
        showStatic(message, durationMs)
    }

    /// 带内容去重的提示：同一 message 在 windowMs 内只显示一次。
    /// windowMs 到期后记录自动清空，相同文案可再次显示。
    public static func showThrottled(message: String, windowMs!: Int32 = 5000, durationMs!: Int32 = 2000): Unit {
        if (message == lastMessage) {
            return
        }
        lastMessage = message
        // 上一次窗口的计时器在此处（回调之外）关闭，是安全的
        if (let Some(prevTimer) <- dedupTimer) {
            prevTimer.close()
        }
        let timer = QTimer()
        timer.setInterval(windowMs)
        dedupTimer = Some(timer)
        // 只引用静态成员，不捕获局部变量。
        // 注意：回调内只复位状态、不释放任何 Qt 对象——释放统一走 close()（P1-5）。
        // 这里只复位窗口状态并停止计时，计时器实例留待下次调用统一关闭。
        timer.setOnTimeoutCapture(
            {
                =>
                    lastMessage = ""
                    if (let Some(t) <- dedupTimer) {
                        t.stop()
                    }
            }
        )
        timer.start()
        showStatic(message, durationMs)
    }

    /// 关闭并释放最近一条静态提示（幂等）。
    /// 用途：退出前清理，或手动打断当前提示；同时复位去重窗口。
    public static func clear(): Unit {
        if (let Some(t) <- latest) {
            t.close()
        }
        latest = None
        if (let Some(dt) <- dedupTimer) {
            dt.stop()
            dt.close()
        }
        dedupTimer = None
        lastMessage = ""
    }

    /// 内部：创建并显示一条提示，替换掉上一条
    private static func showStatic(message: String, durationMs: Int32): Unit {
        if (let Some(prev) <- latest) {
            prev.close()
        }
        let toast = Toast(message, durationMs)
        latest = Some(toast)
        toast.show()
    }
}
