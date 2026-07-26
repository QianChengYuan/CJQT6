package cjqt6.core

// QTimer - 定时器
foreign func qTimerCreate(): Int64
foreign func qTimerSetInterval(ptr: Int64, interval: Int32): Unit
foreign func qTimerStart(ptr: Int64): Unit
foreign func qTimerStop(ptr: Int64): Unit
foreign func qTimerDelete(ptr: Int64): Unit

/// 定时器
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QTimer <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    /// 创建定时器
    public init() {
        unsafe {
            ptr = qTimerCreate()
            if (ptr == 0) {
                throw CreateFailedException("QTimer 创建失败")
            }
        }
    }
    
    /// 设置间隔时间（毫秒）
    public func setInterval(interval: Int32): Unit {
        checkValid()
        unsafe {
            qTimerSetInterval(ptr, interval)
        }
    }
    
    /// 启动定时器
    public func start(): Unit {
        checkValid()
        unsafe {
            qTimerStart(ptr)
        }
    }
    
    /// 停止定时器
    public func stop(): Unit {
        checkValid()
        unsafe {
            qTimerStop(ptr)
        }
    }
    
    /// 设置超时回调，返回 SignalConnection 句柄（可 disconnect）
    public func setOnTimeout(callback: VoidCallback): SignalConnection {
        checkValid()
        unsafe {
            qTimerConnectTimeout(ptr, callback)
        }
        return SignalConnection.createWithWidgetType(ptr, SIGNAL_TIMEOUT, WIDGET_TYPE_TIMER)
    }

    /// 设置超时回调（可捕获局部变量；P1c 闭包捕获），返回 SignalConnection 句柄
    public func setOnTimeoutCapture(callback: () -> Unit): SignalConnection {
        checkValid()
        let id = registerVoidCallback(callback)
        unsafe {
            qTimerConnectTimeoutId(ptr, id)
        }
        return SignalConnection.createCapturing(ptr, SIGNAL_TIMEOUT, WIDGET_TYPE_TIMER, id)
    }
    
    /// 断开超时信号
    public func disconnectTimeout(): Unit {
        if (ptr != 0) {
            unsafe {
                qTimerDisconnectTimeout(ptr)
            }
        }
    }
    
    /// 断开该定时器的全部信号（timeout）
    public func disconnect(): Unit {
        disconnectTimeout()
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
            throw ResourceDisposedException("QTimer 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QTimer 指针为空")
        }
    }
    
    /// 关闭资源，释放Qt对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qTimerDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除定时器（兼容旧API）
    public func delete(): Unit {
        close()
    }
    
    /// 终结器 - 已禁用
    /// 注意：仓颉运行时可能会在不正确的时机调用终结器（例如对象仍被全局变量引用时）。
    /// 这会导致 Qt 对象被提前删除，引发崩溃。
    /// 解决方案：请显式调用 delete() 或 close() 方法释放资源。
    // ~init() {
    //     if (!closed && ptr != 0) {
    //         unsafe {
    //             qSignalCleanup(ptr)
    //             qTimerDelete(ptr)
    //         }
    //         closed = true
    //         ptr = 0
    //     }
    // }
}
