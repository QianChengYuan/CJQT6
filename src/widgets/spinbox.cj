package cjqt6.widgets

import cjqt6.core.*

// QSpinBox - 整数旋转框
foreign func qSpinBoxCreate(): Int64
foreign func qSpinBoxSetValue(ptr: Int64, value: Int32): Unit
foreign func qSpinBoxValue(ptr: Int64): Int32
foreign func qSpinBoxSetRange(ptr: Int64, min: Int32, max: Int32): Unit
foreign func qSpinBoxSetSingleStep(ptr: Int64, step: Int32): Unit
foreign func qSpinBoxConnectValueChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qSpinBoxDisconnectValueChanged(ptr: Int64): Unit
foreign func qSpinBoxSetPrefix(ptr: Int64, prefix: CString): Unit
foreign func qSpinBoxPrefix(ptr: Int64): CString
foreign func qSpinBoxSetSuffix(ptr: Int64, suffix: CString): Unit
foreign func qSpinBoxSuffix(ptr: Int64): CString
foreign func qSpinBoxSetWrapping(ptr: Int64, wrapping: Bool): Unit
foreign func qSpinBoxWrapping(ptr: Int64): Bool
foreign func qSpinBoxSetSpecialValueText(ptr: Int64, text: CString): Unit
foreign func qSpinBoxCleanText(ptr: Int64): CString
foreign func qSpinBoxSetButtonSymbols(ptr: Int64, symbols: Int32): Unit
foreign func qSpinBoxButtonSymbols(ptr: Int64): Int32
foreign func qSpinBoxSetCorrectionMode(ptr: Int64, mode: Int32): Unit
foreign func qSpinBoxSetMinimum(ptr: Int64, value: Int32): Unit
foreign func qSpinBoxMinimum(ptr: Int64): Int32
foreign func qSpinBoxSetMaximum(ptr: Int64, value: Int32): Unit
foreign func qSpinBoxMaximum(ptr: Int64): Int32
foreign func qSpinBoxSetDisplayIntegerBase(ptr: Int64, base: Int32): Unit
foreign func qSpinBoxDisplayIntegerBase(ptr: Int64): Int32
foreign func qSpinBoxSetGroupSeparatorShown(ptr: Int64, shown: Int32): Unit
foreign func qSpinBoxText(ptr: Int64): CString
foreign func qSpinBoxConnectTextChanged(ptr: Int64, callback: CStringCallback): Unit
foreign func qSpinBoxConnectEditingFinished(ptr: Int64, callback: VoidCallback): Unit
foreign func qSpinBoxDelete(ptr: Int64): Unit

