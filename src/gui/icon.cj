package cjqt6.gui

import cjqt6.core.*

// QIcon FFI
foreign func qIconCreate(): Int64
foreign func qIconCreateFromFile(filename: CString): Int64
foreign func qIconIsNull(ptr: Int64): Bool
foreign func qIconAddFile(ptr: Int64, filename: CString): Unit
foreign func qIconDelete(ptr: Int64): Unit

/// QIcon - 图标类
public class QIcon {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QIcon already deleted")
        }
    }

    /// 创建空图标
    public init() {
        unsafe {
            ptr = qIconCreate()
        }
    }

    /// 从文件路径创建图标
    public init(filename: String) {
        unsafe {
            withCString(filename) { c => ptr = qIconCreateFromFile(c) }
        }
    }

    /// 图标是否为空
    public func isNull(): Bool {
        checkValid()
        unsafe { qIconIsNull(ptr) }
    }

    /// 添加图标文件（支持不同模式/状态的图标）
    public func addFile(filename: String): Unit {
        checkValid()
        unsafe {
            withCString(filename) { c => qIconAddFile(ptr, c) }
        }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe { qIconDelete(ptr) }
            ptr = 0
            closed = true
        }
    }

    public func delete(): Unit { close() }
}
