package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*

// ============================================================
// Tag - 标签
// 纯仓颉组合层：QLabel 彩色小标签
// ============================================================

/// 标签：彩色小标签，可设背景色与文字色
public class Tag <: QtResource {
    private let label: QLabel
    private var bgColor: String = "#1890ff"
    private var fgColor: String = "#ffffff"

    /// 创建标签（默认蓝底白字）
    public init(text: String) {
        label = QLabel()
        label.setText(text)
        label.setAlignment(HAlign.toAlignment(0)) // 居中
        applyStyle()
    }

    /// 设置文字
    public func setText(text: String): Unit {
        label.setText(text)
    }

    /// 设置背景色（十六进制）
    public func setColor(color: String): Unit {
        bgColor = color
        applyStyle()
    }

    /// 设置文字颜色（十六进制）
    public func setForegroundColor(color: String): Unit {
        fgColor = color
        applyStyle()
    }

    // 内部：应用样式
    private func applyStyle(): Unit {
        label.setStyleSheet("background-color:${bgColor}; color:${fgColor}; border-radius:3px; padding:2px 8px;")
    }

    // ---- QtResource 接口委托 ----
    public func getPtr(): Int64 {
        label.getPtr()
    }
    public func isClosed(): Bool {
        label.isClosed()
    }
    public func isValid(): Bool {
        label.isValid()
    }
    public func checkValid(): Unit {
        label.checkValid()
    }
    public func close(): Unit {
        label.close()
    }
}