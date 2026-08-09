package cjqt6.widgets

import cjqt6.core.*
import cjqt6.paint.*

// QSplashScreen FFI
foreign func qSplashScreenCreate(): Int64
foreign func qSplashScreenCreateWithPixmap(pixmapPtr: Int64): Int64
foreign func qSplashScreenShow(ptr: Int64): Unit
foreign func qSplashScreenFinish(ptr: Int64, windowPtr: Int64): Unit
foreign func qSplashScreenShowMessage(ptr: Int64, message: CString): Unit
foreign func qSplashScreenSetPixmap(ptr: Int64, pixmapPtr: Int64): Unit
foreign func qSplashScreenClearMessage(ptr: Int64): Unit
foreign func qSplashScreenMessage(ptr: Int64): CString
foreign func qSplashScreenShowMessageAlign(ptr: Int64, message: CString, alignment: Int32): Unit
foreign func qSplashScreenDelete(ptr: Int64): Unit

/// 启动画面
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QSplashScreen <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    public init() {
        unsafe {
            ptr = qSplashScreenCreate()
        }
        if (ptr == 0) {
            throw CreateFailedException("QSplashScreen 创建失败")
        }
        trackObject(ptr)
    }

    public init(pixmap: QPixmap) {
        unsafe {
            ptr = qSplashScreenCreateWithPixmap(pixmap.getPtr())
        }
        if (ptr == 0) {
            throw CreateFailedException("QSplashScreen 创建失败")
        }
        trackObject(ptr)
    }

    public func show(): Unit {
        checkValid()
        unsafe { qSplashScreenShow(ptr) }
    }

    public func finish(window: QWidget): Unit {
        checkValid()
        unsafe { qSplashScreenFinish(ptr, window.getPtr()) }
    }

    public func showMessage(message: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(message)
            qSplashScreenShowMessage(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 显示消息并指定对齐方式（alignment 使用 Qt.AlignmentFlag 位，如 AlignLeft|AlignBottom）
    public func showMessage(message: String, alignment: Int32): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(message)
            qSplashScreenShowMessageAlign(ptr, cstr, alignment)
            LibC.free(cstr)
        }
    }

    /// 清除已显示的消息
    public func clearMessage(): Unit {
        checkValid()
        unsafe { qSplashScreenClearMessage(ptr) }
    }

    /// 获取当前显示的消息
    public func message(): String {
        checkValid()
        unsafe {
            let cstr = qSplashScreenMessage(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    public func setPixmap(pixmap: QPixmap): Unit {
        checkValid()
        unsafe { qSplashScreenSetPixmap(ptr, pixmap.getPtr()) }
    }

    public func setEnabled(enabled: Bool): Unit {
        checkValid()
        unsafe { qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 }) }
    }

    public func setStyleSheet(style: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func getPtr(): Int64 {
        return ptr
    }

    /// 是否已关闭
    public func isClosed(): Bool {
        return closed
    }

    /// 检查对象有效性
    public func isValid(): Bool {
        return !closed && ptr != 0 && isObjectAlive(ptr)
    }

    /// 检查有效性，无效时抛出异常
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QSplashScreen 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QSplashScreen 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QSplashScreen 底层 Qt 对象已失效")
        }
    }

    /// 关闭资源，释放Qt对象
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
                qSignalCleanup(ptr)
                qSplashScreenDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }

    /// 删除启动画面（兼容旧API）
    public func delete(): Unit {
        close()
    }
}
