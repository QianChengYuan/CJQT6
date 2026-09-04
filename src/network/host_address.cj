package cjqt6.network

import cjqt6.core.*

// ============================================================
// QHostAddress - IP地址封装
// ============================================================

foreign func qHostAddressCreate(): Int64
foreign func qHostAddressCreateWithString(address: CString): Int64
foreign func qHostAddressDelete(ptr: Int64): Unit
foreign func qHostAddressSetAddress(ptr: Int64, address: CString): Unit
foreign func qHostAddressToString(ptr: Int64): CString
foreign func qHostAddressProtocol(ptr: Int64): Int32
foreign func qHostAddressIsNull(ptr: Int64): Bool
foreign func qHostAddressEqual(ptr: Int64, address: CString): Bool

/// 网络协议类型
public class NetworkProtocol {
    public static let IPv4: Int32 = 0
    public static let IPv6: Int32 = 1
    public static let AnyIP: Int32 = 2
}

/// IP地址类
/// 支持IPv4和IPv6地址
public class QHostAddress {
    private var ptr: Int64 = 0
    
    /// 创建空地址
    public init() {
        unsafe {
            ptr = qHostAddressCreate()
        }
    }
    
    /// 从字符串创建地址
    /// 支持格式："127.0.0.1"、"::1"、"192.168.1.1"
    public init(address: String) {
        unsafe {
            withCString(address) { c => ptr = qHostAddressCreateWithString(c) }
        }
    }
    
    /// 设置地址
    public func setAddress(address: String): Unit {
        unsafe {
            withCString(address) { c => qHostAddressSetAddress(ptr, c) }
        }
    }
    
    /// 转为字符串
    public func toString(): String {
        unsafe {
            let cstr = qHostAddressToString(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    /// 获取协议类型
    public func protocol(): Int32 {
        unsafe {
            return qHostAddressProtocol(ptr)
        }
    }
    
    /// 是否为空
    public func isNull(): Bool {
        unsafe {
            return qHostAddressIsNull(ptr)
        }
    }
    
    /// 判断是否等于指定地址
    public func equal(address: String): Bool {
        unsafe {
            let cstr = LibC.mallocCString(address)
            let result = qHostAddressEqual(ptr, cstr)
            LibC.free(cstr)
            return result
        }
    }
    
    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除地址对象
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qHostAddressDelete(ptr)
            }
            ptr = 0
        }
    }
}

/// 常用地址常量
public class HostAddress {
    /// 本地回环地址 (127.0.0.1)
    public static func LocalHost(): QHostAddress {
        return QHostAddress("127.0.0.1")
    }
    
    /// IPv6本地回环地址 (::1)
    public static func LocalHostIPv6(): QHostAddress {
        return QHostAddress("::1")
    }
    
    /// 任意地址 (0.0.0.0) - 用于服务器监听
    public static func Any(): QHostAddress {
        return QHostAddress("0.0.0.0")
    }
    
    /// IPv6任意地址 (::)
    public static func AnyIPv6(): QHostAddress {
        return QHostAddress("::")
    }
    
    /// 广播地址 (255.255.255.255)
    public static func Broadcast(): QHostAddress {
        return QHostAddress("255.255.255.255")
    }
}
