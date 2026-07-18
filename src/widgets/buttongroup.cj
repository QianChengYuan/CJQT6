package cjqt6.widgets

import cjqt6.core.*

// QButtonGroup - 按钮分组
foreign func qButtonGroupCreate(): Int64
foreign func qButtonGroupAddButton(ptr: Int64, btnPtr: Int64, id: Int32): Unit
foreign func qButtonGroupRemoveButton(ptr: Int64, btnPtr: Int64): Unit
foreign func qButtonGroupSetExclusive(ptr: Int64, exclusive: Bool): Unit
foreign func qButtonGroupIsExclusive(ptr: Int64): Bool
foreign func qButtonGroupCheckedId(ptr: Int64): Int32
foreign func qButtonGroupCheckedButton(ptr: Int64): Int64
foreign func qButtonGroupSetId(ptr: Int64, btnPtr: Int64, id: Int32): Unit
foreign func qButtonGroupId(ptr: Int64, btnPtr: Int64): Int32
foreign func qButtonGroupButtonsCount(ptr: Int64): Int32
foreign func qButtonGroupDelete(ptr: Int64): Unit

/// 按钮分组
/// 用于管理一组按钮（如 QRadioButton、QCheckBox）的互斥行为
public class QButtonGroup {
    private var ptr: Int64 = 0

    public init() {
        unsafe {
            ptr = qButtonGroupCreate()
        }
    }

    /// 添加按钮到分组，并指定ID
    public func addButton(btnPtr: Int64, id: Int32): Unit {
        unsafe {
            qButtonGroupAddButton(ptr, btnPtr, id)
        }
    }

    /// 从分组移除按钮
    public func removeButton(btnPtr: Int64): Unit {
        unsafe {
            qButtonGroupRemoveButton(ptr, btnPtr)
        }
    }

    /// 设置是否互斥（默认true）
    public func setExclusive(exclusive: Bool): Unit {
        unsafe {
            qButtonGroupSetExclusive(ptr, exclusive)
        }
    }

    /// 获取是否互斥
    public func isExclusive(): Bool {
        unsafe {
            return qButtonGroupIsExclusive(ptr)
        }
    }

    /// 获取当前选中按钮的ID，无选中返回 -1
    public func checkedId(): Int32 {
        unsafe {
            return qButtonGroupCheckedId(ptr)
        }
    }

    /// 获取当前选中的按钮指针
    public func checkedButton(): Int64 {
        unsafe {
            return qButtonGroupCheckedButton(ptr)
        }
    }

    /// 设置按钮的ID
    public func setId(btnPtr: Int64, id: Int32): Unit {
        unsafe {
            qButtonGroupSetId(ptr, btnPtr, id)
        }
    }

    /// 获取按钮的ID
    public func id(btnPtr: Int64): Int32 {
        unsafe {
            return qButtonGroupId(ptr, btnPtr)
        }
    }

    /// 获取分组中的按钮数量
    public func buttonsCount(): Int32 {
        unsafe {
            return qButtonGroupButtonsCount(ptr)
        }
    }

    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }

    /// 删除按钮分组
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qButtonGroupDelete(ptr)
            }
            ptr = 0
        }
    }
}
