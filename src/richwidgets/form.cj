package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*

// ============================================================
// Form - 表单
// 纯仓颉组合层：QGroupBox 容器 + QFormLayout 表单布局
// ============================================================

/// 表单：带标题的分组容器，内部用 QFormLayout 实现「标签:控件」对齐排列
public class Form <: QtResource {
    private let group: QGroupBox
    private let layout: QFormLayout

    /// 创建表单（带标题）
    public init(title: String) {
        group = QGroupBox()
        group.setTitle(title)
        layout = QFormLayout()
        group.setLayout(layout.getPtr())
    }

    /// 创建表单（无标题）
    public init() {
        group = QGroupBox()
        layout = QFormLayout()
        group.setLayout(layout.getPtr())
    }

    /// 添加一行：左侧标签文本 + 右侧输入控件
    public func addRow(label: String, widget: QtResource): Unit {
        layout.addRow(label, widget.getPtr())
    }

    /// 设置标题
    public func setTitle(title: String): Unit {
        group.setTitle(title)
    }

    /// 设置标签对齐（HAlign 常量：0=居中/1=左/2=右）
    public func setLabelAlignment(align: Int32): Unit {
        layout.setLabelAlignment(HAlign.toAlignment(align))
    }

    /// 设置行间距
    public func setSpacing(spacing: Int32): Unit {
        layout.setSpacing(spacing)
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
