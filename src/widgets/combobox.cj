package cjqt6.widgets

import cjqt6.core.*

// QComboBox - 下拉框
// QComboBox::QComboBox() - 创建下拉框
foreign func qComboBoxCreate(): Int64
// QComboBox::addItem() - 添加选项
foreign func qComboBoxAddItem(ptr: Int64, text: CString): Unit
// QComboBox::currentText() - 获取当前文本
foreign func qComboBoxCurrentText(ptr: Int64): CString
// QComboBox::setCurrentIndex() - 设置当前索引
foreign func qComboBoxSetCurrentIndex(ptr: Int64, index: Int32): Unit
// QComboBox::currentIndex() - 获取当前索引
foreign func qComboBoxCurrentIndex(ptr: Int64): Int32
// QComboBox::clear() - 清除所有选项
foreign func qComboBoxClear(ptr: Int64): Unit
// QComboBox::connectCurrentIndexChanged() - 连接当前索引变化信号
foreign func qComboBoxConnectCurrentIndexChanged(ptr: Int64, callback: Int32Callback): Unit
// QComboBox::connectCurrentIndexChangedId() - id 版（支持闭包捕获）
foreign func qComboBoxConnectCurrentIndexChangedId(ptr: Int64, id: Int64): Unit
// QComboBox::disconnectCurrentIndexChanged() - 断开当前索引变化信号
foreign func qComboBoxDisconnectCurrentIndexChanged(ptr: Int64): Unit
// QComboBox::connectCurrentTextChanged() - 连接当前文本变化信号
foreign func qComboBoxConnectCurrentTextChanged(ptr: Int64, callback: CStringCallback): Unit
// QComboBox::disconnectCurrentTextChanged() - 断开当前文本变化信号
foreign func qComboBoxDisconnectCurrentTextChanged(ptr: Int64): Unit
// QComboBox析构 - 删除控件
foreign func qComboBoxDelete(ptr: Int64): Unit
// QComboBox::count() - 获取选项数量
foreign func qComboBoxCount(ptr: Int64): Int32
// QComboBox::itemText() - 获取指定索引的文本
foreign func qComboBoxItemText(ptr: Int64, index: Int32): CString
// QComboBox::setEditable() - 设置是否可编辑
foreign func qComboBoxSetEditable(ptr: Int64, editable: Bool): Unit
// QComboBox::removeItem() - 移除指定索引的选项
foreign func qComboBoxRemoveItem(ptr: Int64, index: Int32): Unit
// QComboBox::addItems() - 批量添加选项
foreign func qComboBoxAddItems(ptr: Int64, items: CString): Unit
// QComboBox::insertItem() - 在指定位置插入选项
foreign func qComboBoxInsertItem(ptr: Int64, index: Int32, text: CString): Unit
// QComboBox::setItemText() - 设置指定索引的文本
foreign func qComboBoxSetItemText(ptr: Int64, index: Int32, text: CString): Unit
// QComboBox::setCurrentText() - 通过文本设置当前选中项
foreign func qComboBoxSetCurrentText(ptr: Int64, text: CString): Unit
// QComboBox::findText() - 查找文本索引
foreign func qComboBoxFindText(ptr: Int64, text: CString): Int32
// QComboBox::setPlaceholderText() - 设置占位文本
foreign func qComboBoxSetPlaceholderText(ptr: Int64, text: CString): Unit
// QComboBox::setIconSize() - 设置图标尺寸
foreign func qComboBoxSetIconSize(ptr: Int64, width: Int32, height: Int32): Unit
// QComboBox::isEditable() - 是否可编辑
foreign func qComboBoxIsEditable(ptr: Int64): Int32
// QComboBox::setInsertPolicy() - 设置插入策略
foreign func qComboBoxSetInsertPolicy(ptr: Int64, policy: Int32): Unit
// QComboBox::insertPolicy() - 获取插入策略
foreign func qComboBoxInsertPolicy(ptr: Int64): Int32
// QComboBox::setMaxVisibleItems() - 设置最大可见项数
foreign func qComboBoxSetMaxVisibleItems(ptr: Int64, max: Int32): Unit
// QComboBox::maxVisibleItems() - 获取最大可见项数
foreign func qComboBoxMaxVisibleItems(ptr: Int64): Int32
// QComboBox::setMaxCount() - 设置最大条目数
foreign func qComboBoxSetMaxCount(ptr: Int64, max: Int32): Unit
// QComboBox::maxCount() - 获取最大条目数
foreign func qComboBoxMaxCount(ptr: Int64): Int32
// QComboBox::setFrame() - 设置是否有边框
foreign func qComboBoxSetFrame(ptr: Int64, frame: Int32): Unit
// QComboBox::hasFrame() - 是否有边框
foreign func qComboBoxHasFrame(ptr: Int64): Int32
// QComboBox::setDuplicatesEnabled() - 设置是否允许重复项
foreign func qComboBoxSetDuplicatesEnabled(ptr: Int64, enabled: Int32): Unit
// QComboBox::setCurrentData() - 通过用户数据设置当前项
foreign func qComboBoxSetCurrentData(ptr: Int64, value: Int64): Unit
// QComboBox::setCompleter() - 设置补全器
foreign func qComboBoxSetCompleter(ptr: Int64, completerPtr: Int64): Unit
// QComboBox::setSizeAdjustPolicy() - 设置尺寸自适应策略
foreign func qComboBoxSetSizeAdjustPolicy(ptr: Int64, policy: Int32): Unit
// QComboBox::connectEditTextChanged() - 连接编辑文本变化信号
foreign func qComboBoxConnectEditTextChanged(ptr: Int64, callback: CStringCallback): Unit
// QComboBox::connectActivated() - 连接用户激活信号
foreign func qComboBoxConnectActivated(ptr: Int64, callback: Int32Callback): Unit
// QComboBox::connectHighlighted() - 连接高亮信号
foreign func qComboBoxConnectHighlighted(ptr: Int64, callback: Int32Callback): Unit

