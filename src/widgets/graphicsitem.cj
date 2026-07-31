package cjqt6.widgets

import cjqt6.core.*

// ============================================================
// QGraphicsItem 子类体系 FFI 声明
// 注意：qGraphicsItemSetPos/Pos/SetZValue/SetRotation/SetVisible/IsVisible/SetSelected/IsSelected/Update
// 已在 graphicsview.cj 中声明，此处只声明新增函数。
// ============================================================

// QGraphicsItem 通用扩展
foreign func qGraphicsItemPosX(ptr: Int64): Float64
foreign func qGraphicsItemPosY(ptr: Int64): Float64
foreign func qGraphicsItemZValue(ptr: Int64): Float64
foreign func qGraphicsItemRotation(ptr: Int64): Float64
foreign func qGraphicsItemSetScale(ptr: Int64, scale: Float64): Unit
foreign func qGraphicsItemScale(ptr: Int64): Float64
foreign func qGraphicsItemSetEnabled(ptr: Int64, enabled: Bool): Unit
foreign func qGraphicsItemIsEnabled(ptr: Int64): Bool
foreign func qGraphicsItemSetOpacity(ptr: Int64, opacity: Float64): Unit
foreign func qGraphicsItemOpacity(ptr: Int64): Float64
foreign func qGraphicsItemSceneBoundingRectX(ptr: Int64): Float64
foreign func qGraphicsItemSceneBoundingRectY(ptr: Int64): Float64
foreign func qGraphicsItemSceneBoundingRectW(ptr: Int64): Float64
foreign func qGraphicsItemSceneBoundingRectH(ptr: Int64): Float64
foreign func qGraphicsItemScene(ptr: Int64): Int64
foreign func qGraphicsItemSetParentItem(ptr: Int64, parentPtr: Int64): Unit
foreign func qGraphicsItemSetToolTip(ptr: Int64, tip: CString): Unit
foreign func qGraphicsItemSetCursor(ptr: Int64, shape: Int32): Unit
foreign func qGraphicsItemType(ptr: Int64): Int32

// QGraphicsRectItem
foreign func qGraphicsRectItemCreate(): Int64
foreign func qGraphicsRectItemCreateXYWH(x: Float64, y: Float64, w: Float64, h: Float64): Int64
foreign func qGraphicsRectItemDelete(ptr: Int64): Unit
foreign func qGraphicsRectItemSetRect(ptr: Int64, x: Float64, y: Float64, w: Float64, h: Float64): Unit
foreign func qGraphicsRectItemRect(ptr: Int64): CString
foreign func qGraphicsRectItemSetPen(ptr: Int64, colorR: Int32, colorG: Int32, colorB: Int32, width: Int32): Unit
foreign func qGraphicsRectItemSetBrush(ptr: Int64, colorR: Int32, colorG: Int32, colorB: Int32): Unit

// QGraphicsEllipseItem
foreign func qGraphicsEllipseItemCreate(): Int64
foreign func qGraphicsEllipseItemCreateXYWH(x: Float64, y: Float64, w: Float64, h: Float64): Int64
foreign func qGraphicsEllipseItemDelete(ptr: Int64): Unit
foreign func qGraphicsEllipseItemSetRect(ptr: Int64, x: Float64, y: Float64, w: Float64, h: Float64): Unit
foreign func qGraphicsEllipseItemRect(ptr: Int64): CString
foreign func qGraphicsEllipseItemSetStartAngle(ptr: Int64, angle: Int32): Unit
foreign func qGraphicsEllipseItemSetSpanAngle(ptr: Int64, angle: Int32): Unit
foreign func qGraphicsEllipseItemSetPen(ptr: Int64, colorR: Int32, colorG: Int32, colorB: Int32, width: Int32): Unit
foreign func qGraphicsEllipseItemSetBrush(ptr: Int64, colorR: Int32, colorG: Int32, colorB: Int32): Unit

// QGraphicsLineItem
foreign func qGraphicsLineItemCreate(): Int64
foreign func qGraphicsLineItemCreateLine(x1: Float64, y1: Float64, x2: Float64, y2: Float64): Int64
foreign func qGraphicsLineItemDelete(ptr: Int64): Unit
foreign func qGraphicsLineItemSetLine(ptr: Int64, x1: Float64, y1: Float64, x2: Float64, y2: Float64): Unit
foreign func qGraphicsLineItemLine(ptr: Int64): CString
foreign func qGraphicsLineItemSetPen(ptr: Int64, colorR: Int32, colorG: Int32, colorB: Int32, width: Int32): Unit

