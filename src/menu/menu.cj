package cjqt6.menu

import cjqt6.core.*

// FFI 声明
// ============================================================

// QWidget公共函数
foreign func qWidgetShow(ptr: Int64): Unit
foreign func qWidgetHide(ptr: Int64): Unit
foreign func qWidgetResize(ptr: Int64, width: Int32, height: Int32): Unit
foreign func qWidgetDelete(ptr: Int64): Unit

// QMenuBar
foreign func qMenuBarCreate(): Int64
foreign func qMenuBarAddMenu(ptr: Int64, title: CString): Int64
foreign func qMenuBarDelete(ptr: Int64): Unit

// QMenu
foreign func qMenuCreate(title: CString): Int64
foreign func qMenuAddAction(ptr: Int64, text: CString): Int64
foreign func qMenuAddActionByPtr(menuPtr: Int64, actionPtr: Int64): Unit
foreign func qMenuAddSeparator(ptr: Int64): Int64
foreign func qMenuAddMenu(ptr: Int64, title: CString): Int64
foreign func qMenuSetTitle(ptr: Int64, title: CString): Unit
foreign func qMenuDelete(ptr: Int64): Unit

// QAction
foreign func qActionCreate(text: CString): Int64
foreign func qActionSetText(ptr: Int64, text: CString): Unit
foreign func qActionText(ptr: Int64): CString
foreign func qActionSetShortcut(ptr: Int64, shortcut: CString): Unit
foreign func qActionSetCheckable(ptr: Int64, checkable: Bool): Unit
foreign func qActionIsCheckable(ptr: Int64): Bool
foreign func qActionSetChecked(ptr: Int64, checked: Bool): Unit
foreign func qActionIsChecked(ptr: Int64): Bool
foreign func qActionSetEnabled(ptr: Int64, enabled: Bool): Unit
foreign func qActionIsEnabled(ptr: Int64): Bool
foreign func qActionSetVisible(ptr: Int64, visible: Bool): Unit
foreign func qActionIsVisible(ptr: Int64): Bool
foreign func qActionConnectTriggered(ptr: Int64, callback: VoidCallback): Unit
foreign func qActionDisconnectTriggered(ptr: Int64): Unit
foreign func qActionDelete(ptr: Int64): Unit

// P1c：闭包捕获 id 版连接（native 仅保存 id，信号触发时回调顶层调度器）
foreign func qActionConnectTriggeredId(ptr: Int64, id: Int64): Unit

// QToolBar
foreign func qToolBarCreate(title: CString): Int64
foreign func qToolBarAddAction(ptr: Int64, actionPtr: Int64): Unit
foreign func qToolBarAddSeparator(ptr: Int64): Unit
foreign func qToolBarAddWidget(ptr: Int64, widgetPtr: Int64): Unit
foreign func qToolBarSetMovable(ptr: Int64, movable: Bool): Unit
foreign func qToolBarDelete(ptr: Int64): Unit

// QStatusBar
foreign func qStatusBarCreate(): Int64
foreign func qStatusBarShowMessage(ptr: Int64, message: CString, timeout: Int32): Unit
foreign func qStatusBarClearMessage(ptr: Int64): Unit
foreign func qStatusBarAddWidget(ptr: Int64, widgetPtr: Int64, stretch: Int32): Unit
foreign func qStatusBarDelete(ptr: Int64): Unit

// QMainWindow
foreign func qMainWindowCreate(): Int64
foreign func qMainWindowSetMenuBar(ptr: Int64, menuBarPtr: Int64): Unit
foreign func qMainWindowAddToolBar(ptr: Int64, toolBarPtr: Int64): Unit
foreign func qMainWindowSetStatusBar(ptr: Int64, statusBarPtr: Int64): Unit
foreign func qMainWindowSetCentralWidget(ptr: Int64, widgetPtr: Int64): Unit
foreign func qMainWindowSetWindowTitle(ptr: Int64, title: CString): Unit
foreign func qMainWindowDelete(ptr: Int64): Unit

// ============================================================
// QAction - 动作类
// ============================================================

