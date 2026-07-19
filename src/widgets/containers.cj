package cjqt6.widgets

import cjqt6.core.*

// ============================================================
// 容器控件 FFI声明
// ============================================================

// QGroupBox - 分组框
foreign func qGroupBoxCreate(): Int64
foreign func qGroupBoxSetTitle(ptr: Int64, title: CString): Unit
foreign func qGroupBoxTitle(ptr: Int64): CString
foreign func qGroupBoxSetCheckable(ptr: Int64, checkable: Bool): Unit
foreign func qGroupBoxIsCheckable(ptr: Int64): Bool
foreign func qGroupBoxSetChecked(ptr: Int64, checked: Bool): Unit
foreign func qGroupBoxIsChecked(ptr: Int64): Bool
foreign func qGroupBoxDelete(ptr: Int64): Unit

// QTabWidget - 标签页
foreign func qTabWidgetCreate(): Int64
foreign func qTabWidgetAddTab(ptr: Int64, widgetPtr: Int64, title: CString): Unit
foreign func qTabWidgetRemoveTab(ptr: Int64, index: Int32): Unit
foreign func qTabWidgetCurrentIndex(ptr: Int64): Int32
foreign func qTabWidgetSetCurrentIndex(ptr: Int64, index: Int32): Unit
foreign func qTabWidgetCount(ptr: Int64): Int32
foreign func qTabWidgetSetTabText(ptr: Int64, index: Int32, text: CString): Unit
foreign func qTabWidgetTabText(ptr: Int64, index: Int32): CString
foreign func qTabWidgetSetTabToolTip(ptr: Int64, index: Int32, toolTip: CString): Unit
foreign func qTabWidgetInsertTab(ptr: Int64, index: Int32, widgetPtr: Int64, title: CString): Int32
foreign func qTabWidgetSetTabsClosable(ptr: Int64, closable: Bool): Unit
foreign func qTabWidgetSetMovable(ptr: Int64, movable: Bool): Unit
foreign func qTabWidgetClear(ptr: Int64): Unit
foreign func qTabWidgetConnectCurrentChanged(ptr: Int64, callback: Int64Callback): Unit
foreign func qTabWidgetDisconnectCurrentChanged(ptr: Int64): Unit
foreign func qTabWidgetDelete(ptr: Int64): Unit

// QScrollArea - 滚动区域
foreign func qScrollAreaCreate(): Int64
foreign func qScrollAreaSetWidget(ptr: Int64, widgetPtr: Int64): Unit
foreign func qScrollAreaSetWidgetResizable(ptr: Int64, resizable: Bool): Unit
foreign func qScrollAreaWidget(ptr: Int64): Int64
foreign func qScrollAreaDelete(ptr: Int64): Unit

// QFrame - 边框容器
foreign func qFrameCreate(): Int64
foreign func qFrameSetFrameShape(ptr: Int64, shape: Int32): Unit
foreign func qFrameSetFrameShadow(ptr: Int64, shadow: Int32): Unit
foreign func qFrameSetLineWidth(ptr: Int64, width: Int32): Unit
foreign func qFrameDelete(ptr: Int64): Unit

// ============================================================
// QGroupBox - 分组框
// ============================================================
public class QGroupBox {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qGroupBoxCreate()
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
            qGroupBoxSetTitle(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func title(): String {
        unsafe {
            let cstr = qGroupBoxTitle(ptr)
            let result = cstr.toString()
            // 注意：cstr指向静态缓冲区，不要free
            return result
        }
    }
    
    public func setCheckable(checkable: Bool) {
        unsafe {
            qGroupBoxSetCheckable(ptr, checkable)
        }
    }
    
    public func isCheckable(): Bool {
        unsafe {
            qGroupBoxIsCheckable(ptr)
        }
    }
    
    public func setChecked(checked: Bool) {
        unsafe {
            qGroupBoxSetChecked(ptr, checked)
        }
    }
    
    public func isChecked(): Bool {
        unsafe {
            qGroupBoxIsChecked(ptr)
        }
    }
    
    public func setLayout(layoutPtr: Int64) {
        unsafe {
            qWidgetSetLayout(ptr, layoutPtr)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        unsafe {
            qWidgetResize(ptr, width, height)
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
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qGroupBoxDelete(ptr)
            }
            ptr = 0
        }
    }
}

// ============================================================
// QTabWidget - 标签页
// ============================================================
public class QTabWidget {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qTabWidgetCreate()
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
    
