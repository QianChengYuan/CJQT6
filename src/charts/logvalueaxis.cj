package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QLogValueAxis FFI 声明
// ============================================================

foreign func qLogValueAxisCreate(): Int64
foreign func qLogValueAxisDelete(ptr: Int64): Unit
foreign func qLogValueAxisSetMin(ptr: Int64, min: Float64): Unit
foreign func qLogValueAxisMin(ptr: Int64): Float64
foreign func qLogValueAxisSetMax(ptr: Int64, max: Float64): Unit
foreign func qLogValueAxisMax(ptr: Int64): Float64
foreign func qLogValueAxisSetRange(ptr: Int64, min: Float64, max: Float64): Unit
foreign func qLogValueAxisSetLabelFormat(ptr: Int64, format: CString): Unit
foreign func qLogValueAxisLabelFormat(ptr: Int64): CString
foreign func qLogValueAxisSetBase(ptr: Int64, base: Float64): Unit
foreign func qLogValueAxisBase(ptr: Int64): Float64
foreign func qLogValueAxisTickCount(ptr: Int64): Int32
foreign func qLogValueAxisSetMinorTickCount(ptr: Int64, count: Int32): Unit
foreign func qLogValueAxisMinorTickCount(ptr: Int64): Int32

// ============================================================
// QLogValueAxis - 对数坐标轴
//
// 用于科学数据可视化（指数/对数刻度）。使用方式：
//   let axis = QLogValueAxis()
//   axis.setRange(1.0, 10000.0)
//   axis.setBase(10.0)
//   axis.setLabelFormat("%.0f")
//   axis.setMinorTickCount(9)
//   chart.addAxis(axis, AxisAlignment.bottom)
//
// 所有权：addAxis 后 QChart 接管 axis 所有权，勿主动 close()。
// ============================================================

public class QLogValueAxis {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QLogValueAxis already deleted")
        }
    }

    /// 创建对数轴
    public init() {
        unsafe { ptr = qLogValueAxisCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QLogValueAxis create failed")
        }
        trackObject(ptr)
    }

    /// 设置最小值
    public func setMin(min: Float64): Unit {
        checkValid()
        unsafe { qLogValueAxisSetMin(ptr, min) }
    }

    /// 获取最小值
    public func min(): Float64 {
        checkValid()
        unsafe { return qLogValueAxisMin(ptr) }
    }

    /// 设置最大值
    public func setMax(max: Float64): Unit {
        checkValid()
        unsafe { qLogValueAxisSetMax(ptr, max) }
    }

    /// 获取最大值
    public func max(): Float64 {
        checkValid()
        unsafe { return qLogValueAxisMax(ptr) }
    }

    /// 设置范围
    public func setRange(min: Float64, max: Float64): Unit {
        checkValid()
        unsafe { qLogValueAxisSetRange(ptr, min, max) }
    }

    /// 设置刻度标签格式（如 "%.0f"、"%.2e"）
    public func setLabelFormat(format: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(format)
            qLogValueAxisSetLabelFormat(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取刻度标签格式
    public func labelFormat(): String {
        checkValid()
        unsafe {
            let cstr = qLogValueAxisLabelFormat(ptr)
            return cstr.toString()
        }
    }

    /// 设置对数底数（默认 10）
    public func setBase(base: Float64): Unit {
        checkValid()
        unsafe { qLogValueAxisSetBase(ptr, base) }
    }

    /// 获取对数底数
    public func base(): Float64 {
        checkValid()
        unsafe { return qLogValueAxisBase(ptr) }
    }

    /// 获取主刻度数量（只读，由范围和底数决定）
    public func tickCount(): Int32 {
        checkValid()
        unsafe { return qLogValueAxisTickCount(ptr) }
    }

    /// 设置次刻度数量
    public func setMinorTickCount(count: Int32): Unit {
        checkValid()
        unsafe { qLogValueAxisSetMinorTickCount(ptr, count) }
    }

    /// 获取次刻度数量
    public func minorTickCount(): Int32 {
        checkValid()
        unsafe { return qLogValueAxisMinorTickCount(ptr) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 addAxis 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qLogValueAxisDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}