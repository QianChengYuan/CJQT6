package cjqt6.qml

import cjqt6.core.*

// ============================================================
// QML/Qt Quick 模块 FFI 声明
// ============================================================

// QQmlApplicationEngine
foreign func qQmlEngineCreate(): Int64
foreign func qQmlEngineLoadFile(ptr: Int64, filePath: CString): Unit
foreign func qQmlEngineLoadUrl(ptr: Int64, url: CString): Unit
foreign func qQmlEngineLoadData(ptr: Int64, qmlData: CString): Unit
foreign func qQmlEngineClearComponentCache(ptr: Int64): Unit
foreign func qQmlEngineRootObjects(ptr: Int64): Int64
foreign func qQmlEngineRootObjectsCount(ptr: Int64): Int32
foreign func qQmlEngineRootContext(ptr: Int64): Int64
foreign func qQmlEngineSetContextProperty(ptr: Int64, name: CString, valuePtr: Int64): Unit
foreign func qQmlEngineSetContextPropertyString(ptr: Int64, name: CString, value: CString): Unit
foreign func qQmlEngineSetContextPropertyInt(ptr: Int64, name: CString, value: Int32): Unit
foreign func qQmlEngineSetContextPropertyDouble(ptr: Int64, name: CString, value: Float64): Unit
foreign func qQmlEngineSetContextPropertyBool(ptr: Int64, name: CString, value: Int32): Unit
foreign func qQmlEngineAddImportPath(ptr: Int64, path: CString): Unit
foreign func qQmlEngineShowRootWindow(ptr: Int64): Unit
foreign func qQmlEngineDelete(ptr: Int64): Unit

// QQuickView
foreign func qQuickViewCreate(): Int64
foreign func qQuickViewSetSource(ptr: Int64, source: CString): Unit
foreign func qQuickViewSetSourceUrl(ptr: Int64, url: CString): Unit
foreign func qQuickViewShow(ptr: Int64): Unit
foreign func qQuickViewHide(ptr: Int64): Unit
foreign func qQuickViewSetTitle(ptr: Int64, title: CString): Unit
foreign func qQuickViewResize(ptr: Int64, width: Int32, height: Int32): Unit
foreign func qQuickViewRootObject(ptr: Int64): Int64
foreign func qQuickViewSetResizeMode(ptr: Int64, mode: Int32): Unit
foreign func qQuickViewStatus(ptr: Int64): Int32
foreign func qQuickViewErrors(ptr: Int64): Int32
foreign func qQuickViewEngine(ptr: Int64): Int64
foreign func qQuickViewDelete(ptr: Int64): Unit

// QQuickWidget
foreign func qQuickWidgetCreate(): Int64
foreign func qQuickWidgetSetSource(ptr: Int64, source: CString): Unit
foreign func qQuickWidgetSetSourceUrl(ptr: Int64, url: CString): Unit
foreign func qQuickWidgetShow(ptr: Int64): Unit
foreign func qQuickWidgetResize(ptr: Int64, width: Int32, height: Int32): Unit
foreign func qQuickWidgetRootObject(ptr: Int64): Int64
foreign func qQuickWidgetSetResizeMode(ptr: Int64, mode: Int32): Unit
foreign func qQuickWidgetGetPtr(ptr: Int64): Int64
foreign func qQuickWidgetEngine(ptr: Int64): Int64
foreign func qQuickWidgetDelete(ptr: Int64): Unit

// QQuickWindow
foreign func qQuickWindowCreate(): Int64
foreign func qQuickWindowShow(ptr: Int64): Unit
foreign func qQuickWindowHide(ptr: Int64): Unit
foreign func qQuickWindowSetTitle(ptr: Int64, title: CString): Unit
foreign func qQuickWindowResize(ptr: Int64, width: Int32, height: Int32): Unit
foreign func qQuickWindowWidth(ptr: Int64): Int32
foreign func qQuickWindowHeight(ptr: Int64): Int32
foreign func qQuickWindowSetColor(ptr: Int64, r: Int32, g: Int32, b: Int32, a: Int32): Unit
foreign func qQuickWindowIsVisible(ptr: Int64): Int32
foreign func qQuickWindowContentItem(ptr: Int64): Int64
foreign func qQuickWindowDelete(ptr: Int64): Unit

// QQmlComponent
foreign func qQmlComponentCreate(enginePtr: Int64): Int64
foreign func qQmlComponentLoadUrl(ptr: Int64, url: CString): Unit
foreign func qQmlComponentSetData(ptr: Int64, data: CString, url: CString): Unit
foreign func qQmlComponentStatus(ptr: Int64): Int32
foreign func qQmlComponentIsReady(ptr: Int64): Int32
foreign func qQmlComponentIsError(ptr: Int64): Int32
foreign func qQmlComponentErrorString(ptr: Int64): CString
foreign func qQmlComponentCreateObject(ptr: Int64, contextPtr: Int64, parentPtr: Int64): Int64
foreign func qQmlComponentDelete(ptr: Int64): Unit

// QQmlContext
foreign func qQmlContextCreate(parentContextPtr: Int64): Int64
foreign func qQmlContextSetContextProperty(ptr: Int64, name: CString, valuePtr: Int64): Unit
foreign func qQmlContextSetContextPropertyString(ptr: Int64, name: CString, value: CString): Unit
foreign func qQmlContextSetContextPropertyInt(ptr: Int64, name: CString, value: Int32): Unit
foreign func qQmlContextSetContextPropertyDouble(ptr: Int64, name: CString, value: Float64): Unit
foreign func qQmlContextSetContextPropertyBool(ptr: Int64, name: CString, value: Int32): Unit
foreign func qQmlContextSetContextObject(ptr: Int64, objPtr: Int64): Unit
foreign func qQmlContextContextObject(ptr: Int64): Int64
foreign func qQmlContextParentContext(ptr: Int64): Int64
foreign func qQmlContextDelete(ptr: Int64): Unit

