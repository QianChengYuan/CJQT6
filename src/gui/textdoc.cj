package cjqt6.gui

import cjqt6.core.*

// ============================================================
// QTextDocument FFI
// ============================================================

foreign func qTextDocumentCreate(): Int64
foreign func qTextDocumentCreateWithText(text: CString): Int64
foreign func qTextDocumentDelete(ptr: Int64): Unit
foreign func qTextDocumentSetPlainText(ptr: Int64, text: CString): Unit
foreign func qTextDocumentToPlainText(ptr: Int64): CString
foreign func qTextDocumentSetHtml(ptr: Int64, html: CString): Unit
foreign func qTextDocumentToHtml(ptr: Int64): CString
foreign func qTextDocumentBlockCount(ptr: Int64): Int32
foreign func qTextDocumentLineCount(ptr: Int64): Int32
foreign func qTextDocumentCharacterCount(ptr: Int64): Int32
foreign func qTextDocumentPageCount(ptr: Int64): Int32
foreign func qTextDocumentIsEmpty(ptr: Int64): Bool
foreign func qTextDocumentIsModified(ptr: Int64): Bool
foreign func qTextDocumentSetModified(ptr: Int64, modified: Bool): Unit
foreign func qTextDocumentSetDefaultFont(ptr: Int64, family: CString, pointSize: Int32): Unit
foreign func qTextDocumentClear(ptr: Int64): Unit

// ============================================================
// QTextCursor FFI
// ============================================================

foreign func qTextCursorCreate(docPtr: Int64): Int64
foreign func qTextCursorDelete(ptr: Int64): Unit
foreign func qTextCursorPosition(ptr: Int64): Int32
foreign func qTextCursorSetPosition(ptr: Int64, pos: Int32): Unit
foreign func qTextCursorAnchor(ptr: Int64): Int32
foreign func qTextCursorInsertText(ptr: Int64, text: CString): Unit
foreign func qTextCursorMovePosition(ptr: Int64, operation: Int32, mode: Int32, count: Int32): Bool
foreign func qTextCursorSelect(ptr: Int64, operation: Int32): Unit
foreign func qTextCursorSelectedText(ptr: Int64): CString
foreign func qTextCursorClearSelection(ptr: Int64): Unit
foreign func qTextCursorHasSelection(ptr: Int64): Bool
foreign func qTextCursorRemoveSelectedText(ptr: Int64): Unit
foreign func qTextCursorDeleteChar(ptr: Int64): Unit
foreign func qTextCursorDeletePreviousChar(ptr: Int64): Unit
foreign func qTextCursorInsertNewBlock(ptr: Int64): Unit
foreign func qTextCursorIsNull(ptr: Int64): Bool
foreign func qTextCursorBlockNumber(ptr: Int64): Int32
foreign func qTextCursorColumnNumber(ptr: Int64): Int32


// ============================================================
// 光标移动操作常量
// ============================================================
public class MoveOperation {
    public static func noMove(): Int32 { 0 }
    public static func start(): Int32 { 1 }
    public static func up(): Int32 { 2 }
    public static func startOfLine(): Int32 { 3 }
    public static func startOfBlock(): Int32 { 4 }
    public static func startOfWord(): Int32 { 5 }
    public static func previousBlock(): Int32 { 6 }
    public static func previousCharacter(): Int32 { 7 }
    public static func previousWord(): Int32 { 8 }
    public static func left(): Int32 { 9 }
    public static func wordLeft(): Int32 { 10 }
    public static func end(): Int32 { 11 }
    public static func down(): Int32 { 12 }
    public static func endOfLine(): Int32 { 13 }
    public static func endOfWord(): Int32 { 14 }
    public static func endOfBlock(): Int32 { 15 }
    public static func nextBlock(): Int32 { 16 }
    public static func nextCharacter(): Int32 { 17 }
    public static func nextWord(): Int32 { 18 }
    public static func right(): Int32 { 19 }
    public static func wordRight(): Int32 { 20 }
    public static func nextCell(): Int32 { 21 }
    public static func previousCell(): Int32 { 22 }
    public static func nextRow(): Int32 { 23 }
    public static func previousRow(): Int32 { 24 }
}

// ============================================================
// 光标移动模式
// ============================================================
public class MoveMode {
    public static func moveAnchor(): Int32 { 0 }
    public static func keepAnchor(): Int32 { 1 }
}


