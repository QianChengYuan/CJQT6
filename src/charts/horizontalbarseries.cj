package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QHorizontalBarSeries FFI 声明
// ============================================================

foreign func qHorizontalBarSeriesCreate(): Int64
foreign func qHorizontalBarSeriesDelete(ptr: Int64): Unit
foreign func qHorizontalBarSeriesAppend(ptr: Int64, setPtr: Int64): Unit
foreign func qHorizontalBarSeriesRemove(ptr: Int64, setPtr: Int64): Unit
foreign func qHorizontalBarSeriesInsert(ptr: Int64, index: Int32, setPtr: Int64): Unit
foreign func qHorizontalBarSeriesCount(ptr: Int64): Int32
foreign func qHorizontalBarSeriesClear(ptr: Int64): Unit
foreign func qHorizontalBarSeriesSetBarWidth(ptr: Int64, width: Float64): Unit
foreign func qHorizontalBarSeriesSetLabelsVisible(ptr: Int64, visible: Int32): Unit
foreign func qHorizontalBarSeriesSetLabelsPosition(ptr: Int64, position: Int32): Unit

// ============================================================
// QHorizontalBarSeries - 水平柱状图序列
//
// 与 QBarSeries 类似，但柱子水平方向生长。使用方式：
//   let series = QHorizontalBarSeries()
//   let set1 = QBarSet("产品A")
//   set1.append(10.0); set1.append(20.0)
//   series.append(set1)
//   chart.addSeries(series)
//
// 所有权：addSeries 后 QChart 接管 series 所有权；
//         append(set) 后 series 接管 set 所有权。
// ============================================================

public class QHorizontalBarSeries {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QHorizontalBarSeries already deleted")
        }
    }

    /// 创建水平柱状图序列
    public init() {
        unsafe { ptr = qHorizontalBarSeriesCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QHorizontalBarSeries create failed")
        }
        trackObject(ptr)
    }

    /// 追加数据集；追加后 series 接管 set 所有权
    public func append(set: QBarSet): Unit {
        checkValid()
        unsafe { qHorizontalBarSeriesAppend(ptr, set.getPtr()) }
    }

    /// 移除数据集
    public func remove(set: QBarSet): Unit {
        checkValid()
        unsafe { qHorizontalBarSeriesRemove(ptr, set.getPtr()) }
    }

    /// 在指定位置插入数据集
    public func insert(index: Int32, set: QBarSet): Unit {
        checkValid()
        unsafe { qHorizontalBarSeriesInsert(ptr, index, set.getPtr()) }
    }

    /// 数据集数量
    public func count(): Int32 {
        checkValid()
        unsafe { return qHorizontalBarSeriesCount(ptr) }
    }

    /// 清除所有数据集
    public func clear(): Unit {
        checkValid()
        unsafe { qHorizontalBarSeriesClear(ptr) }
    }

    /// 设置柱子宽度
    public func setBarWidth(width: Float64): Unit {
        checkValid()
        unsafe { qHorizontalBarSeriesSetBarWidth(ptr, width) }
    }

    /// 设置标签是否可见
    public func setLabelsVisible(visible: Bool): Unit {
        checkValid()
        unsafe { qHorizontalBarSeriesSetLabelsVisible(ptr, if (visible) { 1 } else { 0 }) }
    }

    /// 设置标签位置（见 BarLabelsPosition 常量）
    public func setLabelsPosition(position: Int32): Unit {
        checkValid()
        unsafe { qHorizontalBarSeriesSetLabelsPosition(ptr, position) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 addSeries 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qHorizontalBarSeriesDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}