// QQuickItem
foreign func qQuickItemCreate(): Int64
foreign func qQuickItemSetVisible(ptr: Int64, visible: Int32): Unit
foreign func qQuickItemIsVisible(ptr: Int64): Int32
foreign func qQuickItemSetEnabled(ptr: Int64, enabled: Int32): Unit
foreign func qQuickItemIsEnabled(ptr: Int64): Int32
foreign func qQuickItemSetX(ptr: Int64, x: Float32): Unit
foreign func qQuickItemSetY(ptr: Int64, y: Float32): Unit
foreign func qQuickItemSetWidth(ptr: Int64, width: Float32): Unit
foreign func qQuickItemSetHeight(ptr: Int64, height: Float32): Unit
foreign func qQuickItemX(ptr: Int64): Float32
foreign func qQuickItemY(ptr: Int64): Float32
foreign func qQuickItemWidth(ptr: Int64): Float32
foreign func qQuickItemHeight(ptr: Int64): Float32
foreign func qQuickItemSetOpacity(ptr: Int64, opacity: Float32): Unit
foreign func qQuickItemOpacity(ptr: Int64): Float32
foreign func qQuickItemSetRotation(ptr: Int64, rotation: Float32): Unit
foreign func qQuickItemRotation(ptr: Int64): Float32
foreign func qQuickItemSetScale(ptr: Int64, scale: Float32): Unit
foreign func qQuickItemScale(ptr: Int64): Float32
foreign func qQuickItemSetZ(ptr: Int64, z: Float32): Unit
foreign func qQuickItemZ(ptr: Int64): Float32
foreign func qQuickItemSetObjectName(ptr: Int64, name: CString): Unit
foreign func qQuickItemObjectName(ptr: Int64): CString
foreign func qQuickItemSetFocus(ptr: Int64, focus: Int32): Unit
foreign func qQuickItemHasFocus(ptr: Int64): Int32
foreign func qQuickItemSetParentItem(ptr: Int64, parentPtr: Int64): Unit
foreign func qQuickItemParentItem(ptr: Int64): Int64
foreign func qQuickItemFindChild(ptr: Int64, name: CString): Int64
foreign func qQuickItemDelete(ptr: Int64): Unit

// QML属性操作
foreign func qQuickItemSetPropertyString(ptr: Int64, name: CString, value: CString): Unit
foreign func qQuickItemSetPropertyInt(ptr: Int64, name: CString, value: Int32): Unit
foreign func qQuickItemSetPropertyDouble(ptr: Int64, name: CString, value: Float64): Unit
foreign func qQuickItemSetPropertyBool(ptr: Int64, name: CString, value: Int32): Unit
foreign func qQuickItemGetPropertyString(ptr: Int64, name: CString): CString
foreign func qQuickItemGetPropertyInt(ptr: Int64, name: CString): Int32
foreign func qQuickItemGetPropertyDouble(ptr: Int64, name: CString): Float64
foreign func qQuickItemGetPropertyBool(ptr: Int64, name: CString): Int32
foreign func qQuickItemFreeString(str: CString): Unit

// QQuickItem 信号连接
foreign func qQuickItemConnectXChanged(ptr: Int64, callback: VoidCallback): Unit
foreign func qQuickItemDisconnectXChanged(ptr: Int64): Unit
foreign func qQuickItemConnectYChanged(ptr: Int64, callback: VoidCallback): Unit
foreign func qQuickItemDisconnectYChanged(ptr: Int64): Unit
foreign func qQuickItemConnectWidthChanged(ptr: Int64, callback: VoidCallback): Unit
foreign func qQuickItemDisconnectWidthChanged(ptr: Int64): Unit
foreign func qQuickItemConnectHeightChanged(ptr: Int64, callback: VoidCallback): Unit
foreign func qQuickItemDisconnectHeightChanged(ptr: Int64): Unit
foreign func qQuickItemConnectOpacityChanged(ptr: Int64, callback: VoidCallback): Unit
foreign func qQuickItemDisconnectOpacityChanged(ptr: Int64): Unit
foreign func qQuickItemConnectRotationChanged(ptr: Int64, callback: VoidCallback): Unit
foreign func qQuickItemDisconnectRotationChanged(ptr: Int64): Unit
foreign func qQuickItemConnectScaleChanged(ptr: Int64, callback: VoidCallback): Unit
foreign func qQuickItemDisconnectScaleChanged(ptr: Int64): Unit
foreign func qQuickItemConnectZChanged(ptr: Int64, callback: VoidCallback): Unit
foreign func qQuickItemDisconnectZChanged(ptr: Int64): Unit
foreign func qQuickItemConnectVisibleChanged(ptr: Int64, callback: VoidCallback): Unit
foreign func qQuickItemDisconnectVisibleChanged(ptr: Int64): Unit
foreign func qQuickItemConnectEnabledChanged(ptr: Int64, callback: VoidCallback): Unit
foreign func qQuickItemDisconnectEnabledChanged(ptr: Int64): Unit
foreign func qQuickItemConnectFocusChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qQuickItemDisconnectFocusChanged(ptr: Int64): Unit
foreign func qQuickItemConnectParentChanged(ptr: Int64, callback: Int64Callback): Unit
foreign func qQuickItemDisconnectParentChanged(ptr: Int64): Unit
foreign func qQuickItemConnectChildrenChanged(ptr: Int64, callback: VoidCallback): Unit
foreign func qQuickItemDisconnectChildrenChanged(ptr: Int64): Unit

