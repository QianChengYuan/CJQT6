package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QPolarChart FFI 声明
// ============================================================

foreign func qPolarChartCreate(): Int64
foreign func qPolarChartDelete(ptr: Int64): Unit
foreign func qPolarChartAddAxis(ptr: Int64, axisPtr: Int64, polarOrientation: Int32): Unit

// ============================================================
// 极坐标方向常量（对应 QPolarChart::PolarOrientation）
// ============================================================

public class PolarOrientation {
    public static let radial: Int32 = 0x1   // 径向（从圆心向外）
    public static let angular: Int32 = 0x2  // 角向（沿圆周）
}

// ============================================================
// QPolarChart - 极坐标图
//
// 继承 QChart，将数据以极坐标方式显示。与 QChart 的区别：
// - addAxis 使用 PolarOrientation（径向/角向）而非 AxisAlignment
// - 自动创建极坐标轴
//
// 使用方式：
//   let polar = QPolarChart()
//   let series = QLineSeries()
//   series.append(0.0, 10.0)
//   series.append(90.0, 20.0)
//   series.append(180.0, 15.0)
//   polar.addSeries(series)
//   polar.createDefaultAxes()
//
// 所有权链与 QChart 一致：QChartView → QPolarChart → Series/Axis
// ============================================================

public class QPolarChart {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QPolarChart already deleted")
        }
    }

    /// 创建极坐标图
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe { ptr = qPolarChartCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QPolarChart create failed")
        }
        trackObject(ptr)
    }

    // ---- addSeries 重载（复用 QChart 的 FFI） ----

    /// 添加折线序列
    public func addSeries(series: QLineSeries): Unit {
        checkValid()
        unsafe { qChartAddSeries(ptr, series.getPtr()) }
    }

    /// 添加柱状图序列
    public func addSeries(series: QBarSeries): Unit {
        checkValid()
        unsafe { qChartAddSeries(ptr, series.getPtr()) }
    }

    /// 添加饼图序列
    public func addSeries(series: QPieSeries): Unit {
        checkValid()
        unsafe { qChartAddSeries(ptr, series.getPtr()) }
    }

    /// 添加散点图序列
    public func addSeries(series: QScatterSeries): Unit {
        checkValid()
        unsafe { qChartAddSeries(ptr, series.getPtr()) }
    }

    /// 添加区域图序列
    public func addSeries(series: QAreaSeries): Unit {
        checkValid()
        unsafe { qChartAddSeries(ptr, series.getPtr()) }
    }

    /// 添加样条曲线序列
    public func addSeries(series: QSplineSeries): Unit {
        checkValid()
        unsafe { qChartAddSeries(ptr, series.getPtr()) }
    }

    /// 添加百分比柱状图序列
    public func addSeries(series: QPercentBarSeries): Unit {
        checkValid()
        unsafe { qChartAddSeries(ptr, series.getPtr()) }
    }

    /// 添加堆叠柱状图序列
    public func addSeries(series: QStackedBarSeries): Unit {
        checkValid()
        unsafe { qChartAddSeries(ptr, series.getPtr()) }
    }

    /// 添加箱线图序列
    public func addSeries(series: QBoxPlotSeries): Unit {
        checkValid()
        unsafe { qChartAddSeries(ptr, series.getPtr()) }
    }

    /// 添加 K 线序列
    public func addSeries(series: QCandlestickSeries): Unit {
        checkValid()
        unsafe { qChartAddSeries(ptr, series.getPtr()) }
    }

    // ---- 其他方法（复用 QChart 的 FFI） ----

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

    // ---- addAxis（极坐标特有，使用 PolarOrientation） ----

    /// 添加数值坐标轴到指定极坐标方向；添加后 chart 接管 axis 所有权
    public func addAxis(axis: QValueAxis, polarOrientation: Int32): Unit {
        checkValid()
        unsafe { qPolarChartAddAxis(ptr, axis.getPtr(), polarOrientation) }
    }

    /// 添加分类坐标轴到指定极坐标方向（重载）
    public func addAxis(axis: QBarCategoryAxis, polarOrientation: Int32): Unit {
        checkValid()
        unsafe { qPolarChartAddAxis(ptr, axis.getPtr(), polarOrientation) }
    }

    /// 添加分类值轴到指定极坐标方向（重载）
    public func addAxis(axis: QCategoryAxis, polarOrientation: Int32): Unit {
        checkValid()
        unsafe { qPolarChartAddAxis(ptr, axis.getPtr(), polarOrientation) }
    }

    /// 添加日期时间轴到指定极坐标方向（重载）
    public func addAxis(axis: QDateTimeAxis, polarOrientation: Int32): Unit {
        checkValid()
        unsafe { qPolarChartAddAxis(ptr, axis.getPtr(), polarOrientation) }
    }

    /// 添加对数轴到指定极坐标方向（重载）
    public func addAxis(axis: QLogValueAxis, polarOrientation: Int32): Unit {
        checkValid()
        unsafe { qPolarChartAddAxis(ptr, axis.getPtr(), polarOrientation) }
    }

    /// 获取图例（非拥有式，由 chart 管理生命周期，勿 close）
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public func getLegend(): QLegend {
        checkValid()
        unsafe {
            let legendPtr = qChartLegend(ptr)
            if (legendPtr == 0) {
                throw CreateFailedException("QPolarChart.legend() returned null")
            }
            return QLegend(legendPtr)
        }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已挂载到 QChartView 时由视图级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qPolarChartDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
