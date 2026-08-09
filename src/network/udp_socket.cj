package cjqt6.network

import cjqt6.core.*

// ============================================================
// QUdpSocket - UDP套接字
// ============================================================

foreign func qUdpSocketCreate(): Int64
foreign func qUdpSocketDelete(ptr: Int64): Unit
foreign func qUdpSocketBind(ptr: Int64, address: CString, port: UInt16): Bool
foreign func qUdpSocketClose(ptr: Int64): Unit
foreign func qUdpSocketWriteDatagram(ptr: Int64, data: CPointer<Int8>, size: Int64, host: CString, port: UInt16): Int64
foreign func qUdpSocketReadDatagram(ptr: Int64, buffer: CPointer<Int8>, maxSize: Int64, senderHost: CPointer<Int8>, hostBufferSize: Int64, senderPort: CPointer<UInt16>): Int64
foreign func qUdpSocketHasPendingDatagrams(ptr: Int64): Bool
foreign func qUdpSocketPendingDatagramSize(ptr: Int64): Int64
foreign func qUdpSocketState(ptr: Int64): Int32
foreign func qUdpSocketError(ptr: Int64): Int32
foreign func qUdpSocketErrorString(ptr: Int64): CString
foreign func qUdpSocketIsValid(ptr: Int64): Bool
foreign func qUdpSocketConnectReadyRead(ptr: Int64, callback: VoidCallback): Unit
foreign func qUdpSocketConnectError(ptr: Int64, callback: VoidCallback): Unit
foreign func qUdpSocketDisconnectCallbacks(ptr: Int64): Unit

/// UDP数据报
public class Datagram {
    public var data: Array<Byte>
    public var senderAddress: String
    public var senderPort: UInt16
    
    public init() {
        data = []
        senderAddress = ""
        senderPort = 0
    }
    
    public init(data: Array<Byte>, senderAddress: String, senderPort: UInt16) {
        this.data = data
        this.senderAddress = senderAddress
        this.senderPort = senderPort
    }
}

/// UDP套接字
/// 提供UDP通信功能，支持数据报收发
public class QUdpSocket {
    private var ptr: Int64 = 0
    
    /// 创建UDP套接字
    public init() {
        unsafe {
            ptr = qUdpSocketCreate()
        }
        trackObject(ptr)
    }
    
    /// 绑定到指定地址和端口
    /// address: 绑定地址（空字符串表示任意地址）
    /// port: 端口号
    public func bind(address: String, port: UInt16): Bool {
        unsafe {
            let cstr = LibC.mallocCString(address)
            let result = qUdpSocketBind(ptr, cstr, port)
            LibC.free(cstr)
            return result
        }
    }
    
    /// 绑定到任意地址的指定端口
    public func bind(port: UInt16): Bool {
        return bind("", port)
    }
    
    /// 关闭套接字
    public func close(): Unit {
        unsafe {
            qUdpSocketClose(ptr)
        }
    }
    
    /// 发送数据报
    /// data: 要发送的数据
    /// host: 目标主机地址
    /// port: 目标端口
    /// 返回实际发送的字节数，-1表示错误
    public func writeDatagram(data: Array<Byte>, host: String, port: UInt16): Int64 {
        unsafe {
            var handle = acquireArrayRawData(data)
            let cstr = LibC.mallocCString(host)
            let result = qUdpSocketWriteDatagram(ptr, CPointer<Int8>(handle.pointer), Int64(data.size), cstr, port)
            releaseArrayRawData(handle)
            LibC.free(cstr)
            return result
        }
    }
    
    /// 发送字符串数据报
    public func writeStringDatagram(text: String, host: String, port: UInt16): Int64 {
        let bytes = text.toArray()
        return writeDatagram(bytes, host, port)
    }
    
    /// 读取数据报
    /// 返回Datagram对象，包含数据、发送者地址和端口
    public func readDatagram(): Datagram {
        unsafe {
            let size = pendingDatagramSize()
            if (size <= 0) {
                return Datagram()
            }
            
            let buffer = LibC.malloc<Byte>(count: size)
            let hostBuffer = LibC.malloc<Int8>(count: 256)
            let portPtr = LibC.malloc<UInt16>(count: 1)
            
            let readSize = qUdpSocketReadDatagram(ptr, CPointer<Int8>(buffer), size, CPointer<Int8>(hostBuffer), 256, CPointer<UInt16>(portPtr))
            
            if (readSize <= 0) {
                LibC.free(buffer)
                LibC.free(hostBuffer)
                LibC.free(portPtr)
                return Datagram()
            }
            
            var data: Array<Byte> = []
            for (i in 0..readSize) {
                data = data.concat([buffer.read(i)])
            }
            
            var senderAddressRunes: Array<Rune> = []
            var pos = 0
            while (pos < 256) {
                let b = hostBuffer.read(pos)
                if (b == 0) { break }
                senderAddressRunes = senderAddressRunes.concat([Rune(b)])
                pos += 1
            }
            let senderAddress = String(senderAddressRunes)
            let senderPort = portPtr.read(0)
            
            LibC.free(buffer)
            LibC.free(hostBuffer)
            LibC.free(portPtr)
            
            return Datagram(data, senderAddress, senderPort)
        }
    }
    
    /// 是否有待读取的数据报
    public func hasPendingDatagrams(): Bool {
        unsafe {
            return qUdpSocketHasPendingDatagrams(ptr)
        }
    }
    
    /// 待读取数据报的大小
    public func pendingDatagramSize(): Int64 {
        unsafe {
            return qUdpSocketPendingDatagramSize(ptr)
        }
    }
    
    /// 获取套接字状态
    public func state(): Int32 {
        unsafe {
            return qUdpSocketState(ptr)
        }
    }
    
    /// 获取错误码
    public func error(): Int32 {
        unsafe {
            return qUdpSocketError(ptr)
        }
    }
    
    /// 获取错误描述
    public func errorString(): String {
        unsafe {
            let cstr = qUdpSocketErrorString(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    /// 是否有效
    public func isValid(): Bool {
        unsafe {
            return qUdpSocketIsValid(ptr)
        }
    }
    
    /// 设置数据就绪回调
    public func setOnReadyRead(callback: VoidCallback): Unit {
        unsafe {
            qUdpSocketConnectReadyRead(ptr, callback)
        }
    }
    
    /// 设置错误回调
    public func setOnError(callback: VoidCallback): Unit {
        unsafe {
            qUdpSocketConnectError(ptr, callback)
        }
    }
    
    /// 断开所有信号连接
    public func disconnectCallbacks(): Unit {
        unsafe {
            qUdpSocketDisconnectCallbacks(ptr)
        }
    }
    
    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除套接字
    public func delete(): Unit {
        if (ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                return
            }
            untrackObject(ptr)
            unsafe {
                qUdpSocketDisconnectCallbacks(ptr)
                qUdpSocketDelete(ptr)
            }
            ptr = 0
        }
    }
}