// QQuickWindow 信号连接
foreign func qQuickWindowConnectWidthChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qQuickWindowDisconnectWidthChanged(ptr: Int64): Unit
foreign func qQuickWindowConnectHeightChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qQuickWindowDisconnectHeightChanged(ptr: Int64): Unit
foreign func qQuickWindowConnectVisibleChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qQuickWindowDisconnectVisibleChanged(ptr: Int64): Unit

// QQmlComponent 信号连接
foreign func qQmlComponentConnectStatusChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qQmlComponentDisconnectStatusChanged(ptr: Int64): Unit

// 信号清理（非 public foreign 不可跨包引用，需在本包自行声明）
foreign func qSignalCleanup(ptr: Int64): Unit

// ============================================================
// 常量定义
// ============================================================

/// 视图大小调整模式
public class ResizeMode {
    public static let SizeViewToRootObject: Int32 = 0    // 视图大小跟随根项
    public static let SizeRootObjectToView: Int32 = 1    // 根项大小跟随视图
}

/// 状态常量
public class Status {
    public static let Null: Int32 = 0      // 无源
    public static let Ready: Int32 = 1     // 就绪
    public static let Loading: Int32 = 2   // 加载中
    public static let Error: Int32 = 3     // 错误
}

// ============================================================
// QQmlApplicationEngine - QML应用引擎
// ============================================================

/// QML应用引擎，用于加载QML文件
public class QQmlApplicationEngine <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qQmlEngineCreate()
            if (ptr == 0) {
                throw CreateFailedException("QQmlApplicationEngine 创建失败")
            }
        }
        trackObject(ptr)
    }
    
    /// 获取内部指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 加载QML文件
    public func loadFile(filePath: String): Unit {
        checkValid()
        unsafe {
            withCString(filePath) { c => qQmlEngineLoadFile(ptr, c) }
        }
    }
    
    /// 加载URL
    public func loadUrl(url: String): Unit {
        checkValid()
        unsafe {
            withCString(url) { c => qQmlEngineLoadUrl(ptr, c) }
        }
    }
    
    /// 加载QML数据字符串
    public func loadData(qmlData: String): Unit {
        checkValid()
        unsafe {
            withCString(qmlData) { c => qQmlEngineLoadData(ptr, c) }
        }
    }
    
    /// 清除组件缓存
    public func clearComponentCache(): Unit {
        checkValid()
        unsafe {
            qQmlEngineClearComponentCache(ptr)
        }
    }
    
    /// 获取根对象数量
    public func rootObjectsCount(): Int32 {
        checkValid()
        unsafe {
            return qQmlEngineRootObjectsCount(ptr)
        }
    }
    
    /// 获取根对象
    public func rootObject(): QQuickItem {
        checkValid()
        unsafe {
            let itemPtr = qQmlEngineRootObjects(ptr)
            return QQuickItem.fromPtr(itemPtr)
        }
    }
    
    /// 获取根上下文
    public func rootContext(): QQmlContext {
        checkValid()
        unsafe {
            let ctxPtr = qQmlEngineRootContext(ptr)
            return QQmlContext.fromPtr(ctxPtr)
        }
    }
    
    /// 设置上下文属性（对象）
    public func setContextProperty(name: String, valuePtr: Int64): Unit {
        checkValid()
        unsafe {
            withCString(name) { c => qQmlEngineSetContextProperty(ptr, c, valuePtr) }
        }
    }
    
    /// 设置上下文属性（字符串）
    public func setContextPropertyString(name: String, value: String): Unit {
        checkValid()
        unsafe {
            let nameStr = LibC.mallocCString(name)
            let valueStr = LibC.mallocCString(value)
            qQmlEngineSetContextPropertyString(ptr, nameStr, valueStr)
            LibC.free(nameStr)
            LibC.free(valueStr)
        }
    }
    
    /// 设置上下文属性（整数）
    public func setContextPropertyInt(name: String, value: Int32): Unit {
        checkValid()
        unsafe {
            withCString(name) { c => qQmlEngineSetContextPropertyInt(ptr, c, value) }
        }
    }
    
    /// 设置上下文属性（浮点）
    public func setContextPropertyDouble(name: String, value: Float64): Unit {
        checkValid()
        unsafe {
            withCString(name) { c => qQmlEngineSetContextPropertyDouble(ptr, c, value) }
        }
    }
    
    /// 设置上下文属性（布尔）
    public func setContextPropertyBool(name: String, value: Bool): Unit {
        checkValid()
        unsafe {
            let nameStr = LibC.mallocCString(name)
            qQmlEngineSetContextPropertyBool(ptr, nameStr, if (value) { 1 } else { 0 })
            LibC.free(nameStr)
        }
    }
    
    /// 添加导入路径
    public func addImportPath(path: String): Unit {
        checkValid()
        unsafe {
            withCString(path) { c => qQmlEngineAddImportPath(ptr, c) }
        }
    }
    
    /// 显示根窗口（用于 QQmlApplicationEngine 加载 Window 类型的 QML）
    public func showRootWindow(): Unit {
        checkValid()
        unsafe {
            qQmlEngineShowRootWindow(ptr)
        }
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
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QQmlApplicationEngine 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QQmlApplicationEngine 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QQmlApplicationEngine 底层 Qt 对象已失效")
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
                qQmlEngineDelete(ptr)
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

// ============================================================
// QQuickView - QML视图窗口
// ============================================================

/// QML视图窗口，独立的QML窗口
public class QQuickView <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qQuickViewCreate()
            if (ptr == 0) {
                throw CreateFailedException("QQuickView 创建失败（需要 QApplication 实例）")
            }
        }
        trackObject(ptr)
    }
    
    /// 设置QML源文件
    public func setSource(source: String): Unit {
        checkValid()
        unsafe {
            withCString(source) { c => qQuickViewSetSource(ptr, c) }
        }
    }
    
    /// 设置URL源
    public func setSourceUrl(url: String): Unit {
        checkValid()
        unsafe {
            withCString(url) { c => qQuickViewSetSourceUrl(ptr, c) }
        }
    }
    
    /// 显示窗口
    public func show(): Unit {
        checkValid()
        unsafe {
            qQuickViewShow(ptr)
        }
    }
    
    /// 隐藏窗口
    public func hide(): Unit {
        checkValid()
        unsafe {
            qQuickViewHide(ptr)
        }
    }
    
    /// 设置窗口标题
    public func setTitle(title: String): Unit {
        checkValid()
        unsafe {
            withCString(title) { c => qQuickViewSetTitle(ptr, c) }
        }
    }
    
    /// 设置窗口大小
    public func resize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qQuickViewResize(ptr, width, height)
        }
    }
    
    /// 获取根对象
    public func rootObject(): QQuickItem {
        checkValid()
        unsafe {
            let itemPtr = qQuickViewRootObject(ptr)
            return QQuickItem.fromPtr(itemPtr)
        }
    }
    
    /// 设置大小调整模式
    public func setResizeMode(mode: Int32): Unit {
        checkValid()
        unsafe {
            qQuickViewSetResizeMode(ptr, mode)
        }
    }
    
    /// 获取加载状态
    public func status(): Int32 {
        checkValid()
        unsafe {
            return qQuickViewStatus(ptr)
        }
    }
    
    /// 检查是否有错误
    public func hasErrors(): Bool {
        checkValid()
        unsafe {
            return qQuickViewErrors(ptr) != 0
        }
    }
    
    /// 检查是否加载成功
    public func isReady(): Bool {
        checkValid()
        unsafe {
            return qQuickViewStatus(ptr) == Status.Ready
        }
    }
    
    /// 获取引擎指针
    public func engine(): Int64 {
        checkValid()
        unsafe {
            return qQuickViewEngine(ptr)
        }
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
            throw ResourceDisposedException("QQuickView 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QQuickView 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QQuickView 底层 Qt 对象已失效")
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
                qQuickViewDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 释放资源（兼容旧API）
    public func delete(): Unit {
        close()
    }
    
    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }
}

