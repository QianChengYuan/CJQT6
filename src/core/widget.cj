package cjqt6.core

// QWidget - 基础窗口部件FFI声明
// QWidget::create() - 创建控件实例
foreign func qWidgetCreate(): Int64
// QWidget::setGeometry() - 设置位置和大小
foreign func qWidgetSetGeometry(ptr: Int64, x: Int32, y: Int32, width: Int32, height: Int32): Unit
// QWidget::setParent() - 设置父控件
foreign func qWidgetSetParent(ptr: Int64, parentPtr: Int64): Unit
// QWidget::move() - 移动控件位置
foreign func qWidgetMove(ptr: Int64, x: Int32, y: Int32): Unit
// QWidget::x() - 获取X坐标
foreign func qWidgetX(ptr: Int64): Int32
// QWidget::y() - 获取Y坐标
foreign func qWidgetY(ptr: Int64): Int32
// QWidget::setFixedSize() - 设置固定大小
foreign func qWidgetSetFixedSize(ptr: Int64, width: Int32, height: Int32): Unit
// QWidget::setWindowIcon() - 设置窗口图标
foreign func qWidgetSetWindowIcon(ptr: Int64, iconPath: CString): Unit
// QWidget::setWindowFlags() - 设置窗口标志
foreign func qWidgetSetWindowFlags(ptr: Int64, flags: Int32): Unit
// QWidget::findChild() - 按 objectName 递归查找子控件（返回 QWidget*，未找到返回 0）
foreign func qWidgetFindChild(ptr: Int64, name: CString): Int64
// QWidget::update() - 请求重绘
foreign func qWidgetUpdate(ptr: Int64): Unit
// QWidget::repaint() - 立即重绘
foreign func qWidgetRepaint(ptr: Int64): Unit

/// 设置控件位置和大小
public func setWidgetGeometry(widgetPtr: Int64, x: Int32, y: Int32, width: Int32, height: Int32): Unit {
    unsafe { qWidgetSetGeometry(widgetPtr, x, y, width, height) }
}

/// 设置父控件
public func setWidgetParent(widgetPtr: Int64, parentPtr: Int64): Unit {
    unsafe { qWidgetSetParent(widgetPtr, parentPtr) }
}

// QWidget 样式表和扩展功能（公共FFI声明在common.cj中集中管理，信号FFI在signal.cj中声明）

