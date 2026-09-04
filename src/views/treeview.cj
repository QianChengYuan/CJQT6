package cjqt6.views

import cjqt6.core.*

// ============================================================
// QTreeView FFI declarations
// ============================================================

foreign func qTreeViewCreate(): Int64
foreign func qTreeViewSetModel(ptr: Int64, modelPtr: Int64): Unit
foreign func qTreeViewSetItemDelegate(ptr: Int64, delegatePtr: Int64): Unit
foreign func qTreeViewExpandAll(ptr: Int64): Unit
foreign func qTreeViewCollapseAll(ptr: Int64): Unit
foreign func qTreeViewSetSelectionMode(ptr: Int64, mode: Int32): Unit
foreign func qTreeViewSetHeaderHidden(ptr: Int64, hidden: Int32): Unit
foreign func qTreeViewDelete(ptr: Int64): Unit

// 补充 API FFI（编辑/动画/展开/索引/信号）
foreign func qTreeViewSetEditTriggers(ptr: Int64, v: Int32): Unit
foreign func qTreeViewEditTriggers(ptr: Int64): Int32
foreign func qTreeViewIsSortingEnabled(ptr: Int64): Int32
foreign func qTreeViewSetAnimated(ptr: Int64, v: Int32): Unit
foreign func qTreeViewIsAnimated(ptr: Int64): Int32
foreign func qTreeViewIsHeaderHidden(ptr: Int64): Int32
foreign func qTreeViewSetUniformRowHeights(ptr: Int64, v: Int32): Unit
foreign func qTreeViewUniformRowHeights(ptr: Int64): Int32
foreign func qTreeViewSetItemsExpandable(ptr: Int64, v: Int32): Unit
foreign func qTreeViewItemsExpandable(ptr: Int64): Int32
foreign func qTreeViewSetRootIsDecorated(ptr: Int64, v: Int32): Unit
foreign func qTreeViewRootIsDecorated(ptr: Int64): Int32
foreign func qTreeViewSetExpandsOnDoubleClick(ptr: Int64, v: Int32): Unit
foreign func qTreeViewExpandsOnDoubleClick(ptr: Int64): Int32
foreign func qTreeViewExpand(ptr: Int64, indexPtr: Int64): Unit
foreign func qTreeViewCollapse(ptr: Int64, indexPtr: Int64): Unit
foreign func qTreeViewIsExpanded(ptr: Int64, indexPtr: Int64): Int32
foreign func qTreeViewSetColumnWidth(ptr: Int64, col: Int32, width: Int32): Unit
foreign func qTreeViewSetHeader(ptr: Int64, headerPtr: Int64): Unit
foreign func qTreeViewSetCurrentIndex(ptr: Int64, indexPtr: Int64): Unit
foreign func qTreeViewCurrentIndex(ptr: Int64): Int64
foreign func qTreeViewSetRootIndex(ptr: Int64, indexPtr: Int64): Unit
foreign func qTreeViewRootIndex(ptr: Int64): Int64
foreign func qTreeViewConnectClicked(ptr: Int64, callback: Int64Callback): Unit
foreign func qTreeViewConnectDoubleClicked(ptr: Int64, callback: Int64Callback): Unit
foreign func qTreeViewConnectExpanded(ptr: Int64, callback: Int64Callback): Unit
foreign func qTreeViewConnectCollapsed(ptr: Int64, callback: Int64Callback): Unit
foreign func qTreeViewConnectActivated(ptr: Int64, callback: Int64Callback): Unit