// ============================================================
// QQuickWidget - QML嵌入Widget
// ============================================================

/// QML嵌入Widget，可嵌入到传统Widget布局中
public class QQuickWidget <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qQuickWidgetCreate()
            if (ptr == 0) {
                throw CreateFailedException("QQuickWidget 创建失败（需要 QApplication 实例）")
            }
        }
        trackObject(ptr)
    }
    
    /// 设置QML源文件
    public func setSource(source: String): Unit {
        checkValid()
        unsafe {
            withCString(source) { c => qQuickWidgetSetSource(ptr, c) }
        }
    }
    
    /// 设置URL源
    public func setSourceUrl(url: String): Unit {
        checkValid()
        unsafe {
            withCString(url) { c => qQuickWidgetSetSourceUrl(ptr, c) }
        }
    }
    
    /// 显示
    public func show(): Unit {
        checkValid()
        unsafe {
            qQuickWidgetShow(ptr)
        }
    }
    
    /// 设置大小
    public func resize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qQuickWidgetResize(ptr, width, height)
        }
    }
    
    /// 获取根对象
    public func rootObject(): QQuickItem {
        checkValid()
        unsafe {
            let itemPtr = qQuickWidgetRootObject(ptr)
            return QQuickItem.fromPtr(itemPtr)
        }
    }
    
    /// 设置大小调整模式
    public func setResizeMode(mode: Int32): Unit {
        checkValid()
        unsafe {
            qQuickWidgetSetResizeMode(ptr, mode)
        }
    }
    
    /// 获取引擎指针
    public func engine(): Int64 {
        checkValid()
        unsafe {
            return qQuickWidgetEngine(ptr)
        }
    }
    
    /// 获取指针（用于布局）
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
            throw ResourceDisposedException("QQuickWidget 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QQuickWidget 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QQuickWidget 底层 Qt 对象已失效")
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
                qQuickWidgetDelete(ptr)
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

// ============================================================
// QQuickWindow - QML原生窗口
// ============================================================

