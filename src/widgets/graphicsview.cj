package cjqt6.widgets

import cjqt6.core.*

// ============================================================
// FFI 声明 - QGraphicsView
// ============================================================

foreign func qGraphicsViewCreate(parentPtr: Int64): Int64
foreign func qGraphicsViewDelete(ptr: Int64): Unit

foreign func qGraphicsViewSetScene(ptr: Int64, scenePtr: Int64): Unit
foreign func qGraphicsViewScene(ptr: Int64): Int64

foreign func qGraphicsViewSetRenderHint(ptr: Int64, hint: Int32, enabled: Bool): Unit
foreign func qGraphicsViewSetRenderHints(ptr: Int64, hints: Int32): Unit
foreign func qGraphicsViewSetDragMode(ptr: Int64, mode: Int32): Unit
foreign func qGraphicsViewDragMode(ptr: Int64): Int32
foreign func qGraphicsViewSetViewportUpdateMode(ptr: Int64, mode: Int32): Unit

foreign func qGraphicsViewCenterOn(ptr: Int64, x: Float64, y: Float64): Unit
foreign func qGraphicsViewFitInView(ptr: Int64, x: Float64, y: Float64, w: Float64, h: Float64): Unit
foreign func qGraphicsViewScale(ptr: Int64, fx: Float64, fy: Float64): Unit
foreign func qGraphicsViewRotate(ptr: Int64, angle: Float64): Unit
foreign func qGraphicsViewTranslate(ptr: Int64, dx: Float64, dy: Float64): Unit
foreign func qGraphicsViewResetTransform(ptr: Int64): Unit

foreign func qGraphicsViewSetInteractive(ptr: Int64, interactive: Bool): Unit
foreign func qGraphicsViewIsInteractive(ptr: Int64): Bool

foreign func qGraphicsViewSetSceneRect(ptr: Int64, x: Float64, y: Float64, w: Float64, h: Float64): Unit
foreign func qGraphicsViewSetBackgroundBrush(ptr: Int64, r: Int32, g: Int32, b: Int32): Unit
foreign func qGraphicsViewSetForegroundBrush(ptr: Int64, r: Int32, g: Int32, b: Int32): Unit

foreign func qGraphicsViewMapToScene(ptr: Int64, x: Float64, y: Float64): CString

// ============================================================
// FFI 声明 - QGraphicsScene
// ============================================================

foreign func qGraphicsSceneCreate(): Int64
foreign func qGraphicsSceneDelete(ptr: Int64): Unit

foreign func qGraphicsSceneAddItem(ptr: Int64, itemPtr: Int64): Unit
foreign func qGraphicsSceneRemoveItem(ptr: Int64, itemPtr: Int64): Unit
foreign func qGraphicsSceneClear(ptr: Int64): Unit
foreign func qGraphicsSceneItems(ptr: Int64): CString
foreign func qGraphicsSceneItemAt(ptr: Int64, x: Float64, y: Float64): Int64

foreign func qGraphicsSceneAddRect(ptr: Int64, x: Float64, y: Float64, w: Float64, h: Float64,
                                   penR: Int32, penG: Int32, penB: Int32, penW: Float64,
                                   brushR: Int32, brushG: Int32, brushB: Int32): Int64
foreign func qGraphicsSceneAddEllipse(ptr: Int64, x: Float64, y: Float64, w: Float64, h: Float64,
                                      penR: Int32, penG: Int32, penB: Int32, penW: Float64,
                                      brushR: Int32, brushG: Int32, brushB: Int32): Int64
foreign func qGraphicsSceneAddLine(ptr: Int64, x1: Float64, y1: Float64, x2: Float64, y2: Float64,
                                   penR: Int32, penG: Int32, penB: Int32, penW: Float64): Int64
foreign func qGraphicsSceneAddText(ptr: Int64, text: CString): Int64

