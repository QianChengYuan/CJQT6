package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QLineSeries FFI 声明
// ============================================================

foreign func qLineSeriesCreate(): Int64
foreign func qLineSeriesDelete(ptr: Int64): Unit
foreign func qLineSeriesAppend(ptr: Int64, x: Float64, y: Float64): Unit
foreign func qLineSeriesSetName(ptr: Int64, name: CString): Unit
foreign func qLineSeriesCount(ptr: Int64): Int32

// ============================================================
// QLineSeries - 折线序列
//
// 用于绘制折线图。使用方式：
//   let series = QLineSeries()
//   series.setName("温度")
//   series.append(0.0, 10.0)
//   series.append(1.0, 20.0)
//   series.append(2.0, 15.0)
//   chart.addSeries(series)
//
// 所有权：addSeries 后 QChart 接管 series 所有权，勿主动 close()。
// ============================================================

public class QLineSeries {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QLineSeries already deleted")
        }
    }

    /// 创建折线序列
    public init() {
        unsafe { ptr = qLineSeriesCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QLineSeries create failed")
        }
        trackObject(ptr)
    }

    /// 追加一个数据点 (x, y)
    public func append(x: Float64, y: Float64): Unit {
        checkValid()
        unsafe { qLineSeriesAppend(ptr, x, y) }
    }

    /// 设置序列名称（显示在图例中）
    public func setName(name: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(name)
            qLineSeriesSetName(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 当前数据点数量
    public func count(): Int32 {
        checkValid()
        unsafe { qLineSeriesCount(ptr) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 addSeries 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qLineSeriesDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}