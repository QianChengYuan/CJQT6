package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QScatterSeries FFI 声明
// ============================================================

foreign func qScatterSeriesCreate(): Int64
foreign func qScatterSeriesDelete(ptr: Int64): Unit
foreign func qScatterSeriesAppend(ptr: Int64, x: Float64, y: Float64): Unit
foreign func qScatterSeriesSetName(ptr: Int64, name: CString): Unit
foreign func qScatterSeriesCount(ptr: Int64): Int32
foreign func qScatterSeriesSetMarkerShape(ptr: Int64, shape: Int32): Unit
foreign func qScatterSeriesSetMarkerSize(ptr: Int64, size: Float64): Unit
foreign func qScatterSeriesSetColor(ptr: Int64, r: Int32, g: Int32, b: Int32): Unit
foreign func qScatterSeriesSetBorderColor(ptr: Int64, r: Int32, g: Int32, b: Int32): Unit

// ============================================================
// 散点图标记形状常量（对应 QScatterSeries::MarkerShape）
// ============================================================

public class ScatterMarkerShape {
    public static let circle: Int32 = 0           // MarkerShapeCircle
    public static let rectangle: Int32 = 1        // MarkerShapeRectangle
    public static let rotatedRectangle: Int32 = 2 // MarkerShapeRotatedRectangle
    public static let triangle: Int32 = 3         // MarkerShapeTriangle
    public static let star: Int32 = 4             // MarkerShapeStar
    public static let pentagon: Int32 = 5         // MarkerShapePentagon
}

// ============================================================
// QScatterSeries - 散点图序列
//
// 用于绘制散点图。使用方式：
//   let series = QScatterSeries()
//   series.setName("测量点")
//   series.append(1.0, 10.0)
//   series.append(2.0, 25.0)
//   series.append(3.0, 18.0)
//   series.setMarkerShape(ScatterMarkerShape.circle)
//   series.setMarkerSize(10.0)
//   chart.addSeries(series)
//
// 所有权：addSeries 后 QChart 接管 series 所有权，勿主动 close()。
// ============================================================

public class QScatterSeries {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QScatterSeries already deleted")
        }
    }

    /// 创建散点图序列
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe { ptr = qScatterSeriesCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QScatterSeries create failed")
        }
        trackObject(ptr)
    }

    /// 追加一个数据点 (x, y)
    public func append(x: Float64, y: Float64): Unit {
        checkValid()
        unsafe { qScatterSeriesAppend(ptr, x, y) }
    }

    /// 设置序列名称（显示在图例中）
    public func setName(name: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(name)
            qScatterSeriesSetName(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 当前数据点数量
    public func count(): Int32 {
        checkValid()
        unsafe { return qScatterSeriesCount(ptr) }
    }

    /// 设置标记形状（见 ScatterMarkerShape 常量）
    public func setMarkerShape(shape: Int32): Unit {
        checkValid()
        unsafe { qScatterSeriesSetMarkerShape(ptr, shape) }
    }

    /// 设置标记大小
    public func setMarkerSize(size: Float64): Unit {
        checkValid()
        unsafe { qScatterSeriesSetMarkerSize(ptr, size) }
    }

    /// 设置标记颜色（RGB）
    public func setColor(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe { qScatterSeriesSetColor(ptr, r, g, b) }
    }

    /// 设置标记边框颜色（RGB）
    public func setBorderColor(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe { qScatterSeriesSetBorderColor(ptr, r, g, b) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 addSeries 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qScatterSeriesDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