foreign func qGraphicsSceneSetSceneRect(ptr: Int64, x: Float64, y: Float64, w: Float64, h: Float64): Unit
foreign func qGraphicsSceneSceneRect(ptr: Int64): CString
foreign func qGraphicsSceneUpdate(ptr: Int64): Unit
foreign func qGraphicsSceneSetBackgroundBrush(ptr: Int64, r: Int32, g: Int32, b: Int32): Unit
foreign func qGraphicsSceneAddWidget(ptr: Int64, widgetPtr: Int64): Int64

// ============================================================
// FFI 声明 - QGraphicsItem
// ============================================================

foreign func qGraphicsItemSetPos(ptr: Int64, x: Float64, y: Float64): Unit
foreign func qGraphicsItemPos(ptr: Int64): CString
foreign func qGraphicsItemSetZValue(ptr: Int64, z: Float64): Unit
foreign func qGraphicsItemSetRotation(ptr: Int64, angle: Float64): Unit
foreign func qGraphicsItemSetVisible(ptr: Int64, visible: Bool): Unit
foreign func qGraphicsItemIsVisible(ptr: Int64): Bool
foreign func qGraphicsItemSetSelected(ptr: Int64, selected: Bool): Unit
foreign func qGraphicsItemIsSelected(ptr: Int64): Bool
foreign func qGraphicsItemUpdate(ptr: Int64): Unit

// ============================================================
// 常量定义
// ============================================================

/// QGraphicsView::ViewportAnchor
public class GraphicsViewAnchor {
    public static let NoAnchor: Int32 = 0
    public static let AnchorViewCenter: Int32 = 1
    public static let AnchorUnderMouse: Int32 = 2
}

/// QGraphicsView::DragMode
public class GraphicsViewDragMode {
    public static let NoDrag: Int32 = 0
    public static let ScrollHandDrag: Int32 = 1
    public static let RubberBandDrag: Int32 = 2
}

/// QPainter::RenderHint
public class GraphicsViewRenderHint {
    public static let Antialiasing: Int32 = 0x01
    public static let TextAntialiasing: Int32 = 0x02
    public static let SmoothPixmapTransform: Int32 = 0x10
    public static let LosslessImageRendering: Int32 = 0x40
}

/// QGraphicsView::ViewportUpdateMode
public class GraphicsViewViewportUpdateMode {
    public static let FullViewportUpdate: Int32 = 0
    public static let MinViewportUpdate: Int32 = 1
    public static let SmartViewportUpdate: Int32 = 2
    public static let BoundingRectViewportUpdate: Int32 = 3
    public static let NoViewportUpdate: Int32 = 4
}

// ============================================================
// QGraphicsView - 图形视图部件
// ============================================================

