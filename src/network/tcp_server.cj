package cjqt6.network

import cjqt6.core.*

// ============================================================
// QTcpServer - TCP服务器
// ============================================================

foreign func qTcpServerCreate(): Int64
foreign func qTcpServerDelete(ptr: Int64): Unit
foreign func qTcpServerListen(ptr: Int64, address: CString, port: UInt16): Bool
foreign func qTcpServerClose(ptr: Int64): Unit
foreign func qTcpServerIsListening(ptr: Int64): Bool
foreign func qTcpServerServerPort(ptr: Int64): UInt16
foreign func qTcpServerServerAddress(ptr: Int64): CString
foreign func qTcpServerErrorString(ptr: Int64): CString
foreign func qTcpServerMaxPendingConnections(ptr: Int64): Int32
foreign func qTcpServerSetMaxPendingConnections(ptr: Int64, count: Int32): Unit
foreign func qTcpServerHasPendingConnections(ptr: Int64): Bool
foreign func qTcpServerNextPendingConnection(ptr: Int64): Int64
foreign func qTcpServerConnectNewConnection(ptr: Int64, callback: VoidCallback): Unit
foreign func qTcpServerConnectNewConnectionId(ptr: Int64, id: Int64): Unit
foreign func qTcpServerDisconnectCallbacks(ptr: Int64): Unit

/// TCP服务器
/// 监听指定地址/端口，接受客户端连接
/// 典型用法：
/// ```
/// let server = QTcpServer()
/// server.setOnNewConnection(onNewConn)   // 顶层 CFunc 回调
/// if (!server.listen(9600u16)) { ... }   // 监听所有地址
/// // 回调内：while (server.hasPendingConnections()) {
/// //     if (let Some(sock) <- server.nextPendingConnection()) { ... }
/// // }
/// ```
public class QTcpServer <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// 创建TCP服务器
    public init() {
        unsafe {
            ptr = qTcpServerCreate()
            if (ptr == 0) {
                throw CreateFailedException("QTcpServer 创建失败")
            }
        }
    }

    /// 开始监听
    /// port: 端口号（0 表示系统自动分配）
    /// 监听所有网络接口（0.0.0.0），局域网内其他机器可连接
    /// 返回是否成功（端口被占用等原因会失败，可用 errorString() 查看原因）
    public func listen(port: UInt16): Bool {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString("")
            let result = qTcpServerListen(ptr, cstr, port)
            LibC.free(cstr)
            return result
        }
    }

    /// 在指定地址上监听
    /// address: 绑定地址（如 "127.0.0.1" 仅本机，"0.0.0.0" 所有接口）
    /// port: 端口号
    public func listenOn(address: String, port: UInt16): Bool {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(address)
            let result = qTcpServerListen(ptr, cstr, port)
            LibC.free(cstr)
            return result
        }
    }

    /// 停止监听并关闭服务器
    /// 注意：已接受且未 close 的连接套接字不会被自动关闭，
    /// 调用方需自行管理这些连接的生命周期
    public func closeServer(): Unit {
        checkValid()
        unsafe {
            qTcpServerClose(ptr)
        }
    }

    /// 是否正在监听
    public func isListening(): Bool {
        checkValid()
        unsafe {
            return qTcpServerIsListening(ptr)
        }
    }

    /// 获取实际监听端口（listen(0) 自动分配后可查询）
    public func serverPort(): UInt16 {
        checkValid()
        unsafe {
            return qTcpServerServerPort(ptr)
        }
    }

    /// 获取监听地址
    public func serverAddress(): String {
        checkValid()
        unsafe {
            let cstr = qTcpServerServerAddress(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 获取错误描述（如 listen 失败原因）
    public func errorString(): String {
        checkValid()
        unsafe {
            let cstr = qTcpServerErrorString(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 获取最大待处理连接数
    public func maxPendingConnections(): Int32 {
        checkValid()
        unsafe {
            return qTcpServerMaxPendingConnections(ptr)
        }
    }

    /// 设置最大待处理连接数
    public func setMaxPendingConnections(count: Int32): Unit {
        checkValid()
        unsafe {
            qTcpServerSetMaxPendingConnections(ptr, count)
        }
    }

    /// 是否有待接受的连接
    public func hasPendingConnections(): Bool {
        checkValid()
        unsafe {
            return qTcpServerHasPendingConnections(ptr)
        }
    }

    /// 接受一个待处理连接
    /// 返回的 QTcpSocket 已脱离 Qt 父子树，生命周期由调用方管理：
    /// 使用完毕后必须调用其 close() 释放
    public func nextPendingConnection(): ?QTcpSocket {
        checkValid()
        unsafe {
            let socketPtr = qTcpServerNextPendingConnection(ptr)
            if (socketPtr == 0) {
                return None<QTcpSocket>
            }
            return Some(QTcpSocket(socketPtr))
        }
    }

    /// 设置新连接到达回调（QTcpServer::newConnection 信号）
    /// 注意：回调注册表以服务指针为键，每台服务器仅保留一个回调
    public func setOnNewConnection(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qTcpServerConnectNewConnection(ptr, callback)
        }
    }

    /// 设置新连接到达回调（闭包捕获版，可捕获局部变量）
    /// 返回闭包注册表 id，可调用 unregisterVoidCallback(id) 注销
    public func setOnNewConnectionCapture(callback: () -> Unit): Int64 {
        checkValid()
        ensureNetDispatcher()
        let id = registerVoidCallback(callback)
        unsafe {
            qTcpServerConnectNewConnectionId(ptr, id)
        }
        return id
    }

    /// 断开所有信号连接
    public func disconnectCallbacks(): Unit {
        checkValid()
        unsafe {
            qTcpServerDisconnectCallbacks(ptr)
        }
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
            throw ResourceDisposedException("QTcpServer 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QTcpServer 指针为空")
        }
    }

    /// 关闭资源，释放Qt对象
    /// 先停止监听、断开信号，再删除底层 QTcpServer
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qTcpServerClose(ptr)
                qTcpServerDisconnectCallbacks(ptr)
                qTcpServerDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }

    /// 删除服务器（兼容旧API）
    public func delete(): Unit {
        close()
    }
}
