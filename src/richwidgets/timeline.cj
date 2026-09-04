package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*
import std.collection.ArrayList

// ============================================================
// Timeline - 时间线
// 纯仓颉组合层：垂直排列的事件列表（时间 + 内容）
// ============================================================

/// 时间线：垂直事件列表，每条由时间与内容组成
public class Timeline <: QtResource {
    private let group: QGroupBox
    private let layout: QVBoxLayout
    private let items: ArrayList<QLabel>

    /// 创建时间线（空）
    public init() {
        group = QGroupBox()
        group.setFlat(true)
        layout = QVBoxLayout()
        items = ArrayList<QLabel>()
        group.setLayout(layout.getPtr())
    }

    /// 添加一条事件（时间 + 内容）
    public func addItem(time: String, content: String): Unit {
        let label = QLabel()
        label.setText("${time}  ${content}")
        label.setWordWrap(true)
        layout.addWidget(label.getPtr())
        items.add(label)
    }

    /// 清空所有事件
    public func clear(): Unit {
        for (i in 0..items.size) {
            items[i].close()
        }
        items.clear()
    }

    /// 获取事件数量
    public func itemCount(): Int64 {
        items.size
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