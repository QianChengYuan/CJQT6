package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QValueAxis FFI 声明
// ============================================================

foreign func qValueAxisCreate(): Int64
foreign func qValueAxisDelete(ptr: Int64): Unit
foreign func qValueAxisSetRange(ptr: Int64, min: Float64, max: Float64): Unit
foreign func qValueAxisSetTickCount(ptr: Int64, count: Int32): Unit
foreign func qValueAxisSetLabelFormat(ptr: Int64, format: CString): Unit
foreign func qValueAxisSetMin(ptr: Int64, min: Float64): Unit
foreign func qValueAxisSetMax(ptr: Int64, max: Float64): Unit

// ============================================================
// QValueAxis - 数值坐标轴
//
// 用于折线图/柱状图的数值轴。使用方式：
//   let axis = QValueAxis()
//   axis.setRange(0.0, 100.0)
//   axis.setTickCount(11)
//   axis.setLabelFormat("%.0f")
//   chart.addAxis(axis, AxisAlignment.bottom)
//
// 所有权：addAxis 后 QChart 接管 axis 所有权，勿主动 close()。
// ============================================================

public class QValueAxis {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QValueAxis already deleted")
        }
    }

    /// 创建数值轴
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe { ptr = qValueAxisCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QValueAxis create failed")
        }
        trackObject(ptr)
    }

    /// 设置轴范围
    public func setRange(min: Float64, max: Float64): Unit {
        checkValid()
        unsafe { qValueAxisSetRange(ptr, min, max) }
    }

    /// 设置刻度数量
    public func setTickCount(count: Int32): Unit {
        checkValid()
        unsafe { qValueAxisSetTickCount(ptr, count) }
    }

    /// 设置刻度标签格式（如 "%.0f"、"%.2f"）
    public func setLabelFormat(format: String): Unit {
        checkValid()
        unsafe {
            withCString(format) { c => qValueAxisSetLabelFormat(ptr, c) }
        }
    }

    /// 设置最小值
    public func setMin(min: Float64): Unit {
        checkValid()
        unsafe { qValueAxisSetMin(ptr, min) }
    }

    /// 设置最大值
    public func setMax(max: Float64): Unit {
        checkValid()
        unsafe { qValueAxisSetMax(ptr, max) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 addAxis 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qValueAxisDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
