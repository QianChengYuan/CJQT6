package cjqt6.widgets

import cjqt6.core.*

// 验证器 FFI 声明
foreign func qIntValidatorCreate(min: Int32, max: Int32): Int64
foreign func qIntValidatorSetRange(ptr: Int64, min: Int32, max: Int32): Unit
foreign func qDoubleValidatorCreate(min: Float64, max: Float64, decimals: Int32): Int64
foreign func qDoubleValidatorSetRange(ptr: Int64, min: Float64, max: Float64, decimals: Int32): Unit
foreign func qIntValidatorBottom(ptr: Int64): Int32
foreign func qIntValidatorSetBottom(ptr: Int64, value: Int32): Unit
foreign func qIntValidatorTop(ptr: Int64): Int32
foreign func qIntValidatorSetTop(ptr: Int64, value: Int32): Unit
foreign func qDoubleValidatorBottom(ptr: Int64): Float64
foreign func qDoubleValidatorSetBottom(ptr: Int64, value: Float64): Unit
foreign func qDoubleValidatorTop(ptr: Int64): Float64
foreign func qDoubleValidatorSetTop(ptr: Int64, value: Float64): Unit
foreign func qDoubleValidatorDecimals(ptr: Int64): Int32
foreign func qDoubleValidatorSetDecimals(ptr: Int64, value: Int32): Unit
foreign func qDoubleValidatorNotation(ptr: Int64): Int32
foreign func qDoubleValidatorSetNotation(ptr: Int64, value: Int32): Unit
foreign func qRegExpValidatorCreate(pattern: CString): Int64
foreign func qRegExpValidatorSetPattern(ptr: Int64, pattern: CString): Unit
foreign func qLineEditSetValidator(lineEditPtr: Int64, validatorPtr: Int64): Unit
foreign func qValidatorDelete(ptr: Int64): Unit

/// 整数输入验证器
public class QIntValidator {
    private var ptr: Int64 = 0
    
    public init(min: Int32, max: Int32) {
        unsafe {
            ptr = qIntValidatorCreate(min, max)
        }
    }
    
    public init() {
        this(Int32(-2147483648), Int32(2147483647))
    }
    
    /// 设置验证范围
    public func setRange(min: Int32, max: Int32) {
        unsafe { qIntValidatorSetRange(ptr, min, max) }
    }

    /// 获取下限
    public func bottom(): Int32 {
        unsafe { return qIntValidatorBottom(ptr) }
    }

    /// 设置下限
    public func setBottom(value: Int32) {
        unsafe { qIntValidatorSetBottom(ptr, value) }
    }

    /// 获取上限
    public func top(): Int32 {
        unsafe { return qIntValidatorTop(ptr) }
    }

    /// 设置上限
    public func setTop(value: Int32) {
        unsafe { qIntValidatorSetTop(ptr, value) }
    }

    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }

    /// 删除验证器
    public func delete() {
        if (ptr != 0) {
            unsafe { qValidatorDelete(ptr) }
            ptr = 0
        }
    }
}

/// 浮点数输入验证器
public class QDoubleValidator {
    private var ptr: Int64 = 0
    
    public init(min: Float64, max: Float64, decimals: Int32) {
        unsafe {
            ptr = qDoubleValidatorCreate(min, max, decimals)
        }
    }
    
    /// 设置验证范围
    public func setRange(min: Float64, max: Float64, decimals: Int32) {
        unsafe { qDoubleValidatorSetRange(ptr, min, max, decimals) }
    }

    /// 获取下限
    public func bottom(): Float64 {
        unsafe { return qDoubleValidatorBottom(ptr) }
    }

    /// 设置下限
    public func setBottom(value: Float64) {
        unsafe { qDoubleValidatorSetBottom(ptr, value) }
    }

    /// 获取上限
    public func top(): Float64 {
        unsafe { return qDoubleValidatorTop(ptr) }
    }

    /// 设置上限
    public func setTop(value: Float64) {
        unsafe { qDoubleValidatorSetTop(ptr, value) }
    }

    /// 获取小数位数
    public func decimals(): Int32 {
        unsafe { return qDoubleValidatorDecimals(ptr) }
    }

    /// 设置小数位数
    public func setDecimals(value: Int32) {
        unsafe { qDoubleValidatorSetDecimals(ptr, value) }
    }

    /// 获取记数法（DoubleValidatorNotation 枚举值）
    public func notation(): Int32 {
        unsafe { return qDoubleValidatorNotation(ptr) }
    }

    /// 设置记数法
    public func setNotation(value: Int32) {
        unsafe { qDoubleValidatorSetNotation(ptr, value) }
    }

    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }

    /// 删除验证器
    public func delete() {
        if (ptr != 0) {
            unsafe { qValidatorDelete(ptr) }
            ptr = 0
        }
    }
}

/// 正则表达式验证器（Qt6 使用 QRegularExpression）
public class QRegExpValidator {
    private var ptr: Int64 = 0

    public init(pattern: String) {
        unsafe {
            let cstr = LibC.mallocCString(pattern)
            ptr = qRegExpValidatorCreate(cstr)
            LibC.free(cstr)
        }
    }

    /// 重新设置正则表达式
    public func setPattern(pattern: String) {
        unsafe {
            let cstr = LibC.mallocCString(pattern)
            qRegExpValidatorSetPattern(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }

    /// 删除验证器
    public func delete() {
        if (ptr != 0) {
            unsafe { qValidatorDelete(ptr) }
            ptr = 0
        }
    }
}

/// QLineEdit 扩展：设置验证器（在 QLineEdit 类外部提供）
public func setLineEditValidator(lineEdit: QLineEdit, validator: QIntValidator) {
    unsafe {
        qLineEditSetValidator(lineEdit.getPtr(), validator.getPtr())
    }
}

public func setLineEditValidator(lineEdit: QLineEdit, validator: QDoubleValidator) {
    unsafe {
        qLineEditSetValidator(lineEdit.getPtr(), validator.getPtr())
    }
}

public func setLineEditValidator(lineEdit: QLineEdit, validator: QRegExpValidator) {
    unsafe {
        qLineEditSetValidator(lineEdit.getPtr(), validator.getPtr())
    }
}
