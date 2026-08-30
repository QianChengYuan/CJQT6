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
foreign func qMenuPopup(ptr: Int64, x: Int32, y: Int32): Unit
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
    
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init(text: String) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            ptr = qActionCreate(cstr)
            LibC.free(cstr)
            if (ptr == 0) {
                throw CreateFailedException("QAction 创建失败")
            }
        }
        trackObject(ptr)
    }
    
    // 内部构造函数（从指针创建，不获取所有权）
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init(ptr: Int64) {
        if (ptr == 0) {
            throw CreateFailedException("QAction 指针为空")
        }
        this.ptr = ptr
        closed = false
    }
    
    public func setText(text: String): Unit {
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
            freeBridgeString(cstr)
            return result
        }
    }
    
    public func setShortcut(shortcut: String): Unit {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(shortcut)
            qActionSetShortcut(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setCheckable(checkable: Bool): Unit {
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
    
    public func setChecked(checked: Bool): Unit {
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
    
    public func setEnabled(enabled: Bool): Unit {
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
    
    public func setVisible(visible: Bool): Unit {
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
    
    public func setOnTriggered(callback: VoidCallback): Unit {
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
    
    public func disconnect(): Unit {
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
        return !closed && ptr != 0 && isObjectAlive(ptr)
    }
    
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QAction 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QAction 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QAction 底层 Qt 对象已失效")
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

/// 菜单类
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QMenu <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    private let ownsPtr: Bool
    
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init(title: String) {
        unsafe {
            var cstr = LibC.mallocCString(title)
            ptr = qMenuCreate(cstr)
            LibC.free(cstr)
            if (ptr == 0) {
                throw CreateFailedException("QMenu 创建失败")
            }
        }
        ownsPtr = true
        trackObject(ptr)
    }
    
    // 内部构造函数（从指针创建，不获取所有权）
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init(ptr: Int64) {
        if (ptr == 0) {
            throw CreateFailedException("QMenu 指针为空")
        }
        this.ptr = ptr
        this.ownsPtr = false
        this.closed = false
    }
    
    public func addAction(text: String): QAction {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(text)
            let actionPtr = qMenuAddAction(ptr, cstr)
            LibC.free(cstr)
            return QAction(actionPtr)
        }
    }
    
    // 通过指针添加已存在的QAction
    public func addActionPtr(actionPtr: Int64): Unit {
        checkValid()
        unsafe {
            qMenuAddActionByPtr(ptr, actionPtr)
        }
    }
    
    public func addSeparator(): Unit {
        checkValid()
        unsafe {
            qMenuAddSeparator(ptr)
        }
    }
    
    public func addMenu(title: String): QMenu {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(title)
            let menuPtr = qMenuAddMenu(ptr, cstr)
            LibC.free(cstr)
            return QMenu(menuPtr)
        }
    }
    
    public func setTitle(title: String): Unit {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(title)
            qMenuSetTitle(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func popup(globalX: Int32, globalY: Int32): Unit {
        checkValid()
        unsafe {
            qMenuPopup(ptr, globalX, globalY)
        }
    }
    
    public func getPtr(): Int64 {
        return ptr
    }
    
    public func isClosed(): Bool {
        return closed
    }
    
    public func isValid(): Bool {
        return !closed && ptr != 0 && isObjectAlive(ptr)
    }
    
    /// throws: NullPointerException 空指针访问时抛出
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QMenu 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QMenu 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QMenu 底层 Qt 对象已失效")
        }
    }
    
    /// 关闭资源，释放Qt对象（仅 ownsPtr=true 时删除C++对象）
    public func close(): Unit {
        if (!closed && ptr != 0 && ownsPtr) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                closed = true
                ptr = 0
                return
            }
            untrackObject(ptr)
            unsafe {
                qMenuDelete(ptr)
            }
        }
        closed = true
        ptr = 0
    }
    
    /// 删除菜单（兼容旧API）
    public func delete(): Unit {
        close()
    }
}

// ============================================================
// QMenuBar - 菜单栏类
// ============================================================

public class QMenuBar <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qMenuBarCreate()
            if (ptr == 0) {
                throw CreateFailedException("QMenuBar 创建失败")
            }
        }
        trackObject(ptr)
    }
    
    public func addMenu(title: String): QMenu {
        checkValid()
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
    
    public func isClosed(): Bool {
        return closed
    }
    
    public func isValid(): Bool {
        return !closed && ptr != 0 && isObjectAlive(ptr)
    }
    
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QMenuBar 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QMenuBar 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QMenuBar 底层 Qt 对象已失效")
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
                qMenuBarDelete(ptr)
            }
        }
        closed = true
        ptr = 0
    }
    
    /// 删除菜单栏（兼容旧API）
    public func delete(): Unit {
        close()
    }
}

// ============================================================
// QToolBar - 工具栏类
// ============================================================

