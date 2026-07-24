package cjqt6.core

foreign func qScreenPrimaryDpiX(): Float64
foreign func qScreenPrimaryDpiY(): Float64
foreign func qScreenPrimaryPhysicalDpiX(): Float64
foreign func qScreenPrimaryPhysicalDpiY(): Float64
foreign func qScreenPrimaryDevicePixelRatio(): Float64
foreign func qScreenPrimaryWidth(): Int32
foreign func qScreenPrimaryHeight(): Int32
foreign func qScreenPrimaryRefreshRate(): Float64

public class QScreen {
    public static func primaryDpiX(): Float64 {
        unsafe { return qScreenPrimaryDpiX() }
    }

    public static func primaryDpiY(): Float64 {
        unsafe { return qScreenPrimaryDpiY() }
    }

    public static func primaryPhysicalDpiX(): Float64 {
        unsafe { return qScreenPrimaryPhysicalDpiX() }
    }

    public static func primaryPhysicalDpiY(): Float64 {
        unsafe { return qScreenPrimaryPhysicalDpiY() }
    }

    public static func primaryDevicePixelRatio(): Float64 {
        unsafe { return qScreenPrimaryDevicePixelRatio() }
    }

    public static func primaryWidth(): Int32 {
        unsafe { return qScreenPrimaryWidth() }
    }

    public static func primaryHeight(): Int32 {
        unsafe { return qScreenPrimaryHeight() }
    }

    public static func primaryRefreshRate(): Float64 {
        unsafe { return qScreenPrimaryRefreshRate() }
    }

    /// DPI缩放因子（primaryDevicePixelRatio的语义化别名）
    public static func scaleFactor(): Float64 {
        primaryDevicePixelRatio()
    }

    /// 逻辑像素转物理像素
    public static func logicalToPhysical(logical: Int32): Int32 {
        Int32(Float64(logical) * scaleFactor())
    }

    /// 物理像素转逻辑像素
    public static func physicalToLogical(physical: Int32): Int32 {
        Int32(Float64(physical) / scaleFactor())
    }
}
