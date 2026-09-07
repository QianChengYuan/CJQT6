package cjqt6.core

// ============================================================
// QPropertyAnimation - 属性动画
// ============================================================

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

/// 缓动曲线类型常量（值对齐 Qt 官方 QEasingCurve::Type 枚举，native 侧 static_cast 直传）
public class EasingCurve {
    /// 线性匀速（Qt 0）
    public static let Linear: Int32 = 0
    /// 二次缓入（加速）
    public static let InQuad: Int32 = 1
    /// 二次缓出（减速）
    public static let OutQuad: Int32 = 2
    /// 二次缓入缓出
    public static let InOutQuad: Int32 = 3
    /// 二次缓出缓入
    public static let OutInQuad: Int32 = 4
    /// 三次缓入（加速）
    public static let InCubic: Int32 = 5
    /// 三次缓出（减速）
    public static let OutCubic: Int32 = 6
    /// 三次缓入缓出
    public static let InOutCubic: Int32 = 7
    /// 三次缓出缓入
    public static let OutInCubic: Int32 = 8
    /// 四次缓入
    public static let InQuart: Int32 = 9
    /// 四次缓出
    public static let OutQuart: Int32 = 10
    /// 四次缓入缓出
    public static let InOutQuart: Int32 = 11
    /// 四次缓出缓入
    public static let OutInQuart: Int32 = 12
    /// 五次缓入
    public static let InQuint: Int32 = 13
    /// 五次缓出
    public static let OutQuint: Int32 = 14
    /// 五次缓入缓出
    public static let InOutQuint: Int32 = 15
    /// 五次缓出缓入
    public static let OutInQuint: Int32 = 16
    /// 正弦缓入（加速）
    public static let InSine: Int32 = 17
    /// 正弦缓出（减速）
    public static let OutSine: Int32 = 18
    /// 正弦缓入缓出
    public static let InOutSine: Int32 = 19
    /// 正弦缓出缓入
    public static let OutInSine: Int32 = 20
    /// 指数缓入
    public static let InExpo: Int32 = 21
    /// 指数缓出
    public static let OutExpo: Int32 = 22
    /// 指数缓入缓出
    public static let InOutExpo: Int32 = 23
    /// 指数缓出缓入
    public static let OutInExpo: Int32 = 24
    /// 圆形缓入
    public static let InCirc: Int32 = 25
    /// 圆形缓出
    public static let OutCirc: Int32 = 26
    /// 圆形缓入缓出
    public static let InOutCirc: Int32 = 27
    /// 圆形缓出缓入
    public static let OutInCirc: Int32 = 28
    /// 弹性缓入
    public static let InElastic: Int32 = 29
    /// 弹性缓出
    public static let OutElastic: Int32 = 30
    /// 弹性缓入缓出
    public static let InOutElastic: Int32 = 31
    /// 弹性缓出缓入
    public static let OutInElastic: Int32 = 32
    /// 回退缓入
    public static let InBack: Int32 = 33
    /// 回退缓出
    public static let OutBack: Int32 = 34
    /// 回退缓入缓出
    public static let InOutBack: Int32 = 35
    /// 回退缓出缓入
    public static let OutInBack: Int32 = 36
    /// 弹跳缓入
    public static let InBounce: Int32 = 37
    /// 弹跳缓出
    public static let OutBounce: Int32 = 38
    /// 弹跳缓入缓出
    public static let InOutBounce: Int32 = 39
    /// 弹跳缓出缓入
    public static let OutInBounce: Int32 = 40
}

/// 属性动画，驱动目标对象的指定数值属性在起止值间随时间变化
public class QPropertyAnimation <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// 创建属性动画，target 为目标对象指针，propertyName 为属性名（本封装按 Float64 数值处理）
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init(target: Int64, propertyName: String) {
        unsafe {
            let cstr = LibC.mallocCString(propertyName)
            ptr = qPropertyAnimationCreate(target, cstr)
            LibC.free(cstr)
            if (ptr == 0) {
                throw CreateFailedException("QPropertyAnimation 创建失败")
            }
        }
        trackObject(ptr)
    }

    /// 设置动画时长（毫秒）
    public func setDuration(duration: Int32): Unit {
        checkValid()
        unsafe { qPropertyAnimationSetDuration(ptr, duration) }
    }

    /// 获取动画时长（毫秒）
    public func duration(): Int32 {
        checkValid()
        unsafe { return qPropertyAnimationDuration(ptr) }
    }

    /// 设置起始值
    public func setStartValue(value: Float64): Unit {
        checkValid()
        unsafe { qPropertyAnimationSetStartValue(ptr, value) }
    }

    /// 设置结束值
    public func setEndValue(value: Float64): Unit {
        checkValid()
        unsafe { qPropertyAnimationSetEndValue(ptr, value) }
    }

    /// 开始播放动画
    public func start(): Unit {
        checkValid()
        unsafe { qPropertyAnimationStart(ptr) }
    }

    /// 停止播放动画
    public func stop(): Unit {
        checkValid()
        unsafe { qPropertyAnimationStop(ptr) }
    }

    /// 设置循环次数（-1 表示无限循环）
    public func setLoopCount(count: Int32): Unit {
        checkValid()
        unsafe { qPropertyAnimationSetLoopCount(ptr, count) }
    }

    /// 获取循环次数
    public func loopCount(): Int32 {
        checkValid()
        unsafe { return qPropertyAnimationLoopCount(ptr) }
    }

    /// 设置缓动曲线，curveType 使用 EasingCurve 常量
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
        return !closed && ptr != 0 && isObjectAlive(ptr)
    }

    /// throws: NullPointerException 空指针访问时抛出
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QPropertyAnimation 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QPropertyAnimation 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QPropertyAnimation 底层 Qt 对象已失效")
        }
    }

    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            unsafe { qPropertyAnimationDelete(ptr) }
            closed = true
            ptr = 0
        }
    }

    public func delete(): Unit {
        close()
    }
}
