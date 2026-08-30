package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QStackedBarSeries FFI 声明
// ============================================================

foreign func qStackedBarSeriesCreate(): Int64
foreign func qStackedBarSeriesDelete(ptr: Int64): Unit
foreign func qStackedBarSeriesAppend(ptr: Int64, setPtr: Int64): Unit
foreign func qStackedBarSeriesCount(ptr: Int64): Int32
foreign func qStackedBarSeriesClear(ptr: Int64): Unit
foreign func qStackedBarSeriesSetLabelsVisible(ptr: Int64, visible: Int32): Unit

// ============================================================
// QStackedBarSeries - 堆叠柱状图序列
//
// 同组数据堆叠显示。API 与 QBarSeries 一致。使用方式：
//   let series = QStackedBarSeries()
//   let set1 = QBarSet("产品A")
//   set1.append(10.0); set1.append(20.0)
//   let set2 = QBarSet("产品B")
//   set2.append(15.0); set2.append(25.0)
//   series.append(set1)
//   series.append(set2)
//   chart.addSeries(series)
//
// 所有权：addSeries 后 QChart 接管 series 所有权；
//         append(set) 后 series 接管 set 所有权。
// ============================================================

public class QStackedBarSeries {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QStackedBarSeries already deleted")
        }
    }

    /// 创建堆叠柱状图序列
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe { ptr = qStackedBarSeriesCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QStackedBarSeries create failed")
        }
        trackObject(ptr)
    }

    /// 追加数据集；追加后 series 接管 set 所有权
    public func append(set: QBarSet): Unit {
        checkValid()
        unsafe { qStackedBarSeriesAppend(ptr, set.getPtr()) }
    }

    /// 数据集数量
    public func count(): Int32 {
        checkValid()
        unsafe { return qStackedBarSeriesCount(ptr) }
    }

    /// 清除所有数据集
    public func clear(): Unit {
        checkValid()
        unsafe { qStackedBarSeriesClear(ptr) }
    }

    /// 设置标签是否可见
    public func setLabelsVisible(visible: Bool): Unit {
        checkValid()
        unsafe { qStackedBarSeriesSetLabelsVisible(ptr, if (visible) { 1 } else { 0 }) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 addSeries 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qStackedBarSeriesDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
