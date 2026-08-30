package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QDateTimeAxis FFI 声明
// ============================================================

foreign func qDateTimeAxisCreate(): Int64
foreign func qDateTimeAxisDelete(ptr: Int64): Unit
foreign func qDateTimeAxisSetMin(ptr: Int64, secsSinceEpoch: Float64): Unit
foreign func qDateTimeAxisMin(ptr: Int64): Float64
foreign func qDateTimeAxisSetMax(ptr: Int64, secsSinceEpoch: Float64): Unit
foreign func qDateTimeAxisMax(ptr: Int64): Float64
foreign func qDateTimeAxisSetRange(ptr: Int64, minSecs: Float64, maxSecs: Float64): Unit
foreign func qDateTimeAxisSetFormat(ptr: Int64, format: CString): Unit
foreign func qDateTimeAxisFormat(ptr: Int64): CString
foreign func qDateTimeAxisSetTickCount(ptr: Int64, count: Int32): Unit
foreign func qDateTimeAxisTickCount(ptr: Int64): Int32

// ============================================================
// QDateTimeAxis - 日期时间坐标轴
//
// 用于 K 线图、时间序列等基于时间的图表。使用方式：
//   let axis = QDateTimeAxis()
//   axis.setFormat("yyyy-MM-dd")
//   axis.setRange(1787616000.0, 1787961600.0)  // Unix 时间戳秒
//   axis.setTickCount(5)
//   chart.addAxis(axis, AxisAlignment.bottom)
//
// 时间戳用 Unix 秒数（Float64），桥接层自动转 QDateTime。
//
// 所有权：addAxis 后 QChart 接管 axis 所有权，勿主动 close()。
// ============================================================

public class QDateTimeAxis {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QDateTimeAxis already deleted")
        }
    }

    /// 创建日期时间轴
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe { ptr = qDateTimeAxisCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QDateTimeAxis create failed")
        }
        trackObject(ptr)
    }

    /// 设置最小值（Unix 时间戳秒）
    public func setMin(secsSinceEpoch: Float64): Unit {
        checkValid()
        unsafe { qDateTimeAxisSetMin(ptr, secsSinceEpoch) }
    }

    /// 获取最小值（Unix 时间戳秒）
    public func min(): Float64 {
        checkValid()
        unsafe { return qDateTimeAxisMin(ptr) }
    }

    /// 设置最大值（Unix 时间戳秒）
    public func setMax(secsSinceEpoch: Float64): Unit {
        checkValid()
        unsafe { qDateTimeAxisSetMax(ptr, secsSinceEpoch) }
    }

    /// 获取最大值（Unix 时间戳秒）
    public func max(): Float64 {
        checkValid()
        unsafe { return qDateTimeAxisMax(ptr) }
    }

    /// 设置范围（Unix 时间戳秒）
    public func setRange(minSecs: Float64, maxSecs: Float64): Unit {
        checkValid()
        unsafe { qDateTimeAxisSetRange(ptr, minSecs, maxSecs) }
    }

    /// 设置日期格式（如 "yyyy-MM-dd"、"MM/dd hh:mm"）
    public func setFormat(format: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(format)
            qDateTimeAxisSetFormat(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取日期格式
    public func format(): String {
        checkValid()
        unsafe {
            let cstr = qDateTimeAxisFormat(ptr)
            return cstr.toString()
        }
    }

    /// 设置刻度数量
    public func setTickCount(count: Int32): Unit {
        checkValid()
        unsafe { qDateTimeAxisSetTickCount(ptr, count) }
    }

    /// 获取刻度数量
    public func tickCount(): Int32 {
        checkValid()
        unsafe { return qDateTimeAxisTickCount(ptr) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 addAxis 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qDateTimeAxisDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
