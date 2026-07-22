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


// ============================================================
// QFileSystemModel
// ============================================================
public class QFileSystemModel {
    private var ptr: Int64 = 0

    private func checkValid(): Unit {
        if (ptr == 0) {
            throw ResourceDisposedException("QFileSystemModel already deleted")
        }
    }

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
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func setRootPath(path: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(path)
            qFileSystemModelSetRootPath(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func rootPath(): String {
        checkValid()
        unsafe {
            let cstr = qFileSystemModelRootPath(ptr)
            return cstr.toString()
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
            let cstr = LibC.mallocCString(joined)
            qFileSystemModelSetNameFilters(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func setFilter(filter: Int32): Unit {
        checkValid()
        unsafe {
            qFileSystemModelSetFilter(ptr, filter)
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