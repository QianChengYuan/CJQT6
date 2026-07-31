package cjqt6.widgets

// ============================================================
// QGraphicsOpacityEffect / QGraphicsDropShadowEffect - 图形特效
// ============================================================

foreign func qGraphicsOpacityEffectCreate(): Int64
foreign func qGraphicsOpacityEffectSetOpacity(ptr: Int64, opacity: Float64): Unit
foreign func qGraphicsOpacityEffectOpacity(ptr: Int64): Float64
foreign func qGraphicsOpacityEffectSetEnabled(ptr: Int64, enabled: Bool): Unit
foreign func qGraphicsOpacityEffectDelete(ptr: Int64): Unit

foreign func qGraphicsDropShadowEffectCreate(): Int64
foreign func qGraphicsDropShadowEffectSetOffset(ptr: Int64, dx: Float64, dy: Float64): Unit
foreign func qGraphicsDropShadowEffectSetBlurRadius(ptr: Int64, radius: Float64): Unit
foreign func qGraphicsDropShadowEffectBlurRadius(ptr: Int64): Float64
foreign func qGraphicsDropShadowEffectSetColor(ptr: Int64, r: Int32, g: Int32, b: Int32, a: Int32): Unit
foreign func qGraphicsDropShadowEffectSetEnabled(ptr: Int64, enabled: Bool): Unit
foreign func qGraphicsDropShadowEffectDelete(ptr: Int64): Unit
foreign func qGraphicsDropShadowEffectXOffset(ptr: Int64): Float64
foreign func qGraphicsDropShadowEffectSetXOffset(ptr: Int64, v: Float64): Unit
foreign func qGraphicsDropShadowEffectYOffset(ptr: Int64): Float64
foreign func qGraphicsDropShadowEffectSetYOffset(ptr: Int64, v: Float64): Unit

/// 透明度特效，可调整控件的整体不透明度（0.0 全透明 - 1.0 不透明）
public class QGraphicsOpacityEffect {
    private var ptr: Int64 = 0

    /// 创建透明度特效
    public init() {
        unsafe { ptr = qGraphicsOpacityEffectCreate() }
    }

    /// 设置不透明度（0.0 - 1.0），返回自身以支持链式调用
    public func setOpacity(opacity: Float64): QGraphicsOpacityEffect {
        unsafe { qGraphicsOpacityEffectSetOpacity(ptr, opacity) }
        this
    }

    /// 获取当前不透明度（0.0 - 1.0）
    public func opacity(): Float64 {
        unsafe { qGraphicsOpacityEffectOpacity(ptr) }
    }

    /// 启用或禁用特效，返回自身以支持链式调用
    public func setEnabled(enabled: Bool): QGraphicsOpacityEffect {
        unsafe { qGraphicsOpacityEffectSetEnabled(ptr, enabled) }
        this
    }

    /// 释放底层资源
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qGraphicsOpacityEffectDelete(ptr) }
            ptr = 0
        }
    }
}

/// 投影特效，为控件绘制带模糊的阴影，支持偏移、模糊半径与颜色设置
public class QGraphicsDropShadowEffect {
    private var ptr: Int64 = 0

    /// 创建投影特效
    public init() {
        unsafe { ptr = qGraphicsDropShadowEffectCreate() }
    }

    /// 设置阴影偏移（dx/dy，像素），返回自身以支持链式调用
    public func setOffset(dx: Float64, dy: Float64): QGraphicsDropShadowEffect {
        unsafe { qGraphicsDropShadowEffectSetOffset(ptr, dx, dy) }
        this
    }

    /// 设置阴影模糊半径（像素），返回自身以支持链式调用
    public func setBlurRadius(radius: Float64): QGraphicsDropShadowEffect {
        unsafe { qGraphicsDropShadowEffectSetBlurRadius(ptr, radius) }
        this
    }

    /// 获取阴影模糊半径（像素）
    public func blurRadius(): Float64 {
        unsafe { qGraphicsDropShadowEffectBlurRadius(ptr) }
    }

    /// 设置阴影颜色（RGBA，各分量 0-255），返回自身以支持链式调用
    public func setColor(r: Int32, g: Int32, b: Int32, a: Int32): QGraphicsDropShadowEffect {
        unsafe { qGraphicsDropShadowEffectSetColor(ptr, r, g, b, a) }
        this
    }

    /// 获取阴影水平偏移（像素）
    public func xOffset(): Float64 {
        unsafe { qGraphicsDropShadowEffectXOffset(ptr) }
    }

    /// 设置阴影水平偏移（像素），返回自身以支持链式调用
    public func setXOffset(v: Float64): QGraphicsDropShadowEffect {
        unsafe { qGraphicsDropShadowEffectSetXOffset(ptr, v) }
        this
    }

    /// 获取阴影垂直偏移（像素）
    public func yOffset(): Float64 {
        unsafe { qGraphicsDropShadowEffectYOffset(ptr) }
    }

    /// 设置阴影垂直偏移（像素），返回自身以支持链式调用
    public func setYOffset(v: Float64): QGraphicsDropShadowEffect {
        unsafe { qGraphicsDropShadowEffectSetYOffset(ptr, v) }
        this
    }

    /// 启用或禁用特效，返回自身以支持链式调用
    public func setEnabled(enabled: Bool): QGraphicsDropShadowEffect {
        unsafe { qGraphicsDropShadowEffectSetEnabled(ptr, enabled) }
        this
    }

    /// 释放底层资源
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qGraphicsDropShadowEffectDelete(ptr) }
            ptr = 0
        }
    }
}
