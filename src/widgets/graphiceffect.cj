package cjqt6.widgets

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

public class QGraphicsOpacityEffect {
    private var ptr: Int64 = 0

    public init() {
        unsafe { ptr = qGraphicsOpacityEffectCreate() }
    }

    public func setOpacity(opacity: Float64): QGraphicsOpacityEffect {
        unsafe { qGraphicsOpacityEffectSetOpacity(ptr, opacity) }
        this
    }

    public func opacity(): Float64 {
        unsafe { qGraphicsOpacityEffectOpacity(ptr) }
    }

    public func setEnabled(enabled: Bool): QGraphicsOpacityEffect {
        unsafe { qGraphicsOpacityEffectSetEnabled(ptr, enabled) }
        this
    }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qGraphicsOpacityEffectDelete(ptr) }
            ptr = 0
        }
    }
}

public class QGraphicsDropShadowEffect {
    private var ptr: Int64 = 0

    public init() {
        unsafe { ptr = qGraphicsDropShadowEffectCreate() }
    }

    public func setOffset(dx: Float64, dy: Float64): QGraphicsDropShadowEffect {
        unsafe { qGraphicsDropShadowEffectSetOffset(ptr, dx, dy) }
        this
    }

    public func setBlurRadius(radius: Float64): QGraphicsDropShadowEffect {
        unsafe { qGraphicsDropShadowEffectSetBlurRadius(ptr, radius) }
        this
    }

    public func blurRadius(): Float64 {
        unsafe { qGraphicsDropShadowEffectBlurRadius(ptr) }
    }

    public func setColor(r: Int32, g: Int32, b: Int32, a: Int32): QGraphicsDropShadowEffect {
        unsafe { qGraphicsDropShadowEffectSetColor(ptr, r, g, b, a) }
        this
    }

    public func xOffset(): Float64 {
        unsafe { qGraphicsDropShadowEffectXOffset(ptr) }
    }

    public func setXOffset(v: Float64): QGraphicsDropShadowEffect {
        unsafe { qGraphicsDropShadowEffectSetXOffset(ptr, v) }
        this
    }

    public func yOffset(): Float64 {
        unsafe { qGraphicsDropShadowEffectYOffset(ptr) }
    }

    public func setYOffset(v: Float64): QGraphicsDropShadowEffect {
        unsafe { qGraphicsDropShadowEffectSetYOffset(ptr, v) }
        this
    }

    public func setEnabled(enabled: Bool): QGraphicsDropShadowEffect {
        unsafe { qGraphicsDropShadowEffectSetEnabled(ptr, enabled) }
        this
    }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qGraphicsDropShadowEffectDelete(ptr) }
            ptr = 0
        }
    }
}
