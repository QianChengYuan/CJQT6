package cjqt6.gui

import cjqt6.core.*

// ============================================================
// QStyle FFI declarations
// ============================================================

foreign func qWidgetStyle(widgetPtr: Int64): Int64
foreign func qApplicationStyle(): Int64
foreign func qStylePixelMetric(stylePtr: Int64, metric: Int32): Int32
foreign func qStyleStandardIcon(stylePtr: Int64, standardIcon: Int32): Int64
foreign func qStyleLayoutSpacing(stylePtr: Int64, spacingType: Int32): Int32


// ============================================================
// 标准图标类型
// ============================================================
public class StandardIcon {
    public static func messageBoxInformation(): Int32 { 0 }
    public static func messageBoxWarning(): Int32 { 1 }
    public static func messageBoxCritical(): Int32 { 2 }
    public static func messageBoxQuestion(): Int32 { 3 }
    public static func computerIcon(): Int32 { 4 }
    public static func desktopIcon(): Int32 { 5 }
    public static func driveCDIcon(): Int32 { 9 }
    public static func driveHDIcon(): Int32 { 10 }
    public static func driveNetIcon(): Int32 { 11 }
    public static func fileIcon(): Int32 { 12 }
    public static func fileLinkIcon(): Int32 { 13 }
    public static func folderIcon(): Int32 { 14 }
    public static func folderLinkIcon(): Int32 { 15 }
    public static func infoIcon(): Int32 { 17 }
    public static func warningIcon(): Int32 { 18 }
    public static func errorIcon(): Int32 { 20 }
    public static func arrowUp(): Int32 { 21 }
    public static func arrowDown(): Int32 { 22 }
    public static func arrowLeft(): Int32 { 23 }
    public static func arrowRight(): Int32 { 24 }
    public static func mediaPlay(): Int32 { 47 }
    public static func mediaPause(): Int32 { 48 }
    public static func mediaStop(): Int32 { 49 }
    public static func mediaSkipForward(): Int32 { 50 }
    public static func mediaSkipBackward(): Int32 { 51 }
    public static func mediaVolume(): Int32 { 52 }
    public static func mediaVolumeMuted(): Int32 { 53 }
    public static func dialogClose(): Int32 { 35 }
    public static func dialogOpen(): Int32 { 32 }
    public static func dialogSave(): Int32 { 33 }
    public static func dialogApply(): Int32 { 41 }
    public static func dialogCancel(): Int32 { 30 }
    public static func dialogHelp(): Int32 { 34 }
    public static func dialogYes(): Int32 { 40 }
    public static func dialogNo(): Int32 { 39 }
}

// ============================================================
// 像素度量类型
// ============================================================
public class PixelMetric {
    public static func buttonIconSize(): Int32 { 16 }
    public static func buttonMinimumWidth(): Int32 { 65 }
    public static func buttonMinimumHeight(): Int32 { 66 }
    public static func tabBarTabOverlap(): Int32 { 1 }
    public static func tabBarBaseHeight(): Int32 { 2 }
    public static func titleBarHeight(): Int32 { 27 }
    public static func scrollBarExtent(): Int32 { 68 }
    public static func sliderThickness(): Int32 { 73 }
    public static func sliderLength(): Int32 { 74 }
    public static func progressBarHeight(): Int32 { 75 }
    public static func toolBarIconSize(): Int32 { 88 }
    public static func listViewIconSize(): Int32 { 89 }
    public static func smallIconSize(): Int32 { 102 }
    public static func largeIconSize(): Int32 { 103 }
    public static func focusFrameVMargin(): Int32 { 121 }
    public static func focusFrameHMargin(): Int32 { 120 }
    public static func menuBarHeight(): Int32 { 100 }
    public static func toolBarIconSpacing(): Int32 { 95 }
}


// ============================================================
// QStyleHelper - 样式查询辅助类（静态方法）
// ============================================================
public class QStyleHelper {
    // ---- 获取 QStyle 指针 ----

    /// 获取控件的 QStyle 指针
    public static func widgetStyle(widgetPtr: Int64): Int64 {
        unsafe { qWidgetStyle(widgetPtr) }
    }

    /// 获取应用的 QStyle 指针
    public static func applicationStyle(): Int64 {
        unsafe { qApplicationStyle() }
    }

    // ---- 像素度量查询 ----

    /// 查询控件样式的像素度量值
    public static func pixelMetric(stylePtr: Int64, metric: Int32): Int32 {
        unsafe { qStylePixelMetric(stylePtr, metric) }
    }

    /// 从控件查询像素度量（自动获取控件的 QStyle）
    public static func widgetPixelMetric(widgetPtr: Int64, metric: Int32): Int32 {
        let stylePtr = unsafe { qWidgetStyle(widgetPtr) }
        if (stylePtr == 0) {
            return 0
        }
        unsafe { qStylePixelMetric(stylePtr, metric) }
    }

    // ---- 标准图标 ----

    /// 获取标准图标（返回 QIcon 指针）
    public static func standardIcon(stylePtr: Int64, iconType: Int32): Int64 {
        unsafe { qStyleStandardIcon(stylePtr, iconType) }
    }

    /// 从控件获取标准图标
    public static func widgetStandardIcon(widgetPtr: Int64, iconType: Int32): Int64 {
        let stylePtr = unsafe { qWidgetStyle(widgetPtr) }
        if (stylePtr == 0) {
            return 0
        }
        unsafe { qStyleStandardIcon(stylePtr, iconType) }
    }

    // ---- 常用便捷方法 ----

    /// 获取按钮图标大小
    public static func buttonIconSize(widgetPtr: Int64): Int32 {
        widgetPixelMetric(widgetPtr, PixelMetric.buttonIconSize())
    }

    /// 获取小图标大小
    public static func smallIconSize(widgetPtr: Int64): Int32 {
        widgetPixelMetric(widgetPtr, PixelMetric.smallIconSize())
    }

    /// 获取大图标大小
    public static func largeIconSize(widgetPtr: Int64): Int32 {
        widgetPixelMetric(widgetPtr, PixelMetric.largeIconSize())
    }

    /// 获取工具栏图标大小
    public static func toolBarIconSize(widgetPtr: Int64): Int32 {
        widgetPixelMetric(widgetPtr, PixelMetric.toolBarIconSize())
    }

    /// 获取列表视图图标大小
    public static func listViewIconSize(widgetPtr: Int64): Int32 {
        widgetPixelMetric(widgetPtr, PixelMetric.listViewIconSize())
    }

    /// 获取标题栏高度
    public static func titleBarHeight(widgetPtr: Int64): Int32 {
        widgetPixelMetric(widgetPtr, PixelMetric.titleBarHeight())
    }

    /// 获取滚动条宽度
    public static func scrollBarExtent(widgetPtr: Int64): Int32 {
        widgetPixelMetric(widgetPtr, PixelMetric.scrollBarExtent())
    }

    /// 获取滑块厚度
    public static func sliderThickness(widgetPtr: Int64): Int32 {
        widgetPixelMetric(widgetPtr, PixelMetric.sliderThickness())
    }

    /// 获取进度条高度
    public static func progressBarHeight(widgetPtr: Int64): Int32 {
        widgetPixelMetric(widgetPtr, PixelMetric.progressBarHeight())
    }
}
