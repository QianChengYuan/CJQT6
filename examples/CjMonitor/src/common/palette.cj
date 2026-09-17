package CjMonitor.common

import cjqt6.paint.*

// ============================================================
// 调色板 —— 深色数据仪表盘
// 单一数据源：QSS（app/theme.cj）与自绘（widget/）都从这里取值。
// ============================================================

/// RGB 颜色分量（0~255）
public struct Rgb {
    public let r: Int32
    public let g: Int32
    public let b: Int32

    public init(r: Int32, g: Int32, b: Int32) {
        this.r = r
        this.g = g
        this.b = b
    }

    /// 转为 "#RRGGBB"，供 QSS 使用
    public func hex(): String {
        "#" + hexDigit(r / 16) + hexDigit(r % 16) +
            hexDigit(g / 16) + hexDigit(g % 16) +
            hexDigit(b / 16) + hexDigit(b % 16)
    }
}

func hexDigit(v: Int32): String {
    match (v) {
        case 10 => "A"
        case 11 => "B"
        case 12 => "C"
        case 13 => "D"
        case 14 => "E"
        case 15 => "F"
        case _ => "${v}"
    }
}

// ---- 背景层次 ----
public let C_BG_BASE = Rgb(14, 16, 19)        // #0E1013 窗口底
public let C_BG_PANEL = Rgb(24, 26, 32)       // #181A20 面板
public let C_BG_ELEVATED = Rgb(31, 35, 43)    // #1F232B 抬升面
public let C_BORDER = Rgb(42, 47, 58)         // #2A2F3A 描边

// ---- 文字 ----
public let C_TEXT_PRIMARY = Rgb(230, 234, 242)   // #E6EAF2
public let C_TEXT_SECONDARY = Rgb(154, 164, 178) // #9AA4B2
public let C_TEXT_MUTED = Rgb(91, 100, 112)      // #5B6470
public let C_TEXT_ON_ACCENT = Rgb(255, 255, 255)

// ---- 主色 ----
public let C_ACCENT = Rgb(0, 217, 181)   // #00D9B5 青
public let C_CYAN = Rgb(34, 195, 230)    // #22C3E6
public let C_VIOLET = Rgb(124, 92, 255)  // #7C5CFF
public let C_BLUE = Rgb(76, 141, 255)    // #4C8DFF

// ---- 语义色 ----
public let C_OK = Rgb(61, 214, 140)     // #3DD68C
public let C_WARN = Rgb(255, 176, 32)   // #FFB020
public let C_DANGER = Rgb(255, 92, 92)  // #FF5C5C

// ============================================================
// 通道配色（CPU / MEM / DISK / NET）
// ============================================================

public let C_CH_CPU = C_ACCENT
public let C_CH_MEM = C_CYAN
public let C_CH_DISK = C_VIOLET
public let C_CH_NET = C_BLUE

/// 按通道下标取配色（越界回退为主色）
public func channelColor(idx: Int32): Rgb {
    match (idx) {
        case 0 => C_CH_CPU
        case 1 => C_CH_MEM
        case 2 => C_CH_DISK
        case 3 => C_CH_NET
        case _ => C_ACCENT
    }
}

// ============================================================
// 绘图辅助
// ============================================================

/// 带透明度构造 QColor（自绘高频路径上避免重复书写 rgba 四参）
public func rgbWithAlpha(c: Rgb, a: Int32): QColor {
    QColor.rgba(c.r, c.g, c.b, a)
}

/// 不透明 QColor
public func rgbSolid(c: Rgb): QColor {
    QColor.rgba(c.r, c.g, c.b, 255)
}
