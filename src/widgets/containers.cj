package cjqt6.widgets

import cjqt6.core.*
import cjqt6.gui.{FrameShape, FrameShadow}

// ============================================================
// 容器控件 FFI声明
// ============================================================

// QGroupBox - 分组框
// QGroupBox::QGroupBox() - 创建分组框
foreign func qGroupBoxCreate(): Int64
// QGroupBox::setTitle() - 设置标题
foreign func qGroupBoxSetTitle(ptr: Int64, title: CString): Unit
// QGroupBox::title() - 获取标题
foreign func qGroupBoxTitle(ptr: Int64): CString
// QGroupBox::setCheckable() - 设置是否可勾选
foreign func qGroupBoxSetCheckable(ptr: Int64, checkable: Bool): Unit
// QGroupBox::isCheckable() - 是否可勾选
foreign func qGroupBoxIsCheckable(ptr: Int64): Bool
// QGroupBox::setChecked() - 设置勾选状态
foreign func qGroupBoxSetChecked(ptr: Int64, checked: Bool): Unit
// QGroupBox::isChecked() - 是否已勾选
foreign func qGroupBoxIsChecked(ptr: Int64): Bool
// QGroupBox::setAlignment() - 设置对齐方式
foreign func qGroupBoxSetAlignment(ptr: Int64, alignment: Int32): Unit
// QGroupBox::alignment() - 获取对齐方式
foreign func qGroupBoxAlignment(ptr: Int64): Int32
// QGroupBox::setFlat() - 设置扁平样式
foreign func qGroupBoxSetFlat(ptr: Int64, flat: Int32): Unit
// QGroupBox::isFlat() - 是否扁平样式
foreign func qGroupBoxIsFlat(ptr: Int64): Int32
// QGroupBox::connectClicked() - 连接点击信号
foreign func qGroupBoxConnectClicked(ptr: Int64, callback: BoolCallback): Unit
// QGroupBox::connectToggled() - 连接勾选状态变化信号
foreign func qGroupBoxConnectToggled(ptr: Int64, callback: BoolCallback): Unit
// QGroupBox析构 - 删除控件
foreign func qGroupBoxDelete(ptr: Int64): Unit

// QTabWidget - 标签页
// QTabWidget::QTabWidget() - 创建标签页
foreign func qTabWidgetCreate(): Int64
// QTabWidget::addTab() - 添加标签页
foreign func qTabWidgetAddTab(ptr: Int64, widgetPtr: Int64, title: CString): Unit
// QTabWidget::removeTab() - 移除标签页
foreign func qTabWidgetRemoveTab(ptr: Int64, index: Int32): Unit
// QTabWidget::currentIndex() - 获取当前索引
foreign func qTabWidgetCurrentIndex(ptr: Int64): Int32
// QTabWidget::setCurrentIndex() - 设置当前索引
foreign func qTabWidgetSetCurrentIndex(ptr: Int64, index: Int32): Unit
// QTabWidget::count() - 获取标签页数量
foreign func qTabWidgetCount(ptr: Int64): Int32
// QTabWidget::setTabText() - 设置标签页文本
foreign func qTabWidgetSetTabText(ptr: Int64, index: Int32, text: CString): Unit
// QTabWidget::tabText() - 获取标签页文本
foreign func qTabWidgetTabText(ptr: Int64, index: Int32): CString
// QTabWidget::setTabToolTip() - 设置标签页工具提示
foreign func qTabWidgetSetTabToolTip(ptr: Int64, index: Int32, toolTip: CString): Unit
// QTabWidget::insertTab() - 在指定位置插入标签页
foreign func qTabWidgetInsertTab(ptr: Int64, index: Int32, widgetPtr: Int64, title: CString): Int32
// QTabWidget::setTabsClosable() - 设置标签页是否可关闭
foreign func qTabWidgetSetTabsClosable(ptr: Int64, closable: Bool): Unit
// QTabWidget::setMovable() - 设置标签页是否可移动
foreign func qTabWidgetSetMovable(ptr: Int64, movable: Bool): Unit
// QTabWidget::clear() - 清除所有标签页
foreign func qTabWidgetClear(ptr: Int64): Unit
// QTabWidget::connectCurrentChanged() - 连接当前标签页变化信号
foreign func qTabWidgetConnectCurrentChanged(ptr: Int64, callback: Int32Callback): Unit
// QTabWidget::disconnectCurrentChanged() - 断开当前标签页变化信号
foreign func qTabWidgetDisconnectCurrentChanged(ptr: Int64): Unit
// QTabWidget析构 - 删除控件
foreign func qTabWidgetDelete(ptr: Int64): Unit

