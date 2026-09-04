package cjqt6.views

import cjqt6.core.*

// ============================================================
// QFileSystemModel FFI declarations
// ============================================================

foreign func qFileSystemModelCreate(): Int64
foreign func qFileSystemModelSetRootPath(ptr: Int64, path: CString): Unit
foreign func qFileSystemModelRootPath(ptr: Int64): CString
foreign func qFileSystemModelIndex(ptr: Int64, path: CString): Int64
foreign func qFileSystemModelSetNameFilters(ptr: Int64, filters: CString): Unit
foreign func qFileSystemModelSetFilter(ptr: Int64, filter: Int32): Unit
foreign func qFileSystemModelDelete(ptr: Int64): Unit

// 补充 API FFI
foreign func qFileSystemModelSetReadOnly(ptr: Int64, v: Int32): Unit
foreign func qFileSystemModelIsReadOnly(ptr: Int64): Int32
foreign func qFileSystemModelSetNameFilterDisables(ptr: Int64, v: Int32): Unit
foreign func qFileSystemModelSetResolveSymlinks(ptr: Int64, v: Int32): Unit
foreign func qFileSystemModelIsResolveSymlinks(ptr: Int64): Int32
foreign func qFileSystemModelFilePath(ptr: Int64, indexPtr: Int64): CString
foreign func qFileSystemModelFileName(ptr: Int64, indexPtr: Int64): CString
foreign func qFileSystemModelIsDir(ptr: Int64, indexPtr: Int64): Int32
foreign func qFileSystemModelConnectDirectoryLoaded(ptr: Int64, callback: CStringCallback): Unit
foreign func qFileSystemModelConnectRootPathChanged(ptr: Int64, callback: CStringCallback): Unit

// ============================================================
// QFileSystemModel
// ============================================================
public class QFileSystemModel {
    private var ptr: Int64 = 0

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0) {
            throw ResourceDisposedException("QFileSystemModel already deleted")
        }
    }

    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qFileSystemModelCreate()
        }
        if (ptr == 0) {
            throw CreateFailedException("QFileSystemModel create failed")
        }
    }

    public func show(): Unit {
        checkValid()
        unsafe {
            qWidgetShow(ptr)
        }
    }

    public func hide(): Unit {
        checkValid()
        unsafe {
            qWidgetHide(ptr)
        }
    }

    public func resize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }

    public func setEnabled(enabled: Bool): Unit {
        checkValid()
        unsafe {
            qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }

    public func setStyleSheet(style: String): Unit {
        checkValid()
        unsafe {
            withCString(style) { c => qWidgetSetStyleSheet(ptr, c) }
        }
    }

    public func setRootPath(path: String): Unit {
        checkValid()
        unsafe {
            withCString(path) { c => qFileSystemModelSetRootPath(ptr, c) }
        }
    }

    public func rootPath(): String {
        checkValid()
        unsafe {
            let cstr = qFileSystemModelRootPath(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    public func index(path: String): Int64 {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(path)
            let result = qFileSystemModelIndex(ptr, cstr)
            LibC.free(cstr)
            return result
        }
    }

    public func setNameFilters(filters: Array<String>): Unit {
        checkValid()
        unsafe {
            // Join filters with newline separator for C-side parsing
            var joined = ""
            for (i in 0..filters.size) {
                if (i > 0) {
                    joined += "\n"
                }
                joined += filters[i]
            }
            withCString(joined) { c => qFileSystemModelSetNameFilters(ptr, c) }
        }
    }

    public func setFilter(filter: Int32): Unit {
        checkValid()
        unsafe {
            qFileSystemModelSetFilter(ptr, filter)
        }
    }

    public func setReadOnly(readOnly: Bool): Unit {
        checkValid()
        unsafe {
            qFileSystemModelSetReadOnly(ptr, if (readOnly) { 1 } else { 0 })
        }
    }

    public func isReadOnly(): Bool {
        checkValid()
        unsafe {
            qFileSystemModelIsReadOnly(ptr) != 0
        }
    }

    public func setNameFilterDisables(disables: Bool): Unit {
        checkValid()
        unsafe {
            qFileSystemModelSetNameFilterDisables(ptr, if (disables) { 1 } else { 0 })
        }
    }

    public func setResolveSymlinks(resolve: Bool): Unit {
        checkValid()
        unsafe {
            qFileSystemModelSetResolveSymlinks(ptr, if (resolve) { 1 } else { 0 })
        }
    }

    public func isResolveSymlinks(): Bool {
        checkValid()
        unsafe {
            qFileSystemModelIsResolveSymlinks(ptr) != 0
        }
    }

    public func filePath(index: QModelIndex): String {
        checkValid()
        unsafe {
            let cstr = qFileSystemModelFilePath(ptr, index.ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    public func fileName(index: QModelIndex): String {
        checkValid()
        unsafe {
            let cstr = qFileSystemModelFileName(ptr, index.ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    public func isDir(index: QModelIndex): Bool {
        checkValid()
        unsafe {
            qFileSystemModelIsDir(ptr, index.ptr) != 0
        }
    }

    public func setOnDirectoryLoaded(callback: CStringCallback): Unit {
        checkValid()
        unsafe {
            qFileSystemModelConnectDirectoryLoaded(ptr, callback)
        }
    }

    public func setOnRootPathChanged(callback: CStringCallback): Unit {
        checkValid()
        unsafe {
            qFileSystemModelConnectRootPathChanged(ptr, callback)
        }
    }

    public func getPtr(): Int64 {
        ptr
    }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qFileSystemModelDelete(ptr)
            }
            ptr = 0
        }
    }
}
