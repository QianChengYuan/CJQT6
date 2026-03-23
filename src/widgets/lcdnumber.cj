package CJQT6.widgets

import CJQT6.core.*

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
public class QLCDNumber {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qLCDNumberCreate()
        }
    }
    
    public init(numDigits: Int32) {
        unsafe {
            ptr = qLCDNumberCreateWithDigits(numDigits)
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
    
    /// 显示浮点数值
    public func display(value: Float64) {
        unsafe {
            qLCDNumberDisplay(ptr, value)
        }
    }
    
    /// 显示整数值
    public func displayInt(value: Int32) {
        unsafe {
            qLCDNumberDisplayInt(ptr, value)
        }
    }
    
    /// 设置显示模式
    public func setMode(mode: Int32) {
        unsafe {
            qLCDNumberSetMode(ptr, mode)
        }
    }
    
    /// 获取显示模式
    public func mode(): Int32 {
        unsafe {
            return qLCDNumberMode(ptr)
        }
    }
    
    /// 设置段样式
    public func setSegmentStyle(style: Int32) {
        unsafe {
            qLCDNumberSetSegmentStyle(ptr, style)
        }
    }
    
    /// 获取段样式
    public func segmentStyle(): Int32 {
        unsafe {
            return qLCDNumberSegmentStyle(ptr)
        }
    }
    
    /// 设置小数点样式
    public func setSmallDecimalPoint(small: Bool) {
        unsafe {
            qLCDNumberSetSmallDecimalPoint(ptr, small)
        }
    }
    
    /// 获取小数点样式
    public func smallDecimalPoint(): Bool {
        unsafe {
            return qLCDNumberSmallDecimalPoint(ptr)
        }
    }
    
    /// 获取数字位数
    public func digitCount(): Int32 {
        unsafe {
            return qLCDNumberDigitCount(ptr)
        }
    }
    
    /// 设置数字位数
    public func setDigitCount(numDigits: Int32) {
        unsafe {
            qLCDNumberSetDigitCount(ptr, numDigits)
        }
    }
    
    /// 检查是否溢出
    public func checkOverflow(value: Float64): Bool {
        unsafe {
            return qLCDNumberCheckOverflow(ptr, value)
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除LCD
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qLCDNumberDelete(ptr)
            }
            ptr = 0
        }
    }
}