// QScrollArea - 滚动区域
// QScrollArea::QScrollArea() - 创建滚动区域
foreign func qScrollAreaCreate(): Int64
// QScrollArea::setWidget() - 设置内部部件
foreign func qScrollAreaSetWidget(ptr: Int64, widgetPtr: Int64): Unit
// QScrollArea::setWidgetResizable() - 设置内部部件是否自动调整大小
foreign func qScrollAreaSetWidgetResizable(ptr: Int64, resizable: Bool): Unit
// QScrollArea::widget() - 获取内部部件
foreign func qScrollAreaWidget(ptr: Int64): Int64
// QScrollArea::takeWidget() - 取出内部部件
foreign func qScrollAreaTakeWidget(ptr: Int64): Int64
// QScrollArea::widgetResizable() - 是否自动调整内部部件大小
foreign func qScrollAreaWidgetResizable(ptr: Int64): Int32
// QScrollArea::setHorizontalScrollBarPolicy() - 设置水平滚动条策略
foreign func qScrollAreaSetHorizontalScrollBarPolicy(ptr: Int64, policy: Int32): Unit
// QScrollArea::setVerticalScrollBarPolicy() - 设置垂直滚动条策略
foreign func qScrollAreaSetVerticalScrollBarPolicy(ptr: Int64, policy: Int32): Unit
// QScrollArea::ensureVisible() - 确保指定区域可见
foreign func qScrollAreaEnsureVisible(ptr: Int64, x: Int32, y: Int32, w: Int32, h: Int32): Unit
// QScrollArea::setAlignment() - 设置内容对齐方式
foreign func qScrollAreaSetAlignment(ptr: Int64, alignment: Int32): Unit
// QScrollArea::alignment() - 获取内容对齐方式
foreign func qScrollAreaAlignment(ptr: Int64): Int32
// QScrollArea析构 - 删除控件
foreign func qScrollAreaDelete(ptr: Int64): Unit

// QFrame - 边框容器
// QFrame::QFrame() - 创建边框容器
foreign func qFrameCreate(): Int64
// QFrame::setFrameShape() - 设置边框形状
foreign func qFrameSetFrameShape(ptr: Int64, shape: Int32): Unit
// QFrame::setFrameShadow() - 设置边框阴影
foreign func qFrameSetFrameShadow(ptr: Int64, shadow: Int32): Unit
// QFrame::setLineWidth() - 设置线宽
foreign func qFrameSetLineWidth(ptr: Int64, width: Int32): Unit
// QFrame::setFrameStyle() - 设置整体边框样式
foreign func qFrameSetFrameStyle(ptr: Int64, style: Int32): Unit
// QFrame::frameStyle() - 获取整体边框样式
foreign func qFrameFrameStyle(ptr: Int64): Int32
// QFrame::frameShape() - 获取边框形状
foreign func qFrameFrameShape(ptr: Int64): Int32
// QFrame::frameShadow() - 获取边框阴影
foreign func qFrameFrameShadow(ptr: Int64): Int32
// QFrame::lineWidth() - 获取线宽
foreign func qFrameLineWidth(ptr: Int64): Int32
// QFrame::frameWidth() - 获取边框总宽度
foreign func qFrameFrameWidth(ptr: Int64): Int32
// QFrame::setMidLineWidth() - 设置中线宽度
foreign func qFrameSetMidLineWidth(ptr: Int64, width: Int32): Unit
// QFrame::midLineWidth() - 获取中线宽度
foreign func qFrameMidLineWidth(ptr: Int64): Int32
// QFrame::setFrameRect() - 设置边框矩形
foreign func qFrameSetFrameRect(ptr: Int64, x: Int32, y: Int32, w: Int32, h: Int32): Unit
// QFrame析构 - 删除控件
foreign func qFrameDelete(ptr: Int64): Unit

