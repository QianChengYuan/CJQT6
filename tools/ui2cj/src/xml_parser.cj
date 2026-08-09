// ============================================================
// xml_parser.cj — 轻量 XML DOM 解析器（仅覆盖 Qt Designer .ui 固定格式）
//
// 设计取舍：
//   - 不依赖任何第三方 XML 库（无需 libxml2 / stdx），纯仓颉实现；
//   - 针对 Qt Designer 输出的良构 XML 子集实现，不做完整 XML 标准；
//   - 支持：XML 声明、注释、标签/属性/文本、自闭合标签、实体解码
//     （&amp; &lt; &gt; &quot; &apos; 及 &#NN; / &#xNN; 数字实体）；
//   - String 按 UTF-8 字节索引，切片只在 ASCII 边界进行，避免切断中文。
// ============================================================

package Ui2Cj

import std.collection.*
import std.convert.*

// ------------------------------------------------------------
// 解析结果节点：标签名 + 属性 + 子节点 + 直系文本
// ------------------------------------------------------------
public class XmlNode {
    public var tag: String
    public var attrs: HashMap<String, String>
    public var children: ArrayList<XmlNode>
    public var text: String

    public init() {
        tag = ""
        attrs = HashMap<String, String>()
        children = ArrayList<XmlNode>()
        text = ""
    }

    public func attr(name: String): String {
        let v = attrs.get(name)
        if (let Some(val) <- v) {
            val
        } else {
            ""
        }
    }

    public func findChild(tagName: String): ?XmlNode {
        for (c in children) {
            if (c.tag == tagName) {
                return c
            }
        }
        return None
    }

    public func findChildren(tagName: String): ArrayList<XmlNode> {
        var out = ArrayList<XmlNode>()
        for (c in children) {
            if (c.tag == tagName) {
                out.add(c)
            }
        }
        return out
    }
}

// ------------------------------------------------------------
// 字节流扫描器
// ------------------------------------------------------------
class XmlScanner {
    let src: String
    var pos: Int64

    init(src: String) {
        this.src = src
        pos = 0
    }

    public func eof(): Bool {
        pos >= src.size
    }

    public func peek(): Byte {
        if (eof()) {
            b' '
        } else {
            src[pos]
        }
    }

    public func startsWith(prefix: String, at: Int64): Bool {
        if (at + prefix.size > src.size) {
            return false
        }
        src[at..at + prefix.size] == prefix
    }

    // 跳到指定子串之后；找不到则返回 false
    public func skipTo(marker: String): Bool {
        let idx = src.indexOf(marker, pos)
        if (let Some(i) <- idx) {
            pos = i + marker.size
            return true
        }
        pos = src.size
        return false
    }

    public func skipWhitespace(): Unit {
        while (!eof()) {
            let c = peek()
            if (c == b' ' || c == b'\t' || c == b'\n' || c == b'\r') {
                pos++
            } else {
                break
            }
        }
    }
}

// ------------------------------------------------------------
// 轻量解析器
// ------------------------------------------------------------
public func parseXml(src: String): XmlNode {
    let p = XmlParser(src)
    return p.parse()
}

class XmlParser {
    let scanner: XmlScanner

    init(src: String) {
        scanner = XmlScanner(src)
    }

    public func parse(): XmlNode {
        skipMisc()
        if (scanner.eof()) {
            throw Exception("xml: empty input")
        }
        return parseElement()
    }

    // 跳过开头的 XML 声明 / 注释 / DOCTYPE / 空白
    func skipMisc(): Unit {
        while (!scanner.eof()) {
            if (scanner.startsWith("<?", scanner.pos)) {
                scanner.skipTo("?>")
            } else if (scanner.startsWith("<!--", scanner.pos)) {
                scanner.skipTo("-->")
            } else if (scanner.startsWith("<!DOCTYPE", scanner.pos)) {
                scanner.skipTo(">")
            } else {
                let c = scanner.peek()
                if (c == b' ' || c == b'\t' || c == b'\n' || c == b'\r') {
                    scanner.pos++
                } else {
                    break
                }
            }
        }
    }

    // 解析一个元素（调用前 scanner.pos 指向 '<'）
    func parseElement(): XmlNode {
        if (scanner.peek() != b'<') {
            throw Exception("xml: expected '<' at pos ${scanner.pos}")
        }
        scanner.pos++
        scanner.skipWhitespace()

        let node = XmlNode()
        // 标签名
        let nameStart = scanner.pos
        while (!scanner.eof()) {
            let c = scanner.peek()
            if (c == b' ' || c == b'\t' || c == b'\n' || c == b'\r' ||
                c == b'>' || c == b'/') {
                break
            }
            scanner.pos++
        }
        node.tag = scanner.src[nameStart..scanner.pos]

        var selfClosed = parseAttrs(node)

        if (selfClosed) {
            return node
        }

        // 子节点与文本
        parseContent(node)
        return node
    }

