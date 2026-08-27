package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QCategoryAxis FFI 声明
// ============================================================

foreign func qCategoryAxisCreate(): Int64
foreign func qCategoryAxisDelete(ptr: Int64): Unit
foreign func qCategoryAxisAppend(ptr: Int64, label: CString, endValue: Float64): Unit
foreign func qCategoryAxisRemove(ptr: Int64, label: CString): Unit
foreign func qCategoryAxisReplaceLabel(ptr: Int64, oldLabel: CString, newLabel: CString): Unit
foreign func qCategoryAxisSetStartValue(ptr: Int64, min: Float64): Unit
foreign func qCategoryAxisCount(ptr: Int64): Int32
foreign func qCategoryAxisSetLabelsPosition(ptr: Int64, position: Int32): Unit
foreign func qCategoryAxisLabelsPosition(ptr: Int64): Int32


// ============================================================
// 分类轴标签位置常量（对应 QCategoryAxis::AxisLabelsPosition）
// ============================================================

public class CategoryAxisLabelsPosition {
    public static let center: Int32 = 0   // AxisLabelsPositionCenter
    public static let onValue: Int32 = 1  // AxisLabelsPositionOnValue
}

// ============================================================
// QCategoryAxis - 值轴上的分类范围
//
// 在数值轴上划分分类区间并打标签。使用方式：
//   let axis = QCategoryAxis()
//   axis.setRange(0.0, 30.0)
//   axis.append("低", 10.0)
//   axis.append("中", 20.0)
//   axis.append("高", 30.0)
//   axis.setLabelsPosition(CategoryAxisLabelsPosition.onValue)
//   chart.addAxis(axis, AxisAlignment.bottom)
//
// 所有权：addAxis 后 QChart 接管 axis 所有权，勿主动 close()。
// ============================================================

public class QCategoryAxis {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QCategoryAxis already deleted")
        }
    }

    /// 创建分类值轴
    public init() {
        unsafe { ptr = qCategoryAxisCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QCategoryAxis create failed")
        }
        trackObject(ptr)
    }

    /// 追加分类标签及其结束值
    public func append(label: String, endValue: Float64): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(label)
            qCategoryAxisAppend(ptr, cstr, endValue)
            LibC.free(cstr)
        }
    }

    /// 移除指定分类标签
    public func remove(label: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(label)
            qCategoryAxisRemove(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 替换分类标签
    public func replaceLabel(oldLabel: String, newLabel: String): Unit {
        checkValid()
        unsafe {
            let oldCstr = LibC.mallocCString(oldLabel)
            let newCstr = LibC.mallocCString(newLabel)
            qCategoryAxisReplaceLabel(ptr, oldCstr, newCstr)
            LibC.free(oldCstr)
            LibC.free(newCstr)
        }
    }

    /// 设置起始值
    public func setStartValue(min: Float64): Unit {
        checkValid()
        unsafe { qCategoryAxisSetStartValue(ptr, min) }
    }

    /// 分类数量
    public func count(): Int32 {
        checkValid()
        unsafe { return qCategoryAxisCount(ptr) }
    }

    /// 设置标签位置（见 CategoryAxisLabelsPosition 常量）
    public func setLabelsPosition(position: Int32): Unit {
        checkValid()
        unsafe { qCategoryAxisSetLabelsPosition(ptr, position) }
    }

    /// 获取标签位置
    public func labelsPosition(): Int32 {
        checkValid()
        unsafe { return qCategoryAxisLabelsPosition(ptr) }
    }

    // ---- 继承自 QValueAxis 的方法 ----

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
            let cstr = LibC.mallocCString(format)
            qValueAxisSetLabelFormat(ptr, cstr)
            LibC.free(cstr)
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
            unsafe { qCategoryAxisDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}