// QGraphicsTextItem
foreign func qGraphicsTextItemCreate(): Int64
foreign func qGraphicsTextItemCreateText(text: CString): Int64
foreign func qGraphicsTextItemDelete(ptr: Int64): Unit
foreign func qGraphicsTextItemSetText(ptr: Int64, text: CString): Unit
foreign func qGraphicsTextItemText(ptr: Int64): CString
foreign func qGraphicsTextItemSetHtml(ptr: Int64, html: CString): Unit
foreign func qGraphicsTextItemSetFont(ptr: Int64, family: CString, pointSize: Float64, bold: Bool): Unit
foreign func qGraphicsTextItemSetTextWidth(ptr: Int64, width: Float64): Unit
foreign func qGraphicsTextItemSetDefaultTextColor(ptr: Int64, colorR: Int32, colorG: Int32, colorB: Int32): Unit

// QGraphicsPixmapItem
foreign func qGraphicsPixmapItemCreate(): Int64
foreign func qGraphicsPixmapItemCreatePixmap(pixmapPtr: Int64): Int64
foreign func qGraphicsPixmapItemDelete(ptr: Int64): Unit
foreign func qGraphicsPixmapItemSetPixmap(ptr: Int64, pixmapPtr: Int64): Unit
foreign func qGraphicsPixmapItemSetOffset(ptr: Int64, x: Float64, y: Float64): Unit

// QGraphicsPathItem
foreign func qGraphicsPathItemCreate(): Int64
foreign func qGraphicsPathItemDelete(ptr: Int64): Unit
foreign func qGraphicsPathItemSetPen(ptr: Int64, colorR: Int32, colorG: Int32, colorB: Int32, width: Int32): Unit
foreign func qGraphicsPathItemSetBrush(ptr: Int64, colorR: Int32, colorG: Int32, colorB: Int32): Unit

// QGraphicsItemGroup
foreign func qGraphicsItemGroupCreate(): Int64
foreign func qGraphicsItemGroupDelete(ptr: Int64): Unit
foreign func qGraphicsItemGroupAddToGroup(ptr: Int64, itemPtr: Int64): Unit
foreign func qGraphicsItemGroupRemoveFromGroup(ptr: Int64, itemPtr: Int64): Unit

// ============================================================
// QGraphicsItem - 图形项基类
// ============================================================
// QGraphicsItem - 图形项基类
// ============================================================

/// 图形项基类，提供位置、旋转、缩放、可见性、透明度等通用属性（其他图形项继承自此类）
public open class QGraphicsItem {
    protected var ptr: Int64 = 0
    protected var closed: Bool = false

    protected func checkValid(): Unit {
        if (ptr == 0 || closed) {
            throw ResourceDisposedException("QGraphicsItem already deleted")
        }
    }

    /// 由子类传入底层指针创建
    public init(ptr: Int64) {
        this.ptr = ptr
    }

