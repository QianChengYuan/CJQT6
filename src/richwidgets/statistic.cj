package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*

// ============================================================
// Statistic - 统计数值
// 纯仓颉组合层：标题 + 大数值 + 单位，垂直排列
// ============================================================

/// 统计数值：标题 + 大数值展示，适合数据看板
public class Statistic <: QtResource {
    private let group: QGroupBox
    private let layout: QVBoxLayout
    private let titleLabel: QLabel
    private let valueLabel: QLabel
    private var suffix: String = ""

    /// 创建统计数值（标题 + 字符串值 + 单位）
    public init(title: String, value: String, unit: String) {
        group = QGroupBox()
        group.setFlat(true)
        layout = QVBoxLayout()
        suffix = unit
        titleLabel = QLabel()
        titleLabel.setText(title)
        titleLabel.setStyleSheet("color:#999999; font-size:12px;")
        valueLabel = QLabel()
        valueLabel.setText("${value} ${suffix}")
        valueLabel.setStyleSheet("color:#1890ff; font-size:24px; font-weight:bold;")
        layout.addWidget(titleLabel.getPtr())
        layout.addWidget(valueLabel.getPtr())
        group.setLayout(layout.getPtr())
    }

    /// 创建统计数值（标题 + 整数值，无单位）
    public init(title: String, value: Int64) {
        group = QGroupBox()
        group.setFlat(true)
        layout = QVBoxLayout()
        titleLabel = QLabel()
        titleLabel.setText(title)
        titleLabel.setStyleSheet("color:#999999; font-size:12px;")
        valueLabel = QLabel()

        valueLabel.setText("${value}")
        valueLabel.setStyleSheet("color:#1890ff; font-size:24px; font-weight:bold;")
        layout.addWidget(titleLabel.getPtr())
        layout.addWidget(valueLabel.getPtr())
        group.setLayout(layout.getPtr())
    }

    /// 设置数值（字符串）
    public func setValue(value: String): Unit {
        valueLabel.setText("${value} ${suffix}")
    }

    /// 设置数值（整数）
    public func setValue(value: Int64): Unit {
        valueLabel.setText("${value} ${suffix}")
    }

    /// 设置标题
    public func setTitle(title: String): Unit {
        titleLabel.setText(title)
    }

    /// 设置单位
    public func setUnit(unit: String): Unit {
        suffix = unit
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