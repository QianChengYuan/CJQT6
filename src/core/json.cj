package cjqt6.core

// ============================================================
// QJson 系列 - JSON 编解码封装
// ============================================================

foreign func qJsonDocumentFromJson(json: CString): Int64
foreign func qJsonDocumentDelete(ptr: Int64): Unit
foreign func qJsonDocumentToJson(ptr: Int64, indent: Int32): CString
foreign func qJsonDocumentIsNull(ptr: Int64): Bool
foreign func qJsonDocumentIsArray(ptr: Int64): Bool
foreign func qJsonDocumentIsObject(ptr: Int64): Bool
foreign func qJsonDocumentObject(ptr: Int64): Int64
foreign func qJsonDocumentArray(ptr: Int64): Int64

foreign func qJsonObjectCreate(): Int64
foreign func qJsonObjectDelete(ptr: Int64): Unit
foreign func qJsonObjectInsert(ptr: Int64, key: CString, valuePtr: Int64): Unit
foreign func qJsonObjectValue(ptr: Int64, key: CString): Int64
foreign func qJsonObjectContains(ptr: Int64, key: CString): Bool
foreign func qJsonObjectRemove(ptr: Int64, key: CString): Unit
foreign func qJsonObjectSize(ptr: Int64): Int32
foreign func qJsonObjectIsEmpty(ptr: Int64): Bool
foreign func qJsonObjectKeyAt(ptr: Int64, index: Int32): CString

foreign func qJsonArrayCreate(): Int64
foreign func qJsonArrayDelete(ptr: Int64): Unit
foreign func qJsonArrayAppend(ptr: Int64, valuePtr: Int64): Unit
foreign func qJsonArrayAt(ptr: Int64, index: Int32): Int64
foreign func qJsonArraySize(ptr: Int64): Int32
foreign func qJsonArrayIsEmpty(ptr: Int64): Bool
foreign func qJsonArrayRemoveAt(ptr: Int64, index: Int32): Unit

foreign func qJsonValueCreateNull(): Int64
foreign func qJsonValueCreateString(val: CString): Int64
foreign func qJsonValueCreateInt(val: Int64): Int64
foreign func qJsonValueCreateDouble(val: Float64): Int64
foreign func qJsonValueCreateBool(val: Bool): Int64
foreign func qJsonValueCreateArray(arrPtr: Int64): Int64
foreign func qJsonValueCreateObject(objPtr: Int64): Int64
foreign func qJsonValueDelete(ptr: Int64): Unit
foreign func qJsonValueType(ptr: Int64): Int32
foreign func qJsonValueToString(ptr: Int64): CString
foreign func qJsonValueToInt(ptr: Int64, defaultVal: Int64): Int64
foreign func qJsonValueToDouble(ptr: Int64, defaultVal: Float64): Float64
foreign func qJsonValueToBool(ptr: Int64, defaultVal: Bool): Bool
foreign func qJsonValueToObject(ptr: Int64): Int64
foreign func qJsonValueToArray(ptr: Int64): Int64
foreign func qJsonValueIsNull(ptr: Int64): Bool
foreign func qJsonValueIsString(ptr: Int64): Bool
foreign func qJsonValueIsArray(ptr: Int64): Bool
foreign func qJsonValueIsObject(ptr: Int64): Bool
foreign func qJsonValueIsBool(ptr: Int64): Bool
foreign func qJsonValueIsDouble(ptr: Int64): Bool

// ============================================================
// JsonType - JSON 值类型常量
// ============================================================

/// JSON 值类型常量（与 Qt 的 QJsonValue::Type 对应）
public class JsonType {
    /// Null 类型
    public static func nullType(): Int32 { 0 }
    /// 布尔类型
    public static func boolType(): Int32 { 1 }
    /// 浮点/整数类型
    public static func doubleType(): Int32 { 2 }
    /// 字符串类型
    public static func stringType(): Int32 { 3 }
    /// 数组类型
    public static func arrayType(): Int32 { 4 }
    /// 对象类型
    public static func objectType(): Int32 { 5 }
    /// 未定义类型
    public static func undefinedType(): Int32 { 6 }
}

// ============================================================
// QJsonValue - JSON 值
// ============================================================

