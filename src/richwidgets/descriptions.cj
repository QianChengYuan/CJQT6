package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*
import std.collection.ArrayList

// ============================================================
// Descriptions - 描述列表
// 纯仓颉组合层：QGroupBox + QFormLayout 只读键值对展示
// ============================================================

/// 描述列表：只读键值对展示，适合详情页
public class Descriptions <: QtResource {
    private let group: QGroupBox
    private let layout: QFormLayout
    private let valueLabels: ArrayList<QLabel>

    /// 创建描述列表（带标题）
    public init(title: String) {
        group = QGroupBox()
        group.setTitle(title)
        layout = QFormLayout()
        valueLabels = ArrayList<QLabel>()
        group.setLayout(layout.getPtr())
    }

    /// 创建描述列表（无标题）
    public init() {
        group = QGroupBox()
        layout = QFormLayout()
        valueLabels = ArrayList<QLabel>()
        group.setLayout(layout.getPtr())
    }

    /// 添加一条键值对
    public func addItem(label: String, value: String): Unit {
        let vl = QLabel()
        vl.setText(value)
        vl.setWordWrap(true)
        layout.addRow(label, vl.getPtr())
        valueLabels.add(vl)
    }

    /// 设置标题
    public func setTitle(title: String): Unit {
        group.setTitle(title)
    }

    /// 获取条目数
    public func itemCount(): Int64 {
        valueLabels.size
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