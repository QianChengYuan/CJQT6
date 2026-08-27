package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QBoxSet FFI 声明
// ============================================================

foreign func qBoxSetCreate(label: CString): Int64
foreign func qBoxSetCreate5(le: Float64, lq: Float64, m: Float64, uq: Float64, ue: Float64, label: CString): Int64
foreign func qBoxSetDelete(ptr: Int64): Unit
foreign func qBoxSetAppend(ptr: Int64, value: Float64): Unit
foreign func qBoxSetClear(ptr: Int64): Unit
foreign func qBoxSetSetLabel(ptr: Int64, label: CString): Unit
foreign func qBoxSetSetValue(ptr: Int64, index: Int32, value: Float64): Unit
foreign func qBoxSetAt(ptr: Int64, index: Int32): Float64
foreign func qBoxSetCount(ptr: Int64): Int32

// ============================================================
// QBoxSet - 箱线图数据集
//
// 表示一个箱线图的五值总结：下极值、下四分位、中位数、上四分位、上极值。
// 使用方式：
//   let box = QBoxSet("样本A")
//   box.append(10.0)  // 下极值
//   box.append(20.0)  // 下四分位
//   box.append(30.0)  // 中位数
//   box.append(40.0)  // 上四分位
//   box.append(50.0)  // 上极值
//   series.append(box)
//
// 或直接指定五值：
//   let box = QBoxSet(10.0, 20.0, 30.0, 40.0, 50.0)
//
// 所有权：append(box) 后 series 接管 box 所有权。
// ============================================================

public class QBoxSet {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QBoxSet already deleted")
        }
    }

    /// 创建箱线图数据集，指定标签
    public init(label: String) {
        unsafe {
            let cstr = LibC.mallocCString(label)
            ptr = qBoxSetCreate(cstr)
            LibC.free(cstr)
        }
        if (ptr == 0) {
            throw CreateFailedException("QBoxSet create failed")
        }
        trackObject(ptr)
    }

    /// 创建箱线图数据集，直接指定五值（标签默认为空）
    public init(le: Float64, lq: Float64, m: Float64, uq: Float64, ue: Float64) {
        unsafe {
            let cstr = LibC.mallocCString("")
            ptr = qBoxSetCreate5(le, lq, m, uq, ue, cstr)
            LibC.free(cstr)
        }
        if (ptr == 0) {
            throw CreateFailedException("QBoxSet create failed")
        }
        trackObject(ptr)
    }

    /// 追加一个值（按顺序填充五值位置）
    public func append(value: Float64): Unit {
        checkValid()
        unsafe { qBoxSetAppend(ptr, value) }
    }

    /// 清除所有值
    public func clear(): Unit {
        checkValid()
        unsafe { qBoxSetClear(ptr) }
    }

    /// 设置标签
    public func setLabel(label: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(label)
            qBoxSetSetLabel(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置指定位置的值（0~4 对应五值）
    public func setValue(index: Int32, value: Float64): Unit {
        checkValid()
        unsafe { qBoxSetSetValue(ptr, index, value) }
    }

    /// 获取指定位置的值（0~4 对应五值）
    public func at(index: Int32): Float64 {
        checkValid()
        unsafe { return qBoxSetAt(ptr, index) }
    }

    /// 值数量
    public func count(): Int32 {
        checkValid()
        unsafe { return qBoxSetCount(ptr) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 append 后由 series 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qBoxSetDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}