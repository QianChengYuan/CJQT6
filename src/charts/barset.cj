package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QBarSet FFI 声明
// ============================================================

foreign func qBarSetCreate(label: CString): Int64
foreign func qBarSetDelete(ptr: Int64): Unit
foreign func qBarSetAppend(ptr: Int64, value: Float64): Unit
foreign func qBarSetInsert(ptr: Int64, index: Int32, value: Float64): Unit
foreign func qBarSetRemove(ptr: Int64, index: Int32, count: Int32): Unit
foreign func qBarSetReplace(ptr: Int64, index: Int32, value: Float64): Unit
foreign func qBarSetCount(ptr: Int64): Int32
foreign func qBarSetSum(ptr: Int64): Float64
foreign func qBarSetSetLabel(ptr: Int64, label: CString): Unit
foreign func qBarSetColor(ptr: Int64, r: Int32, g: Int32, b: Int32): Unit
foreign func qBarSetSetBorderColor(ptr: Int64, r: Int32, g: Int32, b: Int32): Unit

// ============================================================
// QBarSet - 柱状图数据集
//
// 一组柱状图数据（如某产品各季度销量）。使用方式：
//   let set = QBarSet("产品A")
//   set.append(10.0)
//   set.append(20.0)
//   set.append(15.0)
//   barSeries.append(set)
//
// 所有权：append 到 QBarSeries 后由 series 接管，勿主动 close()。
// ============================================================

public class QBarSet {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QBarSet already deleted")
        }
    }

    /// 创建数据集，指定标签
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init(label: String) {
        unsafe {
            let cstr = LibC.mallocCString(label)
            ptr = qBarSetCreate(cstr)
            LibC.free(cstr)
        }
        if (ptr == 0) {
            throw CreateFailedException("QBarSet create failed")
        }
        trackObject(ptr)
    }

    /// 追加一个值
    public func append(value: Float64): Unit {
        checkValid()
        unsafe { qBarSetAppend(ptr, value) }
    }

    /// 在指定位置插入值
    public func insert(index: Int32, value: Float64): Unit {
        checkValid()
        unsafe { qBarSetInsert(ptr, index, value) }
    }

    /// 从指定位置移除 count 个值
    public func remove(index: Int32, count!: Int32 = 1): Unit {
        checkValid()
        unsafe { qBarSetRemove(ptr, index, count) }
    }

    /// 替换指定位置的值
    public func replace(index: Int32, value: Float64): Unit {
        checkValid()
        unsafe { qBarSetReplace(ptr, index, value) }
    }

    /// 值数量
    public func count(): Int32 {
        checkValid()
        unsafe { return qBarSetCount(ptr) }
    }

    /// 值总和
    public func sum(): Float64 {
        checkValid()
        unsafe { return qBarSetSum(ptr) }
    }

    /// 设置标签
    public func setLabel(label: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(label)
            qBarSetSetLabel(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置柱子颜色（RGB）
    public func setColor(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe { qBarSetColor(ptr, r, g, b) }
    }

    /// 设置边框颜色（RGB）
    public func setBorderColor(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe { qBarSetSetBorderColor(ptr, r, g, b) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 append 到 QBarSeries 后由 series 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qBarSetDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
