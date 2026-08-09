package cjqt6.views

import cjqt6.core.*

// ============================================================
// QAbstractItemModel FFI - 基于回调的自定义模型
// ============================================================

foreign func qAbstractItemModelCreate(): Int64
foreign func qAbstractItemModelDelete(ptr: Int64): Unit
foreign func qAbstractItemModelSetRowCountCallback(ptr: Int64, callback: CFunc<(Int64, Int64) -> Int32>): Unit
foreign func qAbstractItemModelSetColumnCountCallback(ptr: Int64, callback: CFunc<(Int64, Int64) -> Int32>): Unit
foreign func qAbstractItemModelSetIndexCallback(ptr: Int64, callback: CFunc<(Int64, Int32, Int32, Int64) -> Int64>): Unit
foreign func qAbstractItemModelSetParentCallback(ptr: Int64, callback: CFunc<(Int64, Int64) -> Int64>): Unit
foreign func qAbstractItemModelSetDataCallback(ptr: Int64, callback: CFunc<(Int64, Int64, Int32) -> Int64>): Unit
foreign func qAbstractItemModelSetHeaderDataCallback(ptr: Int64, callback: CFunc<(Int64, Int32, Int32, Int32) -> Int64>): Unit
foreign func qAbstractItemModelSetFlagsCallback(ptr: Int64, callback: CFunc<(Int64, Int64) -> Int32>): Unit
foreign func qAbstractItemModelBeginResetModel(ptr: Int64): Unit
foreign func qAbstractItemModelEndResetModel(ptr: Int64): Unit
foreign func qAbstractItemModelBeginInsertRows(ptr: Int64, first: Int32, last: Int32): Unit
foreign func qAbstractItemModelEndInsertRows(ptr: Int64): Unit
foreign func qAbstractItemModelBeginRemoveRows(ptr: Int64, first: Int32, last: Int32): Unit
foreign func qAbstractItemModelEndRemoveRows(ptr: Int64): Unit
foreign func qAbstractItemModelDataChanged(ptr: Int64, topLeftRow: Int32, topLeftCol: Int32, bottomRightRow: Int32, bottomRightCol: Int32): Unit
foreign func qAbstractItemModelLayoutChanged(ptr: Int64): Unit


// ============================================================
// 数据角色常量
// ============================================================
public class ItemDataRole {
    public static func displayRole(): Int32 { 0 }
    public static func decorationRole(): Int32 { 1 }
    public static func editRole(): Int32 { 2 }
    public static func toolTipRole(): Int32 { 3 }
    public static func statusTipRole(): Int32 { 4 }
    public static func whatsThisRole(): Int32 { 5 }
    public static func fontRole(): Int32 { 6 }
    public static func textAlignmentRole(): Int32 { 7 }
    public static func backgroundRole(): Int32 { 8 }
    public static func foregroundRole(): Int32 { 9 }
    public static func checkStateRole(): Int32 { 10 }
    public static func sizeHintRole(): Int32 { 11 }
}


