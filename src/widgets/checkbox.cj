package cjqt6.widgets

import cjqt6.core.*

// QCheckBox - 复选框
foreign func qCheckBoxCreate(): Int64
foreign func qCheckBoxSetText(ptr: Int64, text: CString): Unit
foreign func qCheckBoxText(ptr: Int64): CString
foreign func qCheckBoxSetChecked(ptr: Int64, checked: Bool): Unit
foreign func qCheckBoxIsChecked(ptr: Int64): Bool
foreign func qCheckBoxConnectStateChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qCheckBoxDisconnectStateChanged(ptr: Int64): Unit
foreign func qCheckBoxDelete(ptr: Int64): Unit
foreign func qCheckBoxSetCheckState(ptr: Int64, state: Int32): Unit
foreign func qCheckBoxCheckState(ptr: Int64): Int32
foreign func qCheckBoxSetTristate(ptr: Int64, v: Int32): Unit
foreign func qCheckBoxIsTristate(ptr: Int64): Int32
foreign func qCheckBoxConnectClicked(ptr: Int64, callback: Int32Callback): Unit

/// 复选框三态枚举（对应 Qt::CheckState）
public class CheckState {
    public static let Unchecked: Int32 = 0
    public static let PartiallyChecked: Int32 = 1
    public static let Checked: Int32 = 2
}

/// 复选框部件
public class QCheckBox {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qCheckBoxCreate()
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
    
    public func setText(text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qCheckBoxSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func text(): String {
        unsafe {
            let cstr = qCheckBoxText(ptr)
            return cstr.toString()
        }
    }
    
    public func setChecked(checked: Bool) {
        unsafe {
            qCheckBoxSetChecked(ptr, checked)
        }
    }
    
    public func isChecked(): Bool {
        unsafe {
            return qCheckBoxIsChecked(ptr)
        }
    }
    
    /// 设置启用/禁用
    public func setEnabled(enabled: Bool) {
        unsafe {
            qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }
    
    /// 检查是否启用
    public func isEnabled(): Bool {
        unsafe {
            qWidgetIsEnabled(ptr) == 1
        }
    }
    
    /// 设置样式表
    public func setStyleSheet(style: String) {
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置最小尺寸
    public func setMinimumSize(minw: Int32, minh: Int32) {
        unsafe {
            qWidgetSetMinimumSize(ptr, minw, minh)
        }
    }
    
    /// 设置最大尺寸
    public func setMaximumSize(maxw: Int32, maxh: Int32) {
        unsafe {
            qWidgetSetMaximumSize(ptr, maxw, maxh)
        }
    }
    
    /// 设置状态变化回调
    public func setOnStateChanged(callback: Int32Callback) {
        unsafe {
            qCheckBoxConnectStateChanged(ptr, callback)
        }
    }
    
    /// 断开状态变化信号
    public func disconnectStateChanged() {
        unsafe {
            qCheckBoxDisconnectStateChanged(ptr)
        }
    }
    
    /// 设置三态勾选状态（使用 CheckState 常量）
    public func setCheckState(state: Int32) {
        unsafe {
            qCheckBoxSetCheckState(ptr, state)
        }
    }
    
    /// 获取勾选状态（CheckState 枚举值）
    public func checkState(): Int32 {
        unsafe {
            return qCheckBoxCheckState(ptr)
        }
    }
    
    /// 设置是否三态
    public func setTristate(tristate: Bool) {
        unsafe {
            qCheckBoxSetTristate(ptr, if (tristate) { 1 } else { 0 })
        }
    }
    
    /// 是否三态
    public func isTristate(): Bool {
        unsafe {
            return qCheckBoxIsTristate(ptr) != 0
        }
    }
    
    /// 点击回调（带 checked 状态，0/1）
    public func setOnClicked(callback: Int32Callback) {
        unsafe {
            qCheckBoxConnectClicked(ptr, callback)
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除复选框
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qCheckBoxDelete(ptr)
            }
            ptr = 0
        }
    }
}