// ============================================================
// QTreeView
// ============================================================
public class QTreeView {
    private var ptr: Int64 = 0

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0) {
            throw ResourceDisposedException("QTreeView already deleted")
        }
    }

    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qTreeViewCreate()
        }
        if (ptr == 0) {
            throw CreateFailedException("QTreeView create failed")
        }
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
            withCString(style) { c => qWidgetSetStyleSheet(ptr, c) }
        }
    }

    public func setModel(model: QStandardItemModel): Unit {
        checkValid()
        unsafe {
            qTreeViewSetModel(ptr, model.getPtr())
        }
    }

    /// 设置自绘委托（QStyledItemDelegate，自定义单元格绘制/尺寸）
    public func setItemDelegate(delegate: QStyledItemDelegate): Unit {
        checkValid()
        unsafe {
            qTreeViewSetItemDelegate(ptr, delegate.getPtr())
        }
    }

    public func expandAll(): Unit {
        checkValid()
        unsafe {
            qTreeViewExpandAll(ptr)
        }
    }

    public func collapseAll(): Unit {
        checkValid()
        unsafe {
            qTreeViewCollapseAll(ptr)
        }
    }

    public func setSelectionMode(mode: Int32): Unit {
        checkValid()
        unsafe {
            qTreeViewSetSelectionMode(ptr, mode)
        }
    }

    public func setHeaderHidden(hidden: Bool): Unit {
        checkValid()
        unsafe {
            qTreeViewSetHeaderHidden(ptr, if (hidden) { 1 } else { 0 })
        }
    }

    public func setEditTriggers(triggers: Int32): Unit {
        checkValid()
        unsafe {
            qTreeViewSetEditTriggers(ptr, triggers)
        }
    }

    public func editTriggers(): Int32 {
        checkValid()
        unsafe {
            qTreeViewEditTriggers(ptr)
        }
    }

    public func isSortingEnabled(): Bool {
        checkValid()
        unsafe {
            qTreeViewIsSortingEnabled(ptr) != 0
        }
    }

    public func setAnimated(animated: Bool): Unit {
        checkValid()
        unsafe {
            qTreeViewSetAnimated(ptr, if (animated) { 1 } else { 0 })
        }
    }

    public func isAnimated(): Bool {
        checkValid()
        unsafe {
            qTreeViewIsAnimated(ptr) != 0
        }
    }

    public func isHeaderHidden(): Bool {
        checkValid()
        unsafe {
            qTreeViewIsHeaderHidden(ptr) != 0
        }
    }

    public func setUniformRowHeights(uniform: Bool): Unit {
        checkValid()
        unsafe {
            qTreeViewSetUniformRowHeights(ptr, if (uniform) { 1 } else { 0 })
        }
    }

    public func uniformRowHeights(): Bool {
        checkValid()
        unsafe {
            qTreeViewUniformRowHeights(ptr) != 0
        }
    }

    public func setItemsExpandable(expandable: Bool): Unit {
        checkValid()
        unsafe {
            qTreeViewSetItemsExpandable(ptr, if (expandable) { 1 } else { 0 })
        }
    }

    public func itemsExpandable(): Bool {
        checkValid()
        unsafe {
            qTreeViewItemsExpandable(ptr) != 0
        }
    }

    public func setRootIsDecorated(decorated: Bool): Unit {
        checkValid()
        unsafe {
            qTreeViewSetRootIsDecorated(ptr, if (decorated) { 1 } else { 0 })
        }
    }

    public func rootIsDecorated(): Bool {
        checkValid()
        unsafe {
            qTreeViewRootIsDecorated(ptr) != 0
        }
    }

    public func setExpandsOnDoubleClick(expands: Bool): Unit {
        checkValid()
        unsafe {
            qTreeViewSetExpandsOnDoubleClick(ptr, if (expands) { 1 } else { 0 })
        }
    }

    public func expandsOnDoubleClick(): Bool {
        checkValid()
        unsafe {
            qTreeViewExpandsOnDoubleClick(ptr) != 0
        }
    }

    public func expand(index: QModelIndex): Unit {
        checkValid()
        unsafe {
            qTreeViewExpand(ptr, index.ptr)
        }
    }

    public func collapse(index: QModelIndex): Unit {
        checkValid()
        unsafe {
            qTreeViewCollapse(ptr, index.ptr)
        }
    }

    public func isExpanded(index: QModelIndex): Bool {
        checkValid()
        unsafe {
            qTreeViewIsExpanded(ptr, index.ptr) != 0
        }
    }

    public func setColumnWidth(col: Int32, width: Int32): Unit {
        checkValid()
        unsafe {
            qTreeViewSetColumnWidth(ptr, col, width)
        }
    }

    public func setHeader(header: QHeaderView): Unit {
        checkValid()
        unsafe {
            qTreeViewSetHeader(ptr, header.getPtr())
        }
    }

    public func setCurrentIndex(index: QModelIndex): Unit {
        checkValid()
        unsafe {
            qTreeViewSetCurrentIndex(ptr, index.ptr)
        }
    }

    public func currentIndex(): Int64 {
        checkValid()
        unsafe {
            qTreeViewCurrentIndex(ptr)
        }
    }

    public func setRootIndex(index: QModelIndex): Unit {
        checkValid()
        unsafe {
            qTreeViewSetRootIndex(ptr, index.ptr)
        }
    }

    public func rootIndex(): Int64 {
        checkValid()
        unsafe {
            qTreeViewRootIndex(ptr)
        }
    }

    public func setOnClicked(callback: Int64Callback): Unit {
        checkValid()
        unsafe {
            qTreeViewConnectClicked(ptr, callback)
        }
    }

    public func setOnDoubleClicked(callback: Int64Callback): Unit {
        checkValid()
        unsafe {
            qTreeViewConnectDoubleClicked(ptr, callback)
        }
    }

    public func setOnExpanded(callback: Int64Callback): Unit {
        checkValid()
        unsafe {
            qTreeViewConnectExpanded(ptr, callback)
        }
    }

    public func setOnCollapsed(callback: Int64Callback): Unit {
        checkValid()
        unsafe {
            qTreeViewConnectCollapsed(ptr, callback)
        }
    }

    public func setOnActivated(callback: Int64Callback): Unit {
        checkValid()
        unsafe {
            qTreeViewConnectActivated(ptr, callback)
        }
    }

    public func getPtr(): Int64 {
        ptr
    }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qTreeViewDelete(ptr)
            }
            ptr = 0
        }
    }
}
