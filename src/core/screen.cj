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
}
