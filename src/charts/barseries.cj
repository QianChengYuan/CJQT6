package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QBarSeries FFI 声明
// ============================================================

foreign func qBarSeriesCreate(): Int64
foreign func qBarSeriesDelete(ptr: Int64): Unit
foreign func qBarSeriesAppend(ptr: Int64, setPtr: Int64): Unit
foreign func qBarSeriesRemove(ptr: Int64, setPtr: Int64): Unit
foreign func qBarSeriesInsert(ptr: Int64, index: Int32, setPtr: Int64): Unit
foreign func qBarSeriesCount(ptr: Int64): Int32
foreign func qBarSeriesClear(ptr: Int64): Unit
foreign func qBarSeriesSetBarWidth(ptr: Int64, width: Float64): Unit
foreign func qBarSeriesSetLabelsVisible(ptr: Int64, visible: Int32): Unit
foreign func qBarSeriesSetLabelsPosition(ptr: Int64, position: Int32): Unit

// ============================================================
// 柱状图标签位置常量（对应 QAbstractBarSeries::LabelsPosition）
// ============================================================

public class BarLabelsPosition {
    public static let center: Int32 = 0       // LabelsCenter
    public static let insideEnd: Int32 = 1    // LabelsInsideEnd
    public static let insideBase: Int32 = 2   // LabelsInsideBase
    public static let outsideEnd: Int32 = 3   // LabelsOutsideEnd
}

// ============================================================
// QBarSeries - 柱状图序列
//
// 包含多个 QBarSet，每个 QBarSet 是一组数据。使用方式：
//   let series = QBarSeries()
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

public class QBarSeries {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QBarSeries already deleted")
        }
    }

    /// 创建柱状图序列
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe { ptr = qBarSeriesCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QBarSeries create failed")
        }
        trackObject(ptr)
    }

    /// 追加数据集；追加后 series 接管 set 所有权
    public func append(set: QBarSet): Unit {
        checkValid()
        unsafe { qBarSeriesAppend(ptr, set.getPtr()) }
    }

    /// 移除数据集
    public func remove(set: QBarSet): Unit {
        checkValid()
        unsafe { qBarSeriesRemove(ptr, set.getPtr()) }
    }

    /// 在指定位置插入数据集
    public func insert(index: Int32, set: QBarSet): Unit {
        checkValid()
        unsafe { qBarSeriesInsert(ptr, index, set.getPtr()) }
    }

    /// 数据集数量
    public func count(): Int32 {
        checkValid()
        unsafe { return qBarSeriesCount(ptr) }
    }

    /// 清除所有数据集
    public func clear(): Unit {
        checkValid()
        unsafe { qBarSeriesClear(ptr) }
    }

    /// 设置柱子宽度
    public func setBarWidth(width: Float64): Unit {
        checkValid()
        unsafe { qBarSeriesSetBarWidth(ptr, width) }
    }

    /// 设置标签是否可见
    public func setLabelsVisible(visible: Bool): Unit {
        checkValid()
        unsafe { qBarSeriesSetLabelsVisible(ptr, if (visible) { 1 } else { 0 }) }
    }

    /// 设置标签位置（见 BarLabelsPosition 常量）
    public func setLabelsPosition(position: Int32): Unit {
        checkValid()
        unsafe { qBarSeriesSetLabelsPosition(ptr, position) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 addSeries 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qBarSeriesDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
