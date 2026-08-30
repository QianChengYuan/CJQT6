package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QHorizontalPercentBarSeries FFI 声明
// ============================================================

foreign func qHorizontalPercentBarSeriesCreate(): Int64
foreign func qHorizontalPercentBarSeriesDelete(ptr: Int64): Unit
foreign func qHorizontalPercentBarSeriesAppend(ptr: Int64, setPtr: Int64): Unit
foreign func qHorizontalPercentBarSeriesRemove(ptr: Int64, setPtr: Int64): Unit
foreign func qHorizontalPercentBarSeriesInsert(ptr: Int64, index: Int32, setPtr: Int64): Unit
foreign func qHorizontalPercentBarSeriesCount(ptr: Int64): Int32
foreign func qHorizontalPercentBarSeriesClear(ptr: Int64): Unit
foreign func qHorizontalPercentBarSeriesSetBarWidth(ptr: Int64, width: Float64): Unit
foreign func qHorizontalPercentBarSeriesSetLabelsVisible(ptr: Int64, visible: Int32): Unit
foreign func qHorizontalPercentBarSeriesSetLabelsPosition(ptr: Int64, position: Int32): Unit

// ============================================================
// QHorizontalPercentBarSeries - 水平百分比柱状图序列
//
// 每个类别的柱子按百分比堆叠，总和为 100%。使用方式：
//   let series = QHorizontalPercentBarSeries()
//   let set1 = QBarSet("产品A")
//   set1.append(10.0); set1.append(20.0)
//   series.append(set1)
//   chart.addSeries(series)
//
// 所有权：addSeries 后 QChart 接管 series 所有权；
//         append(set) 后 series 接管 set 所有权。
// ============================================================

public class QHorizontalPercentBarSeries {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QHorizontalPercentBarSeries already deleted")
        }
    }

    /// 创建水平百分比柱状图序列
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe { ptr = qHorizontalPercentBarSeriesCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QHorizontalPercentBarSeries create failed")
        }
        trackObject(ptr)
    }

    /// 追加数据集；追加后 series 接管 set 所有权
    public func append(set: QBarSet): Unit {
        checkValid()
        unsafe { qHorizontalPercentBarSeriesAppend(ptr, set.getPtr()) }
    }

    /// 移除数据集
    public func remove(set: QBarSet): Unit {
        checkValid()
        unsafe { qHorizontalPercentBarSeriesRemove(ptr, set.getPtr()) }
    }

    /// 在指定位置插入数据集
    public func insert(index: Int32, set: QBarSet): Unit {
        checkValid()
        unsafe { qHorizontalPercentBarSeriesInsert(ptr, index, set.getPtr()) }
    }

    /// 数据集数量
    public func count(): Int32 {
        checkValid()
        unsafe { return qHorizontalPercentBarSeriesCount(ptr) }
    }

    /// 清除所有数据集
    public func clear(): Unit {
        checkValid()
        unsafe { qHorizontalPercentBarSeriesClear(ptr) }
    }

    /// 设置柱子宽度
    public func setBarWidth(width: Float64): Unit {
        checkValid()
        unsafe { qHorizontalPercentBarSeriesSetBarWidth(ptr, width) }
    }

    /// 设置标签是否可见
    public func setLabelsVisible(visible: Bool): Unit {
        checkValid()
        unsafe { qHorizontalPercentBarSeriesSetLabelsVisible(ptr, if (visible) { 1 } else { 0 }) }
    }

    /// 设置标签位置（见 BarLabelsPosition 常量）
    public func setLabelsPosition(position: Int32): Unit {
        checkValid()
        unsafe { qHorizontalPercentBarSeriesSetLabelsPosition(ptr, position) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 addSeries 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qHorizontalPercentBarSeriesDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