// ============================================================
// QTextDocument - 富文本文档
// ============================================================
public class QTextDocument {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QTextDocument already deleted")
        }
    }

    public init() {
        unsafe {
            ptr = qTextDocumentCreate()
            if (ptr == 0) {
                throw CreateFailedException("QTextDocument create failed")
            }
        }
    }

    public init(text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            ptr = qTextDocumentCreateWithText(cstr)
            LibC.free(cstr)
            if (ptr == 0) {
                throw CreateFailedException("QTextDocument create failed")
            }
        }
    }

    public func setPlainText(text: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            qTextDocumentSetPlainText(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func toPlainText(): String {
        checkValid()
        unsafe {
            let cstr = qTextDocumentToPlainText(ptr)
            return cstr.toString()
        }
    }

    public func setHtml(html: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(html)
            qTextDocumentSetHtml(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func toHtml(): String {
        checkValid()
        unsafe {
            let cstr = qTextDocumentToHtml(ptr)
            return cstr.toString()
        }
    }

    public func blockCount(): Int32 {
        checkValid()
        unsafe { qTextDocumentBlockCount(ptr) }
    }

    public func lineCount(): Int32 {
        checkValid()
        unsafe { qTextDocumentLineCount(ptr) }
    }

    public func characterCount(): Int32 {
        checkValid()
        unsafe { qTextDocumentCharacterCount(ptr) }
    }

    public func pageCount(): Int32 {
        checkValid()
        unsafe { qTextDocumentPageCount(ptr) }
    }

    public func isEmpty(): Bool {
        checkValid()
        unsafe { qTextDocumentIsEmpty(ptr) }
    }

    public func isModified(): Bool {
        checkValid()
        unsafe { qTextDocumentIsModified(ptr) }
    }

    public func setModified(modified: Bool): Unit {
        checkValid()
        unsafe { qTextDocumentSetModified(ptr, modified) }
    }

    public func setDefaultFont(family: String, pointSize: Int32): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(family)
            qTextDocumentSetDefaultFont(ptr, cstr, pointSize)
            LibC.free(cstr)
        }
    }

    public func clear(): Unit {
        checkValid()
        unsafe { qTextDocumentClear(ptr) }
    }

    public func getPtr(): Int64 { ptr }

    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe { qTextDocumentDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}

// ============================================================
// QTextCursor - 文本光标
// ============================================================
public class QTextCursor {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QTextCursor already deleted")
        }
    }

    public init(doc: QTextDocument) {
        unsafe {
            ptr = qTextCursorCreate(doc.getPtr())
            if (ptr == 0) {
                throw CreateFailedException("QTextCursor create failed")
            }
        }
    }

    public func position(): Int32 {
        checkValid()
        unsafe { qTextCursorPosition(ptr) }
    }

    public func setPosition(pos: Int32): Unit {
        checkValid()
        unsafe { qTextCursorSetPosition(ptr, pos) }
    }

    public func anchor(): Int32 {
        checkValid()
        unsafe { qTextCursorAnchor(ptr) }
    }

    public func insertText(text: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            qTextCursorInsertText(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 移动光标位置
    public func movePosition(operation: Int32): Bool {
        checkValid()
        unsafe { qTextCursorMovePosition(ptr, operation, MoveMode.moveAnchor(), 1) }
    }

    /// 移动光标位置（指定模式和次数）
    public func movePositionEx(operation: Int32, mode: Int32, count: Int32): Bool {
        checkValid()
        unsafe { qTextCursorMovePosition(ptr, operation, mode, count) }
    }

    public func select(operation: Int32): Unit {
        checkValid()
        unsafe { qTextCursorSelect(ptr, operation) }
    }

    public func selectedText(): String {
        checkValid()
        unsafe {
            let cstr = qTextCursorSelectedText(ptr)
            return cstr.toString()
        }
    }

    public func clearSelection(): Unit {
        checkValid()
        unsafe { qTextCursorClearSelection(ptr) }
    }

    public func hasSelection(): Bool {
        checkValid()
        unsafe { qTextCursorHasSelection(ptr) }
    }

    public func removeSelectedText(): Unit {
        checkValid()
        unsafe { qTextCursorRemoveSelectedText(ptr) }
    }

    public func deleteChar(): Unit {
        checkValid()
        unsafe { qTextCursorDeleteChar(ptr) }
    }

    public func deletePreviousChar(): Unit {
        checkValid()
        unsafe { qTextCursorDeletePreviousChar(ptr) }
    }

    public func insertNewBlock(): Unit {
        checkValid()
        unsafe { qTextCursorInsertNewBlock(ptr) }
    }

    public func isNull(): Bool {
        checkValid()
        unsafe { qTextCursorIsNull(ptr) }
    }

    public func blockNumber(): Int32 {
        checkValid()
        unsafe { qTextCursorBlockNumber(ptr) }
    }

    public func columnNumber(): Int32 {
        checkValid()
        unsafe { qTextCursorColumnNumber(ptr) }
    }

    public func getPtr(): Int64 { ptr }

    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe { qTextCursorDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
