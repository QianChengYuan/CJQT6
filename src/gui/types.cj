package cjqt6.gui

// ============================================================
// GUI布局相关类型定义
// ============================================================

/// 对齐方式（可组合标志）
public struct Alignment {
    public let value: Int32
    
    public init(v: Int32) { value = v }
    
    // 水平对齐
    public static let Left: Alignment = Alignment(0x0001)
    public static let Right: Alignment = Alignment(0x0002)
    public static let HCenter: Alignment = Alignment(0x0004)
    
    // 垂直对齐
    public static let Top: Alignment = Alignment(0x0020)
    public static let Bottom: Alignment = Alignment(0x0040)
    public static let VCenter: Alignment = Alignment(0x0080)
    
    // 常用组合
    public static let Center: Alignment = Alignment(0x0084)      // HCenter | VCenter
    public static let TopLeft: Alignment = Alignment(0x0021)     // Left | Top
    public static let TopRight: Alignment = Alignment(0x0022)    // Right | Top
    public static let BottomLeft: Alignment = Alignment(0x0041)  // Left | Bottom
    public static let BottomRight: Alignment = Alignment(0x0042) // Right | Bottom
    public static let Default: Alignment = Alignment(0x0081)     // Left | VCenter
    
    /// 位或运算 - 组合对齐标志
    public operator func |(other: Alignment): Alignment {
        Alignment(value | other.value)
    }
    
    /// 检查是否包含某标志
    public func has(flag: Alignment): Bool {
        (value & flag.value) != 0
    }
    
    /// 是否水平居中
    public func isHCenter(): Bool { has(HCenter) }
    /// 是否垂直居中
    public func isVCenter(): Bool { has(VCenter) }
    /// 是否完全居中
    public func isCenter(): Bool { isHCenter() && isVCenter() }
}

/// 方向枚举
public enum Orientation {
    | Horizontal
    | Vertical
    
    public func value(): Int32 {
        match (this) {
            case Horizontal => 1
            case Vertical => 2
        }
    }
    
    public static func fromValue(v: Int32): Orientation {
        match (v) {
            case 1 => Horizontal
            case 2 => Vertical
            case _ => Horizontal
        }
    }
    
    public operator func ==(other: Orientation): Bool {
        this.value() == other.value()
    }
    
    public operator func !=(other: Orientation): Bool {
        this.value() != other.value()
    }
}

/// 布局边距
public struct Margins {
    public let left: Int32
    public let top: Int32
    public let right: Int32
    public let bottom: Int32
    
    public init(left: Int32, top: Int32, right: Int32, bottom: Int32) {
        this.left = left
        this.top = top
        this.right = right
        this.bottom = bottom
    }
    
    public init(all: Int32) {
        left = all; top = all; right = all; bottom = all
    }
}

/// 点坐标
public struct Point {
    public let x: Int32
    public let y: Int32
    
    public init(x: Int32, y: Int32) {
        this.x = x
        this.y = y
    }
}

/// 尺寸
public struct Size {
    public let width: Int32
    public let height: Int32
    
    public init(width: Int32, height: Int32) {
        this.width = width
        this.height = height
    }
}

/// 矩形区域
public struct Rect {
    public let x: Int32
    public let y: Int32
    public let width: Int32
    public let height: Int32
    
    public init(x: Int32, y: Int32, width: Int32, height: Int32) {
        this.x = x
        this.y = y
        this.width = width
        this.height = height
    }
    
    public func left(): Int32 { x }
    public func top(): Int32 { y }
    public func right(): Int32 { x + width }
    public func bottom(): Int32 { y + height }
    public func center(): Point { Point(x + width / 2, y + height / 2) }
}
