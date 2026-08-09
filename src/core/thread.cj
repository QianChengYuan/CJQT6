package cjqt6.core

// ============================================================
// QThread / QThreadPool / QRunnable FFI
// ============================================================

foreign func qThreadCreate(): Int64
foreign func qThreadDelete(ptr: Int64): Unit
foreign func qThreadStart(ptr: Int64): Unit
foreign func qThreadQuit(ptr: Int64): Unit
foreign func qThreadWait(ptr: Int64, timeoutMs: Int32): Bool
foreign func qThreadIsRunning(ptr: Int64): Bool
foreign func qThreadIsFinished(ptr: Int64): Bool
foreign func qThreadPriority(ptr: Int64): Int32
foreign func qThreadSetPriority(ptr: Int64, priority: Int32): Unit
foreign func qThreadSetStackSize(ptr: Int64, stackSize: Int64): Unit
foreign func qThreadStackSize(ptr: Int64): Int64
foreign func qThreadExit(ptr: Int64): Unit
foreign func qThreadIsInterruptionRequested(ptr: Int64): Bool
foreign func qThreadRequestInterruption(ptr: Int64): Unit
foreign func qThreadCurrentThread(): Int64
foreign func qThreadIdealThreadCount(): Int64
foreign func qThreadMsleep(ms: Int32): Unit
foreign func qThreadConnectStarted(ptr: Int64, callback: VoidCallback): Unit
foreign func qThreadConnectFinished(ptr: Int64, callback: VoidCallback): Unit
foreign func qThreadDisconnectCallbacks(ptr: Int64): Unit

foreign func qRunnableCreate(callback: VoidCallback): Int64
foreign func qRunnableDelete(ptr: Int64): Unit

foreign func qThreadPoolGlobalInstance(): Int64
foreign func qThreadPoolStart(ptr: Int64, runnablePtr: Int64): Unit
foreign func qThreadPoolWaitForDone(ptr: Int64, timeoutMs: Int32): Bool
foreign func qThreadPoolActiveThreadCount(ptr: Int64): Int32
foreign func qThreadPoolMaxThreadCount(ptr: Int64): Int32
foreign func qThreadPoolSetMaxThreadCount(ptr: Int64, count: Int32): Unit
foreign func qThreadPoolExpiryTimeout(ptr: Int64): Int32
foreign func qThreadPoolSetExpiryTimeout(ptr: Int64, timeout: Int32): Unit


// ============================================================
// 线程优先级常量
// ============================================================
public class ThreadPriority {
    public static func idle(): Int32 { 0 }
    public static func lowest(): Int32 { 1 }
    public static func low(): Int32 { 2 }
    public static func normal(): Int32 { 3 }
    public static func high(): Int32 { 4 }
    public static func highest(): Int32 { 5 }
    public static func timeCritical(): Int32 { 6 }
    public static func inherit(): Int32 { 7 }
}


// ============================================================
// QRunnable - 可运行任务
// ============================================================
public class QRunnable {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QRunnable already deleted")
        }
    }

    /// 创建可运行任务，传入回调函数
    public init(callback: VoidCallback) {
        unsafe {
            ptr = qRunnableCreate(callback)
            if (ptr == 0) {
                throw CreateFailedException("QRunnable create failed")
            }
        }
    }

    public func getPtr(): Int64 { ptr }

    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe { qRunnableDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}


