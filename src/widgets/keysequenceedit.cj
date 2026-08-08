package cjqt6.widgets

import cjqt6.core.*

// QKeySequenceEdit - 快捷键输入控件
foreign func qKeySequenceEditCreate(parentPtr: Int64): Int64
foreign func qKeySequenceEditKeySequence(ptr: Int64): CString
foreign func qKeySequenceEditSetKeySequence(ptr: Int64, text: CString): Unit
foreign func qKeySequenceEditClear(ptr: Int64): Unit
foreign func qKeySequenceEditConnectKeySequenceChanged(ptr: Int64, callback: CStringCallback): Unit
foreign func qKeySequenceEditDelete(ptr: Int64): Unit

/// 快捷键输入控件
/// 允许用户输入键盘快捷键组合（如 Ctrl+C, Alt+Shift+X 等）
public class QKeySequenceEdit {
    private var ptr: Int64 = 0

    public init(parent!: Int64 = 0) {
        unsafe {
            ptr = qKeySequenceEditCreate(parent)
        }
    }

    /// 显示
    public func show(): Unit { unsafe { qWidgetShow(ptr) } }

    /// 隐藏
    public func hide(): Unit { unsafe { qWidgetHide(ptr) } }

    /// 调整大小
    public func resize(width: Int32, height: Int32): Unit {
        unsafe { qWidgetResize(ptr, width, height) }
    }

    /// 设置样式表
    public func setStyleSheet(style: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取当前快捷键序列文本
    public func keySequence(): String {
        unsafe {
            let cstr = qKeySequenceEditKeySequence(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 设置快捷键序列（如 "Ctrl+C", "Alt+Shift+X"）
    public func setKeySequence(text: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qKeySequenceEditSetKeySequence(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 清空快捷键
    public func clear(): Unit { unsafe { qKeySequenceEditClear(ptr) } }

    /// 快捷键序列变化回调（参数为快捷键文本，如 "Ctrl+C"）
    public func setOnKeySequenceChanged(callback: CStringCallback): Unit {
        unsafe { qKeySequenceEditConnectKeySequenceChanged(ptr, callback) }
    }

    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }

    /// 删除快捷键输入控件
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qKeySequenceEditDelete(ptr)
            }
            ptr = 0
        }
    }
}
