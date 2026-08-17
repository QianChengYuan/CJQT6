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
foreign func qDoubleSpinBoxSetWrapping(ptr: Int64, wrap: Int32): Unit
foreign func qDoubleSpinBoxWrapping(ptr: Int64): Int32
foreign func qDoubleSpinBoxSetButtonSymbols(ptr: Int64, symbols: Int32): Unit
foreign func qDoubleSpinBoxCleanText(ptr: Int64): CString
foreign func qDoubleSpinBoxText(ptr: Int64): CString
foreign func qDoubleSpinBoxConnectTextChanged(ptr: Int64, callback: CStringCallback): Unit
foreign func qDoubleSpinBoxConnectEditingFinished(ptr: Int64, callback: VoidCallback): Unit
foreign func qDoubleSpinBoxSelectAll(ptr: Int64): Unit
foreign func qDoubleSpinBoxSetFocus(ptr: Int64): Unit

/// 双精度旋转框部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QDoubleSpinBox <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init() {
        unsafe {
            ptr = qDoubleSpinBoxCreate()
            if (ptr == 0) {
                throw CreateFailedException("QDoubleSpinBox 创建失败")
            }
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
    
    public func setValue(value: Float64): Unit {
        checkValid()
        unsafe {
            qDoubleSpinBoxSetValue(ptr, value)
        }
    }
    
    public func value(): Float64 {
        checkValid()
        unsafe {
            return qDoubleSpinBoxValue(ptr)
        }
    }
    
    public func setRange(min: Float64, max: Float64): Unit {
        checkValid()
        unsafe {
            qDoubleSpinBoxSetRange(ptr, min, max)
        }
    }
    
    public func setSingleStep(step: Float64): Unit {
        checkValid()
        unsafe {
            qDoubleSpinBoxSetSingleStep(ptr, step)
        }
    }
    
    public func setDecimals(decimals: Int32): Unit {
        checkValid()
        unsafe {
            qDoubleSpinBoxSetDecimals(ptr, decimals)
        }
    }
    
    public func decimals(): Int32 {
        checkValid()
        unsafe {
            return qDoubleSpinBoxDecimals(ptr)
        }
    }
    
    /// 设置启用/禁用
    public func setEnabled(enabled: Bool): Unit {
        checkValid()
        unsafe {
            qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }

    /// 设置前缀
    public func setPrefix(prefix: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(prefix)
            qDoubleSpinBoxSetPrefix(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取前缀
    public func prefix(): String {
        checkValid()
        unsafe {
            let cstr = qDoubleSpinBoxPrefix(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 设置后缀
    public func setSuffix(suffix: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(suffix)
            qDoubleSpinBoxSetSuffix(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取后缀
    public func suffix(): String {
        checkValid()
        unsafe {
            let cstr = qDoubleSpinBoxSuffix(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 设置特殊值文本（当值为最小值时显示）
    public func setSpecialValueText(text: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            qDoubleSpinBoxSetSpecialValueText(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置步长类型
    public func setStepType(stepType: Int32): Unit {
        checkValid()
        unsafe {
            qDoubleSpinBoxSetStepType(ptr, stepType)
        }
    }

    /// 设置最小值
    public func setMinimum(value: Float64): Unit {
        checkValid()
        unsafe {
            qDoubleSpinBoxSetMinimum(ptr, value)
        }
    }

    /// 获取最小值
    public func minimum(): Float64 {
        checkValid()
        unsafe {
            return qDoubleSpinBoxMinimum(ptr)
        }
    }

    /// 设置最大值
    public func setMaximum(value: Float64): Unit {
        checkValid()
        unsafe {
            qDoubleSpinBoxSetMaximum(ptr, value)
        }
    }

    /// 获取最大值
    public func maximum(): Float64 {
        checkValid()
        unsafe {
            return qDoubleSpinBoxMaximum(ptr)
        }
    }

    /// 设置是否显示千位分隔符
    public func setGroupSeparatorShown(shown: Bool): Unit {
        checkValid()
        unsafe {
            qDoubleSpinBoxSetGroupSeparatorShown(ptr, if (shown) { 1 } else { 0 })
        }
    }

    /// 设置是否循环（值超过范围后回绕）
    public func setWrapping(wrap: Bool): Unit {
        checkValid()
        unsafe {
            qDoubleSpinBoxSetWrapping(ptr, if (wrap) { 1 } else { 0 })
        }
    }

    /// 是否循环
    public func wrapping(): Bool {
        checkValid()
        unsafe {
            return qDoubleSpinBoxWrapping(ptr) != 0
        }
    }

    /// 设置按钮符号（上下箭头 / 加减 / 无，对应 SpinBoxButtonSymbols）
    public func setButtonSymbols(symbols: Int32): Unit {
        checkValid()
        unsafe {
            qDoubleSpinBoxSetButtonSymbols(ptr, symbols)
        }
    }

    /// 获取纯净文本（无前缀后缀）
    public func cleanText(): String {
        checkValid()
        unsafe {
            let cstr = qDoubleSpinBoxCleanText(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 获取编辑器中的完整文本
    public func text(): String {
        checkValid()
        unsafe {
            let cstr = qDoubleSpinBoxText(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 文本变化回调（含前缀后缀的完整文本）
    public func setOnTextChanged(callback: CStringCallback): Unit {
        checkValid()
        unsafe {
            qDoubleSpinBoxConnectTextChanged(ptr, callback)
        }
    }

    /// 编辑结束回调（回车或失焦）
    public func setOnEditingFinished(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qDoubleSpinBoxConnectEditingFinished(ptr, callback)
        }
    }

    /// 全选文本
    public func selectAll(): Unit {
        checkValid()
        unsafe {
            qDoubleSpinBoxSelectAll(ptr)
        }
    }

    /// 设置焦点
    public func setFocus(): Unit {
        checkValid()
        unsafe {
            qDoubleSpinBoxSetFocus(ptr)
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
    public func setOnValueChanged(callback: Float64Callback): Unit {
        checkValid()
        unsafe {
            qDoubleSpinBoxConnectValueChanged(ptr, callback)
        }
    }
    
    /// 断开值变化信号
    public func disconnectValueChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qDoubleSpinBoxDisconnectValueChanged(ptr)
            }
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
            throw ResourceDisposedException("QDoubleSpinBox 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QDoubleSpinBox 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QDoubleSpinBox 底层 Qt 对象已失效")
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
                qDoubleSpinBoxDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除旋转框（兼容旧API）
    public func delete(): Unit {
        close()
    }
}

/// 双精度旋转框步长类型常量（对应 QAbstractSpinBox::StepType）
public class DoubleSpinBoxStepType {
    public static let DefaultStepType: Int32 = 0
    public static let AdaptiveDecimalStepType: Int32 = 1
}
