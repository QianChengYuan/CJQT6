package cjqt6.views

import cjqt6.core.*

// ============================================================
// QSortFilterProxyModel FFI declarations
// ============================================================

foreign func qSortFilterProxyModelCreate(): Int64
foreign func qSortFilterProxyModelSetSourceModel(ptr: Int64, modelPtr: Int64): Unit
foreign func qSortFilterProxyModelSetFilterRegularExpression(ptr: Int64, pattern: CString): Unit
foreign func qSortFilterProxyModelSetFilterFixedString(ptr: Int64, pattern: CString): Unit
foreign func qSortFilterProxyModelSetFilterKeyColumn(ptr: Int64, col: Int32): Unit
foreign func qSortFilterProxyModelFilterKeyColumn(ptr: Int64): Int32
foreign func qSortFilterProxyModelSetFilterRole(ptr: Int64, role: Int32): Unit
foreign func qSortFilterProxyModelFilterRole(ptr: Int64): Int32
foreign func qSortFilterProxyModelSetSortRole(ptr: Int64, role: Int32): Unit
foreign func qSortFilterProxyModelSortRole(ptr: Int64): Int32
foreign func qSortFilterProxyModelSetDynamicSortFilter(ptr: Int64, enable: Int32): Unit
foreign func qSortFilterProxyModelDynamicSortFilter(ptr: Int64): Int32
foreign func qSortFilterProxyModelSort(ptr: Int64, column: Int32, order: Int32): Unit
foreign func qSortFilterProxyModelSortOrder(ptr: Int64): Int32
foreign func qSortFilterProxyModelMapToSource(ptr: Int64, proxyRow: Int32, proxyCol: Int32): Int64
foreign func qSortFilterProxyModelMapFromSource(ptr: Int64, sourceRow: Int32, sourceCol: Int32, sourceModelPtr: Int64): Int64
foreign func qSortFilterProxyModelSetFilterCaseSensitivity(ptr: Int64, cs: Int32): Unit
foreign func qSortFilterProxyModelFilterCaseSensitivity(ptr: Int64): Int32
foreign func qSortFilterProxyModelInvalidate(ptr: Int64): Unit
foreign func qSortFilterProxyModelSetFilterWildcard(ptr: Int64, pattern: CString): Unit
foreign func qSortFilterProxyModelRowCount(ptr: Int64): Int32
foreign func qSortFilterProxyModelColumnCount(ptr: Int64): Int32
foreign func qSortFilterProxyModelDelete(ptr: Int64): Unit


// ============================================================
// 排序常量
// ============================================================
public class SortOrder {
    public static func ascending(): Int32 { 0 }
    public static func descending(): Int32 { 1 }
}

// ============================================================
// 大小写敏感性
// ============================================================
public class CaseSensitivity {
    public static func insensitive(): Int32 { 0 }
    public static func sensitive(): Int32 { 1 }
}


// ============================================================
// QSortFilterProxyModel - 排序过滤代理模型
// ============================================================
public class QSortFilterProxyModel {
    private var ptr: Int64 = 0

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0) {
            throw ResourceDisposedException("QSortFilterProxyModel already deleted")
        }
    }

    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qSortFilterProxyModelCreate()
        }
        if (ptr == 0) {
            throw CreateFailedException("QSortFilterProxyModel create failed")
        }
    }

    /// 设置源模型
    public func setSourceModel(modelPtr: Int64): Unit {
        checkValid()
        unsafe {
            qSortFilterProxyModelSetSourceModel(ptr, modelPtr)
        }
    }

    /// 设置正则表达式过滤器
    public func setFilterRegularExpression(pattern: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(pattern)
            qSortFilterProxyModelSetFilterRegularExpression(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置固定字符串过滤器
    public func setFilterFixedString(pattern: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(pattern)
            qSortFilterProxyModelSetFilterFixedString(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置通配符过滤器
    public func setFilterWildcard(pattern: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(pattern)
            qSortFilterProxyModelSetFilterWildcard(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置过滤的列
    public func setFilterKeyColumn(col: Int32): Unit {
        checkValid()
        unsafe {
            qSortFilterProxyModelSetFilterKeyColumn(ptr, col)
        }
    }

    /// 获取过滤的列
    public func filterKeyColumn(): Int32 {
        checkValid()
        unsafe {
            qSortFilterProxyModelFilterKeyColumn(ptr)
        }
    }

    /// 设置过滤角色
    public func setFilterRole(role: Int32): Unit {
        checkValid()
        unsafe {
            qSortFilterProxyModelSetFilterRole(ptr, role)
        }
    }

    /// 获取过滤角色
    public func filterRole(): Int32 {
        checkValid()
        unsafe {
            qSortFilterProxyModelFilterRole(ptr)
        }
    }

    /// 设置排序角色
    public func setSortRole(role: Int32): Unit {
        checkValid()
        unsafe {
            qSortFilterProxyModelSetSortRole(ptr, role)
        }
    }

    /// 获取排序角色
    public func sortRole(): Int32 {
        checkValid()
        unsafe {
            qSortFilterProxyModelSortRole(ptr)
        }
    }

    /// 设置动态排序过滤
    public func setDynamicSortFilter(enable: Bool): Unit {
        checkValid()
        unsafe {
            qSortFilterProxyModelSetDynamicSortFilter(ptr, if (enable) { 1 } else { 0 })
        }
    }

    /// 是否动态排序过滤
    public func dynamicSortFilter(): Bool {
        checkValid()
        unsafe {
            qSortFilterProxyModelDynamicSortFilter(ptr) != 0
        }
    }

    /// 排序
    public func sort(column: Int32, order: Int32): Unit {
        checkValid()
        unsafe {
            qSortFilterProxyModelSort(ptr, column, order)
        }
    }

    /// 获取排序顺序
    public func sortOrder(): Int32 {
        checkValid()
        unsafe {
            qSortFilterProxyModelSortOrder(ptr)
        }
    }

    /// 映射代理索引到源模型
    public func mapToSource(proxyRow: Int32, proxyCol: Int32): Int64 {
        checkValid()
        unsafe {
            qSortFilterProxyModelMapToSource(ptr, proxyRow, proxyCol)
        }
    }

    /// 映射源模型索引到代理
    public func mapFromSource(sourceRow: Int32, sourceCol: Int32, sourceModelPtr: Int64): Int64 {
        checkValid()
        unsafe {
            qSortFilterProxyModelMapFromSource(ptr, sourceRow, sourceCol, sourceModelPtr)
        }
    }

    /// 设置过滤大小写敏感
    public func setFilterCaseSensitivity(cs: Int32): Unit {
        checkValid()
        unsafe {
            qSortFilterProxyModelSetFilterCaseSensitivity(ptr, cs)
        }
    }

    /// 获取过滤大小写敏感
    public func filterCaseSensitivity(): Int32 {
        checkValid()
        unsafe {
            qSortFilterProxyModelFilterCaseSensitivity(ptr)
        }
    }

    /// 刷新过滤器
    public func invalidate(): Unit {
        checkValid()
        unsafe {
            qSortFilterProxyModelInvalidate(ptr)
        }
    }

    /// 行数
    public func rowCount(): Int32 {
        checkValid()
        unsafe {
            qSortFilterProxyModelRowCount(ptr)
        }
    }

    /// 列数
    public func columnCount(): Int32 {
        checkValid()
        unsafe {
            qSortFilterProxyModelColumnCount(ptr)
        }
    }

    /// 获取原生指针
    public func getPtr(): Int64 {
        ptr
    }

    /// 释放资源
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qSortFilterProxyModelDelete(ptr)
            }
            ptr = 0
        }
    }
}
