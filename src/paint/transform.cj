package CJQT6.paint

// QTransform - 2D变换矩阵
foreign func qTransformCreate(): Int64
foreign func qTransformCreateWithValues(m11: Float32, m12: Float32, m13: Float32, m21: Float32, m22: Float32, m23: Float32, m31: Float32, m32: Float32, m33: Float32): Int64
foreign func qTransformSetMatrix(ptr: Int64, m11: Float32, m12: Float32, m13: Float32, m21: Float32, m22: Float32, m23: Float32, m31: Float32, m32: Float32, m33: Float32): Unit
foreign func qTransformTranslate(ptr: Int64, dx: Float32, dy: Float32): Int64
foreign func qTransformScale(ptr: Int64, sx: Float32, sy: Float32): Int64
foreign func qTransformRotate(ptr: Int64, angle: Float32): Int64
foreign func qTransformShear(ptr: Int64, sh: Float32, sv: Float32): Int64
foreign func qTransformM11(ptr: Int64): Float32
foreign func qTransformM12(ptr: Int64): Float32
foreign func qTransformM13(ptr: Int64): Float32
foreign func qTransformM21(ptr: Int64): Float32
foreign func qTransformM22(ptr: Int64): Float32
foreign func qTransformM23(ptr: Int64): Float32
foreign func qTransformM31(ptr: Int64): Float32
foreign func qTransformM32(ptr: Int64): Float32
foreign func qTransformM33(ptr: Int64): Float32
foreign func qTransformDx(ptr: Int64): Float32
foreign func qTransformDy(ptr: Int64): Float32
foreign func qTransformIsIdentity(ptr: Int64): Int32
foreign func qTransformIsInvertible(ptr: Int64): Int32
foreign func qTransformInverted(ptr: Int64): Int64
foreign func qTransformMultiply(ptr: Int64, other: Int64): Int64
foreign func qTransformDelete(ptr: Int64): Unit

/// 2D变换矩阵
public class QTransform {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe { ptr = qTransformCreate() }
    }
    
    public init(m11: Float32, m12: Float32, m13: Float32, m21: Float32, m22: Float32, m23: Float32, m31: Float32, m32: Float32, m33: Float32) {
        unsafe { ptr = qTransformCreateWithValues(m11, m12, m13, m21, m22, m23, m31, m32, m33) }
    }
    
    /// 设置矩阵值
    public func setMatrix(m11: Float32, m12: Float32, m13: Float32, m21: Float32, m22: Float32, m23: Float32, m31: Float32, m32: Float32, m33: Float32): Unit {
        unsafe { qTransformSetMatrix(ptr, m11, m12, m13, m21, m22, m23, m31, m32, m33) }
    }
    
    /// 平移变换，返回新变换
    public func translate(dx: Float32, dy: Float32): QTransform {
        let t = QTransform()
        unsafe { t.ptr = qTransformTranslate(ptr, dx, dy) }
        return t
    }
    
    /// 缩放变换，返回新变换
    public func scale(sx: Float32, sy: Float32): QTransform {
        let t = QTransform()
        unsafe { t.ptr = qTransformScale(ptr, sx, sy) }
        return t
    }
    
    /// 旋转变换，返回新变换
    public func rotate(angle: Float32): QTransform {
        let t = QTransform()
        unsafe { t.ptr = qTransformRotate(ptr, angle) }
        return t
    }
    
    /// 扭曲变换，返回新变换
    public func shear(sh: Float32, sv: Float32): QTransform {
        let t = QTransform()
        unsafe { t.ptr = qTransformShear(ptr, sh, sv) }
        return t
    }
    
    /// 获取矩阵元素
    public func m11(): Float32 { unsafe { qTransformM11(ptr) } }
    public func m12(): Float32 { unsafe { qTransformM12(ptr) } }
    public func m13(): Float32 { unsafe { qTransformM13(ptr) } }
    public func m21(): Float32 { unsafe { qTransformM21(ptr) } }
    public func m22(): Float32 { unsafe { qTransformM22(ptr) } }
    public func m23(): Float32 { unsafe { qTransformM23(ptr) } }
    public func m31(): Float32 { unsafe { qTransformM31(ptr) } }
    public func m32(): Float32 { unsafe { qTransformM32(ptr) } }
    public func m33(): Float32 { unsafe { qTransformM33(ptr) } }
    
    /// 获取平移量
    public func dx(): Float32 { unsafe { qTransformDx(ptr) } }
    public func dy(): Float32 { unsafe { qTransformDy(ptr) } }
    
    /// 是否为单位矩阵
    public func isIdentity(): Bool { unsafe { qTransformIsIdentity(ptr) != 0 } }
    
    /// 是否可逆
    public func isInvertible(): Bool { unsafe { qTransformIsInvertible(ptr) != 0 } }
    
    /// 获取逆变换
    public func inverted(): QTransform {
        let t = QTransform()
        unsafe { t.ptr = qTransformInverted(ptr) }
        return t
    }
    
    /// 矩阵乘法
    public func multiply(other: QTransform): QTransform {
        let t = QTransform()
        unsafe { t.ptr = qTransformMultiply(ptr, other.getPtr()) }
        return t
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 { ptr }
    
    /// 删除变换
    public func delete() {
        if (ptr != 0) {
            unsafe { qTransformDelete(ptr) }
            ptr = 0
        }
    }
}
