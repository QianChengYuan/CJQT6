package CJQT6.paint

// ============================================================
// 颜色类
// ============================================================

public class QColor {
    private var ptr: Int64 = 0

    public init() {
        unsafe { ptr = qColorCreate() }
    }

    public init(r: Int32, g: Int32, b: Int32) {
        unsafe { ptr = qColorCreateRgb(r, g, b, 255) }
    }

    // 私有构造函数 - 用于工厂方法
    private init(ptr: Int64) {
        this.ptr = ptr
    }

    public static func rgba(r: Int32, g: Int32, b: Int32, a: Int32): QColor {
        unsafe { QColor(qColorCreateRgb(r, g, b, a)) }
    }

    public static func fromName(name: String): QColor {
        unsafe {
            var cstr = LibC.mallocCString(name)
            let c = QColor(qColorFromName(cstr))
            LibC.free(cstr)
            c
        }
    }

    public func red(): Int32 { unsafe { qColorRed(ptr) } }
    public func green(): Int32 { unsafe { qColorGreen(ptr) } }
    public func blue(): Int32 { unsafe { qColorBlue(ptr) } }
    public func alpha(): Int32 { unsafe { qColorAlpha(ptr) } }

    public func setRed(r: Int32): Unit { unsafe { qColorSetRed(ptr, r) } }
    public func setGreen(g: Int32): Unit { unsafe { qColorSetGreen(ptr, g) } }
    public func setBlue(b: Int32): Unit { unsafe { qColorSetBlue(ptr, b) } }
    public func setAlpha(a: Int32): Unit { unsafe { qColorSetAlpha(ptr, a) } }

    public func getPtr(): Int64 { ptr }
    
    /// 是否有效
    public func isValid(): Bool { ptr != 0 }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qColorDelete(ptr) }
            ptr = 0
        }
    }
    
    /// 终结器 - 最后保障，防止内存泄漏
    ~init() {
        if (ptr != 0) {
            unsafe { qColorDelete(ptr) }
            ptr = 0
        }
    }
}

// 预定义颜色
public class Colors {
    public static func white(): QColor { QColor(255, 255, 255) }
    public static func black(): QColor { QColor(0, 0, 0) }
    public static func red(): QColor { QColor(255, 0, 0) }
    public static func green(): QColor { QColor(0, 255, 0) }
    public static func blue(): QColor { QColor(0, 0, 255) }
    public static func yellow(): QColor { QColor(255, 255, 0) }
    public static func cyan(): QColor { QColor(0, 255, 255) }
    public static func magenta(): QColor { QColor(255, 0, 255) }
    public static func gray(): QColor { QColor(128, 128, 128) }
    public static func lightGray(): QColor { QColor(192, 192, 192) }
    public static func darkGray(): QColor { QColor(64, 64, 64) }
    public static func transparent(): QColor { QColor.rgba(0, 0, 0, 0) }
}

// ============================================================
// 类型安全的枚举定义
// ============================================================

/// 画笔样式
public enum PenStyle {
    | NoPen
    | SolidLine
    | DashLine
    | DotLine
    | DashDotLine
    | DashDotDotLine
    | CustomDashLine
    
    public func value(): Int32 {
        match (this) {
            case NoPen => 0
            case SolidLine => 1
            case DashLine => 2
            case DotLine => 3
            case DashDotLine => 4
            case DashDotDotLine => 5
            case CustomDashLine => 6
        }
    }
    
    public static func fromValue(v: Int32): PenStyle {
        match (v) {
            case 0 => NoPen
            case 1 => SolidLine
            case 2 => DashLine
            case 3 => DotLine
            case 4 => DashDotLine
            case 5 => DashDotDotLine
            case _ => SolidLine
        }
    }
    
    public operator func ==(other: PenStyle): Bool {
        this.value() == other.value()
    }
    
    public operator func !=(other: PenStyle): Bool {
        this.value() != other.value()
    }
}

