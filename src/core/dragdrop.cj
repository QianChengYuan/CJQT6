package CJQT6.core

// ============================================================
// 拖放支持 - QMimeData, QDrag
// ============================================================

// ============================================================
// QMimeData FFI声明
// ============================================================

foreign func qMimeDataCreate(): Int64
foreign func qMimeDataSetText(ptr: Int64, text: CString): Unit
foreign func qMimeDataText(ptr: Int64): CString
foreign func qMimeDataSetHtml(ptr: Int64, html: CString): Unit
foreign func qMimeDataHtml(ptr: Int64): CString
foreign func qMimeDataUrlsCount(ptr: Int64): Int32
foreign func qMimeDataUrlAt(ptr: Int64, index: Int32): CString
foreign func qMimeDataHasText(ptr: Int64): Bool
foreign func qMimeDataHasHtml(ptr: Int64): Bool
foreign func qMimeDataHasUrls(ptr: Int64): Bool
foreign func qMimeDataHasImage(ptr: Int64): Bool
foreign func qMimeDataClear(ptr: Int64): Unit
foreign func qMimeDataDelete(ptr: Int64): Unit

// ============================================================
// QDrag FFI声明
// ============================================================

foreign func qDragCreate(sourcePtr: Int64): Int64
foreign func qDragSetMimeData(ptr: Int64, mimeDataPtr: Int64): Unit
foreign func qDragSetPixmap(ptr: Int64, pixmapPtr: Int64): Unit
foreign func qDragSetHotSpot(ptr: Int64, x: Int32, y: Int32): Unit
foreign func qDragExec(ptr: Int64, supportedActions: Int32): Int32
foreign func qDragExecWithDefault(ptr: Int64, supportedActions: Int32, defaultAction: Int32): Int32
foreign func qDragSource(ptr: Int64): Int64
foreign func qDragTarget(ptr: Int64): Int64
foreign func qDragCancel(): Unit

// ============================================================
// 拖放动作常量 FFI
// ============================================================

foreign func qDropActionCopy(): Int32
foreign func qDropActionMove(): Int32
foreign func qDropActionLink(): Int32
foreign func qDropActionIgnore(): Int32

// ============================================================
// 拖放动作常量
// ============================================================

/// 复制动作
public func DropActionCopy(): Int32 {
    unsafe { qDropActionCopy() }
}

/// 移动动作
public func DropActionMove(): Int32 {
    unsafe { qDropActionMove() }
}

/// 链接动作
public func DropActionLink(): Int32 {
    unsafe { qDropActionLink() }
}

/// 忽略动作
public func DropActionIgnore(): Int32 {
    unsafe { qDropActionIgnore() }
}

// ============================================================
// QMimeData - MIME数据
// ============================================================

/// MIME数据类，用于拖放操作中传递数据
public class QMimeData {
    private var ptr: Int64 = 0
    private var owned: Bool = true
    
    public init() {
        unsafe {
            ptr = qMimeDataCreate()
        }
    }
    
    /// 从指针创建（不拥有所有权）
    public init(ptr: Int64, owned: Bool) {
        this.ptr = ptr
        this.owned = owned
    }
    
    /// 设置文本数据
    public func setText(text: String) {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qMimeDataSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取文本数据
    public func text(): String {
        unsafe {
            let cstr = qMimeDataText(ptr)
            return cstr.toString()
        }
    }
    
    /// 设置HTML数据
    public func setHtml(html: String) {
        unsafe {
            let cstr = LibC.mallocCString(html)
            qMimeDataSetHtml(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取HTML数据
    public func html(): String {
        unsafe {
            let cstr = qMimeDataHtml(ptr)
            return cstr.toString()
        }
    }
    
    /// 获取URL数量
    public func urlsCount(): Int32 {
        unsafe {
            return qMimeDataUrlsCount(ptr)
        }
    }
    
    /// 获取指定索引的URL
    public func urlAt(index: Int32): String {
        unsafe {
            let cstr = qMimeDataUrlAt(ptr, index)
            return cstr.toString()
        }
    }
    
    /// 是否包含文本
    public func hasText(): Bool {
        unsafe {
            return qMimeDataHasText(ptr)
        }
    }
    
    /// 是否包含HTML
    public func hasHtml(): Bool {
        unsafe {
            return qMimeDataHasHtml(ptr)
        }
    }
    
    /// 是否包含URL
    public func hasUrls(): Bool {
        unsafe {
            return qMimeDataHasUrls(ptr)
        }
    }
    
    /// 是否包含图像
    public func hasImage(): Bool {
        unsafe {
            return qMimeDataHasImage(ptr)
        }
    }
    
    /// 清空所有数据
    public func clear() {
        unsafe {
            qMimeDataClear(ptr)
        }
    }
    
    /// 获取指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除
    public func delete() {
        if (ptr != 0 && owned) {
            unsafe {
                qMimeDataDelete(ptr)
            }
            ptr = 0
        }
    }
}

// ============================================================
// QDrag - 拖放操作
// ============================================================

/// 拖放操作类
public class QDrag {
    private var ptr: Int64 = 0
    
    public init(sourcePtr: Int64) {
        unsafe {
            ptr = qDragCreate(sourcePtr)
        }
    }
    
    /// 设置MIME数据
    public func setMimeData(mimeData: QMimeData) {
        unsafe {
            qDragSetMimeData(ptr, mimeData.getPtr())
        }
    }
    
    /// 设置拖动图像
    public func setPixmap(pixmapPtr: Int64) {
        unsafe {
            qDragSetPixmap(ptr, pixmapPtr)
        }
    }
    
    /// 设置热点位置
    public func setHotSpot(x: Int32, y: Int32) {
        unsafe {
            qDragSetHotSpot(ptr, x, y)
        }
    }
    
    /// 执行拖放操作
    /// 返回实际执行的动作
    public func exec(supportedActions: Int32): Int32 {
        unsafe {
            return qDragExec(ptr, supportedActions)
        }
    }
    
    /// 执行拖放操作（带默认动作）
    public func exec(supportedActions: Int32, defaultAction: Int32): Int32 {
        unsafe {
            return qDragExecWithDefault(ptr, supportedActions, defaultAction)
        }
    }
    
    /// 获取源控件
    public func source(): Int64 {
        unsafe {
            return qDragSource(ptr)
        }
    }
    
    /// 获取目标控件
    public func target(): Int64 {
        unsafe {
            return qDragTarget(ptr)
        }
    }
    
    /// 取消拖放操作
    public static func cancel() {
        unsafe {
            qDragCancel()
        }
    }
    
    /// 获取指针
    public func getPtr(): Int64 {
        return ptr
    }
}

// ============================================================
// 拖放辅助函数
// ============================================================

/// 开始文本拖放
public func startTextDrag(sourcePtr: Int64, text: String, supportedActions: Int32): Int32 {
    let drag = QDrag(sourcePtr)
    let mimeData = QMimeData()
    mimeData.setText(text)
    drag.setMimeData(mimeData)
    return drag.exec(supportedActions)
}

/// 开始文件拖放
public func startFileDrag(sourcePtr: Int64, filePath: String, supportedActions: Int32): Int32 {
    let drag = QDrag(sourcePtr)
    let mimeData = QMimeData()
    mimeData.setText(filePath)  // 简化实现
    drag.setMimeData(mimeData)
    return drag.exec(supportedActions)
}