public class QGraphicsView <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    public init(parent!: Int64 = 0) {
        unsafe {
            ptr = qGraphicsViewCreate(parent)
            if (ptr == 0) {
                throw CreateFailedException("QGraphicsView 创建失败")
            }
        }
        trackObject(ptr)
    }

    public func show(): Unit {
        checkValid()
        unsafe {
            qWidgetShow(ptr)
        }
    }

    public func hide(): Unit {
        checkValid()
        unsafe {
            qWidgetHide(ptr)
        }
    }

    public func resize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }

    public func setScene(scene: QGraphicsScene): Unit {
        checkValid()
        unsafe {
            qGraphicsViewSetScene(ptr, scene.getPtr())
        }
    }

    public func scene(): Int64 {
        checkValid()
        unsafe {
            return qGraphicsViewScene(ptr)
        }
    }

    public func setRenderHint(hint: Int32, enabled!: Bool): Unit {
        checkValid()
        unsafe {
            qGraphicsViewSetRenderHint(ptr, hint, enabled)
        }
    }

    public func setRenderHints(hints: Int32): Unit {
        checkValid()
        unsafe {
            qGraphicsViewSetRenderHints(ptr, hints)
        }
    }

    public func setDragMode(mode: Int32): Unit {
        checkValid()
        unsafe {
            qGraphicsViewSetDragMode(ptr, mode)
        }
    }

    public func dragMode(): Int32 {
        checkValid()
        unsafe {
            return qGraphicsViewDragMode(ptr)
        }
    }

    public func setViewportUpdateMode(mode: Int32): Unit {
        checkValid()
        unsafe {
            qGraphicsViewSetViewportUpdateMode(ptr, mode)
        }
    }

    public func centerOn(x: Float64, y: Float64): Unit {
        checkValid()
        unsafe {
            qGraphicsViewCenterOn(ptr, x, y)
        }
    }

    public func fitInView(x: Float64, y: Float64, w: Float64, h: Float64): Unit {
        checkValid()
        unsafe {
            qGraphicsViewFitInView(ptr, x, y, w, h)
        }
    }

    public func scale(fx: Float64, fy: Float64): Unit {
        checkValid()
        unsafe {
            qGraphicsViewScale(ptr, fx, fy)
        }
    }

    public func rotate(angle: Float64): Unit {
        checkValid()
        unsafe {
            qGraphicsViewRotate(ptr, angle)
        }
    }

    public func translate(dx: Float64, dy: Float64): Unit {
        checkValid()
        unsafe {
            qGraphicsViewTranslate(ptr, dx, dy)
        }
    }

    public func resetTransform(): Unit {
        checkValid()
        unsafe {
            qGraphicsViewResetTransform(ptr)
        }
    }

    public func setInteractive(interactive: Bool): Unit {
        checkValid()
        unsafe {
            qGraphicsViewSetInteractive(ptr, interactive)
        }
    }

    public func isInteractive(): Bool {
        checkValid()
        unsafe {
            return qGraphicsViewIsInteractive(ptr)
        }
    }

    public func setSceneRect(x: Float64, y: Float64, w: Float64, h: Float64): Unit {
        checkValid()
        unsafe {
            qGraphicsViewSetSceneRect(ptr, x, y, w, h)
        }
    }

    public func setBackgroundBrush(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe {
            qGraphicsViewSetBackgroundBrush(ptr, r, g, b)
        }
    }

    public func setForegroundBrush(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe {
            qGraphicsViewSetForegroundBrush(ptr, r, g, b)
        }
    }

    public func mapToScene(x: Float64, y: Float64): String {
        checkValid()
        unsafe {
            let cstr = qGraphicsViewMapToScene(ptr, x, y)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
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

    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QGraphicsView 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QGraphicsView 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QGraphicsView 底层 Qt 对象已失效")
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
            unsafe {
                qSignalCleanup(ptr)
                qGraphicsViewDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }

    public func delete(): Unit {
        close()
    }
}

// ============================================================
// QGraphicsScene - 图形场景
// ============================================================

public class QGraphicsScene <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    public init() {
        unsafe {
            ptr = qGraphicsSceneCreate()
            if (ptr == 0) {
                throw CreateFailedException("QGraphicsScene 创建失败")
            }
        }
        trackObject(ptr)
    }

    public func addRect(x: Float64, y: Float64, w: Float64, h: Float64,
                        penR: Int32, penG: Int32, penB: Int32, penW: Float64,
                        brushR: Int32, brushG: Int32, brushB: Int32): Int64 {
        checkValid()
        unsafe {
            return qGraphicsSceneAddRect(ptr, x, y, w, h, penR, penG, penB, penW, brushR, brushG, brushB)
        }
    }

    public func addEllipse(x: Float64, y: Float64, w: Float64, h: Float64,
                           penR: Int32, penG: Int32, penB: Int32, penW: Float64,
                           brushR: Int32, brushG: Int32, brushB: Int32): Int64 {
        checkValid()
        unsafe {
            return qGraphicsSceneAddEllipse(ptr, x, y, w, h, penR, penG, penB, penW, brushR, brushG, brushB)
        }
    }

    public func addLine(x1: Float64, y1: Float64, x2: Float64, y2: Float64,
                        penR: Int32, penG: Int32, penB: Int32, penW: Float64): Int64 {
        checkValid()
        unsafe {
            return qGraphicsSceneAddLine(ptr, x1, y1, x2, y2, penR, penG, penB, penW)
        }
    }

    public func addText(text: String): Int64 {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            let result = qGraphicsSceneAddText(ptr, cstr)
            LibC.free(cstr)
            return result
        }
    }

    public func addItem(itemPtr: Int64): Unit {
        checkValid()
        unsafe {
            qGraphicsSceneAddItem(ptr, itemPtr)
        }
    }

    public func removeItem(itemPtr: Int64): Unit {
        checkValid()
        unsafe {
            qGraphicsSceneRemoveItem(ptr, itemPtr)
        }
    }

    public func clear(): Unit {
        checkValid()
        unsafe {
            qGraphicsSceneClear(ptr)
        }
    }

    public func items(): String {
        checkValid()
        unsafe {
            let cstr = qGraphicsSceneItems(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    public func itemAt(x: Float64, y: Float64): Int64 {
        checkValid()
        unsafe {
            return qGraphicsSceneItemAt(ptr, x, y)
        }
    }

    public func setSceneRect(x: Float64, y: Float64, w: Float64, h: Float64): Unit {
        checkValid()
        unsafe {
            qGraphicsSceneSetSceneRect(ptr, x, y, w, h)
        }
    }

    public func sceneRect(): String {
        checkValid()
        unsafe {
            let cstr = qGraphicsSceneSceneRect(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    public func update(): Unit {
        checkValid()
        unsafe {
            qGraphicsSceneUpdate(ptr)
        }
    }

    public func setBackgroundBrush(r: Int32, g: Int32, b: Int32): Unit {
        checkValid()
        unsafe {
            qGraphicsSceneSetBackgroundBrush(ptr, r, g, b)
        }
    }

    public func addWidget(widgetPtr: Int64): Int64 {
        checkValid()
        unsafe {
            return qGraphicsSceneAddWidget(ptr, widgetPtr)
        }
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

    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QGraphicsScene 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QGraphicsScene 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QGraphicsScene 底层 Qt 对象已失效")
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
            unsafe {
                qSignalCleanup(ptr)
                qGraphicsSceneDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }

    public func delete(): Unit {
        close()
    }
}

// ============================================================
// QGraphicsItem 工具函数
// ============================================================

public func graphicsItemSetPos(itemPtr: Int64, x: Float64, y: Float64): Unit {
    unsafe { qGraphicsItemSetPos(itemPtr, x, y) }
}

public func graphicsItemPos(itemPtr: Int64): String {
    unsafe {
        let cstr = qGraphicsItemPos(itemPtr)
        let result = cstr.toString()
        freeBridgeString(cstr)
        return result
    }
}

public func graphicsItemSetZValue(itemPtr: Int64, z: Float64): Unit {
    unsafe { qGraphicsItemSetZValue(itemPtr, z) }
}

public func graphicsItemSetRotation(itemPtr: Int64, angle: Float64): Unit {
    unsafe { qGraphicsItemSetRotation(itemPtr, angle) }
}

public func graphicsItemSetVisible(itemPtr: Int64, visible: Bool): Unit {
    unsafe { qGraphicsItemSetVisible(itemPtr, visible) }
}

public func graphicsItemIsVisible(itemPtr: Int64): Bool {
    unsafe { return qGraphicsItemIsVisible(itemPtr) }
}

public func graphicsItemSetSelected(itemPtr: Int64, selected: Bool): Unit {
    unsafe { qGraphicsItemSetSelected(itemPtr, selected) }
}

public func graphicsItemIsSelected(itemPtr: Int64): Bool {
    unsafe { return qGraphicsItemIsSelected(itemPtr) }
}

public func graphicsItemUpdate(itemPtr: Int64): Unit {
    unsafe { qGraphicsItemUpdate(itemPtr) }
}