/// 画刷样式
public enum BrushStyle {
    | NoBrush
    | SolidPattern
    | Dense1Pattern
    | Dense2Pattern
    | Dense3Pattern
    | Dense4Pattern
    | Dense5Pattern
    | Dense6Pattern
    | Dense7Pattern
    | HorPattern
    | VerPattern
    | CrossPattern
    | LinearGradient
    | RadialGradient
    | ConicalGradient
    
    public func value(): Int32 {
        match (this) {
            case NoBrush => 0
            case SolidPattern => 1
            case Dense1Pattern => 2
            case Dense2Pattern => 3
            case Dense3Pattern => 4
            case Dense4Pattern => 5
            case Dense5Pattern => 6
            case Dense6Pattern => 7
            case Dense7Pattern => 8
            case HorPattern => 9
            case VerPattern => 10
            case CrossPattern => 11
            case LinearGradient => 15
            case RadialGradient => 16
            case ConicalGradient => 17
        }
    }
    
    public static func fromValue(v: Int32): BrushStyle {
        match (v) {
            case 0 => NoBrush
            case 1 => SolidPattern
            case 15 => LinearGradient
            case 16 => RadialGradient
            case 17 => ConicalGradient
            case _ => SolidPattern
        }
    }
    
    public operator func ==(other: BrushStyle): Bool {
        this.value() == other.value()
    }
    
    public operator func !=(other: BrushStyle): Bool {
        this.value() != other.value()
    }
}

/// 渲染提示标志（可组合）
public enum RenderHint {
    | Antialiasing
    | TextAntialiasing
    | SmoothPixmapTransform
    | HighQualityAntialiasing
    | NonCosmeticDefaultPen
    
    public func value(): Int32 {
        match (this) {
            case Antialiasing => 0x01
            case TextAntialiasing => 0x02
            case SmoothPixmapTransform => 0x04
            case HighQualityAntialiasing => 0x08
            case NonCosmeticDefaultPen => 0x10
        }
    }
    
    public operator func ==(other: RenderHint): Bool {
        this.value() == other.value()
    }
    
    public operator func !=(other: RenderHint): Bool {
        this.value() != other.value()
    }
}

/// 文本对齐标志（可组合）
public struct TextAlignment {
    public let value: Int32
    
    public init(v: Int32) { value = v }
    
    // 水平对齐
    public static let Left: TextAlignment = TextAlignment(0x0001)
    public static let Right: TextAlignment = TextAlignment(0x0002)
    public static let HCenter: TextAlignment = TextAlignment(0x0004)
    
    // 垂直对齐
    public static let Top: TextAlignment = TextAlignment(0x0020)
    public static let Bottom: TextAlignment = TextAlignment(0x0040)
    public static let VCenter: TextAlignment = TextAlignment(0x0080)
    
    // 组合对齐
    public static let Center: TextAlignment = TextAlignment(0x0084)  // HCenter | VCenter
    public static let Default: TextAlignment = TextAlignment(0x0081) // Left | VCenter
    
    public operator func |(other: TextAlignment): TextAlignment {
        TextAlignment(value | other.value)
    }
}

/// 图像格式
public enum ImageFormat {
    | Invalid
    | Mono
    | MonoLSB
    | Indexed8
    | RGB32
    | ARGB32
    | ARGB32_Premultiplied
    | RGB16
    | RGB888
    | RGBA8888
    
    public func value(): Int32 {
        match (this) {
            case Invalid => 0
            case Mono => 1
            case MonoLSB => 2
            case Indexed8 => 3
            case RGB32 => 4
            case ARGB32 => 5
            case ARGB32_Premultiplied => 6
            case RGB16 => 7
            case RGB888 => 8
            case RGBA8888 => 9
        }
    }
    
    public static func fromValue(v: Int32): ImageFormat {
        match (v) {
            case 0 => Invalid
            case 1 => Mono
            case 2 => MonoLSB
            case 3 => Indexed8
            case 4 => RGB32
            case 5 => ARGB32
            case 6 => ARGB32_Premultiplied
            case 7 => RGB16
            case 8 => RGB888
            case 9 => RGBA8888
            case _ => Invalid
        }
    }
    
