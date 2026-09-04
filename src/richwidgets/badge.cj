package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*

// ============================================================
// Badge - 徽标
// 纯仓颉组合层：QLabel 小圆点，显示数字（超过上限显示 "N+"）
// ============================================================

/// 徽标：数字标记，超过上限显示 "N+"
public class Badge <: QtResource {
    private let label: QLabel
    private var count: Int32 = 0
    private var maxCount: Int32 = 99
    private var bgColor: String = "#ff4d4f"
    private var fgColor: String = "#ffffff"

    /// 创建徽标（默认 0，红底白字，上限 99）
    public init() {
        label = QLabel()
        label.setAlignment(HAlign.toAlignment(0)) // 居中
        applyStyle()
    }

    /// 创建徽标（带初始数字）
    public init(initialCount: Int32) {
        label = QLabel()
        count = if (initialCount < 0) { 0 } else { initialCount }
        label.setAlignment(HAlign.toAlignment(0))
        applyStyle()
    }

    /// 设置数字（负数归零）
    public func setCount(n: Int32): Unit {
        count = if (n < 0) { 0 } else { n }
        applyStyle()
    }

    /// 获取数字
    public func getCount(): Int32 {
        count
    }

    /// 设置显示上限（超过则显示 "N+"）
    public func setMaxCount(max: Int32): Unit {
        maxCount = if (max < 1) { 1 } else { max }
        applyStyle()
    }

    /// 设置背景色（十六进制）
    public func setBackgroundColor(color: String): Unit {
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
        let display = if (count > maxCount) {
            "${maxCount}+"
        } else {
            "${count}"
        }
        label.setText(display)
        // 数字为 0 时隐藏，否则显示红点
        if (count == 0) {
            label.setStyleSheet("background-color:transparent; color:transparent; border:none;")
        } else {
            label.setStyleSheet("background-color:${bgColor}; color:${fgColor}; border-radius:8px; padding:0 6px; font-size:12px; min-width:16px;")
        }
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