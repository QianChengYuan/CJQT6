package cjqt6.widgets

import cjqt6.core.*

// QPlainTextEdit - 纯文本编辑器
foreign func qPlainTextEditCreate(): Int64
foreign func qPlainTextEditSetPlainText(ptr: Int64, text: CString): Unit
foreign func qPlainTextEditToPlainText(ptr: Int64): CString
foreign func qPlainTextEditSetReadOnly(ptr: Int64, readonly: Bool): Unit
foreign func qPlainTextEditIsReadOnly(ptr: Int64): Bool
foreign func qPlainTextEditClear(ptr: Int64): Unit
foreign func qPlainTextEditCut(ptr: Int64): Unit
foreign func qPlainTextEditCopy(ptr: Int64): Unit
foreign func qPlainTextEditPaste(ptr: Int64): Unit
foreign func qPlainTextEditSelectAll(ptr: Int64): Unit
foreign func qPlainTextEditUndo(ptr: Int64): Unit
foreign func qPlainTextEditRedo(ptr: Int64): Unit
foreign func qPlainTextEditCanUndo(ptr: Int64): Bool
foreign func qPlainTextEditCanRedo(ptr: Int64): Bool
foreign func qPlainTextEditIsModified(ptr: Int64): Bool
foreign func qPlainTextEditSetModified(ptr: Int64, modified: Bool): Unit
foreign func qPlainTextEditSetLineWrapMode(ptr: Int64, mode: Int32): Unit
foreign func qPlainTextEditLineWrapMode(ptr: Int64): Int32
foreign func qPlainTextEditSetTabStopDistance(ptr: Int64, distance: Float64): Unit
foreign func qPlainTextEditLineCount(ptr: Int64): Int64
foreign func qPlainTextEditAppendPlainText(ptr: Int64, text: CString): Unit
foreign func qPlainTextEditSetMaximumBlockCount(ptr: Int64, maxBlocks: Int32): Unit
foreign func qPlainTextEditAppendHtml(ptr: Int64, html: CString): Unit
foreign func qPlainTextEditZoomIn(ptr: Int64, range: Int32): Unit
foreign func qPlainTextEditZoomOut(ptr: Int64, range: Int32): Unit
foreign func qPlainTextEditBlockCount(ptr: Int64): Int32
foreign func qPlainTextEditConnectTextChanged(ptr: Int64, callback: VoidCallback): Unit
foreign func qPlainTextEditConnectBlockCountChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qPlainTextEditConnectModificationChanged(ptr: Int64, callback: BoolCallback): Unit
foreign func qPlainTextEditConnectCopyAvailable(ptr: Int64, callback: BoolCallback): Unit
foreign func qPlainTextEditDelete(ptr: Int64): Unit

/// 换行模式常量
public class PlainTextLineWrap {
    public static let NoWrap: Int32 = 0        // 不换行
    public static let WidgetWidth: Int32 = 1   // 按控件宽度换行
}

/// 纯文本编辑器
/// 比 QTextEdit 更轻量，适合代码编辑、日志查看等场景
public class QPlainTextEdit {
    private var ptr: Int64 = 0

    public init(parent!: Int64 = 0) {
        unsafe {
            ptr = qPlainTextEditCreate()
            if (parent != 0) {
                setWidgetParent(ptr, parent)
            }
        }
    }

    /// 显示
    public func show(): Unit {
        unsafe {
            qWidgetShow(ptr)
        }
    }

    /// 隐藏
    public func hide(): Unit {
        unsafe {
            qWidgetHide(ptr)
        }
    }

    /// 调整大小
    public func resize(width: Int32, height: Int32): Unit {
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }

