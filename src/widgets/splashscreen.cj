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

public class QSplashScreen {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qSplashScreenCreate()
        }
    }
    
    public init(pixmap: QPixmap) {
        unsafe {
            ptr = qSplashScreenCreateWithPixmap(pixmap.getPtr())
        }
    }
    
    public func show(): Unit {
        unsafe { qSplashScreenShow(ptr) }
    }
    
    public func finish(window: QWidget): Unit {
        unsafe { qSplashScreenFinish(ptr, window.getPtr()) }
    }
    
    public func showMessage(message: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(message)
            qSplashScreenShowMessage(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 显示消息并指定对齐方式（alignment 使用 Qt.AlignmentFlag 位，如 AlignLeft|AlignBottom）
    public func showMessage(message: String, alignment: Int32): Unit {
        unsafe {
            let cstr = LibC.mallocCString(message)
            qSplashScreenShowMessageAlign(ptr, cstr, alignment)
            LibC.free(cstr)
        }
    }

    /// 清除已显示的消息
    public func clearMessage(): Unit {
        unsafe { qSplashScreenClearMessage(ptr) }
    }

    /// 获取当前显示的消息
    public func message(): String {
        unsafe {
            let cstr = qSplashScreenMessage(ptr)
            return cstr.toString()
        }
    }
    
    public func setPixmap(pixmap: QPixmap): Unit {
        unsafe { qSplashScreenSetPixmap(ptr, pixmap.getPtr()) }
    }
    
    public func setEnabled(enabled: Bool): Unit {
        unsafe { qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 }) }
    }
    
    public func setStyleSheet(style: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func getPtr(): Int64 {
        return ptr
    }
    
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qSplashScreenDelete(ptr)
            }
            ptr = 0
        }
    }
}