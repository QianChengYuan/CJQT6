package cjqt6.views

import cjqt6.core.*

// ============================================================
// QHeaderView FFI declarations
// ============================================================

foreign func qHeaderViewCreate(orientation: Int32): Int64
foreign func qHeaderViewSetStretchLastSection(ptr: Int64, stretch: Int32): Unit
foreign func qHeaderViewSetSectionResizeMode(ptr: Int64, mode: Int32): Unit
foreign func qHeaderViewDelete(ptr: Int64): Unit

// 补充 API FFI（可见性/布局/尺寸/索引/信号）
foreign func qHeaderViewSetVisible(ptr: Int64, v: Int32): Unit
foreign func qHeaderViewShow(ptr: Int64): Unit
foreign func qHeaderViewHide(ptr: Int64): Unit
foreign func qHeaderViewIsStretchLastSection(ptr: Int64): Int32
foreign func qHeaderViewSetDefaultSectionSize(ptr: Int64, v: Int32): Unit
foreign func qHeaderViewDefaultSectionSize(ptr: Int64): Int32
foreign func qHeaderViewSetMinimumSectionSize(ptr: Int64, v: Int32): Unit
foreign func qHeaderViewMinimumSectionSize(ptr: Int64): Int32
foreign func qHeaderViewSetSectionResizeModeIndex(ptr: Int64, index: Int32, mode: Int32): Unit
foreign func qHeaderViewSetSortIndicatorShown(ptr: Int64, v: Int32): Unit
foreign func qHeaderViewIsSortIndicatorShown(ptr: Int64): Int32
foreign func qHeaderViewSetSectionsClickable(ptr: Int64, v: Int32): Unit
foreign func qHeaderViewIsSectionsClickable(ptr: Int64): Int32
foreign func qHeaderViewSetHighlightSections(ptr: Int64, v: Int32): Unit
foreign func qHeaderViewIsHighlightSections(ptr: Int64): Int32
foreign func qHeaderViewSetCascadingSectionResizes(ptr: Int64, v: Int32): Unit
foreign func qHeaderViewIsCascadingSectionResizes(ptr: Int64): Int32
foreign func qHeaderViewResizeSection(ptr: Int64, index: Int32, size: Int32): Unit
foreign func qHeaderViewSectionSize(ptr: Int64, index: Int32): Int32
foreign func qHeaderViewSetSectionHidden(ptr: Int64, index: Int32, v: Int32): Unit
foreign func qHeaderViewIsSectionHidden(ptr: Int64, index: Int32): Int32
foreign func qHeaderViewCount(ptr: Int64): Int32
foreign func qHeaderViewLength(ptr: Int64): Int32
foreign func qHeaderViewLogicalIndex(ptr: Int64, visual: Int32): Int32
foreign func qHeaderViewVisualIndex(ptr: Int64, logical: Int32): Int32
foreign func qHeaderViewSetOffset(ptr: Int64, offset: Int32): Unit
foreign func qHeaderViewOffset(ptr: Int64): Int32
foreign func qHeaderViewMoveSection(ptr: Int64, from: Int32, to: Int32): Unit
foreign func qHeaderViewSwapSections(ptr: Int64, one: Int32, two: Int32): Unit
foreign func qHeaderViewSetDefaultAlignment(ptr: Int64, alignment: Int32): Unit
foreign func qHeaderViewConnectSectionClicked(ptr: Int64, callback: Int32Callback): Unit
foreign func qHeaderViewConnectSectionDoubleClicked(ptr: Int64, callback: Int32Callback): Unit
foreign func qHeaderViewConnectSectionResized(ptr: Int64, callback: CFunc<(Int32, Int32, Int32) -> Unit>): Unit
foreign func qHeaderViewConnectSectionMoved(ptr: Int64, callback: CFunc<(Int32, Int32, Int32) -> Unit>): Unit
foreign func qHeaderViewConnectSortIndicatorChanged(ptr: Int64, callback: Int32Int32Callback): Unit
foreign func qHeaderViewConnectSectionHandleDoubleClicked(ptr: Int64, callback: Int32Callback): Unit

// ============================================================
// Orientation constants
// ============================================================
public class Orientation {
    public static let Horizontal: Int32 = 1
    public static let Vertical: Int32 = 2
}

// ============================================================
// ResizeMode constants
// ============================================================
public class ResizeMode {
    public static let Interactive: Int32 = 0
    public static let Stretch: Int32 = 1
    public static let Fixed: Int32 = 2
    public static let ResizeToContents: Int32 = 3
}

