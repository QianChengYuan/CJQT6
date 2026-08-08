package cjqt6.network

import cjqt6.core.*

// ============================================================
// QTcpSocket - TCP套接字
// ============================================================

foreign func qTcpSocketCreate(): Int64
foreign func qTcpSocketDelete(ptr: Int64): Unit
foreign func qTcpSocketConnectToHost(ptr: Int64, host: CString, port: UInt16): Unit
foreign func qTcpSocketDisconnectFromHost(ptr: Int64): Unit
foreign func qTcpSocketWrite(ptr: Int64, data: CPointer<Int8>, size: Int64): Int64
foreign func qTcpSocketRead(ptr: Int64, buffer: CPointer<Int8>, maxSize: Int64): Int64
foreign func qTcpSocketReadAll(ptr: Int64, buffer: CPointer<Int8>, bufferSize: Int64): Int64
foreign func qTcpSocketBytesAvailable(ptr: Int64): Int64
foreign func qTcpSocketBytesToWrite(ptr: Int64): Int64
foreign func qTcpSocketFlush(ptr: Int64): Bool
foreign func qTcpSocketAtEnd(ptr: Int64): Bool
foreign func qTcpSocketState(ptr: Int64): Int32
foreign func qTcpSocketError(ptr: Int64): Int32
foreign func qTcpSocketErrorString(ptr: Int64): CString
foreign func qTcpSocketIsValid(ptr: Int64): Bool
foreign func qTcpSocketClose(ptr: Int64): Unit
foreign func qTcpSocketPeerAddress(ptr: Int64): CString
foreign func qTcpSocketPeerPort(ptr: Int64): UInt16
foreign func qTcpSocketLocalAddress(ptr: Int64): CString
foreign func qTcpSocketLocalPort(ptr: Int64): UInt16
foreign func qTcpSocketConnectConnected(ptr: Int64, callback: VoidCallback): Unit
foreign func qTcpSocketConnectDisconnected(ptr: Int64, callback: VoidCallback): Unit
foreign func qTcpSocketConnectReadyRead(ptr: Int64, callback: VoidCallback): Unit
foreign func qTcpSocketConnectError(ptr: Int64, callback: VoidCallback): Unit
foreign func qTcpSocketDisconnectCallbacks(ptr: Int64): Unit
foreign func qNetSetVoidDispatcher(disp: CFunc<(Int64) -> Unit>): Unit
foreign func qTcpSocketConnectConnectedId(ptr: Int64, id: Int64): Unit
foreign func qTcpSocketConnectDisconnectedId(ptr: Int64, id: Int64): Unit
foreign func qTcpSocketConnectReadyReadId(ptr: Int64, id: Int64): Unit
foreign func qTcpSocketConnectErrorId(ptr: Int64, id: Int64): Unit

// 网络模块闭包调度器注册标记（Capture 回调首次使用时初始化）
private var gNetDispatcherReady: Bool = false

/// 确保 native 网络模块已注册 Cangjie 闭包调度器
/// tcp_socket / tcp_server 的 Capture 回调均依赖此调度器按 id 派发
public func ensureNetDispatcher(): Unit {
    if (!gNetDispatcherReady) {
        unsafe {
            qNetSetVoidDispatcher(getVoidDispatcher())
        }
        gNetDispatcherReady = true
    }
}

/// 套接字状态
public class SocketState {
    public static let UnconnectedState: Int32 = 0
    public static let HostLookupState: Int32 = 1
    public static let ConnectingState: Int32 = 2
    public static let ConnectedState: Int32 = 3
    public static let BoundState: Int32 = 4
    public static let ListeningState: Int32 = 5
    public static let ClosingState: Int32 = 6
}

