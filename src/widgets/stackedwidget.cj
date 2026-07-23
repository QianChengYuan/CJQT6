package cjqt6.widgets

import cjqt6.core.*

// QStackedWidget - 堆叠窗口
foreign func qStackedWidgetCreate(): Int64
foreign func qStackedWidgetAddWidget(ptr: Int64, widgetPtr: Int64): Int32
foreign func qStackedWidgetInsertWidget(ptr: Int64, index: Int32, widgetPtr: Int64): Int32
foreign func qStackedWidgetRemoveWidget(ptr: Int64, widgetPtr: Int64): Unit
foreign func qStackedWidgetSetCurrentIndex(ptr: Int64, index: Int32): Unit
foreign func qStackedWidgetCurrentIndex(ptr: Int64): Int32
foreign func qStackedWidgetCurrentWidget(ptr: Int64): Int64
foreign func qStackedWidgetCount(ptr: Int64): Int32
foreign func qStackedWidgetSetCurrentWidget(ptr: Int64, widgetPtr: Int64): Unit
foreign func qStackedWidgetWidget(ptr: Int64, index: Int32): Int64
foreign func qStackedWidgetConnectCurrentChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qStackedWidgetConnectWidgetRemoved(ptr: Int64, callback: Int32Callback): Unit
foreign func qStackedWidgetDelete(ptr: Int64): Unit

/// 堆叠窗口部件
/// 管理多个子页面，一次只显示一个，常用于多页切换界面
public class QStackedWidget {
    private var ptr: Int64 = 0

    public init(parent!: Int64 = 0) {
        unsafe {
            ptr = qStackedWidgetCreate()
            if (parent != 0) {
                setWidgetParent(ptr, parent)
            }
        }
    }

    /// 显示
    public func show(): Unit {
        unsafe {
            qWidgetShow(ptr)
        }
    }

    /// 隐藏
    public func hide(): Unit {
        unsafe {
            qWidgetHide(ptr)
        }
    }

    /// 调整大小
    public func resize(width: Int32, height: Int32): Unit {
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }

    /// 添加页面到末尾，返回页面索引
    public func addWidget(widgetPtr: Int64): Int32 {
        unsafe {
            return qStackedWidgetAddWidget(ptr, widgetPtr)
        }
    }

    /// 在指定位置插入页面，返回页面索引
    public func insertWidget(index: Int32, widgetPtr: Int64): Int32 {
        unsafe {
            return qStackedWidgetInsertWidget(ptr, index, widgetPtr)
        }
    }

    /// 移除指定页面（不从内存释放控件）
    public func removeWidget(widgetPtr: Int64): Unit {
        unsafe {
            qStackedWidgetRemoveWidget(ptr, widgetPtr)
        }
    }

    /// 设置当前显示页面的索引
    public func setCurrentIndex(index: Int32): Unit {
        unsafe {
            qStackedWidgetSetCurrentIndex(ptr, index)
        }
    }

    /// 获取当前页面索引
    public func currentIndex(): Int32 {
        unsafe {
            return qStackedWidgetCurrentIndex(ptr)
        }
    }

    /// 获取当前页面指针
    public func currentWidget(): Int64 {
        unsafe {
            return qStackedWidgetCurrentWidget(ptr)
        }
    }

    /// 获取页面总数
    public func count(): Int32 {
        unsafe {
            return qStackedWidgetCount(ptr)
        }
    }

    /// 设置当前显示的子部件
    public func setCurrentWidget(widgetPtr: Int64): Unit {
        unsafe {
            qStackedWidgetSetCurrentWidget(ptr, widgetPtr)
        }
    }

    /// 获取指定索引处的子部件指针
    public func widget(index: Int32): Int64 {
        unsafe {
            return qStackedWidgetWidget(ptr, index)
        }
    }

    /// 当前页面切换回调（索引）
    public func setOnCurrentChanged(callback: Int32Callback): Unit {
        unsafe {
            qStackedWidgetConnectCurrentChanged(ptr, callback)
        }
    }

    /// 页面移除回调（索引）
    public func setOnWidgetRemoved(callback: Int32Callback): Unit {
        unsafe {
            qStackedWidgetConnectWidgetRemoved(ptr, callback)
        }
    }

    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }

    /// 删除堆叠窗口
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qStackedWidgetDelete(ptr)
            }
            ptr = 0
        }
    }
}
