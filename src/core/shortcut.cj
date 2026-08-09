package cjqt6.core

// ============================================================
// QShortcut - 快捷键
// ============================================================

foreign func qShortcutCreate(parentPtr: Int64): Int64
foreign func qShortcutSetKey(ptr: Int64, keySequence: CString): Unit
foreign func qShortcutSetEnabled(ptr: Int64, enabled: Bool): Unit
foreign func qShortcutSetAutoRepeat(ptr: Int64, repeat: Bool): Unit
foreign func qShortcutDelete(ptr: Int64): Unit

/// 快捷键，将按键序列绑定到父控件，触发对应操作（结合信号系统使用）
public class QShortcut <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// 为指定父控件创建快捷键
    public init(parent: QWidget) {
        unsafe {
            ptr = qShortcutCreate(parent.getPtr())
            if (ptr == 0) {
                throw CreateFailedException("QShortcut 创建失败")
            }
        }
        trackObject(ptr)
    }

    /// 设置快捷键对应的按键序列（如 "Ctrl+O"）
    public func setKey(keySequence: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(keySequence)
            qShortcutSetKey(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 启用或禁用快捷键
    public func setEnabled(enabled: Bool): Unit {
        checkValid()
        unsafe {
            qShortcutSetEnabled(ptr, enabled)
        }
    }

    /// 设置长按按键时是否自动重复触发
    public func setAutoRepeat(repeat: Bool): Unit {
        checkValid()
        unsafe {
            qShortcutSetAutoRepeat(ptr, repeat)
        }
    }

    public func getPtr(): Int64 {
        return ptr
    }

    public func isClosed(): Bool {
        return closed
    }

    public func isValid(): Bool {
        return !closed && ptr != 0 && isObjectAlive(ptr)
    }

    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QShortcut 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QShortcut 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QShortcut 底层 Qt 对象已失效")
        }
    }

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
                qShortcutDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }

    public func delete(): Unit {
        close()
    }
}