// ============================================================
// QAbstractItemModel - 自定义模型基类（基于回调）
//
// 使用方式：
//   1. 创建 QAbstractItemModel 实例
//   2. 通过 setOnRowCount/setOnColumnCount 注册各虚方法回调
//   3. 将 getPtr() 设置到 QTableView/QTreeView 等视图控件
//
// 回调签名说明：
//   - RowCount/ColumnCount: (modelPtr, parentPtr) -> Int32
//   - Index: (modelPtr, row, col, parentPtr) -> Int64 (返回内部ID)
//   - Parent: (modelPtr, childPtr) -> Int64 (返回父项内部ID)
//   - Data: (modelPtr, indexPtr, role) -> Int64 (返回字符串指针或0)
//   - HeaderData: (modelPtr, section, orientation, role) -> Int64
//   - Flags: (modelPtr, indexPtr) -> Int32
// ============================================================
public class QAbstractItemModel {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QAbstractItemModel already deleted")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QAbstractItemModel 底层 Qt 对象已失效")
        }
    }

    /// 创建自定义模型
    public init() {
        unsafe {
            ptr = qAbstractItemModelCreate()
            if (ptr == 0) {
                throw CreateFailedException("QAbstractItemModel create failed")
            }
        }
        trackObject(ptr)
    }

    /// 设置行数回调 (modelPtr, parentPtr) -> 行数
    public func setOnRowCount(callback: CFunc<(Int64, Int64) -> Int32>): Unit {
        checkValid()
        unsafe { qAbstractItemModelSetRowCountCallback(ptr, callback) }
    }

    /// 设置列数回调 (modelPtr, parentPtr) -> 列数
    public func setOnColumnCount(callback: CFunc<(Int64, Int64) -> Int32>): Unit {
        checkValid()
        unsafe { qAbstractItemModelSetColumnCountCallback(ptr, callback) }
    }

    /// 设置索引回调 (modelPtr, row, col, parentPtr) -> 内部ID
    public func setOnIndex(callback: CFunc<(Int64, Int32, Int32, Int64) -> Int64>): Unit {
        checkValid()
        unsafe { qAbstractItemModelSetIndexCallback(ptr, callback) }
    }

    /// 设置父项回调 (modelPtr, childPtr) -> 父项内部ID
    public func setOnParent(callback: CFunc<(Int64, Int64) -> Int64>): Unit {
        checkValid()
        unsafe { qAbstractItemModelSetParentCallback(ptr, callback) }
    }

    /// 设置数据回调 (modelPtr, indexPtr, role) -> 返回字符串指针(Int64)或0
    public func setOnData(callback: CFunc<(Int64, Int64, Int32) -> Int64>): Unit {
        checkValid()
        unsafe { qAbstractItemModelSetDataCallback(ptr, callback) }
    }

    /// 设置表头回调 (modelPtr, section, orientation, role) -> 返回字符串指针(Int64)或0
    public func setOnHeaderData(callback: CFunc<(Int64, Int32, Int32, Int32) -> Int64>): Unit {
        checkValid()
        unsafe { qAbstractItemModelSetHeaderDataCallback(ptr, callback) }
    }

    /// 设置标志回调 (modelPtr, indexPtr) -> ItemFlags
    public func setOnFlags(callback: CFunc<(Int64, Int64) -> Int32>): Unit {
        checkValid()
        unsafe { qAbstractItemModelSetFlagsCallback(ptr, callback) }
    }

    // ---- Model通知方法 ----

    /// 开始重置模型
    public func beginResetModel(): Unit {
        checkValid()
        unsafe { qAbstractItemModelBeginResetModel(ptr) }
    }

    /// 完成重置模型
    public func endResetModel(): Unit {
        checkValid()
        unsafe { qAbstractItemModelEndResetModel(ptr) }
    }

    /// 开始插入行
    public func beginInsertRows(first: Int32, last: Int32): Unit {
        checkValid()
        unsafe { qAbstractItemModelBeginInsertRows(ptr, first, last) }
    }

    /// 完成插入行
    public func endInsertRows(): Unit {
        checkValid()
        unsafe { qAbstractItemModelEndInsertRows(ptr) }
    }

    /// 开始移除行
    public func beginRemoveRows(first: Int32, last: Int32): Unit {
        checkValid()
        unsafe { qAbstractItemModelBeginRemoveRows(ptr, first, last) }
    }

    /// 完成移除行
    public func endRemoveRows(): Unit {
        checkValid()
        unsafe { qAbstractItemModelEndRemoveRows(ptr) }
    }

    /// 通知局部数据更新（dataChanged，P1）
    /// 视图只刷新 topLeft 到 bottomRight 围成的矩形区域，避免整表 reset。
    /// 行/列号对应当前模型的行列索引（0 起）。
    public func notifyDataChanged(topLeftRow: Int32, topLeftCol: Int32, bottomRightRow: Int32, bottomRightCol: Int32): Unit {
        checkValid()
        unsafe { qAbstractItemModelDataChanged(ptr, topLeftRow, topLeftCol, bottomRightRow, bottomRightCol) }
    }

    /// 通知布局变化（layoutChanged，P1）
    /// 行/列顺序或结构发生变化后调用，让视图重新排列。
    public func notifyLayoutChanged(): Unit {
        checkValid()
        unsafe { qAbstractItemModelLayoutChanged(ptr) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            unsafe { qAbstractItemModelDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
