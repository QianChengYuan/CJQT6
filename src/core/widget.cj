package cjqt6.core

// QWidget - 基础窗口部件
foreign func qWidgetCreate(): Int64
foreign func qWidgetShow(ptr: Int64): Unit
foreign func qWidgetHide(ptr: Int64): Unit
foreign func qWidgetSetTitle(ptr: Int64, title: CString): Unit
foreign func qWidgetResize(ptr: Int64, width: Int32, height: Int32): Unit
foreign func qWidgetSetGeometry(ptr: Int64, x: Int32, y: Int32, width: Int32, height: Int32): Unit
foreign func qWidgetSetParent(ptr: Int64, parentPtr: Int64): Unit
foreign func qWidgetSetLayout(widgetPtr: Int64, layoutPtr: Int64): Unit
foreign func qWidgetDelete(ptr: Int64): Unit

public func setWidgetGeometry(widgetPtr: Int64, x: Int32, y: Int32, width: Int32, height: Int32): Unit {
    unsafe { qWidgetSetGeometry(widgetPtr, x, y, width, height) }
}

public func setWidgetParent(widgetPtr: Int64, parentPtr: Int64): Unit {
    unsafe { qWidgetSetParent(widgetPtr, parentPtr) }
}

// QWidget 样式表和扩展功能
foreign func qWidgetSetStyleSheet(ptr: Int64, styleSheet: CString): Unit
foreign func qWidgetStyleSheet(ptr: Int64): CString
foreign func qWidgetSetEnabled(ptr: Int64, enabled: Int32): Unit
foreign func qWidgetIsEnabled(ptr: Int64): Int32
foreign func qWidgetSetVisible(ptr: Int64, visible: Int32): Unit
foreign func qWidgetIsVisible(ptr: Int64): Int32
foreign func qWidgetSetToolTip(ptr: Int64, toolTip: CString): Unit
foreign func qWidgetSetMinimumSize(ptr: Int64, width: Int32, height: Int32): Unit
foreign func qWidgetSetMaximumSize(ptr: Int64, width: Int32, height: Int32): Unit
foreign func qWidgetWidth(ptr: Int64): Int32
foreign func qWidgetHeight(ptr: Int64): Int32
foreign func qWidgetUpdate(ptr: Int64): Unit
foreign func qWidgetRepaint(ptr: Int64): Unit

/// 基础窗口部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QWidget <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    /// 创建窗口部件
    public init() {
        unsafe {
            ptr = qWidgetCreate()
            if (ptr == 0) {
                throw CreateFailedException("QWidget 创建失败")
            }
        }
    }
    
    /// 从指针创建（用于继承）
    protected init(ptr: Int64) {
        if (ptr == 0) {
            throw CreateFailedException("QWidget 指针无效")
        }
        this.ptr = ptr
    }
    
    /// 显示窗口
    public func show(): Unit {
        checkValid()
        unsafe {
            qWidgetShow(ptr)
        }
    }
    
    /// 隐藏窗口
    public func hide(): Unit {
        checkValid()
        unsafe {
            qWidgetHide(ptr)
        }
    }
    
    /// 设置窗口标题
    public func setTitle(title: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(title)
            qWidgetSetTitle(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 调整窗口大小
    public func resize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }
    
    /// 设置窗口位置和大小
    public func setGeometry(x: Int32, y: Int32, width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetSetGeometry(ptr, x, y, width, height)
        }
    }
    
    /// 设置布局
    public func setLayout(layoutPtr: Int64): Unit {
        checkValid()
        unsafe {
            qWidgetSetLayout(ptr, layoutPtr)
        }
    }
    
    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 是否已关闭
    public func isClosed(): Bool {
        return closed
    }
    
    /// 检查对象有效性
    public func isValid(): Bool {
        return !closed && ptr != 0
    }
    
    /// 检查有效性，无效时抛出异常
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QWidget 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QWidget 指针为空")
        }
    }
    
    /// 关闭资源，释放Qt对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qWidgetDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除窗口（兼容旧API）
    public func delete(): Unit {
        close()
    }
    
    /// 终结器 - 已禁用
    /// 注意：仓颉 GC 调用终结器的时机不确定，可能在 Qt 对象仍被使用时提前删除导致崩溃
    /// 请在不需要时显式调用 delete() 或 close() 释放资源
    // ~init() {
    //     if (!closed && ptr != 0) {
    //         unsafe {
    //             qSignalCleanup(ptr)
    //             qWidgetDelete(ptr)
    //         }
    //         closed = true
    //         ptr = 0
    //     }
    // }
    
    // ========== 样式表和扩展功能 ==========
    
    /// 设置样式表
    public func setStyleSheet(styleSheet: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(styleSheet)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取样式表
    public func styleSheet(): String {
        checkValid()
        unsafe {
            let cstr = qWidgetStyleSheet(ptr)
            return cstr.toString()
        }
    }
    
    /// 设置启用状态
    public func setEnabled(enabled: Bool): Unit {
        checkValid()
        unsafe {
            qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }
    
    /// 是否启用
    public func isEnabled(): Bool {
        checkValid()
        unsafe {
            return qWidgetIsEnabled(ptr) == 1
        }
    }
    
    /// 设置可见性
    public func setVisible(visible: Bool): Unit {
        checkValid()
        unsafe {
            qWidgetSetVisible(ptr, if (visible) { 1 } else { 0 })
        }
    }
    
    /// 是否可见
    public func isVisible(): Bool {
        checkValid()
        unsafe {
            return qWidgetIsVisible(ptr) == 1
        }
    }
    
    /// 设置工具提示
    public func setToolTip(toolTip: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(toolTip)
            qWidgetSetToolTip(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置最小尺寸
    public func setMinimumSize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetSetMinimumSize(ptr, width, height)
        }
    }
    
    /// 设置最大尺寸
    public func setMaximumSize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetSetMaximumSize(ptr, width, height)
        }
    }
    
    /// 获取宽度
    public func width(): Int32 {
        checkValid()
        unsafe {
            return qWidgetWidth(ptr)
        }
    }
    
    /// 获取高度
    public func height(): Int32 {
        checkValid()
        unsafe {
            return qWidgetHeight(ptr)
        }
    }
    
    /// 更新窗口
    public func update(): Unit {
        checkValid()
        unsafe {
            qWidgetUpdate(ptr)
        }
    }
    
    /// 重绘窗口
    public func repaint(): Unit {
        checkValid()
        unsafe {
            qWidgetRepaint(ptr)
        }
    }
    
    /// 设置控件销毁回调
    public func setOnDestroyed(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qWidgetConnectDestroyed(ptr, callback)
        }
    }
    
    /// 断开控件销毁信号
    public func disconnectDestroyed(): Unit {
        if (ptr != 0) {
            unsafe {
                qWidgetDisconnectDestroyed(ptr)
            }
        }
    }
}
