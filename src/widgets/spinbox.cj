package CJQT6.widgets

import CJQT6.core.*

// QSpinBox - 整数旋转框
foreign func qSpinBoxCreate(): Int64
foreign func qSpinBoxSetValue(ptr: Int64, value: Int32): Unit
foreign func qSpinBoxValue(ptr: Int64): Int32
foreign func qSpinBoxSetRange(ptr: Int64, min: Int32, max: Int32): Unit
foreign func qSpinBoxSetSingleStep(ptr: Int64, step: Int32): Unit
foreign func qSpinBoxConnectValueChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qSpinBoxDisconnectValueChanged(ptr: Int64): Unit
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