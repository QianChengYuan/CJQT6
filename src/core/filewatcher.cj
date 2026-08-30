package cjqt6.core

// ============================================================
// QFileSystemWatcher - 文件系统监视器
// ============================================================

foreign func qFileSystemWatcherCreate(): Int64
foreign func qFileSystemWatcherAddPath(ptr: Int64, path: CString): Unit
foreign func qFileSystemWatcherRemovePath(ptr: Int64, path: CString): Unit
foreign func qFileSystemWatcherDelete(ptr: Int64): Unit

/// 文件系统监视器，监听指定文件/目录的变化（本封装提供路径的添加与移除管理）
public class QFileSystemWatcher <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// 创建文件系统监视器
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qFileSystemWatcherCreate()
            if (ptr == 0) {
                throw CreateFailedException("QFileSystemWatcher 创建失败")
            }
        }
        trackObject(ptr)
    }

    /// 添加要监视的文件或目录路径
    public func addPath(path: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(path)
            qFileSystemWatcherAddPath(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 移除不再监视的文件或目录路径
    public func removePath(path: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(path)
            qFileSystemWatcherRemovePath(ptr, cstr)
            LibC.free(cstr)
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

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QFileSystemWatcher 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QFileSystemWatcher 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QFileSystemWatcher 底层 Qt 对象已失效")
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
                qFileSystemWatcherDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }

    public func delete(): Unit {
        close()
    }
}
