package CJQT6.core

// QTimer - 定时器
foreign func qTimerCreate(): Int64
foreign func qTimerSetInterval(ptr: Int64, interval: Int32): Unit
foreign func qTimerStart(ptr: Int64): Unit
foreign func qTimerStop(ptr: Int64): Unit
foreign func qTimerSetTimeout(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit
foreign func qTimerDelete(ptr: Int64): Unit

// 全局回调存储
private var timerCallbacks: Array<CFunc<(Int64) -> Unit>> = []

public class QTimer {
    private var ptr: Int64 = 0
    private var callbackId: Int64 = -1
    
    public init() {
        unsafe {
            ptr = qTimerCreate()
        }
    }
    
    public func setInterval(interval: Int32) {
        unsafe {
            qTimerSetInterval(ptr, interval)
        }
    }
    
    public func start() {
        unsafe {
            qTimerStart(ptr)
        }
    }
    
    public func stop() {
        unsafe {
            qTimerStop(ptr)
        }
    }
    
    public func setTimeout(callback: CFunc<(Int64) -> Unit>) {
        unsafe {
            qTimerSetTimeout(ptr, callback)
        }
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qTimerDelete(ptr)
            }
            ptr = 0
        }
    }
}
