package cjqt6.widgets

import cjqt6.core.*

// QCheckBox - 复选框FFI声明
// QCheckBox::create() - 创建复选框
foreign func qCheckBoxCreate(): Int64
// QCheckBox::setText() - 设置文本
foreign func qCheckBoxSetText(ptr: Int64, text: CString): Unit
// QCheckBox::text() - 获取文本
foreign func qCheckBoxText(ptr: Int64): CString
// QCheckBox::setChecked() - 设置选中状态
foreign func qCheckBoxSetChecked(ptr: Int64, checked: Bool): Unit
// QCheckBox::isChecked() - 获取选中状态
foreign func qCheckBoxIsChecked(ptr: Int64): Bool
// QCheckBox::connectStateChanged() - 连接状态变化信号
foreign func qCheckBoxConnectStateChanged(ptr: Int64, callback: Int32Callback): Unit
// QCheckBox::disconnectStateChanged() - 断开状态变化信号
foreign func qCheckBoxDisconnectStateChanged(ptr: Int64): Unit
// QCheckBox析构 - 删除复选框
foreign func qCheckBoxDelete(ptr: Int64): Unit
// QCheckBox::setCheckState() - 设置三态勾选状态
foreign func qCheckBoxSetCheckState(ptr: Int64, state: Int32): Unit
// QCheckBox::checkState() - 获取三态勾选状态
foreign func qCheckBoxCheckState(ptr: Int64): Int32
// QCheckBox::setTristate() - 设置是否三态
foreign func qCheckBoxSetTristate(ptr: Int64, v: Int32): Unit
// QCheckBox::isTristate() - 获取是否三态
foreign func qCheckBoxIsTristate(ptr: Int64): Int32
// QCheckBox::connectClicked() - 连接点击信号
foreign func qCheckBoxConnectClicked(ptr: Int64, callback: Int32Callback): Unit

/// 复选框三态枚举（对应 Qt::CheckState）
public class CheckState {
    public static let Unchecked: Int32 = 0
    public static let PartiallyChecked: Int32 = 1
    public static let Checked: Int32 = 2
}

/// 复选框部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QCheckBox <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init() {
        unsafe {
            ptr = qCheckBoxCreate()
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
            withCString(text) { c => qCheckBoxSetText(ptr, c) }
        }
    }
    
    public func text(): String {
        checkValid()
        unsafe {
            let cstr = qCheckBoxText(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    public func setChecked(checked: Bool): Unit {
        checkValid()
        unsafe {
            qCheckBoxSetChecked(ptr, checked)
        }
    }
    
    public func isChecked(): Bool {
        checkValid()
        unsafe {
            return qCheckBoxIsChecked(ptr)
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
            withCString(style) { c => qWidgetSetStyleSheet(ptr, c) }
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
    
    /// 设置状态变化回调
    public func setOnStateChanged(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qCheckBoxConnectStateChanged(ptr, callback)
        }
    }
    
    /// 断开状态变化信号
    public func disconnectStateChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qCheckBoxDisconnectStateChanged(ptr)
            }
        }
    }
    
    /// 断开该复选框的全部信号（stateChanged）
    public func disconnect(): Unit {
        disconnectStateChanged()
    }
    
    /// 设置三态勾选状态（使用 CheckState 常量）
    public func setCheckState(state: Int32): Unit {
        checkValid()
        unsafe {
            qCheckBoxSetCheckState(ptr, state)
        }
    }
    
    /// 获取勾选状态（CheckState 枚举值）
    public func checkState(): Int32 {
        checkValid()
        unsafe {
            return qCheckBoxCheckState(ptr)
        }
    }
    
    /// 设置是否三态
    public func setTristate(tristate: Bool): Unit {
        checkValid()
        unsafe {
            qCheckBoxSetTristate(ptr, if (tristate) { 1 } else { 0 })
        }
    }
    
    /// 是否三态
    public func isTristate(): Bool {
        checkValid()
        unsafe {
            return qCheckBoxIsTristate(ptr) != 0
        }
    }
    
    /// 点击回调（带 checked 状态，0/1）
    public func setOnClicked(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qCheckBoxConnectClicked(ptr, callback)
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
        return !closed && ptr != 0 && isObjectAlive(ptr)
    }
    
    /// 检查有效性，无效时抛出异常
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QCheckBox 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QCheckBox 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QCheckBox 底层 Qt 对象已失效")
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
                qCheckBoxDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除复选框（兼容旧API）
    public func delete(): Unit {
        close()
    }
}
