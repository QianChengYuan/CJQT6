package cjqt6.widgets

import cjqt6.core.*

// QScrollBar FFI 声明
foreign func qScrollBarCreate(orientation: Int32): Int64
foreign func qScrollBarSetRange(ptr: Int64, min: Int32, max: Int32): Unit
foreign func qScrollBarSetValue(ptr: Int64, value: Int32): Unit
foreign func qScrollBarValue(ptr: Int64): Int32
foreign func qScrollBarSetSingleStep(ptr: Int64, step: Int32): Unit
foreign func qScrollBarSetPageStep(ptr: Int64, step: Int32): Unit
foreign func qScrollBarSetOrientation(ptr: Int64, orientation: Int32): Unit
foreign func qScrollBarConnectValueChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qScrollBarDelete(ptr: Int64): Unit

/// 独立滚动条部件
public class QScrollBar {
    private var ptr: Int64 = 0
    
    /// 创建滚动条
    /// orientation: ScrollBarOrientation.Horizontal 或 ScrollBarOrientation.Vertical
    public init(orientation: Int32) {
        unsafe {
            ptr = qScrollBarCreate(orientation)
        }
    }
    
    public func show() {
        unsafe { qWidgetShow(ptr) }
    }
    
    public func hide() {
        unsafe { qWidgetHide(ptr) }
    }
    
    public func resize(width: Int32, height: Int32) {
        unsafe { qWidgetResize(ptr, width, height) }
    }
    
    /// 设置范围 [min, max]
    public func setRange(min: Int32, max: Int32) {
        unsafe { qScrollBarSetRange(ptr, min, max) }
    }
    
    /// 设置当前值
    public func setValue(value: Int32) {
        unsafe { qScrollBarSetValue(ptr, value) }
    }
    
    /// 获取当前值
    public func value(): Int32 {
        unsafe { return qScrollBarValue(ptr) }
    }
    
    /// 设置单步步长（箭头点击）
    public func setSingleStep(step: Int32) {
        unsafe { qScrollBarSetSingleStep(ptr, step) }
    }
    
    /// 设置翻页步长（点击滑块空白区域）
    public func setPageStep(step: Int32) {
        unsafe { qScrollBarSetPageStep(ptr, step) }
    }
    
    /// 设置方向
    public func setOrientation(orientation: Int32) {
        unsafe { qScrollBarSetOrientation(ptr, orientation) }
    }
    
    /// 设置值变化回调
    public func setOnValueChanged(callback: Int32Callback) {
        unsafe { qScrollBarConnectValueChanged(ptr, callback) }
    }
    
    /// 设置启用/禁用
    public func setEnabled(enabled: Bool) {
        unsafe { qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 }) }
    }
    
    /// 设置样式表
    public func setStyleSheet(style: String) {
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除部件
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qScrollBarDelete(ptr)
            }
            ptr = 0
        }
    }
}

/// 滚动条方向常量
public class ScrollBarOrientation {
    public static let Horizontal: Int32 = 1
    public static let Vertical: Int32 = 2
}
