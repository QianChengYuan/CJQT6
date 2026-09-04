package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*
import std.collection.ArrayList

// ============================================================
// Steps - 步骤条
// 纯仓颉组合层：水平排列的步骤指示器（圆圈编号 + 标题）
// ============================================================

/// 步骤条：水平步骤指示，当前步及之前高亮，之后置灰
public class Steps <: QtResource {
    private let group: QGroupBox
    private let layout: QHBoxLayout
    private let circles: ArrayList<QLabel>
    private let titleLabels: ArrayList<QLabel>
    private var current: Int64 = 0

    /// 创建步骤条（传入各步标题）
    public init(titles: Array<String>) {
        group = QGroupBox()
        group.setFlat(true)
        layout = QHBoxLayout()
        layout.setSpacing(16)
        circles = ArrayList<QLabel>()
        titleLabels = ArrayList<QLabel>()
        var idx: Int64 = 0
        for (t in titles) {
            let circle = QLabel()
            circle.setText("${idx + 1}")
            circle.setAlignment(HAlign.toAlignment(0)) // 居中
            let title = QLabel()
            title.setText(t)
            layout.addWidget(circle.getPtr())
            layout.addWidget(title.getPtr())
            circles.add(circle)
            titleLabels.add(title)
            idx = idx + 1
        }
        current = 0
        updateStyles()
        group.setLayout(layout.getPtr())
    }

    /// 设置当前步（0-based，越界自动钳制）
    public func setCurrentStep(step: Int32): Unit {
        let n = circles.size
        if (n == 0) {
            return
        }
        let s = Int64(step)
        current = if (s < 0) {
            0
        } else if (s >= n) {
            n - 1
        } else {
            s
        }
        updateStyles()
    }

    /// 获取当前步
    public func getCurrentStep(): Int32 {
        Int32(current)
    }

    /// 获取步骤数
    public func stepCount(): Int32 {
        Int32(circles.size)
    }

    // 内部：更新圆圈样式（当前步及之前实心蓝，之后空心灰）
    private func updateStyles(): Unit {
        for (i in 0..circles.size) {
            let circle = circles[i]
            if (i <= current) {
                circle.setStyleSheet("background-color:#1890ff; color:#ffffff; border-radius:10px; min-width:20px; min-height:20px; max-width:20px; max-height:20px;")
            } else {
                circle.setStyleSheet("background-color:#ffffff; color:#999999; border:1px solid #d9d9d9; border-radius:10px; min-width:20px; min-height:20px; max-width:20px; max-height:20px;")
            }
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
        group.close()
    }
}