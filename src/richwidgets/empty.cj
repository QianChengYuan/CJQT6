package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*

// ============================================================
// Empty - 空状态
// 纯仓颉组合层：QLabel 居中灰色文字，无数据时占位
// ============================================================

/// 空状态：居中灰色文字占位，用于无数据场景
public class Empty <: QtResource {
    private let label: QLabel

    /// 创建空状态（主文字）
    public init(text: String) {
        label = QLabel()
        label.setText(text)
        label.setAlignment(HAlign.toAlignment(0)) // 居中
        label.setStyleSheet("color:#999999; padding:20px;")
    }

    /// 创建空状态（主文字 + 描述，换行显示）
    public init(text: String, description: String) {
        label = QLabel()
        label.setText("${text}\n${description}")
        label.setAlignment(HAlign.toAlignment(0))
        label.setWordWrap(true)
        label.setStyleSheet("color:#999999; padding:20px;")
    }

    /// 设置文字
    public func setText(text: String): Unit {
        label.setText(text)
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