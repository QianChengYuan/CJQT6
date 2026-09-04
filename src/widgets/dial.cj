package cjqt6.widgets

import cjqt6.core.*

// QDial - 旋钮控件
foreign func qDialCreate(): Int64
foreign func qDialSetValue(ptr: Int64, value: Int32): Unit
foreign func qDialValue(ptr: Int64): Int32
foreign func qDialSetRange(ptr: Int64, min: Int32, max: Int32): Unit
foreign func qDialSetSingleStep(ptr: Int64, step: Int32): Unit
foreign func qDialSetWrapping(ptr: Int64, wrapping: Bool): Unit
foreign func qDialWrapping(ptr: Int64): Bool
foreign func qDialSetNotchesVisible(ptr: Int64, visible: Bool): Unit
foreign func qDialNotchesVisible(ptr: Int64): Bool
foreign func qDialDelete(ptr: Int64): Unit
foreign func qDialConnectValueChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qDialDisconnectValueChanged(ptr: Int64): Unit
foreign func qDialSetNotchTarget(ptr: Int64, target: Float64): Unit
foreign func qDialNotchTarget(ptr: Int64): Float64
foreign func qDialSetPageStep(ptr: Int64, step: Int32): Unit
foreign func qDialPageStep(ptr: Int64): Int32

/// 旋钮控件部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QDial <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init() {
        unsafe {
            ptr = qDialCreate()
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
    
    public func setValue(value: Int32): Unit {
        checkValid()
        unsafe {
            qDialSetValue(ptr, value)
        }
    }
    
    public func value(): Int32 {
        checkValid()
        unsafe {
            return qDialValue(ptr)
        }
    }
    
    public func setRange(min: Int32, max: Int32): Unit {
        checkValid()
        unsafe {
            qDialSetRange(ptr, min, max)
        }
    }
    
    public func setSingleStep(step: Int32): Unit {
        checkValid()
        unsafe {
            qDialSetSingleStep(ptr, step)
        }
    }
    
    /// 设置是否循环
    public func setWrapping(wrapping: Bool): Unit {
        checkValid()
        unsafe {
            qDialSetWrapping(ptr, wrapping)
        }
    }
    
    /// 获取是否循环
    public func wrapping(): Bool {
        checkValid()
        unsafe {
            return qDialWrapping(ptr)
        }
    }
    
    /// 设置刻度是否可见
    public func setNotchesVisible(visible: Bool): Unit {
        checkValid()
        unsafe {
            qDialSetNotchesVisible(ptr, visible)
        }
    }
    
    /// 获取刻度是否可见
    public func notchesVisible(): Bool {
        checkValid()
        unsafe {
            return qDialNotchesVisible(ptr)
        }
    }
    
    /// 设置启用/禁用
    public func setEnabled(enabled: Bool): Unit {
        checkValid()
        unsafe {
            qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }

    /// 设置刻度目标像素间距
    public func setNotchTarget(target: Float64): Unit {
        checkValid()
        unsafe {
            qDialSetNotchTarget(ptr, target)
        }
    }

    /// 获取刻度目标像素间距
    public func notchTarget(): Float64 {
        checkValid()
        unsafe {
            return qDialNotchTarget(ptr)
        }
    }

    /// 设置翻页步长
    public func setPageStep(step: Int32): Unit {
        checkValid()
        unsafe {
            qDialSetPageStep(ptr, step)
        }
    }

    /// 获取翻页步长
    public func pageStep(): Int32 {
        checkValid()
        unsafe {
            return qDialPageStep(ptr)
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
    
    /// 设置值变化回调
    public func setOnValueChanged(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qDialConnectValueChanged(ptr, callback)
        }
    }
    
    /// 断开值变化信号
    public func disconnectValueChanged(): Unit {
        checkValid()
        unsafe {
            qDialDisconnectValueChanged(ptr)
        }
    }
    
    /// 断开该拨盘的全部信号（valueChanged）
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
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QDial 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QDial 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QDial 底层 Qt 对象已失效")
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
                qDialDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除旋钮（兼容旧API）
    public func delete(): Unit {
        close()
    }
}
