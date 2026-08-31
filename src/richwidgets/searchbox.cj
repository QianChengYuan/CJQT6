package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.widgets.*

// ============================================================
// SearchBox - 搜索框
// 纯仓颉组合层：QLineEdit 封装（占位提示 + 清空按钮 + 回车触发搜索）
// ============================================================

/// 搜索框：单行输入 + 占位提示 + 清空按钮 + 回车触发搜索
public class SearchBox <: QtResource {
    private let edit: QLineEdit

    /// 创建搜索框（默认占位「搜索...」，带清空按钮）
    public init() {
        edit = QLineEdit()
        edit.setPlaceholder("搜索...")
        edit.setClearButtonEnabled(true)
    }

    /// 设置占位提示
    public func setPlaceholder(text: String): Unit {
        edit.setPlaceholder(text)
    }

    /// 获取当前输入文本
    public func text(): String {
        edit.text()
    }

    /// 设置文本
    public func setText(text: String): Unit {
        edit.setText(text)
    }

    /// 清空输入
    public func clear(): Unit {
        edit.clear()
    }

    /// 搜索触发回调（回车触发，可捕获局部变量）
    public func setOnSearch(callback: () -> Unit): SignalConnection {
        edit.setOnReturnPressedCapture(callback)
    }

    // ---- QtResource 接口委托 ----
    public func getPtr(): Int64 {
        edit.getPtr()
    }
    public func isClosed(): Bool {
        edit.isClosed()
    }
    public func isValid(): Bool {
        edit.isValid()
    }
    public func checkValid(): Unit {
        edit.checkValid()
    }
    public func close(): Unit {
        edit.close()
    }
}
