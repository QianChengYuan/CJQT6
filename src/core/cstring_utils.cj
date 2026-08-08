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
