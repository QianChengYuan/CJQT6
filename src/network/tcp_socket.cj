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
foreign func qTcpSocketConnectConnected(ptr: Int64, callback: VoidCallback): Unit
foreign func qTcpSocketConnectDisconnected(ptr: Int64, callback: VoidCallback): Unit
foreign func qTcpSocketConnectReadyRead(ptr: Int64, callback: VoidCallback): Unit
foreign func qTcpSocketConnectError(ptr: Int64, callback: VoidCallback): Unit
foreign func qTcpSocketDisconnectCallbacks(ptr: Int64): Unit

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
    public static let UnknownSocketError: Int32 = 11
}

/// TCP套接字
/// 提供TCP客户端功能，支持连接、读写、断开等操作
public class QTcpSocket {
    private var ptr: Int64 = 0
    
    /// 创建TCP套接字
    public init() {
        unsafe {
            ptr = qTcpSocketCreate()
        }
    }
    
    /// 连接到主机
    /// host: 主机地址（IP或域名）
    /// port: 端口号
    public func connectToHost(host: String, port: UInt16): Unit {
        unsafe {
            let cstr = LibC.mallocCString(host)
            qTcpSocketConnectToHost(ptr, cstr, port)
            LibC.free(cstr)
        }
    }
    
    /// 断开连接
    public func disconnectFromHost(): Unit {
        unsafe {
            qTcpSocketDisconnectFromHost(ptr)
        }
    }
    
    /// 写入数据
    /// 返回实际写入的字节数，-1表示错误
    public func write(data: Array<Byte>): Int64 {
        unsafe {
            var handle = acquireArrayRawData(data)
            let result = qTcpSocketWrite(ptr, CPointer<Int8>(handle.pointer), Int64(data.size))
            releaseArrayRawData(handle)
            return result
        }
    }
    
    /// 写入字符串数据
    public func writeString(text: String): Int64 {
        let bytes = text.toArray()
        return write(bytes)
    }
    
    /// 读取数据
    /// maxSize: 最大读取字节数
    /// 返回读取到的字节数组
    public func read(maxSize: Int64): Array<Byte> {
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
        let available = bytesAvailable()
        if (available <= 0) {
            return []
        }
        return read(available)
    }
    
    /// 读取为字符串
    public func readString(maxSize: Int64): String {
        let bytes = read(maxSize)
        return String.fromUtf8(bytes)
    }
    
    /// 可读取字节数
    public func bytesAvailable(): Int64 {
        unsafe {
            return qTcpSocketBytesAvailable(ptr)
        }
    }
    
    /// 待写入字节数
    public func bytesToWrite(): Int64 {
        unsafe {
            return qTcpSocketBytesToWrite(ptr)
        }
    }
    
    /// 刷新缓冲区
    public func flush(): Bool {
        unsafe {
            return qTcpSocketFlush(ptr)
        }
    }
    
    /// 是否到达末尾
    public func atEnd(): Bool {
        unsafe {
            return qTcpSocketAtEnd(ptr)
        }
    }
    
    /// 获取套接字状态
    public func state(): Int32 {
        unsafe {
            return qTcpSocketState(ptr)
        }
    }
    
    /// 获取错误码
    public func error(): Int32 {
        unsafe {
            return qTcpSocketError(ptr)
        }
    }
    
    /// 获取错误描述
    public func errorString(): String {
        unsafe {
            let cstr = qTcpSocketErrorString(ptr)
            return cstr.toString()
        }
    }
    
    /// 是否有效
    public func isValid(): Bool {
        unsafe {
            return qTcpSocketIsValid(ptr)
        }
    }
    
    /// 关闭套接字
    public func close(): Unit {
        unsafe {
            qTcpSocketClose(ptr)
        }
    }
    
    /// 设置连接成功回调
    public func setOnConnected(callback: VoidCallback): Unit {
        unsafe {
            qTcpSocketConnectConnected(ptr, callback)
        }
    }
    
    /// 设置断开连接回调
    public func setOnDisconnected(callback: VoidCallback): Unit {
        unsafe {
            qTcpSocketConnectDisconnected(ptr, callback)
        }
    }
    
    /// 设置数据就绪回调
    public func setOnReadyRead(callback: VoidCallback): Unit {
        unsafe {
            qTcpSocketConnectReadyRead(ptr, callback)
        }
    }
    
    /// 设置错误回调
    public func setOnError(callback: VoidCallback): Unit {
        unsafe {
            qTcpSocketConnectError(ptr, callback)
        }
    }
    
    /// 断开所有信号连接
    public func disconnectCallbacks(): Unit {
        unsafe {
            qTcpSocketDisconnectCallbacks(ptr)
        }
    }
    
    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除套接字
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qTcpSocketDisconnectCallbacks(ptr)
                qTcpSocketDelete(ptr)
            }
            ptr = 0
        }
    }
}
