package cjqt6.widgets

import cjqt6.core.*

// QPushButton - 按钮
foreign func qButtonCreate(): Int64
foreign func qButtonSetText(ptr: Int64, text: CString): Unit
foreign func qButtonConnectClicked(ptr: Int64, callback: VoidCallback): Unit
foreign func qButtonDisconnectClicked(ptr: Int64): Unit
foreign func qButtonSetIcon(ptr: Int64, iconPath: CString): Unit
foreign func qButtonSetIconSize(ptr: Int64, width: Int32, height: Int32): Unit
foreign func qButtonSetMenu(ptr: Int64, menuPtr: Int64): Unit
foreign func qButtonSetStandardIcon(ptr: Int64, iconType: Int32): Unit
foreign func qButtonSetCheckable(ptr: Int64, checkable: Bool): Unit
foreign func qButtonSetChecked(ptr: Int64, checked: Bool): Unit
foreign func qButtonIsChecked(ptr: Int64): Bool
foreign func qButtonText(ptr: Int64): CString
foreign func qButtonSetDefault(ptr: Int64, isDefault: Bool): Unit
foreign func qButtonSetFlat(ptr: Int64, flat: Bool): Unit
foreign func qButtonDelete(ptr: Int64): Unit
foreign func qButtonIconName(ptr: Int64): CString
foreign func qButtonShortcut(ptr: Int64): CString
foreign func qButtonSetShortcut(ptr: Int64, key: CString): Unit
foreign func qButtonIsCheckable(ptr: Int64): Int32
foreign func qButtonIsAutoDefault(ptr: Int64): Int32
foreign func qButtonIsDefault(ptr: Int64): Int32
foreign func qButtonIsFlat(ptr: Int64): Int32
foreign func qButtonIsAutoRepeat(ptr: Int64): Int32
foreign func qButtonSetAutoDefault(ptr: Int64, v: Int32): Unit
foreign func qButtonSetAutoRepeat(ptr: Int64, v: Int32): Unit
foreign func qButtonConnectPressed(ptr: Int64, callback: VoidCallback): Unit
foreign func qButtonConnectReleased(ptr: Int64, callback: VoidCallback): Unit
foreign func qButtonConnectToggled(ptr: Int64, callback: Int32Callback): Unit
foreign func qButtonConnectClickedChecked(ptr: Int64, callback: Int32Callback): Unit
foreign func qButtonDisconnectPressed(ptr: Int64): Unit
foreign func qButtonDisconnectReleased(ptr: Int64): Unit

// P1c：闭包捕获 id 版连接（native 仅保存 id，信号触发时回调顶层调度器）
foreign func qButtonConnectClickedId(ptr: Int64, id: Int64): Unit
foreign func qButtonConnectPressedId(ptr: Int64, id: Int64): Unit
foreign func qButtonConnectReleasedId(ptr: Int64, id: Int64): Unit
foreign func qButtonDisconnectToggled(ptr: Int64): Unit
foreign func qButtonDisconnectClickedChecked(ptr: Int64): Unit

/// 标准图标类型枚举
public class StandardIcon {
    public static let Open: Int32 = 0
    public static let Save: Int32 = 1
    public static let Close: Int32 = 2
    public static let Apply: Int32 = 3
    public static let Cancel: Int32 = 4
    public static let Help: Int32 = 5
    public static let File: Int32 = 6
    public static let Folder: Int32 = 7
    public static let NewFolder: Int32 = 8
    public static let Link: Int32 = 9
    public static let Reload: Int32 = 10
    public static let Stop: Int32 = 11
    public static let MediaPlay: Int32 = 12
    public static let MediaPause: Int32 = 13
    public static let MediaStop: Int32 = 14
    public static let MediaForward: Int32 = 15
    public static let MediaBackward: Int32 = 16
    public static let MediaSkipForward: Int32 = 17
    public static let MediaSkipBackward: Int32 = 18
    public static let ArrowUp: Int32 = 19
    public static let ArrowDown: Int32 = 20
    public static let ArrowLeft: Int32 = 21
    public static let ArrowRight: Int32 = 22
    public static let Yes: Int32 = 23
    public static let No: Int32 = 24
}

