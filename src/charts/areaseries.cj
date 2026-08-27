package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QAreaSeries FFI 声明
// ============================================================

foreign func qAreaSeriesCreate(upperPtr: Int64, lowerPtr: Int64): Int64
foreign func qAreaSeriesDelete(ptr: Int64): Unit
foreign func qAreaSeriesSetColor(ptr: Int64, r: Int32, g: Int32, b: Int32): Unit
foreign func qAreaSeriesSetBorderColor(ptr: Int64, r: Int32, g: Int32, b: Int32): Unit
foreign func qAreaSeriesSetPointsVisible(ptr: Int64, visible: Int32): Unit

// ============================================================
// QAreaSeries - 区域图序列
//
// 用上下两条折线围成填充区域。使用方式：
//   let upper = QLineSeries()
//   upper.append(0.0, 10.0); upper.append(1.0, 20.0)
//   let area = QAreaSeries(upper)
//   chart.addSeries(area)
//
// 所有权：addSeries 后 QChart 接管 series 所有权，勿主动 close()。
// ============================================================

public class QAreaSeries {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QAreaSeries already deleted")
        }
    }

    /// 创建区域图，指定上边界折线（下边界默认为 0）
    public init(upper: QLineSeries) {
        unsafe { ptr = qAreaSeriesCreate(upper.getPtr(), 0) }
        if (ptr == 0) {
            throw CreateFailedException("QAreaSeries create failed")
        }
        trackObject(ptr)
    }

    /// 创建区域图，指定上/下边界折线
    public init(upper: QLineSeries, lower: QLineSeries) {
        unsafe { ptr = qAreaSeriesCreate(upper.getPtr(), lower.getPtr()) }
        if (ptr == 0) {
            throw CreateFailedException("QAreaSeries create failed")
        }
        trackObject(ptr)
    }

    /// 设置区域颜色（RGB）
    public func setColor(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe { qAreaSeriesSetColor(ptr, r, g, b) }
    }

    /// 设置边框颜色（RGB）
    public func setBorderColor(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe { qAreaSeriesSetBorderColor(ptr, r, g, b) }
    }

    /// 设置数据点是否可见
    public func setPointsVisible(visible: Bool): Unit {
        checkValid()
        unsafe { qAreaSeriesSetPointsVisible(ptr, if (visible) { 1 } else { 0 }) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 addSeries 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qAreaSeriesDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}