    /// 设置样式表
    public func setStyleSheet(style: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置纯文本内容
    public func setPlainText(text: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qPlainTextEditSetPlainText(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取纯文本内容
    public func toPlainText(): String {
        unsafe {
            let cstr = qPlainTextEditToPlainText(ptr)
            return cstr.toString()
        }
    }

    /// 追加文本
    public func appendPlainText(text: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qPlainTextEditAppendPlainText(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置只读
    public func setReadOnly(readonly: Bool): Unit {
        unsafe {
            qPlainTextEditSetReadOnly(ptr, readonly)
        }
    }

    /// 是否只读
    public func isReadOnly(): Bool {
        unsafe {
            return qPlainTextEditIsReadOnly(ptr)
        }
    }

    /// 清空
    public func clear(): Unit {
        unsafe {
            qPlainTextEditClear(ptr)
        }
    }

    /// 剪切
    public func cut(): Unit { unsafe { qPlainTextEditCut(ptr) } }

    /// 复制
    public func copy(): Unit { unsafe { qPlainTextEditCopy(ptr) } }

    /// 粘贴
    public func paste(): Unit { unsafe { qPlainTextEditPaste(ptr) } }

    /// 全选
    public func selectAll(): Unit { unsafe { qPlainTextEditSelectAll(ptr) } }

    /// 撤销
    public func undo(): Unit { unsafe { qPlainTextEditUndo(ptr) } }

    /// 重做
    public func redo(): Unit { unsafe { qPlainTextEditRedo(ptr) } }

    /// 是否可以撤销
    public func canUndo(): Bool { unsafe { return qPlainTextEditCanUndo(ptr) } }

    /// 是否可以重做
    public func canRedo(): Bool { unsafe { return qPlainTextEditCanRedo(ptr) } }

    /// 内容是否被修改
    public func isModified(): Bool { unsafe { return qPlainTextEditIsModified(ptr) } }

    /// 设置修改状态
    public func setModified(modified: Bool): Unit {
        unsafe { qPlainTextEditSetModified(ptr, modified) }
    }

    /// 设置换行模式
    /// 0 = NoWrap, 1 = WidgetWidth
    public func setLineWrapMode(mode: Int32): Unit {
        unsafe { qPlainTextEditSetLineWrapMode(ptr, mode) }
    }

    /// 获取换行模式
    public func lineWrapMode(): Int32 {
        unsafe { return qPlainTextEditLineWrapMode(ptr) }
    }

    /// 设置制表符距离（像素）
    public func setTabStopDistance(distance: Float64): Unit {
        unsafe { qPlainTextEditSetTabStopDistance(ptr, distance) }
    }

    /// 获取文本行数
    public func lineCount(): Int64 {
        unsafe { return qPlainTextEditLineCount(ptr) }
    }

    /// 设置最大文本块数量（用于日志截断）
    public func setMaximumBlockCount(maxBlocks: Int32): Unit {
        unsafe { qPlainTextEditSetMaximumBlockCount(ptr, maxBlocks) }
    }

    /// 追加 HTML 片段
    public func appendHtml(html: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(html)
            qPlainTextEditAppendHtml(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 放大字体
    public func zoomIn(range: Int32): Unit {
        unsafe { qPlainTextEditZoomIn(ptr, range) }
    }

    /// 缩小字体
    public func zoomOut(range: Int32): Unit {
        unsafe { qPlainTextEditZoomOut(ptr, range) }
    }

    /// 获取文本块（行）数量
    public func blockCount(): Int32 {
        unsafe { return qPlainTextEditBlockCount(ptr) }
    }

    /// 文本内容变化回调
    public func setOnTextChanged(callback: VoidCallback): Unit {
        unsafe { qPlainTextEditConnectTextChanged(ptr, callback) }
    }

    /// 文本块数量变化回调（参数: 新的块数量）
    public func setOnBlockCountChanged(callback: Int32Callback): Unit {
        unsafe { qPlainTextEditConnectBlockCountChanged(ptr, callback) }
    }

    /// 修改状态变化回调（参数: 是否已修改）
    public func setOnModificationChanged(callback: BoolCallback): Unit {
        unsafe { qPlainTextEditConnectModificationChanged(ptr, callback) }
    }

    /// 复制可用性变化回调（参数: 是否有选中内容可复制）
    public func setOnCopyAvailable(callback: BoolCallback): Unit {
        unsafe { qPlainTextEditConnectCopyAvailable(ptr, callback) }
    }

    /// 设置最小尺寸
    public func setMinimumSize(minw: Int32, minh: Int32): Unit {
        unsafe {
            qWidgetSetMinimumSize(ptr, minw, minh)
        }
    }

    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }

    /// 删除纯文本编辑器
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qPlainTextEditDelete(ptr)
            }
            ptr = 0
        }
    }
}