// ============================================================
// QHeaderView
// ============================================================
public class QHeaderView {
    private var ptr: Int64 = 0

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0) {
            throw ResourceDisposedException("QHeaderView already deleted")
        }
    }

    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init(orientation: Int32) {
        unsafe {
            ptr = qHeaderViewCreate(orientation)
        }
        if (ptr == 0) {
            throw CreateFailedException("QHeaderView create failed")
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
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func setStretchLastSection(stretch: Bool): Unit {
        checkValid()
        unsafe {
            qHeaderViewSetStretchLastSection(ptr, if (stretch) { 1 } else { 0 })
        }
    }

    public func setSectionResizeMode(mode: Int32): Unit {
        checkValid()
        unsafe {
            qHeaderViewSetSectionResizeMode(ptr, mode)
        }
    }

    public func setVisible(visible: Bool): Unit {
        checkValid()
        unsafe {
            qHeaderViewSetVisible(ptr, if (visible) { 1 } else { 0 })
        }
    }

    public func isStretchLastSection(): Bool {
        checkValid()
        unsafe {
            qHeaderViewIsStretchLastSection(ptr) != 0
        }
    }

    public func setDefaultSectionSize(size: Int32): Unit {
        checkValid()
        unsafe {
            qHeaderViewSetDefaultSectionSize(ptr, size)
        }
    }

    public func defaultSectionSize(): Int32 {
        checkValid()
        unsafe {
            qHeaderViewDefaultSectionSize(ptr)
        }
    }

    public func setMinimumSectionSize(size: Int32): Unit {
        checkValid()
        unsafe {
            qHeaderViewSetMinimumSectionSize(ptr, size)
        }
    }

    public func minimumSectionSize(): Int32 {
        checkValid()
        unsafe {
            qHeaderViewMinimumSectionSize(ptr)
        }
    }

    public func setSectionResizeMode(index: Int32, mode: Int32): Unit {
        checkValid()
        unsafe {
            qHeaderViewSetSectionResizeModeIndex(ptr, index, mode)
        }
    }

    public func setSortIndicatorShown(shown: Bool): Unit {
        checkValid()
        unsafe {
            qHeaderViewSetSortIndicatorShown(ptr, if (shown) { 1 } else { 0 })
        }
    }

    public func isSortIndicatorShown(): Bool {
        checkValid()
        unsafe {
            qHeaderViewIsSortIndicatorShown(ptr) != 0
        }
    }

    public func setSectionsClickable(clickable: Bool): Unit {
        checkValid()
        unsafe {
            qHeaderViewSetSectionsClickable(ptr, if (clickable) { 1 } else { 0 })
        }
    }

    public func isSectionsClickable(): Bool {
        checkValid()
        unsafe {
            qHeaderViewIsSectionsClickable(ptr) != 0
        }
    }

    public func setHighlightSections(highlight: Bool): Unit {
        checkValid()
        unsafe {
            qHeaderViewSetHighlightSections(ptr, if (highlight) { 1 } else { 0 })
        }
    }

    public func isHighlightSections(): Bool {
        checkValid()
        unsafe {
            qHeaderViewIsHighlightSections(ptr) != 0
        }
    }

    public func setCascadingSectionResizes(cascading: Bool): Unit {
        checkValid()
        unsafe {
            qHeaderViewSetCascadingSectionResizes(ptr, if (cascading) { 1 } else { 0 })
        }
    }

    public func isCascadingSectionResizes(): Bool {
        checkValid()
        unsafe {
            qHeaderViewIsCascadingSectionResizes(ptr) != 0
        }
    }

    public func resizeSection(index: Int32, size: Int32): Unit {
        checkValid()
        unsafe {
            qHeaderViewResizeSection(ptr, index, size)
        }
    }

    public func sectionSize(index: Int32): Int32 {
        checkValid()
        unsafe {
            qHeaderViewSectionSize(ptr, index)
        }
    }

    public func setSectionHidden(index: Int32, hidden: Bool): Unit {
        checkValid()
        unsafe {
            qHeaderViewSetSectionHidden(ptr, index, if (hidden) { 1 } else { 0 })
        }
    }

    public func isSectionHidden(index: Int32): Bool {
        checkValid()
        unsafe {
            qHeaderViewIsSectionHidden(ptr, index) != 0
        }
    }

    public func count(): Int32 {
        checkValid()
        unsafe {
            qHeaderViewCount(ptr)
        }
    }

    public func length(): Int32 {
        checkValid()
        unsafe {
            qHeaderViewLength(ptr)
        }
    }

    public func logicalIndex(visual: Int32): Int32 {
        checkValid()
        unsafe {
            qHeaderViewLogicalIndex(ptr, visual)
        }
    }

    public func visualIndex(logical: Int32): Int32 {
        checkValid()
        unsafe {
            qHeaderViewVisualIndex(ptr, logical)
        }
    }

    public func setOffset(offset: Int32): Unit {
        checkValid()
        unsafe {
            qHeaderViewSetOffset(ptr, offset)
        }
    }

    public func offset(): Int32 {
        checkValid()
        unsafe {
            qHeaderViewOffset(ptr)
        }
    }

    public func moveSection(from: Int32, to: Int32): Unit {
        checkValid()
        unsafe {
            qHeaderViewMoveSection(ptr, from, to)
        }
    }

    public func swapSections(one: Int32, two: Int32): Unit {
        checkValid()
        unsafe {
            qHeaderViewSwapSections(ptr, one, two)
        }
    }

    public func setDefaultAlignment(alignment: Int32): Unit {
        checkValid()
        unsafe {
            qHeaderViewSetDefaultAlignment(ptr, alignment)
        }
    }

    // 信号
    public func setOnSectionClicked(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qHeaderViewConnectSectionClicked(ptr, callback)
        }
    }

    public func setOnSectionDoubleClicked(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qHeaderViewConnectSectionDoubleClicked(ptr, callback)
        }
    }

    public func setOnSectionResized(callback: CFunc<(Int32, Int32, Int32) -> Unit>): Unit {
        checkValid()
        unsafe {
            qHeaderViewConnectSectionResized(ptr, callback)
        }
    }

    public func setOnSectionMoved(callback: CFunc<(Int32, Int32, Int32) -> Unit>): Unit {
        checkValid()
        unsafe {
            qHeaderViewConnectSectionMoved(ptr, callback)
        }
    }

    public func setOnSortIndicatorChanged(callback: Int32Int32Callback): Unit {
        checkValid()
        unsafe {
            qHeaderViewConnectSortIndicatorChanged(ptr, callback)
        }
    }

    public func setOnSectionHandleDoubleClicked(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qHeaderViewConnectSectionHandleDoubleClicked(ptr, callback)
        }
    }

    public func getPtr(): Int64 {
        ptr
    }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qHeaderViewDelete(ptr)
            }
            ptr = 0
        }
    }
}
