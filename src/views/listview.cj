package cjqt6.views

import cjqt6.core.*

// ============================================================
// QListView FFI declarations
// ============================================================

foreign func qListViewCreate(): Int64
foreign func qListViewSetModel(ptr: Int64, modelPtr: Int64): Unit
foreign func qListViewSetItemDelegate(ptr: Int64, delegatePtr: Int64): Unit
foreign func qListViewSetSelectionMode(ptr: Int64, mode: Int32): Unit
foreign func qListViewDelete(ptr: Int64): Unit

// 选择 / 编辑 / 外观
foreign func qListViewSelectionMode(ptr: Int64): Int32
foreign func qListViewSetEditTriggers(ptr: Int64, v: Int32): Unit
foreign func qListViewEditTriggers(ptr: Int64): Int32
foreign func qListViewSetViewMode(ptr: Int64, v: Int32): Unit
foreign func qListViewViewMode(ptr: Int64): Int32
foreign func qListViewSetMovement(ptr: Int64, v: Int32): Unit
foreign func qListViewMovement(ptr: Int64): Int32
foreign func qListViewSetFlow(ptr: Int64, v: Int32): Unit
foreign func qListViewFlow(ptr: Int64): Int32
foreign func qListViewSetWrapping(ptr: Int64, v: Int32): Unit
foreign func qListViewIsWrapping(ptr: Int64): Int32
foreign func qListViewSetSpacing(ptr: Int64, v: Int32): Unit
foreign func qListViewSpacing(ptr: Int64): Int32
foreign func qListViewSetResizeMode(ptr: Int64, v: Int32): Unit
foreign func qListViewResizeMode(ptr: Int64): Int32
foreign func qListViewSetWordWrap(ptr: Int64, v: Int32): Unit
foreign func qListViewIsWordWrap(ptr: Int64): Int32
foreign func qListViewSetUniformItemSizes(ptr: Int64, v: Int32): Unit
foreign func qListViewUniformItemSizes(ptr: Int64): Int32
foreign func qListViewSetCurrentIndex(ptr: Int64, indexPtr: Int64): Unit
foreign func qListViewCurrentIndex(ptr: Int64): Int64
foreign func qListViewSetRootIndex(ptr: Int64, indexPtr: Int64): Unit
foreign func qListViewRootIndex(ptr: Int64): Int64

// 信号
foreign func qListViewConnectClicked(ptr: Int64, callback: Int64Callback): Unit
foreign func qListViewConnectDoubleClicked(ptr: Int64, callback: Int64Callback): Unit
foreign func qListViewConnectActivated(ptr: Int64, callback: Int64Callback): Unit
foreign func qListViewConnectPressed(ptr: Int64, callback: Int64Callback): Unit

// QModelIndex 句柄辅助
foreign func qModelIndexRow(ptr: Int64): Int32
foreign func qModelIndexColumn(ptr: Int64): Int32
foreign func qModelIndexIsValid(ptr: Int64): Int32
foreign func qModelIndexDelete(ptr: Int64): Unit


