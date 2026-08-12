package cjqt6.core

// ============================================================
// QUndoCommand / QUndoStack FFI declarations
// ============================================================

/// 撤销/重做回调类型
public type UndoRedoCallback = CFunc<(Int64) -> Unit>

foreign func qUndoCommandCreate(undoCallback: UndoRedoCallback, redoCallback: UndoRedoCallback, userData: Int64, text: CString): Int64
foreign func qUndoCommandSetText(ptr: Int64, text: CString): Unit
foreign func qUndoCommandText(ptr: Int64): CString
foreign func qUndoCommandDelete(ptr: Int64): Unit

foreign func qUndoStackCreate(): Int64
foreign func qUndoStackPush(ptr: Int64, cmdPtr: Int64): Unit
foreign func qUndoStackUndo(ptr: Int64): Unit
foreign func qUndoStackRedo(ptr: Int64): Unit
foreign func qUndoStackCanUndo(ptr: Int64): Int32
foreign func qUndoStackCanRedo(ptr: Int64): Int32
foreign func qUndoStackUndoText(ptr: Int64): CString
foreign func qUndoStackRedoText(ptr: Int64): CString
foreign func qUndoStackCount(ptr: Int64): Int32
foreign func qUndoStackIndex(ptr: Int64): Int32
foreign func qUndoStackClear(ptr: Int64): Unit
foreign func qUndoStackSetUndoLimit(ptr: Int64, limit: Int32): Unit
foreign func qUndoStackUndoLimit(ptr: Int64): Int32
foreign func qUndoStackSetClean(ptr: Int64): Unit
foreign func qUndoStackIsClean(ptr: Int64): Int32
foreign func qUndoStackBeginMacro(ptr: Int64, text: CString): Unit
foreign func qUndoStackEndMacro(ptr: Int64): Unit
foreign func qUndoStackDelete(ptr: Int64): Unit


// ============================================================
// QUndoCommand - 撤销命令
// ============================================================
public class QUndoCommand {
    private var ptr: Int64 = 0
    private var pushed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0) {
            throw ResourceDisposedException("QUndoCommand already deleted or pushed")
        }
    }

    /// 创建撤销命令
    /// undoCallback: 撤销回调 (userData: Int64)
    /// redoCallback: 重做回调 (userData: Int64)
    /// userData: 用户数据（传递给回调）
    /// text: 命令描述文本
    public init(undoCallback: UndoRedoCallback, redoCallback: UndoRedoCallback, userData: Int64, text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            ptr = qUndoCommandCreate(undoCallback, redoCallback, userData, cstr)
            LibC.free(cstr)
        }
        if (ptr == 0) {
            throw CreateFailedException("QUndoCommand create failed")
        }
    }

    /// 设置命令文本
    public func setText(text: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            qUndoCommandSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取命令文本
    public func text(): String {
        checkValid()
        unsafe {
            let cstr = qUndoCommandText(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 获取原生指针
    public func getPtr(): Int64 { ptr }

    /// 标记为已入栈（不再手动删除，由栈管理生命周期）
    public func markPushed(): Unit {
        pushed = true
    }

    /// 是否已入栈
    public func isPushed(): Bool { pushed }

    /// 释放资源（仅当未入栈时可用）
    public func delete(): Unit {
        if (ptr != 0 && !pushed) {

            unsafe { qUndoCommandDelete(ptr) }
            ptr = 0
        }
    }
}


// ============================================================
// QUndoStack - 撤销栈
// ============================================================
public class QUndoStack {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QUndoStack already deleted")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QUndoStack 底层 Qt 对象已失效")
        }
    }

    public init() {
        unsafe { ptr = qUndoStackCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QUndoStack create failed")
        }
        trackObject(ptr)
    }

    /// 压入命令（入栈后 QUndoCommand 由栈管理生命周期）
    public func push(cmd: QUndoCommand): Unit {
        checkValid()
        cmd.markPushed()
        unsafe { qUndoStackPush(ptr, cmd.getPtr()) }
    }

    /// 撤销
    public func undo(): Unit {
        checkValid()
        unsafe { qUndoStackUndo(ptr) }
    }

    /// 重做
    public func redo(): Unit {
        checkValid()
        unsafe { qUndoStackRedo(ptr) }
    }

    /// 是否可以撤销
    public func canUndo(): Bool {
        checkValid()
        unsafe { qUndoStackCanUndo(ptr) != 0 }
    }

    /// 是否可以重做
    public func canRedo(): Bool {
        checkValid()
        unsafe { qUndoStackCanRedo(ptr) != 0 }
    }

    /// 获取撤销操作的描述
    public func undoText(): String {
        checkValid()
        unsafe {
            let cstr = qUndoStackUndoText(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            result
        }
    }

    /// 获取重做操作的描述
    public func redoText(): String {
        checkValid()
        unsafe {
            let cstr = qUndoStackRedoText(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            result
        }
    }

    /// 获取命令数量
    public func count(): Int32 {
        checkValid()
        unsafe { qUndoStackCount(ptr) }
    }

    /// 获取当前索引
    public func index(): Int32 {
        checkValid()
        unsafe { qUndoStackIndex(ptr) }
    }

    /// 清空栈
    public func clear(): Unit {
        checkValid()
        unsafe { qUndoStackClear(ptr) }
    }

    /// 设置撤销限制
    public func setUndoLimit(limit: Int32): Unit {
        checkValid()
        unsafe { qUndoStackSetUndoLimit(ptr, limit) }
    }

    /// 获取撤销限制
    public func undoLimit(): Int32 {
        checkValid()
        unsafe { qUndoStackUndoLimit(ptr) }
    }

    /// 标记为干净状态
    public func setClean(): Unit {
        checkValid()
        unsafe { qUndoStackSetClean(ptr) }
    }

    /// 是否干净状态
    public func isClean(): Bool {
        checkValid()
        unsafe { qUndoStackIsClean(ptr) != 0 }
    }

    /// 开始宏命令
    public func beginMacro(text: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            qUndoStackBeginMacro(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 结束宏命令
    public func endMacro(): Unit {
        checkValid()
        unsafe { qUndoStackEndMacro(ptr) }
    }

    /// 获取原生指针
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
            unsafe { qUndoStackDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
