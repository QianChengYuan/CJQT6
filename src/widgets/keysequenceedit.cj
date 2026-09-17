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
public class QKeySequenceEdit <: QtWidgetCore {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    public init(parent!: Int64 = 0) {
        unsafe {
            ptr = qKeySequenceEditCreate(parent)
        }
        trackObject(ptr)
    }

    /// 显示
    public func show(): Unit {
        unsafe { qWidgetShow(ptr) }
    }

    /// 隐藏
    public func hide(): Unit {
        unsafe { qWidgetHide(ptr) }
    }

    /// 调整大小
    public func resize(width: Int32, height: Int32): Unit {
        unsafe { qWidgetResize(ptr, width, height) }
    }

    /// 设置样式表
    public func setStyleSheet(style: String): Unit {
        unsafe {
            withCString(style) {c => qWidgetSetStyleSheet(ptr, c)}
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
            withCString(text) {c => qKeySequenceEditSetKeySequence(ptr, c)}
        }
    }

    /// 清空快捷键
    public func clear(): Unit {
        unsafe { qKeySequenceEditClear(ptr) }
    }

    /// 快捷键序列变化回调（参数为快捷键文本，如 "Ctrl+C"）
    public func setOnKeySequenceChanged(callback: CStringCallback): Unit {
        unsafe { qKeySequenceEditConnectKeySequenceChanged(ptr, callback) }
    }

    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }

    /// 删除快捷键输入控件
    /// 是否已关闭
    public func isClosed(): Bool {
        closed
    }

    /// 对象是否仍然可用
    public func isValid(): Bool {
        !closed && ptr != 0 && isObjectAlive(ptr)
    }

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QKeySequenceEdit 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QKeySequenceEdit 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QKeySequenceEdit 底层 Qt 对象已失效")
        }
    }

    /// 关闭资源，释放 Qt 对象（幂等）
    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            unsafe {
                qKeySequenceEditDelete(ptr)
            }
        }
        closed = true
        ptr = 0
    }

    /// 删除部件（兼容旧 API，等价于 close()）
    public func delete(): Unit {
        close()
    }
}
