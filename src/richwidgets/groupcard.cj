package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*

// ============================================================
// GroupCard - 卡片容器
// 纯仓颉组合层：QGroupBox 容器 + QVBoxLayout 垂直布局
// ============================================================

/// 卡片：带标题的垂直分组容器，适合聚合一组相关控件
public class GroupCard <: QtResource {
    private let group: QGroupBox
    private let layout: QVBoxLayout

    /// 创建卡片（带标题）
    public init(title: String) {
        group = QGroupBox()
        group.setTitle(title)
        layout = QVBoxLayout()
        group.setLayout(layout.getPtr())
    }

    /// 创建卡片（无标题）
    public init() {
        group = QGroupBox()
        layout = QVBoxLayout()
        group.setLayout(layout.getPtr())
    }

    /// 添加控件
    public func addWidget(widget: QtResource): Unit {
        layout.addWidget(widget.getPtr())
    }

    /// 添加弹簧（弹性间距，把后续控件推到底部）
    public func addStretch(): Unit {
        layout.addStretch()
    }

    /// 设置标题
    public func setTitle(title: String): Unit {
        group.setTitle(title)
    }

    /// 设置标题
    public func title(): String {
        group.title()
    }

    /// 设置控件间距
    public func setSpacing(spacing: Int32): Unit {
        layout.setSpacing(spacing)
    }

    /// 设置扁平样式（无边框）
    public func setFlat(flat: Bool): Unit {
        group.setFlat(flat)
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