public class QAction <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init(text: String) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            ptr = qActionCreate(cstr)
            LibC.free(cstr)
            if (ptr == 0) {
                throw CreateFailedException("QAction 创建失败")
            }
        }
    }
    
    // 内部构造函数（从指针创建，不获取所有权）
    public init(ptr: Int64) {
        if (ptr == 0) {
            throw CreateFailedException("QAction 指针为空")
        }
        this.ptr = ptr
        closed = false
    }
    
    public func setText(text: String) {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(text)
            qActionSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func text(): String {
        checkValid()
        unsafe {
            let cstr = qActionText(ptr)
            let result = cstr.toString()
            return result
        }
    }
    
    public func setShortcut(shortcut: String) {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(shortcut)
            qActionSetShortcut(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setCheckable(checkable: Bool) {
        checkValid()
        unsafe {
            qActionSetCheckable(ptr, checkable)
        }
    }
    
    public func isCheckable(): Bool {
        checkValid()
        unsafe {
            qActionIsCheckable(ptr)
        }
    }
    
    public func setChecked(checked: Bool) {
        checkValid()
        unsafe {
            qActionSetChecked(ptr, checked)
        }
    }
    
    public func isChecked(): Bool {
        checkValid()
        unsafe {
            qActionIsChecked(ptr)
        }
    }
    
    public func setEnabled(enabled: Bool) {
        checkValid()
        unsafe {
            qActionSetEnabled(ptr, enabled)
        }
    }
    
    public func isEnabled(): Bool {
        checkValid()
        unsafe {
            qActionIsEnabled(ptr)
        }
    }
    
    public func setVisible(visible: Bool) {
        checkValid()
        unsafe {
            qActionSetVisible(ptr, visible)
        }
    }
    
    public func isVisible(): Bool {
        checkValid()
        unsafe {
            qActionIsVisible(ptr)
        }
    }
    
    public func setOnTriggered(callback: VoidCallback) {
        checkValid()
        unsafe {
            qActionConnectTriggered(ptr, callback)
        }
    }

    /// 设置触发回调（可捕获局部变量；P1c 闭包捕获），返回 SignalConnection 句柄
    public func setOnTriggeredCapture(callback: () -> Unit): SignalConnection {
        checkValid()
        let id = registerVoidCallback(callback)
        unsafe {
            qActionConnectTriggeredId(ptr, id)
        }
        return SignalConnection.createCapturing(ptr, SIGNAL_TRIGGERED, WIDGET_TYPE_ACTION, id)
    }
    
    public func disconnect() {
        checkValid()
        unsafe {
            qActionDisconnectTriggered(ptr)
        }
    }
    
    public func getPtr(): Int64 {
        return ptr
    }
    
    public func isClosed(): Bool {
        return closed
    }
    
    public func isValid(): Bool {
        return !closed && ptr != 0
    }
    
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QAction 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QAction 指针为空")
        }
    }
    
    /// 关闭资源，释放Qt对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qActionDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除动作（兼容旧API）
    public func delete(): Unit {
        close()
    }
}

// ============================================================
// QMenu - 菜单类
// ============================================================

public class QMenu {
    private let ptr: Int64
    private let ownsPtr: Bool
    
    public init(title: String) {
        unsafe {
            var cstr = LibC.mallocCString(title)
            ptr = qMenuCreate(cstr)
            LibC.free(cstr)
        }
        ownsPtr = true
    }
    
    // 内部构造函数（从指针创建，不获取所有权）
    public init(ptr: Int64) {
        this.ptr = ptr
        this.ownsPtr = false
    }
    
    public func addAction(text: String): QAction {
        unsafe {
            var cstr = LibC.mallocCString(text)
            let actionPtr = qMenuAddAction(ptr, cstr)
            LibC.free(cstr)
            return QAction(actionPtr)
        }
    }
    
    // 通过指针添加已存在的QAction
    public func addActionPtr(actionPtr: Int64) {
        unsafe {
            qMenuAddActionByPtr(ptr, actionPtr)
        }
    }
    
    public func addSeparator() {
        unsafe {
            qMenuAddSeparator(ptr)
        }
    }
    
    public func addMenu(title: String): QMenu {
        unsafe {
            var cstr = LibC.mallocCString(title)
            let menuPtr = qMenuAddMenu(ptr, cstr)
            LibC.free(cstr)
            return QMenu(menuPtr)
        }
    }
    