    public func addTab(widgetPtr: Int64, title: String) {
        unsafe {
            var cstr = LibC.mallocCString(title)
            qTabWidgetAddTab(ptr, widgetPtr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func removeTab(index: Int32) {
        unsafe {
            qTabWidgetRemoveTab(ptr, index)
        }
    }
    
    public func currentIndex(): Int32 {
        unsafe {
            qTabWidgetCurrentIndex(ptr)
        }
    }
    
    public func setCurrentIndex(index: Int32) {
        unsafe {
            qTabWidgetSetCurrentIndex(ptr, index)
        }
    }
    
    public func count(): Int32 {
        unsafe {
            qTabWidgetCount(ptr)
        }
    }
    
    /// 设置指定标签页的文本
    public func setTabText(index: Int32, text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qTabWidgetSetTabText(ptr, index, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取指定标签页的文本
    public func tabText(index: Int32): String {
        unsafe {
            let cstr = qTabWidgetTabText(ptr, index)
            return cstr.toString()
        }
    }
    
    /// 设置指定标签页的工具提示
    public func setTabToolTip(index: Int32, toolTip: String) {
        unsafe {
            let cstr = LibC.mallocCString(toolTip)
            qTabWidgetSetTabToolTip(ptr, index, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 在指定位置插入标签页
    public func insertTab(index: Int32, widgetPtr: Int64, title: String): Int32 {
        unsafe {
            let cstr = LibC.mallocCString(title)
            let result = qTabWidgetInsertTab(ptr, index, widgetPtr, cstr)
            LibC.free(cstr)
            return result
        }
    }
    
    /// 设置标签页是否可关闭
    public func setTabsClosable(closable: Bool) {
        unsafe {
            qTabWidgetSetTabsClosable(ptr, closable)
        }
    }
    
    /// 设置标签页是否可移动
    public func setMovable(movable: Bool) {
        unsafe {
            qTabWidgetSetMovable(ptr, movable)
        }
    }
    
    /// 清除所有标签页
    public func clear() {
        unsafe {
            qTabWidgetClear(ptr)
        }
    }
    
    /// 设置当前标签页变化回调
    public func setOnCurrentChanged(callback: Int64Callback) {
        unsafe {
            qTabWidgetConnectCurrentChanged(ptr, callback)
        }
    }
    
    /// 断开当前标签页变化信号
    public func disconnectCurrentChanged() {
        unsafe {
            qTabWidgetDisconnectCurrentChanged(ptr)
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
    
    /// 设置最大尺寸
    public func setMaximumSize(maxw: Int32, maxh: Int32) {
        unsafe {
            qWidgetSetMaximumSize(ptr, maxw, maxh)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }

    public func setMinimumSize(minw: Int32, minh: Int32) {
        unsafe {
            qWidgetSetMinimumSize(ptr, minw, minh)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qTabWidgetDelete(ptr)
            }
            ptr = 0
        }
    }
}

// ============================================================
// QScrollArea - 滚动区域
// ============================================================
public class QScrollArea {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qScrollAreaCreate()
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
    
    public func setWidget(widgetPtr: Int64) {
        unsafe {
            qScrollAreaSetWidget(ptr, widgetPtr)
        }
    }
    
    public func setWidgetResizable(resizable: Bool) {
        unsafe {
            qScrollAreaSetWidgetResizable(ptr, resizable)
        }
    }
    
    public func widget(): Int64 {
        unsafe {
            qScrollAreaWidget(ptr)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        unsafe {
            qWidgetResize(ptr, width, height)
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
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qScrollAreaDelete(ptr)
            }
            ptr = 0
        }
    }
}

// ============================================================
// QFrame - 边框容器
// ============================================================

// Frame形状
public const NoFrame: Int32 = 0
public const Box: Int32 = 1
public const Panel: Int32 = 2
public const WinPanel: Int32 = 3
public const HLine: Int32 = 4
public const VLine: Int32 = 5
public const StyledPanel: Int32 = 6

// Frame阴影
public const Plain: Int32 = 16
public const Raised: Int32 = 32
public const Sunken: Int32 = 48

public class QFrame {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qFrameCreate()
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
    
    public func setFrameShape(shape: Int32) {
        unsafe {
            qFrameSetFrameShape(ptr, shape)
        }
    }
    
    public func setFrameShadow(shadow: Int32) {
        unsafe {
            qFrameSetFrameShadow(ptr, shadow)
        }
    }
    
    public func setLineWidth(width: Int32) {
        unsafe {
            qFrameSetLineWidth(ptr, width)
        }
    }
    
    public func setLayout(layoutPtr: Int64) {
        unsafe {
            qWidgetSetLayout(ptr, layoutPtr)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        unsafe {
            qWidgetResize(ptr, width, height)
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
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qFrameDelete(ptr)
            }
            ptr = 0
        }
    }
}

// ============================================================
// QSplitter - 分割器
// ============================================================
foreign func qSplitterCreate(parentPtr: Int64): Int64
foreign func qSplitterCreateHorizontal(parentPtr: Int64): Int64
foreign func qSplitterCreateVertical(parentPtr: Int64): Int64
foreign func qSplitterDelete(ptr: Int64): Unit
foreign func qSplitterAddWidget(ptr: Int64, widgetPtr: Int64): Unit
foreign func qSplitterCount(ptr: Int64): Int32
foreign func qSplitterWidget(ptr: Int64, index: Int32): Int64
foreign func qSplitterSetStretchFactor(ptr: Int64, index: Int32, stretch: Int32): Unit
foreign func qSplitterSetHandleWidth(ptr: Int64, width: Int32): Unit
foreign func qSplitterHandleWidth(ptr: Int64): Int32
foreign func qSplitterSetChildrenCollapsible(ptr: Int64, collapsible: Int32): Unit
foreign func qSplitterChildrenCollapsible(ptr: Int64): Int32
foreign func qSplitterSetOrientation(ptr: Int64, orientation: Int32): Unit
foreign func qSplitterOrientation(ptr: Int64): Int32

public class QSplitter {
    private let ptr: Int64
    
    // 创建水平分割器
    public static func createHorizontal(parent: Int64): QSplitter {
        unsafe {
            QSplitter(qSplitterCreateHorizontal(parent), true)
        }
    }
    
    // 创建垂直分割器
    public static func createVertical(parent: Int64): QSplitter {
        unsafe {
            QSplitter(qSplitterCreateVertical(parent), true)
        }
    }
    
    public init(parent: Int64) {
        unsafe {
            ptr = qSplitterCreate(parent)
        }
    }
    
    // 内部构造函数，用于静态工厂方法
    private init(ptr: Int64, _: Bool) {
        this.ptr = ptr
    }
    
    public func addWidget(widgetPtr: Int64) {
        unsafe {
            qSplitterAddWidget(ptr, widgetPtr)
        }
    }
    
    public func count(): Int32 {
        unsafe {
            qSplitterCount(ptr)
        }
    }
    
    public func setStretchFactor(index: Int32, stretch: Int32) {
        unsafe {
            qSplitterSetStretchFactor(ptr, index, stretch)
        }
    }
    
    public func setHandleWidth(width: Int32) {
        unsafe {
            qSplitterSetHandleWidth(ptr, width)
        }
    }
    
    public func handleWidth(): Int32 {
        unsafe {
            qSplitterHandleWidth(ptr)
        }
    }
    
    public func setChildrenCollapsible(collapsible: Bool) {
        unsafe {
            qSplitterSetChildrenCollapsible(ptr, if (collapsible) { 1 } else { 0 })
        }
    }
    
    public func childrenCollapsible(): Bool {
        unsafe {
            qSplitterChildrenCollapsible(ptr) == 1
        }
    }
    
    public func setOrientation(orientation: Int32) {
        unsafe {
            qSplitterSetOrientation(ptr, orientation)
        }
    }
    
    public func orientation(): Int32 {
        unsafe {
            qSplitterOrientation(ptr)
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
    
    public func resize(width: Int32, height: Int32) {
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSplitterDelete(ptr)
            }
        }
    }
}

// 分割器方向常量
public class SplitterOrientation {
    public static let Horizontal: Int32 = 1  // Qt::Horizontal
    public static let Vertical: Int32 = 2    // Qt::Vertical
}