    public operator func ==(other: ImageFormat): Bool {
        this.value() == other.value()
    }
    
    public operator func !=(other: ImageFormat): Bool {
        this.value() != other.value()
    }
}

// ============================================================
// 画笔类
// ============================================================

public class QPen {
    private var ptr: Int64 = 0

    public init() {
        unsafe { ptr = qPenCreate() }
    }

    public init(color: QColor) {
        unsafe { ptr = qPenCreateColor(color.getPtr()) }
    }

    public func setColor(c: QColor): QPen { unsafe { qPenSetColor(ptr, c.getPtr()) }; this }
    public func setWidth(w: Int32): QPen { unsafe { qPenSetWidth(ptr, w) }; this }
    public func width(): Int32 { unsafe { qPenWidth(ptr) } }
    /// 设置样式（整数值，兼容旧API）
    public func setStyle(s: Int32): QPen { unsafe { qPenSetStyle(ptr, s) }; this }
    /// 设置样式（类型安全枚举）
    public func setPenStyle(s: PenStyle): QPen { unsafe { qPenSetStyle(ptr, s.value()) }; this }
    public func getPtr(): Int64 { ptr }
    public func isValid(): Bool { ptr != 0 }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qPenDelete(ptr) }
            ptr = 0
        }
    }
    
    /// 终结器 - 最后保障
    ~init() {
        if (ptr != 0) {
            unsafe { qPenDelete(ptr) }
            ptr = 0
        }
    }
}

// ============================================================
// 画刷类
// ============================================================

public class QBrush {
    private var ptr: Int64 = 0

    public init() {
        unsafe { ptr = qBrushCreate() }
    }

    public init(color: QColor) {
        unsafe { ptr = qBrushCreateColor(color.getPtr()) }
    }

    public init(gradient: QLinearGradient) {
        unsafe { ptr = qBrushCreateGradient(gradient.getPtr()) }
    }

    public func setColor(c: QColor): QBrush { unsafe { qBrushSetColor(ptr, c.getPtr()) }; this }
    /// 设置样式（整数值，兼容旧API）
    public func setStyle(s: Int32): QBrush { unsafe { qBrushSetStyle(ptr, s) }; this }
    /// 设置样式（类型安全枚举）
    public func setBrushStyle(s: BrushStyle): QBrush { unsafe { qBrushSetStyle(ptr, s.value()) }; this }
    public func getPtr(): Int64 { ptr }
    public func isValid(): Bool { ptr != 0 }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qBrushDelete(ptr) }
            ptr = 0
        }
    }
    
    /// 终结器 - 最后保障
    ~init() {
        if (ptr != 0) {
            unsafe { qBrushDelete(ptr) }
            ptr = 0
        }
    }
}

// ============================================================
// 渐变类
// ============================================================

public class QLinearGradient {
    private var ptr: Int64 = 0

    public init(x1: Float32, y1: Float32, x2: Float32, y2: Float32) {
        unsafe { ptr = qLinearGradientCreate(x1, y1, x2, y2) }
    }

    public static func fromInt(x1: Int32, y1: Int32, x2: Int32, y2: Int32): QLinearGradient {
        QLinearGradient(Float32(x1), Float32(y1), Float32(x2), Float32(y2))
    }

    public func setColorAt(pos: Float32, c: QColor): QLinearGradient {
        unsafe { qGradientSetColorAt(ptr, pos, c.getPtr()) }; this
    }
    public func getPtr(): Int64 { ptr }
    public func isValid(): Bool { ptr != 0 }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qLinearGradientDelete(ptr) }
            ptr = 0
        }
    }
    
    ~init() {
        if (ptr != 0) {
            unsafe { qLinearGradientDelete(ptr) }
            ptr = 0
        }
    }
}

/// 径向渐变
public class QRadialGradient {
    private var ptr: Int64 = 0

