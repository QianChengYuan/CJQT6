package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QChartView FFI 声明
// ============================================================

foreign func qChartViewCreate(): Int64
foreign func qChartViewDelete(ptr: Int64): Unit
foreign func qChartViewSetChart(ptr: Int64, chartPtr: Int64): Unit

// widget 基类方法（foreign func 默认包私有，跨包需重新声明，链接同一符号）
foreign func qWidgetShow(ptr: Int64): Unit
foreign func qWidgetResize(ptr: Int64, width: Int32, height: Int32): Unit

// ============================================================
// QChartView - 图表视图 widget
//
// 显示 QChart 的 QGraphicsView 子类。使用方式：
//   let view = QChartView()
//   view.setChart(chart)
//   view.resize(640, 480)
//   view.show()
//
// 所有权：setChart 后 view 接管 chart 所有权，view 析构时级联释放 chart 及其 series/axis。
// ============================================================

public class QChartView {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QChartView already deleted")
        }
    }

    /// 创建图表视图
    public init() {
        unsafe { ptr = qChartViewCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QChartView create failed")
        }
        trackObject(ptr)
    }

    /// 设置要显示的图表；设置后 view 接管 chart 所有权
    public func setChart(chart: QChart): Unit {
        checkValid()
        unsafe { qChartViewSetChart(ptr, chart.getPtr()) }
    }

    /// 设置极坐标图；设置后 view 接管 polar 所有权
    public func setChart(polar: QPolarChart): Unit {
        checkValid()
        unsafe { qChartViewSetChart(ptr, polar.getPtr()) }
    }

    /// 显示窗口
    public func show(): Unit {
        checkValid()
        unsafe { qWidgetShow(ptr) }
    }

    /// 调整窗口大小
    public func resize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe { qWidgetResize(ptr, width, height) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；会级联释放已 setChart 的 QChart 及其 series/axis
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qChartViewDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}