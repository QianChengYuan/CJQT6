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

import std.collection.HashMap
import std.sync.{Mutex}

// void 闭包注册表：id -> 可捕获闭包
private var gVoidRegistry: HashMap<Int64, () -> Unit> = HashMap<Int64, () -> Unit>()
private let gRegistryLock = Mutex()
private var gNextId: Int64 = 1
private var gDispatcherSet: Bool = false

// 顶层调度器（CFunc，仅引用全局注册表、不捕获局部变量）：native 触发信号时回调此函数
private let gVoidDispatcher: CFunc<(Int64) -> Unit> = { id: Int64 =>
    let cb = gVoidRegistry.get(id)
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
