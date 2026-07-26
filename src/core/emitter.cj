package cjqt6.core

// ============================================================
// P2：SignalEmitter —— 通用自定义信号发射器
// ------------------------------------------------------------
// 仓颉无法从 C++ 侧派生 Q_OBJECT 子类，故通过 native 的 CjSignalEmitter
// （一组固定的 void/int/double/string 信号 + emit 包装）实现「用户自定义信号」。
// 连接时可指定 ConnectionType，从而支持跨线程 QueuedConnection。
// 注：仓颉 1.1.0 不支持默认参数，故以「单参重载委托双参重载（connType=Auto）」提供易用 API。
// ============================================================

// 连接类型（映射 Qt::ConnectionType）
public class ConnectionType {
    public static let Auto: Int32 = 0            // Qt::AutoConnection
    public static let Direct: Int32 = 1          // Qt::DirectConnection
    public static let Queued: Int32 = 2          // Qt::QueuedConnection
    public static let BlockingQueued: Int32 = 3  // Qt::BlockingQueuedConnection
}

// 控件类型 / 信号常量（供 SignalConnection 路由断开）
public const WIDGET_TYPE_EMITTER: String = "emitter"
public const SIGNAL_EMIT_VOID: String = "emitVoid"
public const SIGNAL_EMIT_INT: String = "emitInt"
public const SIGNAL_EMIT_DOUBLE: String = "emitDouble"
public const SIGNAL_EMIT_STRING: String = "emitString"

// ---- native 声明（同包 cjqt6.core 内调用，非 public 即可） ----
foreign func qEmitterCreate(): Int64
foreign func qEmitterDelete(ptr: Int64): Unit
foreign func qEmitterConnectVoid(ptr: Int64, callback: VoidCallback, connType: Int32): Unit
foreign func qEmitterConnectVoidId(ptr: Int64, id: Int64, connType: Int32): Unit
foreign func qEmitterConnectInt(ptr: Int64, callback: Int32Callback, connType: Int32): Unit
foreign func qEmitterConnectDouble(ptr: Int64, callback: Float64Callback, connType: Int32): Unit
foreign func qEmitterConnectString(ptr: Int64, callback: CStringCallback, connType: Int32): Unit
foreign func qEmitterDisconnectVoid(ptr: Int64): Unit
foreign func qEmitterDisconnectInt(ptr: Int64): Unit
foreign func qEmitterDisconnectDouble(ptr: Int64): Unit
foreign func qEmitterDisconnectString(ptr: Int64): Unit
foreign func qEmitterEmitVoid(ptr: Int64): Unit
foreign func qEmitterEmitInt(ptr: Int64, v: Int32): Unit
foreign func qEmitterEmitDouble(ptr: Int64, v: Float64): Unit
foreign func qEmitterEmitString(ptr: Int64, s: CString): Unit