/// JSON 值，可表示字符串、整数、浮点、布尔、数组、对象或 null
public class QJsonValue {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) { throw ResourceDisposedException("QJsonValue already deleted") }
    }

    internal init(p: Int64) { ptr = p }

    /// 创建 Null 值
    public static func createNull(): QJsonValue {
        let p = unsafe { qJsonValueCreateNull() }
        QJsonValue(p)
    }

    /// 创建字符串值
    public static func createString(val: String): QJsonValue {
        let p = unsafe { let c = LibC.mallocCString(val); let r = qJsonValueCreateString(c); LibC.free(c); r }
        QJsonValue(p)
    }

    /// 创建整数值
    public static func createInt(val: Int64): QJsonValue {
        let p = unsafe { qJsonValueCreateInt(val) }
        QJsonValue(p)
    }

    /// 创建浮点值
    public static func createDouble(val: Float64): QJsonValue {
        let p = unsafe { qJsonValueCreateDouble(val) }
        QJsonValue(p)
    }

    /// 创建布尔值
    public static func createBool(val: Bool): QJsonValue {
        let p = unsafe { qJsonValueCreateBool(val) }
        QJsonValue(p)
    }

    /// 获取值的类型（见 JsonType 常量）
    public func valueType(): Int32 { checkValid(); unsafe { qJsonValueType(ptr) } }
    /// 将值转换为字符串
    public func toString(): String { checkValid(); unsafe { qJsonValueToString(ptr).toString() } }
    /// 转换为整数（非整型时返回默认值）
    public func toInt(defaultVal: Int64): Int64 { checkValid(); unsafe { qJsonValueToInt(ptr, defaultVal) } }
    /// 转换为浮点数（非浮点类型时返回默认值）
    public func toDouble(defaultVal: Float64): Float64 { checkValid(); unsafe { qJsonValueToDouble(ptr, defaultVal) } }
    /// 转换为布尔值（非布尔类型时返回默认值）
    public func toBool(defaultVal: Bool): Bool { checkValid(); unsafe { qJsonValueToBool(ptr, defaultVal) } }
    /// 转换为对象指针（仅当值为对象时有意义）
    public func toObject(): Int64 { checkValid(); unsafe { qJsonValueToObject(ptr) } }
    /// 转换为数组指针（仅当值为数组时有意义）
    public func toArray(): Int64 { checkValid(); unsafe { qJsonValueToArray(ptr) } }
    /// 是否为 Null
    public func isNull(): Bool { checkValid(); unsafe { qJsonValueIsNull(ptr) } }
    /// 是否为字符串
    public func isString(): Bool { checkValid(); unsafe { qJsonValueIsString(ptr) } }
    /// 是否为数组
    public func isArray(): Bool { checkValid(); unsafe { qJsonValueIsArray(ptr) } }
    /// 是否为对象
    public func isObject(): Bool { checkValid(); unsafe { qJsonValueIsObject(ptr) } }
    /// 是否为布尔值
    public func isBool(): Bool { checkValid(); unsafe { qJsonValueIsBool(ptr) } }
    /// 是否为浮点/整数
    public func isDouble(): Bool { checkValid(); unsafe { qJsonValueIsDouble(ptr) } }

    /// 获取底层指针
    public func getPtr(): Int64 { ptr }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) { unsafe { qJsonValueDelete(ptr) }; ptr = 0; closed = true }
    }
}

// ============================================================
// QJsonObject - JSON 对象
// ============================================================

