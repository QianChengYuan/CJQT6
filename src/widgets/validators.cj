package cjqt6.widgets

import cjqt6.core.*

// 验证器 FFI 声明
foreign func qIntValidatorCreate(min: Int32, max: Int32): Int64
foreign func qIntValidatorSetRange(ptr: Int64, min: Int32, max: Int32): Unit
foreign func qDoubleValidatorCreate(min: Float64, max: Float64, decimals: Int32): Int64
foreign func qDoubleValidatorSetRange(ptr: Int64, min: Float64, max: Float64, decimals: Int32): Unit
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