/// 套接字错误
public class SocketError {
    public static let ConnectionRefusedError: Int32 = 0
    public static let RemoteHostClosedError: Int32 = 1
    public static let HostNotFoundError: Int32 = 2
    public static let SocketAccessError: Int32 = 3
    public static let SocketResourceError: Int32 = 4
    public static let SocketTimeoutError: Int32 = 5
    public static let DatagramTooLargeError: Int32 = 6
    public static let NetworkError: Int32 = 7
    public static let AddressInUseError: Int32 = 8
    public static let SocketAddressNotAvailableError: Int32 = 9
    public static let UnsupportedSocketOperationError: Int32 = 10
    public static let UnfinishedSocketOperationError: Int32 = 11
    public static let ProxyAuthenticationRequiredError: Int32 = 12
    public static let SslHandshakeFailedError: Int32 = 13
    public static let ProxyConnectionRefusedError: Int32 = 14
    public static let ProxyConnectionClosedError: Int32 = 15
    public static let ProxyConnectionTimeoutError: Int32 = 16
    public static let ProxyNotFoundError: Int32 = 17
    public static let ProxyProtocolError: Int32 = 18
    public static let OperationError: Int32 = 19
    public static let SslInternalError: Int32 = 20
    public static let SslInvalidUserDataError: Int32 = 21
    public static let TemporaryError: Int32 = 22
    public static let UnknownSocketError: Int32 = -1
}

