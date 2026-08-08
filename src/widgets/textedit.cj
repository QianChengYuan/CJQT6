package cjqt6.widgets

import cjqt6.core.*

// QTextEdit - 多行文本编辑框
// QTextEdit::QTextEdit() - 创建多行文本编辑框
foreign func qTextEditCreate(): Int64
// QTextEdit::setText() - 设置文本内容
foreign func qTextEditSetText(ptr: Int64, text: CString): Unit
// QTextEdit::toPlainText() - 获取文本内容
foreign func qTextEditText(ptr: Int64): CString
// QTextEdit::setReadOnly() - 设置只读模式
foreign func qTextEditSetReadOnly(ptr: Int64, readonly: Bool): Unit
// QTextEdit::clear() - 清除所有内容
foreign func qTextEditClear(ptr: Int64): Unit
// QTextEdit::cut() - 剪切选中内容
foreign func qTextEditCut(ptr: Int64): Unit
// QTextEdit::copy() - 复制选中内容
foreign func qTextEditCopy(ptr: Int64): Unit
// QTextEdit::paste() - 粘贴内容
foreign func qTextEditPaste(ptr: Int64): Unit
// QTextEdit::selectAll() - 全选
foreign func qTextEditSelectAll(ptr: Int64): Unit
// QTextEdit::canPaste() - 是否可以粘贴
foreign func qTextEditCanPaste(ptr: Int64): Bool
// QTextEdit::undo() - 撤销
foreign func qTextEditUndo(ptr: Int64): Unit
// QTextEdit::redo() - 重做
foreign func qTextEditRedo(ptr: Int64): Unit
// QTextEdit::canUndo() - 是否可以撤销
foreign func qTextEditCanUndo(ptr: Int64): Bool
// QTextEdit::canRedo() - 是否可以重做
foreign func qTextEditCanRedo(ptr: Int64): Bool
// QTextEdit::isModified() - 内容是否已修改
foreign func qTextEditIsModified(ptr: Int64): Bool
// QTextEdit::setModified() - 设置修改标记
foreign func qTextEditSetModified(ptr: Int64, modified: Bool): Unit
// QTextEdit::setLineWrapMode() - 设置换行模式
foreign func qTextEditSetLineWrapMode(ptr: Int64, mode: Int32): Unit
// QTextEdit::lineWrapMode() - 获取换行模式
foreign func qTextEditLineWrapMode(ptr: Int64): Int32
// QTextEdit::setFontFamily() - 设置字体族
foreign func qTextEditSetFontFamily(ptr: Int64, family: CString): Unit
// QTextEdit::setFontPointSize() - 设置字体大小
foreign func qTextEditSetFontSize(ptr: Int64, size: Int32): Unit
// QTextEdit::setFontWeight() - 设置字体粗体
foreign func qTextEditSetFontBold(ptr: Int64, bold: Bool): Unit
// QTextEdit::setFontItalic() - 设置字体斜体
foreign func qTextEditSetFontItalic(ptr: Int64, italic: Bool): Unit
// QTextEdit::find() - 查找文本
foreign func qTextEditFind(ptr: Int64, text: CString, caseSensitive: Bool): Bool
// QTextEdit::findNext() - 查找下一个
foreign func qTextEditFindNext(ptr: Int64, text: CString, caseSensitive: Bool): Unit
// QTextEdit::findPrev() - 查找上一个
foreign func qTextEditFindPrev(ptr: Int64, text: CString, caseSensitive: Bool): Unit
// QTextEdit::replace() - 替换当前选中内容
foreign func qTextEditReplace(ptr: Int64, newText: CString): Unit
// QTextEdit::replaceAll() - 替换所有匹配项
foreign func qTextEditReplaceAll(ptr: Int64, oldText: CString, newText: CString, caseSensitive: Bool): Int32
// QTextEdit::lineCount() - 获取总行数
foreign func qTextEditLineCount(ptr: Int64): Int32
// QTextEdit::currentLine() - 获取当前行号
foreign func qTextEditCurrentLine(ptr: Int64): Int32
// QTextEdit::currentColumn() - 获取当前列号
foreign func qTextEditCurrentColumn(ptr: Int64): Int32
// QTextEdit::characterCount() - 获取字符总数
foreign func qTextEditCharacterCount(ptr: Int64): Int32
// QTextEdit::print() - 打印文档
foreign func qTextEditPrint(ptr: Int64, printerPtr: Int64): Unit
// QTextEdit::goToLine() - 跳转到指定行
foreign func qTextEditGoToLine(ptr: Int64, line: Int32): Unit
// QTextEdit析构 - 删除控件
foreign func qTextEditDelete(ptr: Int64): Unit
// QTextEdit::setHtml() - 设置HTML内容
foreign func qTextEditSetHtml(ptr: Int64, html: CString): Unit
// QTextEdit::toHtml() - 获取HTML内容
foreign func qTextEditToHtml(ptr: Int64): CString
// QTextEdit::setPlainText() - 设置纯文本内容
foreign func qTextEditSetPlainText(ptr: Int64, text: CString): Unit
// QTextEdit::toPlainText() - 获取纯文本内容
foreign func qTextEditToPlainText(ptr: Int64): CString
// QTextEdit::append() - 追加文本
foreign func qTextEditAppend(ptr: Int64, text: CString): Unit
// QTextEdit::insertHtml() - 在光标处插入HTML片段
foreign func qTextEditInsertHtml(ptr: Int64, html: CString): Unit
// QTextEdit::setTextColor() - 设置文本颜色
foreign func qTextEditSetTextColor(ptr: Int64, r: Int32, g: Int32, b: Int32): Unit
// QTextEdit::zoomIn() - 放大字体
foreign func qTextEditZoomIn(ptr: Int64, range: Int32): Unit
// QTextEdit::zoomOut() - 缩小字体
foreign func qTextEditZoomOut(ptr: Int64, range: Int32): Unit
// QTextEdit::connectTextChanged() - 连接文本内容变化信号
foreign func qTextEditConnectTextChanged(ptr: Int64, callback: VoidCallback): Unit
// QTextEdit::connectUndoAvailable() - 连接撤销可用性变化信号
foreign func qTextEditConnectUndoAvailable(ptr: Int64, callback: BoolCallback): Unit
// QTextEdit::connectRedoAvailable() - 连接重做可用性变化信号
foreign func qTextEditConnectRedoAvailable(ptr: Int64, callback: BoolCallback): Unit
// QTextEdit::connectCopyAvailable() - 连接复制可用性变化信号
foreign func qTextEditConnectCopyAvailable(ptr: Int64, callback: BoolCallback): Unit