    /// 创建径向渐变
    /// cx, cy: 圆心坐标
    /// radius: 半径
    /// fx, fy: 焦点坐标
    public init(cx: Float32, cy: Float32, radius: Float32, fx: Float32, fy: Float32) {
        unsafe { ptr = qRadialGradientCreate(cx, cy, radius, fx, fy) }
    }

    public static func fromInt(cx: Int32, cy: Int32, radius: Int32, fx: Int32, fy: Int32): QRadialGradient {
        QRadialGradient(Float32(cx), Float32(cy), Float32(radius), Float32(fx), Float32(fy))
    }

    public func setColorAt(pos: Float32, c: QColor): QRadialGradient {
        unsafe { qGradientSetColorAt(ptr, pos, c.getPtr()) }; this
    }
    public func getPtr(): Int64 { ptr }
    public func isValid(): Bool { ptr != 0 }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qRadialGradientDelete(ptr) }
            ptr = 0
        }
    }
    
    ~init() {
        if (ptr != 0) {
            unsafe { qRadialGradientDelete(ptr) }
            ptr = 0
        }
    }
}

/// 锥形渐变
public class QConicalGradient {
    private var ptr: Int64 = 0

    /// 创建锥形渐变
    /// cx, cy: 中心坐标
    /// angle: 起始角度(度)
    public init(cx: Float32, cy: Float32, angle: Float32) {
        unsafe { ptr = qConicalGradientCreate(cx, cy, angle) }
    }

    public static func fromInt(cx: Int32, cy: Int32, angle: Int32): QConicalGradient {
        QConicalGradient(Float32(cx), Float32(cy), Float32(angle))
    }

    public func setColorAt(pos: Float32, c: QColor): QConicalGradient {
        unsafe { qGradientSetColorAt(ptr, pos, c.getPtr()) }; this
    }
    public func getPtr(): Int64 { ptr }
    public func isValid(): Bool { ptr != 0 }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qConicalGradientDelete(ptr) }
            ptr = 0
        }
    }
    
    ~init() {
        if (ptr != 0) {
            unsafe { qConicalGradientDelete(ptr) }
            ptr = 0
        }
    }
}

// ============================================================
// 绘图字体类
// ============================================================

public class QFont {
    private var ptr: Int64 = 0

    public init(family: String) {
        unsafe {
            var cstr = LibC.mallocCString(family)
            ptr = qFontCreate(cstr, 12, 0, 0)
            LibC.free(cstr)
        }
    }

    public init(family: String, pointSize: Int32) {
        unsafe {
            var cstr = LibC.mallocCString(family)
            ptr = qFontCreate(cstr, pointSize, 0, 0)
            LibC.free(cstr)
        }
    }

    public func setPointSize(n: Int32): QFont { unsafe { qFontSetPointSize(ptr, n) }; this }
    public func setBold(b: Bool): QFont { unsafe { qFontSetBold(ptr, if (b) { 1 } else { 0 }) }; this }
    public func setItalic(b: Bool): QFont { unsafe { qFontSetItalic(ptr, if (b) { 1 } else { 0 }) }; this }
    public func getPtr(): Int64 { ptr }
    public func isValid(): Bool { ptr != 0 }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qFontDelete(ptr) }
            ptr = 0
        }
    }
    
    ~init() {
        if (ptr != 0) {
            unsafe { qFontDelete(ptr) }
            ptr = 0
        }
    }
}

// ============================================================
// 绘图路径类
// ============================================================

public class QPainterPath {
    private var ptr: Int64 = 0

    public init() {
        unsafe { ptr = qPainterPathCreate() }
    }

