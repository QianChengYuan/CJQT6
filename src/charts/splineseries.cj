package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QSplineSeries FFI 声明
// ============================================================

foreign func qSplineSeriesCreate(): Int64
foreign func qSplineSeriesDelete(ptr: Int64): Unit
foreign func qSplineSeriesAppend(ptr: Int64, x: Float64, y: Float64): Unit
foreign func qSplineSeriesSetName(ptr: Int64, name: CString): Unit
foreign func qSplineSeriesCount(ptr: Int64): Int32

// ============================================================
// QSplineSeries - 样条曲线序列
//
// 绘制平滑样条曲线，API 与 QLineSeries 一致。使用方式：
//   let series = QSplineSeries()
//   series.setName("平滑曲线")
//   series.append(0.0, 10.0)
//   series.append(1.0, 20.0)
//   chart.addSeries(series)
//
// 所有权：addSeries 后 QChart 接管 series 所有权，勿主动 close()。
// ============================================================

public class QSplineSeries {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QSplineSeries already deleted")
        }
    }

    /// 创建样条曲线序列
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe { ptr = qSplineSeriesCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QSplineSeries create failed")
        }
        trackObject(ptr)
    }

    /// 追加一个数据点 (x, y)
    public func append(x: Float64, y: Float64): Unit {
        checkValid()
        unsafe { qSplineSeriesAppend(ptr, x, y) }
    }

    /// 设置序列名称（显示在图例中）
    public func setName(name: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(name)
            qSplineSeriesSetName(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 当前数据点数量
    public func count(): Int32 {
        checkValid()
        unsafe { return qSplineSeriesCount(ptr) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 addSeries 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qSplineSeriesDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