/// QML原生窗口（QQuickWindow），可直接显示并承载 QQuickItem 内容
public class QQuickWindow <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qQuickWindowCreate()
            if (ptr == 0) {
                throw CreateFailedException("QQuickWindow 创建失败（需要 QApplication 实例）")
            }
        }
        trackObject(ptr)
    }
    
    /// 显示窗口
    public func show(): Unit {
        checkValid()
        unsafe {
            qQuickWindowShow(ptr)
        }
    }
    
    /// 隐藏窗口
    public func hide(): Unit {
        checkValid()
        unsafe {
            qQuickWindowHide(ptr)
        }
    }
    
    /// 设置窗口标题
    public func setTitle(title: String): Unit {
        checkValid()
        unsafe {
            withCString(title) { c => qQuickWindowSetTitle(ptr, c) }
        }
    }
    
    /// 设置窗口大小
    public func resize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qQuickWindowResize(ptr, width, height)
        }
    }
    
    /// 获取窗口宽度
    public func width(): Int32 {
        checkValid()
        unsafe {
            return qQuickWindowWidth(ptr)
        }
    }
    
    /// 获取窗口高度
    public func height(): Int32 {
        checkValid()
        unsafe {
            return qQuickWindowHeight(ptr)
        }
    }
    
    /// 设置窗口背景色（RGBA 0-255）
    public func setColor(r: Int32, g: Int32, b: Int32, a: Int32): Unit {
        checkValid()
        unsafe {
            qQuickWindowSetColor(ptr, r, g, b, a)
        }
    }
    
    /// 窗口是否可见
    public func isVisible(): Bool {
        checkValid()
        unsafe {
            return qQuickWindowIsVisible(ptr) != 0
        }
    }
    
    /// 获取内容项（根 QQuickItem）
    public func contentItem(): QQuickItem {
        checkValid()
        unsafe {
            let itemPtr = qQuickWindowContentItem(ptr)
            return QQuickItem.fromPtr(itemPtr)
        }
    }
    
    /// 设置宽度变化回调
    public func setOnWidthChanged(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qQuickWindowConnectWidthChanged(ptr, callback)
        }
    }
    
    /// 断开宽度变化信号
    public func disconnectWidthChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qQuickWindowDisconnectWidthChanged(ptr)
            }
        }
    }
    
    /// 设置高度变化回调
    public func setOnHeightChanged(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qQuickWindowConnectHeightChanged(ptr, callback)
        }
    }
    
    /// 断开高度变化信号
    public func disconnectHeightChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qQuickWindowDisconnectHeightChanged(ptr)
            }
        }
    }
    
    /// 设置可见性变化回调
    public func setOnVisibleChanged(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qQuickWindowConnectVisibleChanged(ptr, callback)
        }
    }
    
    /// 断开可见性变化信号
    public func disconnectVisibleChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qQuickWindowDisconnectVisibleChanged(ptr)
            }
        }
    }
    
    /// 断开该窗口的全部信号
    public func disconnect(): Unit {
        disconnectWidthChanged()
        disconnectHeightChanged()
        disconnectVisibleChanged()
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
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QQuickWindow 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QQuickWindow 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QQuickWindow 底层 Qt 对象已失效")
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
                qQuickWindowDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 释放资源（兼容旧API）
    public func delete(): Unit {
        close()
    }
    
    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }
}

// ============================================================
// QQmlComponent - QML组件
// ============================================================

/// QML组件，可从 URL 或字符串数据动态创建 QML 对象
public class QQmlComponent <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    /// 创建组件（需要引擎指针，可用 QQmlApplicationEngine.getPtr() 或 QQuickView.engine()）
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init(enginePtr: Int64) {
        unsafe {
            ptr = qQmlComponentCreate(enginePtr)
            if (ptr == 0) {
                throw CreateFailedException("QQmlComponent 创建失败")
            }
        }
        trackObject(ptr)
    }
    
    /// 从 URL 加载组件
    public func loadUrl(url: String): Unit {
        checkValid()
        unsafe {
            withCString(url) { c => qQmlComponentLoadUrl(ptr, c) }
        }
    }
    
    /// 从字符串数据加载组件
    public func setData(data: String, url!: String = ""): Unit {
        checkValid()
        unsafe {
            let dataStr = LibC.mallocCString(data)
            let urlStr = LibC.mallocCString(url)
            qQmlComponentSetData(ptr, dataStr, urlStr)
            LibC.free(dataStr)
            LibC.free(urlStr)
        }
    }
    
    /// 获取组件状态（Status.Null/Ready/Loading/Error）
    public func status(): Int32 {
        checkValid()
        unsafe {
            return qQmlComponentStatus(ptr)
        }
    }
    
    /// 组件是否就绪
    public func isReady(): Bool {
        checkValid()
        unsafe {
            return qQmlComponentIsReady(ptr) != 0
        }
    }
    
    /// 组件是否有错误
    public func isError(): Bool {
        checkValid()
        unsafe {
            return qQmlComponentIsError(ptr) != 0
        }
    }
    
    /// 获取错误信息
    public func errorString(): String {
        checkValid()
        unsafe {
            let cstr = qQmlComponentErrorString(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    /// 创建对象实例（contextPtr 传 0 表示使用默认上下文；parentPtr 传 0 表示无父对象）
    public func createObject(contextPtr: Int64, parentPtr: Int64): QQuickItem {
        checkValid()
        unsafe {
            let objPtr = qQmlComponentCreateObject(ptr, contextPtr, parentPtr)
            return QQuickItem.fromPtr(objPtr)
        }
    }
    
    /// 设置状态变化回调（Status.Null=0/Ready=1/Loading=2/Error=3）
    public func setOnStatusChanged(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qQmlComponentConnectStatusChanged(ptr, callback)
        }
    }
    
    /// 断开状态变化信号
    public func disconnectStatusChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qQmlComponentDisconnectStatusChanged(ptr)
            }
        }
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
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QQmlComponent 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QQmlComponent 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QQmlComponent 底层 Qt 对象已失效")
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
                qQmlComponentDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 释放资源（兼容旧API）
    public func delete(): Unit {
        close()
    }
    
    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }
}

// ============================================================
// QQmlContext - QML上下文
// ============================================================

