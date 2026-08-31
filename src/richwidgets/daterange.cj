package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*

// ============================================================
// DateRangePicker - 日期范围选择器
// 纯仓颉组合层：两个 QDateEdit + 分隔标签，水平排列
// ============================================================

/// 日期范围选择器：起始日期 + 结束日期，带日历弹出
public class DateRangePicker <: QtResource {
    private let group: QGroupBox
    private let layout: QHBoxLayout
    private let startEdit: QDateEdit
    private let sepLabel: QLabel
    private let endEdit: QDateEdit

    /// 创建日期范围选择器（默认日历弹出，格式 yyyy-MM-dd）
    public init() {
        group = QGroupBox()
        startEdit = QDateEdit()
        startEdit.setCalendarPopup(true)
        startEdit.setDisplayFormat("yyyy-MM-dd")
        sepLabel = QLabel()
        sepLabel.setText(" 至 ")
        endEdit = QDateEdit()
        endEdit.setCalendarPopup(true)
        endEdit.setDisplayFormat("yyyy-MM-dd")
        layout = QHBoxLayout()
        layout.addWidget(startEdit.getPtr())
        layout.addWidget(sepLabel.getPtr())
        layout.addWidget(endEdit.getPtr())
        group.setLayout(layout.getPtr())
    }

    /// 设置起始日期（按年/月/日）
    public func setStartDate(year: Int32, month: Int32, day: Int32): Unit {
        startEdit.setDateFromParts(year, month, day)
    }

    /// 设置结束日期（按年/月/日）
    public func setEndDate(year: Int32, month: Int32, day: Int32): Unit {
        endEdit.setDateFromParts(year, month, day)
    }

    /// 获取起始日期
    public func getStartDate(): QDate {
        startEdit.date()
    }

    /// 获取结束日期
    public func getEndDate(): QDate {
        endEdit.date()
    }

    /// 设置显示格式（同时应用于两个编辑器）
    public func setDisplayFormat(format: String): Unit {
        startEdit.setDisplayFormat(format)
        endEdit.setDisplayFormat(format)
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
        // QDateEdit 非 QtResource，需显式 delete；QLabel 由容器级联清理
        startEdit.delete()
        endEdit.delete()
        group.close()
    }
}
