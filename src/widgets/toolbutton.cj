package cjqt6.widgets

import cjqt6.core.*

// QToolButton - 工具按钮
foreign func qToolButtonCreate(): Int64
foreign func qToolButtonSetText(ptr: Int64, text: CString): Unit
foreign func qToolButtonSetIcon(ptr: Int64, iconPtr: Int64): Unit
foreign func qToolButtonSetIconSize(ptr: Int64, width: Int32, height: Int32): Unit
foreign func qToolButtonSetToolButtonStyle(ptr: Int64, style: Int32): Unit
foreign func qToolButtonSetPopupMode(ptr: Int64, mode: Int32): Unit
foreign func qToolButtonSetAutoRaise(ptr: Int64, enabled: Bool): Unit
foreign func qToolButtonAutoRaise(ptr: Int64): Bool
foreign func qToolButtonSetArrowType(ptr: Int64, arrowType: Int32): Unit
foreign func qToolButtonSetMenu(ptr: Int64, menuPtr: Int64): Unit
foreign func qToolButtonShowMenu(ptr: Int64): Unit
foreign func qToolButtonDelete(ptr: Int64): Unit
foreign func qToolButtonConnectClicked(ptr: Int64, callback: VoidCallback): Unit
foreign func qToolButtonDisconnectClicked(ptr: Int64): Unit

/// 工具按钮样式
public const ToolButtonIconOnly: Int32 = 0        // 只显示图标
public const ToolButtonTextOnly: Int32 = 1        // 只显示文本
public const ToolButtonTextBesideIcon: Int32 = 2  // 文本在图标旁边
public const ToolButtonTextUnderIcon: Int32 = 3   // 文本在图标下方
public const ToolButtonFollowStyle: Int32 = 4     // 跟随样式

/// 弹出模式
public const ToolButtonInstantPopup: Int32 = 0    // 立即弹出
public const ToolButtonMenuButtonPopup: Int32 = 1 // 菜单按钮弹出
public const ToolButtonDelayedPopup: Int32 = 2    // 延迟弹出

/// 箭头类型
public const ArrowNoArrow: Int32 = 0     // 无箭头
public const ArrowUp: Int32 = 1          // 上箭头
public const ArrowDown: Int32 = 2        // 下箭头
public const ArrowLeft: Int32 = 3        // 左箭头
public const ArrowRight: Int32 = 4       // 右箭头

/// 工具按钮部件
public class QToolButton {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qToolButtonCreate()
        }
    }
    
    public func show() {
        unsafe {
            qWidgetShow(ptr)
        }
    }
    
    public func hide() {
        unsafe {
            qWidgetHide(ptr)
        }
    }
    
    public func setText(text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qToolButtonSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置图标
    public func setIcon(iconPtr: Int64) {
        unsafe {
            qToolButtonSetIcon(ptr, iconPtr)
        }
    }
    
    /// 设置图标大小
    public func setIconSize(width: Int32, height: Int32) {
        unsafe {
            qToolButtonSetIconSize(ptr, width, height)
        }
    }
    
    /// 设置工具按钮样式
    public func setToolButtonStyle(style: Int32) {
        unsafe {
            qToolButtonSetToolButtonStyle(ptr, style)
        }
    }
    
    /// 设置弹出模式
    public func setPopupMode(mode: Int32) {
        unsafe {
            qToolButtonSetPopupMode(ptr, mode)
        }
    }
    
    /// 设置自动凸起
    public func setAutoRaise(enabled: Bool) {
        unsafe {
            qToolButtonSetAutoRaise(ptr, enabled)
        }
    }
    
    /// 获取自动凸起
    public func autoRaise(): Bool {
        unsafe {
            return qToolButtonAutoRaise(ptr)
        }
    }
    
    /// 设置箭头类型
    public func setArrowType(arrowType: Int32) {
        unsafe {
            qToolButtonSetArrowType(ptr, arrowType)
        }
    }
    
    /// 设置关联菜单
    public func setMenu(menuPtr: Int64) {
        unsafe {
            qToolButtonSetMenu(ptr, menuPtr)
        }
    }
    
    /// 显示菜单
    public func showMenu() {
        unsafe {
            qToolButtonShowMenu(ptr)
        }
    }
    
    /// 设置启用/禁用
    public func setEnabled(enabled: Bool) {
        unsafe {
            qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }
    
    /// 检查是否启用
    public func isEnabled(): Bool {
        unsafe {
            qWidgetIsEnabled(ptr) == 1
        }
    }
    
    /// 设置样式表
    public func setStyleSheet(style: String) {
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置最小尺寸
    public func setMinimumSize(minw: Int32, minh: Int32) {
        unsafe {
            qWidgetSetMinimumSize(ptr, minw, minh)
        }
    }
    
    /// 设置最大尺寸
    public func setMaximumSize(maxw: Int32, maxh: Int32) {
        unsafe {
            qWidgetSetMaximumSize(ptr, maxw, maxh)
        }
    }
    
    /// 设置点击回调
    public func setOnClick(callback: VoidCallback) {
        unsafe {
            qToolButtonConnectClicked(ptr, callback)
        }
    }
    
    /// 断开点击信号
    public func disconnectClicked() {
        unsafe {
            qToolButtonDisconnectClicked(ptr)
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除按钮
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qToolButtonDelete(ptr)
            }
            ptr = 0
        }
    }
}