/// QML上下文，用于向 QML 暴露 C++ 对象/值
/// 注意：fromPtr 创建的上下文不拥有所有权，close() 只标记关闭；引擎销毁时上下文随之销毁
public class QQmlContext <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    private var owned: Bool = false
    
    private init() {}
    
    /// 从已有指针创建（不拥有所有权，如 engine.rootContext()）
    public static func fromPtr(p: Int64): QQmlContext {
        let ctx = QQmlContext()
        ctx.ptr = p
        ctx.owned = false
        return ctx
    }
    
    /// 创建子上下文（拥有所有权，parentContextPtr 传 0 表示顶层上下文）
    public static func create(parentContextPtr: Int64): QQmlContext {
        let ctx = QQmlContext()
        unsafe {
            ctx.ptr = qQmlContextCreate(parentContextPtr)
        }
        ctx.owned = true
        trackObject(ctx.ptr)
        return ctx
    }
    
    /// 设置上下文属性（对象）
    public func setContextProperty(name: String, valuePtr: Int64): Unit {
        checkValid()
        unsafe {
            withCString(name) { c => qQmlContextSetContextProperty(ptr, c, valuePtr) }
        }
    }
    
    /// 设置上下文属性（字符串）
    public func setContextPropertyString(name: String, value: String): Unit {
        checkValid()
        unsafe {
            let nameStr = LibC.mallocCString(name)
            let valueStr = LibC.mallocCString(value)
            qQmlContextSetContextPropertyString(ptr, nameStr, valueStr)
            LibC.free(nameStr)
            LibC.free(valueStr)
        }
    }
    
    /// 设置上下文属性（整数）
    public func setContextPropertyInt(name: String, value: Int32): Unit {
        checkValid()
        unsafe {
            withCString(name) { c => qQmlContextSetContextPropertyInt(ptr, c, value) }
        }
    }
    
    /// 设置上下文属性（浮点）
    public func setContextPropertyDouble(name: String, value: Float64): Unit {
        checkValid()
        unsafe {
            withCString(name) { c => qQmlContextSetContextPropertyDouble(ptr, c, value) }
        }
    }
    
    /// 设置上下文属性（布尔）
    public func setContextPropertyBool(name: String, value: Bool): Unit {
        checkValid()
        unsafe {
            let nameStr = LibC.mallocCString(name)
            qQmlContextSetContextPropertyBool(ptr, nameStr, if (value) { 1 } else { 0 })
            LibC.free(nameStr)
        }
    }
    
    /// 设置上下文对象
    public func setContextObject(objPtr: Int64): Unit {
        checkValid()
        unsafe {
            qQmlContextSetContextObject(ptr, objPtr)
        }
    }
    
    /// 获取上下文对象指针
    public func contextObject(): Int64 {
        checkValid()
        unsafe {
            return qQmlContextContextObject(ptr)
        }
    }
    
    /// 获取父上下文指针
    public func parentContext(): Int64 {
        checkValid()
        unsafe {
            return qQmlContextParentContext(ptr)
        }
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
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QQmlContext 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QQmlContext 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QQmlContext 底层 Qt 对象已失效")
        }
    }
    
    /// 关闭资源（仅拥有所有权时删除对象）
    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            if (owned) {
                unsafe {
                    qSignalCleanup(ptr)
                    qQmlContextDelete(ptr)
                }
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 释放资源（兼容旧API）
    public func delete(): Unit {
        close()
    }
    
    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }
}

// ============================================================
// QQuickItem - QML项
// ============================================================