/// JSON 对象（键值对集合）
public class QJsonObject {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) { throw ResourceDisposedException("QJsonObject already deleted") }
    }

    internal init(p: Int64) { ptr = p }

    /// 创建空对象
    public init() { unsafe { ptr = qJsonObjectCreate() } }

    /// 插入键值对（键不存在时新增，存在时覆盖）
    public func insert(key: String, value: QJsonValue): Unit {
        checkValid()
        unsafe { let c = LibC.mallocCString(key); qJsonObjectInsert(ptr, c, value.getPtr()); LibC.free(c) }
    }

    /// 获取指定键对应的值（不存在时返回 Null 值）
    public func value(key: String): QJsonValue {
        checkValid()
        let p = unsafe { let c = LibC.mallocCString(key); let r = qJsonObjectValue(ptr, c); LibC.free(c); r }
        QJsonValue(p)
    }

    /// 是否包含指定键
    public func contains(key: String): Bool {
        checkValid()
        unsafe { let c = LibC.mallocCString(key); let r = qJsonObjectContains(ptr, c); LibC.free(c); r }
    }

    /// 移除指定键
    public func remove(key: String): Unit {
        checkValid()
        unsafe { let c = LibC.mallocCString(key); qJsonObjectRemove(ptr, c); LibC.free(c) }
    }

    /// 键值对数量
    public func size(): Int32 { checkValid(); unsafe { qJsonObjectSize(ptr) } }
    /// 是否为空对象
    public func isEmpty(): Bool { checkValid(); unsafe { qJsonObjectIsEmpty(ptr) } }

    /// 按索引获取键名
    public func keyAt(index: Int32): String {
        checkValid()
        unsafe { qJsonObjectKeyAt(ptr, index).toString() }
    }

    /// 获取底层指针
    public func getPtr(): Int64 { ptr }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) { unsafe { qJsonObjectDelete(ptr) }; ptr = 0; closed = true }
    }
}

// ============================================================
// QJsonArray - JSON 数组
// ============================================================

/// JSON 数组（有序值集合）
public class QJsonArray {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) { throw ResourceDisposedException("QJsonArray already deleted") }
    }

    internal init(p: Int64) { ptr = p }

    /// 创建空数组
    public init() { unsafe { ptr = qJsonArrayCreate() } }

    /// 追加值到数组末尾
    public func append(value: QJsonValue): Unit {
        checkValid()
        unsafe { qJsonArrayAppend(ptr, value.getPtr()) }
    }

    /// 按索引获取值
    public func at(index: Int32): QJsonValue {
        checkValid()
        let p = unsafe { qJsonArrayAt(ptr, index) }
        QJsonValue(p)
    }

    /// 元素数量
    public func size(): Int32 { checkValid(); unsafe { qJsonArraySize(ptr) } }
    /// 是否为空数组
    public func isEmpty(): Bool { checkValid(); unsafe { qJsonArrayIsEmpty(ptr) } }

    /// 移除指定索引处的值
    public func removeAt(index: Int32): Unit {
        checkValid()
        unsafe { qJsonArrayRemoveAt(ptr, index) }
    }

    /// 获取底层指针
    public func getPtr(): Int64 { ptr }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) { unsafe { qJsonArrayDelete(ptr) }; ptr = 0; closed = true }
    }
}

// ============================================================
// QJsonDocument - JSON 文档
// ============================================================

/// JSON 文档，可从 JSON 字符串解析，支持序列化回字符串
public class QJsonDocument {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) { throw ResourceDisposedException("QJsonDocument already deleted") }
    }

    /// 从 JSON 字符串解析文档（解析失败时文档为 Null）
    public init(json: String) {
        unsafe {
            let c = LibC.mallocCString(json)
            ptr = qJsonDocumentFromJson(c)
            LibC.free(c)
        }
    }

    /// 序列化为 JSON 字符串，indent 为缩进空格数（0 表示紧凑输出）
    public func toJson(indent: Int32): String {
        checkValid()
        unsafe { qJsonDocumentToJson(ptr, indent).toString() }
    }

    /// 文档是否为 Null（解析失败或空文档）
    public func isNull(): Bool { checkValid(); unsafe { qJsonDocumentIsNull(ptr) } }
    /// 文档是否为数组
    public func isArray(): Bool { checkValid(); unsafe { qJsonDocumentIsArray(ptr) } }
    /// 文档是否为对象
    public func isObject(): Bool { checkValid(); unsafe { qJsonDocumentIsObject(ptr) } }

    /// 获取文档根对象
    public func object(): QJsonObject {
        checkValid()
        let p = unsafe { qJsonDocumentObject(ptr) }
        QJsonObject(p)
    }

    /// 获取文档根数组
    public func array(): QJsonArray {
        checkValid()
        let p = unsafe { qJsonDocumentArray(ptr) }
        QJsonArray(p)
    }

    /// 获取底层指针
    public func getPtr(): Int64 { ptr }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) { unsafe { qJsonDocumentDelete(ptr) }; ptr = 0; closed = true }
    }
}
