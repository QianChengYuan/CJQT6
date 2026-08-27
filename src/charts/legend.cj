package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QLegend FFI 声明（图例由 QChart::legend() 获取，非拥有式）
// ============================================================

foreign func qLegendSetAlignment(ptr: Int64, alignment: Int32): Unit
foreign func qLegendAlignment(ptr: Int64): Int32
foreign func qLegendSetBackgroundVisible(ptr: Int64, visible: Int32): Unit
foreign func qLegendIsBackgroundVisible(ptr: Int64): Int32
foreign func qLegendDetachFromChart(ptr: Int64): Unit
foreign func qLegendAttachToChart(ptr: Int64): Unit
foreign func qLegendIsAttachedToChart(ptr: Int64): Int32
foreign func qLegendSetReverseMarkers(ptr: Int64, reverse: Int32): Unit
foreign func qLegendReverseMarkers(ptr: Int64): Int32
foreign func qLegendSetShowToolTips(ptr: Int64, show: Int32): Unit
foreign func qLegendShowToolTips(ptr: Int64): Int32
foreign func qLegendSetInteractive(ptr: Int64, interactive: Int32): Unit
foreign func qLegendIsInteractive(ptr: Int64): Int32
foreign func qLegendSetMarkerShape(ptr: Int64, shape: Int32): Unit
foreign func qLegendMarkerShape(ptr: Int64): Int32
foreign func qLegendSetColor(ptr: Int64, r: Int32, g: Int32, b: Int32): Unit
foreign func qLegendSetBorderColor(ptr: Int64, r: Int32, g: Int32, b: Int32): Unit
foreign func qLegendSetLabelColor(ptr: Int64, r: Int32, g: Int32, b: Int32): Unit

// ============================================================
// 图例标记形状常量（对应 QLegend::MarkerShape）
// ============================================================

public class LegendMarkerShape {
    public static let defaultShape: Int32 = 0       // MarkerShapeDefault
    public static let rectangle: Int32 = 1          // MarkerShapeRectangle
    public static let circle: Int32 = 2             // MarkerShapeCircle
    public static let fromSeries: Int32 = 3         // MarkerShapeFromSeries
    public static let rotatedRectangle: Int32 = 4   // MarkerShapeRotatedRectangle
    public static let triangle: Int32 = 5           // MarkerShapeTriangle
    public static let star: Int32 = 6               // MarkerShapeStar
    public static let pentagon: Int32 = 7           // MarkerShapePentagon
}

// ============================================================
// QLegend - 图例
//
// 由 QChart.getLegend() 获取，非拥有式（由 chart 管理生命周期）。
// 使用方式：
//   let legend = chart.getLegend()
//   legend.setAlignment(AxisAlignment.bottom)
//   legend.setBackgroundVisible(true)
//   legend.setMarkerShape(LegendMarkerShape.circle)
//
// 勿调用 close()，图例生命周期由 QChart 管理。
// ============================================================

public class QLegend {
    private var ptr: Int64 = 0

    private func checkValid(): Unit {
        if (ptr == 0) {
            throw ResourceDisposedException("QLegend is null")
        }
    }

    /// 内部构造：由 QChart.getLegend() 调用，接收已存在的图例指针
    public init(legendPtr: Int64) {
        ptr = legendPtr
    }

    /// 设置图例对齐方式（见 AxisAlignment 常量）
    public func setAlignment(alignment: Int32): Unit {
        checkValid()
        unsafe { qLegendSetAlignment(ptr, alignment) }
    }

    /// 获取图例对齐方式
    public func alignment(): Int32 {
        checkValid()
        unsafe { return qLegendAlignment(ptr) }
    }

    /// 设置背景是否可见
    public func setBackgroundVisible(visible: Bool): Unit {
        checkValid()
        unsafe { qLegendSetBackgroundVisible(ptr, if (visible) { 1 } else { 0 }) }
    }

    /// 背景是否可见
    public func isBackgroundVisible(): Bool {
        checkValid()
        unsafe { return qLegendIsBackgroundVisible(ptr) != 0 }
    }

    /// 将图例从图表分离
    public func detachFromChart(): Unit {
        checkValid()
        unsafe { qLegendDetachFromChart(ptr) }
    }

    /// 将图例附着到图表
    public func attachToChart(): Unit {
        checkValid()
        unsafe { qLegendAttachToChart(ptr) }
    }

    /// 图例是否附着到图表
    public func isAttachedToChart(): Bool {
        checkValid()
        unsafe { return qLegendIsAttachedToChart(ptr) != 0 }
    }

    /// 设置是否反转标记顺序
    public func setReverseMarkers(reverse: Bool): Unit {
        checkValid()
        unsafe { qLegendSetReverseMarkers(ptr, if (reverse) { 1 } else { 0 }) }
    }

    /// 是否反转标记顺序
    public func reverseMarkers(): Bool {
        checkValid()
        unsafe { return qLegendReverseMarkers(ptr) != 0 }
    }

    /// 设置是否显示工具提示
    public func setShowToolTips(show: Bool): Unit {
        checkValid()
        unsafe { qLegendSetShowToolTips(ptr, if (show) { 1 } else { 0 }) }
    }

    /// 是否显示工具提示
    public func showToolTips(): Bool {
        checkValid()
        unsafe { return qLegendShowToolTips(ptr) != 0 }
    }

    /// 设置是否可交互
    public func setInteractive(interactive: Bool): Unit {
        checkValid()
        unsafe { qLegendSetInteractive(ptr, if (interactive) { 1 } else { 0 }) }
    }

    /// 是否可交互
    public func isInteractive(): Bool {
        checkValid()
        unsafe { return qLegendIsInteractive(ptr) != 0 }
    }

    /// 设置标记形状（见 LegendMarkerShape 常量）
    public func setMarkerShape(shape: Int32): Unit {
        checkValid()
        unsafe { qLegendSetMarkerShape(ptr, shape) }
    }

    /// 获取标记形状
    public func markerShape(): Int32 {
        checkValid()
        unsafe { return qLegendMarkerShape(ptr) }
    }

    /// 设置背景颜色（RGB）
    public func setColor(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe { qLegendSetColor(ptr, r, g, b) }
    }

    /// 设置边框颜色（RGB）
    public func setBorderColor(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe { qLegendSetBorderColor(ptr, r, g, b) }
    }

    /// 设置标签颜色（RGB）
    public func setLabelColor(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe { qLegendSetLabelColor(ptr, r, g, b) }
    }

    public func getPtr(): Int64 { ptr }
}