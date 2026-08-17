package cjqt6.widgets

import cjqt6.core.*

// QSizeGrip FFI 声明
foreign func qSizeGripCreate(parentPtr: Int64): Int64
foreign func qSizeGripSetVisible(ptr: Int64, visible: Bool): Unit
foreign func qSizeGripDelete(ptr: Int64): Unit

/// 窗口右下角调整大小手柄
public class QSizeGrip {
    private var ptr: Int64 = 0
    
    public init(parent: QWidget) {
        unsafe {
            ptr = qSizeGripCreate(parent.getPtr())
        }
    }
    
    /// 设置可见性
    public func setVisible(visible: Bool): Unit {
        unsafe { qSizeGripSetVisible(ptr, visible) }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除部件
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qSizeGripDelete(ptr)
            }
            ptr = 0
        }
    }
}
