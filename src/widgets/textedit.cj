package cjqt6.widgets

import cjqt6.core.*

// QTextEdit - 多行文本编辑框
foreign func qTextEditCreate(): Int64
foreign func qTextEditSetText(ptr: Int64, text: CString): Unit
foreign func qTextEditText(ptr: Int64): CString
foreign func qTextEditSetReadOnly(ptr: Int64, readonly: Bool): Unit
foreign func qTextEditClear(ptr: Int64): Unit
foreign func qTextEditCut(ptr: Int64): Unit
foreign func qTextEditCopy(ptr: Int64): Unit
foreign func qTextEditPaste(ptr: Int64): Unit
foreign func qTextEditSelectAll(ptr: Int64): Unit
foreign func qTextEditCanPaste(ptr: Int64): Bool
foreign func qTextEditUndo(ptr: Int64): Unit
foreign func qTextEditRedo(ptr: Int64): Unit
foreign func qTextEditCanUndo(ptr: Int64): Bool
foreign func qTextEditCanRedo(ptr: Int64): Bool
foreign func qTextEditIsModified(ptr: Int64): Bool
foreign func qTextEditSetModified(ptr: Int64, modified: Bool): Unit
foreign func qTextEditSetLineWrapMode(ptr: Int64, mode: Int32): Unit
foreign func qTextEditLineWrapMode(ptr: Int64): Int32
foreign func qTextEditSetFontFamily(ptr: Int64, family: CString): Unit
foreign func qTextEditSetFontSize(ptr: Int64, size: Int32): Unit
foreign func qTextEditSetFontBold(ptr: Int64, bold: Bool): Unit
foreign func qTextEditSetFontItalic(ptr: Int64, italic: Bool): Unit
foreign func qTextEditFind(ptr: Int64, text: CString, caseSensitive: Bool): Bool
foreign func qTextEditFindNext(ptr: Int64, text: CString, caseSensitive: Bool): Unit
foreign func qTextEditFindPrev(ptr: Int64, text: CString, caseSensitive: Bool): Unit
foreign func qTextEditReplace(ptr: Int64, newText: CString): Unit
foreign func qTextEditReplaceAll(ptr: Int64, oldText: CString, newText: CString, caseSensitive: Bool): Int32
foreign func qTextEditLineCount(ptr: Int64): Int32
foreign func qTextEditCurrentLine(ptr: Int64): Int32
foreign func qTextEditCurrentColumn(ptr: Int64): Int32
foreign func qTextEditCharacterCount(ptr: Int64): Int32
foreign func qTextEditPrint(ptr: Int64, printerPtr: Int64): Unit
foreign func qTextEditGoToLine(ptr: Int64, line: Int32): Unit
foreign func qTextEditDelete(ptr: Int64): Unit
foreign func qTextEditSetHtml(ptr: Int64, html: CString): Unit
foreign func qTextEditToHtml(ptr: Int64): CString
foreign func qTextEditSetPlainText(ptr: Int64, text: CString): Unit
foreign func qTextEditToPlainText(ptr: Int64): CString
foreign func qTextEditAppend(ptr: Int64, text: CString): Unit
foreign func qTextEditInsertHtml(ptr: Int64, html: CString): Unit
foreign func qTextEditSetTextColor(ptr: Int64, r: Int32, g: Int32, b: Int32): Unit
foreign func qTextEditZoomIn(ptr: Int64, range: Int32): Unit
foreign func qTextEditZoomOut(ptr: Int64, range: Int32): Unit
foreign func qTextEditConnectTextChanged(ptr: Int64, callback: VoidCallback): Unit
foreign func qTextEditConnectUndoAvailable(ptr: Int64, callback: BoolCallback): Unit
foreign func qTextEditConnectRedoAvailable(ptr: Int64, callback: BoolCallback): Unit
foreign func qTextEditConnectCopyAvailable(ptr: Int64, callback: BoolCallback): Unit

public class QTextEdit {
    private let ptr: Int64
    
    public init() {
        unsafe {
            ptr = qTextEditCreate()
        }
    }
    