// ============================================================
// QGroupBox - 分组框
// ============================================================
/// 分组框部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QGroupBox <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init() {
        unsafe {
            ptr = qGroupBoxCreate()
        }
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
    
    public func setTitle(title: String) {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(title)
            qGroupBoxSetTitle(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func title(): String {
        checkValid()
        unsafe {
            let cstr = qGroupBoxTitle(ptr)
            let result = cstr.toString()
            return result
        }
    }
    
    public func setCheckable(checkable: Bool) {
        checkValid()
        unsafe {
            qGroupBoxSetCheckable(ptr, checkable)
        }
    }
    
    public func isCheckable(): Bool {
        checkValid()
        unsafe {
            qGroupBoxIsCheckable(ptr)
        }
    }
    
    public func setChecked(checked: Bool) {
        checkValid()
        unsafe {
            qGroupBoxSetChecked(ptr, checked)
        }
    }
    
    public func isChecked(): Bool {
        checkValid()
        unsafe {
            qGroupBoxIsChecked(ptr)
        }
    }
    
    /// 设置对齐方式（Qt::Alignment 位或值）
    public func setAlignment(alignment: Int32) {
        checkValid()
        unsafe {
            qGroupBoxSetAlignment(ptr, alignment)
        }
    }
    
    /// 获取对齐方式
    public func alignment(): Int32 {
        checkValid()
        unsafe {
            qGroupBoxAlignment(ptr)
        }
    }
    
    /// 点击（带选中态）回调
    public func setOnClicked(callback: BoolCallback) {
        checkValid()
        unsafe {
            qGroupBoxConnectClicked(ptr, callback)
        }
    }
    
    /// 勾选状态变化回调
    public func setOnToggled(callback: BoolCallback) {
        checkValid()
        unsafe {
            qGroupBoxConnectToggled(ptr, callback)
        }
    }

    /// 设置扁平样式
    public func setFlat(flat: Bool) {
        checkValid()
        unsafe {
            qGroupBoxSetFlat(ptr, if (flat) { 1 } else { 0 })
        }
    }

    /// 是否扁平样式
    public func isFlat(): Bool {
        checkValid()
        unsafe {
            return qGroupBoxIsFlat(ptr) != 0
        }
    }
    
    public func setLayout(layoutPtr: Int64) {
        checkValid()
        unsafe {
            qWidgetSetLayout(ptr, layoutPtr)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
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
        return !closed && ptr != 0
    }
    
    /// 检查有效性，无效时抛出异常
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QGroupBox 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QGroupBox 指针为空")
        }
    }
    
    /// 关闭资源，释放Qt对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qGroupBoxDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除分组框（兼容旧API）
    public func delete(): Unit {
        close()
    }
}