/// 下拉框插入策略常量（对应 QComboBox::InsertPolicy）
public class ComboBoxInsertPolicy {
    public static let NoInsert: Int32 = 0
    public static let InsertAtTop: Int32 = 1
    public static let InsertAtCurrent: Int32 = 2
    public static let InsertAtBottom: Int32 = 3
    public static let InsertAfterCurrent: Int32 = 4
    public static let InsertBeforeCurrent: Int32 = 5
    public static let InsertAlphabetically: Int32 = 6
}

/// 下拉框尺寸自适应策略常量（对应 QComboBox::SizeAdjustPolicy）
public class ComboBoxSizeAdjustPolicy {
    public static let AdjustToContents: Int32 = 0
    public static let AdjustToContentsOnFirstShow: Int32 = 1
    public static let AdjustToMinimumContentsLengthWithIcon: Int32 = 2
}

/// 下拉框部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QComboBox <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init() {
        unsafe {
            ptr = qComboBoxCreate()
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
    
    public func resize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }
    
    public func addItem(text: String): Unit {
        checkValid()
        unsafe {
            withCString(text) { c => qComboBoxAddItem(ptr, c) }
        }
    }
    
    public func currentText(): String {
        checkValid()
        unsafe {
            let cstr = qComboBoxCurrentText(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    public func setCurrentIndex(index: Int32): Unit {
        checkValid()
        unsafe {
            qComboBoxSetCurrentIndex(ptr, index)
        }
    }
    
    public func currentIndex(): Int32 {
        checkValid()
        unsafe {
            return qComboBoxCurrentIndex(ptr)
        }
    }
    
    public func clear(): Unit {
        checkValid()
        unsafe {
            qComboBoxClear(ptr)
        }
    }
    
    /// 批量添加选项（使用换行符分隔）
    public func addItems(items: String): Unit {
        checkValid()
        unsafe {
            withCString(items) { c => qComboBoxAddItems(ptr, c) }
        }
    }
    
    /// 在指定位置插入选项
    public func insertItem(index: Int32, text: String): Unit {
        checkValid()
        unsafe {
            withCString(text) { c => qComboBoxInsertItem(ptr, index, c) }
        }
    }
    
    /// 设置指定索引的文本
    public func setItemText(index: Int32, text: String): Unit {
        checkValid()
        unsafe {
            withCString(text) { c => qComboBoxSetItemText(ptr, index, c) }
        }
    }
    
    /// 通过文本设置当前选中项
    public func setCurrentText(text: String): Unit {
        checkValid()
        unsafe {
            withCString(text) { c => qComboBoxSetCurrentText(ptr, c) }
        }
    }
    
    /// 查找文本的索引（未找到返回-1）
    public func findText(text: String): Int32 {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            let result = qComboBoxFindText(ptr, cstr)
            LibC.free(cstr)
            return result
        }
    }
    
    /// 设置占位文本
    public func setPlaceholderText(text: String): Unit {
        checkValid()
        unsafe {
            withCString(text) { c => qComboBoxSetPlaceholderText(ptr, c) }
        }
    }
    
    /// 设置图标尺寸
    public func setIconSize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qComboBoxSetIconSize(ptr, width, height)
        }
    }
    
    /// 获取选项数量
    public func count(): Int32 {
        checkValid()
        unsafe {
            return qComboBoxCount(ptr)
        }
    }


    /// 获取指定索引的文本
    public func itemText(index: Int32): String {
        checkValid()
        unsafe {
            let cstr = qComboBoxItemText(ptr, index)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }


    /// 设置是否可编辑
    public func setEditable(editable: Bool): Unit {
        checkValid()
        unsafe {
            qComboBoxSetEditable(ptr, editable)
        }
    }


    /// 移除指定索引的选项
    public func removeItem(index: Int32): Unit {
        checkValid()
        unsafe {
            qComboBoxRemoveItem(ptr, index)
        }
    }


    /// 是否可编辑
    public func isEditable(): Bool {
        checkValid()
        unsafe {
            return qComboBoxIsEditable(ptr) != 0
        }
    }


    /// 设置插入策略（ComboBoxInsertPolicy.*）
    public func setInsertPolicy(policy: Int32): Unit {
        checkValid()
        unsafe {
            qComboBoxSetInsertPolicy(ptr, policy)
        }
    }


    /// 获取插入策略
    public func insertPolicy(): Int32 {
        checkValid()
        unsafe {
            return qComboBoxInsertPolicy(ptr)
        }
    }

    /// 设置最大可见项数
    public func setMaxVisibleItems(max: Int32): Unit {
        checkValid()
        unsafe {
            qComboBoxSetMaxVisibleItems(ptr, max)
        }
    }

    /// 获取最大可见项数
    public func maxVisibleItems(): Int32 {
        checkValid()
        unsafe {
            return qComboBoxMaxVisibleItems(ptr)
        }
    }

    /// 设置最大条目数
    public func setMaxCount(max: Int32): Unit {
        checkValid()
        unsafe {
            qComboBoxSetMaxCount(ptr, max)
        }
    }

    /// 获取最大条目数
    public func maxCount(): Int32 {
        checkValid()
        unsafe {
            return qComboBoxMaxCount(ptr)
        }
    }

    /// 设置是否有边框
    public func setFrame(frame: Bool): Unit {
        checkValid()
        unsafe {
            qComboBoxSetFrame(ptr, if (frame) { 1 } else { 0 })
        }
    }

    /// 是否有边框
    public func hasFrame(): Bool {
        checkValid()
        unsafe {
            return qComboBoxHasFrame(ptr) != 0
        }
    }

    /// 设置是否允许重复项
    public func setDuplicatesEnabled(enabled: Bool): Unit {
        checkValid()
        unsafe {
            qComboBoxSetDuplicatesEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }

    /// 通过用户数据设置当前项
    public func setCurrentData(value: Int64): Unit {
        checkValid()
        unsafe {
            qComboBoxSetCurrentData(ptr, value)
        }
    }

    /// 设置补全器（传入 QCompleter.getPtr()）
    public func setCompleter(completerPtr: Int64): Unit {
        checkValid()
        unsafe {
            qComboBoxSetCompleter(ptr, completerPtr)
        }
    }

    /// 设置尺寸自适应策略（ComboBoxSizeAdjustPolicy.*）
    public func setSizeAdjustPolicy(policy: Int32): Unit {
        checkValid()
        unsafe {
            qComboBoxSetSizeAdjustPolicy(ptr, policy)
        }
    }

    /// 编辑文本变化回调（可编辑模式下触发）
    public func setOnEditTextChanged(callback: CStringCallback): Unit {
        checkValid()
        unsafe {
            qComboBoxConnectEditTextChanged(ptr, callback)
        }
    }

    /// 用户激活（点击/回车）某项回调，参数为索引
    public func setOnActivated(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qComboBoxConnectActivated(ptr, callback)
        }
    }

    /// 高亮某项回调，参数为索引
    public func setOnHighlighted(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qComboBoxConnectHighlighted(ptr, callback)
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

    /// 设置当前索引变化回调
    public func setOnCurrentIndexChanged(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qComboBoxConnectCurrentIndexChanged(ptr, callback)
        }
    }

    /// 设置当前索引变化回调（可捕获局部变量；回调内用 currentIndex() 读取新索引），返回 SignalConnection 句柄
    public func setOnCurrentIndexChangedCapture(callback: () -> Unit): SignalConnection {
        checkValid()
        let id = registerVoidCallback(callback)
        unsafe {
            qComboBoxConnectCurrentIndexChangedId(ptr, id)
        }
        return SignalConnection.createCapturing(ptr, SIGNAL_CURRENT_INDEX_CHANGED, WIDGET_TYPE_COMBOBOX, id)
    }

    /// 断开索引变化信号
    public func disconnectCurrentIndexChanged(): Unit {
        checkValid()
        unsafe {
            qComboBoxDisconnectCurrentIndexChanged(ptr)
        }
    }

    /// 设置当前文本变化回调
    public func setOnCurrentTextChanged(callback: CStringCallback): Unit {
        checkValid()
        unsafe {
            qComboBoxConnectCurrentTextChanged(ptr, callback)
        }
    }

    /// 断开当前文本变化回调
    public func disconnectCurrentTextChanged(): Unit {
        checkValid()
        unsafe {
            qComboBoxDisconnectCurrentTextChanged(ptr)
        }
    }

    /// 断开该组合框的全部信号（currentIndexChanged/currentTextChanged）
    public func disconnect(): Unit {
        checkValid()
        disconnectCurrentIndexChanged()
        disconnectCurrentTextChanged()
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
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QComboBox 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QComboBox 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QComboBox 底层 Qt 对象已失效")
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
                qComboBoxDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除下拉框（兼容旧API）
    public func delete(): Unit {
        close()
    }
}