    /// 设置位置（场景坐标）
    public func setPos(x: Float64, y: Float64): Unit { checkValid(); unsafe { qGraphicsItemSetPos(ptr, x, y) } }
    /// 获取位置（返回 "x,y" 字符串）
    public func pos(): String { checkValid(); unsafe { qGraphicsItemPos(ptr).toString() } }
    /// 获取 X 坐标
    public func posX(): Float64 { checkValid(); unsafe { qGraphicsItemPosX(ptr) } }
    /// 获取 Y 坐标
    public func posY(): Float64 { checkValid(); unsafe { qGraphicsItemPosY(ptr) } }
    /// 设置 Z 值（控制层叠顺序，大者在上）
    public func setZValue(z: Float64): Unit { checkValid(); unsafe { qGraphicsItemSetZValue(ptr, z) } }
    /// 获取 Z 值
    public func zValue(): Float64 { checkValid(); unsafe { qGraphicsItemZValue(ptr) } }
    /// 设置旋转角度（度）
    public func setRotation(angle: Float64): Unit { checkValid(); unsafe { qGraphicsItemSetRotation(ptr, angle) } }
    /// 获取旋转角度
    public func rotation(): Float64 { checkValid(); unsafe { qGraphicsItemRotation(ptr) } }
    /// 设置缩放比例
    public func setScale(scale: Float64): Unit { checkValid(); unsafe { qGraphicsItemSetScale(ptr, scale) } }
    /// 获取缩放比例
    public func scale(): Float64 { checkValid(); unsafe { qGraphicsItemScale(ptr) } }
    /// 设置是否可见
    public func setVisible(visible: Bool): Unit { checkValid(); unsafe { qGraphicsItemSetVisible(ptr, visible) } }
    /// 是否可见
    public func isVisible(): Bool { checkValid(); unsafe { qGraphicsItemIsVisible(ptr) } }
    /// 设置是否启用（禁用后不响应交互）
    public func setEnabled(enabled: Bool): Unit { checkValid(); unsafe { qGraphicsItemSetEnabled(ptr, enabled) } }
    /// 是否启用
    public func isEnabled(): Bool { checkValid(); unsafe { qGraphicsItemIsEnabled(ptr) } }
    /// 设置是否选中
    public func setSelected(selected: Bool): Unit { checkValid(); unsafe { qGraphicsItemSetSelected(ptr, selected) } }
    /// 是否选中
    public func isSelected(): Bool { checkValid(); unsafe { qGraphicsItemIsSelected(ptr) } }
    /// 设置不透明度（0.0-1.0）
    public func setOpacity(opacity: Float64): Unit { checkValid(); unsafe { qGraphicsItemSetOpacity(ptr, opacity) } }
    /// 获取不透明度
    public func opacity(): Float64 { checkValid(); unsafe { qGraphicsItemOpacity(ptr) } }
    /// 请求重绘
    public func update(): Unit { checkValid(); unsafe { qGraphicsItemUpdate(ptr) } }
    /// 场景包围盒 X
    public func sceneBoundingRectX(): Float64 { checkValid(); unsafe { qGraphicsItemSceneBoundingRectX(ptr) } }
    /// 场景包围盒 Y
    public func sceneBoundingRectY(): Float64 { checkValid(); unsafe { qGraphicsItemSceneBoundingRectY(ptr) } }
    /// 场景包围盒宽度
    public func sceneBoundingRectW(): Float64 { checkValid(); unsafe { qGraphicsItemSceneBoundingRectW(ptr) } }
    /// 场景包围盒高度
    public func sceneBoundingRectH(): Float64 { checkValid(); unsafe { qGraphicsItemSceneBoundingRectH(ptr) } }
    /// 获取所属场景指针
    public func scene(): Int64 { checkValid(); unsafe { qGraphicsItemScene(ptr) } }
    /// 设置父图形项
    public func setParentItem(parentPtr: Int64): Unit { checkValid(); unsafe { qGraphicsItemSetParentItem(ptr, parentPtr) } }

    /// 设置悬浮提示文本
    public func setToolTip(tip: String): Unit {
        checkValid()
        unsafe { let c = LibC.mallocCString(tip); qGraphicsItemSetToolTip(ptr, c); LibC.free(c) }
    }

    /// 设置悬停光标形状（CursorShape 常量）
    public func setCursor(shape: Int32): Unit { checkValid(); unsafe { qGraphicsItemSetCursor(ptr, shape) } }
    /// 获取图形项类型（子类各自覆盖）
    public func itemType(): Int32 { checkValid(); unsafe { qGraphicsItemType(ptr) } }

    /// 获取底层指针
    public func getPtr(): Int64 { ptr }
}

// ============================================================
// QGraphicsRectItem - 矩形图形项
// ============================================================

/// 矩形图形项，可设置矩形范围、边框画笔和填充画刷
public class QGraphicsRectItem <: QGraphicsItem {
    /// 创建空矩形图形项
    public init() {
        super(unsafe { qGraphicsRectItemCreate() })
    }

    /// 创建指定位置和大小的矩形图形项
    public init(x: Float64, y: Float64, w: Float64, h: Float64) {
        super(unsafe { qGraphicsRectItemCreateXYWH(x, y, w, h) })
    }

    /// 设置矩形范围
    public func setRect(x: Float64, y: Float64, w: Float64, h: Float64): Unit {
        checkValid(); unsafe { qGraphicsRectItemSetRect(ptr, x, y, w, h) }
    }

    /// 获取矩形范围（返回 "x,y,w,h" 字符串）
    public func rect(): String { checkValid(); unsafe { qGraphicsRectItemRect(ptr).toString() } }

    /// 设置边框画笔（颜色 RGB + 线宽）
    public func setPen(colorR: Int32, colorG: Int32, colorB: Int32, width: Int32): Unit {
        checkValid(); unsafe { qGraphicsRectItemSetPen(ptr, colorR, colorG, colorB, width) }
    }

