package cjqt6.network

import cjqt6.core.*

// ============================================================
// QNetworkRequest / QNetworkReply / QNetworkAccessManager FFI
// ============================================================

foreign func qNetworkRequestCreate(url: CString): Int64
foreign func qNetworkRequestDelete(ptr: Int64): Unit
foreign func qNetworkRequestSetUrl(ptr: Int64, url: CString): Unit
foreign func qNetworkRequestUrl(ptr: Int64): CString
foreign func qNetworkRequestSetHeader(ptr: Int64, header: Int32, value: CString): Unit
foreign func qNetworkRequestHeader(ptr: Int64, header: Int32): CString
foreign func qNetworkRequestSetRawHeader(ptr: Int64, name: CString, value: CString): Unit
foreign func qNetworkRequestSetTransferTimeout(ptr: Int64, timeoutMs: Int32): Unit

foreign func qNetworkAccessManagerCreate(): Int64
foreign func qNetworkAccessManagerDelete(ptr: Int64): Unit
foreign func qNetworkAccessManagerGet(ptr: Int64, requestPtr: Int64): Int64
foreign func qNetworkAccessManagerPost(ptr: Int64, requestPtr: Int64, data: CString): Int64
foreign func qNetworkAccessManagerPut(ptr: Int64, requestPtr: Int64, data: CString): Int64
foreign func qNetworkAccessManagerDeleteResource(ptr: Int64, requestPtr: Int64): Int64
foreign func qNetworkAccessManagerSetTransferTimeout(ptr: Int64, timeoutMs: Int32): Unit

foreign func qNetworkReplyReadAll(ptr: Int64): CString
foreign func qNetworkReplyBytesAvailable(ptr: Int64): Int64
foreign func qNetworkReplyError(ptr: Int64): Int32
foreign func qNetworkReplyErrorString(ptr: Int64): CString
foreign func qNetworkReplyStatusCode(ptr: Int64): Int32
foreign func qNetworkReplyHeader(ptr: Int64, header: Int32): CString
foreign func qNetworkReplyIsFinished(ptr: Int64): Bool
foreign func qNetworkReplyIsRunning(ptr: Int64): Bool
foreign func qNetworkReplyAbort(ptr: Int64): Unit
foreign func qNetworkReplyClose(ptr: Int64): Unit
foreign func qNetworkReplyDelete(ptr: Int64): Unit
foreign func qNetworkReplyUrl(ptr: Int64): CString
foreign func qNetworkReplyConnectFinished(ptr: Int64, callback: Int64Callback): Unit
foreign func qNetworkReplyDisconnectCallbacks(ptr: Int64): Unit


// ============================================================
// 已知HTTP头常量
// ============================================================
public class KnownHeaders {
    public static func contentType(): Int32 { 0 }
    public static func contentLength(): Int32 { 1 }
    public static func location(): Int32 { 2 }
    public static func lastModified(): Int32 { 3 }
    public static func cookie(): Int32 { 4 }
    public static func setCookie(): Int32 { 5 }
    public static func userAgent(): Int32 { 6 }
    public static func referer(): Int32 { 7 }
    public static func server(): Int32 { 8 }
}


