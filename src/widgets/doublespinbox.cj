package cjqt6.widgets

import cjqt6.core.*

// QDoubleSpinBox - 双精度旋转框
foreign func qDoubleSpinBoxCreate(): Int64
foreign func qDoubleSpinBoxSetValue(ptr: Int64, value: Float64): Unit
foreign func qDoubleSpinBoxValue(ptr: Int64): Float64
foreign func qDoubleSpinBoxSetRange(ptr: Int64, min: Float64, max: Float64): Unit
foreign func qDoubleSpinBoxSetSingleStep(ptr: Int64, step: Float64): Unit
foreign func qDoubleSpinBoxSetDecimals(ptr: Int64, decimals: Int32): Unit
foreign func qDoubleSpinBoxDecimals(ptr: Int64): Int32
foreign func qDoubleSpinBoxDelete(ptr: Int64): Unit
foreign func qDoubleSpinBoxConnectValueChanged(ptr: Int64, callback: Float64Callback): Unit
foreign func qDoubleSpinBoxDisconnectValueChanged(ptr: Int64): Unit
foreign func qDoubleSpinBoxSetPrefix(ptr: Int64, prefix: CString): Unit
foreign func qDoubleSpinBoxPrefix(ptr: Int64): CString
foreign func qDoubleSpinBoxSetSuffix(ptr: Int64, suffix: CString): Unit
foreign func qDoubleSpinBoxSuffix(ptr: Int64): CString
foreign func qDoubleSpinBoxSetSpecialValueText(ptr: Int64, text: CString): Unit
foreign func qDoubleSpinBoxSetStepType(ptr: Int64, stepType: Int32): Unit
foreign func qDoubleSpinBoxSetMinimum(ptr: Int64, value: Float64): Unit
foreign func qDoubleSpinBoxMinimum(ptr: Int64): Float64
foreign func qDoubleSpinBoxSetMaximum(ptr: Int64, value: Float64): Unit
foreign func qDoubleSpinBoxMaximum(ptr: Int64): Float64
foreign func qDoubleSpinBoxSetGroupSeparatorShown(ptr: Int64, shown: Int32): Unit
foreign func qDoubleSpinBoxCleanText(ptr: Int64): CString
foreign func qDoubleSpinBoxText(ptr: Int64): CString
foreign func qDoubleSpinBoxConnectTextChanged(ptr: Int64, callback: CStringCallback): Unit
foreign func qDoubleSpinBoxConnectEditingFinished(ptr: Int64, callback: VoidCallback): Unit

/// 双精度旋转框部件
public class QDoubleSpinBox {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qDoubleSpinBoxCreate()
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
    
    public func setValue(value: Float64) {
        unsafe {
            qDoubleSpinBoxSetValue(ptr, value)
        }
    }
    
    public func value(): Float64 {
        unsafe {
            return qDoubleSpinBoxValue(ptr)
        }
    }
    
    public func setRange(min: Float64, max: Float64) {
        unsafe {
            qDoubleSpinBoxSetRange(ptr, min, max)
        }
    }
    
    public func setSingleStep(step: Float64) {
        unsafe {
            qDoubleSpinBoxSetSingleStep(ptr, step)
        }
    }
    
    public func setDecimals(decimals: Int32) {
        unsafe {
            qDoubleSpinBoxSetDecimals(ptr, decimals)
        }
    }
    
    public func decimals(): Int32 {
        unsafe {
            return qDoubleSpinBoxDecimals(ptr)
        }
    }
    
    /// 设置启用/禁用
    public func setEnabled(enabled: Bool) {
        unsafe {
            qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }

    /// 设置前缀
    public func setPrefix(prefix: String) {
        unsafe {
            let cstr = LibC.mallocCString(prefix)
            qDoubleSpinBoxSetPrefix(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取前缀
    public func prefix(): String {
        unsafe {
            let cstr = qDoubleSpinBoxPrefix(ptr)
            return cstr.toString()
        }
    }

    /// 设置后缀
    public func setSuffix(suffix: String) {
        unsafe {
            let cstr = LibC.mallocCString(suffix)
            qDoubleSpinBoxSetSuffix(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取后缀
    public func suffix(): String {
        unsafe {
            let cstr = qDoubleSpinBoxSuffix(ptr)
            return cstr.toString()
        }
    }

    /// 设置特殊值文本（当值为最小值时显示）
    public func setSpecialValueText(text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qDoubleSpinBoxSetSpecialValueText(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置步长类型
    public func setStepType(stepType: Int32) {
        unsafe {
            qDoubleSpinBoxSetStepType(ptr, stepType)
        }
    }

    /// 设置最小值
    public func setMinimum(value: Float64) {
        unsafe {
            qDoubleSpinBoxSetMinimum(ptr, value)
        }
    }

    /// 获取最小值
    public func minimum(): Float64 {
        unsafe {
            return qDoubleSpinBoxMinimum(ptr)
        }
    }

    /// 设置最大值
    public func setMaximum(value: Float64) {
        unsafe {
            qDoubleSpinBoxSetMaximum(ptr, value)
        }
    }

    /// 获取最大值
    public func maximum(): Float64 {
        unsafe {
            return qDoubleSpinBoxMaximum(ptr)
        }
    }

    /// 设置是否显示千位分隔符
    public func setGroupSeparatorShown(shown: Bool) {
        unsafe {
            qDoubleSpinBoxSetGroupSeparatorShown(ptr, if (shown) { 1 } else { 0 })
        }
    }

    /// 获取纯净文本（无前缀后缀）
    public func cleanText(): String {
        unsafe {
            let cstr = qDoubleSpinBoxCleanText(ptr)
            return cstr.toString()
        }
    }

    /// 获取编辑器中的完整文本
    public func text(): String {
        unsafe {
            let cstr = qDoubleSpinBoxText(ptr)
            return cstr.toString()
        }
    }

    /// 文本变化回调（含前缀后缀的完整文本）
    public func setOnTextChanged(callback: CStringCallback) {
        unsafe {
            qDoubleSpinBoxConnectTextChanged(ptr, callback)
        }
    }

    /// 编辑结束回调（回车或失焦）
    public func setOnEditingFinished(callback: VoidCallback) {
        unsafe {
            qDoubleSpinBoxConnectEditingFinished(ptr, callback)
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
    
    /// 设置值变化回调
    public func setOnValueChanged(callback: Float64Callback) {
        unsafe {
            qDoubleSpinBoxConnectValueChanged(ptr, callback)
        }
    }
    
    /// 断开值变化信号
    public func disconnectValueChanged() {
        unsafe {
            qDoubleSpinBoxDisconnectValueChanged(ptr)
        }
    }
    
    /// 断开该双精度数值框的全部信号（valueChanged）
    public func disconnect(): Unit {
        disconnectValueChanged()
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除旋转框
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qDoubleSpinBoxDelete(ptr)
            }
            ptr = 0
        }
    }
}

/// 双精度旋转框步长类型常量（对应 QAbstractSpinBox::StepType）
public class DoubleSpinBoxStepType {
    public static let DefaultStepType: Int32 = 0
    public static let AdaptiveDecimalStepType: Int32 = 1
}
