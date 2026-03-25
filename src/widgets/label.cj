package CJQT6.widgets

import CJQT6.core.*

// QLabel - 标签
foreign func qLabelCreate(): Int64
foreign func qLabelSetText(ptr: Int64, text: CString): Unit
foreign func qLabelSetAlignment(ptr: Int64, alignment: Int32): Unit
foreign func qLabelSetPixmap(ptr: Int64, pixmapPtr: Int64): Unit
foreign func qLabelDelete(ptr: Int64): Unit

/// 标签部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QLabel <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    /// 创建标签
    public init() {
        unsafe {
            ptr = qLabelCreate()
            if (ptr == 0) {
                throw CreateFailedException("QLabel 创建失败")
            }
        }
    }
    
    /// 显示标签
    public func show(): Unit {
        checkValid()
        unsafe {
            qWidgetShow(ptr)
        }
    }
    
    /// 隐藏标签
    public func hide(): Unit {
        checkValid()
        unsafe {
            qWidgetHide(ptr)
        }
    }
    
    /// 设置标签文本
    public func setText(text: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            qLabelSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置对齐方式
    public func setAlignment(alignment: Int32): Unit {
        checkValid()
        unsafe {
            qLabelSetAlignment(ptr, alignment)
        }
    }
    
    /// 设置图像
    public func setPixmap(pixmapPtr: Int64): Unit {
        checkValid()
        unsafe {
            qLabelSetPixmap(ptr, pixmapPtr)
        }
    }
    
    /// 调整大小
    public func resize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
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
        return !closed && ptr != 0
    }
    
    /// 检查有效性，无效时抛出异常
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QLabel 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QLabel 指针为空")
        }
    }
    
    /// 关闭资源，释放Qt对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qLabelDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除标签（兼容旧API）
    public func delete(): Unit {
        close()
    }
    
    /// 终结器 - 已禁用
    /// 注意：仓颉 GC 调用终结器的时机不确定，可能在 Qt 对象仍被使用时提前删除导致崩溃
    /// 请在不需要时显式调用 delete() 或 close() 释放资源
    // ~init() {
    //     if (!closed && ptr != 0) {
    //         unsafe {
    //             qLabelDelete(ptr)
    //         }
    //         closed = true
    //         ptr = 0
    //     }
    // }
}
