package cjqt6.multimedia

import cjqt6.core.*

// ============================================================
// QVideoWidget FFI declarations
// ============================================================

foreign func qVideoWidgetCreate(): Int64
foreign func qVideoWidgetSetAspectRatioMode(ptr: Int64, mode: Int32): Unit
foreign func qVideoWidgetAspectRatioMode(ptr: Int64): Int32
foreign func qVideoWidgetShow(ptr: Int64): Unit
foreign func qVideoWidgetDelete(ptr: Int64): Unit


// ============================================================
// QVideoWidget - 视频显示控件
// ============================================================
public class QVideoWidget <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    public func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QVideoWidget already deleted")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QVideoWidget 底层 Qt 对象已失效")
        }
    }

    /// 创建视频显示控件
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qVideoWidgetCreate()
        }
        if (ptr == 0) {
            throw CreateFailedException("QVideoWidget create failed")
        }
        trackObject(ptr)
    }

    /// 显示控件
    public func show(): Unit {
        checkValid()
        unsafe {
            qVideoWidgetShow(ptr)
        }
    }

    /// 设置宽高比模式
    public func setAspectRatioMode(mode: Int32): Unit {
        checkValid()
        unsafe {
            qVideoWidgetSetAspectRatioMode(ptr, mode)
        }
    }

    /// 获取宽高比模式
    public func aspectRatioMode(): Int32 {
        checkValid()
        unsafe {
            qVideoWidgetAspectRatioMode(ptr)
        }
    }

    /// 获取原生指针
    public func getPtr(): Int64 {
        ptr
    }

    /// 是否已关闭
    public func isClosed(): Bool {
        closed
    }

    /// 检查对象有效性
    public func isValid(): Bool {
        !closed && ptr != 0 && isObjectAlive(ptr)
    }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            unsafe {
                qVideoWidgetDelete(ptr)
            }
            ptr = 0
            closed = true
        }
    }
}
