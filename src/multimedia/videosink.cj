package cjqt6.multimedia

import cjqt6.core.*

// ============================================================
// QVideoSink FFI declarations
// ============================================================

foreign func qVideoSinkCreate(): Int64
foreign func qVideoSinkDelete(ptr: Int64): Unit
foreign func qVideoSinkVideoWidth(ptr: Int64): Int32
foreign func qVideoSinkVideoHeight(ptr: Int64): Int32
foreign func qVideoSinkSetSubtitleText(ptr: Int64, text: CString): Unit
foreign func qVideoSinkSubtitleText(ptr: Int64): CString

// ============================================================
// QVideoSink - 视频帧接收端
//
// Qt 6.10.3 的 QVideoSink 继承自 QObject，提供视频帧尺寸、字幕文本等 API。
// 可通过 QMediaCaptureSession::videoSink() 获取已绑定的实例，
// 也可直接创建独立实例用于离屏视频处理。
//
// 注意：Qt5/Qt6 早期版本的 brightness/contrast/hue/saturation 属性
// 在 Qt 6.10.3 中已不存在，视频调节需通过着色器或帧处理实现。
// ============================================================
public class QVideoSink <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    public func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QVideoSink already deleted")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QVideoSink 底层 Qt 对象已失效")
        }
    }

    /// 创建视频接收端
    public init() {
        unsafe {
            ptr = qVideoSinkCreate()
        }
        if (ptr == 0) {
            throw CreateFailedException("QVideoSink create failed")
        }
        trackObject(ptr)
    }

    /// 视频帧宽度
    public func videoWidth(): Int32 {
        checkValid()
        unsafe {
            qVideoSinkVideoWidth(ptr)
        }
    }

    /// 视频帧高度
    public func videoHeight(): Int32 {
        checkValid()
        unsafe {
            qVideoSinkVideoHeight(ptr)
        }
    }

    /// 设置字幕文本
    public func setSubtitleText(text: String): Unit {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(text)
            qVideoSinkSetSubtitleText(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取字幕文本
    public func subtitleText(): String {
        checkValid()
        unsafe {
            let cstr = qVideoSinkSubtitleText(ptr)
            return cstr.toString()
        }
    }

    /// 获取原生指针
    public func getPtr(): Int64 {
        ptr
    }

    /// 是否已关闭
    public func isClosed(): Bool {
        closed
    }

    /// 检查对象有效性
    public func isValid(): Bool {
        !closed && ptr != 0 && isObjectAlive(ptr)
    }

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
            unsafe {
                qVideoSinkDelete(ptr)
            }
            ptr = 0
            closed = true
        }
    }
}
