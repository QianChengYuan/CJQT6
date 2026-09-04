package cjqt6.widgets

import cjqt6.core.*

// QUiLoader - Qt Designer .ui 文件加载器
foreign func qUiLoaderCreate(): Int64
foreign func qUiLoaderDelete(ptr: Int64): Unit
foreign func qUiLoaderLoadFile(ptr: Int64, filePath: CString, parentPtr: Int64): Int64
foreign func qUiLoaderSetWorkingDirectory(ptr: Int64, dir: CString): Unit
foreign func qUiLoaderErrorString(ptr: Int64): CString

/// Qt Designer .ui 文件加载器（QtUiTools）
/// 从 .ui 文件静态构建控件树，返回根控件；加载后可用 QWidget.findChild() 按 objectName 获取子控件。
/// 支持资源管理，可使用 try-with-resources 自动释放。
public class QUiLoader <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// 创建加载器
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qUiLoaderCreate()
            if (ptr == 0) {
                throw CreateFailedException("QUiLoader 创建失败")
            }
        }
        trackObject(ptr)
    }

    /// 加载 .ui 文件，返回根控件
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    /// @param filePath .ui 文件路径
    /// @param parentPtr 父控件指针（0 表示无父，返回的控件作为独立顶层窗口）
    /// @return 根控件（parentPtr=0 时拥有所有权，close() 释放；否则由 Qt 父子关系管理）
    public func load(filePath: String, parentPtr: Int64): QWidget {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(filePath)
            let wptr = qUiLoaderLoadFile(ptr, cstr, parentPtr)
            LibC.free(cstr)
            if (wptr == 0) {
                throw CreateFailedException("QUiLoader 加载失败: ${errorString()}")
            }
            if (parentPtr == 0) {
                return QWidget.fromPtrOwned(wptr)
            }
            return QWidget.fromPtr(wptr)
        }
    }

    /// 设置工作目录（.ui 内相对路径资源基于此目录解析）
    public func setWorkingDirectory(dir: String): Unit {
        checkValid()
        unsafe {
            withCString(dir) { c => qUiLoaderSetWorkingDirectory(ptr, c) }
        }
    }

    /// 获取最近一次加载的错误信息
    public func errorString(): String {
        checkValid()
        unsafe {
            let cstr = qUiLoaderErrorString(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 获取原生指针
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
    /// throws: NullPointerException 空指针访问时抛出
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QUiLoader 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QUiLoader 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QUiLoader 底层 Qt 对象已失效")
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
                qUiLoaderDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }

    /// 释放资源（兼容旧API）
    public func delete(): Unit {
        close()
    }
}