    /// 设置填充画刷（颜色 RGB）
    public func setBrush(colorR: Int32, colorG: Int32, colorB: Int32): Unit {
        checkValid(); unsafe { qGraphicsRectItemSetBrush(ptr, colorR, colorG, colorB) }
    }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) { unsafe { qGraphicsRectItemDelete(ptr) }; ptr = 0; closed = true }
    }
}

// ============================================================
// QGraphicsEllipseItem - 椭圆图形项
// ============================================================

/// 椭圆图形项，可设置外接矩形范围及扇形起始角/跨度角
public class QGraphicsEllipseItem <: QGraphicsItem {
    /// 创建空椭圆图形项
    public init() {
        super(unsafe { qGraphicsEllipseItemCreate() })
    }

    /// 创建指定外接矩形位置的椭圆图形项
    public init(x: Float64, y: Float64, w: Float64, h: Float64) {
        super(unsafe { qGraphicsEllipseItemCreateXYWH(x, y, w, h) })
    }

    /// 设置外接矩形范围
    public func setRect(x: Float64, y: Float64, w: Float64, h: Float64): Unit {
        checkValid(); unsafe { qGraphicsEllipseItemSetRect(ptr, x, y, w, h) }
    }

    /// 获取外接矩形范围（返回 "x,y,w,h" 字符串）
    public func rect(): String { checkValid(); unsafe { qGraphicsEllipseItemRect(ptr).toString() } }

    /// 设置扇形起始角（度，0 为三点钟方向）
    public func setStartAngle(angle: Int32): Unit { checkValid(); unsafe { qGraphicsEllipseItemSetStartAngle(ptr, angle) } }
    /// 设置扇形跨度角（度，正值顺时针）
    public func setSpanAngle(angle: Int32): Unit { checkValid(); unsafe { qGraphicsEllipseItemSetSpanAngle(ptr, angle) } }

    /// 设置边框画笔（颜色 RGB + 线宽）
    public func setPen(colorR: Int32, colorG: Int32, colorB: Int32, width: Int32): Unit {
        checkValid(); unsafe { qGraphicsEllipseItemSetPen(ptr, colorR, colorG, colorB, width) }
    }

    /// 设置填充画刷（颜色 RGB）
    public func setBrush(colorR: Int32, colorG: Int32, colorB: Int32): Unit {
        checkValid(); unsafe { qGraphicsEllipseItemSetBrush(ptr, colorR, colorG, colorB) }
    }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) { unsafe { qGraphicsEllipseItemDelete(ptr) }; ptr = 0; closed = true }
    }
}

// ============================================================
// QGraphicsLineItem - 线段图形项
// ============================================================

/// 线段图形项，通过两个端点定义直线
public class QGraphicsLineItem <: QGraphicsItem {
    /// 创建空线段图形项
    public init() {
        super(unsafe { qGraphicsLineItemCreate() })
    }

    /// 创建指定端点的线段图形项
    public init(x1: Float64, y1: Float64, x2: Float64, y2: Float64) {
        super(unsafe { qGraphicsLineItemCreateLine(x1, y1, x2, y2) })
    }

    /// 设置线段端点
    public func setLine(x1: Float64, y1: Float64, x2: Float64, y2: Float64): Unit {
        checkValid(); unsafe { qGraphicsLineItemSetLine(ptr, x1, y1, x2, y2) }
    }

    /// 获取线段端点（返回 "x1,y1,x2,y2" 字符串）
    public func line(): String { checkValid(); unsafe { qGraphicsLineItemLine(ptr).toString() } }

    /// 设置线段画笔（颜色 RGB + 线宽）
    public func setPen(colorR: Int32, colorG: Int32, colorB: Int32, width: Int32): Unit {
        checkValid(); unsafe { qGraphicsLineItemSetPen(ptr, colorR, colorG, colorB, width) }
    }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) { unsafe { qGraphicsLineItemDelete(ptr) }; ptr = 0; closed = true }
    }
}

// ============================================================
// QGraphicsTextItem - 文本图形项
// ============================================================

/// 文本图形项，可显示纯文本或 HTML 富文本，并设置字体与颜色
public class QGraphicsTextItem <: QGraphicsItem {
    /// 创建空文本图形项
    public init() {
        super(unsafe { qGraphicsTextItemCreate() })
    }

    /// 创建并设置初始文本
    public init(text: String) {
        super(unsafe {
            let c = LibC.mallocCString(text)
            let p = qGraphicsTextItemCreateText(c)
            LibC.free(c)
            p
        })
    }

