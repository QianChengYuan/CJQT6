package cjqt6.views

import cjqt6.core.*

// ============================================================
// QTreeWidget FFI声明
// ============================================================

// QTreeWidget
foreign func qTreeWidgetCreate(): Int64
foreign func qTreeWidgetDelete(ptr: Int64): Unit
foreign func qTreeWidgetSetColumnCount(ptr: Int64, columns: Int32): Unit
foreign func qTreeWidgetSetHeaderLabel(ptr: Int64, column: Int32, label: CString): Unit
foreign func qTreeWidgetSetHeaderHidden(ptr: Int64, hidden: Bool): Unit

foreign func qTreeWidgetAddTopLevelItem(ptr: Int64, text: CString): Int64
foreign func qTreeWidgetInsertTopLevelItem(ptr: Int64, index: Int32, itemPtr: Int64): Unit
foreign func qTreeWidgetTakeTopLevelItem(ptr: Int64, index: Int32): Unit
foreign func qTreeWidgetTopLevelItemCount(ptr: Int64): Int32
foreign func qTreeWidgetTopLevelItem(ptr: Int64, index: Int32): Int64
foreign func qTreeWidgetClear(ptr: Int64): Unit

foreign func qTreeWidgetCurrentItem(ptr: Int64): Int64
foreign func qTreeWidgetSetCurrentItem(ptr: Int64, itemPtr: Int64): Unit

foreign func qTreeWidgetExpandItem(ptr: Int64, itemPtr: Int64): Unit
foreign func qTreeWidgetCollapseItem(ptr: Int64, itemPtr: Int64): Unit
foreign func qTreeWidgetExpandAll(ptr: Int64): Unit
foreign func qTreeWidgetCollapseAll(ptr: Int64): Unit

// QTreeWidgetItem
foreign func qTreeWidgetItemCreate(): Int64
foreign func qTreeWidgetItemCreateWithText(text: CString): Int64
foreign func qTreeWidgetItemDelete(itemPtr: Int64): Unit

foreign func qTreeWidgetItemSetText(itemPtr: Int64, column: Int32, text: CString): Unit
foreign func qTreeWidgetItemText(itemPtr: Int64, column: Int32): CString

foreign func qTreeWidgetItemAddChild(itemPtr: Int64, text: CString): Int64
foreign func qTreeWidgetItemAddChildItem(itemPtr: Int64, childPtr: Int64): Unit
foreign func qTreeWidgetItemChildCount(itemPtr: Int64): Int32
foreign func qTreeWidgetItemChild(itemPtr: Int64, index: Int32): Int64
foreign func qTreeWidgetItemTakeChild(itemPtr: Int64, index: Int32): Unit
foreign func qTreeWidgetItemParent(itemPtr: Int64): Int64

foreign func qTreeWidgetItemSetData(itemPtr: Int64, column: Int32, data: Int64): Unit
foreign func qTreeWidgetItemGetData(itemPtr: Int64, column: Int32): Int64

foreign func qTreeWidgetItemSetExpanded(itemPtr: Int64, expanded: Bool): Unit
foreign func qTreeWidgetItemIsExpanded(itemPtr: Int64): Bool

foreign func qTreeWidgetItemSetCheckState(itemPtr: Int64, column: Int32, state: Int32): Unit
foreign func qTreeWidgetItemCheckState(itemPtr: Int64, column: Int32): Int32

foreign func qTreeWidgetItemSetSelected(itemPtr: Int64, selected: Bool): Unit
foreign func qTreeWidgetItemIsSelected(itemPtr: Int64): Bool

foreign func qTreeWidgetItemSetHidden(itemPtr: Int64, hidden: Bool): Unit
foreign func qTreeWidgetItemIsHidden(itemPtr: Int64): Bool

