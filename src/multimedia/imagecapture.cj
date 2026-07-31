package cjqt6.multimedia

import cjqt6.core.*

// ============================================================
// QImageCapture - 相机图像捕获
// ============================================================

foreign func qImageCaptureCreate(): Int64
foreign func qImageCaptureDelete(ptr: Int64): Unit
foreign func qImageCaptureCapture(ptr: Int64): Int32
foreign func qImageCaptureCaptureToFile(ptr: Int64, path: CString): Int32
foreign func qImageCaptureIsReadyForCapture(ptr: Int64): Bool
foreign func qImageCaptureSetQuality(ptr: Int64, quality: Int32): Unit
foreign func qImageCaptureQuality(ptr: Int64): Int32

/// 图像捕获错误码（与 QImageCapture::Error 枚举对应）
public class ImageCaptureError {
    /// 无错误
    public static func noError(): Int32 { 0 }
    /// 相机未就绪
    public static func notReady(): Int32 { 1 }
    /// 资源错误（相机被占用等）
    public static func resourceError(): Int32 { 2 }
    /// 存储空间不足
    public static func outOfSpace(): Int32 { 3 }
    /// 不支持该操作
    public static func notSupported(): Int32 { 4 }
    /// 文件写入错误
    public static func fileError(): Int32 { 5 }
}

/// 图像捕获质量（与 QImageCapture::Quality 枚举对应）
public class ImageCaptureQuality {
    /// 低质量（小文件）
    public static func lowQuality(): Int32 { 0 }
    /// 普通质量
    public static func normalQuality(): Int32 { 1 }
    /// 高质量（大文件）
    public static func highQuality(): Int32 { 2 }
}

/// 图像捕获器，用于从相机捕获静态图像
public class QImageCapture {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) { throw ResourceDisposedException("QImageCapture already deleted") }
    }

    /// 创建图像捕获器
    public init() { unsafe { ptr = qImageCaptureCreate() } }

    /// 触发捕获，返回错误码（ImageCaptureError）
    public func capture(): Int32 { checkValid(); unsafe { qImageCaptureCapture(ptr) } }

    /// 捕获图像并保存到指定路径，返回错误码（ImageCaptureError）
    public func captureToFile(path: String): Int32 {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(path)
            let result = qImageCaptureCaptureToFile(ptr, cstr)
            LibC.free(cstr)
            result
        }
    }

    /// 相机是否已准备好捕获
    public func isReadyForCapture(): Bool { checkValid(); unsafe { qImageCaptureIsReadyForCapture(ptr) } }

    /// 设置捕获质量（ImageCaptureQuality）
    public func setQuality(quality: Int32): Unit { checkValid(); unsafe { qImageCaptureSetQuality(ptr, quality) } }

    /// 获取捕获质量
    public func quality(): Int32 { checkValid(); unsafe { qImageCaptureQuality(ptr) } }

    /// 获取底层指针
    public func getPtr(): Int64 { ptr }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) { unsafe { qImageCaptureDelete(ptr) }; ptr = 0; closed = true }
    }
}
