package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QPieSeries FFI 声明
// ============================================================

foreign func qPieSeriesCreate(): Int64
foreign func qPieSeriesDelete(ptr: Int64): Unit
foreign func qPieSeriesAppend(ptr: Int64, label: CString, value: Float64): Unit
foreign func qPieSeriesClear(ptr: Int64): Unit
foreign func qPieSeriesCount(ptr: Int64): Int32
foreign func qPieSeriesSum(ptr: Int64): Float64
foreign func qPieSeriesSetHoleSize(ptr: Int64, size: Float64): Unit
foreign func qPieSeriesSetPieSize(ptr: Int64, size: Float64): Unit
foreign func qPieSeriesSetHorizontalPosition(ptr: Int64, pos: Float64): Unit
foreign func qPieSeriesSetVerticalPosition(ptr: Int64, pos: Float64): Unit
foreign func qPieSeriesSetPieStartAngle(ptr: Int64, angle: Float64): Unit
foreign func qPieSeriesSetPieEndAngle(ptr: Int64, angle: Float64): Unit
foreign func qPieSeriesSetLabelsVisible(ptr: Int64, visible: Int32): Unit
foreign func qPieSeriesAppendSlice(ptr: Int64, slicePtr: Int64): Unit

// ============================================================
// QPieSeries - 饼图序列
//
// 用于绘制饼图/环形图。使用方式：
//   let series = QPieSeries()
//   series.append("苹果", 30.0)
//   series.append("香蕉", 25.0)
//   series.append("橙子", 45.0)
//   series.setHoleSize(0.4)  // 环形图
//   chart.addSeries(series)
//
// 所有权：addSeries 后 QChart 接管 series 所有权，勿主动 close()。
// ============================================================

public class QPieSeries {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QPieSeries already deleted")
        }
    }

    /// 创建饼图序列
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe { ptr = qPieSeriesCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QPieSeries create failed")
        }
        trackObject(ptr)
    }

    /// 追加一个切片（标签 + 值）
    public func append(label: String, value: Float64): Unit {
        checkValid()
        unsafe {
            withCString(label) { c => qPieSeriesAppend(ptr, c, value) }
        }
    }

    /// 追加一个 QPieSlice 对象；追加后 series 接管 slice 所有权
    public func append(slice: QPieSlice): Unit {
        checkValid()
        unsafe { qPieSeriesAppendSlice(ptr, slice.getPtr()) }
    }

    /// 清除所有切片
    public func clear(): Unit {
        checkValid()
        unsafe { qPieSeriesClear(ptr) }
    }

    /// 切片数量
    public func count(): Int32 {
        checkValid()
        unsafe { return qPieSeriesCount(ptr) }
    }

    /// 切片值总和
    public func sum(): Float64 {
        checkValid()
        unsafe { return qPieSeriesSum(ptr) }
    }

    /// 设置中心孔大小（0.0~1.0，大于 0 时为环形图）
    public func setHoleSize(size: Float64): Unit {
        checkValid()
        unsafe { qPieSeriesSetHoleSize(ptr, size) }
    }

    /// 设置饼图大小（0.0~1.0，相对视图的比例）
    public func setPieSize(size: Float64): Unit {
        checkValid()
        unsafe { qPieSeriesSetPieSize(ptr, size) }
    }

    /// 设置水平位置（0.0~1.0）
    public func setHorizontalPosition(pos: Float64): Unit {
        checkValid()
        unsafe { qPieSeriesSetHorizontalPosition(ptr, pos) }
    }

    /// 设置垂直位置（0.0~1.0）
    public func setVerticalPosition(pos: Float64): Unit {
        checkValid()
        unsafe { qPieSeriesSetVerticalPosition(ptr, pos) }
    }

    /// 设置起始角度（度）
    public func setPieStartAngle(angle: Float64): Unit {
        checkValid()
        unsafe { qPieSeriesSetPieStartAngle(ptr, angle) }
    }

    /// 设置结束角度（度）
    public func setPieEndAngle(angle: Float64): Unit {
        checkValid()
        unsafe { qPieSeriesSetPieEndAngle(ptr, angle) }
    }

    /// 设置切片标签是否可见
    public func setLabelsVisible(visible: Bool): Unit {
        checkValid()
        unsafe { qPieSeriesSetLabelsVisible(ptr, if (visible) { 1 } else { 0 }) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 addSeries 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qPieSeriesDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
