package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*

// ============================================================
// Countdown - 倒计时
// 纯仓颉组合层：QLabel 显示剩余秒数 + QTimer 每秒递减
// ============================================================

/// 倒计时：从指定秒数递减到 0，结束触发回调
public class Countdown <: QtResource {
    private let group: QGroupBox
    private let layout: QVBoxLayout
    private let label: QLabel
    private let timer: QTimer
    private var remaining: Int32 = 0
    private var finishedCb: ?(() -> Unit) = None
    private var registered: Bool = false

    /// 创建倒计时（指定秒数）
    public init(seconds: Int32) {
        group = QGroupBox()
        group.setFlat(true)
        layout = QVBoxLayout()
        label = QLabel()
        remaining = seconds
        if (remaining < 0) {
            remaining = 0
        }
        label.setText("${remaining}")
        label.setAlignment(HAlign.toAlignment(0)) // 居中
        label.setStyleSheet("color:#1890ff; font-size:20px; font-weight:bold;")
        timer = QTimer()
        timer.setInterval(1000) // 每秒触发
        layout.addWidget(label.getPtr())
        group.setLayout(layout.getPtr())
    }

    /// 开始倒计时（首次调用时注册回调，规避 init 成员未完成约束）
    public func start(): Unit {
        if (!registered) {
            timer.setOnTimeoutCapture({ => onTick() })
            registered = true
        }
        timer.start()
    }

    /// 暂停倒计时
    public func stop(): Unit {
        timer.stop()
    }

    /// 获取剩余秒数
    public func getRemaining(): Int32 {
        remaining
    }

    /// 倒计时结束回调（可捕获局部变量）
    public func setOnFinished(callback: () -> Unit): Unit {
        finishedCb = Some(callback)
    }

    // 内部：每秒递减
    private func onTick(): Unit {
        remaining = remaining - 1
        if (remaining <= 0) {
            remaining = 0
            timer.stop()
            label.setText("0")
            if (let Some(cb) <- finishedCb) {
                cb()
            }
        } else {
            label.setText("${remaining}")
        }
    }

    // ---- QtResource 接口委托给内部容器 ----
    public func getPtr(): Int64 {
        group.getPtr()
    }
    public func isClosed(): Bool {
        group.isClosed()
    }
    public func isValid(): Bool {
        group.isValid()
    }
    public func checkValid(): Unit {
        group.checkValid()
    }
    public func close(): Unit {
        timer.stop()
        timer.close()
        group.close()
    }
}