/// 整数旋转框部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QSpinBox <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    /// 创建旋转框
    public init() {
        unsafe {
            ptr = qSpinBoxCreate()
            if (ptr == 0) {
                throw CreateFailedException("QSpinBox 创建失败")
            }
        }
    }
    
    /// 显示
    public func show(): Unit {
        checkValid()
        unsafe {
            qWidgetShow(ptr)
        }
    }
    
    /// 隐藏
    public func hide(): Unit {
        checkValid()
        unsafe {
            qWidgetHide(ptr)
        }
    }
    
    /// 设置值
    public func setValue(value: Int32): Unit {
        checkValid()
        unsafe {
            qSpinBoxSetValue(ptr, value)
        }
    }
    
    /// 获取值
    public func value(): Int32 {
        checkValid()
        unsafe {
            return qSpinBoxValue(ptr)
        }
    }
    
    /// 设置范围
    public func setRange(min: Int32, max: Int32): Unit {
        checkValid()
        unsafe {
            qSpinBoxSetRange(ptr, min, max)
        }
    }
    
    /// 设置步长
    public func setSingleStep(step: Int32): Unit {
        checkValid()
        unsafe {
            qSpinBoxSetSingleStep(ptr, step)
        }
    }
    
    /// 设置前缀
    public func setPrefix(prefix: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(prefix)
            qSpinBoxSetPrefix(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取前缀
    public func prefix(): String {
        checkValid()
        unsafe {
            let cstr = qSpinBoxPrefix(ptr)
            return cstr.toString()
        }
    }
    
    /// 设置后缀
    public func setSuffix(suffix: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(suffix)
            qSpinBoxSetSuffix(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取后缀
    public func suffix(): String {
        checkValid()
        unsafe {
            let cstr = qSpinBoxSuffix(ptr)
            return cstr.toString()
        }
    }
    
    /// 设置循环
    public func setWrapping(wrapping: Bool): Unit {
        checkValid()
        unsafe {
            qSpinBoxSetWrapping(ptr, wrapping)
        }
    }
    
    /// 是否循环
    public func wrapping(): Bool {
        checkValid()
        unsafe {
            return qSpinBoxWrapping(ptr)
        }
    }
    
    /// 设置特殊值文本（当值为最小值时显示）
    public func setSpecialValueText(text: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            qSpinBoxSetSpecialValueText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取纯净文本（无前缀后缀）
    public func cleanText(): String {
        checkValid()
        unsafe {
            let cstr = qSpinBoxCleanText(ptr)
            return cstr.toString()
        }
    }
    
    /// 设置按钮符号（上下箭头 / 加减 / 无）
    public func setButtonSymbols(symbols: Int32): Unit {
        checkValid()
        unsafe {
            qSpinBoxSetButtonSymbols(ptr, symbols)
        }
    }
    
    /// 获取按钮符号
    public func buttonSymbols(): Int32 {
        checkValid()
        unsafe {
            return qSpinBoxButtonSymbols(ptr)
        }
    }
    
    /// 设置纠正模式
    public func setCorrectionMode(mode: Int32): Unit {
        checkValid()
        unsafe {
            qSpinBoxSetCorrectionMode(ptr, mode)
        }
    }
    
    /// 设置最小值
    public func setMinimum(value: Int32): Unit {
        checkValid()
        unsafe {
            qSpinBoxSetMinimum(ptr, value)
        }
    }
    
    /// 获取最小值
    public func minimum(): Int32 {
        checkValid()
        unsafe {
            return qSpinBoxMinimum(ptr)
        }
    }
    
    /// 设置最大值
    public func setMaximum(value: Int32): Unit {
        checkValid()
        unsafe {
            qSpinBoxSetMaximum(ptr, value)
        }
    }
    
    /// 获取最大值
    public func maximum(): Int32 {
        checkValid()
        unsafe {
            return qSpinBoxMaximum(ptr)
        }
    }
    
    /// 设置显示整数进制（如 16 显示十六进制）
    public func setDisplayIntegerBase(base: Int32): Unit {
        checkValid()
        unsafe {
            qSpinBoxSetDisplayIntegerBase(ptr, base)
        }
    }
    
    /// 获取显示整数进制
    public func displayIntegerBase(): Int32 {
        checkValid()
        unsafe {
            return qSpinBoxDisplayIntegerBase(ptr)
        }
    }
    
    /// 设置是否显示千位分隔符
    public func setGroupSeparatorShown(shown: Bool): Unit {
        checkValid()
        unsafe {
            qSpinBoxSetGroupSeparatorShown(ptr, if (shown) { 1 } else { 0 })
        }
    }
    
    /// 获取编辑器中的完整文本
    public func text(): String {
        checkValid()
        unsafe {
            let cstr = qSpinBoxText(ptr)
            return cstr.toString()
        }
    }
    
    /// 文本变化回调（含前缀后缀的完整文本）
    public func setOnTextChanged(callback: CStringCallback): Unit {
        checkValid()
        unsafe {
            qSpinBoxConnectTextChanged(ptr, callback)
        }
    }
    
    /// 编辑结束回调（回车或失焦）
    public func setOnEditingFinished(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qSpinBoxConnectEditingFinished(ptr, callback)
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
    
    /// 设置值变化回调
    public func setOnValueChanged(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qSpinBoxConnectValueChanged(ptr, callback)
        }
    }
    
    /// 断开值变化信号
    public func disconnectValueChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qSpinBoxDisconnectValueChanged(ptr)
            }
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
            throw ResourceDisposedException("QSpinBox 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QSpinBox 指针为空")
        }
    }
    
    /// 关闭资源，释放Qt对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qSpinBoxDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除旋转框（兼容旧API）
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
    //             qSpinBoxDelete(ptr)
    //         }
    //         closed = true
    //         ptr = 0
    //     }
    // }
}

/// 旋转框按钮符号常量（对应 QAbstractSpinBox::ButtonSymbols）
public class SpinBoxButtonSymbols {
    public static let UpDownArrows: Int32 = 0
    public static let PlusMinus: Int32 = 1
    public static let NoButtons: Int32 = 2
}

/// 旋转框纠正模式常量（对应 QAbstractSpinBox::CorrectionMode）
public class SpinBoxCorrectionMode {
    public static let CorrectToPreviousValue: Int32 = 0
    public static let CorrectToNearestValue: Int32 = 1
}