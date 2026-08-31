package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.widgets.*

// ============================================================
// Switch - 开关控件
// 纯仓颉组合层：复用 QPushButton 的 checkable 能力，不新增桥接函数
// ============================================================

/// 开关控件：基于可勾选按钮的轻量开关
public class Switch <: QtResource {
    private let btn: QPushButton

    /// 创建开关（默认关闭状态）
    public init() {
        btn = QPushButton()
        btn.setCheckable(true)
    }

    /// 设置开关状态
    public func setChecked(checked: Bool): Unit {
        btn.setChecked(checked)
    }

    /// 获取开关状态
    public func isChecked(): Bool {
        btn.isChecked()
    }

    /// 切换开关状态
    public func toggle(): Unit {
        btn.setChecked(!btn.isChecked())
    }

    /// 设置开关显示文本
    public func setText(text: String): Unit {
        btn.setText(text)
    }

    /// 状态变化回调（点击触发，回调内用 isChecked() 读取新状态，可捕获局部变量）
    public func setOnChanged(callback: () -> Unit): SignalConnection {
        btn.setOnClickCapture(callback)
    }

    // ---- QtResource 接口委托给内部按钮 ----
    public func getPtr(): Int64 {
        btn.getPtr()
    }
    public func isClosed(): Bool {
        btn.isClosed()
    }
    public func isValid(): Bool {
        btn.isValid()
    }
    public func checkValid(): Unit {
        btn.checkValid()
    }
    public func close(): Unit {
        btn.close()
    }
}
