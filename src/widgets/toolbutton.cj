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
foreign func qToolButtonText(ptr: Int64): CString
foreign func qToolButtonDefaultAction(ptr: Int64): Int64
foreign func qToolButtonSetDefaultAction(ptr: Int64, actionPtr: Int64): Unit
foreign func qToolButtonSetIconPath(ptr: Int64, path: CString): Unit
foreign func qToolButtonToolButtonStyle(ptr: Int64): Int32
foreign func qToolButtonConnectPressed(ptr: Int64, callback: VoidCallback): Unit
foreign func qToolButtonConnectReleased(ptr: Int64, callback: VoidCallback): Unit
foreign func qToolButtonConnectClickedChecked(ptr: Int64, callback: Int32Callback): Unit
foreign func qToolButtonDisconnectPressed(ptr: Int64): Unit
foreign func qToolButtonDisconnectReleased(ptr: Int64): Unit
foreign func qToolButtonDisconnectClickedChecked(ptr: Int64): Unit

// P1c：闭包捕获 id 版连接（native 仅保存 id，信号触发时回调顶层调度器）
foreign func qToolButtonConnectClickedId(ptr: Int64, id: Int64): Unit
foreign func qToolButtonConnectPressedId(ptr: Int64, id: Int64): Unit
foreign func qToolButtonConnectReleasedId(ptr: Int64, id: Int64): Unit

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
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QToolButton <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init() {
        unsafe {
            ptr = qToolButtonCreate()
        }
        trackObject(ptr)
    }
    
    public func show() {
        checkValid()
        unsafe {
            qWidgetShow(ptr)
        }
    }
    
    public func hide() {
        checkValid()
        unsafe {
            qWidgetHide(ptr)
        }
    }
    
    public func setText(text: String) {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            qToolButtonSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取文本
    public func text(): String {
        checkValid()
        unsafe {
            let cstr = qToolButtonText(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 获取默认关联动作（返回 QAction* 指针）
    public func defaultAction(): Int64 {
        checkValid()
        unsafe {
            return qToolButtonDefaultAction(ptr)
        }
    }

    /// 设置默认关联动作
    public func setDefaultAction(actionPtr: Int64) {
        checkValid()
        unsafe {
            qToolButtonSetDefaultAction(ptr, actionPtr)
        }
    }

    /// 设置图标
    public func setIcon(iconPtr: Int64) {
        checkValid()
        unsafe {
            qToolButtonSetIcon(ptr, iconPtr)
        }
    }
    
    /// 设置图标大小
    public func setIconSize(width: Int32, height: Int32) {
        checkValid()
        unsafe {
            qToolButtonSetIconSize(ptr, width, height)
        }
    }
    
    /// 设置工具按钮样式
    public func setToolButtonStyle(style: Int32) {
        checkValid()
        unsafe {
            qToolButtonSetToolButtonStyle(ptr, style)
        }
    }
    
    /// 设置弹出模式
    public func setPopupMode(mode: Int32) {
        checkValid()
        unsafe {
            qToolButtonSetPopupMode(ptr, mode)
        }
    }
    
    /// 设置自动凸起
    public func setAutoRaise(enabled: Bool) {
        checkValid()
        unsafe {
            qToolButtonSetAutoRaise(ptr, enabled)
        }
    }
    
    /// 获取自动凸起
    public func autoRaise(): Bool {
        checkValid()
        unsafe {
            return qToolButtonAutoRaise(ptr)
        }
    }
    
    /// 设置箭头类型
    public func setArrowType(arrowType: Int32) {
        checkValid()
        unsafe {
            qToolButtonSetArrowType(ptr, arrowType)
        }
    }
    
    /// 设置关联菜单
    public func setMenu(menuPtr: Int64) {
        checkValid()
        unsafe {
            qToolButtonSetMenu(ptr, menuPtr)
        }
    }
    
    /// 显示菜单
    public func showMenu() {
        checkValid()
        unsafe {
            qToolButtonShowMenu(ptr)
        }
    }
    
    /// 设置启用/禁用
    public func setEnabled(enabled: Bool) {
        checkValid()
        unsafe {
            qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }
    
    /// 检查是否启用
    public func isEnabled(): Bool {
        checkValid()
        unsafe {
            qWidgetIsEnabled(ptr) == 1
        }
    }
    
    /// 设置样式表
    public func setStyleSheet(style: String) {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置最小尺寸
    public func setMinimumSize(minw: Int32, minh: Int32) {
        checkValid()
        unsafe {
            qWidgetSetMinimumSize(ptr, minw, minh)
        }
    }
    
    /// 设置最大尺寸
    public func setMaximumSize(maxw: Int32, maxh: Int32) {
        checkValid()
        unsafe {
            qWidgetSetMaximumSize(ptr, maxw, maxh)
        }
    }
    
    /// 设置点击回调
    public func setOnClick(callback: VoidCallback) {
        checkValid()
        unsafe {
            qToolButtonConnectClicked(ptr, callback)
        }
    }

    /// 设置点击回调（可捕获局部变量；P1c 闭包捕获），返回 SignalConnection 句柄
    public func setOnClickCapture(callback: () -> Unit): SignalConnection {
        checkValid()
        let id = registerVoidCallback(callback)
        unsafe {
            qToolButtonConnectClickedId(ptr, id)
        }
        return SignalConnection.createCapturing(ptr, SIGNAL_CLICKED, WIDGET_TYPE_TOOL_BUTTON, id)
    }
    
    /// 断开点击信号
    public func disconnectClicked() {
        checkValid()
        unsafe {
            qToolButtonDisconnectClicked(ptr)
        }
    }
    
    /// 从文件路径设置图标
    public func setIconFromPath(path: String) {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(path)
            qToolButtonSetIconPath(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取工具按钮样式
    public func toolButtonStyle(): Int32 {
        checkValid()
        unsafe {
            return qToolButtonToolButtonStyle(ptr)
        }
    }
    
    /// 是否自动凸起
    public func isAutoRaise(): Bool {
        checkValid()
        unsafe {
            return qToolButtonAutoRaise(ptr)
        }
    }
    
    /// 按下回调，返回 SignalConnection 句柄（可 disconnect）
    public func setOnPressed(callback: VoidCallback): SignalConnection {
        checkValid()
        unsafe {
            qToolButtonConnectPressed(ptr, callback)
        }
        return SignalConnection.createWithWidgetType(ptr, SIGNAL_PRESSED, WIDGET_TYPE_TOOL_BUTTON)
    }

    /// 按下回调（可捕获局部变量；P1c 闭包捕获），返回 SignalConnection 句柄
    public func setOnPressedCapture(callback: () -> Unit): SignalConnection {
        checkValid()
        let id = registerVoidCallback(callback)
        unsafe {
            qToolButtonConnectPressedId(ptr, id)
        }
        return SignalConnection.createCapturing(ptr, SIGNAL_PRESSED, WIDGET_TYPE_TOOL_BUTTON, id)
    }
    
    /// 断开按下信号
    public func disconnectPressed(): Unit {
        if (ptr != 0) {
            unsafe {
                qToolButtonDisconnectPressed(ptr)
            }
        }
    }
    
    /// 释放回调，返回 SignalConnection 句柄
    public func setOnReleased(callback: VoidCallback): SignalConnection {
        checkValid()
        unsafe {
            qToolButtonConnectReleased(ptr, callback)
        }
        return SignalConnection.createWithWidgetType(ptr, SIGNAL_RELEASED, WIDGET_TYPE_TOOL_BUTTON)
    }

    /// 释放回调（可捕获局部变量；P1c 闭包捕获），返回 SignalConnection 句柄
    public func setOnReleasedCapture(callback: () -> Unit): SignalConnection {
        checkValid()
        let id = registerVoidCallback(callback)
        unsafe {
            qToolButtonConnectReleasedId(ptr, id)
        }
        return SignalConnection.createCapturing(ptr, SIGNAL_RELEASED, WIDGET_TYPE_TOOL_BUTTON, id)
    }
    
    /// 断开释放信号
    public func disconnectReleased(): Unit {
        if (ptr != 0) {
            unsafe {
                qToolButtonDisconnectReleased(ptr)
            }
        }
    }
    
    /// 点击回调（带 checked 状态，0/1），返回 SignalConnection 句柄
    public func setOnClickedChecked(callback: Int32Callback): SignalConnection {
        checkValid()
        unsafe {
            qToolButtonConnectClickedChecked(ptr, callback)
        }
        return SignalConnection.createWithWidgetType(ptr, SIGNAL_CLICKED_CHECKED, WIDGET_TYPE_TOOL_BUTTON)
    }
    
    /// 断开带 checked 的点击信号
    public func disconnectClickedChecked(): Unit {
        if (ptr != 0) {
            unsafe {
                qToolButtonDisconnectClickedChecked(ptr)
            }
        }
    }
    
    /// 断开该工具按钮的全部信号（clicked/pressed/released/clickedChecked）
    public func disconnect(): Unit {
        disconnectClicked()
        disconnectPressed()
        disconnectReleased()
        disconnectClickedChecked()
    }
    
    /// 获取对象指针
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
            throw ResourceDisposedException("QToolButton 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QToolButton 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QToolButton 底层 Qt 对象已失效")
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
                qToolButtonDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除按钮（兼容旧API）
    public func delete(): Unit {
        close()
    }
}