/// 通用自定义信号发射器：支持 void/int/double/string 四种参数信号，
/// 可连接 Cangjie 回调，可指定连接类型（含跨线程 QueuedConnection）。
public class SignalEmitter <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// 创建发射器
    public init() {
        unsafe {
            ptr = qEmitterCreate()
            if (ptr == 0) {
                throw CreateFailedException("SignalEmitter 创建失败")
            }
        }
    }

    // ---- void 信号 ----
    /// 连接 void 信号监听（默认 AutoConnection）
    public func setOnVoid(callback: VoidCallback): SignalConnection {
        return setOnVoid(callback, ConnectionType.Auto)
    }

    /// 连接 void 信号监听（可指定连接类型）
    public func setOnVoid(callback: VoidCallback, connType: Int32): SignalConnection {
        checkValid()
        unsafe { qEmitterConnectVoid(ptr, callback, connType) }
        return SignalConnection.createWithWidgetType(ptr, SIGNAL_EMIT_VOID, WIDGET_TYPE_EMITTER)
    }

    /// 连接 void 信号监听（闭包捕获版本，P1c 风格，默认 AutoConnection）
    public func setOnVoidCapture(callback: () -> Unit): SignalConnection {
        return setOnVoidCapture(callback, ConnectionType.Auto)
    }

    /// 连接 void 信号监听（闭包捕获版本，P1c 风格，可指定连接类型）
    public func setOnVoidCapture(callback: () -> Unit, connType: Int32): SignalConnection {
        checkValid()
        let id = registerVoidCallback(callback)
        unsafe { qEmitterConnectVoidId(ptr, id, connType) }
        return SignalConnection.createCapturing(ptr, SIGNAL_EMIT_VOID, WIDGET_TYPE_EMITTER, id)
    }

    /// 发射 void 信号
    public func emitVoid(): Unit {
        checkValid()
        unsafe { qEmitterEmitVoid(ptr) }
    }

    public func disconnectVoid(): Unit {
        if (ptr != 0) { unsafe { qEmitterDisconnectVoid(ptr) } }
    }

    // ---- int 信号 ----
    public func setOnInt(callback: Int32Callback): SignalConnection {
        return setOnInt(callback, ConnectionType.Auto)
    }

    public func setOnInt(callback: Int32Callback, connType: Int32): SignalConnection {
        checkValid()
        unsafe { qEmitterConnectInt(ptr, callback, connType) }
        return SignalConnection.createWithWidgetType(ptr, SIGNAL_EMIT_INT, WIDGET_TYPE_EMITTER)
    }

    public func emitInt(v: Int32): Unit {
        checkValid()
        unsafe { qEmitterEmitInt(ptr, v) }
    }

    public func disconnectInt(): Unit {
        if (ptr != 0) { unsafe { qEmitterDisconnectInt(ptr) } }
    }

    // ---- double 信号 ----
    public func setOnDouble(callback: Float64Callback): SignalConnection {
        return setOnDouble(callback, ConnectionType.Auto)
    }

    public func setOnDouble(callback: Float64Callback, connType: Int32): SignalConnection {
        checkValid()
        unsafe { qEmitterConnectDouble(ptr, callback, connType) }
        return SignalConnection.createWithWidgetType(ptr, SIGNAL_EMIT_DOUBLE, WIDGET_TYPE_EMITTER)
    }

    public func emitDouble(v: Float64): Unit {
        checkValid()
        unsafe { qEmitterEmitDouble(ptr, v) }
    }

    public func disconnectDouble(): Unit {
        if (ptr != 0) { unsafe { qEmitterDisconnectDouble(ptr) } }
    }

    // ---- string 信号 ----
    public func setOnString(callback: CStringCallback): SignalConnection {
        return setOnString(callback, ConnectionType.Auto)
    }

    public func setOnString(callback: CStringCallback, connType: Int32): SignalConnection {
        checkValid()
        unsafe { qEmitterConnectString(ptr, callback, connType) }
        return SignalConnection.createWithWidgetType(ptr, SIGNAL_EMIT_STRING, WIDGET_TYPE_EMITTER)
    }

    public func emitString(s: String): Unit {
        checkValid()
        unsafe {
            let cs = LibC.mallocCString(s)
            qEmitterEmitString(ptr, cs)
            LibC.free(cs)
        }
    }

    public func disconnectString(): Unit {
        if (ptr != 0) { unsafe { qEmitterDisconnectString(ptr) } }
    }

    /// 断开该发射器的全部信号
    public func disconnect(): Unit {
        disconnectVoid()
        disconnectInt()
        disconnectDouble()
        disconnectString()
    }

    /// 获取原生指针
    public func getPtr(): Int64 { ptr }

    public func isClosed(): Bool { closed }
    public func isValid(): Bool { !closed && ptr != 0 }
    public func checkValid(): Unit {
        if (closed) { throw ResourceDisposedException("SignalEmitter 已经被释放") }
        if (ptr == 0) { throw NullPointerException("SignalEmitter 指针为空") }
    }

    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qEmitterDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }

    public func delete(): Unit { close() }
}