    public func moveTo(x: Float32, y: Float32): QPainterPath {
        unsafe { qPainterPathMoveTo(ptr, x, y) }; this
    }
    public func lineTo(x: Float32, y: Float32): QPainterPath {
        unsafe { qPainterPathLineTo(ptr, x, y) }; this
    }
    public func addRect(x: Float32, y: Float32, w: Float32, h: Float32): QPainterPath {
        unsafe { qPainterPathAddRect(ptr, x, y, w, h) }; this
    }
    public func addEllipse(x: Float32, y: Float32, w: Float32, h: Float32): QPainterPath {
        unsafe { qPainterPathAddEllipse(ptr, x, y, w, h) }; this
    }
    public func closeSubpath(): QPainterPath { unsafe { qPainterPathCloseSubpath(ptr) }; this }
    public func isEmpty(): Bool { unsafe { qPainterPathIsEmpty(ptr) != 0 } }
    public func getPtr(): Int64 { ptr }
    public func isValid(): Bool { ptr != 0 }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qPainterPathDelete(ptr) }
            ptr = 0
        }
    }
    
    ~init() {
        if (ptr != 0) {
            unsafe { qPainterPathDelete(ptr) }
            ptr = 0
        }
    }
}

// ============================================================
// 图像类
// ============================================================

public class QPixmap {
    private var ptr: Int64 = 0

    public init() {
        unsafe { ptr = qPixmapCreate() }
    }

    // 私有构造函数 - 用于工厂方法
    private init(ptr: Int64) {
        this.ptr = ptr
    }

    public static func withSize(w: Int32, h: Int32): QPixmap {
        unsafe { QPixmap(qPixmapCreateSize(w, h)) }
    }

    public static func load(path: String): QPixmap {
        unsafe {
            var cstr = LibC.mallocCString(path)
            let p = QPixmap(qPixmapLoad(cstr))
            LibC.free(cstr)
            p
        }
    }

    public func width(): Int32 { unsafe { qPixmapWidth(ptr) } }
    public func height(): Int32 { unsafe { qPixmapHeight(ptr) } }
    public func isNull(): Bool { unsafe { qPixmapIsNull(ptr) != 0 } }
    public func fill(c: QColor): Unit { unsafe { qPixmapFill(ptr, c.getPtr()) } }
    public func getPtr(): Int64 { ptr }
    public func isValid(): Bool { ptr != 0 }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qPixmapDelete(ptr) }
            ptr = 0
        }
    }
    
    ~init() {
        if (ptr != 0) {
            unsafe { qPixmapDelete(ptr) }
            ptr = 0
        }
    }
}

public class QImage {
    private var ptr: Int64 = 0

    public init() {
        unsafe { ptr = qImageCreate() }
    }

    // 私有构造函数 - 用于工厂方法
    private init(ptr: Int64) {
        this.ptr = ptr
    }

    public static func withSize(w: Int32, h: Int32): QImage {
        unsafe { QImage(qImageCreateSize(w, h, ImageFormat.ARGB32.value())) }
    }

    public func width(): Int32 { unsafe { qImageWidth(ptr) } }
    public func height(): Int32 { unsafe { qImageHeight(ptr) } }
    public func isNull(): Bool { unsafe { qImageIsNull(ptr) != 0 } }
    public func getPtr(): Int64 { ptr }
    public func isValid(): Bool { ptr != 0 }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qImageDelete(ptr) }
            ptr = 0
        }
    }
    
    ~init() {
        if (ptr != 0) {
            unsafe { qImageDelete(ptr) }
            ptr = 0
        }
    }
}

// ============================================================
// 绘图器类
// ============================================================

public class QPainter {
    private var ptr: Int64 = 0
    private var owned: Bool = true  // 是否拥有这个指针（需要释放）
    
    public init() {
        unsafe { ptr = qPainterCreate(0) }
    }
    
    public init(device: Int64) {
        unsafe { ptr = qPainterCreate(device) }
    }
    
    /// 私有构造函数 - 用于 fromPtr 创建
    private init(ptr: Int64, owned: Bool) {
        this.ptr = ptr
        this.owned = owned
    }
    
    /// 从现有指针创建QPainter（不拥有指针，不负责释放）
    /// 用于paintEvent回调中接收现有的QPainter
    public static func fromPtr(ptr: Int64): QPainter {
        QPainter(ptr, false)  // 直接使用私有构造函数，无泄漏
    }
    