// ============================================================
// QTabWidget - 标签页
// ============================================================
/// 标签页部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QTabWidget <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init() {
        unsafe {
            ptr = qTabWidgetCreate()
        }
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
    
    public func addTab(widgetPtr: Int64, title: String) {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(title)
            qTabWidgetAddTab(ptr, widgetPtr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func removeTab(index: Int32) {
        checkValid()
        unsafe {
            qTabWidgetRemoveTab(ptr, index)
        }
    }
    
    public func currentIndex(): Int32 {
        checkValid()
        unsafe {
            qTabWidgetCurrentIndex(ptr)
        }
    }
    
    public func setCurrentIndex(index: Int32) {
        checkValid()
        unsafe {
            qTabWidgetSetCurrentIndex(ptr, index)
        }
    }
    
    public func count(): Int32 {
        checkValid()
        unsafe {
            qTabWidgetCount(ptr)
        }
    }
    
    /// 设置指定标签页的文本
    public func setTabText(index: Int32, text: String) {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            qTabWidgetSetTabText(ptr, index, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取指定标签页的文本
    public func tabText(index: Int32): String {
        checkValid()
        unsafe {
            let cstr = qTabWidgetTabText(ptr, index)
            return cstr.toString()
        }
    }
    
    /// 设置指定标签页的工具提示
    public func setTabToolTip(index: Int32, toolTip: String) {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(toolTip)
            qTabWidgetSetTabToolTip(ptr, index, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 在指定位置插入标签页
    public func insertTab(index: Int32, widgetPtr: Int64, title: String): Int32 {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(title)
            let result = qTabWidgetInsertTab(ptr, index, widgetPtr, cstr)
            LibC.free(cstr)
            return result
        }
    }
    
    /// 设置标签页是否可关闭
    public func setTabsClosable(closable: Bool) {
        checkValid()
        unsafe {
            qTabWidgetSetTabsClosable(ptr, closable)
        }
    }
    
    /// 设置标签页是否可移动
    public func setMovable(movable: Bool) {
        checkValid()
        unsafe {
            qTabWidgetSetMovable(ptr, movable)
        }
    }
    
    /// 清除所有标签页
    public func clear() {
        checkValid()
        unsafe {
            qTabWidgetClear(ptr)
        }
    }
    
    /// 设置当前标签页变化回调
    public func setOnCurrentChanged(callback: Int32Callback) {
        checkValid()
        unsafe {
            qTabWidgetConnectCurrentChanged(ptr, callback)
        }
    }
    
    /// 断开当前标签页变化信号
    public func disconnectCurrentChanged() {
        if (ptr != 0) {
            unsafe {
                qTabWidgetDisconnectCurrentChanged(ptr)
            }
        }
    }
    
    /// 断开该标签控件的全部信号（currentChanged）
    public func disconnect(): Unit {
        disconnectCurrentChanged()
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
    
    /// 设置最大尺寸
    public func setMaximumSize(maxw: Int32, maxh: Int32) {
        checkValid()
        unsafe {
            qWidgetSetMaximumSize(ptr, maxw, maxh)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }

    public func setMinimumSize(minw: Int32, minh: Int32) {
        checkValid()
        unsafe {
            qWidgetSetMinimumSize(ptr, minw, minh)
        }
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
        return !closed && ptr != 0
    }
    
    /// 检查有效性，无效时抛出异常
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QTabWidget 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QTabWidget 指针为空")
        }
    }
    
    /// 关闭资源，释放Qt对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qTabWidgetDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除标签页（兼容旧API）
    public func delete(): Unit {
        close()
    }
}

// ============================================================
// QScrollArea - 滚动区域
// ============================================================
/// 滚动区域部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QScrollArea <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init() {
        unsafe {
            ptr = qScrollAreaCreate()
        }
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
    
    public func setWidget(widgetPtr: Int64) {
        checkValid()
        unsafe {
            qScrollAreaSetWidget(ptr, widgetPtr)
        }
    }
    
    public func setWidgetResizable(resizable: Bool) {
        checkValid()
        unsafe {
            qScrollAreaSetWidgetResizable(ptr, resizable)
        }
    }
    
    public func widget(): Int64 {
        checkValid()
        unsafe {
            qScrollAreaWidget(ptr)
        }
    }
    
    /// 取出内部部件并返回其指针（之后不再由 QScrollArea 管理）
    public func takeWidget(): Int64 {
        checkValid()
        unsafe {
            qScrollAreaTakeWidget(ptr)
        }
    }
    
    /// 是否自动调整内部部件尺寸
    public func widgetResizable(): Bool {
        checkValid()
        unsafe {
            qScrollAreaWidgetResizable(ptr) != 0
        }
    }
    
    /// 设置水平滚动条策略
    public func setHorizontalScrollBarPolicy(policy: Int32) {
        checkValid()
        unsafe {
            qScrollAreaSetHorizontalScrollBarPolicy(ptr, policy)
        }
    }
    
    /// 设置垂直滚动条策略
    public func setVerticalScrollBarPolicy(policy: Int32) {
        checkValid()
        unsafe {
            qScrollAreaSetVerticalScrollBarPolicy(ptr, policy)
        }
    }
    
    /// 滚动以确保 (x,y) 处可见（w,h 为边距）
    public func ensureVisible(x: Int32, y: Int32, w: Int32, h: Int32) {
        checkValid()
        unsafe {
            qScrollAreaEnsureVisible(ptr, x, y, w, h)
        }
    }
    
    /// 设置内容对齐方式
    public func setAlignment(alignment: Int32) {
        checkValid()
        unsafe {
            qScrollAreaSetAlignment(ptr, alignment)
        }
    }
    
    /// 获取内容对齐方式
    public func alignment(): Int32 {
        checkValid()
        unsafe {
            qScrollAreaAlignment(ptr)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
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
        return !closed && ptr != 0
    }
    
    /// 检查有效性，无效时抛出异常
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QScrollArea 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QScrollArea 指针为空")
        }
    }
    
    /// 关闭资源，释放Qt对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qScrollAreaDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除滚动区域（兼容旧API）
    public func delete(): Unit {
        close()
    }
}

// ============================================================
// QFrame - 边框容器
// ============================================================

// Frame形状（使用 FrameShape 类常量）
// Frame阴影（使用 FrameShadow 类常量）

// 滚动条策略（对应 Qt::ScrollBarPolicy）
public class ScrollBarPolicy {
    public static let ScrollBarAsNeeded: Int32 = 0
    public static let ScrollBarAlwaysOff: Int32 = 1
    public static let ScrollBarAlwaysOn: Int32 = 2
}

/// 边框容器部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QFrame <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init() {
        unsafe {
            ptr = qFrameCreate()
        }
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
    
    public func setFrameShape(shape: Int32) {
        checkValid()
        unsafe {
            qFrameSetFrameShape(ptr, shape)
        }
    }
    
    public func setFrameShadow(shadow: Int32) {
        checkValid()
        unsafe {
            qFrameSetFrameShadow(ptr, shadow)
        }
    }
    
    public func setLineWidth(width: Int32) {
        checkValid()
        unsafe {
            qFrameSetLineWidth(ptr, width)
        }
    }

    /// 获取线宽
    public func lineWidth(): Int32 {
        checkValid()
        unsafe {
            return qFrameLineWidth(ptr)
        }
    }

    /// 获取边框总宽度（基于线宽和中线宽的实际渲染宽度）
    public func frameWidth(): Int32 {
        checkValid()
        unsafe {
            return qFrameFrameWidth(ptr)
        }
    }
    
    /// 设置整体边框样式（形状 | 阴影 的组合值）
    public func setFrameStyle(style: Int32) {
        checkValid()
        unsafe {
            qFrameSetFrameStyle(ptr, style)
        }
    }
    
    /// 获取整体边框样式
    public func frameStyle(): Int32 {
        checkValid()
        unsafe {
            qFrameFrameStyle(ptr)
        }
    }
    
    /// 获取边框形状
    public func frameShape(): Int32 {
        checkValid()
        unsafe {
            qFrameFrameShape(ptr)
        }
    }
    
    /// 获取边框阴影
    public func frameShadow(): Int32 {
        checkValid()
        unsafe {
            qFrameFrameShadow(ptr)
        }
    }
    
    /// 设置中线宽度
    public func setMidLineWidth(width: Int32) {
        checkValid()
        unsafe {
            qFrameSetMidLineWidth(ptr, width)
        }
    }
    
    /// 获取中线宽度
    public func midLineWidth(): Int32 {
        checkValid()
        unsafe {
            qFrameMidLineWidth(ptr)
        }
    }
    
    /// 设置边框矩形
    public func setFrameRect(x: Int32, y: Int32, w: Int32, h: Int32) {
        checkValid()
        unsafe {
            qFrameSetFrameRect(ptr, x, y, w, h)
        }
    }
    
    public func setLayout(layoutPtr: Int64) {
        checkValid()
        unsafe {
            qWidgetSetLayout(ptr, layoutPtr)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
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
    
    /// 设置工具提示
    public func setToolTip(toolTip: String) {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(toolTip)
            qWidgetSetToolTip(ptr, cstr)
            LibC.free(cstr)
        }
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
        return !closed && ptr != 0
    }
    
    /// 检查有效性，无效时抛出异常
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QFrame 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QFrame 指针为空")
        }
    }
    
    /// 关闭资源，释放Qt对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qFrameDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除边框容器（兼容旧API）
    public func delete(): Unit {
        close()
    }
}

