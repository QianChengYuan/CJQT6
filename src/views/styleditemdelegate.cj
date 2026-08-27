package cjqt6.views

import cjqt6.core.*

// ============================================================
// QStyledItemDelegate FFI - 基于回调的自绘委托
// ============================================================

foreign func qStyledItemDelegateCreate(): Int64
foreign func qStyledItemDelegateDelete(ptr: Int64): Unit
foreign func qStyledItemDelegateSetPaintCallback(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit
foreign func qStyledItemDelegateSetSizeHintCallback(ptr: Int64, callback: CFunc<(Int64) -> Int64>): Unit
foreign func qStyledItemDelegateIsMounted(ptr: Int64): Int32
foreign func qStyledItemDelegateGetPainterPtr(ptr: Int64): Int64
foreign func qStyledItemDelegateGetRectX(ptr: Int64): Int32
foreign func qStyledItemDelegateGetRectY(ptr: Int64): Int32
foreign func qStyledItemDelegateGetRectW(ptr: Int64): Int32
foreign func qStyledItemDelegateGetRectH(ptr: Int64): Int32
foreign func qStyledItemDelegateGetState(ptr: Int64): Int32
foreign func qStyledItemDelegateGetRow(ptr: Int64): Int32
foreign func qStyledItemDelegateGetCol(ptr: Int64): Int32

// 编辑委托
foreign func qStyledItemDelegateSetCreateEditorCallback(ptr: Int64, callback: CFunc<(Int64) -> Int64>): Unit
foreign func qStyledItemDelegateSetSetEditorDataCallback(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit
foreign func qStyledItemDelegateSetSetModelDataCallback(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit
foreign func qStyledItemDelegateGetParentPtr(ptr: Int64): Int64
foreign func qStyledItemDelegateGetEditorPtr(ptr: Int64): Int64
foreign func qStyledItemDelegateGetModelPtr(ptr: Int64): Int64

// ============================================================
// 回调类型别名
// ============================================================

/// 自绘回调：入参为委托自身指针，绘制上下文经 getter 读取
public type DelegatePaintCallback = CFunc<(Int64) -> Unit>
/// 尺寸回调：入参为委托自身指针，返回打包尺寸（makeSizeHintValue 构造）
public type DelegateSizeHintCallback = CFunc<(Int64) -> Int64>
/// 创建编辑器回调：入参为委托自身指针，返回编辑器 widget 指针（0 表示不编辑）
public type DelegateCreateEditorCallback = CFunc<(Int64) -> Int64>
/// 设置编辑器数据回调：从 model 取数据填入编辑器，入参为委托自身指针
public type DelegateSetEditorDataCallback = CFunc<(Int64) -> Unit>
/// 设置模型数据回调：从编辑器取数据写回 model，入参为委托自身指针
public type DelegateSetModelDataCallback = CFunc<(Int64) -> Unit>

// ============================================================
// 绘制状态常量（对应 QStyle::State 位标志，按需扩展）
// ============================================================

/// 绘制状态位标志，用于判断当前单元格是否被选中/悬浮/聚焦等
public class PaintState {
    /// 被选中（对应 QStyle::State_Selected）
    public static func selected(): Int32 { 0x00008000 }
    /// 鼠标悬浮（对应 QStyle::State_MouseOver）
    public static func mouseOver(): Int32 { 0x00002000 }
    /// 拥有焦点（对应 QStyle::State_HasFocus）
    public static func hasFocus(): Int32 { 0x00000100 }
    /// 处于激活状态（对应 QStyle::State_Active）
    public static func active(): Int32 { 0x00010000 }
    /// 判断是否包含某状态位
    public static func has(state: Int32, flag: Int32): Bool { (state & flag) != 0 }
}

// ============================================================
// 工具函数
// ============================================================

/// 打包宽度/高度为 sizeHint 回调的返回值（高 32 位 = 高度，低 32 位 = 宽度）
/// width/height 须为非负值
public func makeSizeHintValue(width: Int32, height: Int32): Int64 {
    (Int64(height) << 32) | (Int64(width) & 0xFFFFFFFF)
}

// ============================================================
// QStyledItemDelegate - 自绘委托（基于回调）
//
// 使用方式：
//   1. 创建 QStyledItemDelegate 实例
//   2. 通过 setOnPaint / setOnSizeHint 注册绘制与尺寸回调
//   3. 将 delegate 挂载到 QTableView/QListView/QTreeView：
//        view.setItemDelegate(delegate.getPtr())
//
// 回调签名：
//   - Paint: (delegatePtr) -> Unit
//   - SizeHint: (delegatePtr) -> Int64（返回 makeSizeHintValue(w, h)）
//
// 绘制上下文 getter（仅在回调执行期间有效，退出回调后值为脏数据）：
//   - getPainterPtr() -> Int64    当前 QPainter 指针，可用 QPainter.fromPtr 包裹绘制
//   - getRectX/Y/W/H() -> Int32   当前单元格绘制矩形
//   - getState() -> Int32         绘制状态位标志（见 PaintState）
//   - getRow()/getCol() -> Int32  当前单元格的行/列号
//
// 内存管理（重要）：
//   - 委托挂载到视图后（setItemDelegate），视图接管其所有权并在视图析构时级联释放；
//     此时 delegate.close() 仅标记关闭、不主动删除，避免 double-free。
//   - 未挂载的委托由 close() 显式释放。
// ============================================================
public class QStyledItemDelegate {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QStyledItemDelegate already deleted")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QStyledItemDelegate 底层 Qt 对象已失效")
        }
    }

    /// 创建自绘委托
    public init() {
        unsafe {
            ptr = qStyledItemDelegateCreate()
            if (ptr == 0) {
                throw CreateFailedException("QStyledItemDelegate create failed")
            }
        }
        trackObject(ptr)
    }

    /// 注册自绘回调；注册后视图对该委托的单元格绘制完全交由回调接管
    public func setOnPaint(callback: DelegatePaintCallback): Unit {
        checkValid()
        unsafe { qStyledItemDelegateSetPaintCallback(ptr, callback) }
    }

    /// 注册自定义尺寸回调；返回 makeSizeHintValue(w, h)，返回 0 表示使用默认尺寸
    public func setOnSizeHint(callback: DelegateSizeHintCallback): Unit {
        checkValid()
        unsafe { qStyledItemDelegateSetSizeHintCallback(ptr, callback) }
    }

    // ---- 绘制上下文 getter（仅回调内有效）----

    /// 当前 QPainter 指针（仅 paint 回调内有效）
    public func getPainterPtr(): Int64 {
        checkValid()
        unsafe { qStyledItemDelegateGetPainterPtr(ptr) }
    }

    /// 当前绘制矩形左上角 X（仅回调内有效）
    public func getRectX(): Int32 {
        checkValid()
        unsafe { qStyledItemDelegateGetRectX(ptr) }
    }

    /// 当前绘制矩形左上角 Y（仅回调内有效）
    public func getRectY(): Int32 {
        checkValid()
        unsafe { qStyledItemDelegateGetRectY(ptr) }
    }

    /// 当前绘制矩形宽度（仅回调内有效）
    public func getRectW(): Int32 {
        checkValid()
        unsafe { qStyledItemDelegateGetRectW(ptr) }
    }

    /// 当前绘制矩形高度（仅回调内有效）
    public func getRectH(): Int32 {
        checkValid()
        unsafe { qStyledItemDelegateGetRectH(ptr) }
    }

    /// 当前绘制状态位标志（仅回调内有效，见 PaintState）
    public func getState(): Int32 {
        checkValid()
        unsafe { qStyledItemDelegateGetState(ptr) }
    }

    /// 当前单元格行号（仅回调内有效）
    public func getRow(): Int32 {
        checkValid()
        unsafe { qStyledItemDelegateGetRow(ptr) }
    }

    /// 当前单元格列号（仅回调内有效）
    public func getCol(): Int32 {
        checkValid()
        unsafe { qStyledItemDelegateGetCol(ptr) }
    }

    // ---- 编辑委托 ----

    /// 注册创建编辑器回调；双击单元格时调用，返回编辑器 widget 指针（0 表示不编辑）
    /// 回调内可通过 getParentPtr() 取父 widget 指针、getRow()/getCol() 取单元格行列
    public func setOnCreateEditor(callback: DelegateCreateEditorCallback): Unit {
        checkValid()
        unsafe { qStyledItemDelegateSetCreateEditorCallback(ptr, callback) }
    }

    /// 注册设置编辑器数据回调；编辑器打开后调用，从 model 取数据填入编辑器
    /// 回调内可通过 getEditorPtr() 取编辑器指针、getRow()/getCol() 取单元格行列
    public func setOnSetEditorData(callback: DelegateSetEditorDataCallback): Unit {
        checkValid()
        unsafe { qStyledItemDelegateSetSetEditorDataCallback(ptr, callback) }
    }

    /// 注册设置模型数据回调；编辑完成时调用，从编辑器取数据写回 model
    /// 回调内可通过 getEditorPtr() 取编辑器、getModelPtr() 取 model、getRow()/getCol() 取行列
    public func setOnSetModelData(callback: DelegateSetModelDataCallback): Unit {
        checkValid()
        unsafe { qStyledItemDelegateSetSetModelDataCallback(ptr, callback) }
    }

    // ---- 编辑上下文 getter（仅编辑回调内有效）----

    /// 父 widget 指针（仅 createEditor 回调内有效，用于创建编辑器时指定父对象）
    public func getParentPtr(): Int64 {
        checkValid()
        unsafe { qStyledItemDelegateGetParentPtr(ptr) }
    }

    /// 当前编辑器指针（仅 setEditorData/setModelData 回调内有效）
    public func getEditorPtr(): Int64 {
        checkValid()
        unsafe { qStyledItemDelegateGetEditorPtr(ptr) }
    }

    /// 当前 model 指针（仅 setModelData 回调内有效）
    public func getModelPtr(): Int64 {
        checkValid()
        unsafe { qStyledItemDelegateGetModelPtr(ptr) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源；已挂载（视图接管）则只标记关闭，不删除底层对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            // 已挂载到视图：所有权归视图，这里不主动删除，避免 double-free
            if (unsafe { qStyledItemDelegateIsMounted(ptr) } == 0) {
                unsafe { qStyledItemDelegateDelete(ptr) }
            }
            ptr = 0
            closed = true
        }
    }
}