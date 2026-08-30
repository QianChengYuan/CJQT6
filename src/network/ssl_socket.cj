package cjqt6.network

import cjqt6.core.*

// ============================================================
// QSslSocket FFI
// ============================================================

foreign func qSslSocketCreate(): Int64
foreign func qSslSocketDelete(ptr: Int64): Unit
foreign func qSslSocketConnectToHostEncrypted(ptr: Int64, host: CString, port: UInt16): Unit
foreign func qSslSocketStartClientEncryption(ptr: Int64): Unit
foreign func qSslSocketStartServerEncryption(ptr: Int64): Unit
foreign func qSslSocketIsEncrypted(ptr: Int64): Bool
foreign func qSslSocketSslMode(ptr: Int64): Int32
foreign func qSslSocketSetPeerVerifyMode(ptr: Int64, mode: Int32): Unit
foreign func qSslSocketPeerVerifyMode(ptr: Int64): Int32
foreign func qSslSocketPeerCertificateInfo(ptr: Int64): CString
foreign func qSslSocketConnectEncrypted(ptr: Int64, callback: VoidCallback): Unit
foreign func qSslSocketConnectPeerVerifyError(ptr: Int64, callback: CStringCallback): Unit


// ============================================================
// SSL模式常量（与 QSsl::SslMode 枚举对应）
// ============================================================
/// SSL 模式常量：无加密 / 客户端 / 服务端
public class SslMode {
    /// 未加密模式
    public static func unsecured(): Int32 { 0 }
    /// SSL 客户端模式
    public static func sslClient(): Int32 { 1 }
    /// SSL 服务端模式
    public static func sslServer(): Int32 { 2 }
}

// ============================================================
// 对端验证模式常量（与 QSslSocket::PeerVerifyMode 枚举对应）
// ============================================================
/// 对端证书验证模式常量
public class PeerVerifyMode {
    /// 不验证对端证书
    public static func verifyNone(): Int32 { 0 }
    /// 请求对端证书但不验证
    public static func queryPeer(): Int32 { 1 }
    /// 请求并验证对端证书
    public static func verifyPeer(): Int32 { 2 }
    /// 自动验证（客户端模式自动开启验证）
    public static func autoVerify(): Int32 { 3 }
}


// ============================================================
// QSslSocket - SSL/TLS加密套接字
// ============================================================
/// SSL/TLS 加密套接字，提供加密的网络通信（如 HTTPS）
public class QSslSocket {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QSslSocket already deleted")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QSslSocket 底层 Qt 对象已失效")
        }
    }

    /// 创建SSL套接字
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qSslSocketCreate()
            if (ptr == 0) {
                throw CreateFailedException("QSslSocket create failed")
            }
        }
        trackObject(ptr)
    }

    /// 连接到加密主机
    public func connectToHostEncrypted(host: String, port: UInt16): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(host)
            qSslSocketConnectToHostEncrypted(ptr, cstr, port)
            LibC.free(cstr)
        }
    }

    /// 启动客户端加密（用于已建立连接的加密升级）
    public func startClientEncryption(): Unit {
        checkValid()
        unsafe { qSslSocketStartClientEncryption(ptr) }
    }

    /// 启动服务端加密
    public func startServerEncryption(): Unit {
        checkValid()
        unsafe { qSslSocketStartServerEncryption(ptr) }
    }

    /// 是否已加密
    public func isEncrypted(): Bool {
        checkValid()
        unsafe { qSslSocketIsEncrypted(ptr) }
    }

    /// 获取SSL模式
    public func sslMode(): Int32 {
        checkValid()
        unsafe { qSslSocketSslMode(ptr) }
    }

    /// 设置对端验证模式
    public func setPeerVerifyMode(mode: Int32): Unit {
        checkValid()
        unsafe { qSslSocketSetPeerVerifyMode(ptr, mode) }
    }

    /// 获取对端验证模式
    public func peerVerifyMode(): Int32 {
        checkValid()
        unsafe { qSslSocketPeerVerifyMode(ptr) }
    }

    /// 获取对端证书信息
    public func peerCertificateInfo(): String {
        checkValid()
        unsafe {
            let cstr = qSslSocketPeerCertificateInfo(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    // ---- 信号连接 ----

    /// 加密完成时回调
    public func setOnEncrypted(callback: VoidCallback): Unit {
        checkValid()
        unsafe { qSslSocketConnectEncrypted(ptr, callback) }
    }

    /// 对端证书验证错误时回调
    public func setOnPeerVerifyError(callback: CStringCallback): Unit {
        checkValid()
        unsafe { qSslSocketConnectPeerVerifyError(ptr, callback) }
    }

    /// 获取底层指针
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
            unsafe { qSslSocketDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
