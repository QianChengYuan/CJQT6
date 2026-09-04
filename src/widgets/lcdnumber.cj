package cjqt6.widgets

import cjqt6.core.*

// QLCDNumber - LCD数字显示
foreign func qLCDNumberCreate(): Int64
foreign func qLCDNumberCreateWithDigits(numDigits: Int32): Int64
foreign func qLCDNumberDisplay(ptr: Int64, value: Float64): Unit
foreign func qLCDNumberDisplayInt(ptr: Int64, value: Int32): Unit
foreign func qLCDNumberSetMode(ptr: Int64, mode: Int32): Unit
foreign func qLCDNumberMode(ptr: Int64): Int32
foreign func qLCDNumberSetSegmentStyle(ptr: Int64, style: Int32): Unit
foreign func qLCDNumberSegmentStyle(ptr: Int64): Int32
foreign func qLCDNumberSetSmallDecimalPoint(ptr: Int64, small: Bool): Unit
foreign func qLCDNumberSmallDecimalPoint(ptr: Int64): Bool
foreign func qLCDNumberDigitCount(ptr: Int64): Int32
foreign func qLCDNumberSetDigitCount(ptr: Int64, numDigits: Int32): Unit
foreign func qLCDNumberCheckOverflow(ptr: Int64, value: Float64): Bool
foreign func qLCDNumberValue(ptr: Int64): Float64
foreign func qLCDNumberDisplayString(ptr: Int64, value: CString): Unit
foreign func qLCDNumberDelete(ptr: Int64): Unit

// LCD显示模式常量
public class LCDMode {
    public static func hex(): Int32 { 0 }    // 十六进制
    public static func dec(): Int32 { 1 }    // 十进制
    public static func oct(): Int32 { 2 }    // 八进制
    public static func bin(): Int32 { 3 }    // 二进制
}

// LCD段样式常量
public class LCDSegmentStyle {
    public static func outline(): Int32 { 0 }  // 轮廓
    public static func filled(): Int32 { 1 }   // 填充
    public static func flat(): Int32 { 2 }     // 平面
}

/// LCD数字显示部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QLCDNumber <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init() {
        unsafe {
            ptr = qLCDNumberCreate()
        }
        trackObject(ptr)
    }
    
    public init(numDigits: Int32) {
        unsafe {
            ptr = qLCDNumberCreateWithDigits(numDigits)
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
    
    /// 显示浮点数值
    public func display(value: Float64): Unit {
        checkValid()
        unsafe {
            qLCDNumberDisplay(ptr, value)
        }
    }
    
    /// 显示整数值
    public func displayInt(value: Int32): Unit {
        checkValid()
        unsafe {
            qLCDNumberDisplayInt(ptr, value)
        }
    }
    
    /// 设置显示模式
    public func setMode(mode: Int32): Unit {
        checkValid()
        unsafe {
            qLCDNumberSetMode(ptr, mode)
        }
    }
    
    /// 获取显示模式
    public func mode(): Int32 {
        checkValid()
        unsafe {
            return qLCDNumberMode(ptr)
        }
    }
    
    /// 设置段样式
    public func setSegmentStyle(style: Int32): Unit {
        checkValid()
        unsafe {
            qLCDNumberSetSegmentStyle(ptr, style)
        }
    }
    
    /// 获取段样式
    public func segmentStyle(): Int32 {
        checkValid()
        unsafe {
            return qLCDNumberSegmentStyle(ptr)
        }
    }
    
    /// 设置小数点样式
    public func setSmallDecimalPoint(small: Bool): Unit {
        checkValid()
        unsafe {
            qLCDNumberSetSmallDecimalPoint(ptr, small)
        }
    }
    
    /// 获取小数点样式
    public func smallDecimalPoint(): Bool {
        checkValid()
        unsafe {
            return qLCDNumberSmallDecimalPoint(ptr)
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
    
    /// 获取数字位数
    public func digitCount(): Int32 {
        checkValid()
        unsafe {
            return qLCDNumberDigitCount(ptr)
        }
    }
    
    /// 设置数字位数
    public func setDigitCount(numDigits: Int32): Unit {
        checkValid()
        unsafe {
            qLCDNumberSetDigitCount(ptr, numDigits)
        }
    }
    
    /// 检查是否溢出
    public func checkOverflow(value: Float64): Bool {
        checkValid()
        unsafe {
            return qLCDNumberCheckOverflow(ptr, value)
        }
    }
    
    /// 获取当前显示的数值
    public func value(): Float64 {
        checkValid()
        unsafe {
            return qLCDNumberValue(ptr)
        }
    }
    
    /// 显示字符串
    public func display(value: String): Unit {
        checkValid()
        unsafe {
            withCString(value) { c => qLCDNumberDisplayString(ptr, c) }
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
    /// throws: NullPointerException 空指针访问时抛出
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QLCDNumber 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QLCDNumber 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QLCDNumber 底层 Qt 对象已失效")
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
                qLCDNumberDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除LCD（兼容旧API）
    public func delete(): Unit {
        close()
    }
}
