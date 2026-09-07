package cjqt6.core

// ============================================================
// 闭包捕获支持（P1c）
// ------------------------------------------------------------
// 背景：CFunc 不能捕获局部变量，导致回调只能访问全局 ?T 变量。
// 方案：Cangjie 侧把「可捕获闭包」存入全局注册表得到 id；native 侧
//       仅保存 id，信号触发时回调顶层调度器 CFunc，按 id 查表调用闭包。
// 该机制与既有 CFunc 路径并存（互不破坏）：
//   - 旧 API setOnXxx(VoidCallback) 走 CFunc 直接连接，行为不变；
//   - 新增重载 setOnXxx(callback: () -> Unit) 走注册表，可捕获局部变量。
// ============================================================

import std.collection.{HashMap, ArrayList}
import std.sync.{Mutex}

// void 闭包注册表：id -> 可捕获闭包
private var gVoidRegistry: HashMap<Int64, () -> Unit> = HashMap<Int64, () -> Unit>()
private let gRegistryLock = Mutex()
private var gNextId: Int64 = 1
private var gDispatcherSet: Bool = false

// 顶层调度器（CFunc，仅引用全局注册表、不捕获局部变量）：native 触发信号时回调此函数
// 线程安全：native 侧可能在任意线程调用本调度器（如 UiPoster 队列投递到 GUI 线程、
// 信号在发射线程直接派发），必须持 gRegistryLock 读取注册表，避免与
// registerVoidCallback / unregisterVoidCallback 的写操作并发导致 HashMap 数据竞争。
// 锁内只取出闭包、锁外调用：回调体内再 register/unregister 时不重入死锁。
private let gVoidDispatcher: CFunc<(Int64) -> Unit> = { id: Int64 =>
    var cb: ?(() -> Unit) = None
    synchronized (gRegistryLock) {
        cb = gVoidRegistry.get(id)
    }
    match (cb) {
        case Some(f) => f()
        case None => ()
    }
}

// native 侧注册表调度器入口与 id 版连接（foreign 声明见 signal.cj，与既有信号声明同处）

/// 注册一个可捕获的 void 闭包，返回注册表 id（供 native 按 id 派发）
public func registerVoidCallback(callback: () -> Unit): Int64 {
    synchronized (gRegistryLock) {
        if (!gDispatcherSet) {
            unsafe {
                qSetCallbackDispatcher(gVoidDispatcher)
            }
            gDispatcherSet = true
        }
        let id = gNextId
        gNextId = gNextId + 1
        gVoidRegistry[id] = callback
        return id
    }
}

/// 注销指定 id 的闭包（连接断开时调用，避免注册表泄漏）
public func unregisterVoidCallback(id: Int64): Unit {
    synchronized (gRegistryLock) {
        gVoidRegistry.remove(id)
    }
}

/// 获取顶层 void 闭包调度器
/// 供其他模块（如 cjqt6.network）注册自己的 id 派发入口时复用同一调度器：
/// 信号触发 -> native 调用此调度器(id) -> 查 gVoidRegistry 调用对应闭包
public func getVoidDispatcher(): CFunc<(Int64) -> Unit> {
    return gVoidDispatcher
}

// ============================================================
// 对象级捕获回调注册表（P1：close 级注销）
// ------------------------------------------------------------
// 背景：setOnXxxCapture 系列把可捕获闭包注册进 gVoidRegistry 得到 id；native
// 侧连接在对象销毁时自动断开，但 Cangjie 侧闭包仅靠「用户手动 disconnect」
// 注销。若用户直接 close()/delete() 对象（或连接句柄被丢弃），闭包与捕获的
// 对象图会永久滞留注册表 → 无界增长。本注册表把每个 id 记到「属主对象 ptr」
// 名下，对象 close() 时调用 unregisterObjectVoidCallbacks(ptr) 统一注销。
// 锁顺序：gRegistryLock 与 gObjVoidIdsLock 不嵌套持有（见各函数注释），无死锁。
// ============================================================

// ptr -> 该对象名下已注册的捕获闭包 id 列表
private var gObjVoidIds: HashMap<Int64, ArrayList<Int64>> = HashMap<Int64, ArrayList<Int64>>()
private let gObjVoidIdsLock = Mutex()

/// 注册可捕获闭包并记录到对象 ptr 名下（返回 id，供 native 派发）
/// 对象 close()/delete() 时请调用 unregisterObjectVoidCallbacks(ptr) 统一注销
public func registerObjectVoidCallback(ptr: Int64, callback: () -> Unit): Int64 {
    let id = registerVoidCallback(callback)
    // 先持 gRegistryLock（在上方已释放）再持 gObjVoidIdsLock，顺序恒定
    synchronized (gObjVoidIdsLock) {
        if (let Some(list) <- gObjVoidIds.get(ptr)) {
            list.add(id)
        } else {
            let list = ArrayList<Int64>()
            list.add(id)
            gObjVoidIds[ptr] = list
        }
    }
    return id
}

/// 注销对象名下全部捕获闭包（对象 close/delete 时调用，幂等）
public func unregisterObjectVoidCallbacks(ptr: Int64): Unit {
    var ids = ArrayList<Int64>()
    synchronized (gObjVoidIdsLock) {
        if (let Some(list) <- gObjVoidIds.get(ptr)) {
            ids = list
            gObjVoidIds.remove(ptr)
        }
    }
    // 锁外注销：unregisterVoidCallback 只持 gRegistryLock，避免两锁嵌套
    for (id in ids) {
        unregisterVoidCallback(id)
    }
}

/// 注销对象名下单个捕获闭包（信号断开路径调用，幂等；已断开的 id 注销为空操作）
public func unregisterObjectVoidCallback(ptr: Int64, id: Int64): Unit {
    synchronized (gObjVoidIdsLock) {
        if (let Some(list) <- gObjVoidIds.get(ptr)) {
            var i = 0
            while (i < list.size) {
                if (list[i] == id) {
                    list.remove(at: i)
                } else {
                    i = i + 1
                }
            }
            if (list.size == 0) {
                gObjVoidIds.remove(ptr)
            }
        }
    }
    unregisterVoidCallback(id)
}
