package cjqt6.gui

import cjqt6.core.*

// ============================================================
// QCursor FFI
// ============================================================

foreign func qCursorCreate(): Int64
foreign func qCursorCreateWithShape(shape: Int32): Int64
foreign func qCursorDelete(ptr: Int64): Unit
foreign func qCursorShape(ptr: Int64): Int32
foreign func qCursorSetShape(ptr: Int64, shape: Int32): Unit
foreign func qCursorSetPos(x: Int32, y: Int32): Unit
foreign func qCursorPosX(): Int32
foreign func qCursorPosY(): Int32


// ============================================================
// 光标形状常量（与 Qt::CursorShape 枚举对应）
// ============================================================
/// 光标形状常量，用于创建或设置光标形状
public class CursorShape {
    /// 标准箭头光标
    public static func arrow(): Int32 { 0 }
    /// 向上箭头光标
    public static func upArrow(): Int32 { 1 }
    /// 十字光标
    public static func cross(): Int32 { 2 }
    /// 等待（沙漏/转圈）光标
    public static func waitCursor(): Int32 { 3 }
    /// 文本编辑 I 形光标
    public static func iBeam(): Int32 { 4 }
    /// 垂直大小调整光标（上下箭头）
    public static func sizeVer(): Int32 { 5 }
    /// 水平大小调整光标（左右箭头）
    public static func sizeHor(): Int32 { 6 }
    /// 沿主对角线调整大小光标
    public static func sizeBDiag(): Int32 { 7 }
    /// 沿副对角线调整大小光标
    public static func sizeFDiag(): Int32 { 8 }
    /// 四方向调整大小光标
    public static func sizeAll(): Int32 { 9 }
    /// 空白光标（隐藏光标）
    public static func blank(): Int32 { 10 }
    /// 垂直分割光标
    public static func splitV(): Int32 { 11 }
    /// 水平分割光标
    public static func splitH(): Int32 { 12 }
    /// 手型光标（链接等可点击元素）
    public static func pointingHand(): Int32 { 13 }
    /// 禁止（斜杠圆）光标
    public static func forbidden(): Int32 { 14 }
    /// "这是什么"帮助光标
    public static func whatsThis(): Int32 { 15 }
    /// 忙（后台运行）光标
    public static func busy(): Int32 { 16 }
    /// 张开的手型（可抓取）
    public static func openHand(): Int32 { 17 }
    /// 握紧的手型（抓取中）
    public static func closedHand(): Int32 { 18 }
    /// 拖拽复制光标
    public static func dragCopy(): Int32 { 19 }
    /// 拖拽移动光标
    public static func dragMove(): Int32 { 20 }
    /// 拖拽链接光标
    public static func dragLink(): Int32 { 21 }
}


// ============================================================
// QCursor - 光标
// ============================================================
/// 鼠标光标，可设置形状或屏幕位置（含全局光标控制）
public class QCursor {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QCursor already deleted")
        }
    }

    /// 创建默认光标
    public init() {
        unsafe { ptr = qCursorCreate() }
    }

    /// 创建指定形状的光标
    public init(shape: Int32) {
        unsafe { ptr = qCursorCreateWithShape(shape) }
    }

    /// 获取光标形状
    public func shape(): Int32 {
        checkValid()
        unsafe { qCursorShape(ptr) }
    }

    /// 设置光标形状
    public func setShape(shape: Int32): Unit {
        checkValid()
        unsafe { qCursorSetShape(ptr, shape) }
    }

    /// 设置全局光标位置
    public static func setPos(x: Int32, y: Int32): Unit {
        unsafe { qCursorSetPos(x, y) }
    }

    /// 获取光标屏幕X位置
    public static func posX(): Int32 {
        unsafe { qCursorPosX() }
    }

    /// 获取光标屏幕Y位置
    public static func posY(): Int32 {
        unsafe { qCursorPosY() }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe { qCursorDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
