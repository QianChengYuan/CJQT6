package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*
import std.collection.ArrayList

// ============================================================
// Skeleton - 骨架屏
// 纯仓颉组合层：多个 QLabel 灰色占位条，加载时展示
// ============================================================

/// 骨架屏：灰色占位条，用于加载态占位
public class Skeleton <: QtResource {
    private let group: QGroupBox
    private let layout: QVBoxLayout
    private let bars: ArrayList<QLabel>

    /// 创建骨架屏（指定占位行数）
    public init(rows: Int32) {
        group = QGroupBox()
        group.setFlat(true)
        layout = QVBoxLayout()
        layout.setSpacing(8)
        bars = ArrayList<QLabel>()
        var n = rows
        if (n < 1) {
            n = 1
        }
        for (i in 0..n) {
            let bar = QLabel()
            bar.setStyleSheet("background-color:#e8e8e8; border-radius:4px; min-height:16px;")
            layout.addWidget(bar.getPtr())
            bars.add(bar)
        }
        group.setLayout(layout.getPtr())
    }

    /// 创建骨架屏（默认 1 行）
    public init() {
        group = QGroupBox()
        group.setFlat(true)
        layout = QVBoxLayout()
        layout.setSpacing(8)
        bars = ArrayList<QLabel>()
        let bar = QLabel()
        bar.setStyleSheet("background-color:#e8e8e8; border-radius:4px; min-height:16px;")
        layout.addWidget(bar.getPtr())
        bars.add(bar)
        group.setLayout(layout.getPtr())
    }

    /// 获取占位行数
    public func rowCount(): Int64 {
        bars.size
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
