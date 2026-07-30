package cjqt6.core

// ============================================================
// QAbstractAnimation / QParallelAnimationGroup FFI declarations
// ============================================================

foreign func qParallelAnimationGroupCreate(): Int64

foreign func qAnimationGroupAddAnimation(groupPtr: Int64, animPtr: Int64): Unit
foreign func qAnimationGroupRemoveAnimation(groupPtr: Int64, animPtr: Int64): Unit
foreign func qAnimationGroupAnimationCount(groupPtr: Int64): Int32

foreign func qAbstractAnimationStart(ptr: Int64): Unit
foreign func qAbstractAnimationStop(ptr: Int64): Unit
foreign func qAbstractAnimationPause(ptr: Int64): Unit
foreign func qAbstractAnimationResume(ptr: Int64): Unit
foreign func qAbstractAnimationState(ptr: Int64): Int32
foreign func qAbstractAnimationDuration(ptr: Int64): Int64
foreign func qAbstractAnimationSetLoopCount(ptr: Int64, count: Int32): Unit
foreign func qAbstractAnimationLoopCount(ptr: Int64): Int32
foreign func qAbstractAnimationCurrentTime(ptr: Int64): Int32
foreign func qAbstractAnimationSetCurrentTime(ptr: Int64, ms: Int32): Unit
foreign func qAbstractAnimationCurrentLoop(ptr: Int64): Int32
foreign func qAbstractAnimationSetDirection(ptr: Int64, direction: Int32): Unit
foreign func qAbstractAnimationDirection(ptr: Int64): Int32

foreign func qParallelAnimationGroupDelete(ptr: Int64): Unit
foreign func qAbstractAnimationDelete(ptr: Int64): Unit


// ============================================================
// 动画状态常量
// ============================================================
public class AnimationState {
    public static func stopped(): Int32 { 0 }
    public static func paused(): Int32 { 1 }
    public static func running(): Int32 { 2 }
}

// ============================================================
// 动画方向常量
// ============================================================
public class AnimationDirection {
    public static func forward(): Int32 { 0 }
    public static func backward(): Int32 { 1 }
}


// ============================================================
// QAbstractAnimation - 动画基类
// ============================================================
public class QAbstractAnimation {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QAbstractAnimation already deleted")
        }
    }

    internal init(p: Int64) {
        ptr = p
    }

    /// 启动动画
    public func start(): Unit {
        checkValid()
        unsafe { qAbstractAnimationStart(ptr) }
    }

    /// 停止动画
    public func stop(): Unit {
        checkValid()
        unsafe { qAbstractAnimationStop(ptr) }
    }

    /// 暂停动画
    public func pause(): Unit {
        checkValid()
        unsafe { qAbstractAnimationPause(ptr) }
    }

    /// 恢复动画
    public func resume(): Unit {
        checkValid()
        unsafe { qAbstractAnimationResume(ptr) }
    }

    /// 获取动画状态
    public func state(): Int32 {
        checkValid()
        unsafe { qAbstractAnimationState(ptr) }
    }

    /// 获取动画持续时间
    public func duration(): Int64 {
        checkValid()
        unsafe { qAbstractAnimationDuration(ptr) }
    }

    /// 设置循环次数
    public func setLoopCount(count: Int32): Unit {
        checkValid()
        unsafe { qAbstractAnimationSetLoopCount(ptr, count) }
    }

    /// 获取循环次数
    public func loopCount(): Int32 {
        checkValid()
        unsafe { qAbstractAnimationLoopCount(ptr) }
    }

    /// 获取当前时间
    public func currentTime(): Int32 {
        checkValid()
        unsafe { qAbstractAnimationCurrentTime(ptr) }
    }

    /// 设置当前时间
    public func setCurrentTime(ms: Int32): Unit {
        checkValid()
        unsafe { qAbstractAnimationSetCurrentTime(ptr, ms) }
    }

    /// 获取当前循环
    public func currentLoop(): Int32 {
        checkValid()
        unsafe { qAbstractAnimationCurrentLoop(ptr) }
    }

    /// 设置播放方向
    public func setDirection(direction: Int32): Unit {
        checkValid()
        unsafe { qAbstractAnimationSetDirection(ptr, direction) }
    }

    /// 获取播放方向
    public func direction(): Int32 {
        checkValid()
        unsafe { qAbstractAnimationDirection(ptr) }
    }

    /// 获取原生指针
    public func getPtr(): Int64 { ptr }

    /// 释放资源
    public func delete(): Unit {
        if (!closed && ptr != 0) {
            unsafe { qAbstractAnimationDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}


// ============================================================
// QParallelAnimationGroup - 并行动画组
// ============================================================
public class QParallelAnimationGroup {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    private func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QParallelAnimationGroup already deleted")
        }
    }

    public init() {
        unsafe { ptr = qParallelAnimationGroupCreate() }
        if (ptr == 0) {
            throw CreateFailedException("QParallelAnimationGroup create failed")
        }
    }

    /// 添加动画
    public func addAnimation(animPtr: Int64): Unit {
        checkValid()
        unsafe { qAnimationGroupAddAnimation(ptr, animPtr) }
    }

    /// 移除动画
    public func removeAnimation(animPtr: Int64): Unit {
        checkValid()
        unsafe { qAnimationGroupRemoveAnimation(ptr, animPtr) }
    }

    /// 获取动画数量
    public func animationCount(): Int32 {
        checkValid()
        unsafe { qAnimationGroupAnimationCount(ptr) }
    }

    // ---- 动画控制（委托到 QAbstractAnimation） ----

    /// 启动
    public func start(): Unit {
        checkValid()
        unsafe { qAbstractAnimationStart(ptr) }
    }

    /// 停止
    public func stop(): Unit {
        checkValid()
        unsafe { qAbstractAnimationStop(ptr) }
    }

    /// 暂停
    public func pause(): Unit {
        checkValid()
        unsafe { qAbstractAnimationPause(ptr) }
    }

    /// 恢复
    public func resume(): Unit {
        checkValid()
        unsafe { qAbstractAnimationResume(ptr) }
    }

    /// 获取状态
    public func state(): Int32 {
        checkValid()
        unsafe { qAbstractAnimationState(ptr) }
    }

    /// 获取持续时间
    public func duration(): Int64 {
        checkValid()
        unsafe { qAbstractAnimationDuration(ptr) }
    }

    /// 设置循环次数
    public func setLoopCount(count: Int32): Unit {
        checkValid()
        unsafe { qAbstractAnimationSetLoopCount(ptr, count) }
    }

    /// 获取循环次数
    public func loopCount(): Int32 {
        checkValid()
        unsafe { qAbstractAnimationLoopCount(ptr) }
    }

    /// 设置方向
    public func setDirection(direction: Int32): Unit {
        checkValid()
        unsafe { qAbstractAnimationSetDirection(ptr, direction) }
    }

    /// 获取方向
    public func direction(): Int32 {
        checkValid()
        unsafe { qAbstractAnimationDirection(ptr) }
    }

    /// 获取原生指针
    public func getPtr(): Int64 { ptr }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe { qParallelAnimationGroupDelete(ptr) }
            ptr = 0
            closed = true
        }
    }
}
