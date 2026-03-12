package CJQT6.qml

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
foreign func qQmlEngineSetContextProperty(ptr: Int64, name: CString, valuePtr: Int64): Unit
foreign func qQmlEngineSetContextPropertyString(ptr: Int64, name: CString, value: CString): Unit
foreign func qQmlEngineSetContextPropertyInt(ptr: Int64, name: CString, value: Int32): Unit
foreign func qQmlEngineSetContextPropertyDouble(ptr: Int64, name: CString, value: Float64): Unit
foreign func qQmlEngineSetContextPropertyBool(ptr: Int64, name: CString, value: Int32): Unit
foreign func qQmlEngineAddImportPath(ptr: Int64, path: CString): Unit
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
foreign func qQuickWidgetDelete(ptr: Int64): Unit

// QQuickItem
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
foreign func qQuickItemFindChild(ptr: Int64, name: CString): Int64

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
public class QQmlApplicationEngine {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qQmlEngineCreate()
        }
    }
    
    /// 获取内部指针（调试用）
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 加载QML文件
    public func loadFile(filePath: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(filePath)
            qQmlEngineLoadFile(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 加载URL
    public func loadUrl(url: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(url)
            qQmlEngineLoadUrl(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 加载QML数据字符串
    public func loadData(qmlData: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(qmlData)
            qQmlEngineLoadData(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 清除组件缓存
    public func clearComponentCache(): Unit {
        unsafe {
            qQmlEngineClearComponentCache(ptr)
        }
    }
    
    /// 获取根对象数量
    public func rootObjectsCount(): Int32 {
        unsafe {
            return qQmlEngineRootObjectsCount(ptr)
        }
    }
    
    /// 获取根对象
    public func rootObject(): QQuickItem {
        unsafe {
            let itemPtr = qQmlEngineRootObjects(ptr)
            return QQuickItem.fromPtr(itemPtr)
        }
    }
    
    /// 设置上下文属性（对象）
    public func setContextProperty(name: String, valuePtr: Int64): Unit {
        unsafe {
            let nameStr = LibC.mallocCString(name)
            qQmlEngineSetContextProperty(ptr, nameStr, valuePtr)
            LibC.free(nameStr)
        }
    }
    
    /// 设置上下文属性（字符串）
    public func setContextPropertyString(name: String, value: String): Unit {
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
        unsafe {
            let nameStr = LibC.mallocCString(name)
            qQmlEngineSetContextPropertyInt(ptr, nameStr, value)
            LibC.free(nameStr)
        }
    }
    
    /// 设置上下文属性（浮点）
    public func setContextPropertyDouble(name: String, value: Float64): Unit {
        unsafe {
            let nameStr = LibC.mallocCString(name)
            qQmlEngineSetContextPropertyDouble(ptr, nameStr, value)
            LibC.free(nameStr)
        }
    }
    
    /// 设置上下文属性（布尔）
    public func setContextPropertyBool(name: String, value: Bool): Unit {
        unsafe {
            let nameStr = LibC.mallocCString(name)
            qQmlEngineSetContextPropertyBool(ptr, nameStr, if (value) { 1 } else { 0 })
            LibC.free(nameStr)
        }
    }
    
    /// 添加导入路径
    public func addImportPath(path: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(path)
            qQmlEngineAddImportPath(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func delete(): Unit {
        unsafe {
            if (ptr != 0) {
                qQmlEngineDelete(ptr)
                ptr = 0
            }
        }
    }
}

// ============================================================
// QQuickView - QML视图窗口
// ============================================================

/// QML视图窗口，独立的QML窗口
public class QQuickView {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qQuickViewCreate()
        }
    }
    
    /// 设置QML源文件
    public func setSource(source: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(source)
            qQuickViewSetSource(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置URL源
    public func setSourceUrl(url: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(url)
            qQuickViewSetSourceUrl(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 显示窗口
    public func show(): Unit {
        unsafe {
            qQuickViewShow(ptr)
        }
    }
    
    /// 隐藏窗口
    public func hide(): Unit {
        unsafe {
            qQuickViewHide(ptr)
        }
    }
    
    /// 设置窗口标题
    public func setTitle(title: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(title)
            qQuickViewSetTitle(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置窗口大小
    public func resize(width: Int32, height: Int32): Unit {
        unsafe {
            qQuickViewResize(ptr, width, height)
        }
    }
    
    /// 获取根对象
    public func rootObject(): QQuickItem {
        unsafe {
            let itemPtr = qQuickViewRootObject(ptr)
            return QQuickItem.fromPtr(itemPtr)
        }
    }
    
    /// 设置大小调整模式
    public func setResizeMode(mode: Int32): Unit {
        unsafe {
            qQuickViewSetResizeMode(ptr, mode)
        }
    }
    
    /// 获取加载状态
    public func status(): Int32 {
        unsafe {
            return qQuickViewStatus(ptr)
        }
    }
    
    /// 检查是否有错误
    public func hasErrors(): Bool {
        unsafe {
            return qQuickViewErrors(ptr) != 0
        }
    }
    
    /// 检查是否加载成功
    public func isReady(): Bool {
        unsafe {
            return qQuickViewStatus(ptr) == Status.Ready
        }
    }
    
    public func delete(): Unit {
        unsafe {
            if (ptr != 0) {
                qQuickViewDelete(ptr)
                ptr = 0
            }
        }
    }
    
    public func getPtr(): Int64 {
        return ptr
    }
}

// ============================================================
// QQuickWidget - QML嵌入Widget
// ============================================================

/// QML嵌入Widget，可嵌入到传统Widget布局中
public class QQuickWidget {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qQuickWidgetCreate()
        }
    }
    
    /// 设置QML源文件
    public func setSource(source: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(source)
            qQuickWidgetSetSource(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置URL源
    public func setSourceUrl(url: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(url)
            qQuickWidgetSetSourceUrl(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 显示
    public func show(): Unit {
        unsafe {
            qQuickWidgetShow(ptr)
        }
    }
    
    /// 设置大小
    public func resize(width: Int32, height: Int32): Unit {
        unsafe {
            qQuickWidgetResize(ptr, width, height)
        }
    }
    
    /// 获取根对象
    public func rootObject(): QQuickItem {
        unsafe {
            let itemPtr = qQuickWidgetRootObject(ptr)
            return QQuickItem.fromPtr(itemPtr)
        }
    }
    
    /// 设置大小调整模式
    public func setResizeMode(mode: Int32): Unit {
        unsafe {
            qQuickWidgetSetResizeMode(ptr, mode)
        }
    }
    
    /// 获取指针（用于布局）
    public func getPtr(): Int64 {
        return ptr
    }
    
    public func delete(): Unit {
        unsafe {
            if (ptr != 0) {
                qQuickWidgetDelete(ptr)
                ptr = 0
            }
        }
    }
}

// ============================================================
// QQuickItem - QML项
// ============================================================

/// QML项，QML中的可视元素基类
/// 注意：QQuickItem 的指针由 Qt 管理，不应手动删除
public class QQuickItem {
    private var ptr: Int64 = 0
    private var owned: Bool = false  // 是否拥有所有权（默认不拥有）
    
    private init() {}
    
    /// 从指针创建（不拥有所有权，由 Qt 管理）
    public static func fromPtr(p: Int64): QQuickItem {
        let item = QQuickItem()
        item.ptr = p
        item.owned = false  // Qt 管理的对象
        return item
    }
    
    /// 检查指针是否有效
    public func isValid(): Bool {
        return ptr != 0
    }
    
    /// 设置可见性
    public func setVisible(visible: Bool): Unit {
        unsafe {
            qQuickItemSetVisible(ptr, if (visible) { 1 } else { 0 })
        }
    }
    
    /// 是否可见
    public func isVisible(): Bool {
        unsafe {
            return qQuickItemIsVisible(ptr) != 0
        }
    }
    
    /// 设置启用状态
    public func setEnabled(enabled: Bool): Unit {
        unsafe {
            qQuickItemSetEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }
    
    /// 是否启用
    public func isEnabled(): Bool {
        unsafe {
            return qQuickItemIsEnabled(ptr) != 0
        }
    }
    
    /// 设置X坐标
    public func setX(x: Float32): Unit {
        unsafe {
            qQuickItemSetX(ptr, x)
        }
    }
    
    /// 设置Y坐标
    public func setY(y: Float32): Unit {
        unsafe {
            qQuickItemSetY(ptr, y)
        }
    }
    
    /// 设置宽度
    public func setWidth(width: Float32): Unit {
        unsafe {
            qQuickItemSetWidth(ptr, width)
        }
    }
    
    /// 设置高度
    public func setHeight(height: Float32): Unit {
        unsafe {
            qQuickItemSetHeight(ptr, height)
        }
    }
    
    /// 获取X坐标
    public func x(): Float32 {
        unsafe {
            return qQuickItemX(ptr)
        }
    }
    
    /// 获取Y坐标
    public func y(): Float32 {
        unsafe {
            return qQuickItemY(ptr)
        }
    }
    
    /// 获取宽度
    public func width(): Float32 {
        unsafe {
            return qQuickItemWidth(ptr)
        }
    }
    
    /// 获取高度
    public func height(): Float32 {
        unsafe {
            return qQuickItemHeight(ptr)
        }
    }
    
    /// 查找子项
    public func findChild(name: String): QQuickItem {
        unsafe {
            let cstr = LibC.mallocCString(name)
            let childPtr = qQuickItemFindChild(ptr, cstr)
            LibC.free(cstr)
            return QQuickItem.fromPtr(childPtr)
        }
    }
    
    /// 设置属性（字符串）
    public func setProperty(name: String, value: String): Unit {
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
        unsafe {
            let nameStr = LibC.mallocCString(name)
            qQuickItemSetPropertyInt(ptr, nameStr, value)
            LibC.free(nameStr)
        }
    }
    
    /// 设置属性（浮点）
    public func setPropertyDouble(name: String, value: Float64): Unit {
        unsafe {
            let nameStr = LibC.mallocCString(name)
            qQuickItemSetPropertyDouble(ptr, nameStr, value)
            LibC.free(nameStr)
        }
    }
    
    /// 设置属性（布尔）
    public func setPropertyBool(name: String, value: Bool): Unit {
        unsafe {
            let nameStr = LibC.mallocCString(name)
            qQuickItemSetPropertyBool(ptr, nameStr, if (value) { 1 } else { 0 })
            LibC.free(nameStr)
        }
    }
    
    /// 获取属性（字符串）
    public func getPropertyString(name: String): String {
        unsafe {
            let nameStr = LibC.mallocCString(name)
            let cstr = qQuickItemGetPropertyString(ptr, nameStr)
            LibC.free(nameStr)
            let result = cstr.toString()
            qQuickItemFreeString(cstr)
            return result
        }
    }
    
    /// 获取属性（整数）
    public func getPropertyInt(name: String): Int32 {
        unsafe {
            let nameStr = LibC.mallocCString(name)
            let result = qQuickItemGetPropertyInt(ptr, nameStr)
            LibC.free(nameStr)
            return result
        }
    }
    
    /// 获取属性（浮点）
    public func getPropertyDouble(name: String): Float64 {
        unsafe {
            let nameStr = LibC.mallocCString(name)
            let result = qQuickItemGetPropertyDouble(ptr, nameStr)
            LibC.free(nameStr)
            return result
        }
    }
    
    /// 获取属性（布尔）
    public func getPropertyBool(name: String): Bool {
        unsafe {
            let nameStr = LibC.mallocCString(name)
            let result = qQuickItemGetPropertyBool(ptr, nameStr)
            LibC.free(nameStr)
            return result != 0
        }
    }
    
    public func getPtr(): Int64 {
        return ptr
    }
}
