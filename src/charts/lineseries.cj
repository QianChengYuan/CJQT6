package cjqt6.charts

import cjqt6.core.*
import cjqt6.paint.*

// ============================================================
// QLineSeries FFI 声明
// ============================================================

foreign func qLineSeriesCreate(): Int64

foreign func qLineSeriesDelete(ptr: Int64): Unit

foreign func qLineSeriesAppend(ptr: Int64, x: Float64, y: Float64): Unit

foreign func qLineSeriesSetName(ptr: Int64, name: CString): Unit

foreign func qLineSeriesCount(ptr: Int64): Int32

foreign func qLineSeriesSetColor(ptr: Int64, r: Int32, g: Int32, b: Int32): Unit

foreign func qLineSeriesSetColorA(ptr: Int64, r: Int32, g: Int32, b: Int32, a: Int32): Unit

foreign func qLineSeriesSetPen(ptr: Int64, penPtr: Int64): Unit

foreign func qLineSeriesClear(ptr: Int64): Unit

// ============================================================
// QLineSeries - 折线序列
//
// 用于绘制折线图。使用方式：
//   let series = QLineSeries()
//   series.setName("温度")
//   series.append(0.0, 10.0)
//   series.append(1.0, 20.0)
//   series.append(2.0, 15.0)
//   chart.addSeries(series)
//
// 所有权：addSeries 后 QChart 接管 series 所有权，勿主动 close()。
// ============================================================

public class QLineSeries {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QLineSeries already deleted")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QLineSeries 底层 Qt 对象已失效")
        }
    }

    /// 创建折线序列
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe { ptr = qLineSeriesCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QLineSeries create failed")
        }
        trackObject(ptr)
    }

    /// 追加一个数据点 (x, y)
    public func append(x: Float64, y: Float64): Unit {
        checkValid()
        unsafe { qLineSeriesAppend(ptr, x, y) }
    }

    /// 设置序列名称（显示在图例中）
    public func setName(name: String): Unit {
        checkValid()
        unsafe {
            withCString(name) {c => qLineSeriesSetName(ptr, c)}
        }
    }

    /// 当前数据点数量
    public func count(): Int32 {
        checkValid()
        unsafe { qLineSeriesCount(ptr) }
    }

    /// 设置线条颜色（与 QScatterSeries / QAreaSeries 的 setColor 同名同义）
    public func setColor(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe { qLineSeriesSetColor(ptr, r, g, b) }
    }

    /// 设置线条颜色（含透明度，取值 0-255）
    public func setColor(r: Int32, g: Int32, b: Int32, a: Int32): Unit {
        checkValid()
        unsafe { qLineSeriesSetColorA(ptr, r, g, b, a) }
    }

    /// 设置画笔（线宽/线型等由 QPen 决定）
    public func setPen(pen: QPen): Unit {
        checkValid()
        unsafe { qLineSeriesSetPen(ptr, pen.getPtr()) }
    }

    /// 清空全部数据点（保留命名与样式），可原地复用同一序列继续追加
    public func clear(): Unit {
        checkValid()
        unsafe { qLineSeriesClear(ptr) }
    }

    public func getPtr(): Int64 {
        ptr
    }

    /// 释放资源；已 addSeries 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            // 级联销毁守卫：对象已被父对象（chart/view）接管并销毁时，只注销不 delete，避免 use-after-free
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            unsafe { qLineSeriesDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
