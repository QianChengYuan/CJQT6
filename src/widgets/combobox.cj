package cjqt6.widgets

import cjqt6.core.*

// QComboBox - 下拉框
foreign func qComboBoxCreate(): Int64
foreign func qComboBoxAddItem(ptr: Int64, text: CString): Unit
foreign func qComboBoxCurrentText(ptr: Int64): CString
foreign func qComboBoxSetCurrentIndex(ptr: Int64, index: Int32): Unit
foreign func qComboBoxCurrentIndex(ptr: Int64): Int32
foreign func qComboBoxClear(ptr: Int64): Unit
foreign func qComboBoxConnectCurrentIndexChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qComboBoxDisconnectCurrentIndexChanged(ptr: Int64): Unit
foreign func qComboBoxConnectCurrentTextChanged(ptr: Int64, callback: CStringCallback): Unit
foreign func qComboBoxDisconnectCurrentTextChanged(ptr: Int64): Unit
foreign func qComboBoxDelete(ptr: Int64): Unit
foreign func qComboBoxCount(ptr: Int64): Int32
foreign func qComboBoxItemText(ptr: Int64, index: Int32): CString
foreign func qComboBoxSetEditable(ptr: Int64, editable: Bool): Unit
foreign func qComboBoxRemoveItem(ptr: Int64, index: Int32): Unit
foreign func qComboBoxAddItems(ptr: Int64, items: CString): Unit
foreign func qComboBoxInsertItem(ptr: Int64, index: Int32, text: CString): Unit
foreign func qComboBoxSetItemText(ptr: Int64, index: Int32, text: CString): Unit
foreign func qComboBoxSetCurrentText(ptr: Int64, text: CString): Unit
foreign func qComboBoxFindText(ptr: Int64, text: CString): Int32
foreign func qComboBoxSetPlaceholderText(ptr: Int64, text: CString): Unit

/// 下拉框部件
public class QComboBox {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qComboBoxCreate()
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
    
    public func addItem(text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qComboBoxAddItem(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func currentText(): String {
        unsafe {
            let cstr = qComboBoxCurrentText(ptr)
            return cstr.toString()
        }
    }
    
    public func setCurrentIndex(index: Int32) {
        unsafe {
            qComboBoxSetCurrentIndex(ptr, index)
        }
    }
    
    public func currentIndex(): Int32 {
        unsafe {
            return qComboBoxCurrentIndex(ptr)
        }
    }
    
    public func clear() {
        unsafe {
            qComboBoxClear(ptr)
        }
    }
    
    /// 批量添加选项（使用换行符分隔）
    public func addItems(items: String) {
        unsafe {
            let cstr = LibC.mallocCString(items)
            qComboBoxAddItems(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 在指定位置插入选项
    public func insertItem(index: Int32, text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qComboBoxInsertItem(ptr, index, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置指定索引的文本
    public func setItemText(index: Int32, text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qComboBoxSetItemText(ptr, index, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 通过文本设置当前选中项
    public func setCurrentText(text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qComboBoxSetCurrentText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 查找文本的索引（未找到返回-1）
    public func findText(text: String): Int32 {
        unsafe {
            let cstr = LibC.mallocCString(text)
            let result = qComboBoxFindText(ptr, cstr)
            LibC.free(cstr)
            return result
        }
    }
    
    /// 设置占位文本
    public func setPlaceholderText(text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qComboBoxSetPlaceholderText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取选项数量
    public func count(): Int32 {
        unsafe {
            return qComboBoxCount(ptr)
        }
    }
    
    /// 获取指定索引的文本
    public func itemText(index: Int32): String {
        unsafe {
            let cstr = qComboBoxItemText(ptr, index)
            return cstr.toString()
        }
    }
    
    /// 设置是否可编辑
    public func setEditable(editable: Bool) {
        unsafe {
            qComboBoxSetEditable(ptr, editable)
        }
    }
    
    /// 移除指定索引的选项
    public func removeItem(index: Int32) {
        unsafe {
            qComboBoxRemoveItem(ptr, index)
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
    
    /// 设置当前索引变化回调
    public func setOnCurrentIndexChanged(callback: Int32Callback) {
        unsafe {
            qComboBoxConnectCurrentIndexChanged(ptr, callback)
        }
    }
    
    /// 断开索引变化信号
    public func disconnectCurrentIndexChanged() {
        unsafe {
            qComboBoxDisconnectCurrentIndexChanged(ptr)
        }
    }
    
    /// 设置当前文本变化回调
    public func setOnCurrentTextChanged(callback: CStringCallback) {
        unsafe {
            qComboBoxConnectCurrentTextChanged(ptr, callback)
        }
    }
    
    /// 断开当前文本变化回调
    public func disconnectCurrentTextChanged() {
        unsafe {
            qComboBoxDisconnectCurrentTextChanged(ptr)
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除下拉框
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qComboBoxDelete(ptr)
            }
            ptr = 0
        }
    }
}