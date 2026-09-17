package cjqt6.widgets

import cjqt6.core.*

// QSizeGrip FFI 声明
foreign func qSizeGripCreate(parentPtr: Int64): Int64

foreign func qSizeGripSetVisible(ptr: Int64, visible: Bool): Unit

foreign func qSizeGripDelete(ptr: Int64): Unit

/// 窗口右下角调整大小手柄
public class QSizeGrip <: QtWidgetCore {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    public init(parent: QWidget) {
        unsafe {
            ptr = qSizeGripCreate(parent.getPtr())
        }
        trackObject(ptr)
    }

    /// 设置可见性
    public func setVisible(visible: Bool): Unit {
        unsafe { qSizeGripSetVisible(ptr, visible) }
    }

    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }

    /// 是否已关闭
    public func isClosed(): Bool {
        closed
    }

    /// 对象是否仍然可用
    public func isValid(): Bool {
        !closed && ptr != 0 && isObjectAlive(ptr)
    }

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QSizeGrip 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QSizeGrip 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QSizeGrip 底层 Qt 对象已失效")
        }
    }

    /// 关闭资源，释放 Qt 对象（幂等）
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
                qSignalCleanup(ptr)
                qSizeGripDelete(ptr)
            }
        }
        closed = true
        ptr = 0
    }

    /// 删除部件（兼容旧 API，等价于 close()）
    public func delete(): Unit {
        close()
    }
}