/// 基础窗口部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QWidget <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    /// 是否拥有原生对象所有权（fromPtr 包装的指针为 false，close() 只标记关闭不删除）
    private var owned: Bool = true

    /// 从原生指针包装 QWidget（不拥有所有权，close() 不删除底层对象）
    public static func fromPtr(p: Int64): QWidget {
        let w = QWidget()
        untrackObject(w.ptr)
        w.ptr = p
        w.owned = false
        return w
    }

    /// 从原生指针包装 QWidget（拥有所有权，close() 删除底层对象）
    /// 用于 QUiLoader.load 等返回无父顶层控件的场景，避免对象泄漏
    public static func fromPtrOwned(p: Int64): QWidget {
        let w = QWidget()
        untrackObject(w.ptr)
        w.ptr = p
        w.owned = true
        trackObject(p)
        return w
    }

    /// 按 objectName 递归查找子控件（未找到返回无效 QWidget，用 isValid() 判断）
    public func findChild(name: String): QWidget {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(name)
            let childPtr = qWidgetFindChild(ptr, cstr)
            LibC.free(cstr)
            return QWidget.fromPtr(childPtr)
        }
    }

    /// 创建窗口部件
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qWidgetCreate()
            if (ptr == 0) {
                throw CreateFailedException("QWidget 创建失败")
            }
        }
        trackObject(ptr)
    }

    /// 从指针创建（用于继承）
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    protected init(ptr: Int64) {
        if (ptr == 0) {
            throw CreateFailedException("QWidget 指针无效")
        }
        this.ptr = ptr
        trackObject(ptr)
    }

    /// 显示窗口
    public func show(): Unit {
        checkValid()
        unsafe {
            qWidgetShow(ptr)
        }
    }

    /// 隐藏窗口
    public func hide(): Unit {
        checkValid()
        unsafe {
            qWidgetHide(ptr)
        }
    }

    /// 设置窗口标题
    public func setTitle(title: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(title)
            qWidgetSetTitle(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 调整窗口大小
    public func resize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }

    /// 设置窗口位置和大小
    public func setGeometry(x: Int32, y: Int32, width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetSetGeometry(ptr, x, y, width, height)
        }
    }

    /// 设置布局
    public func setLayout(layoutPtr: Int64): Unit {
        checkValid()
        unsafe {
            qWidgetSetLayout(ptr, layoutPtr)
        }
    }

    /// 移动控件到指定位置
    public func move(x: Int32, y: Int32): Unit {
        checkValid();
        unsafe { qWidgetMove(ptr, x, y) }
    }
    /// 获取X坐标
    public func x(): Int32 {
        checkValid();
        unsafe { qWidgetX(ptr) }
    }
    /// 获取Y坐标
    public func y(): Int32 {
        checkValid();
        unsafe { qWidgetY(ptr) }
    }
    /// 设置固定大小
    public func setFixedSize(width: Int32, height: Int32): Unit {
        checkValid();
        unsafe { qWidgetSetFixedSize(ptr, width, height) }
    }
    /// 设置窗口图标
    public func setWindowIcon(iconPath: String): Unit {
        checkValid();
        unsafe {
            let cstr = LibC.mallocCString(iconPath);
            qWidgetSetWindowIcon(ptr, cstr);
            LibC.free(cstr)
        }
    }

    /// 设置窗口标志位（如去除系统标题栏）
    public func setWindowFlags(flags: Int32): Unit {
        checkValid();
        unsafe { qWidgetSetWindowFlags(ptr, flags) }
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
            throw ResourceDisposedException("QWidget 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QWidget 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QWidget 底层 Qt 对象已失效")
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
                if (owned) {
                    qWidgetDelete(ptr)
                }
            }
            closed = true
            ptr = 0
        }
    }

    /// 删除窗口（兼容旧API）
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
    //             qWidgetDelete(ptr)
    //         }
    //         closed = true
    //         ptr = 0
    //     }
    // }

    // ========== 样式表和扩展功能 ==========

    /// 设置样式表
    public func setStyleSheet(styleSheet: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(styleSheet)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取样式表
    public func styleSheet(): String {
        checkValid()
        unsafe {
            let cstr = qWidgetStyleSheet(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 设置启用状态
    public func setEnabled(enabled: Bool): Unit {
        checkValid()
        unsafe {
            qWidgetSetEnabled(ptr, if (enabled) {
                1
            } else {
                0
            })
        }
    }

    /// 是否启用
    public func isEnabled(): Bool {
        checkValid()
        unsafe {
            return qWidgetIsEnabled(ptr) == 1
        }
    }

    /// 设置可见性
    public func setVisible(visible: Bool): Unit {
        checkValid()
        unsafe {
            qWidgetSetVisible(ptr, if (visible) {
                1
            } else {
                0
            })
        }
    }

    /// 是否可见
    public func isVisible(): Bool {
        checkValid()
        unsafe {
            return qWidgetIsVisible(ptr) == 1
        }
    }

    /// 设置工具提示
    public func setToolTip(toolTip: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(toolTip)
            qWidgetSetToolTip(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置最小尺寸
    public func setMinimumSize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetSetMinimumSize(ptr, width, height)
        }
    }

    /// 设置最大尺寸
    public func setMaximumSize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetSetMaximumSize(ptr, width, height)
        }
    }

    /// 设置尺寸策略（水平/垂直），参数为 SizePolicy 常量，如 SizePolicy.Expanding
    public func setSizePolicy(horizontal: Int32, vertical: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetSetSizePolicy(ptr, horizontal, vertical)
        }
    }

    /// 设置尺寸策略（水平/垂直相同），参数为 SizePolicy 常量
    public func setSizePolicy(both: Int32): Unit {
        setSizePolicy(both, both)
    }

    /// 获取水平尺寸策略（返回 SizePolicy 常量值）
    public func sizePolicyHorizontal(): Int32 {
        checkValid()
        unsafe {
            return qWidgetSizePolicyH(ptr)
        }
    }

    /// 获取垂直尺寸策略（返回 SizePolicy 常量值）
    public func sizePolicyVertical(): Int32 {
        checkValid()
        unsafe {
            return qWidgetSizePolicyV(ptr)
        }
    }

    /// 获取宽度
    public func width(): Int32 {
        checkValid()
        unsafe {
            return qWidgetWidth(ptr)
        }
    }

    /// 获取高度
    public func height(): Int32 {
        checkValid()
        unsafe {
            return qWidgetHeight(ptr)
        }
    }

    /// 更新窗口
    public func update(): Unit {
        checkValid()
        unsafe {
            qWidgetUpdate(ptr)
        }
    }

    /// 重绘窗口
    public func repaint(): Unit {
        checkValid()
        unsafe {
            qWidgetRepaint(ptr)
        }
    }

    /// DPI感知的调整窗口大小（逻辑像素）
    public func resizeDp(logicalWidth: Int32, logicalHeight: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetResize(ptr, QScreen.logicalToPhysical(logicalWidth), QScreen.logicalToPhysical(logicalHeight))
        }
    }

    /// DPI感知的设置最小尺寸（逻辑像素）
    public func setMinimumSizeDp(logicalWidth: Int32, logicalHeight: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetSetMinimumSize(ptr, QScreen.logicalToPhysical(logicalWidth), QScreen.logicalToPhysical(logicalHeight))
        }
    }

    /// DPI感知的设置最大尺寸（逻辑像素）
    public func setMaximumSizeDp(logicalWidth: Int32, logicalHeight: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetSetMaximumSize(ptr, QScreen.logicalToPhysical(logicalWidth), QScreen.logicalToPhysical(logicalHeight))
        }
    }

    /// 设置控件销毁回调
    public func setOnDestroyed(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qWidgetConnectDestroyed(ptr, callback)
        }
    }

    /// 设置控件销毁回调（可捕获局部变量；P1c 闭包捕获）
    public func setOnDestroyedCapture(callback: () -> Unit): Unit {
        checkValid()
        let id = registerVoidCallback(callback)
        unsafe {
            qWidgetConnectDestroyedId(ptr, id)
        }
    }

    /// 断开控件销毁信号
    public func disconnectDestroyed(): Unit {
        if (ptr != 0) {
            unsafe {
                qWidgetDisconnectDestroyed(ptr)
            }
        }
    }

    /// 设置窗口关闭回调（可捕获局部变量；事件过滤器拦截 QEvent::Close）
    /// 返回注册表 id，断开连接时传给 disconnectClose 以清理闭包注册
    public func setOnCloseCapture(callback: () -> Unit): Int64 {
        checkValid()
        let id = registerVoidCallback(callback)
        unsafe {
            qWidgetConnectCloseId(ptr, id)
        }
        return id
    }

    /// 断开窗口关闭回调
    public func disconnectClose(callbackId: Int64): Unit {
        if (ptr != 0) {
            unsafe {
                qWidgetDisconnectClose(ptr)
            }
        }
        if (callbackId != 0) {
            unregisterVoidCallback(callbackId)
        }
    }

    /// 断开该控件的全部信号（destroyed）
    public func disconnect(): Unit {
        disconnectDestroyed()
    }
}

// ============================================================
// WindowFlags - 窗口标志常量
// ============================================================

public class WindowFlags {
    public static let Window: Int32 = 1
    public static let Dialog: Int32 = 2
    public static let FramelessWindowHint: Int32 = 2048
    public static let WindowStaysOnTopHint: Int32 = 4096
    public static let WindowMinimizeButtonHint: Int32 = 8
    public static let WindowMaximizeButtonHint: Int32 = 16
    public static let WindowCloseButtonHint: Int32 = 32
}
