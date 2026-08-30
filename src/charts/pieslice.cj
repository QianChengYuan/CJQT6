package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QPieSlice FFI 声明
// ============================================================

foreign func qPieSliceCreate(): Int64
foreign func qPieSliceCreateLabelValue(label: CString, value: Float64): Int64
foreign func qPieSliceDelete(ptr: Int64): Unit
foreign func qPieSliceSetLabel(ptr: Int64, label: CString): Unit
foreign func qPieSliceLabel(ptr: Int64): CString
foreign func qPieSliceSetValue(ptr: Int64, value: Float64): Unit
foreign func qPieSliceValue(ptr: Int64): Float64
foreign func qPieSliceSetLabelVisible(ptr: Int64, visible: Int32): Unit
foreign func qPieSliceIsLabelVisible(ptr: Int64): Int32
foreign func qPieSliceSetLabelPosition(ptr: Int64, position: Int32): Unit
foreign func qPieSliceLabelPosition(ptr: Int64): Int32
foreign func qPieSliceSetExploded(ptr: Int64, exploded: Int32): Unit
foreign func qPieSliceIsExploded(ptr: Int64): Int32
foreign func qPieSliceSetColor(ptr: Int64, r: Int32, g: Int32, b: Int32, a: Int32): Unit
foreign func qPieSliceSetBorderColor(ptr: Int64, r: Int32, g: Int32, b: Int32, a: Int32): Unit
foreign func qPieSliceSetBorderWidth(ptr: Int64, width: Int32): Unit
foreign func qPieSliceSetLabelColor(ptr: Int64, r: Int32, g: Int32, b: Int32, a: Int32): Unit
foreign func qPieSliceSetLabelArmLengthFactor(ptr: Int64, factor: Float64): Unit
foreign func qPieSliceLabelArmLengthFactor(ptr: Int64): Float64
foreign func qPieSliceSetExplodeDistanceFactor(ptr: Int64, factor: Float64): Unit
foreign func qPieSliceExplodeDistanceFactor(ptr: Int64): Float64
foreign func qPieSlicePercentage(ptr: Int64): Float64
foreign func qPieSliceStartAngle(ptr: Int64): Float64
foreign func qPieSliceAngleSpan(ptr: Int64): Float64

// ============================================================
// 饼图切片标签位置常量（对应 QPieSlice::LabelPosition）
// ============================================================

public class PieSliceLabelPosition {
    public static let outside: Int32 = 0              // LabelOutside
    public static let insideHorizontal: Int32 = 1     // LabelInsideHorizontal
    public static let insideTangential: Int32 = 2     // LabelInsideTangential
    public static let insideNormal: Int32 = 3         // LabelInsideNormal
}

// ============================================================
// QPieSlice - 饼图切片
//
// 表示饼图中的一个切片（扇区）。使用方式：
//   let slice = QPieSlice("产品A", 40.0)
//   slice.setLabelVisible(true)
//   slice.setExploded(true)
//   slice.setColor(255, 0, 0)
//
// 所有权：QPieSeries.append(slice) 后 series 接管 slice 所有权。
// ============================================================

