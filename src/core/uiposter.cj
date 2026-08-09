package cjqt6.core

// ============================================================
// UiPoster —— 跨线程回投 UI 线程的唯一出口（P1）
// ------------------------------------------------------------
// 背景：仓颉 spawn 出的工作线程没有 Qt 事件循环，结果必须投递到
// GUI 线程的事件队列才能安全操作控件。本类收口所有「回投 UI 线程」
// 的投递路径：内部复用 registerVoidCallback（闭包注册表）+ native
// UiPoster（QMetaObject::invokeMethod QueuedConnection 塞进
// QCoreApplication 事件队列），GUI 线程事件循环取出后按 id 派发闭包。
//
// 约束（roadmap 4.1）：
//   - 所有 runOnUiThread / 异步回投只走本入口，禁止各模块各自
//     new QTimer / 自建投递路径；
//   - 回调在 GUI 线程事件循环中异步执行（即使调用方就在 GUI 线程，
//     也是排队执行，与 QTimer::singleShot(0) 语义一致）；
//   - 一次性任务执行后自动从注册表注销，避免注册表无界增长。
// ============================================================

foreign func qUiPosterPost(id: Int64): Unit

// 一次性任务载体：闭包捕获不可变引用、改其字段来拿注册表 id，
// 规避 Cangjie「捕获可变变量需直接调用」的限制（与信号捕获约定一致）。
private class UiPosterTask {
    public var id: Int64 = 0
}

/// UI 线程投递器（单例，全部静态方法）
public class UiPoster {

    /// 把一个可捕获闭包投递到 GUI 线程事件队列（异步，先进先出）
    public static func runOnUiThread(callback: () -> Unit): Unit {
        let holder = UiPosterTask()
        let id = registerVoidCallback({ =>
            callback()
            unregisterVoidCallback(holder.id)
        })
        holder.id = id
        unsafe { qUiPosterPost(id) }
    }

    /// 别名：runOnUiThread
    public static func post(callback: () -> Unit): Unit {
        runOnUiThread(callback)
    }
}

/// 顶层便捷函数：把一个可捕获闭包投递到 GUI 线程事件队列
public func runOnUiThread(callback: () -> Unit): Unit {
    UiPoster.runOnUiThread(callback)
}

/// 顶层便捷函数：后台执行 work，完成后在 GUI 线程调用 onDone（P1）
/// 典型用法：
///   runAsync({
///       // 耗时计算 / IO
///       let r = heavyCompute()
///   }, {
///       // GUI 线程安全操作控件
///       label.setText("完成")
///   })
public func runAsync(work: () -> Unit, onDone: () -> Unit): Unit {
    spawn { =>
        work()
        runOnUiThread(onDone)
    }
}