    public func begin(device: Int64): Bool { unsafe { qPainterBegin(ptr, device) != 0 } }
    public func end(): Bool { unsafe { qPainterEnd(ptr) != 0 } }
    public func isActive(): Bool { unsafe { qPainterIsActive(ptr) != 0 } }
    
    public func setPen(p: QPen): QPainter { unsafe { qPainterSetPen(ptr, p.getPtr()) }; this }
    public func setPenColor(c: QColor): QPainter { unsafe { qPainterSetPenColor(ptr, c.getPtr()) }; this }
    public func setBrush(b: QBrush): QPainter { unsafe { qPainterSetBrush(ptr, b.getPtr()) }; this }
    public func setFont(f: QFont): QPainter { unsafe { qPainterSetFont(ptr, f.getPtr()) }; this }
    public func setRenderHint(h: Int32): QPainter { unsafe { qPainterSetRenderHint(ptr, h, 1) }; this }
    public func setOpacity(o: Float32): QPainter { unsafe { qPainterSetOpacity(ptr, o) }; this }
    
    public func drawLine(x1: Int32, y1: Int32, x2: Int32, y2: Int32): QPainter { 
        unsafe { qPainterDrawLine(ptr, x1, y1, x2, y2) }; this 
    }
    public func drawRect(x: Int32, y: Int32, w: Int32, h: Int32): QPainter { 
        unsafe { qPainterDrawRect(ptr, x, y, w, h) }; this 
    }
    public func drawEllipse(x: Int32, y: Int32, w: Int32, h: Int32): QPainter { 
        unsafe { qPainterDrawEllipse(ptr, x, y, w, h) }; this 
    }
    public func drawCircle(cx: Int32, cy: Int32, r: Int32): QPainter { 
        unsafe { qPainterDrawEllipseCenter(ptr, cx, cy, r, r) }; this 
    }
    public func drawArc(x: Int32, y: Int32, w: Int32, h: Int32, start: Int32, span: Int32): QPainter {
        unsafe { qPainterDrawArc(ptr, x, y, w, h, start, span) }; this
    }
    public func drawPie(x: Int32, y: Int32, w: Int32, h: Int32, start: Int32, span: Int32): QPainter {
        unsafe { qPainterDrawPie(ptr, x, y, w, h, start, span) }; this
    }
    
    public func drawText(x: Int32, y: Int32, s: String): QPainter {
        unsafe {
            var cstr = LibC.mallocCString(s)
            qPainterDrawText(ptr, x, y, cstr)
            LibC.free(cstr)
        }
        this
    }
    public func drawTextRect(x: Int32, y: Int32, w: Int32, h: Int32, flags: Int32, s: String): QPainter {
        unsafe {
            var cstr = LibC.mallocCString(s)
            qPainterDrawTextRect(ptr, x, y, w, h, flags, cstr)
            LibC.free(cstr)
        }
        this
    }
    
    public func drawPixmap(x: Int32, y: Int32, p: QPixmap): QPainter { 
        unsafe { qPainterDrawPixmap(ptr, x, y, p.getPtr()) }; this 
    }
    public func drawImage(x: Int32, y: Int32, i: QImage): QPainter { 
        unsafe { qPainterDrawImage(ptr, x, y, i.getPtr()) }; this 
    }
    
    public func drawPath(p: QPainterPath): QPainter { unsafe { qPainterDrawPath(ptr, p.getPtr()) }; this }
    public func fillPath(p: QPainterPath, b: QBrush): QPainter { unsafe { qPainterFillPath(ptr, p.getPtr(), b.getPtr()) }; this }
    
    public func fillRect(x: Int32, y: Int32, w: Int32, h: Int32, b: QBrush): QPainter {
        unsafe { qPainterFillRect(ptr, x, y, w, h, b.getPtr()) }; this
    }
    public func fillRectColor(x: Int32, y: Int32, w: Int32, h: Int32, c: QColor): QPainter {
        unsafe { qPainterFillRectColor(ptr, x, y, w, h, c.getPtr()) }; this
    }
    