// QTreeWidget 事件回调
foreign func qTreeWidgetSetOnItemClicked(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit
foreign func qTreeWidgetSetOnItemDoubleClicked(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit
foreign func qTreeWidgetSetOnItemExpanded(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit
foreign func qTreeWidgetSetOnItemCollapsed(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit
foreign func qTreeWidgetSetOnCurrentItemChanged(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit

// 补充 API FFI
foreign func qTreeWidgetColumnCount(ptr: Int64): Int32
foreign func qTreeWidgetSetHeaderItem(ptr: Int64, itemPtr: Int64): Unit
foreign func qTreeWidgetIndexOfTopLevelItem(ptr: Int64, itemPtr: Int64): Int32
foreign func qTreeWidgetSelectedItems(ptr: Int64): Int32
foreign func qTreeWidgetSetSelectionMode(ptr: Int64, mode: Int32): Unit
foreign func qTreeWidgetConnectItemClicked(ptr: Int64, callback: CFunc<(Int64, Int32) -> Unit>): Unit
foreign func qTreeWidgetConnectItemDoubleClicked(ptr: Int64, callback: CFunc<(Int64, Int32) -> Unit>): Unit
foreign func qTreeWidgetConnectItemChanged(ptr: Int64, callback: CFunc<(Int64, Int32) -> Unit>): Unit

// 勾选状态常量
public class CheckState {
    public static let Unchecked: Int32 = 0
    public static let PartiallyChecked: Int32 = 1
    public static let Checked: Int32 = 2
}

// ============================================================
// QTreeWidgetItem - 树形项
// ============================================================
public class QTreeWidgetItem {
    private let ptr: Int64
    
    public init() {
        unsafe {
            ptr = qTreeWidgetItemCreate()
        }
    }
    
    public init(text: String) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            ptr = qTreeWidgetItemCreateWithText(cstr)
            LibC.free(cstr)
        }
    }
    
    // 从指针创建（不拥有所有权）
    public static func fromPtr(ptr: Int64): QTreeWidgetItem {
        QTreeWidgetItem(ptr, ())  // 直接使用私有构造函数，无泄漏
    }
    
    // 内部构造函数
    private init(ptr: Int64, _: Unit) {
        this.ptr = ptr
    }
    
    public static func __fromPtr(ptr: Int64): QTreeWidgetItem {
        QTreeWidgetItem(ptr, ())
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    // ========== 文本 ==========
    
    public func setText(column: Int32, text: String) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            qTreeWidgetItemSetText(ptr, column, cstr)
            LibC.free(cstr)
        }
    }
    
    public func text(column: Int32): String {
        unsafe {
            let cstr = qTreeWidgetItemText(ptr, column)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    // ========== 子项 ==========
    
    public func addChild(text: String): QTreeWidgetItem {
        unsafe {
            var cstr = LibC.mallocCString(text)
            let childPtr = qTreeWidgetItemAddChild(ptr, cstr)
            LibC.free(cstr)
            return QTreeWidgetItem.__fromPtr(childPtr)
        }
    }
    
    public func addChildItem(child: QTreeWidgetItem) {
        unsafe {
            qTreeWidgetItemAddChildItem(ptr, child.getPtr())
        }
    }
    
    public func childCount(): Int32 {
        unsafe {
            qTreeWidgetItemChildCount(ptr)
        }
    }
    
    public func child(index: Int32): QTreeWidgetItem {
        unsafe {
            let childPtr = qTreeWidgetItemChild(ptr, index)
            return QTreeWidgetItem.__fromPtr(childPtr)
        }
    }
    
    public func takeChild(index: Int32) {
        unsafe {
            qTreeWidgetItemTakeChild(ptr, index)
        }
    }
    
    // ========== 父项 ==========
    
    public func parent(): ?QTreeWidgetItem {
        unsafe {
            let parentPtr = qTreeWidgetItemParent(ptr)
            if (parentPtr == 0) {
                return None
            }
            return Some(QTreeWidgetItem.__fromPtr(parentPtr))
        }
    }
    
    // ========== 用户数据 ==========
    
    public func setData(column: Int32, data: Int64) {
        unsafe {
            qTreeWidgetItemSetData(ptr, column, data)
        }
    }
    
    public func getData(column: Int32): Int64 {
        unsafe {
            qTreeWidgetItemGetData(ptr, column)
        }
    }
    
    // ========== 展开/折叠 ==========
    
    public func setExpanded(expanded: Bool) {
        unsafe {
            qTreeWidgetItemSetExpanded(ptr, expanded)
        }
    }
    
    public func isExpanded(): Bool {
        unsafe {
            qTreeWidgetItemIsExpanded(ptr)
        }
    }
    
    // ========== 勾选 ==========
    
    public func setCheckState(column: Int32, state: Int32) {
        unsafe {
            qTreeWidgetItemSetCheckState(ptr, column, state)
        }
    }
    
    public func checkState(column: Int32): Int32 {
        unsafe {
            qTreeWidgetItemCheckState(ptr, column)
        }
    }
    
    // ========== 选中 ==========
    
    public func setSelected(selected: Bool) {
        unsafe {
            qTreeWidgetItemSetSelected(ptr, selected)
        }
    }
    
    public func isSelected(): Bool {
        unsafe {
            qTreeWidgetItemIsSelected(ptr)
        }
    }
    
    // ========== 隐藏 ==========
    
    public func setHidden(hidden: Bool) {
        unsafe {
            qTreeWidgetItemSetHidden(ptr, hidden)
        }
    }
    
    public func isHidden(): Bool {
        unsafe {
            qTreeWidgetItemIsHidden(ptr)
        }
    }
}

// ============================================================
// QTreeWidget - 树形部件
// ============================================================
public class QTreeWidget {
    private let ptr: Int64
    
    public init() {
        unsafe {
            ptr = qTreeWidgetCreate()
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qTreeWidgetDelete(ptr)
            }
        }
    }
    
    // ========== 列设置 ==========
    
    public func setColumnCount(columns: Int32) {
        unsafe {
            qTreeWidgetSetColumnCount(ptr, columns)
        }
    }
    
    public func setHeaderLabel(column: Int32, label: String) {
        unsafe {
            var cstr = LibC.mallocCString(label)
            qTreeWidgetSetHeaderLabel(ptr, column, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setHeaderHidden(hidden: Bool) {
        unsafe {
            qTreeWidgetSetHeaderHidden(ptr, hidden)
        }
    }
    
    // ========== 顶级项 ==========
    
    public func addTopLevelItem(text: String): QTreeWidgetItem {
        unsafe {
            var cstr = LibC.mallocCString(text)
            let itemPtr = qTreeWidgetAddTopLevelItem(ptr, cstr)
            LibC.free(cstr)
            return QTreeWidgetItem.__fromPtr(itemPtr)
        }
    }
    
    public func insertTopLevelItem(index: Int32, item: QTreeWidgetItem) {
        unsafe {
            qTreeWidgetInsertTopLevelItem(ptr, index, item.getPtr())
        }
    }
    
    public func takeTopLevelItem(index: Int32) {
        unsafe {
            qTreeWidgetTakeTopLevelItem(ptr, index)
        }
    }
    
    public func topLevelItemCount(): Int32 {
        unsafe {
            qTreeWidgetTopLevelItemCount(ptr)
        }
    }
    
    public func topLevelItem(index: Int32): QTreeWidgetItem {
        unsafe {
            let itemPtr = qTreeWidgetTopLevelItem(ptr, index)
            return QTreeWidgetItem.__fromPtr(itemPtr)
        }
    }
    
    public func clear() {
        unsafe {
            qTreeWidgetClear(ptr)
        }
    }
    
    // ========== 当前选中 ==========
    
    public func currentItem(): ?QTreeWidgetItem {
        unsafe {
            let itemPtr = qTreeWidgetCurrentItem(ptr)
            if (itemPtr == 0) {
                return None
            }
            return Some(QTreeWidgetItem.__fromPtr(itemPtr))
        }
    }
    
    public func setCurrentItem(item: QTreeWidgetItem) {
        unsafe {
            qTreeWidgetSetCurrentItem(ptr, item.getPtr())
        }
    }
    
    // ========== 展开/折叠 ==========
    
    public func expandItem(item: QTreeWidgetItem) {
        unsafe {
            qTreeWidgetExpandItem(ptr, item.getPtr())
        }
    }
    
    public func collapseItem(item: QTreeWidgetItem) {
        unsafe {
            qTreeWidgetCollapseItem(ptr, item.getPtr())
        }
    }
    
    public func expandAll() {
        unsafe {
            qTreeWidgetExpandAll(ptr)
        }
    }
    
    public func collapseAll() {
        unsafe {
            qTreeWidgetCollapseAll(ptr)
        }
    }
    
    // ========== 事件回调 ==========
    
    // 设置项点击回调
    public func setOnItemClicked(callback: CFunc<(Int64) -> Unit>) {
        unsafe {
            qTreeWidgetSetOnItemClicked(ptr, callback)
        }
    }
    
    // 设置项双击回调
    public func setOnItemDoubleClicked(callback: CFunc<(Int64) -> Unit>) {
        unsafe {
            qTreeWidgetSetOnItemDoubleClicked(ptr, callback)
        }
    }
    
    // 设置项展开回调
    public func setOnItemExpanded(callback: CFunc<(Int64) -> Unit>) {
        unsafe {
            qTreeWidgetSetOnItemExpanded(ptr, callback)
        }
    }
    
    // 设置项折叠回调
    public func setOnItemCollapsed(callback: CFunc<(Int64) -> Unit>) {
        unsafe {
            qTreeWidgetSetOnItemCollapsed(ptr, callback)
        }
    }
    
    // 设置当前项变化回调
    public func setOnCurrentItemChanged(callback: CFunc<(Int64) -> Unit>) {
        unsafe {
            qTreeWidgetSetOnCurrentItemChanged(ptr, callback)
        }
    }
    
    // ========== 补充 API ==========

    public func columnCount(): Int32 {
        unsafe {
            qTreeWidgetColumnCount(ptr)
        }
    }

    public func setHeaderItem(item: QTreeWidgetItem) {
        unsafe {
            qTreeWidgetSetHeaderItem(ptr, item.getPtr())
        }
    }

    public func indexOfTopLevelItem(item: QTreeWidgetItem): Int32 {
        unsafe {
            qTreeWidgetIndexOfTopLevelItem(ptr, item.getPtr())
        }
    }

    public func selectedItems(): Int32 {
        unsafe {
            qTreeWidgetSelectedItems(ptr)
        }
    }

    public func setSelectionMode(mode: Int32) {
        unsafe {
            qTreeWidgetSetSelectionMode(ptr, mode)
        }
    }

    // 带列号的点击回调（区别于已有的 setOnItemClicked 仅传项指针）
    public func setOnItemClickedWithColumn(callback: CFunc<(Int64, Int32) -> Unit>) {
        unsafe {
            qTreeWidgetConnectItemClicked(ptr, callback)
        }
    }

    public func setOnItemDoubleClickedWithColumn(callback: CFunc<(Int64, Int32) -> Unit>) {
        unsafe {
            qTreeWidgetConnectItemDoubleClicked(ptr, callback)
        }
    }

    public func setOnItemChanged(callback: CFunc<(Int64, Int32) -> Unit>) {
        unsafe {
            qTreeWidgetConnectItemChanged(ptr, callback)
        }
    }

    // ========== 继承自QWidget的方法 ==========
    
    public func show() {
        unsafe {
            qWidgetShow(ptr)
        }
    }
    
    public func hide() {
        unsafe {
            qWidgetHide(ptr)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }

    public func setMinimumSize(minw: Int32, minh: Int32) {
        unsafe {
            qWidgetSetMinimumSize(ptr, minw, minh)
        }
    }
}