public class QPieSlice {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QPieSlice already deleted")
        }
    }

    /// 创建空切片
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe { ptr = qPieSliceCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QPieSlice create failed")
        }
        trackObject(ptr)
    }

    /// 创建带标签和值的切片
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init(label: String, value: Float64) {
        unsafe {
            let cstr = LibC.mallocCString(label)
            ptr = qPieSliceCreateLabelValue(cstr, value)
            LibC.free(cstr)
        }
        if (ptr == 0) {
            throw CreateFailedException("QPieSlice create failed")
        }
        trackObject(ptr)
    }

    /// 设置切片标签
    public func setLabel(label: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(label)
            qPieSliceSetLabel(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取切片标签
    public func label(): String {
        checkValid()
        unsafe {
            let cstr = qPieSliceLabel(ptr)
            return cstr.toString()
        }
    }

    /// 设置切片值
    public func setValue(value: Float64): Unit {
        checkValid()
        unsafe { qPieSliceSetValue(ptr, value) }
    }

    /// 获取切片值
    public func value(): Float64 {
        checkValid()
        unsafe { return qPieSliceValue(ptr) }
    }

    /// 设置标签是否可见
    public func setLabelVisible(visible: Bool): Unit {
        checkValid()
        unsafe { qPieSliceSetLabelVisible(ptr, if (visible) { 1 } else { 0 }) }
    }

    /// 查询标签是否可见
    public func isLabelVisible(): Bool {
        checkValid()
        unsafe { return qPieSliceIsLabelVisible(ptr) != 0 }
    }

    /// 设置标签位置（见 PieSliceLabelPosition 常量）
    public func setLabelPosition(position: Int32): Unit {
        checkValid()
        unsafe { qPieSliceSetLabelPosition(ptr, position) }
    }

    /// 获取标签位置
    public func labelPosition(): Int32 {
        checkValid()
        unsafe { return qPieSliceLabelPosition(ptr) }
    }

    /// 设置是否爆炸（分离显示）
    public func setExploded(exploded: Bool): Unit {
        checkValid()
        unsafe { qPieSliceSetExploded(ptr, if (exploded) { 1 } else { 0 }) }
    }

    /// 查询是否爆炸
    public func isExploded(): Bool {
        checkValid()
        unsafe { return qPieSliceIsExploded(ptr) != 0 }
    }

    /// 设置切片颜色（RGB）
    public func setColor(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe { qPieSliceSetColor(ptr, r, g, b, 255) }
    }

    /// 设置切片颜色（RGBA）
    public func setColor(r: Int32, g: Int32, b: Int32, a: Int32): Unit {
        checkValid()
        unsafe { qPieSliceSetColor(ptr, r, g, b, a) }
    }

    /// 设置边框颜色（RGB）
    public func setBorderColor(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe { qPieSliceSetBorderColor(ptr, r, g, b, 255) }
    }

    /// 设置边框颜色（RGBA）
    public func setBorderColor(r: Int32, g: Int32, b: Int32, a: Int32): Unit {
        checkValid()
        unsafe { qPieSliceSetBorderColor(ptr, r, g, b, a) }
    }

    /// 设置边框宽度
    public func setBorderWidth(width: Int32): Unit {
        checkValid()
        unsafe { qPieSliceSetBorderWidth(ptr, width) }
    }

    /// 设置标签颜色（RGB）
    public func setLabelColor(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe { qPieSliceSetLabelColor(ptr, r, g, b, 255) }
    }

    /// 设置标签颜色（RGBA）
    public func setLabelColor(r: Int32, g: Int32, b: Int32, a: Int32): Unit {
        checkValid()
        unsafe { qPieSliceSetLabelColor(ptr, r, g, b, a) }
    }

    /// 设置标签臂长因子
    public func setLabelArmLengthFactor(factor: Float64): Unit {
        checkValid()
        unsafe { qPieSliceSetLabelArmLengthFactor(ptr, factor) }
    }

    /// 获取标签臂长因子
    public func labelArmLengthFactor(): Float64 {
        checkValid()
        unsafe { return qPieSliceLabelArmLengthFactor(ptr) }
    }

    /// 设置爆炸距离因子
    public func setExplodeDistanceFactor(factor: Float64): Unit {
        checkValid()
        unsafe { qPieSliceSetExplodeDistanceFactor(ptr, factor) }
    }

    /// 获取爆炸距离因子
    public func explodeDistanceFactor(): Float64 {
        checkValid()
        unsafe { return qPieSliceExplodeDistanceFactor(ptr) }
    }

    /// 获取百分比（只读，由 series 计算）
    public func percentage(): Float64 {
        checkValid()
        unsafe { return qPieSlicePercentage(ptr) }
    }

    /// 获取起始角度（只读）
    public func startAngle(): Float64 {
        checkValid()
        unsafe { return qPieSliceStartAngle(ptr) }
    }

    /// 获取角度跨度（只读）
    public func angleSpan(): Float64 {
        checkValid()
        unsafe { return qPieSliceAngleSpan(ptr) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 append 后由 series 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qPieSliceDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