    /// 设置文本内容
    public func setText(text: String): Unit {
        checkValid()
        unsafe { let c = LibC.mallocCString(text); qGraphicsTextItemSetText(ptr, c); LibC.free(c) }
    }

    /// 获取文本内容
    public func text(): String { checkValid(); unsafe { qGraphicsTextItemText(ptr).toString() } }

    /// 设置 HTML 富文本内容
    public func setHtml(html: String): Unit {
        checkValid()
        unsafe { let c = LibC.mallocCString(html); qGraphicsTextItemSetHtml(ptr, c); LibC.free(c) }
    }

    /// 设置字体（字体族、字号、是否加粗）
    public func setFont(family: String, pointSize: Float64, bold: Bool): Unit {
        checkValid()
        unsafe {
            let c = LibC.mallocCString(family)
            qGraphicsTextItemSetFont(ptr, c, pointSize, bold)
            LibC.free(c)
        }
    }

    /// 设置文本宽度（用于自动换行）
    public func setTextWidth(width: Float64): Unit { checkValid(); unsafe { qGraphicsTextItemSetTextWidth(ptr, width) } }

    /// 设置默认文本颜色（RGB）
    public func setDefaultTextColor(colorR: Int32, colorG: Int32, colorB: Int32): Unit {
        checkValid(); unsafe { qGraphicsTextItemSetDefaultTextColor(ptr, colorR, colorG, colorB) }
    }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) { unsafe { qGraphicsTextItemDelete(ptr) }; ptr = 0; closed = true }
    }
}

// ============================================================
// QGraphicsPixmapItem - 图像图形项
// ============================================================

/// 图像图形项，显示 QPixmap 图像并可设置偏移
public class QGraphicsPixmapItem <: QGraphicsItem {
    /// 创建空图像图形项
    public init() {
        super(unsafe { qGraphicsPixmapItemCreate() })
    }

    /// 创建并设置图像
    public init(pixmapPtr: Int64) {
        super(unsafe { qGraphicsPixmapItemCreatePixmap(pixmapPtr) })
    }

    /// 设置图像（QPixmap 指针）
    public func setPixmap(pixmapPtr: Int64): Unit { checkValid(); unsafe { qGraphicsPixmapItemSetPixmap(ptr, pixmapPtr) } }
    /// 设置图像偏移
    public func setOffset(x: Float64, y: Float64): Unit { checkValid(); unsafe { qGraphicsPixmapItemSetOffset(ptr, x, y) } }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) { unsafe { qGraphicsPixmapItemDelete(ptr) }; ptr = 0; closed = true }
    }
}

// ============================================================
// QGraphicsPathItem - 路径图形项
// ============================================================

/// 路径图形项，绘制任意 QPainterPath 形状
public class QGraphicsPathItem <: QGraphicsItem {
    /// 创建路径图形项
    public init() {
        super(unsafe { qGraphicsPathItemCreate() })
    }

    /// 设置路径画笔（颜色 RGB + 线宽）
    public func setPen(colorR: Int32, colorG: Int32, colorB: Int32, width: Int32): Unit {
        checkValid(); unsafe { qGraphicsPathItemSetPen(ptr, colorR, colorG, colorB, width) }
    }

    /// 设置路径填充画刷（颜色 RGB）
    public func setBrush(colorR: Int32, colorG: Int32, colorB: Int32): Unit {
        checkValid(); unsafe { qGraphicsPathItemSetBrush(ptr, colorR, colorG, colorB) }
    }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) { unsafe { qGraphicsPathItemDelete(ptr) }; ptr = 0; closed = true }
    }
}

// ============================================================
// QGraphicsItemGroup - 图形项组
// ============================================================

/// 图形项组，将多个图形项组合为一个整体（可统一移动、变换）
public class QGraphicsItemGroup <: QGraphicsItem {
    /// 创建图形项组
    public init() {
        super(unsafe { qGraphicsItemGroupCreate() })
    }

    /// 将图形项加入组
    public func addToGroup(itemPtr: Int64): Unit { checkValid(); unsafe { qGraphicsItemGroupAddToGroup(ptr, itemPtr) } }
    /// 将图形项移出组
    public func removeFromGroup(itemPtr: Int64): Unit { checkValid(); unsafe { qGraphicsItemGroupRemoveFromGroup(ptr, itemPtr) } }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) { unsafe { qGraphicsItemGroupDelete(ptr) }; ptr = 0; closed = true }
    }
}