// ============================================================
// QNetworkRequest - 网络请求
// ============================================================
public class QNetworkRequest {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QNetworkRequest already deleted")
        }
    }

    /// 从URL创建网络请求
    public init(url: String) {
        unsafe {
            let cstr = LibC.mallocCString(url)
            ptr = qNetworkRequestCreate(cstr)
            LibC.free(cstr)
            if (ptr == 0) {
                throw CreateFailedException("QNetworkRequest create failed")
            }
        }
    }

    /// 设置URL
    public func setUrl(url: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(url)
            qNetworkRequestSetUrl(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取URL
    public func url(): String {
        checkValid()
        unsafe {
            let cstr = qNetworkRequestUrl(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 设置HTTP头
    public func setHeader(header: Int32, value: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(value)
            qNetworkRequestSetHeader(ptr, header, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取HTTP头
    public func header(header: Int32): String {
        checkValid()
        unsafe {
            let cstr = qNetworkRequestHeader(ptr, header)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 设置原始HTTP头
    public func setRawHeader(name: String, value: String): Unit {
        checkValid()
        unsafe {
            let nstr = LibC.mallocCString(name)
            let vstr = LibC.mallocCString(value)
            qNetworkRequestSetRawHeader(ptr, nstr, vstr)
            LibC.free(nstr)
            LibC.free(vstr)
        }
    }

    /// 设置传输超时（毫秒）
    public func setTransferTimeout(timeoutMs: Int32): Unit {
        checkValid()
        unsafe { qNetworkRequestSetTransferTimeout(ptr, timeoutMs) }
    }

    public func getPtr(): Int64 { ptr }

    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe { qNetworkRequestDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}


// ============================================================
// QNetworkReply - 网络响应
// ============================================================
public class QNetworkReply {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QNetworkReply already deleted")
        }
    }

    internal init(p: Int64) {
        ptr = p
    }

    /// 读取所有响应数据
    public func readAll(): String {
        checkValid()
        unsafe {
            let cstr = qNetworkReplyReadAll(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 获取可用字节数
    public func bytesAvailable(): Int64 {
        checkValid()
        unsafe { qNetworkReplyBytesAvailable(ptr) }
    }

    /// 获取错误码
    public func error(): Int32 {
        checkValid()
        unsafe { qNetworkReplyError(ptr) }
    }

    /// 获取错误描述
    public func errorString(): String {
        checkValid()
        unsafe {
            let cstr = qNetworkReplyErrorString(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 获取HTTP状态码
    public func statusCode(): Int32 {
        checkValid()
        unsafe { qNetworkReplyStatusCode(ptr) }
    }

    /// 获取响应头
    public func header(header: Int32): String {
        checkValid()
        unsafe {
            let cstr = qNetworkReplyHeader(ptr, header)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 请求是否完成
    public func isFinished(): Bool {
        checkValid()
        unsafe { qNetworkReplyIsFinished(ptr) }
    }

    /// 请求是否进行中
    public func isRunning(): Bool {
        checkValid()
        unsafe { qNetworkReplyIsRunning(ptr) }
    }

    /// 中止请求
    public func abort(): Unit {
        checkValid()
        unsafe { qNetworkReplyAbort(ptr) }
    }

    /// 获取请求URL
    public func url(): String {
        checkValid()
        unsafe {
            let cstr = qNetworkReplyUrl(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    // ---- 信号连接 ----

    /// 请求完成时回调（参数为reply指针）
    public func setOnFinished(callback: Int64Callback): Unit {
        checkValid()
        unsafe { qNetworkReplyConnectFinished(ptr, callback) }
    }

    public func getPtr(): Int64 { ptr }

    /// 释放资源（使用deleteLater确保线程安全）
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qNetworkReplyDisconnectCallbacks(ptr)
                qNetworkReplyDelete(ptr)
            }
            ptr = 0
            closed = true
        }
    }
}


// ============================================================
// QNetworkAccessManager - 网络访问管理器
// ============================================================
public class QNetworkAccessManager {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QNetworkAccessManager already deleted")
        }
    }

    public init() {
        unsafe {
            ptr = qNetworkAccessManagerCreate()
            if (ptr == 0) {
                throw CreateFailedException("QNetworkAccessManager create failed")
            }
        }
    }

    /// 发送GET请求
    public func get(request: QNetworkRequest): QNetworkReply {
        checkValid()
        unsafe {
            let replyPtr = qNetworkAccessManagerGet(ptr, request.getPtr())
            if (replyPtr == 0) {
                throw CreateFailedException("QNetworkReply create failed")
            }
            return QNetworkReply(replyPtr)
        }
    }

    /// 发送POST请求
    public func post(request: QNetworkRequest, data: String): QNetworkReply {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(data)
            let replyPtr = qNetworkAccessManagerPost(ptr, request.getPtr(), cstr)
            LibC.free(cstr)
            if (replyPtr == 0) {
                throw CreateFailedException("QNetworkReply create failed")
            }
            return QNetworkReply(replyPtr)
        }
    }

    /// 发送PUT请求
    public func put(request: QNetworkRequest, data: String): QNetworkReply {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(data)
            let replyPtr = qNetworkAccessManagerPut(ptr, request.getPtr(), cstr)
            LibC.free(cstr)
            if (replyPtr == 0) {
                throw CreateFailedException("QNetworkReply create failed")
            }
            return QNetworkReply(replyPtr)
        }
    }

    /// 发送DELETE请求
    public func deleteResource(request: QNetworkRequest): QNetworkReply {
        checkValid()
        unsafe {
            let replyPtr = qNetworkAccessManagerDeleteResource(ptr, request.getPtr())
            if (replyPtr == 0) {
                throw CreateFailedException("QNetworkReply create failed")
            }
            return QNetworkReply(replyPtr)
        }
    }

    /// 设置传输超时（毫秒）
    public func setTransferTimeout(timeoutMs: Int32): Unit {
        checkValid()
        unsafe { qNetworkAccessManagerSetTransferTimeout(ptr, timeoutMs) }
    }

    public func getPtr(): Int64 { ptr }

    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe { qNetworkAccessManagerDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
