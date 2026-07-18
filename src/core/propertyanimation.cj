package cjqt6.core

foreign func qPropertyAnimationCreate(targetPtr: Int64, propertyName: CString): Int64
foreign func qPropertyAnimationSetDuration(ptr: Int64, duration: Int32): Unit
foreign func qPropertyAnimationDuration(ptr: Int64): Int32
foreign func qPropertyAnimationSetStartValue(ptr: Int64, value: Float64): Unit
foreign func qPropertyAnimationSetEndValue(ptr: Int64, value: Float64): Unit
foreign func qPropertyAnimationStart(ptr: Int64): Unit
foreign func qPropertyAnimationStop(ptr: Int64): Unit
foreign func qPropertyAnimationSetLoopCount(ptr: Int64, count: Int32): Unit
foreign func qPropertyAnimationLoopCount(ptr: Int64): Int32
foreign func qPropertyAnimationSetEasingCurve(ptr: Int64, curveType: Int32): Unit
foreign func qPropertyAnimationDelete(ptr: Int64): Unit

public class EasingCurve {
    public static let Linear: Int32 = 0
    public static let InQuad: Int32 = 1
    public static let OutQuad: Int32 = 2
    public static let InOutQuad: Int32 = 3
    public static let InCubic: Int32 = 4
    public static let OutCubic: Int32 = 5
    public static let InOutCubic: Int32 = 6
    public static let InSine: Int32 = 7
    public static let OutSine: Int32 = 8
    public static let InOutSine: Int32 = 9
    public static let InElastic: Int32 = 14
    public static let OutElastic: Int32 = 15
    public static let InOutElastic: Int32 = 16
    public static let InBounce: Int32 = 17
    public static let OutBounce: Int32 = 18
    public static let InOutBounce: Int32 = 19
}

public class QPropertyAnimation <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    public init(target: Int64, propertyName: String) {
        unsafe {
            let cstr = LibC.mallocCString(propertyName)
            ptr = qPropertyAnimationCreate(target, cstr)
            LibC.free(cstr)
            if (ptr == 0) {
                throw CreateFailedException("QPropertyAnimation 创建失败")
            }
        }
    }

    public func setDuration(duration: Int32): Unit {
        checkValid()
        unsafe { qPropertyAnimationSetDuration(ptr, duration) }
    }

    public func duration(): Int32 {
        checkValid()
        unsafe { return qPropertyAnimationDuration(ptr) }
    }

    public func setStartValue(value: Float64): Unit {
        checkValid()
        unsafe { qPropertyAnimationSetStartValue(ptr, value) }
    }

    public func setEndValue(value: Float64): Unit {
        checkValid()
        unsafe { qPropertyAnimationSetEndValue(ptr, value) }
    }

    public func start(): Unit {
        checkValid()
        unsafe { qPropertyAnimationStart(ptr) }
    }

    public func stop(): Unit {
        checkValid()
        unsafe { qPropertyAnimationStop(ptr) }
    }

    public func setLoopCount(count: Int32): Unit {
        checkValid()
        unsafe { qPropertyAnimationSetLoopCount(ptr, count) }
    }

    public func loopCount(): Int32 {
        checkValid()
        unsafe { return qPropertyAnimationLoopCount(ptr) }
    }

    public func setEasingCurve(curveType: Int32): Unit {
        checkValid()
        unsafe { qPropertyAnimationSetEasingCurve(ptr, curveType) }
    }

    public func getPtr(): Int64 {
        return ptr
    }

    public func isClosed(): Bool {
        return closed
    }

    public func isValid(): Bool {
        return !closed && ptr != 0
    }

    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QPropertyAnimation 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QPropertyAnimation 指针为空")
        }
    }

    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe { qPropertyAnimationDelete(ptr) }
            closed = true
            ptr = 0
        }
    }

    public func delete(): Unit {
        close()
    }
}
