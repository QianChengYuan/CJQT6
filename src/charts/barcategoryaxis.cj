package cjqt6.charts

import cjqt6.core.*

// ============================================================
// QBarCategoryAxis FFI 声明
// ============================================================

foreign func qBarCategoryAxisCreate(): Int64
foreign func qBarCategoryAxisDelete(ptr: Int64): Unit
foreign func qBarCategoryAxisAppend(ptr: Int64, category: CString): Unit
foreign func qBarCategoryAxisRemove(ptr: Int64, category: CString): Unit
foreign func qBarCategoryAxisInsert(ptr: Int64, index: Int32, category: CString): Unit
foreign func qBarCategoryAxisReplace(ptr: Int64, oldCat: CString, newCat: CString): Unit
foreign func qBarCategoryAxisClear(ptr: Int64): Unit
foreign func qBarCategoryAxisCount(ptr: Int64): Int32
foreign func qBarCategoryAxisSetMin(ptr: Int64, minCat: CString): Unit
foreign func qBarCategoryAxisSetMax(ptr: Int64, maxCat: CString): Unit
foreign func qBarCategoryAxisSetRange(ptr: Int64, minCat: CString, maxCat: CString): Unit

// ============================================================
// QBarCategoryAxis - 分类坐标轴
//
// 用于柱状图的 X 轴分类标签。使用方式：
//   let axis = QBarCategoryAxis()
//   axis.append("周一")
//   axis.append("周二")
//   axis.append("周三")
//   chart.addAxis(axis, AxisAlignment.bottom)
//
// 所有权：addAxis 后 QChart 接管 axis 所有权，勿主动 close()。
// ============================================================

public class QBarCategoryAxis {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QBarCategoryAxis already deleted")
        }
    }

    /// 创建分类轴
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe { ptr = qBarCategoryAxisCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QBarCategoryAxis create failed")
        }
        trackObject(ptr)
    }

    /// 追加一个分类
    public func append(category: String): Unit {
        checkValid()
        unsafe {
            withCString(category) { c => qBarCategoryAxisAppend(ptr, c) }
        }
    }

    /// 移除指定分类
    public func remove(category: String): Unit {
        checkValid()
        unsafe {
            withCString(category) { c => qBarCategoryAxisRemove(ptr, c) }
        }
    }

    /// 在指定位置插入分类
    public func insert(index: Int32, category: String): Unit {
        checkValid()
        unsafe {
            withCString(category) { c => qBarCategoryAxisInsert(ptr, index, c) }
        }
    }

    /// 替换分类标签
    public func replace(oldCategory: String, newCategory: String): Unit {
        checkValid()
        unsafe {
            let oldCstr = LibC.mallocCString(oldCategory)
            let newCstr = LibC.mallocCString(newCategory)
            qBarCategoryAxisReplace(ptr, oldCstr, newCstr)
            LibC.free(oldCstr)
            LibC.free(newCstr)
        }
    }

    /// 清除所有分类
    public func clear(): Unit {
        checkValid()
        unsafe { qBarCategoryAxisClear(ptr) }
    }

    /// 分类数量
    public func count(): Int32 {
        checkValid()
        unsafe { return qBarCategoryAxisCount(ptr) }
    }

    /// 设置最小分类
    public func setMin(minCategory: String): Unit {
        checkValid()
        unsafe {
            withCString(minCategory) { c => qBarCategoryAxisSetMin(ptr, c) }
        }
    }

    /// 设置最大分类
    public func setMax(maxCategory: String): Unit {
        checkValid()
        unsafe {
            withCString(maxCategory) { c => qBarCategoryAxisSetMax(ptr, c) }
        }
    }

    /// 设置分类范围
    public func setRange(minCategory: String, maxCategory: String): Unit {
        checkValid()
        unsafe {
            let minCstr = LibC.mallocCString(minCategory)
            let maxCstr = LibC.mallocCString(maxCategory)
            qBarCategoryAxisSetRange(ptr, minCstr, maxCstr)
            LibC.free(minCstr)
            LibC.free(maxCstr)
        }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已 addAxis 后由 chart 级联释放，勿主动调用
    public func close(): Unit {
        if (!closed && ptr != 0) {
            untrackObject(ptr)
            unsafe { qBarCategoryAxisDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
