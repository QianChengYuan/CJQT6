package cjqt6.network

import cjqt6.core.*

// ============================================================
// QLocalServer - 本地（Unix 域/Windows 命名管道）服务器
// ============================================================

foreign func qLocalServerCreate(): Int64
foreign func qLocalServerDelete(ptr: Int64): Unit
foreign func qLocalServerListen(ptr: Int64, name: CString): Bool
foreign func qLocalServerClose(ptr: Int64): Unit
foreign func qLocalServerIsListening(ptr: Int64): Bool
foreign func qLocalServerFullServerName(ptr: Int64): CString
foreign func qLocalServerServerName(ptr: Int64): CString
foreign func qLocalServerMaxPendingConnections(ptr: Int64): Int32
foreign func qLocalServerSetMaxPendingConnections(ptr: Int64, count: Int32): Unit
foreign func qLocalServerWaitForNewConnection(ptr: Int64, msec: Int32): Int64
foreign func qLocalServerHasPendingConnections(ptr: Int64): Bool
foreign func qLocalServerNextPendingConnection(ptr: Int64): Int64
foreign func qLocalServerSetSocketOptions(ptr: Int64, options: Int32): Unit
foreign func qLocalServerSocketOptions(ptr: Int64): Int32
foreign func qLocalServerRemoveServer(name: CString): Bool

/// 本地套接字访问权限选项（与 QLocalServer::SocketOption 枚举对应，可按位组合）
public class SocketOption {
    /// 无特殊权限
    public static func noOptions(): Int32 { 0 }
    /// 仅用户可访问
    public static func userAccessOption(): Int32 { 1 }
    /// 同组用户可访问
    public static func groupAccessOption(): Int32 { 2 }
    /// 其他用户可访问
    public static func otherAccessOption(): Int32 { 4 }
    /// 所有用户可访问（user|group|other）
    public static func worldAccessOption(): Int32 { 7 }
}

/// 本地服务器，通过 Unix 域套接字或 Windows 命名管道提供进程间通信
public class QLocalServer {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QLocalServer already deleted")
        }
    }

    /// 创建本地服务器
    public init() {
        unsafe {
            ptr = qLocalServerCreate()
            if (ptr == 0) {
                throw CreateFailedException("QLocalServer create failed")
            }
        }
    }

    /// 开始监听指定名称，返回是否成功
    public func listen(name: String): Bool {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(name)
            let result = qLocalServerListen(ptr, cstr)
            LibC.free(cstr)
            result
        }
    }

    /// 停止监听（Qt 的 close）
    public func stopListening(): Unit {
        checkValid()
        unsafe { qLocalServerClose(ptr) }
    }

    /// 是否正在监听
    public func isListening(): Bool {
        checkValid()
        unsafe { qLocalServerIsListening(ptr) }
    }

    /// 获取完整服务器名称（含平台前缀，如 Windows 管道路径）
    public func fullServerName(): String {
        checkValid()
        unsafe { qLocalServerFullServerName(ptr).toString() }
    }

    /// 获取服务器名称
    public func serverName(): String {
        checkValid()
        unsafe { qLocalServerServerName(ptr).toString() }
    }

    /// 最大挂起连接数
    public func maxPendingConnections(): Int32 {
        checkValid()
        unsafe { qLocalServerMaxPendingConnections(ptr) }
    }

    /// 设置最大挂起连接数
    public func setMaxPendingConnections(count: Int32): Unit {
        checkValid()
        unsafe { qLocalServerSetMaxPendingConnections(ptr, count) }
    }

    /// 等待新连接，返回已连接的 QLocalSocket 指针（无连接返回 0）
    public func waitForNewConnection(msec: Int32): Int64 {
        checkValid()
        unsafe { qLocalServerWaitForNewConnection(ptr, msec) }
    }

    /// 是否有挂起的连接
    public func hasPendingConnections(): Bool {
        checkValid()
        unsafe { qLocalServerHasPendingConnections(ptr) }
    }

    /// 获取下一个挂起连接（返回 QLocalSocket 指针）
    public func nextPendingConnection(): Int64 {
        checkValid()
        unsafe { qLocalServerNextPendingConnection(ptr) }
    }

    /// 设置套接字访问权限（SocketOption 常量组合）
    public func setSocketOptions(options: Int32): Unit {
        checkValid()
        unsafe { qLocalServerSetSocketOptions(ptr, options) }
    }

    /// 获取套接字访问权限
    public func socketOptions(): Int32 {
        checkValid()
        unsafe { qLocalServerSocketOptions(ptr) }
    }

    /// 移除指定名称的服务器（静态方法）
    public static func removeServer(name: String): Bool {
        unsafe {
            let cstr = LibC.mallocCString(name)
            let result = qLocalServerRemoveServer(cstr)
            LibC.free(cstr)
            result
        }
    }

    /// 获取底层指针
    public func getPtr(): Int64 { ptr }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe { qLocalServerDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
