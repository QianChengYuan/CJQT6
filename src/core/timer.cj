package CJQT6.core

// QTimer - 定时器
foreign func qTimerCreate(): Int64
foreign func qTimerSetInterval(ptr: Int64, interval: Int32): Unit
foreign func qTimerStart(ptr: Int64): Unit
foreign func qTimerStop(ptr: Int64): Unit
foreign func qTimerDelete(ptr: Int64): Unit

/// 定时器
public class QTimer {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qTimerCreate()
        }
    }
    
    /// 设置间隔时间（毫秒）
    public func setInterval(interval: Int32) {
        unsafe {
            qTimerSetInterval(ptr, interval)
        }
    }
    
    /// 启动定时器
    public func start() {
        unsafe {
            qTimerStart(ptr)
        }
    }
    
    /// 停止定时器
    public func stop() {
        unsafe {
            qTimerStop(ptr)
        }
    }
    
    /// 设置超时回调
    /// 使用示例：
    /// ```
    /// timer.setOnTimeout(voidCallback({ => println("timeout!") }))
    /// ```
    public func setOnTimeout(callback: VoidCallback) {
        unsafe {
            qTimerConnectTimeout(ptr, callback)
        }
    }
    
    /// 断开超时信号
    public func disconnectTimeout() {
        unsafe {
            qTimerDisconnectTimeout(ptr)
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除定时器
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qTimerDelete(ptr)
            }
            ptr = 0
        }
    }
}