    public func show() {
        unsafe {
            qWidgetShow(ptr)
        }
    }
    
    public func hide() {
        unsafe {
            qWidgetHide(ptr)
        }
    }
    
    public func setText(text: String) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            qTextEditSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func text(): String {
        unsafe {
            let cstr = qTextEditText(ptr)
            let result = cstr.toString()
            // 注意：cstr指向静态缓冲区，不要free
            return result
        }
    }
    
    public func setReadOnly(readonly: Bool) {
        unsafe {
            qTextEditSetReadOnly(ptr, readonly)
        }
    }
    
    public func clear() {
        unsafe {
            qTextEditClear(ptr)
        }
    }
    
    public func cut() {
        unsafe {
            qTextEditCut(ptr)
        }
    }
    
    public func copy() {
        unsafe {
            qTextEditCopy(ptr)
        }
    }
    
    public func paste() {
        unsafe {
            qTextEditPaste(ptr)
        }
    }
    
    public func selectAll() {
        unsafe {
            qTextEditSelectAll(ptr)
        }
    }
    
    public func canPaste(): Bool {
        unsafe {
            qTextEditCanPaste(ptr)
        }
    }
    
    public func undo() {
        unsafe {
            qTextEditUndo(ptr)
        }
    }
    
    public func redo() {
        unsafe {
            qTextEditRedo(ptr)
        }
    }
    
    public func canUndo(): Bool {
        unsafe {
            qTextEditCanUndo(ptr)
        }
    }
    
    public func canRedo(): Bool {
        unsafe {
            qTextEditCanRedo(ptr)
        }
    }
    
    public func isModified(): Bool {
        unsafe {
            qTextEditIsModified(ptr)
        }
    }
    
    public func setModified(modified: Bool) {
        unsafe {
            qTextEditSetModified(ptr, modified)
        }
    }
    
    // LineWrapMode: 0 = NoWrap, 1 = WidgetWidth, 2 = ManualWidth
    public func setLineWrapMode(mode: Int32) {
        unsafe {
            qTextEditSetLineWrapMode(ptr, mode)
        }
    }
    
    public func lineWrapMode(): Int32 {
        unsafe {
            qTextEditLineWrapMode(ptr)
        }
    }
    