/// 按钮部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QPushButton <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    /// 创建按钮
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qButtonCreate()
            if (ptr == 0) {
                throw CreateFailedException("QPushButton 创建失败")
            }
        }
        trackObject(ptr)
    }
    
    /// 显示按钮
    public func show(): Unit {
        checkValid()
        unsafe {
            qWidgetShow(ptr)
        }
    }
    
    /// 隐藏按钮
    public func hide(): Unit {
        checkValid()
        unsafe {
            qWidgetHide(ptr)
        }
    }
    
    /// 设置按钮文本
    public func setText(text: String): Unit {
        checkValid()
        unsafe {
            withCString(text) { c => qButtonSetText(ptr, c) }
        }
    }
    
    /// 获取按钮文本
    public func text(): String {
        checkValid()
        unsafe {
            let cstr = qButtonText(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    /// 设置按钮图标（从文件路径）
    /// 支持格式：PNG, JPG, SVG, ICO 等
    public func setIcon(iconPath: String): Unit {
        checkValid()
        unsafe {
            withCString(iconPath) { c => qButtonSetIcon(ptr, c) }
        }
    }
    
    /// 设置按钮图标大小
    public func setIconSize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qButtonSetIconSize(ptr, width, height)
        }
    }
    
    /// 设置按钮关联菜单（点击按钮弹出下拉菜单）
    /// 参数 menuPtr 为 QMenu.getPtr() 返回值
    public func setMenu(menuPtr: Int64): Unit {
        checkValid()
        unsafe {
            qButtonSetMenu(ptr, menuPtr)
        }
    }
    
    /// 设置按钮使用 Qt 标准图标
    /// 使用 StandardIcon 类中的常量
    public func setStandardIcon(iconType: Int32): Unit {
        checkValid()
        unsafe {
            qButtonSetStandardIcon(ptr, iconType)
        }
    }
    
    /// 调整按钮大小
    public func resize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }
    
    /// 设置样式表
    public func setStyleSheet(style: String): Unit {
        checkValid()
        unsafe {
            withCString(style) { c => qWidgetSetStyleSheet(ptr, c) }
        }
    }

    /// 设置最小尺寸
    public func setMinimumSize(minw: Int32, minh: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetSetMinimumSize(ptr, minw, minh)
        }
    }

    /// 设置最大尺寸
    public func setMaximumSize(maxw: Int32, maxh: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetSetMaximumSize(ptr, maxw, maxh)
        }
    }

    /// 设置启用/禁用
    public func setEnabled(enabled: Bool): Unit {
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
    
    /// 设置点击回调
    public func setOnClick(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qButtonConnectClicked(ptr, callback)
        }
    }

    /// 设置点击回调（可捕获局部变量；P1c 闭包捕获），返回 SignalConnection 句柄
    public func setOnClickCapture(callback: () -> Unit): SignalConnection {
        checkValid()
        let id = registerVoidCallback(callback)
        unsafe {
            qButtonConnectClickedId(ptr, id)
        }
        return SignalConnection.createCapturing(ptr, SIGNAL_CLICKED, WIDGET_TYPE_BUTTON, id)
    }
    
    /// 断开点击信号
    public func disconnectClick(): Unit {
        if (ptr != 0) {
            unsafe {
                qButtonDisconnectClicked(ptr)
            }
        }
    }
    
    /// 设置可勾选
    public func setCheckable(checkable: Bool): Unit {
        checkValid()
        unsafe {
            qButtonSetCheckable(ptr, checkable)
        }
    }
    
    /// 设置勾选状态
    public func setChecked(checked: Bool): Unit {
        checkValid()
        unsafe {
            qButtonSetChecked(ptr, checked)
        }
    }
    
    /// 是否勾选
    public func isChecked(): Bool {
        checkValid()
        unsafe {
            return qButtonIsChecked(ptr)
        }
    }
    
    /// 设置是否默认按钮（回车触发）
    public func setDefault(isDefault: Bool): Unit {
        checkValid()
        unsafe {
            qButtonSetDefault(ptr, isDefault)
        }
    }
    
    /// 设置扁平样式
    public func setFlat(flat: Bool): Unit {
        checkValid()
        unsafe {
            qButtonSetFlat(ptr, flat)
        }
    }
    
    /// 获取图标名称（主题名，文件图标可能为空）
    public func iconName(): String {
        checkValid()
        unsafe {
            let cstr = qButtonIconName(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    /// 设置快捷键（如 "Ctrl+S"）
    public func setShortcut(key: String): Unit {
        checkValid()
        unsafe {
            withCString(key) { c => qButtonSetShortcut(ptr, c) }
        }
    }
    
    /// 获取快捷键字符串
    public func shortcut(): String {
        checkValid()
        unsafe {
            let cstr = qButtonShortcut(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    /// 是否可勾选
    public func isCheckable(): Bool {
        checkValid()
        unsafe {
            return qButtonIsCheckable(ptr) != 0
        }
    }
    
    /// 是否自动默认按钮
    public func isAutoDefault(): Bool {
        checkValid()
        unsafe {
            return qButtonIsAutoDefault(ptr) != 0
        }
    }
    
    /// 设置自动默认按钮
    public func setAutoDefault(autoDefault: Bool): Unit {
        checkValid()
        unsafe {
            qButtonSetAutoDefault(ptr, if (autoDefault) { 1 } else { 0 })
        }
    }
    
    /// 是否默认按钮
    public func isDefault(): Bool {
        checkValid()
        unsafe {
            return qButtonIsDefault(ptr) != 0
        }
    }
    
    /// 是否扁平样式
    public func isFlat(): Bool {
        checkValid()
        unsafe {
            return qButtonIsFlat(ptr) != 0
        }
    }
    
    /// 是否自动重复触发（按下不松时持续触发）
    public func isAutoRepeat(): Bool {
        checkValid()
        unsafe {
            return qButtonIsAutoRepeat(ptr) != 0
        }
    }
    
    /// 设置自动重复触发
    public func setAutoRepeat(autoRepeat: Bool): Unit {
        checkValid()
        unsafe {
            qButtonSetAutoRepeat(ptr, if (autoRepeat) { 1 } else { 0 })
        }
    }
    
    /// 按下回调，返回 SignalConnection 句柄（可 disconnect）
    public func setOnPressed(callback: VoidCallback): SignalConnection {
        checkValid()
        unsafe {
            qButtonConnectPressed(ptr, callback)
        }
        return SignalConnection.createWithWidgetType(ptr, SIGNAL_PRESSED, WIDGET_TYPE_BUTTON)
    }

    /// 按下回调（可捕获局部变量；P1c 闭包捕获），返回 SignalConnection 句柄
    public func setOnPressedCapture(callback: () -> Unit): SignalConnection {
        checkValid()
        let id = registerVoidCallback(callback)
        unsafe {
            qButtonConnectPressedId(ptr, id)
        }
        return SignalConnection.createCapturing(ptr, SIGNAL_PRESSED, WIDGET_TYPE_BUTTON, id)
    }
    
    /// 断开按下信号
    public func disconnectPressed(): Unit {
        if (ptr != 0) {
            unsafe {
                qButtonDisconnectPressed(ptr)
            }
        }
    }
    
    /// 释放回调，返回 SignalConnection 句柄
    public func setOnReleased(callback: VoidCallback): SignalConnection {
        checkValid()
        unsafe {
            qButtonConnectReleased(ptr, callback)
        }
        return SignalConnection.createWithWidgetType(ptr, SIGNAL_RELEASED, WIDGET_TYPE_BUTTON)
    }

    /// 释放回调（可捕获局部变量；P1c 闭包捕获），返回 SignalConnection 句柄
    public func setOnReleasedCapture(callback: () -> Unit): SignalConnection {
        checkValid()
        let id = registerVoidCallback(callback)
        unsafe {
            qButtonConnectReleasedId(ptr, id)
        }
        return SignalConnection.createCapturing(ptr, SIGNAL_RELEASED, WIDGET_TYPE_BUTTON, id)
    }
    
    /// 断开释放信号
    public func disconnectReleased(): Unit {
        if (ptr != 0) {
            unsafe {
                qButtonDisconnectReleased(ptr)
            }
        }
    }
    
    /// 切换状态回调（checked: 0/1），返回 SignalConnection 句柄
    public func setOnToggled(callback: Int32Callback): SignalConnection {
        checkValid()
        unsafe {
            qButtonConnectToggled(ptr, callback)
        }
        return SignalConnection.createWithWidgetType(ptr, SIGNAL_BTN_TOGGLED, WIDGET_TYPE_BUTTON)
    }
    
    /// 断开切换信号
    public func disconnectToggled(): Unit {
        if (ptr != 0) {
            unsafe {
                qButtonDisconnectToggled(ptr)
            }
        }
    }
    
    /// 点击回调（带 checked 状态，0/1），返回 SignalConnection 句柄
    public func setOnClickedChecked(callback: Int32Callback): SignalConnection {
        checkValid()
        unsafe {
            qButtonConnectClickedChecked(ptr, callback)
        }
        return SignalConnection.createWithWidgetType(ptr, SIGNAL_CLICKED_CHECKED, WIDGET_TYPE_BUTTON)
    }
    
    /// 断开带 checked 的点击信号
    public func disconnectClickedChecked(): Unit {
        if (ptr != 0) {
            unsafe {
                qButtonDisconnectClickedChecked(ptr)
            }
        }
    }
    
    /// 断开该按钮的全部信号（clicked/pressed/released/toggled/clickedChecked）
    public func disconnect(): Unit {
        disconnectClick()
        disconnectPressed()
        disconnectReleased()
        disconnectToggled()
        disconnectClickedChecked()
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
            throw ResourceDisposedException("QPushButton 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QPushButton 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QPushButton 底层 Qt 对象已失效")
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
                qButtonDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除按钮（兼容旧API）
    public func delete(): Unit {
        close()
    }
    
    /// 终结器 - 已禁用
    /// 注意：仓颉 GC 调用终结器的时机不确定，可能在 Qt 对象仍被使用时提前删除导致崩溃
    /// 请在不需要时显式调用 delete() 或 close() 释放资源
    // ~init() {
    //     if (!closed && ptr != 0) {
    //         unsafe {
    //             qSignalCleanup(ptr)
    //             qButtonDelete(ptr)
    //         }
    //         closed = true
    //         ptr = 0
    //     }
    // }
}
