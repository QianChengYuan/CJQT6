// ============================================================
// QQ局域网聊天 - 客户端协议工具
// JSON-line 帧的编码辅助与解析辅助。
// 解析基于 cjqt6.core 的 QJsonDocument 封装；
// 注意：每个 value()/object()/array() 返回的包装对象都需 close()。
// ============================================================
package qq_lan_client.core

import cjqt6.core.*

/// JSON 字符串转义（构造帧时使用）
public func escapeJson(s: String): String {
    var r = s
    r = r.replace("\\", "\\\\")
    r = r.replace("\"", "\\\"")
    r = r.replace("\n", "\\n")
    r = r.replace("\r", "\\r")
    r = r.replace("\t", "\\t")
    r
}

/// 解析一行 JSON 帧，返回根对象；解析失败返回 None
/// 调用方负责对返回的对象调用 close()
public func parseFrame(line: String): ?QJsonObject {
    let doc = QJsonDocument(line)
    if (doc.getPtr() == 0) {
        return None<QJsonObject>
    }
    if (!doc.isObject()) {
        doc.close()
        return None<QJsonObject>
    }
    let obj = doc.object()
    doc.close()
    return Some(obj)
}

/// 从对象取字符串字段（内部立即释放 QJsonValue）
public func jstr(obj: QJsonObject, key: String): String {
    let v = obj.value(key)
    let s = if (v.isString()) { v.toString() } else { "" }
    v.close()
    s
}

/// 从对象取整数字段
public func jint(obj: QJsonObject, key: String): Int64 {
    let v = obj.value(key)
    let n = v.toInt(0)
    v.close()
    n
}

/// 从对象取布尔字段
public func jbool(obj: QJsonObject, key: String): Bool {
    let v = obj.value(key)
    let b = v.toBool(false)
    v.close()
    b
}
