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
public class QVideoWidget {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QVideoWidget already deleted")
        }
    }

    /// 创建视频显示控件
    public init() {
        unsafe {
            ptr = qVideoWidgetCreate()
        }
        if (ptr == 0) {
            throw CreateFailedException("QVideoWidget create failed")
        }
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

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qVideoWidgetDelete(ptr)
            }
            ptr = 0
            closed = true
        }
    }
}
