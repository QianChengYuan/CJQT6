package cjqt6.multimedia

import cjqt6.core.*

// ============================================================
// QCamera / QMediaCaptureSession / QMediaDevices FFI declarations
// ============================================================

foreign func qMediaDevicesDefaultVideoInput(): Int64
foreign func qMediaDevicesVideoInputCount(): Int32
foreign func qCameraDeviceDescription(ptr: Int64): CString
foreign func qCameraDeviceId(ptr: Int64): CString
foreign func qCameraDeviceDelete(ptr: Int64): Unit

foreign func qCameraCreate(devicePtr: Int64): Int64
foreign func qCameraStart(ptr: Int64): Unit
foreign func qCameraStop(ptr: Int64): Unit
foreign func qCameraIsActive(ptr: Int64): Int32
foreign func qCameraErrorCode(ptr: Int64): Int32
foreign func qCameraErrorString(ptr: Int64): CString
foreign func qCameraDelete(ptr: Int64): Unit

foreign func qMediaCaptureSessionCreate(): Int64
foreign func qMediaCaptureSessionSetCamera(ptr: Int64, cameraPtr: Int64): Unit
foreign func qMediaCaptureSessionSetVideoOutput(ptr: Int64, outputPtr: Int64): Unit
foreign func qMediaCaptureSessionDelete(ptr: Int64): Unit


// ============================================================
// QCameraDevice - 摄像头设备描述
// ============================================================
public class QCameraDevice {
    private var ptr: Int64 = 0

    internal init(p: Int64) {
        ptr = p
    }

    /// 获取设备描述
    public func description(): String {
        if (ptr == 0) { return "" }
        unsafe {
            let cstr = qCameraDeviceDescription(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            result
        }
    }

    /// 获取设备ID
    public func id(): String {
        if (ptr == 0) { return "" }
        unsafe {
            let cstr = qCameraDeviceId(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            result
        }
    }

    /// 释放设备描述
    public func getPtr(): Int64 { ptr }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qCameraDeviceDelete(ptr) }
            ptr = 0
        }
    }
}


// ============================================================
// QMediaDevices - 媒体设备信息（静态类）
// ============================================================
public class QMediaDevices {
    /// 获取默认视频输入设备（摄像头）
    public static func defaultVideoInput(): QCameraDevice {
        let p = unsafe { qMediaDevicesDefaultVideoInput() }
        QCameraDevice(p)
    }

    /// 获取可用视频输入设备数量
    public static func videoInputCount(): Int32 {
        unsafe { qMediaDevicesVideoInputCount() }
    }
}


// ============================================================
// QCamera - 摄像头控制
// ============================================================
public class QCamera {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QCamera already deleted")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QCamera 底层 Qt 对象已失效")
        }
    }

    /// 创建摄像头（使用默认设备）
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe { ptr = qCameraCreate(0) }
        if (ptr == 0) {
            throw CreateFailedException("QCamera create failed")
        }
        trackObject(ptr)
    }

    /// 创建摄像头（指定设备）
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init(device: QCameraDevice) {
        unsafe { ptr = qCameraCreate(device.getPtr()) }
        if (ptr == 0) {
            throw CreateFailedException("QCamera create failed")
        }
        trackObject(ptr)
    }

    /// 启动摄像头
    public func start(): Unit {
        checkValid()
        unsafe { qCameraStart(ptr) }
    }

    /// 停止摄像头
    public func stop(): Unit {
        checkValid()
        unsafe { qCameraStop(ptr) }
    }

    /// 摄像头是否活跃
    public func isActive(): Bool {
        checkValid()
        unsafe { qCameraIsActive(ptr) != 0 }
    }

    /// 获取错误码
    public func errorCode(): Int32 {
        checkValid()
        unsafe { qCameraErrorCode(ptr) }
    }

    /// 获取错误描述
    public func errorString(): String {
        checkValid()
        unsafe {
            let cstr = qCameraErrorString(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            result
        }
    }

    /// 获取原生指针
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
            unsafe { qCameraDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}


// ============================================================
// QMediaCaptureSession - 媒体捕获会话
// ============================================================
public class QMediaCaptureSession {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QMediaCaptureSession already deleted")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QMediaCaptureSession 底层 Qt 对象已失效")
        }
    }

    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe { ptr = qMediaCaptureSessionCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QMediaCaptureSession create failed")
        }
        trackObject(ptr)
    }

    /// 设置摄像头
    public func setCamera(cameraPtr: Int64): Unit {
        checkValid()
        unsafe { qMediaCaptureSessionSetCamera(ptr, cameraPtr) }
    }

    /// 设置视频输出（QVideoWidget 指针）
    public func setVideoOutput(outputPtr: Int64): Unit {
        checkValid()
        unsafe { qMediaCaptureSessionSetVideoOutput(ptr, outputPtr) }
    }

    /// 获取原生指针
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
            unsafe { qMediaCaptureSessionDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