/// QML项，QML中的可视元素基类
/// 注意：fromPtr 创建的 QQuickItem 指针由 Qt 管理，close() 只标记关闭，不会删除对象；
/// 通过 init() 创建的独立项拥有所有权，close() 会释放对象
public class QQuickItem <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    private var owned: Bool = false
    
    private init() {}
    
    /// 创建独立 QML 项（拥有所有权）
    public static func create(): QQuickItem {
        let item = QQuickItem()
        unsafe {
            item.ptr = qQuickItemCreate()
        }
        item.owned = true
        trackObject(item.ptr)
        return item
    }
    
    /// 从指针创建（不拥有所有权，由 Qt 管理）
    public static func fromPtr(p: Int64): QQuickItem {
        let item = QQuickItem()
        item.ptr = p
        item.owned = false
        return item
    }
    
    /// 检查指针是否有效
    public func isValid(): Bool {
        return !closed && ptr != 0 && isObjectAlive(ptr)
    }
    
    /// 是否已关闭
    public func isClosed(): Bool {
        return closed
    }
    
    /// 检查有效性，无效时抛出异常
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QQuickItem 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QQuickItem 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QQuickItem 底层 Qt 对象已失效")
        }
    }
    
    /// 关闭资源（仅拥有所有权时删除对象；借用指针只标记关闭并断开信号）
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
                    qQuickItemDelete(ptr)
                }
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 释放资源（兼容旧API）
    public func delete(): Unit {
        close()
    }
    
    /// 设置可见性
    public func setVisible(visible: Bool): Unit {
        checkValid()
        unsafe {
            qQuickItemSetVisible(ptr, if (visible) { 1 } else { 0 })
        }
    }
    
    /// 是否可见
    public func isVisible(): Bool {
        checkValid()
        unsafe {
            return qQuickItemIsVisible(ptr) != 0
        }
    }
    
    /// 设置启用状态
    public func setEnabled(enabled: Bool): Unit {
        checkValid()
        unsafe {
            qQuickItemSetEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }
    
    /// 是否启用
    public func isEnabled(): Bool {
        checkValid()
        unsafe {
            return qQuickItemIsEnabled(ptr) != 0
        }
    }
    
    /// 设置X坐标
    public func setX(x: Float32): Unit {
        checkValid()
        unsafe {
            qQuickItemSetX(ptr, x)
        }
    }
    
    /// 设置Y坐标
    public func setY(y: Float32): Unit {
        checkValid()
        unsafe {
            qQuickItemSetY(ptr, y)
        }
    }
    
    /// 设置宽度
    public func setWidth(width: Float32): Unit {
        checkValid()
        unsafe {
            qQuickItemSetWidth(ptr, width)
        }
    }
    
    /// 设置高度
    public func setHeight(height: Float32): Unit {
        checkValid()
        unsafe {
            qQuickItemSetHeight(ptr, height)
        }
    }
    
    /// 获取X坐标
    public func x(): Float32 {
        checkValid()
        unsafe {
            return qQuickItemX(ptr)
        }
    }
    
    /// 获取Y坐标
    public func y(): Float32 {
        checkValid()
        unsafe {
            return qQuickItemY(ptr)
        }
    }
    
    /// 获取宽度
    public func width(): Float32 {
        checkValid()
        unsafe {
            return qQuickItemWidth(ptr)
        }
    }
    
    /// 获取高度
    public func height(): Float32 {
        checkValid()
        unsafe {
            return qQuickItemHeight(ptr)
        }
    }
    
    /// 设置不透明度（0.0 ~ 1.0）
    public func setOpacity(opacity: Float32): Unit {
        checkValid()
        unsafe {
            qQuickItemSetOpacity(ptr, opacity)
        }
    }
    
    /// 获取不透明度
    public func opacity(): Float32 {
        checkValid()
        unsafe {
            return qQuickItemOpacity(ptr)
        }
    }
    
    /// 设置旋转角度（度）
    public func setRotation(rotation: Float32): Unit {
        checkValid()
        unsafe {
            qQuickItemSetRotation(ptr, rotation)
        }
    }
    
    /// 获取旋转角度
    public func rotation(): Float32 {
        checkValid()
        unsafe {
            return qQuickItemRotation(ptr)
        }
    }
    
    /// 设置缩放比例
    public func setScale(scale: Float32): Unit {
        checkValid()
        unsafe {
            qQuickItemSetScale(ptr, scale)
        }
    }
    
    /// 获取缩放比例
    public func scale(): Float32 {
        checkValid()
        unsafe {
            return qQuickItemScale(ptr)
        }
    }
    
    /// 设置Z轴层级
    public func setZ(z: Float32): Unit {
        checkValid()
        unsafe {
            qQuickItemSetZ(ptr, z)
        }
    }
    
    /// 获取Z轴层级
    public func z(): Float32 {
        checkValid()
        unsafe {
            return qQuickItemZ(ptr)
        }
    }
    
    /// 设置对象名称
    public func setObjectName(name: String): Unit {
        checkValid()
        unsafe {
            withCString(name) { c => qQuickItemSetObjectName(ptr, c) }
        }
    }
    
    /// 获取对象名称
    public func objectName(): String {
        checkValid()
        unsafe {
            let cstr = qQuickItemObjectName(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    /// 设置焦点
    public func setFocus(focus: Bool): Unit {
        checkValid()
        unsafe {
            qQuickItemSetFocus(ptr, if (focus) { 1 } else { 0 })
        }
    }
    
    /// 是否拥有焦点
    public func hasFocus(): Bool {
        checkValid()
        unsafe {
            return qQuickItemHasFocus(ptr) != 0
        }
    }
    
    /// 设置父项
    public func setParentItem(parent: QQuickItem): Unit {
        checkValid()
        unsafe {
            qQuickItemSetParentItem(ptr, parent.getPtr())
        }
    }
    
    /// 获取父项指针
    public func parentItem(): Int64 {
        checkValid()
        unsafe {
            return qQuickItemParentItem(ptr)
        }
    }
    
    /// 查找子项
    public func findChild(name: String): QQuickItem {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(name)
            let childPtr = qQuickItemFindChild(ptr, cstr)
            LibC.free(cstr)
            return QQuickItem.fromPtr(childPtr)
        }
    }
    
    /// 设置属性（字符串）
    public func setProperty(name: String, value: String): Unit {
        checkValid()
        unsafe {
            let nameStr = LibC.mallocCString(name)
            let valueStr = LibC.mallocCString(value)
            qQuickItemSetPropertyString(ptr, nameStr, valueStr)
            LibC.free(nameStr)
            LibC.free(valueStr)
        }
    }
    
    /// 设置属性（整数）
    public func setPropertyInt(name: String, value: Int32): Unit {
        checkValid()
        unsafe {
            withCString(name) { c => qQuickItemSetPropertyInt(ptr, c, value) }
        }
    }
    
    /// 设置属性（浮点）
    public func setPropertyDouble(name: String, value: Float64): Unit {
        checkValid()
        unsafe {
            withCString(name) { c => qQuickItemSetPropertyDouble(ptr, c, value) }
        }
    }
    
    /// 设置属性（布尔）
    public func setPropertyBool(name: String, value: Bool): Unit {
        checkValid()
        unsafe {
            let nameStr = LibC.mallocCString(name)
            qQuickItemSetPropertyBool(ptr, nameStr, if (value) { 1 } else { 0 })
            LibC.free(nameStr)
        }
    }
    
    /// 获取属性（字符串）
    public func getPropertyString(name: String): String {
        checkValid()
        unsafe {
            let nameStr = LibC.mallocCString(name)
            let cstr = qQuickItemGetPropertyString(ptr, nameStr)
            LibC.free(nameStr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    /// 获取属性（整数）
    public func getPropertyInt(name: String): Int32 {
        checkValid()
        unsafe {
            let nameStr = LibC.mallocCString(name)
            let result = qQuickItemGetPropertyInt(ptr, nameStr)
            LibC.free(nameStr)
            return result
        }
    }
    
    /// 获取属性（浮点）
    public func getPropertyDouble(name: String): Float64 {
        checkValid()
        unsafe {
            let nameStr = LibC.mallocCString(name)
            let result = qQuickItemGetPropertyDouble(ptr, nameStr)
            LibC.free(nameStr)
            return result
        }
    }
    
    /// 获取属性（布尔）
    public func getPropertyBool(name: String): Bool {
        checkValid()
        unsafe {
            let nameStr = LibC.mallocCString(name)
            let result = qQuickItemGetPropertyBool(ptr, nameStr)
            LibC.free(nameStr)
            return result != 0
        }
    }
    
    /// 设置X坐标变化回调
    public func setOnXChanged(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qQuickItemConnectXChanged(ptr, callback)
        }
    }
    
    /// 断开X坐标变化信号
    public func disconnectXChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qQuickItemDisconnectXChanged(ptr)
            }
        }
    }
    
    /// 设置Y坐标变化回调
    public func setOnYChanged(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qQuickItemConnectYChanged(ptr, callback)
        }
    }
    
    /// 断开Y坐标变化信号
    public func disconnectYChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qQuickItemDisconnectYChanged(ptr)
            }
        }
    }
    
    /// 设置宽度变化回调
    public func setOnWidthChanged(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qQuickItemConnectWidthChanged(ptr, callback)
        }
    }
    
    /// 断开宽度变化信号
    public func disconnectWidthChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qQuickItemDisconnectWidthChanged(ptr)
            }
        }
    }
    
    /// 设置高度变化回调
    public func setOnHeightChanged(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qQuickItemConnectHeightChanged(ptr, callback)
        }
    }
    
    /// 断开高度变化信号
    public func disconnectHeightChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qQuickItemDisconnectHeightChanged(ptr)
            }
        }
    }
    
    /// 设置不透明度变化回调
    public func setOnOpacityChanged(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qQuickItemConnectOpacityChanged(ptr, callback)
        }
    }
    
    /// 断开不透明度变化信号
    public func disconnectOpacityChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qQuickItemDisconnectOpacityChanged(ptr)
            }
        }
    }
    
    /// 设置旋转变化回调
    public func setOnRotationChanged(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qQuickItemConnectRotationChanged(ptr, callback)
        }
    }
    
    /// 断开旋转变化信号
    public func disconnectRotationChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qQuickItemDisconnectRotationChanged(ptr)
            }
        }
    }
    
    /// 设置缩放变化回调
    public func setOnScaleChanged(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qQuickItemConnectScaleChanged(ptr, callback)
        }
    }
    
    /// 断开缩放变化信号
    public func disconnectScaleChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qQuickItemDisconnectScaleChanged(ptr)
            }
        }
    }
    
    /// 设置Z轴层级变化回调
    public func setOnZChanged(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qQuickItemConnectZChanged(ptr, callback)
        }
    }
    
    /// 断开Z轴层级变化信号
    public func disconnectZChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qQuickItemDisconnectZChanged(ptr)
            }
        }
    }
    
    /// 设置可见性变化回调
    public func setOnVisibleChanged(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qQuickItemConnectVisibleChanged(ptr, callback)
        }
    }
    
    /// 断开可见性变化信号
    public func disconnectVisibleChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qQuickItemDisconnectVisibleChanged(ptr)
            }
        }
    }
    
    /// 设置启用状态变化回调
    public func setOnEnabledChanged(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qQuickItemConnectEnabledChanged(ptr, callback)
        }
    }
    
    /// 断开启用状态变化信号
    public func disconnectEnabledChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qQuickItemDisconnectEnabledChanged(ptr)
            }
        }
    }
    
    /// 设置焦点变化回调（参数为 Int32：1=获得焦点，0=失去焦点）
    public func setOnFocusChanged(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qQuickItemConnectFocusChanged(ptr, callback)
        }
    }
    
    /// 断开焦点变化信号
    public func disconnectFocusChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qQuickItemDisconnectFocusChanged(ptr)
            }
        }
    }
    
    /// 设置父项变化回调（参数为父项指针 Int64）
    public func setOnParentChanged(callback: Int64Callback): Unit {
        checkValid()
        unsafe {
            qQuickItemConnectParentChanged(ptr, callback)
        }
    }
    
    /// 断开父项变化信号
    public func disconnectParentChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qQuickItemDisconnectParentChanged(ptr)
            }
        }
    }
    
    /// 设置子项变化回调
    public func setOnChildrenChanged(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qQuickItemConnectChildrenChanged(ptr, callback)
        }
    }
    
    /// 断开子项变化信号
    public func disconnectChildrenChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qQuickItemDisconnectChildrenChanged(ptr)
            }
        }
    }
    
    /// 断开该项的全部信号
    public func disconnect(): Unit {
        disconnectXChanged()
        disconnectYChanged()
        disconnectWidthChanged()
        disconnectHeightChanged()
        disconnectOpacityChanged()
        disconnectRotationChanged()
        disconnectScaleChanged()
        disconnectZChanged()
        disconnectVisibleChanged()
        disconnectEnabledChanged()
        disconnectFocusChanged()
        disconnectParentChanged()
        disconnectChildrenChanged()
    }
    
    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }
}
