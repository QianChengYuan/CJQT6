package cjqt6.widgets

import cjqt6.core.*

// QCommandLinkButton FFI 声明
foreign func qCommandLinkButtonCreate(): Int64
foreign func qCommandLinkButtonCreateWithParent(parentPtr: Int64): Int64
foreign func qCommandLinkButtonSetText(ptr: Int64, text: CString): Unit
foreign func qCommandLinkButtonSetDescription(ptr: Int64, description: CString): Unit
foreign func qCommandLinkButtonDescription(ptr: Int64): CString
foreign func qCommandLinkButtonSetIcon(ptr: Int64, path: CString): Unit
foreign func qCommandLinkButtonSetFlat(ptr: Int64, flat: Int32): Unit
foreign func qCommandLinkButtonIsFlat(ptr: Int64): Int32
foreign func qCommandLinkButtonDelete(ptr: Int64): Unit

/// 命令链接按钮（Vista 风格大按钮，带标题 + 描述文字）
public class QCommandLinkButton {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qCommandLinkButtonCreate()
        }
    }
    
    public init(parent: QWidget) {
        unsafe {
            ptr = qCommandLinkButtonCreateWithParent(parent.getPtr())
        }
    }
    
    public func show(): Unit {
        unsafe { qWidgetShow(ptr) }
    }
    
    public func hide(): Unit {
        unsafe { qWidgetHide(ptr) }
    }
    
    public func resize(width: Int32, height: Int32): Unit {
        unsafe { qWidgetResize(ptr, width, height) }
    }
    
    /// 设置按钮文本（主标题）
    public func setText(text: String): Unit {
        unsafe {
            withCString(text) { c => qCommandLinkButtonSetText(ptr, c) }
        }
    }
    
    /// 设置描述文字（副标题，灰色小字）
    public func setDescription(desc: String): Unit {
        unsafe {
            withCString(desc) { c => qCommandLinkButtonSetDescription(ptr, c) }
        }
    }

    /// 获取描述文字
    public func description(): String {
        unsafe {
            let cstr = qCommandLinkButtonDescription(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 设置图标（按文件路径）
    public func setIcon(path: String): Unit {
        unsafe {
            withCString(path) { c => qCommandLinkButtonSetIcon(ptr, c) }
        }
    }

    /// 设置扁平样式
    public func setFlat(flat: Bool): Unit {
        unsafe { qCommandLinkButtonSetFlat(ptr, if (flat) { 1 } else { 0 }) }
    }

    /// 是否扁平样式
    public func isFlat(): Bool {
        unsafe { return qCommandLinkButtonIsFlat(ptr) != 0 }
    }
    
    /// 设置启用/禁用
    public func setEnabled(enabled: Bool): Unit {
        unsafe { qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 }) }
    }
    
    /// 设置样式表
    public func setStyleSheet(style: String): Unit {
        unsafe {
            withCString(style) { c => qWidgetSetStyleSheet(ptr, c) }
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除部件
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qCommandLinkButtonDelete(ptr)
            }
            ptr = 0
        }
    }
}
