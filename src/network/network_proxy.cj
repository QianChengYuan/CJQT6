package cjqt6.network

import cjqt6.core.*

// ============================================================
// QNetworkProxy - 网络代理
// ============================================================

foreign func qNetworkProxyCreate(): Int64
foreign func qNetworkProxyCreateWithType(proxyType: Int32): Int64
foreign func qNetworkProxyDelete(ptr: Int64): Unit
foreign func qNetworkProxySetType(ptr: Int64, proxyType: Int32): Unit
foreign func qNetworkProxyType(ptr: Int64): Int32
foreign func qNetworkProxySetHostName(ptr: Int64, host: CString): Unit
foreign func qNetworkProxyHostName(ptr: Int64): CString
foreign func qNetworkProxySetPort(ptr: Int64, port: UInt16): Unit
foreign func qNetworkProxyPort(ptr: Int64): UInt16
foreign func qNetworkProxySetUser(ptr: Int64, user: CString): Unit
foreign func qNetworkProxyUser(ptr: Int64): CString
foreign func qNetworkProxySetPassword(ptr: Int64, pass: CString): Unit
foreign func qNetworkProxyPassword(ptr: Int64): CString
foreign func qNetworkProxySetApplicationProxy(host: CString, port: UInt16): Unit

/// 代理类型（与 QNetworkProxy::ProxyType 枚举对应）
public class ProxyType {
    /// 不使用代理
    public static func noProxy(): Int32 { 0 }
    /// 使用系统默认代理
    public static func defaultProxy(): Int32 { 1 }
    /// SOCKS5 代理
    public static func socks5(): Int32 { 2 }
    /// HTTP 代理
    public static func http(): Int32 { 3 }
    /// HTTP 缓存代理
    public static func httpCaching(): Int32 { 4 }
    /// FTP 缓存代理
    public static func ftpCaching(): Int32 { 5 }
}

/// 网络代理配置，描述代理服务器的类型、主机、端口及认证信息
public class QNetworkProxy {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QNetworkProxy already deleted")
        }
    }

    /// 创建默认代理配置（NoProxy）
    public init() {
        unsafe {
            ptr = qNetworkProxyCreate()
            if (ptr == 0) {
                throw CreateFailedException("QNetworkProxy create failed")
            }
        }
    }

    /// 创建指定类型的代理配置
    public init(proxyType: Int32) {
        unsafe {
            ptr = qNetworkProxyCreateWithType(proxyType)
            if (ptr == 0) {
                throw CreateFailedException("QNetworkProxy create failed")
            }
        }
    }

    /// 设置代理类型（ProxyType 常量）
    public func setType(proxyType: Int32): Unit {
        checkValid()
        unsafe { qNetworkProxySetType(ptr, proxyType) }
    }

    /// 获取代理类型（ProxyType 常量）
    public func proxyType(): Int32 {
        checkValid()
        unsafe { qNetworkProxyType(ptr) }
    }

    /// 设置代理服务器主机名
    public func setHostName(host: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(host)
            qNetworkProxySetHostName(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取代理服务器主机名
    public func hostName(): String {
        checkValid()
        unsafe {
            let cstr = qNetworkProxyHostName(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            result
        }
    }

    /// 设置代理服务器端口
    public func setPort(port: UInt16): Unit {
        checkValid()
        unsafe { qNetworkProxySetPort(ptr, port) }
    }

    /// 获取代理服务器端口
    public func port(): UInt16 {
        checkValid()
        unsafe { qNetworkProxyPort(ptr) }
    }

    /// 设置代理认证用户名
    public func setUser(user: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(user)
            qNetworkProxySetUser(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取代理认证用户名
    public func user(): String {
        checkValid()
        unsafe {
            let cstr = qNetworkProxyUser(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            result
        }
    }

    /// 设置代理认证密码
    public func setPassword(pass: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(pass)
            qNetworkProxySetPassword(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取代理认证密码
    public func password(): String {
        checkValid()
        unsafe {
            let cstr = qNetworkProxyPassword(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            result
        }
    }

    /// 设置为应用级代理（静态方法，影响所有网络请求）
    public static func setApplicationProxy(host: String, port: UInt16): Unit {
        unsafe {
            let cstr = LibC.mallocCString(host)
            qNetworkProxySetApplicationProxy(cstr, port)
            LibC.free(cstr)
        }
    }

    /// 获取底层指针
    public func getPtr(): Int64 { ptr }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe { qNetworkProxyDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