// ============================================================
// QSplitter - 分割器
// QSplitter::QSplitter() - 创建分割器
foreign func qSplitterCreate(parentPtr: Int64): Int64
// QSplitter::QSplitter(Qt::Horizontal) - 创建水平分割器
foreign func qSplitterCreateHorizontal(parentPtr: Int64): Int64
// QSplitter::QSplitter(Qt::Vertical) - 创建垂直分割器
foreign func qSplitterCreateVertical(parentPtr: Int64): Int64
// QSplitter析构 - 删除控件
foreign func qSplitterDelete(ptr: Int64): Unit
// QSplitter::addWidget() - 添加子部件
foreign func qSplitterAddWidget(ptr: Int64, widgetPtr: Int64): Unit
// QSplitter::count() - 获取子部件数量
foreign func qSplitterCount(ptr: Int64): Int32
// QSplitter::widget() - 获取指定索引的子部件
foreign func qSplitterWidget(ptr: Int64, index: Int32): Int64
// QSplitter::setStretchFactor() - 设置拉伸因子
foreign func qSplitterSetStretchFactor(ptr: Int64, index: Int32, stretch: Int32): Unit
// QSplitter::setHandleWidth() - 设置分割手柄宽度
foreign func qSplitterSetHandleWidth(ptr: Int64, width: Int32): Unit
// QSplitter::handleWidth() - 获取分割手柄宽度
foreign func qSplitterHandleWidth(ptr: Int64): Int32
// QSplitter::setChildrenCollapsible() - 设置子部件是否可折叠
foreign func qSplitterSetChildrenCollapsible(ptr: Int64, collapsible: Int32): Unit
// QSplitter::childrenCollapsible() - 子部件是否可折叠
foreign func qSplitterChildrenCollapsible(ptr: Int64): Int32
// QSplitter::setOrientation() - 设置方向
foreign func qSplitterSetOrientation(ptr: Int64, orientation: Int32): Unit
// QSplitter::orientation() - 获取方向
foreign func qSplitterOrientation(ptr: Int64): Int32

