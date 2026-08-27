package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QChart FFI 声明
// ============================================================

foreign func qChartCreate(): Int64
foreign func qChartDelete(ptr: Int64): Unit
foreign func qChartAddSeries(ptr: Int64, seriesPtr: Int64): Unit
foreign func qChartRemoveAllSeries(ptr: Int64): Unit
foreign func qChartSetTitle(ptr: Int64, title: CString): Unit
foreign func qChartSetTheme(ptr: Int64, theme: Int32): Unit
foreign func qChartCreateDefaultAxes(ptr: Int64): Unit
foreign func qChartSetAnimationOptions(ptr: Int64, options: Int32): Unit
foreign func qChartAddAxis(ptr: Int64, axisPtr: Int64, alignment: Int32): Unit
foreign func qChartLegend(ptr: Int64): Int64

// ============================================================
// 图表主题常量（对应 QChart::ChartTheme）
// ============================================================

public class ChartTheme {
    public static let light: Int32 = 0          // ChartThemeLight
    public static let blueCerulean: Int32 = 1   // ChartThemeBlueCerulean
    public static let dark: Int32 = 2           // ChartThemeDark
    public static let brownSand: Int32 = 3      // ChartThemeBrownSand
    public static let blueNcs: Int32 = 4        // ChartThemeBlueNcs
    public static let highContrast: Int32 = 5   // ChartThemeHighContrast
    public static let blueIcy: Int32 = 6        // ChartThemeBlueIcy
    public static let qt: Int32 = 7             // ChartThemeQt
}

// ============================================================
// 动画选项常量（对应 QChart::AnimationOption）
// ============================================================

public class ChartAnimation {
    public static let none: Int32 = 0               // NoAnimation
    public static let gridAxis: Int32 = 1           // GridAxisAnimations
    public static let series: Int32 = 2             // SeriesAnimations
    public static let all: Int32 = 3                // AllAnimations
}

// ============================================================
// 对齐标志常量（对应 Qt::AlignmentFlag，用于 addAxis）
// ============================================================

public class AxisAlignment {
    public static let left: Int32 = 0x0001      // AlignLeft
    public static let right: Int32 = 0x0002     // AlignRight
    public static let hCenter: Int32 = 0x0004   // AlignHCenter
    public static let top: Int32 = 0x0020       // AlignTop
    public static let bottom: Int32 = 0x0040    // AlignBottom
    public static let vCenter: Int32 = 0x0080   // AlignVCenter
}

// ============================================================
// QChart - 图表容器
//
// 管理 series、axis、legend。使用方式：
//   let chart = QChart()
//   chart.addSeries(series)
//   chart.createDefaultAxes()
//   chart.setTitle("标题")
//   let view = QChartView()
//   view.setChart(chart)
//
// 所有权：setChart 后 QChartView 接管 QChart 所有权；
//         addSeries 后 QChart 接管 series 所有权。
// 挂载后勿主动 close()，由视图级联释放。
// ============================================================

public class QChart {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QChart already deleted")
        }
    }

    /// 创建图表
    public init() {
        unsafe { ptr = qChartCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QChart create failed")
        }
        trackObject(ptr)
    }

    /// 添加折线序列；添加后 chart 接管 series 所有权
    public func addSeries(series: QLineSeries): Unit {
        checkValid()
        unsafe { qChartAddSeries(ptr, series.getPtr()) }
    }

    /// 移除所有序列
    public func removeAllSeries(): Unit {
        checkValid()
        unsafe { qChartRemoveAllSeries(ptr) }
    }

    /// 设置图表标题
    public func setTitle(title: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(title)
            qChartSetTitle(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置图表主题（见 ChartTheme 常量）
    public func setTheme(theme: Int32): Unit {
        checkValid()
        unsafe { qChartSetTheme(ptr, theme) }
    }

    /// 根据已添加的序列自动创建默认坐标轴
    public func createDefaultAxes(): Unit {
        checkValid()
        unsafe { qChartCreateDefaultAxes(ptr) }
    }

    /// 设置动画选项（见 ChartAnimation 常量）
    public func setAnimationOptions(options: Int32): Unit {
        checkValid()
        unsafe { qChartSetAnimationOptions(ptr, options) }
    }

    /// 添加坐标轴到指定位置（见 AxisAlignment 常量）；添加后 chart 接管 axis 所有权
    public func addAxis(axis: QValueAxis, alignment: Int32): Unit {
        checkValid()
        unsafe { qChartAddAxis(ptr, axis.getPtr(), alignment) }
    }

    /// 添加分类坐标轴（重载）；添加后 chart 接管 axis 所有权
    public func addAxis(axis: QBarCategoryAxis, alignment: Int32): Unit {
        checkValid()
        unsafe { qChartAddAxis(ptr, axis.getPtr(), alignment) }
    }

    /// 添加分类值轴（重载）；添加后 chart 接管 axis 所有权
    public func addAxis(axis: QCategoryAxis, alignment: Int32): Unit {
        checkValid()
        unsafe { qChartAddAxis(ptr, axis.getPtr(), alignment) }
    }

    /// 获取图例（非拥有式，由 chart 管理生命周期，勿 close）
    public func getLegend(): QLegend {
        checkValid()
        unsafe {
            let legendPtr = qChartLegend(ptr)
            if (legendPtr == 0) {
                throw CreateFailedException("QChart.legend() returned null")
            }
            return QLegend(legendPtr)
        }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已挂载到 QChartView 时由视图级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qChartDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}