/// TCP套接字
/// 提供TCP客户端功能，支持连接、读写、断开等操作
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QTcpSocket <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    /// 创建TCP套接字
    public init() {
        unsafe {
            ptr = qTcpSocketCreate()
            if (ptr == 0) {
                throw CreateFailedException("QTcpSocket 创建失败")
            }
        }
    }
    
    /// 包装已存在的原生套接字指针
    /// 用于 QTcpServer.nextPendingConnection() 返回的连接，
    /// 其生命周期由本包装对象接管（释放时调用 close()）
    public init(nativePtr: Int64) {
        if (nativePtr == 0) {
            throw CreateFailedException("QTcpSocket 包装失败：原生指针为空")
        }
        ptr = nativePtr
    }
    
    /// 连接到主机
    /// host: 主机地址（IP或域名）
    /// port: 端口号
    public func connectToHost(host: String, port: UInt16): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(host)
            qTcpSocketConnectToHost(ptr, cstr, port)
            LibC.free(cstr)
        }
    }
    
    /// 断开连接
    public func disconnectFromHost(): Unit {
        checkValid()
        unsafe {
            qTcpSocketDisconnectFromHost(ptr)
        }
    }
    
    /// 立即关闭套接字连接（不等待数据传输完成）
    public func abort(): Unit {
        checkValid()
        unsafe {
            qTcpSocketClose(ptr)
        }
    }
    
    /// 写入数据
    /// 返回实际写入的字节数，-1表示错误
    public func write(data: Array<Byte>): Int64 {
        checkValid()
        unsafe {
            var handle = acquireArrayRawData(data)
            let result = qTcpSocketWrite(ptr, CPointer<Int8>(handle.pointer), Int64(data.size))
            releaseArrayRawData(handle)
            return result
        }
    }
    
    /// 写入字符串数据
    public func writeString(text: String): Int64 {
        checkValid()
        let bytes = text.toArray()
        return write(bytes)
    }
    
    /// 读取数据
    /// maxSize: 最大读取字节数
    /// 返回读取到的字节数组
    public func read(maxSize: Int64): Array<Byte> {
        checkValid()
        unsafe {
            let buffer = LibC.malloc<Byte>(count: maxSize)
            let size = qTcpSocketRead(ptr, CPointer<Int8>(buffer), maxSize)
            if (size <= 0) {
                LibC.free(buffer)
                return []
            }
            
            var result: Array<Byte> = []
            for (i in 0..size) {
                result = result.concat([buffer.read(i)])
            }
            LibC.free(buffer)
            return result
        }
    }
    
    /// 读取所有可用数据
    public func readAll(): Array<Byte> {
        checkValid()
        let available = bytesAvailable()
        if (available <= 0) {
            return []
        }
        return read(available)
    }
    
    /// 读取为字符串
    public func readString(maxSize: Int64): String {
        checkValid()
        let bytes = read(maxSize)
        return String.fromUtf8(bytes)
    }
    
    /// 可读取字节数
    public func bytesAvailable(): Int64 {
        checkValid()
        unsafe {
            return qTcpSocketBytesAvailable(ptr)
        }
    }
    
    /// 待写入字节数
    public func bytesToWrite(): Int64 {
        checkValid()
        unsafe {
            return qTcpSocketBytesToWrite(ptr)
        }
    }
    
    /// 刷新缓冲区
    public func flush(): Bool {
        checkValid()
        unsafe {
            return qTcpSocketFlush(ptr)
        }
    }
    
    /// 是否到达末尾
    public func atEnd(): Bool {
        checkValid()
        unsafe {
            return qTcpSocketAtEnd(ptr)
        }
    }
    
    /// 获取套接字状态
    public func state(): Int32 {
        checkValid()
        unsafe {
            return qTcpSocketState(ptr)
        }
    }
    
    /// 获取错误码
    public func error(): Int32 {
        checkValid()
        unsafe {
            return qTcpSocketError(ptr)
        }
    }
    
    /// 获取错误描述
    public func errorString(): String {
        checkValid()
        unsafe {
            let cstr = qTcpSocketErrorString(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    /// 获取对端IP地址（连接建立后有效）
    public func peerAddress(): String {
        checkValid()
        unsafe {
            let cstr = qTcpSocketPeerAddress(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    /// 获取对端端口（连接建立后有效）
    public func peerPort(): UInt16 {
        checkValid()
        unsafe {
            return qTcpSocketPeerPort(ptr)
        }
    }
    
    /// 获取本端IP地址
    public func localAddress(): String {
        checkValid()
        unsafe {
            let cstr = qTcpSocketLocalAddress(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    /// 获取本端端口
    public func localPort(): UInt16 {
        checkValid()
        unsafe {
            return qTcpSocketLocalPort(ptr)
        }
    }
    
    /// Qt资源管理：检查底层套接字是否有效
    public func isSocketValid(): Bool {
        checkValid()
        unsafe {
            return qTcpSocketIsValid(ptr)
        }
    }
    
    /// 设置连接成功回调
    public func setOnConnected(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qTcpSocketConnectConnected(ptr, callback)
        }
    }
    
    /// 设置断开连接回调
    public func setOnDisconnected(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qTcpSocketConnectDisconnected(ptr, callback)
        }
    }
    
    /// 设置数据就绪回调
    public func setOnReadyRead(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qTcpSocketConnectReadyRead(ptr, callback)
        }
    }
    
    /// 设置错误回调
    public func setOnError(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qTcpSocketConnectError(ptr, callback)
        }
    }
    
    /// 断开所有信号连接
    public func disconnectCallbacks(): Unit {
        checkValid()
        unsafe {
            qTcpSocketDisconnectCallbacks(ptr)
        }
    }
    
    /// 设置连接成功回调（闭包捕获版，可捕获局部变量）
    /// 返回闭包注册表 id，可调用 unregisterVoidCallback(id) 注销
    public func setOnConnectedCapture(callback: () -> Unit): Int64 {
        checkValid()
        ensureNetDispatcher()
        let id = registerVoidCallback(callback)
        unsafe {
            qTcpSocketConnectConnectedId(ptr, id)
        }
        return id
    }
    
    /// 设置断开连接回调（闭包捕获版）
    public func setOnDisconnectedCapture(callback: () -> Unit): Int64 {
        checkValid()
        ensureNetDispatcher()
        let id = registerVoidCallback(callback)
        unsafe {
            qTcpSocketConnectDisconnectedId(ptr, id)
        }
        return id
    }
    
    /// 设置数据就绪回调（闭包捕获版）
    /// 服务器多连接场景：每个连接套接字注册各自闭包即可区分来源
    public func setOnReadyReadCapture(callback: () -> Unit): Int64 {
        checkValid()
        ensureNetDispatcher()
        let id = registerVoidCallback(callback)
        unsafe {
            qTcpSocketConnectReadyReadId(ptr, id)
        }
        return id
    }
    
    /// 设置错误回调（闭包捕获版）
    public func setOnErrorCapture(callback: () -> Unit): Int64 {
        checkValid()
        ensureNetDispatcher()
        let id = registerVoidCallback(callback)
        unsafe {
            qTcpSocketConnectErrorId(ptr, id)
        }
        return id
    }
    
    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 是否已关闭（资源已释放）
    public func isClosed(): Bool {
        return closed
    }
    
    /// 检查对象有效性（未关闭且指针有效）
    public func isValid(): Bool {
        return !closed && ptr != 0
    }
    
    /// 检查有效性，无效时抛出异常
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QTcpSocket 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QTcpSocket 指针为空")
        }
    }
    
    /// 关闭资源，释放Qt对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qTcpSocketClose(ptr)
                qTcpSocketDisconnectCallbacks(ptr)
                qTcpSocketDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除套接字（兼容旧API）
    public func delete(): Unit {
        close()
    }
}
