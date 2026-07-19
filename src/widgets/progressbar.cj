package cjqt6.widgets

import cjqt6.core.*

// QProgressBar - 进度条
foreign func qProgressBarCreate(): Int64
foreign func qProgressBarSetValue(ptr: Int64, value: Int32): Unit
foreign func qProgressBarValue(ptr: Int64): Int32
foreign func qProgressBarSetRange(ptr: Int64, min: Int32, max: Int32): Unit
foreign func qProgressBarSetTextVisible(ptr: Int64, visible: Bool): Unit
foreign func qProgressBarSetFormat(ptr: Int64, format: CString): Unit
foreign func qProgressBarFormat(ptr: Int64): CString
foreign func qProgressBarSetOrientation(ptr: Int64, orientation: Int32): Unit
foreign func qProgressBarSetInvertedAppearance(ptr: Int64, invert: Bool): Unit
foreign func qProgressBarReset(ptr: Int64): Unit
foreign func qProgressBarDelete(ptr: Int64): Unit

public class QProgressBar {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qProgressBarCreate()
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
    
    public func setValue(value: Int32) {
        unsafe {
            qProgressBarSetValue(ptr, value)
        }
    }
    
    public func value(): Int32 {
        unsafe {
            qProgressBarValue(ptr)
        }
    }
    
    public func setRange(min: Int32, max: Int32) {
        unsafe {
            qProgressBarSetRange(ptr, min, max)
        }
    }
    
    public func setTextVisible(visible: Bool) {
        unsafe {
            qProgressBarSetTextVisible(ptr, visible)
        }
    }
    
    /// 设置显示格式（如 "%p%" 显示百分比）
    public func setFormat(format: String) {
        unsafe {
            let cstr = LibC.mallocCString(format)
            qProgressBarSetFormat(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取显示格式
    public func format(): String {
        unsafe {
            let cstr = qProgressBarFormat(ptr)
            return cstr.toString()
        }
    }
    
    /// 设置方向
    public func setOrientation(orientation: Int32) {
        unsafe {
            qProgressBarSetOrientation(ptr, orientation)
        }
    }
    
    /// 设置反向外观
    public func setInvertedAppearance(invert: Bool) {
        unsafe {
            qProgressBarSetInvertedAppearance(ptr, invert)
        }
    }
    
    /// 重置进度条
    public func reset() {
        unsafe {
            qProgressBarReset(ptr)
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
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qProgressBarDelete(ptr)
            }
            ptr = 0
        }
    }
}