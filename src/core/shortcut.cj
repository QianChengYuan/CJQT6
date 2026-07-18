package cjqt6.core

foreign func qShortcutCreate(parentPtr: Int64): Int64
foreign func qShortcutSetKey(ptr: Int64, keySequence: CString): Unit
foreign func qShortcutSetEnabled(ptr: Int64, enabled: Bool): Unit
foreign func qShortcutSetAutoRepeat(ptr: Int64, repeat: Bool): Unit
foreign func qShortcutDelete(ptr: Int64): Unit

public class QShortcut <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    public init(parent: QWidget) {
        unsafe {
            ptr = qShortcutCreate(parent.getPtr())
            if (ptr == 0) {
                throw CreateFailedException("QShortcut 创建失败")
            }
        }
    }

    public func setKey(keySequence: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(keySequence)
            qShortcutSetKey(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func setEnabled(enabled: Bool): Unit {
        checkValid()
        unsafe {
            qShortcutSetEnabled(ptr, enabled)
        }
    }

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
        return !closed && ptr != 0
    }

    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QShortcut 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QShortcut 指针为空")
        }
    }

    public func close(): Unit {
        if (!closed && ptr != 0) {
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