// ============================================================
// QListView
// ============================================================
public class QListView {
    private var ptr: Int64 = 0

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0) {
            throw ResourceDisposedException("QListView already deleted")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QListView 底层 Qt 对象已失效")
        }
    }

    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qListViewCreate()
        }
        if (ptr == 0) {
            throw CreateFailedException("QListView create failed")
        }
        trackObject(ptr)
    }

    public func show(): Unit {
        checkValid()
        unsafe {
            qWidgetShow(ptr)
        }
    }

    public func hide(): Unit {
        checkValid()
        unsafe {
            qWidgetHide(ptr)
        }
    }

    public func resize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }

    public func setEnabled(enabled: Bool): Unit {
        checkValid()
        unsafe {
            qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }

    public func setStyleSheet(style: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func setModel(model: QStandardItemModel): Unit {
        checkValid()
        unsafe {
            qListViewSetModel(ptr, model.getPtr())
        }
    }

    /// 设置自绘委托（QStyledItemDelegate，自定义单元格绘制/尺寸）
    public func setItemDelegate(delegate: QStyledItemDelegate): Unit {
        checkValid()
        unsafe {
            qListViewSetItemDelegate(ptr, delegate.getPtr())
        }
    }

    public func setSelectionMode(mode: Int32): Unit {
        checkValid()
        unsafe {
            qListViewSetSelectionMode(ptr, mode)
        }
    }

    public func selectionMode(): Int32 {
        checkValid()
        unsafe {
            qListViewSelectionMode(ptr)
        }
    }

    public func setEditTriggers(triggers: Int32): Unit {
        checkValid()
        unsafe {
            qListViewSetEditTriggers(ptr, triggers)
        }
    }

    public func editTriggers(): Int32 {
        checkValid()
        unsafe {
            qListViewEditTriggers(ptr)
        }
    }

    public func setViewMode(mode: Int32): Unit {
        checkValid()
        unsafe {
            qListViewSetViewMode(ptr, mode)
        }
    }

    public func viewMode(): Int32 {
        checkValid()
        unsafe {
            qListViewViewMode(ptr)
        }
    }

    public func setMovement(movement: Int32): Unit {
        checkValid()
        unsafe {
            qListViewSetMovement(ptr, movement)
        }
    }

    public func movement(): Int32 {
        checkValid()
        unsafe {
            qListViewMovement(ptr)
        }
    }

    public func setFlow(flow: Int32): Unit {
        checkValid()
        unsafe {
            qListViewSetFlow(ptr, flow)
        }
    }

    public func flow(): Int32 {
        checkValid()
        unsafe {
            qListViewFlow(ptr)
        }
    }

    public func setWrapping(wrapping: Bool): Unit {
        checkValid()
        unsafe {
            qListViewSetWrapping(ptr, if (wrapping) { 1 } else { 0 })
        }
    }

    public func isWrapping(): Bool {
        checkValid()
        unsafe {
            qListViewIsWrapping(ptr) != 0
        }
    }

    public func setSpacing(spacing: Int32): Unit {
        checkValid()
        unsafe {
            qListViewSetSpacing(ptr, spacing)
        }
    }

    public func spacing(): Int32 {
        checkValid()
        unsafe {
            qListViewSpacing(ptr)
        }
    }

    public func setResizeMode(mode: Int32): Unit {
        checkValid()
        unsafe {
            qListViewSetResizeMode(ptr, mode)
        }
    }

    public func resizeMode(): Int32 {
        checkValid()
        unsafe {
            qListViewResizeMode(ptr)
        }
    }

    public func setWordWrap(wordWrap: Bool): Unit {
        checkValid()
        unsafe {
            qListViewSetWordWrap(ptr, if (wordWrap) { 1 } else { 0 })
        }
    }

    public func isWordWrap(): Bool {
        checkValid()
        unsafe {
            qListViewIsWordWrap(ptr) != 0
        }
    }

    public func setUniformItemSizes(uniform: Bool): Unit {
        checkValid()
        unsafe {
            qListViewSetUniformItemSizes(ptr, if (uniform) { 1 } else { 0 })
        }
    }

    public func uniformItemSizes(): Bool {
        checkValid()
        unsafe {
            qListViewUniformItemSizes(ptr) != 0
        }
    }

    public func setCurrentIndex(indexPtr: Int64): Unit {
        checkValid()
        unsafe {
            qListViewSetCurrentIndex(ptr, indexPtr)
        }
    }

    public func setCurrentIndex(index: QModelIndex): Unit {
        checkValid()
        unsafe {
            qListViewSetCurrentIndex(ptr, index.ptr)
        }
    }

    public func currentIndex(): Int64 {
        checkValid()
        unsafe {
            qListViewCurrentIndex(ptr)
        }
    }

    public func setRootIndex(indexPtr: Int64): Unit {
        checkValid()
        unsafe {
            qListViewSetRootIndex(ptr, indexPtr)
        }
    }

    public func setRootIndex(index: QModelIndex): Unit {
        checkValid()
        unsafe {
            qListViewSetRootIndex(ptr, index.ptr)
        }
    }

    public func rootIndex(): Int64 {
        checkValid()
        unsafe {
            qListViewRootIndex(ptr)
        }
    }

    public func setOnClicked(callback: Int64Callback): Unit {
        checkValid()
        unsafe {
            qListViewConnectClicked(ptr, callback)
        }
    }

    public func setOnDoubleClicked(callback: Int64Callback): Unit {
        checkValid()
        unsafe {
            qListViewConnectDoubleClicked(ptr, callback)
        }
    }

    public func setOnActivated(callback: Int64Callback): Unit {
        checkValid()
        unsafe {
            qListViewConnectActivated(ptr, callback)
        }
    }

    public func setOnPressed(callback: Int64Callback): Unit {
        checkValid()
        unsafe {
            qListViewConnectPressed(ptr, callback)
        }
    }

    public func getPtr(): Int64 {
        ptr
    }

    public func delete(): Unit {
        if (ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                return
            }
            untrackObject(ptr)
            unsafe {
                qSignalCleanup(ptr)
                qListViewDelete(ptr)
            }
            ptr = 0
        }
    }
}

// 编辑触发方式（对应 QAbstractItemView::EditTrigger 标志位，可位或组合）
public class EditTrigger {
    public static let NoEditTriggers: Int32 = 0
    public static let CurrentChanged: Int32 = 1
    public static let DoubleClicked: Int32 = 2
    public static let SelectedClicked: Int32 = 4
    public static let EditKeyPressed: Int32 = 8
    public static let AnyKeyPressed: Int32 = 16
    public static let AllEditTriggers: Int32 = 31
}

// QModelIndex 句柄辅助（封装由 C++ 侧以 QPersistentModelIndex* 堆分配的索引）
// 注意：currentIndex()/rootIndex() 返回的句柄需调用 delete() 释放；
// 信号回调内传入的索引句柄仅在回调期间有效，离开回调后由 C++ 侧释放，不要再次 delete。
public class QModelIndex {
    public let ptr: Int64

    public init(ptr: Int64) {
        this.ptr = ptr
    }

    public func row(): Int32 {
        unsafe { qModelIndexRow(ptr) }
    }

    public func column(): Int32 {
        unsafe { qModelIndexColumn(ptr) }
    }

    public func isValid(): Bool {
        unsafe { qModelIndexIsValid(ptr) != 0 }
    }

    public func delete(): Unit {
        unsafe { qModelIndexDelete(ptr) }
    }
}
