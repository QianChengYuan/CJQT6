package cjqt6.widgets

import cjqt6.core.*

// QToolBox - 工具箱
foreign func qToolBoxCreate(): Int64
foreign func qToolBoxDelete(ptr: Int64): Unit
foreign func qToolBoxAddItem(ptr: Int64, widgetPtr: Int64, title: CString): Int32
foreign func qToolBoxInsertItem(ptr: Int64, index: Int32, widgetPtr: Int64, title: CString): Int32
foreign func qToolBoxRemoveItem(ptr: Int64, index: Int32): Unit
foreign func qToolBoxCount(ptr: Int64): Int32
foreign func qToolBoxCurrentIndex(ptr: Int64): Int32
foreign func qToolBoxSetCurrentIndex(ptr: Int64, index: Int32): Unit
foreign func qToolBoxSetItemText(ptr: Int64, index: Int32, text: CString): Unit
foreign func qToolBoxItemText(ptr: Int64, index: Int32): CString
foreign func qToolBoxSetItemToolTip(ptr: Int64, index: Int32, toolTip: CString): Unit
foreign func qToolBoxSetItemEnabled(ptr: Int64, index: Int32, enabled: Int32): Unit
foreign func qToolBoxIsItemEnabled(ptr: Int64, index: Int32): Int32
foreign func qToolBoxSetItemIcon(ptr: Int64, index: Int32, path: CString): Unit
foreign func qToolBoxSetCurrentWidget(ptr: Int64, widgetPtr: Int64): Unit
foreign func qToolBoxIndexOf(ptr: Int64, widgetPtr: Int64): Int32
foreign func qToolBoxConnectCurrentChanged(ptr: Int64, callback: Int32Callback): Unit

/// 工具箱控件，以选项卡方式组织多个页面（类似分页容器）
public class QToolBox {
    private var ptr: Int64 = 0

    public init(parent!: Int64 = 0) {
        unsafe {
            ptr = qToolBoxCreate()
            if (parent != 0) {
                setWidgetParent(ptr, parent)
            }
        }
    }

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

    public func addItem(widgetPtr: Int64, title: String): Int32 {
        unsafe {
            var cstr = LibC.mallocCString(title)
            let ret = qToolBoxAddItem(ptr, widgetPtr, cstr)
            LibC.free(cstr)
            ret
        }
    }

    public func insertItem(index: Int32, widgetPtr: Int64, title: String): Int32 {
        unsafe {
            var cstr = LibC.mallocCString(title)
            let ret = qToolBoxInsertItem(ptr, index, widgetPtr, cstr)
            LibC.free(cstr)
            ret
        }
    }

    public func removeItem(index: Int32) {
        unsafe {
            qToolBoxRemoveItem(ptr, index)
        }
    }

    public func count(): Int32 {
        unsafe {
            qToolBoxCount(ptr)
        }
    }

    public func currentIndex(): Int32 {
        unsafe {
            qToolBoxCurrentIndex(ptr)
        }
    }

    public func setCurrentIndex(index: Int32) {
        unsafe {
            qToolBoxSetCurrentIndex(ptr, index)
        }
    }

    public func setItemText(index: Int32, text: String) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            qToolBoxSetItemText(ptr, index, cstr)
            LibC.free(cstr)
        }
    }

    public func itemText(index: Int32): String {
        unsafe {
            let cstr = qToolBoxItemText(ptr, index)
            let result = cstr.toString()
            freeBridgeString(cstr)
            result
        }
    }

    public func setItemToolTip(index: Int32, toolTip: String) {
        unsafe {
            var cstr = LibC.mallocCString(toolTip)
            qToolBoxSetItemToolTip(ptr, index, cstr)
            LibC.free(cstr)
        }
    }

    public func setItemEnabled(index: Int32, enabled: Bool) {
        unsafe {
            qToolBoxSetItemEnabled(ptr, index, if (enabled) { 1 } else { 0 })
        }
    }

    public func isItemEnabled(index: Int32): Bool {
        unsafe {
            qToolBoxIsItemEnabled(ptr, index) == 1
        }
    }

    /// 设置指定项图标（按文件路径）
    public func setItemIcon(index: Int32, path: String) {
        unsafe {
            let cstr = LibC.mallocCString(path)
            qToolBoxSetItemIcon(ptr, index, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置当前显示的子部件
    public func setCurrentWidget(widgetPtr: Int64) {
        unsafe {
            qToolBoxSetCurrentWidget(ptr, widgetPtr)
        }
    }

    /// 查找子部件所在的索引（未找到返回 -1）
    public func indexOf(widgetPtr: Int64): Int32 {
        unsafe {
            qToolBoxIndexOf(ptr, widgetPtr)
        }
    }

    /// 当前项切换回调（索引）
    public func setOnCurrentChanged(callback: Int32Callback) {
        unsafe {
            qToolBoxConnectCurrentChanged(ptr, callback)
        }
    }
    
    public func setLayout(layoutPtr: Int64) {
        unsafe {
            qWidgetSetLayout(ptr, layoutPtr)
        }
    }

    public func getPtr(): Int64 {
        ptr
    }

    public func delete() {
        if (ptr != 0) {
            unsafe {
                qToolBoxDelete(ptr)
            }
            ptr = 0
        }
    }
}
