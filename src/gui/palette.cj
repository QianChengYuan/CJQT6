package cjqt6.gui

import cjqt6.core.*

// ============================================================
// QPalette - 调色板
// ============================================================

foreign func qPaletteCreate(): Int64
foreign func qPaletteDelete(ptr: Int64): Unit
foreign func qPaletteColor(ptr: Int64, group: Int32, role: Int32): Int64
foreign func qPaletteSetColor(ptr: Int64, group: Int32, role: Int32, r: Int32, g: Int32, b: Int32, a: Int32): Unit

/// 调色板，定义控件在不同状态（普通/禁用/激活等）下各角色的颜色，用于统一样式
public class QPalette {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) { throw ResourceDisposedException("QPalette already deleted") }
    }
    /// 创建默认调色板
    public init() { unsafe { ptr = qPaletteCreate() } }
    /// 获取指定状态组、角色下的颜色（返回 ARGB 值），group 为 QPalette::ColorGroup，role 为 QPalette::ColorRole
    public func color(group: Int32, role: Int32): Int64 {
        checkValid()
        unsafe { qPaletteColor(ptr, group, role) }
    }
    /// 设置指定状态组、角色下的颜色（RGBA 分量 0-255）
    public func setColor(group: Int32, role: Int32, r: Int32, g: Int32, b: Int32, a: Int32): Unit {
        checkValid()
        unsafe { qPaletteSetColor(ptr, group, role, r, g, b, a) }
    }
    /// 获取底层指针
    public func getPtr(): Int64 { ptr }
    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) { unsafe { qPaletteDelete(ptr) }; ptr = 0; closed = true }
    }
}
