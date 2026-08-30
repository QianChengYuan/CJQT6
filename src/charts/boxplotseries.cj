package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QBoxPlotSeries FFI 声明
// ============================================================

foreign func qBoxPlotSeriesCreate(): Int64
foreign func qBoxPlotSeriesDelete(ptr: Int64): Unit
foreign func qBoxPlotSeriesAppend(ptr: Int64, boxPtr: Int64): Unit
foreign func qBoxPlotSeriesCount(ptr: Int64): Int32
foreign func qBoxPlotSeriesClear(ptr: Int64): Unit
foreign func qBoxPlotSeriesSetBoxOutlineVisible(ptr: Int64, visible: Int32): Unit
foreign func qBoxPlotSeriesSetBoxWidth(ptr: Int64, width: Float64): Unit

// ============================================================
// QBoxPlotSeries - 箱线图序列
//
// 包含多个 QBoxSet，每个 QBoxSet 是一组五值总结。使用方式：
//   let series = QBoxPlotSeries()
//   let box1 = QBoxSet(10.0, 20.0, 30.0, 40.0, 50.0)
//   let box2 = QBoxSet(15.0, 25.0, 35.0, 45.0, 55.0)
//   series.append(box1)
//   series.append(box2)
//   chart.addSeries(series)
//
// 所有权：addSeries 后 QChart 接管 series 所有权；
//         append(box) 后 series 接管 box 所有权。
// ============================================================

public class QBoxPlotSeries {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QBoxPlotSeries already deleted")
        }
    }

    /// 创建箱线图序列
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe { ptr = qBoxPlotSeriesCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QBoxPlotSeries create failed")
        }
        trackObject(ptr)
    }

    /// 追加数据集；追加后 series 接管 box 所有权
    public func append(box: QBoxSet): Unit {
        checkValid()
        unsafe { qBoxPlotSeriesAppend(ptr, box.getPtr()) }
    }

    /// 数据集数量
    public func count(): Int32 {
        checkValid()
        unsafe { return qBoxPlotSeriesCount(ptr) }
    }

    /// 清除所有数据集
    public func clear(): Unit {
        checkValid()
        unsafe { qBoxPlotSeriesClear(ptr) }
    }

    /// 设置箱体边框可见性
    public func setBoxOutlineVisible(visible: Bool): Unit {
        checkValid()
        unsafe { qBoxPlotSeriesSetBoxOutlineVisible(ptr, if (visible) { 1 } else { 0 }) }
    }

    /// 设置箱体宽度
    public func setBoxWidth(width: Float64): Unit {
        checkValid()
        unsafe { qBoxPlotSeriesSetBoxWidth(ptr, width) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 addSeries 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qBoxPlotSeriesDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
