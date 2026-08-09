package cjqt6.gui

import cjqt6.core.*

// ============================================================
// QSyntaxHighlighter - 语法高亮
// ============================================================

foreign func qSyntaxHighlighterCreate(selfId: Int64, docPtr: Int64): Int64
foreign func qSyntaxHighlighterDelete(ptr: Int64): Unit
foreign func qSyntaxHighlighterSetCallback(ptr: Int64, callback: CFunc<(Int64, CString) -> Unit>): Unit
foreign func qSyntaxHighlighterSetFormat(ptr: Int64, start: Int32, count: Int32, color: Int64, bold: Bool, italic: Bool, underline: Bool): Unit
foreign func qSyntaxHighlighterRehighlight(ptr: Int64): Unit
foreign func qSyntaxHighlighterDocument(ptr: Int64): Int64

/// 语法高亮器，为 QTextDocument 提供基于回调的语法高亮（用于代码编辑器）
public class QSyntaxHighlighter {
    private var ptr: Int64 = 0
    private var selfId: Int64 = 0
    private static var nextId: Int64 = 1
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) { throw ResourceDisposedException("QSyntaxHighlighter already deleted") }
        if (!isObjectAlive(ptr)) { throw ResourceDisposedException("QSyntaxHighlighter 底层 Qt 对象已失效") }
    }

    /// 创建语法高亮器，docPtr 为关联的 QTextDocument 指针
    public init(docPtr: Int64) {
        selfId = QSyntaxHighlighter.nextId
        QSyntaxHighlighter.nextId += 1
        unsafe {
            ptr = qSyntaxHighlighterCreate(selfId, docPtr)
            if (ptr == 0) { throw CreateFailedException("QSyntaxHighlighter create failed") }
        }
        trackObject(ptr)
    }

    /// 设置高亮回调（收到文本块内容后调用 setFormat 应用格式）
    public func setOnHighlight(callback: CFunc<(Int64, CString) -> Unit>): Unit {
        checkValid()
        unsafe { qSyntaxHighlighterSetCallback(ptr, callback) }
    }

    /// 设置文本格式（颜色/粗体/斜体/下划线），start 为起始位置，count 为长度
    public func setFormat(start: Int32, count: Int32, color: Int64, bold: Bool, italic: Bool, underline: Bool): Unit {
        checkValid()
        unsafe { qSyntaxHighlighterSetFormat(ptr, start, count, color, bold, italic, underline) }
    }

    /// 设置文本格式（仅颜色）
    public func setFormat(start: Int32, count: Int32, color: Int64): Unit {
        setFormat(start, count, color, false, false, false)
    }

    /// 重新高亮整个文档
    public func rehighlight(): Unit {
        checkValid()
        unsafe { qSyntaxHighlighterRehighlight(ptr) }
    }

    /// 获取关联文档指针
    public func document(): Int64 {
        checkValid()
        unsafe { qSyntaxHighlighterDocument(ptr) }
    }

    /// 获取底层指针
    public func getPtr(): Int64 { ptr }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            unsafe { qSyntaxHighlighterDelete(ptr) }
            ptr = 0; closed = true
        }
    }
}
