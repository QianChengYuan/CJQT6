package cjqt6.core

// ============================================================
// bridge 分配字符串的释放助手
// ============================================================
//
// 桥接层所有返回的 CString 均由 C++ 侧 std::malloc(UCRT) 分配。
// 仓颉侧 LibC.free 绑定的是 msvcrt free，与 UCRT 堆不兼容，
// 直接释放会造成堆损坏导致崩溃/挂起。必须经由 qCStringFree
// 让 malloc/free 处于同一堆，跨平台安全。

foreign func qCStringFree(s: CString): Unit

/// 释放桥接层 malloc 分配的返回字符串（与 qXxx 返回值配套使用）
public func freeBridgeString(s: CString): Unit {
    unsafe { qCStringFree(s) }
}

// ============================================================
// 输入字符串借用助手（P2 样板收敛）
//
// 调用带 CString 入参的 FFI 函数的标准三连（malloc -> call -> free）
// 收敛为单个尾随 Lambda 调用，free 集中在助手内保证不遗漏：
//     withCString(text) { c => unsafe { qLabelSetText(ptr, c) } }
// 或外层已有 unsafe 上下文时：
//     unsafe { withCString(text) { c => qLabelSetText(ptr, c) } }
// ============================================================

/// 借用 String 的 CString 视图执行 FFI 调用，调用结束自动释放
public func withCString(s: String, f: (CString) -> Unit): Unit {
    unsafe {
        let cstr = LibC.mallocCString(s)
        f(cstr)
        LibC.free(cstr)
    }
}

// ============================================================
// QObject 存活注册表（P0 反向失效通知）
//
// native 侧维护存活注册表：trackObject 在对象创建后调用，注册
// QObject::destroyed 连接；untrackObject 在 close() 时调用，注销条目；
// isObjectAlive 查询对象是否仍存活。
//
// 语义：
//   - 未 track 的对象（值类型/非 QObject）视为存活，返回 true；
//   - 对象被级联销毁（父控件 close 等）后，native 侧 destroyed 信号
//     自动标记失效，isObjectAlive 返回 false，配合 isValid()/checkValid()
//     即可识别"仓颉句柄仍持有、但 Qt 对象已消亡"的场景。
// ============================================================

foreign func qTrackObject(ptr: Int64): Unit
foreign func qUntrackObject(ptr: Int64): Unit
foreign func qIsObjectAlive(ptr: Int64): Bool

/// 注册对象到 native 存活表（对象创建后调用）
public func trackObject(ptr: Int64): Unit {
    unsafe { qTrackObject(ptr) }
}

/// 从 native 存活表注销对象（close() 时调用）
public func untrackObject(ptr: Int64): Unit {
    unsafe { qUntrackObject(ptr) }
}

/// 查询对象是否仍存活；未 track 的对象视为存活
public func isObjectAlive(ptr: Int64): Bool {
    unsafe { qIsObjectAlive(ptr) }
}