public class QToolBar <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init(title: String) {
        unsafe {
            var cstr = LibC.mallocCString(title)
            ptr = qToolBarCreate(cstr)
            LibC.free(cstr)
            if (ptr == 0) {
                throw CreateFailedException("QToolBar 创建失败")
            }
        }
        trackObject(ptr)
    }
    
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            var cstr = LibC.mallocCString("")
            ptr = qToolBarCreate(cstr)
            LibC.free(cstr)
            if (ptr == 0) {
                throw CreateFailedException("QToolBar 创建失败")
            }
        }
        trackObject(ptr)
    }
    
    public func addAction(actionPtr: Int64): Unit {
        checkValid()
        unsafe {
            qToolBarAddAction(ptr, actionPtr)
        }
    }
    
    public func addSeparator(): Unit {
        checkValid()
        unsafe {
            qToolBarAddSeparator(ptr)
        }
    }
    
    public func addWidget(widgetPtr: Int64): Unit {
        checkValid()
        unsafe {
            qToolBarAddWidget(ptr, widgetPtr)
        }
    }
    
    public func setMovable(movable: Bool): Unit {
        checkValid()
        unsafe {
            qToolBarSetMovable(ptr, movable)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func isClosed(): Bool {
        return closed
    }
    
    public func isValid(): Bool {
        return !closed && ptr != 0 && isObjectAlive(ptr)
    }
    
    /// throws: NullPointerException 空指针访问时抛出
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QToolBar 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QToolBar 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QToolBar 底层 Qt 对象已失效")
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
                qToolBarDelete(ptr)
            }
        }
        closed = true
        ptr = 0
    }
    
    /// 删除工具栏（兼容旧API）
    public func delete(): Unit {
        close()
    }
}

// ============================================================
// QStatusBar - 状态栏类
// ============================================================

public class QStatusBar <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qStatusBarCreate()
            if (ptr == 0) {
                throw CreateFailedException("QStatusBar 创建失败")
            }
        }
        trackObject(ptr)
    }
    
    public func showMessage(message: String): Unit {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(message)
            qStatusBarShowMessage(ptr, cstr, 0)
            LibC.free(cstr)
        }
    }
    
    public func showMessageWithTimeout(message: String, timeout: Int32): Unit {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(message)
            qStatusBarShowMessage(ptr, cstr, timeout)
            LibC.free(cstr)
        }
    }
    
    public func clearMessage(): Unit {
        checkValid()
        unsafe {
            qStatusBarClearMessage(ptr)
        }
    }
    
    public func addWidget(widgetPtr: Int64): Unit {
        checkValid()
        unsafe {
            qStatusBarAddWidget(ptr, widgetPtr, 0)
        }
    }
    
    public func addWidgetWithStretch(widgetPtr: Int64, stretch: Int32): Unit {
        checkValid()
        unsafe {
            qStatusBarAddWidget(ptr, widgetPtr, stretch)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func isClosed(): Bool {
        return closed
    }
    
    public func isValid(): Bool {
        return !closed && ptr != 0 && isObjectAlive(ptr)
    }
    
    /// throws: NullPointerException 空指针访问时抛出
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QStatusBar 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QStatusBar 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QStatusBar 底层 Qt 对象已失效")
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
                qStatusBarDelete(ptr)
            }
        }
        closed = true
        ptr = 0
    }
    
    /// 删除状态栏（兼容旧API）
    public func delete(): Unit {
        close()
    }
}

// ============================================================
// QMainWindow - 主窗口类
// ============================================================

public class QMainWindow <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qMainWindowCreate()
            if (ptr == 0) {
                throw CreateFailedException("QMainWindow 创建失败")
            }
        }
        trackObject(ptr)
    }
    
    public func show(): Unit {
        checkValid()
        unsafe {
            qWidgetShow(ptr)
        }
    }
    
    public func hide(): Unit {
        checkValid()
        unsafe {
            qWidgetHide(ptr)
        }
    }
    
    public func setTitle(title: String): Unit {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(title)
            qMainWindowSetWindowTitle(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func resize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }
    
    public func setMenuBar(menuBarPtr: Int64): Unit {
        checkValid()
        unsafe {
            qMainWindowSetMenuBar(ptr, menuBarPtr)
        }
    }
    
    public func addToolBar(toolBarPtr: Int64): Unit {
        checkValid()
        unsafe {
            qMainWindowAddToolBar(ptr, toolBarPtr)
        }
    }
    
    public func setStatusBar(statusBarPtr: Int64): Unit {
        checkValid()
        unsafe {
            qMainWindowSetStatusBar(ptr, statusBarPtr)
        }
    }
    
    public func setCentralWidget(widgetPtr: Int64): Unit {
        checkValid()
        unsafe {
            qMainWindowSetCentralWidget(ptr, widgetPtr)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func isClosed(): Bool {
        return closed
    }
    
    public func isValid(): Bool {
        return !closed && ptr != 0 && isObjectAlive(ptr)
    }
    
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QMainWindow 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QMainWindow 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QMainWindow 底层 Qt 对象已失效")
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
                qMainWindowDelete(ptr)
            }
        }
        closed = true
        ptr = 0
    }
    
    /// 删除主窗口（兼容旧API）
    public func delete(): Unit {
        close()
    }
}
