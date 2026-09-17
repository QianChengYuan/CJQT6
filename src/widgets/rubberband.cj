package cjqt6.widgets

import cjqt6.core.*

// QRubberBand FFI
foreign func qRubberBandCreate(shape: Int32, parentPtr: Int64): Int64

foreign func qRubberBandSetGeometry(ptr: Int64, x: Int32, y: Int32, w: Int32, h: Int32): Unit

foreign func qRubberBandMove(ptr: Int64, x: Int32, y: Int32): Unit

foreign func qRubberBandResize(ptr: Int64, w: Int32, h: Int32): Unit

foreign func qRubberBandShow(ptr: Int64): Unit

foreign func qRubberBandHide(ptr: Int64): Unit

foreign func qRubberBandGeometryX(ptr: Int64): Int32

foreign func qRubberBandGeometryY(ptr: Int64): Int32

foreign func qRubberBandGeometryWidth(ptr: Int64): Int32

foreign func qRubberBandGeometryHeight(ptr: Int64): Int32

foreign func qRubberBandSetShape(ptr: Int64, shape: Int32): Unit

foreign func qRubberBandShape(ptr: Int64): Int32

foreign func qRubberBandDelete(ptr: Int64): Unit

/// 橡皮筋选框控件，用于在父控件上绘制矩形选择区域（如拖拽框选）
public class QRubberBand <: QtWidgetCore {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    public init(shape: Int32, parent: QWidget) {
        unsafe {
            ptr = qRubberBandCreate(shape, parent.getPtr())
        }
        trackObject(ptr)
    }

    public func setGeometry(x: Int32, y: Int32, w: Int32, h: Int32): Unit {
        unsafe { qRubberBandSetGeometry(ptr, x, y, w, h) }
    }

    public func move(x: Int32, y: Int32): Unit {
        unsafe { qRubberBandMove(ptr, x, y) }
    }

    public func resize(w: Int32, h: Int32): Unit {
        unsafe { qRubberBandResize(ptr, w, h) }
    }

    public func show(): Unit {
        unsafe { qRubberBandShow(ptr) }
    }

    public func hide(): Unit {
        unsafe { qRubberBandHide(ptr) }
    }

    public func x(): Int32 {
        unsafe { return qRubberBandGeometryX(ptr) }
    }

    public func y(): Int32 {
        unsafe { return qRubberBandGeometryY(ptr) }
    }

    public func width(): Int32 {
        unsafe { return qRubberBandGeometryWidth(ptr) }
    }

    public func height(): Int32 {
        unsafe { return qRubberBandGeometryHeight(ptr) }
    }

    /// 设置形状（RubberBandShape.Line / .Rectangle）
    public func setShape(shape: Int32): Unit {
        unsafe { qRubberBandSetShape(ptr, shape) }
    }

    /// 获取形状
    public func shape(): Int32 {
        unsafe { return qRubberBandShape(ptr) }
    }

    public func getPtr(): Int64 {
        return ptr
    }

    /// 是否已关闭
    public func isClosed(): Bool {
        closed
    }

    /// 对象是否仍然可用
    public func isValid(): Bool {
        !closed && ptr != 0 && isObjectAlive(ptr)
    }

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QRubberBand 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QRubberBand 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QRubberBand 底层 Qt 对象已失效")
        }
    }

    /// 关闭资源，释放 Qt 对象（幂等）
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
                qRubberBandDelete(ptr)
            }
        }
        closed = true
        ptr = 0
    }

    /// 删除部件（兼容旧 API，等价于 close()）
    public func delete(): Unit {
        close()
    }
}

/// 橡皮筋选框形状枚举：直线/矩形
public class RubberBandShape {
    public static let Line: Int32 = 0
    public static let Rectangle: Int32 = 1
}
