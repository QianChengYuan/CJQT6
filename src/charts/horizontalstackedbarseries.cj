package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QHorizontalStackedBarSeries FFI 声明
// ============================================================

foreign func qHorizontalStackedBarSeriesCreate(): Int64
foreign func qHorizontalStackedBarSeriesDelete(ptr: Int64): Unit
foreign func qHorizontalStackedBarSeriesAppend(ptr: Int64, setPtr: Int64): Unit
foreign func qHorizontalStackedBarSeriesRemove(ptr: Int64, setPtr: Int64): Unit
foreign func qHorizontalStackedBarSeriesInsert(ptr: Int64, index: Int32, setPtr: Int64): Unit
foreign func qHorizontalStackedBarSeriesCount(ptr: Int64): Int32
foreign func qHorizontalStackedBarSeriesClear(ptr: Int64): Unit
foreign func qHorizontalStackedBarSeriesSetBarWidth(ptr: Int64, width: Float64): Unit
foreign func qHorizontalStackedBarSeriesSetLabelsVisible(ptr: Int64, visible: Int32): Unit
foreign func qHorizontalStackedBarSeriesSetLabelsPosition(ptr: Int64, position: Int32): Unit

// ============================================================
// QHorizontalStackedBarSeries - 水平堆叠柱状图序列
//
// 每个类别的柱子按实际值堆叠。使用方式：
//   let series = QHorizontalStackedBarSeries()
//   let set1 = QBarSet("产品A")
//   set1.append(10.0); set1.append(20.0)
//   series.append(set1)
//   chart.addSeries(series)
//
// 所有权：addSeries 后 QChart 接管 series 所有权；
//         append(set) 后 series 接管 set 所有权。
// ============================================================

public class QHorizontalStackedBarSeries {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QHorizontalStackedBarSeries already deleted")
        }
    }

    /// 创建水平堆叠柱状图序列
    public init() {
        unsafe { ptr = qHorizontalStackedBarSeriesCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QHorizontalStackedBarSeries create failed")
        }
        trackObject(ptr)
    }

    /// 追加数据集；追加后 series 接管 set 所有权
    public func append(set: QBarSet): Unit {
        checkValid()
        unsafe { qHorizontalStackedBarSeriesAppend(ptr, set.getPtr()) }
    }

    /// 移除数据集
    public func remove(set: QBarSet): Unit {
        checkValid()
        unsafe { qHorizontalStackedBarSeriesRemove(ptr, set.getPtr()) }
    }

    /// 在指定位置插入数据集
    public func insert(index: Int32, set: QBarSet): Unit {
        checkValid()
        unsafe { qHorizontalStackedBarSeriesInsert(ptr, index, set.getPtr()) }
    }

    /// 数据集数量
    public func count(): Int32 {
        checkValid()
        unsafe { return qHorizontalStackedBarSeriesCount(ptr) }
    }

    /// 清除所有数据集
    public func clear(): Unit {
        checkValid()
        unsafe { qHorizontalStackedBarSeriesClear(ptr) }
    }

    /// 设置柱子宽度
    public func setBarWidth(width: Float64): Unit {
        checkValid()
        unsafe { qHorizontalStackedBarSeriesSetBarWidth(ptr, width) }
    }

    /// 设置标签是否可见
    public func setLabelsVisible(visible: Bool): Unit {
        checkValid()
        unsafe { qHorizontalStackedBarSeriesSetLabelsVisible(ptr, if (visible) { 1 } else { 0 }) }
    }

    /// 设置标签位置（见 BarLabelsPosition 常量）
    public func setLabelsPosition(position: Int32): Unit {
        checkValid()
        unsafe { qHorizontalStackedBarSeriesSetLabelsPosition(ptr, position) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 addSeries 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qHorizontalStackedBarSeriesDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}