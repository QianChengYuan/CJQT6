package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*

// ============================================================
// Avatar - 头像
// 纯仓颉组合层：QLabel 圆形样式，显示文字（首字母/自定义）
// ============================================================

/// 头像：圆形背景 + 居中文字，可设尺寸与颜色
public class Avatar <: QtResource {
    private let label: QLabel
    private var diameter: Int32 = 40
    private var bgColor: String = "#1890ff"
    private var fgColor: String = "#ffffff"

    /// 创建头像（文字 + 直径，默认蓝底白字）
    public init(text: String, size: Int32) {
        label = QLabel()
        diameter = if (size < 16) { 16 } else { size }
        label.setText(text)
        label.setAlignment(HAlign.toAlignment(0)) // 居中
        applyStyle()
    }

    /// 创建头像（默认直径 40）
    public init(text: String) {
        label = QLabel()
        label.setText(text)
        label.setAlignment(HAlign.toAlignment(0))
        applyStyle()
    }

    /// 设置显示文字
    public func setText(text: String): Unit {
        label.setText(text)
    }

    /// 设置直径
    public func setSize(size: Int32): Unit {
        diameter = if (size < 16) { 16 } else { size }
        applyStyle()
    }

    /// 设置背景色（十六进制，如 "#1890ff"）
    public func setBackgroundColor(color: String): Unit {
        bgColor = color
        applyStyle()
    }

    /// 设置文字颜色（十六进制）
    public func setForegroundColor(color: String): Unit {
        fgColor = color
        applyStyle()
    }

    // 内部：应用圆形样式
    private func applyStyle(): Unit {
        label.setMinimumSize(diameter, diameter)
        label.setMaximumSize(diameter, diameter)
        label.setStyleSheet("background-color:${bgColor}; color:${fgColor}; border-radius:${diameter / 2}px; font-weight:bold;")
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