    public func setTitle(title: String) {
        unsafe {
            var cstr = LibC.mallocCString(title)
            qMenuSetTitle(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0 && ownsPtr) {
            unsafe {
                qMenuDelete(ptr)
            }
        }
    }
}

// ============================================================
// QMenuBar - 菜单栏类
// ============================================================

public class QMenuBar {
    private let ptr: Int64
    
    public init() {
        unsafe {
            ptr = qMenuBarCreate()
        }
    }
    
    public func addMenu(title: String): QMenu {
        unsafe {
            var cstr = LibC.mallocCString(title)
            let menuPtr = qMenuBarAddMenu(ptr, cstr)
            LibC.free(cstr)
            return QMenu(menuPtr)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qMenuBarDelete(ptr)
            }
        }
    }
}

// ============================================================
// QToolBar - 工具栏类
// ============================================================

public class QToolBar {
    private let ptr: Int64
    
    public init(title: String) {
        unsafe {
            var cstr = LibC.mallocCString(title)
            ptr = qToolBarCreate(cstr)
            LibC.free(cstr)
        }
    }
    
    public init() {
        unsafe {
            var cstr = LibC.mallocCString("")
            ptr = qToolBarCreate(cstr)
            LibC.free(cstr)
        }
    }
    
    public func addAction(actionPtr: Int64) {
        unsafe {
            qToolBarAddAction(ptr, actionPtr)
        }
    }
    
    public func addSeparator() {
        unsafe {
            qToolBarAddSeparator(ptr)
        }
    }
    
    public func addWidget(widgetPtr: Int64) {
        unsafe {
            qToolBarAddWidget(ptr, widgetPtr)
        }
    }
    
    public func setMovable(movable: Bool) {
        unsafe {
            qToolBarSetMovable(ptr, movable)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qToolBarDelete(ptr)
            }
        }
    }
}

// ============================================================
// QStatusBar - 状态栏类
// ============================================================

public class QStatusBar {
    private let ptr: Int64
    
    public init() {
        unsafe {
            ptr = qStatusBarCreate()
        }
    }
    
    public func showMessage(message: String) {
        unsafe {
            var cstr = LibC.mallocCString(message)
            qStatusBarShowMessage(ptr, cstr, 0)
            LibC.free(cstr)
        }
    }
    
    public func showMessageWithTimeout(message: String, timeout: Int32) {
        unsafe {
            var cstr = LibC.mallocCString(message)
            qStatusBarShowMessage(ptr, cstr, timeout)
            LibC.free(cstr)
        }
    }
    
    public func clearMessage() {
        unsafe {
            qStatusBarClearMessage(ptr)
        }
    }
    
    public func addWidget(widgetPtr: Int64) {
        unsafe {
            qStatusBarAddWidget(ptr, widgetPtr, 0)
        }
    }
    
    public func addWidgetWithStretch(widgetPtr: Int64, stretch: Int32) {
        unsafe {
            qStatusBarAddWidget(ptr, widgetPtr, stretch)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qStatusBarDelete(ptr)
            }
        }
    }
}

// ============================================================
// QMainWindow - 主窗口类
// ============================================================

public class QMainWindow {
    private let ptr: Int64
    
    public init() {
        unsafe {
            ptr = qMainWindowCreate()
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
    
    public func setTitle(title: String) {
        unsafe {
            var cstr = LibC.mallocCString(title)
            qMainWindowSetWindowTitle(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }
    
    public func setMenuBar(menuBarPtr: Int64) {
        unsafe {
            qMainWindowSetMenuBar(ptr, menuBarPtr)
        }
    }
    
    public func addToolBar(toolBarPtr: Int64) {
        unsafe {
            qMainWindowAddToolBar(ptr, toolBarPtr)
        }
    }
    
    public func setStatusBar(statusBarPtr: Int64) {
        unsafe {
            qMainWindowSetStatusBar(ptr, statusBarPtr)
        }
    }
    
    public func setCentralWidget(widgetPtr: Int64) {
        unsafe {
            qMainWindowSetCentralWidget(ptr, widgetPtr)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qMainWindowDelete(ptr)
            }
        }
    }
}
