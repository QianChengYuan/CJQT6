package cjqt6.core

foreign func qSettingsCreate(appName: CString): Int64
foreign func qSettingsCreateWithFile(fileName: CString): Int64
foreign func qSettingsSetValue(ptr: Int64, key: CString, value: CString): Unit
foreign func qSettingsValue(ptr: Int64, key: CString, defaultValue: CString): CString
foreign func qSettingsValueInt(ptr: Int64, key: CString, defaultValue: Int32): Int32
foreign func qSettingsValueBool(ptr: Int64, key: CString, defaultValue: Bool): Bool
foreign func qSettingsBeginGroup(ptr: Int64, prefix: CString): Unit
foreign func qSettingsEndGroup(ptr: Int64): Unit
foreign func qSettingsSync(ptr: Int64): Unit
foreign func qSettingsContains(ptr: Int64, key: CString): Bool
foreign func qSettingsRemove(ptr: Int64, key: CString): Unit
foreign func qSettingsDelete(ptr: Int64): Unit

public class QSettings <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private init() {}

    public init(appName: String) {
        unsafe {
            let cstr = LibC.mallocCString(appName)
            ptr = qSettingsCreate(cstr)
            LibC.free(cstr)
            if (ptr == 0) {
                throw CreateFailedException("QSettings 创建失败")
            }
        }
    }

    public static func fromFile(fileName: String): QSettings {
        let s = QSettings()
        unsafe {
            let cstr = LibC.mallocCString(fileName)
            s.ptr = qSettingsCreateWithFile(cstr)
            LibC.free(cstr)
            if (s.ptr == 0) {
                throw CreateFailedException("QSettings 创建失败")
            }
        }
        return s
    }

    public func setValue(key: String, value: String): Unit {
        checkValid()
        unsafe {
            let cstrKey = LibC.mallocCString(key)
            let cstrVal = LibC.mallocCString(value)
            qSettingsSetValue(ptr, cstrKey, cstrVal)
            LibC.free(cstrKey)
            LibC.free(cstrVal)
        }
    }

    public func value(key: String, defaultValue: String): String {
        checkValid()
        unsafe {
            let cstrKey = LibC.mallocCString(key)
            let cstrDef = LibC.mallocCString(defaultValue)
            let cstr = qSettingsValue(ptr, cstrKey, cstrDef)
            LibC.free(cstrKey)
            LibC.free(cstrDef)
            return cstr.toString()
        }
    }

    public func valueInt(key: String, defaultValue: Int32): Int32 {
        checkValid()
        unsafe {
            let cstrKey = LibC.mallocCString(key)
            let result = qSettingsValueInt(ptr, cstrKey, defaultValue)
            LibC.free(cstrKey)
            return result
        }
    }

    public func valueBool(key: String, defaultValue: Bool): Bool {
        checkValid()
        unsafe {
            let cstrKey = LibC.mallocCString(key)
            let result = qSettingsValueBool(ptr, cstrKey, defaultValue)
            LibC.free(cstrKey)
            return result
        }
    }

    public func beginGroup(prefix: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(prefix)
            qSettingsBeginGroup(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func endGroup(): Unit {
        checkValid()
        unsafe {
            qSettingsEndGroup(ptr)
        }
    }

    public func sync(): Unit {
        checkValid()
        unsafe {
            qSettingsSync(ptr)
        }
    }

    public func contains(key: String): Bool {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(key)
            let result = qSettingsContains(ptr, cstr)
            LibC.free(cstr)
            return result
        }
    }

    public func remove(key: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(key)
            qSettingsRemove(ptr, cstr)
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
        return !closed && ptr != 0
    }

    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QSettings 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QSettings 指针为空")
        }
    }

    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qSettingsDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }

    public func delete(): Unit {
        close()
    }
}
