package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QCandlestickSeries FFI 声明
// ============================================================

foreign func qCandlestickSeriesCreate(): Int64
foreign func qCandlestickSeriesDelete(ptr: Int64): Unit
foreign func qCandlestickSeriesAppend(ptr: Int64, setPtr: Int64): Unit
foreign func qCandlestickSeriesCount(ptr: Int64): Int32
foreign func qCandlestickSeriesClear(ptr: Int64): Unit
foreign func qCandlestickSeriesSetBodyWidth(ptr: Int64, width: Float64): Unit
foreign func qCandlestickSeriesSetBodyOutlineVisible(ptr: Int64, visible: Int32): Unit
foreign func qCandlestickSeriesSetCapsWidth(ptr: Int64, width: Float64): Unit
foreign func qCandlestickSeriesSetCapsVisible(ptr: Int64, visible: Int32): Unit
foreign func qCandlestickSeriesSetIncreasingColor(ptr: Int64, r: Int32, g: Int32, b: Int32): Unit
foreign func qCandlestickSeriesSetDecreasingColor(ptr: Int64, r: Int32, g: Int32, b: Int32): Unit

// ============================================================
// QCandlestickSeries - K线序列
//
// 包含多根 K 线（QCandlestickSet）。使用方式：
//   let series = QCandlestickSeries()
//   series.setIncreasingColor(255, 0, 0)   // 上涨红色
//   series.setDecreasingColor(0, 255, 0)   // 下跌绿色
//   let candle1 = QCandlestickSet(100.0, 105.0, 95.0, 102.0, 1.0)
//   let candle2 = QCandlestickSet(102.0, 108.0, 100.0, 98.0, 2.0)
//   series.append(candle1)
//   series.append(candle2)
//   chart.addSeries(series)
//
// 所有权：addSeries 后 QChart 接管 series 所有权；
//         append(set) 后 series 接管 set 所有权。
// ============================================================

public class QCandlestickSeries {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QCandlestickSeries already deleted")
        }
    }

    /// 创建 K 线序列
    public init() {
        unsafe { ptr = qCandlestickSeriesCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QCandlestickSeries create failed")
        }
        trackObject(ptr)
    }

    /// 追加 K 线数据集；追加后 series 接管 set 所有权
    public func append(set: QCandlestickSet): Unit {
        checkValid()
        unsafe { qCandlestickSeriesAppend(ptr, set.getPtr()) }
    }

    /// K 线数量
    public func count(): Int32 {
        checkValid()
        unsafe { return qCandlestickSeriesCount(ptr) }
    }

    /// 清除所有 K 线
    public func clear(): Unit {
        checkValid()
        unsafe { qCandlestickSeriesClear(ptr) }
    }

    /// 设置实体宽度
    public func setBodyWidth(width: Float64): Unit {
        checkValid()
        unsafe { qCandlestickSeriesSetBodyWidth(ptr, width) }
    }

    /// 设置实体边框可见性
    public func setBodyOutlineVisible(visible: Bool): Unit {
        checkValid()
        unsafe { qCandlestickSeriesSetBodyOutlineVisible(ptr, if (visible) { 1 } else { 0 }) }
    }

    /// 设置上下影线宽度
    public func setCapsWidth(width: Float64): Unit {
        checkValid()
        unsafe { qCandlestickSeriesSetCapsWidth(ptr, width) }
    }

    /// 设置上下影线可见性
    public func setCapsVisible(visible: Bool): Unit {
        checkValid()
        unsafe { qCandlestickSeriesSetCapsVisible(ptr, if (visible) { 1 } else { 0 }) }
    }

    /// 设置上涨颜色（RGB）
    public func setIncreasingColor(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe { qCandlestickSeriesSetIncreasingColor(ptr, r, g, b) }
    }

    /// 设置下跌颜色（RGB）
    public func setDecreasingColor(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe { qCandlestickSeriesSetDecreasingColor(ptr, r, g, b) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 addSeries 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qCandlestickSeriesDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}