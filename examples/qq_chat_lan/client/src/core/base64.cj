// ============================================================
// QQ局域网聊天 - 客户端 base64 工具
// 标准 RFC4648 编码/解码，用于文件分块传输。
// 服务端仅透传 base64 字符串，无需解码。
// ============================================================
package qq_lan_client.core

let B64_TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

/// base64 编码：预分配输出数组，避免反复拼接
public func base64Encode(data: Array<Byte>): String {
    let outLen = ((data.size + 2) / 3) * 4
    if (outLen == 0) { return "" }
    var out = Array<Byte>(outLen, repeat: 0)
    var i: Int64 = 0
    var o: Int64 = 0
    while (i < data.size) {
        let b0 = Int64(data[i])
        let has1 = i + 1 < data.size
        let has2 = i + 2 < data.size
        let b1 = if (has1) { Int64(data[i + 1]) } else { 0 }
        let b2 = if (has2) { Int64(data[i + 2]) } else { 0 }
        out[o] = UInt8(UInt32(B64_TABLE[b0 >> 2]))
        out[o + 1] = UInt8(UInt32(B64_TABLE[((b0 & 3) << 4) | (b1 >> 4)]))
        if (has1) {
            out[o + 2] = UInt8(UInt32(B64_TABLE[((b1 & 15) << 2) | (b2 >> 6)]))
        } else {
            out[o + 2] = UInt8(61)
        }
        if (has2) {
            out[o + 3] = UInt8(UInt32(B64_TABLE[b2 & 63]))
        } else {
            out[o + 3] = UInt8(61)
        }
        i = i + 3
        o = o + 4
    }
    String.fromUtf8(out)
}

/// 单字符解码值（ASCII），非法返回 -1
func b64Value(c: Byte): Int64 {
    let v = Int64(c)
    if (v >= 65 && v <= 90) { return v - 65 }        // A-Z
    if (v >= 97 && v <= 122) { return v - 71 }       // a-z
    if (v >= 48 && v <= 57) { return v + 4 }         // 0-9
    if (v == 43) { return 62 }                       // +
    if (v == 47) { return 63 }                       // /
    -1
}

/// base64 解码：忽略填充符 '='；非法字符跳过
public func base64Decode(text: String): Array<Byte> {
    let src = text.toArray()
    // 有效字符数
    var valid: Int64 = 0
    for (c in src) {
        if (b64Value(c) >= 0) { valid++ }
    }
    let outLen = (valid * 6) / 8
    var out = Array<Byte>(outLen, repeat: 0)
    var acc: Int64 = 0
    var bits: Int64 = 0
    var o: Int64 = 0
    for (c in src) {
        let v = b64Value(c)
        if (v < 0) { continue }
        acc = (acc << 6) | v
        bits = bits + 6
        if (bits >= 8) {
            bits = bits - 8
            if (o < outLen) {
                out[o] = UInt8((acc >> bits) & 255)
                o++
            }
        }
    }
    out
}
