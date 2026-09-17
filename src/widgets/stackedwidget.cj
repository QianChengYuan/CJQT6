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
public class QStackedWidget <: QtWidgetCore {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    public init(parent!: Int64 = 0) {
        unsafe {
            ptr = qStackedWidgetCreate()
            if (parent != 0) {
                setWidgetParent(ptr, parent)
            }
        }
        trackObject(ptr)
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

    /// 是否已关闭
    public func isClosed(): Bool {
        closed
    }

    /// 对象是否仍然可用
    public func isValid(): Bool {
        !closed && ptr != 0 && isObjectAlive(ptr)
    }

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QStackedWidget 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QStackedWidget 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QStackedWidget 底层 Qt 对象已失效")
        }
    }

    /// 关闭资源，释放 Qt 对象（幂等）
    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            unsafe {
                qStackedWidgetDelete(ptr)
            }
        }
        closed = true
        ptr = 0
    }

    /// 删除堆叠窗口（兼容旧 API，等价于 close()）
    public func delete(): Unit {
        close()
    }
}