    public func setFontFamily(family: String) {
        unsafe {
            var cstr = LibC.mallocCString(family)
            qTextEditSetFontFamily(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setFontSize(size: Int32) {
        unsafe {
            qTextEditSetFontSize(ptr, size)
        }
    }
    
    public func setFontBold(bold: Bool) {
        unsafe {
            qTextEditSetFontBold(ptr, bold)
        }
    }
    
    public func setFontItalic(italic: Bool) {
        unsafe {
            qTextEditSetFontItalic(ptr, italic)
        }
    }
    
    // ==================== HTML / 纯文本 ====================
    
    /// 设置 HTML 内容
    public func setHtml(html: String) {
        unsafe {
            var cstr = LibC.mallocCString(html)
            qTextEditSetHtml(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取 HTML 内容
    public func toHtml(): String {
        unsafe {
            let cstr = qTextEditToHtml(ptr)
            return cstr.toString()
        }
    }
    
    /// 设置纯文本内容
    public func setPlainText(text: String) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            qTextEditSetPlainText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取纯文本内容
    public func toPlainText(): String {
        unsafe {
            let cstr = qTextEditToPlainText(ptr)
            return cstr.toString()
        }
    }
    
    /// 追加文本（自动添加换行）
    public func append(text: String) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            qTextEditAppend(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 在光标处插入 HTML 片段
    public func insertHtml(html: String) {
        unsafe {
            var cstr = LibC.mallocCString(html)
            qTextEditInsertHtml(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置当前文本颜色（RGB，0-255）
    public func setTextColor(r: Int32, g: Int32, b: Int32) {
        unsafe {
            qTextEditSetTextColor(ptr, r, g, b)
        }
    }
    
    /// 放大字体
    public func zoomIn(range: Int32) {
        unsafe {
            qTextEditZoomIn(ptr, range)
        }
    }
    
    /// 缩小字体
    public func zoomOut(range: Int32) {
        unsafe {
            qTextEditZoomOut(ptr, range)
        }
    }
    
    // ==================== 信号 ====================
    
    /// 文本内容变化回调
    public func setOnTextChanged(callback: VoidCallback) {
        unsafe {
            qTextEditConnectTextChanged(ptr, callback)
        }
    }
    
    /// 撤销可用性变化回调（参数: 是否可撤销）
    public func setOnUndoAvailable(callback: BoolCallback) {
        unsafe {
            qTextEditConnectUndoAvailable(ptr, callback)
        }
    }
    
    /// 重做可用性变化回调（参数: 是否可重做）
    public func setOnRedoAvailable(callback: BoolCallback) {
        unsafe {
            qTextEditConnectRedoAvailable(ptr, callback)
        }
    }
    
    /// 复制可用性变化回调（参数: 是否有选中内容可复制）
    public func setOnCopyAvailable(callback: BoolCallback) {
        unsafe {
            qTextEditConnectCopyAvailable(ptr, callback)
        }
    }
    
    // ==================== 查找功能 ====================
    
    // 查找文本，返回是否找到
    public func find(text: String, caseSensitive: Bool): Bool {
        unsafe {
            var cstr = LibC.mallocCString(text)
            let result = qTextEditFind(ptr, cstr, caseSensitive)
            LibC.free(cstr)
            return result
        }
    }
    
    // 查找下一个
    public func findNext(text: String, caseSensitive: Bool) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            qTextEditFindNext(ptr, cstr, caseSensitive)
            LibC.free(cstr)
        }
    }
    
    // 查找上一个
    public func findPrev(text: String, caseSensitive: Bool) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            qTextEditFindPrev(ptr, cstr, caseSensitive)
            LibC.free(cstr)
        }
    }
    
    // ==================== 替换功能 ====================
    
    // 替换当前选中内容
    public func replace(newText: String) {
        unsafe {
            var cstr = LibC.mallocCString(newText)
            qTextEditReplace(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    // 替换所有匹配项，返回替换数量
    public func replaceAll(oldText: String, newText: String, caseSensitive: Bool): Int32 {
        unsafe {
            var oldCstr = LibC.mallocCString(oldText)
            var newCstr = LibC.mallocCString(newText)
            let count = qTextEditReplaceAll(ptr, oldCstr, newCstr, caseSensitive)
            LibC.free(oldCstr)
            LibC.free(newCstr)
            return count
        }
    }
    
    // ==================== 光标位置 ====================
    
    // 获取总行数
    public func lineCount(): Int32 {
        unsafe {
            qTextEditLineCount(ptr)
        }
    }
    
    // 获取当前行号 (1-based)
    public func currentLine(): Int32 {
        unsafe {
            qTextEditCurrentLine(ptr)
        }
    }
    
    // 获取当前列号 (1-based)
    public func currentColumn(): Int32 {
        unsafe {
            qTextEditCurrentColumn(ptr)
        }
    }
    
    // 获取字符总数
    public func characterCount(): Int32 {
        unsafe {
            qTextEditCharacterCount(ptr)
        }
    }
    
    // 跳转到指定行
    public func goToLine(line: Int32) {
        unsafe {
            qTextEditGoToLine(ptr, line)
        }
    }
    
    // ==================== 打印功能 ====================
    
    // 打印文档
    public func print(printerPtr: Int64) {
        unsafe {
            qTextEditPrint(ptr, printerPtr)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }

    public func setMinimumSize(minw: Int32, minh: Int32) {
        unsafe {
            qWidgetSetMinimumSize(ptr, minw, minh)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    // 样式表支持
    public func setStyleSheet(style: String) {
        unsafe {
            var cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    // 兼容旧API
    public func setWidgetStyleSheet(style: String) {
        unsafe {
            var cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func widgetStyleSheet(): String {
        unsafe {
            let cstr = qWidgetStyleSheet(ptr)
            cstr.toString()
        }
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qTextEditDelete(ptr)
            }
        }
    }
}