    // 解析属性直到 '>'；返回是否为自闭合标签
    func parseAttrs(node: XmlNode): Bool {
        while (true) {
            scanner.skipWhitespace()
            if (scanner.eof()) {
                throw Exception("xml: unexpected end in tag <${node.tag}>")
            }
            let c = scanner.peek()
            if (c == b'>') {
                scanner.pos++
                return false
            }
            if (c == b'/') {
                if (scanner.pos + 1 < scanner.src.size && scanner.src[scanner.pos + 1] == b'>') {
                    scanner.pos += 2
                    return true
                }
                // 单个 '/' 异常，跳过
                scanner.pos++
                continue
            }
            // 属性名
            let aStart = scanner.pos
            while (!scanner.eof()) {
                let cc = scanner.peek()
                if (cc == b'=' || cc == b' ' || cc == b'\t' || cc == b'\n' ||
                    cc == b'\r' || cc == b'>' || cc == b'/') {
                    break
                }
                scanner.pos++
            }
            let attrName = scanner.src[aStart..scanner.pos]
            scanner.skipWhitespace()
            if (scanner.eof()) {
                throw Exception("xml: unterminated attribute in <${node.tag}>")
            }
            if (scanner.peek() == b'=') {
                scanner.pos++
                scanner.skipWhitespace()
                if (scanner.eof()) {
                    throw Exception("xml: missing attribute value for '${attrName}'")
                }
                let q = scanner.peek()
                if (q != b'"' && q != b'\'') {
                    throw Exception("xml: attribute value must be quoted: '${attrName}'")
                }
                scanner.pos++
                let vStart = scanner.pos
                while (!scanner.eof()) {
                    if (scanner.peek() == q) {
                        break
                    }
                    scanner.pos++
                }
                if (scanner.eof()) {
                    throw Exception("xml: unterminated attribute value for '${attrName}'")
                }
                let raw = scanner.src[vStart..scanner.pos]
                scanner.pos++
                node.attrs[attrName] = decodeEntities(raw)
            } else {
                // 无值属性（如 <item/> 少见），赋空串
                node.attrs[attrName] = ""
            }
        }
        return false
    }

    // 解析元素内容：子标签 + 文本
    func parseContent(node: XmlNode): Unit {
        let textBuf = StringBuilder()
        while (!scanner.eof()) {
            if (scanner.peek() == b'<') {
                // 结束标签
                if (scanner.startsWith("</", scanner.pos)) {
                    scanner.pos += 2
                    scanner.skipWhitespace()
                    while (!scanner.eof()) {
                        let c = scanner.peek()
                        if (c == b'>') {
                            break
                        }
                        scanner.pos++
                    }
                    if (scanner.eof()) {
                        throw Exception("xml: unterminated close tag </${node.tag}>")
                    }
                    scanner.pos++
                    break
                }
                // 注释
                if (scanner.startsWith("<!--", scanner.pos)) {
                    scanner.skipTo("-->")
                    continue
                }
                // 声明/处理指令
                if (scanner.startsWith("<?", scanner.pos)) {
                    scanner.skipTo("?>")
                    continue
                }
                // 子元素
                let child = parseElement()
                node.children.add(child)
            } else {
                // 普通文本：收集到下一个 '<'
                let lt = scanner.src.indexOf("<", scanner.pos)
                let end = if (let Some(i) <- lt) { i } else { scanner.src.size }
                if (end > scanner.pos) {
                    textBuf.append(scanner.src[scanner.pos..end])
                    scanner.pos = end
                } else {
                    scanner.pos++
                }
            }
        }
        node.text = decodeEntities(textBuf.toString())
    }
}

// ------------------------------------------------------------
// XML 实体解码
// ------------------------------------------------------------
func decodeEntities(input: String): String {
    if (!input.contains("&")) {
        return input
    }
    var result = StringBuilder()
    var i: Int64 = 0
    while (i < input.size) {
        if (input[i] == b'&') {
            let semi = input.indexOf(";", i)
            if (let Some(s) <- semi) {
                let ent = input[i..s]
                result.append(decodeEntity(ent))
                i = s + 1
            } else {
                result.append(input[i])
                i++
            }
        } else {
            result.append(input[i])
            i++
        }
    }
    return result.toString()
}

func decodeEntity(ent: String): String {
    if (ent == "&amp;") { return "&" }
    if (ent == "&lt;") { return "<" }
    if (ent == "&gt;") { return ">" }
    if (ent == "&quot;") { return "\"" }
    if (ent == "&apos;") { return "'" }
    // 数字实体 &#NN; 或 &#xNN;
    if (ent.startsWith("&#")) {
        let body = ent[2..]
        if (body.startsWith("x") || body.startsWith("X")) {
            let hex = body[1..]
            if (let Some(n) <- Int64.tryParse(hex, radix: 16)) {
                return runeToString(n)
            }
        } else if (let Some(n) <- Int64.tryParse(body)) {
            return runeToString(n)
        }
    }
    return ent
}

func runeToString(codePoint: Int64): String {
    if (codePoint < 0 || codePoint > 0x10FFFF) {
        return ""
    }
    let r = Rune(codePoint)
    return String([r])
}