/// 分割器部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QSplitter <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
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
        checkValid()
        unsafe {
            qSplitterAddWidget(ptr, widgetPtr)
        }
    }
    
    public func count(): Int32 {
        checkValid()
        unsafe {
            qSplitterCount(ptr)
        }
    }
    
    public func setStretchFactor(index: Int32, stretch: Int32) {
        checkValid()
        unsafe {
            qSplitterSetStretchFactor(ptr, index, stretch)
        }
    }
    
    public func setHandleWidth(width: Int32) {
        checkValid()
        unsafe {
            qSplitterSetHandleWidth(ptr, width)
        }
    }
    
    public func handleWidth(): Int32 {
        checkValid()
        unsafe {
            qSplitterHandleWidth(ptr)
        }
    }
    
    public func setChildrenCollapsible(collapsible: Bool) {
        checkValid()
        unsafe {
            qSplitterSetChildrenCollapsible(ptr, if (collapsible) { 1 } else { 0 })
        }
    }
    
    public func childrenCollapsible(): Bool {
        checkValid()
        unsafe {
            qSplitterChildrenCollapsible(ptr) == 1
        }
    }
    
    public func setOrientation(orientation: Int32) {
        checkValid()
        unsafe {
            qSplitterSetOrientation(ptr, orientation)
        }
    }
    
    public func orientation(): Int32 {
        checkValid()
        unsafe {
            qSplitterOrientation(ptr)
        }
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
    
    public func resize(width: Int32, height: Int32) {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
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
        return !closed && ptr != 0
    }
    
    /// 检查有效性，无效时抛出异常
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QSplitter 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QSplitter 指针为空")
        }
    }
    
    /// 关闭资源，释放Qt对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qSplitterDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除分割器（兼容旧API）
    public func delete(): Unit {
        close()
    }
}

// 分割器方向常量
public class SplitterOrientation {
    public static let Horizontal: Int32 = 1  // Qt::Horizontal
    public static let Vertical: Int32 = 2    // Qt::Vertical
}