/// 多行文本编辑框部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QTextEdit <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init() {
        unsafe {
            ptr = qTextEditCreate()
        }
    }
    
    public func show() {
        checkValid()
        unsafe {
            qWidgetShow(ptr)
        }
    }
    
    public func hide() {
        checkValid()
        unsafe {
            qWidgetHide(ptr)
        }
    }
    
    public func setText(text: String) {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(text)
            qTextEditSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func text(): String {
        checkValid()
        unsafe {
            let cstr = qTextEditText(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    public func setReadOnly(readonly: Bool) {
        checkValid()
        unsafe {
            qTextEditSetReadOnly(ptr, readonly)
        }
    }
    
    public func clear() {
        checkValid()
        unsafe {
            qTextEditClear(ptr)
        }
    }
    
    public func cut() {
        checkValid()
        unsafe {
            qTextEditCut(ptr)
        }
    }
    
    public func copy() {
        checkValid()
        unsafe {
            qTextEditCopy(ptr)
        }
    }
    
    public func paste() {
        checkValid()
        unsafe {
            qTextEditPaste(ptr)
        }
    }
    
    public func selectAll() {
        checkValid()
        unsafe {
            qTextEditSelectAll(ptr)
        }
    }
    
    public func canPaste(): Bool {
        checkValid()
        unsafe {
            qTextEditCanPaste(ptr)
        }
    }
    
    public func undo() {
        checkValid()
        unsafe {
            qTextEditUndo(ptr)
        }
    }
    
    public func redo() {
        checkValid()
        unsafe {
            qTextEditRedo(ptr)
        }
    }
    
    public func canUndo(): Bool {
        checkValid()
        unsafe {
            qTextEditCanUndo(ptr)
        }
    }
    
    public func canRedo(): Bool {
        checkValid()
        unsafe {
            qTextEditCanRedo(ptr)
        }
    }
    
    public func isModified(): Bool {
        checkValid()
        unsafe {
            qTextEditIsModified(ptr)
        }
    }
    
    public func setModified(modified: Bool) {
        checkValid()
        unsafe {
            qTextEditSetModified(ptr, modified)
        }
    }
    
    public func setLineWrapMode(mode: Int32) {
        checkValid()
        unsafe {
            qTextEditSetLineWrapMode(ptr, mode)
        }
    }
    
    public func lineWrapMode(): Int32 {
        checkValid()
        unsafe {
            qTextEditLineWrapMode(ptr)
        }
    }
    
    public func setFontFamily(family: String) {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(family)
            qTextEditSetFontFamily(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setFontSize(size: Int32) {
        checkValid()
        unsafe {
            qTextEditSetFontSize(ptr, size)
        }
    }
    
    public func setFontBold(bold: Bool) {
        checkValid()
        unsafe {
            qTextEditSetFontBold(ptr, bold)
        }
    }
    
    public func setFontItalic(italic: Bool) {
        checkValid()
        unsafe {
            qTextEditSetFontItalic(ptr, italic)
        }
    }
    
    /// 设置 HTML 内容
    public func setHtml(html: String) {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(html)
            qTextEditSetHtml(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取 HTML 内容
    public func toHtml(): String {
        checkValid()
        unsafe {
            let cstr = qTextEditToHtml(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    /// 设置纯文本内容
    public func setPlainText(text: String) {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(text)
            qTextEditSetPlainText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取纯文本内容
    public func toPlainText(): String {
        checkValid()
        unsafe {
            let cstr = qTextEditToPlainText(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    /// 追加文本（自动添加换行）
    public func append(text: String) {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(text)
            qTextEditAppend(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 在光标处插入 HTML 片段
    public func insertHtml(html: String) {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(html)
            qTextEditInsertHtml(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置当前文本颜色（RGB，0-255）
    public func setTextColor(r: Int32, g: Int32, b: Int32) {
        checkValid()
        unsafe {
            qTextEditSetTextColor(ptr, r, g, b)
        }
    }
    
    /// 放大字体
    public func zoomIn(range: Int32) {
        checkValid()
        unsafe {
            qTextEditZoomIn(ptr, range)
        }
    }
    
    /// 缩小字体
    public func zoomOut(range: Int32) {
        checkValid()
        unsafe {
            qTextEditZoomOut(ptr, range)
        }
    }
    
    /// 文本内容变化回调
    public func setOnTextChanged(callback: VoidCallback) {
        checkValid()
        unsafe {
            qTextEditConnectTextChanged(ptr, callback)
        }
    }
    
    /// 撤销可用性变化回调（参数: 是否可撤销）
    public func setOnUndoAvailable(callback: BoolCallback) {
        checkValid()
        unsafe {
            qTextEditConnectUndoAvailable(ptr, callback)
        }
    }
    
    /// 重做可用性变化回调（参数: 是否可重做）
    public func setOnRedoAvailable(callback: BoolCallback) {
        checkValid()
        unsafe {
            qTextEditConnectRedoAvailable(ptr, callback)
        }
    }
    
    /// 复制可用性变化回调（参数: 是否有选中内容可复制）
    public func setOnCopyAvailable(callback: BoolCallback) {
        checkValid()
        unsafe {
            qTextEditConnectCopyAvailable(ptr, callback)
        }
    }
    
    /// 查找文本，返回是否找到
    public func find(text: String, caseSensitive: Bool): Bool {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(text)
            let result = qTextEditFind(ptr, cstr, caseSensitive)
            LibC.free(cstr)
            return result
        }
    }
    
    /// 查找下一个
    public func findNext(text: String, caseSensitive: Bool) {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(text)
            qTextEditFindNext(ptr, cstr, caseSensitive)
            LibC.free(cstr)
        }
    }
    
    /// 查找上一个
    public func findPrev(text: String, caseSensitive: Bool) {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(text)
            qTextEditFindPrev(ptr, cstr, caseSensitive)
            LibC.free(cstr)
        }
    }
    
    /// 替换当前选中内容
    public func replace(newText: String) {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(newText)
            qTextEditReplace(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 替换所有匹配项，返回替换数量
    public func replaceAll(oldText: String, newText: String, caseSensitive: Bool): Int32 {
        checkValid()
        unsafe {
            var oldCstr = LibC.mallocCString(oldText)
            var newCstr = LibC.mallocCString(newText)
            let count = qTextEditReplaceAll(ptr, oldCstr, newCstr, caseSensitive)
            LibC.free(oldCstr)
            LibC.free(newCstr)
            return count
        }
    }
    
    /// 获取总行数
    public func lineCount(): Int32 {
        checkValid()
        unsafe {
            qTextEditLineCount(ptr)
        }
    }
    
    /// 获取当前行号 (1-based)
    public func currentLine(): Int32 {
        checkValid()
        unsafe {
            qTextEditCurrentLine(ptr)
        }
    }
    
    /// 获取当前列号 (1-based)
    public func currentColumn(): Int32 {
        checkValid()
        unsafe {
            qTextEditCurrentColumn(ptr)
        }
    }
    
    /// 获取字符总数
    public func characterCount(): Int32 {
        checkValid()
        unsafe {
            qTextEditCharacterCount(ptr)
        }
    }
    
    /// 跳转到指定行
    public func goToLine(line: Int32) {
        checkValid()
        unsafe {
            qTextEditGoToLine(ptr, line)
        }
    }
    
    /// 打印文档
    public func print(printerPtr: Int64) {
        checkValid()
        unsafe {
            qTextEditPrint(ptr, printerPtr)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }

    public func setMinimumSize(minw: Int32, minh: Int32) {
        checkValid()
        unsafe {
            qWidgetSetMinimumSize(ptr, minw, minh)
        }
    }
    
    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 是否已关闭
    public func isClosed(): Bool {
        return closed
    }
    
    /// 检查对象有效性
    public func isValid(): Bool {
        return !closed && ptr != 0
    }
    
    /// 检查有效性，无效时抛出异常
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QTextEdit 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QTextEdit 指针为空")
        }
    }
    
    /// 关闭资源，释放Qt对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qTextEditDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除文本编辑框（兼容旧API）
    public func delete(): Unit {
        close()
    }
    
    /// 设置样式表
    public func setStyleSheet(style: String) {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 兼容旧API
    @Deprecated[message: "请使用 setStyleSheet 代替"]
    public func setWidgetStyleSheet(style: String) {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func widgetStyleSheet(): String {
        checkValid()
        unsafe {
            let cstr = qWidgetStyleSheet(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            result
        }
    }
    
    /// 设置启用状态
    public func setEnabled(enabled: Bool): Unit {
        checkValid()
        unsafe {
            qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }
    
    /// 是否启用
    public func isEnabled(): Bool {
        checkValid()
        unsafe {
            return qWidgetIsEnabled(ptr) == 1
        }
    }
    
    /// 设置工具提示
    public func setToolTip(toolTip: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(toolTip)
            qWidgetSetToolTip(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置可见性
    public func setVisible(visible: Bool): Unit {
        checkValid()
        unsafe {
            qWidgetSetVisible(ptr, if (visible) { 1 } else { 0 })
        }
    }
    
    /// 是否可见
    public func isVisible(): Bool {
        checkValid()
        unsafe {
            return qWidgetIsVisible(ptr) == 1
        }
    }
    
    /// 获取宽度
    public func width(): Int32 {
        checkValid()
        unsafe {
            return qWidgetWidth(ptr)
        }
    }
    
    /// 获取高度
    public func height(): Int32 {
        checkValid()
        unsafe {
            return qWidgetHeight(ptr)
        }
    }
    
    /// 设置最大尺寸
    public func setMaximumSize(maxw: Int32, maxh: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetSetMaximumSize(ptr, maxw, maxh)
        }
    }
}