    public func translate(dx: Float32, dy: Float32): QPainter { unsafe { qPainterTranslate(ptr, dx, dy) }; this }
    public func scale(sx: Float32, sy: Float32): QPainter { unsafe { qPainterScale(ptr, sx, sy) }; this }
    public func rotate(a: Float32): QPainter { unsafe { qPainterRotate(ptr, a) }; this }
    public func save(): QPainter { unsafe { qPainterSave(ptr) }; this }
    public func restore(): QPainter { unsafe { qPainterRestore(ptr) }; this }
    
    public func device(): Int64 { unsafe { qPainterDevice(ptr) } }
    public func getPtr(): Int64 { ptr }
}

// ============================================================
// FFI 声明
// ============================================================

foreign func qColorCreate(): Int64
foreign func qColorCreateRgb(r: Int32, g: Int32, b: Int32, a: Int32): Int64
foreign func qColorFromName(n: CString): Int64
foreign func qColorRed(p: Int64): Int32
foreign func qColorGreen(p: Int64): Int32
foreign func qColorBlue(p: Int64): Int32
foreign func qColorAlpha(p: Int64): Int32
foreign func qColorSetRed(p: Int64, v: Int32): Unit
foreign func qColorSetGreen(p: Int64, v: Int32): Unit
foreign func qColorSetBlue(p: Int64, v: Int32): Unit
foreign func qColorSetAlpha(p: Int64, v: Int32): Unit
foreign func qColorDelete(p: Int64): Unit

foreign func qPenCreate(): Int64
foreign func qPenCreateColor(c: Int64): Int64
foreign func qPenSetColor(p: Int64, c: Int64): Unit
foreign func qPenSetWidth(p: Int64, w: Int32): Unit
foreign func qPenWidth(p: Int64): Int32
foreign func qPenSetStyle(p: Int64, s: Int32): Unit
foreign func qPenDelete(p: Int64): Unit

foreign func qBrushCreate(): Int64
foreign func qBrushCreateColor(c: Int64): Int64
foreign func qBrushCreateGradient(g: Int64): Int64
foreign func qBrushSetColor(p: Int64, c: Int64): Unit
foreign func qBrushSetStyle(p: Int64, s: Int32): Unit
foreign func qBrushDelete(p: Int64): Unit

foreign func qLinearGradientCreate(x1: Float32, y1: Float32, x2: Float32, y2: Float32): Int64
foreign func qRadialGradientCreate(cx: Float32, cy: Float32, radius: Float32, fx: Float32, fy: Float32): Int64
foreign func qConicalGradientCreate(cx: Float32, cy: Float32, angle: Float32): Int64
foreign func qGradientSetColorAt(p: Int64, pos: Float32, c: Int64): Unit
foreign func qLinearGradientDelete(p: Int64): Unit
foreign func qRadialGradientDelete(p: Int64): Unit
foreign func qConicalGradientDelete(p: Int64): Unit

foreign func qFontCreate(f: CString, s: Int32, b: Int32, i: Int32): Int64
foreign func qFontSetPointSize(p: Int64, s: Int32): Unit
foreign func qFontSetBold(p: Int64, b: Int32): Unit
foreign func qFontSetItalic(p: Int64, i: Int32): Unit
foreign func qFontDelete(p: Int64): Unit

