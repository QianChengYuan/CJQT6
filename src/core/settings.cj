package cjqt6.core

// ============================================================
// QSettings - 应用配置持久化
// ============================================================

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

/// 应用配置持久化，以键值对方式读写应用设置（支持分组与多类型取值）
public class QSettings <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private init() {}

    /// 按应用名称创建配置存储（读写平台约定的应用配置位置）
    public init(appName: String) {
        unsafe {
            let cstr = LibC.mallocCString(appName)
            ptr = qSettingsCreate(cstr)
            LibC.free(cstr)
            if (ptr == 0) {
                throw CreateFailedException("QSettings 创建失败")
            }
        }
        trackObject(ptr)
    }

    /// 从指定 INI 格式文件创建配置存储
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
        trackObject(s.ptr)
        return s
    }

    /// 写入字符串键值对
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

    /// 读取字符串值，键不存在时返回 defaultValue
    public func value(key: String, defaultValue: String): String {
        checkValid()
        unsafe {
            let cstrKey = LibC.mallocCString(key)
            let cstrDef = LibC.mallocCString(defaultValue)
            let cstr = qSettingsValue(ptr, cstrKey, cstrDef)
            let result = cstr.toString()
            freeBridgeString(cstr)
            LibC.free(cstrKey)
            LibC.free(cstrDef)
            return result
        }
    }

    /// 读取整数值，键不存在时返回 defaultValue
    public func valueInt(key: String, defaultValue: Int32): Int32 {
        checkValid()
        unsafe {
            let cstrKey = LibC.mallocCString(key)
            let result = qSettingsValueInt(ptr, cstrKey, defaultValue)
            LibC.free(cstrKey)
            return result
        }
    }

    /// 读取布尔值，键不存在时返回 defaultValue
    public func valueBool(key: String, defaultValue: Bool): Bool {
        checkValid()
        unsafe {
            let cstrKey = LibC.mallocCString(key)
            let result = qSettingsValueBool(ptr, cstrKey, defaultValue)
            LibC.free(cstrKey)
            return result
        }
    }

    /// 开始分组，后续键读写都带上前缀（如 "window/"）
    public func beginGroup(prefix: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(prefix)
            qSettingsBeginGroup(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 结束当前分组
    public func endGroup(): Unit {
        checkValid()
        unsafe {
            qSettingsEndGroup(ptr)
        }
    }

    /// 将内存中的改动同步写入磁盘
    public func sync(): Unit {
        checkValid()
        unsafe {
            qSettingsSync(ptr)
        }
    }

    /// 指定键是否存在
    public func contains(key: String): Bool {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(key)
            let result = qSettingsContains(ptr, cstr)
            LibC.free(cstr)
            return result
        }
    }

    /// 删除指定键及其值
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
        return !closed && ptr != 0 && isObjectAlive(ptr)
    }

    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QSettings 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QSettings 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QSettings 底层 Qt 对象已失效")
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
