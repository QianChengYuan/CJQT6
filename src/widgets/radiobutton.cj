package cjqt6.widgets

import cjqt6.core.*

// QRadioButton - 单选按钮
foreign func qRadioButtonCreate(): Int64
foreign func qRadioButtonSetText(ptr: Int64, text: CString): Unit
foreign func qRadioButtonText(ptr: Int64): CString
foreign func qRadioButtonSetChecked(ptr: Int64, checked: Bool): Unit
foreign func qRadioButtonIsChecked(ptr: Int64): Bool
foreign func qRadioButtonConnectToggled(ptr: Int64, callback: Int32Callback): Unit
foreign func qRadioButtonDisconnectToggled(ptr: Int64): Unit
foreign func qRadioButtonDelete(ptr: Int64): Unit
foreign func qRadioButtonSetAutoExclusive(ptr: Int64, v: Int32): Unit
foreign func qRadioButtonIsAutoExclusive(ptr: Int64): Int32
foreign func qRadioButtonConnectClicked(ptr: Int64, callback: Int32Callback): Unit

/// 单选按钮部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QRadioButton <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init() {
        unsafe {
            ptr = qRadioButtonCreate()
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
    
    public func setText(text: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            qRadioButtonSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func text(): String {
        checkValid()
        unsafe {
            let cstr = qRadioButtonText(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    public func setChecked(checked: Bool): Unit {
        checkValid()
        unsafe {
            qRadioButtonSetChecked(ptr, checked)
        }
    }
    
    public func isChecked(): Bool {
        checkValid()
        unsafe {
            return qRadioButtonIsChecked(ptr)
        }
    }
    
    /// 设置启用/禁用
    public func setEnabled(enabled: Bool): Unit {
        checkValid()
        unsafe {
            qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }
    
    /// 检查是否启用
    public func isEnabled(): Bool {
        checkValid()
        unsafe {
            qWidgetIsEnabled(ptr) == 1
        }
    }
    
    /// 设置样式表
    public func setStyleSheet(style: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置最小尺寸
    public func setMinimumSize(minw: Int32, minh: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetSetMinimumSize(ptr, minw, minh)
        }
    }
    
    /// 设置最大尺寸
    public func setMaximumSize(maxw: Int32, maxh: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetSetMaximumSize(ptr, maxw, maxh)
        }
    }
    
    /// 设置切换回调
    public func setOnToggled(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qRadioButtonConnectToggled(ptr, callback)
        }
    }
    
    /// 断开切换信号
    public func disconnectToggled(): Unit {
        checkValid()
        unsafe {
            qRadioButtonDisconnectToggled(ptr)
        }
    }
    
    /// 断开该单选按钮的全部信号（toggled）
    public func disconnect(): Unit {
        disconnectToggled()
    }
    
    /// 设置是否自动互斥（同父容器内自动排他）
    public func setAutoExclusive(autoExclusive: Bool): Unit {
        checkValid()
        unsafe {
            qRadioButtonSetAutoExclusive(ptr, if (autoExclusive) { 1 } else { 0 })
        }
    }
    
    /// 是否自动互斥
    public func isAutoExclusive(): Bool {
        checkValid()
        unsafe {
            return qRadioButtonIsAutoExclusive(ptr) != 0
        }
    }
    
    /// 点击回调（带 checked 状态，0/1）
    public func setOnClicked(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qRadioButtonConnectClicked(ptr, callback)
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 是否已关闭
    public func isClosed(): Bool {
        return closed
    }
    
    /// 检查对象有效性
    public func isValid(): Bool {
        return !closed && ptr != 0 && isObjectAlive(ptr)
    }
    
    /// 检查有效性，无效时抛出异常
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QRadioButton 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QRadioButton 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QRadioButton 底层 Qt 对象已失效")
        }
    }
    
    /// 关闭资源，释放Qt对象
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
                qSignalCleanup(ptr)
                qRadioButtonDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除单选按钮（兼容旧API）
    public func delete(): Unit {
        close()
    }
}
