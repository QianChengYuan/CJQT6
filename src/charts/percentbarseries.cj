package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QPercentBarSeries FFI 声明
// ============================================================

foreign func qPercentBarSeriesCreate(): Int64
foreign func qPercentBarSeriesDelete(ptr: Int64): Unit
foreign func qPercentBarSeriesAppend(ptr: Int64, setPtr: Int64): Unit
foreign func qPercentBarSeriesCount(ptr: Int64): Int32
foreign func qPercentBarSeriesClear(ptr: Int64): Unit
foreign func qPercentBarSeriesSetLabelsVisible(ptr: Int64, visible: Int32): Unit

// ============================================================
// QPercentBarSeries - 百分比柱状图序列
//
// 每组数据归一化为 100% 显示。API 与 QBarSeries 一致。使用方式：
//   let series = QPercentBarSeries()
//   let set1 = QBarSet("产品A")
//   set1.append(10.0); set1.append(20.0)
//   series.append(set1)
//   chart.addSeries(series)
//
// 所有权：addSeries 后 QChart 接管 series 所有权；
//         append(set) 后 series 接管 set 所有权。
// ============================================================

public class QPercentBarSeries {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QPercentBarSeries already deleted")
        }
    }

    /// 创建百分比柱状图序列
    public init() {
        unsafe { ptr = qPercentBarSeriesCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QPercentBarSeries create failed")
        }
        trackObject(ptr)
    }

    /// 追加数据集；追加后 series 接管 set 所有权
    public func append(set: QBarSet): Unit {
        checkValid()
        unsafe { qPercentBarSeriesAppend(ptr, set.getPtr()) }
    }

    /// 数据集数量
    public func count(): Int32 {
        checkValid()
        unsafe { return qPercentBarSeriesCount(ptr) }
    }

    /// 清除所有数据集
    public func clear(): Unit {
        checkValid()
        unsafe { qPercentBarSeriesClear(ptr) }
    }

    /// 设置标签是否可见
    public func setLabelsVisible(visible: Bool): Unit {
        checkValid()
        unsafe { qPercentBarSeriesSetLabelsVisible(ptr, if (visible) { 1 } else { 0 }) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 addSeries 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qPercentBarSeriesDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}