// ============================================================
// QThread - 线程
// ============================================================
public class QThread {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QThread already deleted")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QThread 底层 Qt 对象已失效")
        }
    }

    public init() {
        unsafe {
            ptr = qThreadCreate()
            if (ptr == 0) {
                throw CreateFailedException("QThread create failed")
            }
        }
        trackObject(ptr)
    }

    /// 启动线程
    public func start(): Unit {
        checkValid()
        unsafe { qThreadStart(ptr) }
    }

    /// 退出线程事件循环
    public func quit(): Unit {
        checkValid()
        unsafe { qThreadQuit(ptr) }
    }

    /// 等待线程结束（无限等待）
    public func wait(): Bool {
        checkValid()
        unsafe { qThreadWait(ptr, -1) }
    }

    /// 等待线程结束（指定超时毫秒数）
    public func waitTimeout(timeoutMs: Int32): Bool {
        checkValid()
        unsafe { qThreadWait(ptr, timeoutMs) }
    }

    /// 线程是否在运行
    public func isRunning(): Bool {
        checkValid()
        unsafe { qThreadIsRunning(ptr) }
    }

    /// 线程是否已结束
    public func isFinished(): Bool {
        checkValid()
        unsafe { qThreadIsFinished(ptr) }
    }

    /// 设置优先级
    public func setPriority(priority: Int32): Unit {
        checkValid()
        unsafe { qThreadSetPriority(ptr, priority) }
    }

    /// 获取优先级
    public func priority(): Int32 {
        checkValid()
        unsafe { qThreadPriority(ptr) }
    }

    /// 设置栈大小
    public func setStackSize(stackSize: Int64): Unit {
        checkValid()
        unsafe { qThreadSetStackSize(ptr, stackSize) }
    }

    /// 获取栈大小
    public func stackSize(): Int64 {
        checkValid()
        unsafe { qThreadStackSize(ptr) }
    }

    /// 退出线程（带返回码）
    public func exit(): Unit {
        checkValid()
        unsafe { qThreadExit(ptr) }
    }

    /// 是否请求中断
    public func isInterruptionRequested(): Bool {
        checkValid()
        unsafe { qThreadIsInterruptionRequested(ptr) }
    }

    /// 请求线程中断
    public func requestInterruption(): Unit {
        checkValid()
        unsafe { qThreadRequestInterruption(ptr) }
    }

    // ---- 信号连接 ----

    /// 线程启动时回调
    public func setOnStarted(callback: VoidCallback): Unit {
        checkValid()
        unsafe { qThreadConnectStarted(ptr, callback) }
    }

    /// 线程结束时回调
    public func setOnFinished(callback: VoidCallback): Unit {
        checkValid()
        unsafe { qThreadConnectFinished(ptr, callback) }
    }

    /// 断开所有信号连接
    public func disconnectCallbacks(): Unit {
        checkValid()
        unsafe { qThreadDisconnectCallbacks(ptr) }
    }

    // ---- 静态方法 ----

    /// 获取当前线程指针
    public static func currentThreadPtr(): Int64 {
        unsafe { qThreadCurrentThread() }
    }

    /// 获取理想线程数（CPU核心数）
    public static func idealThreadCount(): Int64 {
        unsafe { qThreadIdealThreadCount() }
    }

    /// 休眠指定毫秒
    public static func msleep(ms: Int32): Unit {
        unsafe { qThreadMsleep(ms) }
    }

    public func getPtr(): Int64 { ptr }

    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            unsafe { qThreadDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}


// ============================================================
// QThreadPool - 线程池
// ============================================================
public class QThreadPool {
    private var ptr: Int64 = 0

    private init(p: Int64) {
        ptr = p
    }

    /// 获取全局线程池实例
    public static func globalInstance(): QThreadPool {
        let pool = QThreadPool(0)
        unsafe { pool.ptr = qThreadPoolGlobalInstance() }
        trackObject(pool.ptr)
        return pool
    }

    /// 启动任务
    public func start(runnable: QRunnable): Unit {
        unsafe { qThreadPoolStart(ptr, runnable.getPtr()) }
    }

    /// 等待所有任务完成（无限等待）
    public func waitForDone(): Bool {
        unsafe { qThreadPoolWaitForDone(ptr, -1) }
    }

    /// 等待所有任务完成（指定超时毫秒数）
    public func waitForDoneTimeout(timeoutMs: Int32): Bool {
        unsafe { qThreadPoolWaitForDone(ptr, timeoutMs) }
    }

    /// 活动线程数
    public func activeThreadCount(): Int32 {
        unsafe { qThreadPoolActiveThreadCount(ptr) }
    }

    /// 最大线程数
    public func maxThreadCount(): Int32 {
        unsafe { qThreadPoolMaxThreadCount(ptr) }
    }

    /// 设置最大线程数
    public func setMaxThreadCount(count: Int32): Unit {
        unsafe { qThreadPoolSetMaxThreadCount(ptr, count) }
    }

    /// 获取超时时间
    public func expiryTimeout(): Int32 {
        unsafe { qThreadPoolExpiryTimeout(ptr) }
    }

    /// 设置超时时间
    public func setExpiryTimeout(timeout: Int32): Unit {
        unsafe { qThreadPoolSetExpiryTimeout(ptr, timeout) }
    }

    public func getPtr(): Int64 { ptr }
}
