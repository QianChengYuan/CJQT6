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
foreign func qRubberBandDelete(ptr: Int64): Unit

public class QRubberBand {
    private var ptr: Int64 = 0
    
    public init(shape: Int32, parent: QWidget) {
        unsafe {
            ptr = qRubberBandCreate(shape, parent.getPtr())
        }
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
    
    public func getPtr(): Int64 {
        return ptr
    }
    
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qRubberBandDelete(ptr)
            }
            ptr = 0
        }
    }
}

public class RubberBandShape {
    public static let Line: Int32 = 0
    public static let Rectangle: Int32 = 1
}