foreign func qPainterCreate(d: Int64): Int64
foreign func qPainterFromPtr(ptr: Int64): Int64
foreign func qPainterBegin(p: Int64, d: Int64): Int32
foreign func qPainterEnd(p: Int64): Int32
foreign func qPainterIsActive(p: Int64): Int32
foreign func qPainterSetPen(p: Int64, pen: Int64): Unit
foreign func qPainterSetPenColor(p: Int64, c: Int64): Unit
foreign func qPainterSetBrush(p: Int64, b: Int64): Unit
foreign func qPainterSetFont(p: Int64, f: Int64): Unit
foreign func qPainterSetRenderHint(p: Int64, h: Int32, on: Int32): Unit
foreign func qPainterSetOpacity(p: Int64, o: Float32): Unit
foreign func qPainterDrawLine(p: Int64, x1: Int32, y1: Int32, x2: Int32, y2: Int32): Unit
foreign func qPainterDrawRect(p: Int64, x: Int32, y: Int32, w: Int32, h: Int32): Unit
foreign func qPainterDrawEllipse(p: Int64, x: Int32, y: Int32, w: Int32, h: Int32): Unit
foreign func qPainterDrawEllipseCenter(p: Int64, cx: Int32, cy: Int32, rx: Int32, ry: Int32): Unit
foreign func qPainterDrawArc(p: Int64, x: Int32, y: Int32, w: Int32, h: Int32, s: Int32, sp: Int32): Unit
foreign func qPainterDrawPie(p: Int64, x: Int32, y: Int32, w: Int32, h: Int32, s: Int32, sp: Int32): Unit
foreign func qPainterDrawText(p: Int64, x: Int32, y: Int32, t: CString): Unit
foreign func qPainterDrawTextRect(p: Int64, x: Int32, y: Int32, w: Int32, h: Int32, f: Int32, t: CString): Unit
foreign func qPainterDrawPixmap(p: Int64, x: Int32, y: Int32, pm: Int64): Unit
foreign func qPainterDrawImage(p: Int64, x: Int32, y: Int32, i: Int64): Unit
foreign func qPainterFillRect(p: Int64, x: Int32, y: Int32, w: Int32, h: Int32, b: Int64): Unit
foreign func qPainterFillRectColor(p: Int64, x: Int32, y: Int32, w: Int32, h: Int32, c: Int64): Unit
foreign func qPainterTranslate(p: Int64, dx: Float32, dy: Float32): Unit
foreign func qPainterScale(p: Int64, sx: Float32, sy: Float32): Unit
foreign func qPainterRotate(p: Int64, a: Float32): Unit
foreign func qPainterSave(p: Int64): Unit
foreign func qPainterRestore(p: Int64): Unit
foreign func qPainterDevice(p: Int64): Int64

foreign func qPainterPathCreate(): Int64
foreign func qPainterPathMoveTo(p: Int64, x: Float32, y: Float32): Unit
foreign func qPainterPathLineTo(p: Int64, x: Float32, y: Float32): Unit
foreign func qPainterPathAddRect(p: Int64, x: Float32, y: Float32, w: Float32, h: Float32): Unit
foreign func qPainterPathAddEllipse(p: Int64, x: Float32, y: Float32, w: Float32, h: Float32): Unit
foreign func qPainterPathCloseSubpath(p: Int64): Unit
foreign func qPainterPathIsEmpty(p: Int64): Int32
foreign func qPainterPathDelete(p: Int64): Unit
foreign func qPainterDrawPath(p: Int64, path: Int64): Unit
foreign func qPainterFillPath(p: Int64, path: Int64, b: Int64): Unit

foreign func qPixmapCreate(): Int64
foreign func qPixmapCreateSize(w: Int32, h: Int32): Int64
foreign func qPixmapLoad(f: CString): Int64
foreign func qPixmapWidth(p: Int64): Int32
foreign func qPixmapHeight(p: Int64): Int32
foreign func qPixmapIsNull(p: Int64): Int32
foreign func qPixmapFill(p: Int64, c: Int64): Unit
foreign func qPixmapDelete(p: Int64): Unit

foreign func qImageCreate(): Int64
foreign func qImageCreateSize(w: Int32, h: Int32, fmt: Int32): Int64
foreign func qImageWidth(p: Int64): Int32
foreign func qImageHeight(p: Int64): Int32
foreign func qImageIsNull(p: Int64): Int32
foreign func qImageDelete(p: Int64): Unit
