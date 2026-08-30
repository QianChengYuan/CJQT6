package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QCandlestickSet FFI 声明
// ============================================================

foreign func qCandlestickSetCreate(timestamp: Float64): Int64
foreign func qCandlestickSetCreateOHLC(open: Float64, high: Float64, low: Float64, close: Float64, timestamp: Float64): Int64
foreign func qCandlestickSetDelete(ptr: Int64): Unit
foreign func qCandlestickSetSetTimestamp(ptr: Int64, timestamp: Float64): Unit
foreign func qCandlestickSetTimestamp(ptr: Int64): Float64
foreign func qCandlestickSetSetOpen(ptr: Int64, value: Float64): Unit
foreign func qCandlestickSetOpen(ptr: Int64): Float64
foreign func qCandlestickSetSetHigh(ptr: Int64, value: Float64): Unit
foreign func qCandlestickSetHigh(ptr: Int64): Float64
foreign func qCandlestickSetSetLow(ptr: Int64, value: Float64): Unit
foreign func qCandlestickSetLow(ptr: Int64): Float64
foreign func qCandlestickSetSetClose(ptr: Int64, value: Float64): Unit
foreign func qCandlestickSetClose(ptr: Int64): Float64

// ============================================================
// QCandlestickSet - K线数据集
//
// 表示一根 K 线（OHLC + 时间戳）。使用方式：
//   let candle = QCandlestickSet(100.0, 105.0, 95.0, 102.0, 1.0)
//   series.append(candle)
//
// 或逐步设置：
//   let candle = QCandlestickSet(1.0)
//   candle.setOpen(100.0)
//   candle.setHigh(105.0)
//   candle.setLow(95.0)
//   candle.setClose(102.0)
//
// 所有权：append(set) 后 series 接管 set 所有权。
// ============================================================

public class QCandlestickSet {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QCandlestickSet already deleted")
        }
    }

    /// 创建 K 线数据集，指定时间戳
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init(timestamp: Float64) {
        unsafe { ptr = qCandlestickSetCreate(timestamp) }
        if (ptr == 0) {
            throw CreateFailedException("QCandlestickSet create failed")
        }
        trackObject(ptr)
    }

    /// 创建 K 线数据集，直接指定 OHLC + 时间戳
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init(open: Float64, high: Float64, low: Float64, close: Float64, timestamp: Float64) {
        unsafe { ptr = qCandlestickSetCreateOHLC(open, high, low, close, timestamp) }
        if (ptr == 0) {
            throw CreateFailedException("QCandlestickSet create failed")
        }
        trackObject(ptr)
    }

    /// 设置时间戳
    public func setTimestamp(timestamp: Float64): Unit {
        checkValid()
        unsafe { qCandlestickSetSetTimestamp(ptr, timestamp) }
    }

    /// 获取时间戳
    public func timestamp(): Float64 {
        checkValid()
        unsafe { return qCandlestickSetTimestamp(ptr) }
    }

    /// 设置开盘价
    public func setOpen(value: Float64): Unit {
        checkValid()
        unsafe { qCandlestickSetSetOpen(ptr, value) }
    }

    /// 获取开盘价
    public func open(): Float64 {
        checkValid()
        unsafe { return qCandlestickSetOpen(ptr) }
    }

    /// 设置最高价
    public func setHigh(value: Float64): Unit {
        checkValid()
        unsafe { qCandlestickSetSetHigh(ptr, value) }
    }

    /// 获取最高价
    public func high(): Float64 {
        checkValid()
        unsafe { return qCandlestickSetHigh(ptr) }
    }

    /// 设置最低价
    public func setLow(value: Float64): Unit {
        checkValid()
        unsafe { qCandlestickSetSetLow(ptr, value) }
    }

    /// 获取最低价
    public func low(): Float64 {
        checkValid()
        unsafe { return qCandlestickSetLow(ptr) }
    }

    /// 设置收盘价
    public func setClose(value: Float64): Unit {
        checkValid()
        unsafe { qCandlestickSetSetClose(ptr, value) }
    }

    /// 获取收盘价
    public func closeValue(): Float64 {
        checkValid()
        unsafe { return qCandlestickSetClose(ptr) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 append 后由 series 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qCandlestickSetDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
