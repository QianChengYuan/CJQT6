package cjqt6.widgets

import cjqt6.core.*

// QLabel - 标签
foreign func qLabelCreate(): Int64
foreign func qLabelSetText(ptr: Int64, text: CString): Unit
foreign func qLabelSetAlignment(ptr: Int64, alignment: Int32): Unit
foreign func qLabelAlignment(ptr: Int64): Int32
foreign func qLabelSetPixmap(ptr: Int64, pixmapPtr: Int64): Unit
foreign func qLabelSetPixmapByPath(ptr: Int64, path: CString): Unit
foreign func qLabelSetScaledContents(ptr: Int64, scaled: Bool): Unit
foreign func qLabelIsScaledContents(ptr: Int64): Bool
foreign func qLabelSetIndent(ptr: Int64, indent: Int32): Unit
foreign func qLabelIndent(ptr: Int64): Int32
foreign func qLabelSetMargin(ptr: Int64, margin: Int32): Unit
foreign func qLabelMargin(ptr: Int64): Int32
foreign func qLabelSetOpenExternalLinks(ptr: Int64, open: Bool): Unit
foreign func qLabelSetTextFormat(ptr: Int64, format: Int32): Unit
foreign func qLabelSetBuddy(ptr: Int64, buddyPtr: Int64): Unit
foreign func qLabelText(ptr: Int64): CString
foreign func qLabelSetWordWrap(ptr: Int64, wrap: Bool): Unit
foreign func qLabelWordWrap(ptr: Int64): Bool
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
    
    /// 设置样式表
    public func setStyleSheet(style: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
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
    
    /// 获取对齐方式
    public func alignment(): Int32 {
        checkValid()
        unsafe { qLabelAlignment(ptr) }
    }
    
    /// 通过文件路径设置图像
    public func setPixmapByPath(path: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(path)
            qLabelSetPixmapByPath(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置是否缩放内容以填满标签
    public func setScaledContents(scaled: Bool): Unit {
        checkValid()
        unsafe { qLabelSetScaledContents(ptr, scaled) }
    }
    
    /// 是否缩放内容
    public func isScaledContents(): Bool {
        checkValid()
        unsafe { qLabelIsScaledContents(ptr) }
    }
    
    /// 设置缩进像素
    public func setIndent(indent: Int32): Unit {
        checkValid()
        unsafe { qLabelSetIndent(ptr, indent) }
    }
    
    /// 获取缩进像素（-1 表示未设置）
    public func indent(): Int32 {
        checkValid()
        unsafe { qLabelIndent(ptr) }
    }
    
    /// 设置边距像素
    public func setMargin(margin: Int32): Unit {
        checkValid()
        unsafe { qLabelSetMargin(ptr, margin) }
    }
    
    /// 获取边距像素（-1 表示未设置）
    public func margin(): Int32 {
        checkValid()
        unsafe { qLabelMargin(ptr) }
    }
    
    /// 设置是否允许打开外部链接
    public func setOpenExternalLinks(open: Bool): Unit {
        checkValid()
        unsafe { qLabelSetOpenExternalLinks(ptr, open) }
    }
    
    /// 设置文本格式（使用 LabelTextFormat 常量）
    public func setTextFormat(format: Int32): Unit {
        checkValid()
        unsafe { qLabelSetTextFormat(ptr, format) }
    }
    
    /// 设置伙伴控件（按 Alt+快捷键聚焦）
    public func setBuddy(buddyPtr: Int64): Unit {
        checkValid()
        unsafe { qLabelSetBuddy(ptr, buddyPtr) }
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
    public func text(): String { checkValid(); unsafe { qLabelText(ptr).toString() } }
    public func setWordWrap(wrap: Bool): Unit { checkValid(); unsafe { qLabelSetWordWrap(ptr, wrap) } }
    public func wordWrap(): Bool { checkValid(); unsafe { qLabelWordWrap(ptr) } }

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

/// 标签文本格式常量（对应 Qt::TextFormat）
public class LabelTextFormat {
    public static let PlainText: Int32 = 0
    public static let RichText: Int32 = 1
    public static let AutoText: Int32 = 2
    public static let MarkdownText: Int32 = 3
}
