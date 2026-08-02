# CJQT6 绘图模块

本模块提供绑定Qt的绘图功能，包括颜色、画笔、画刷、渐变、绘图路径和绘图器。

```cangjie
import cjqt6.paint.*
```

## 类型安全枚举

绘图模块使用类型安全枚举替代原有的整型常量：

```cangjie
// PenStyle - 画笔样式
let style = PenStyle.DashLine
pen.setPenStyle(style)  // 推荐：类型安全

// BrushStyle - 画刷样式  
let brushStyle = BrushStyle.SolidPattern
brush.setBrushStyle(brushStyle)

// RenderHint - 渲染提示
painter.setRenderHint(RenderHint.Antialiasing.value())

// ImageFormat - 图像格式
let format = ImageFormat.ARGB32
```

---

## QColor - 颜色

```cangjie
// 创建颜色
let red = QColor(255, 0, 0)           // RGB
let transparent = QColor.rgba(255, 0, 0, 128)  // RGBA
let blue = QColor.fromName("blue")    // 从名称

// 预定义颜色
let white = Colors.white()
let black = Colors.black()
let red = Colors.red()
let green = Colors.green()
let blue = Colors.blue()
let yellow = Colors.yellow()
let cyan = Colors.cyan()
let magenta = Colors.magenta()
let gray = Colors.gray()
let lightGray = Colors.lightGray()
let darkGray = Colors.darkGray()
let transparent = Colors.transparent()
```

**QColor 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空颜色 |
| `init(r, g, b)` | 创建RGB颜色 |
| `rgba(r, g, b, a)` | 创建RGBA颜色（静态方法） |
| `fromName(name)` | 从名称创建颜色（静态方法） |
| `red(): Int32` | 获取红色分量 |
| `green(): Int32` | 获取绿色分量 |
| `blue(): Int32` | 获取蓝色分量 |
| `alpha(): Int32` | 获取透明度 |
| `setRed(r)` | 设置红色分量 |
| `setGreen(g)` | 设置绿色分量 |
| `setBlue(b)` | 设置蓝色分量 |
| `setAlpha(a)` | 设置透明度 |
| `isValid(): Bool` | 检查是否有效 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

---

## QPen - 画笔

画笔用于绘制线条和边框。

```cangjie
let pen = QPen(Colors.black())
pen.setWidth(2)
pen.setPenStyle(PenStyle.DashLine)  // 推荐：类型安全
```

**QPen 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建默认画笔 |
| `init(color: QColor)` | 创建指定颜色画笔 |
| `setColor(c: QColor)` | 设置颜色 |
| `setWidth(w: Int32)` | 设置宽度 |
| `width(): Int32` | 获取宽度 |
| `setStyle(s: Int32)` | 设置样式（整数值，兼容旧API） |
| `setPenStyle(s: PenStyle)` | 设置样式（类型安全枚举，推荐） |
| `isValid(): Bool` | 检查是否有效 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

**PenStyle 枚举值**:
| 枚举值 | 说明 |
|--------|------|
| `NoPen` | 无线条 |
| `SolidLine` | 实线 |
| `DashLine` | 虚线 |
| `DotLine` | 点线 |
| `DashDotLine` | 点划线 |
| `DashDotDotLine` | 双点划线 |
| `CustomDashLine` | 自定义虚线 |

---

## QBrush - 画刷

画刷用于填充形状。

```cangjie
let brush = QBrush(Colors.red())

// 渐变画刷
let gradient = QLinearGradient.fromInt(0, 0, 100, 100)
gradient.setColorAt(0.0f32, Colors.red())
gradient.setColorAt(1.0f32, Colors.blue())
let gradientBrush = QBrush(gradient)
```

**QBrush 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建默认画刷 |
| `init(color: QColor)` | 创建纯色画刷 |
| `init(gradient: QLinearGradient)` | 创建渐变画刷 |
| `setColor(c: QColor)` | 设置颜色 |
| `setStyle(s: Int32)` | 设置样式（整数值，兼容旧API） |
| `setBrushStyle(s: BrushStyle)` | 设置样式（类型安全枚举，推荐） |
| `isValid(): Bool` | 检查是否有效 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

**BrushStyle 枚举值**:
| 枚举值 | 说明 |
|--------|------|
| `NoBrush` | 无填充 |
| `SolidPattern` | 纯色填充 |
| `Dense1Pattern` | 高密度点阵（密度1~7递减） |
| `Dense2Pattern` | 密度2点阵 |
| `Dense3Pattern` | 密度3点阵 |
| `Dense4Pattern` | 密度4点阵 |
| `Dense5Pattern` | 密度5点阵 |
| `Dense6Pattern` | 密度6点阵 |
| `Dense7Pattern` | 低密度点阵 |
| `HorPattern` | 水平线 |
| `VerPattern` | 垂直线 |
| `CrossPattern` | 十字线 |
| `LinearGradient` | 线性渐变 |
| `RadialGradient` | 径向渐变 |
| `ConicalGradient` | 锥形渐变 |

---

## 渐变类

### QLinearGradient - 线性渐变

```cangjie
let gradient = QLinearGradient.fromInt(0, 0, 200, 0)  // 水平渐变
gradient.setColorAt(0.0f32, Colors.red())
gradient.setColorAt(0.5f32, Colors.yellow())
gradient.setColorAt(1.0f32, Colors.blue())
```

| 方法 | 说明 |
|------|------|
| `init(x1, y1, x2, y2)` | 以 Float32 坐标创建线性渐变 |
| `fromInt(x1, y1, x2, y2)` | 以 Int32 坐标创建（静态方法） |
| `setColorAt(pos: Float32, c: QColor): QLinearGradient` | 设置位置颜色（pos: 0.0~1.0），返回自身支持链式调用 |
| `getPtr(): Int64` | 获取原生指针 |
| `isValid(): Bool` | 检查是否有效 |
| `delete()` | 释放资源 |

### QRadialGradient - 径向渐变

从中心点向外扩散的圆形渐变，可指定焦点偏移。

```cangjie
// 圆心 (100,100)，半径 80，焦点 (120,120)
let gradient = QRadialGradient.fromInt(100, 100, 80, 120, 120)
gradient.setColorAt(0.0f32, Colors.white())
gradient.setColorAt(1.0f32, Colors.blue())

// 作为画刷使用
let brush = QBrush(gradient)
```

> 注意：`QBrush` 的构造函数只接收 `QLinearGradient`，径向/锥形渐变需配合 `setBrushStyle(BrushStyle.RadialGradient)` 与 `setColor` 场景使用，或直接作为画刷样式常量传入。

| 方法 | 说明 |
|------|------|
| `init(cx, cy, radius, fx, fy)` | 以 Float32 创建径向渐变（圆心/半径/焦点） |
| `fromInt(cx, cy, radius, fx, fy)` | 以 Int32 创建（静态方法） |
| `setColorAt(pos: Float32, c: QColor): QRadialGradient` | 设置位置颜色，返回自身支持链式调用 |
| `getPtr(): Int64` | 获取原生指针 |
| `isValid(): Bool` | 检查是否有效 |
| `delete()` | 释放资源 |

### QConicalGradient - 锥形渐变

围绕中心点按角度展开的渐变。

```cangjie
// 中心 (100,100)，起始角度 45 度
let gradient = QConicalGradient.fromInt(100, 100, 45)
gradient.setColorAt(0.0f32, Colors.red())
gradient.setColorAt(0.5f32, Colors.yellow())
gradient.setColorAt(1.0f32, Colors.green())
```

| 方法 | 说明 |
|------|------|
| `init(cx, cy, angle)` | 以 Float32 创建锥形渐变（中心/起始角度，度） |
| `fromInt(cx, cy, angle)` | 以 Int32 创建（静态方法） |
| `setColorAt(pos: Float32, c: QColor): QConicalGradient` | 设置位置颜色，返回自身支持链式调用 |
| `getPtr(): Int64` | 获取原生指针 |
| `isValid(): Bool` | 检查是否有效 |
| `delete()` | 释放资源 |

---

## QFontDatabase - 字体数据库

查询系统可用字体族、样式与字号信息。全部为静态方法，无需实例化。

```cangjie
// 获取全部可用字体族（逗号分隔）
let families = QFontDatabase.families()

// 查询某字体族是否等宽/可缩放
let fixed = QFontDatabase.isFixedPitch("Consolas", "Regular")
let scalable = QFontDatabase.isScalable("Arial")

// 查询样式与字号
let styles = QFontDatabase.styles("Arial")     // 如 "Regular,Bold,Italic"
let sizes = QFontDatabase.pointSizes("Arial", "Regular")
```

| 方法 | 说明 |
|------|------|
| `families(): String` | 获取系统全部可用字体族名称（逗号分隔） |
| `standardSizes(): Int32` | 获取系统标准字号列表（通常 6~40 等差序列） |
| `isFixedPitch(family, style): Bool` | 指定字体族/样式是否为等宽字体 |
| `isScalable(family): Bool` | 指定字体族是否可缩放（矢量字体返回 true） |
| `styles(family): String` | 获取指定字体族支持的样式名（逗号分隔） |
| `pointSizes(family, style): Int32` | 获取指定字体族/样式支持的字号（磅值） |

---

## QTransform - 2D 变换矩阵

用于坐标变换的 3x3 矩阵，支持平移、缩放、旋转、扭曲及矩阵运算。变换方法均返回**新的** QTransform 对象，原对象不变。

```cangjie
let t = QTransform()
let moved = t.translate(10.0f32, 20.0f32)
let scaled = moved.scale(2.0f32, 2.0f32)
let rotated = scaled.rotate(45.0f32)

// 矩阵运算
let result = t.multiply(rotated)
let inverse = t.inverted()

// 判断
if (t.isIdentity()) {
    // 单位矩阵
}
if (t.isInvertible()) {
    // 可逆
}
```

| 方法 | 说明 |
|------|------|
| `init()` | 创建单位矩阵 |
| `init(m11..m33)` | 以 9 个 Float32 值创建矩阵 |
| `setMatrix(m11..m33)` | 设置矩阵值 |
| `translate(dx, dy): QTransform` | 平移变换，返回新变换 |
| `scale(sx, sy): QTransform` | 缩放变换，返回新变换 |
| `rotate(angle): QTransform` | 旋转变换（角度），返回新变换 |
| `shear(sh, sv): QTransform` | 扭曲变换，返回新变换 |
| `m11() ~ m33(): Float32` | 获取矩阵元素 |
| `dx(): Float32` / `dy(): Float32` | 获取平移量 |
| `isIdentity(): Bool` | 是否为单位矩阵 |
| `isInvertible(): Bool` | 是否可逆 |
| `inverted(): QTransform` | 获取逆变换 |
| `multiply(other: QTransform): QTransform` | 矩阵乘法 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

---

## QFont - 绘图字体

```cangjie
let font = QFont("Arial", 16)
font.setBold(true)
font.setItalic(true)
```

**QFont 方法**:
| 方法 | 说明 |
|------|------|
| `init(family: String)` | 创建字体（默认12号） |
| `init(family: String, pointSize: Int32)` | 创建指定大小字体 |
| `setPointSize(n: Int32)` | 设置字号 |
| `setBold(b: Bool)` | 设置粗体 |
| `setItalic(b: Bool)` | 设置斜体 |
| `isValid(): Bool` | 检查是否有效 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

---

## QPainterPath - 绘图路径

用于创建复杂形状。

```cangjie
let path = QPainterPath()
path.moveTo(100.0f32, 20.0f32)
path.lineTo(180.0f32, 80.0f32)
path.lineTo(140.0f32, 160.0f32)
path.closeSubpath()

// 预定义形状
let ellipsePath = QPainterPath()
ellipsePath.addEllipse(50.0f32, 50.0f32, 100.0f32, 80.0f32)
```

**QPainterPath 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空路径 |
| `moveTo(x, y)` | 移动到点 |
| `lineTo(x, y)` | 画线到点 |
| `addRect(x, y, w, h)` | 添加矩形 |
| `addEllipse(x, y, w, h)` | 添加椭圆 |
| `closeSubpath()` | 闭合路径 |
| `isEmpty(): Bool` | 是否为空 |
| `isValid(): Bool` | 检查是否有效 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

---

## QPixmap / QImage - 图像

```cangjie
// 创建空白图像
let pixmap = QPixmap.withSize(400, 300)
pixmap.fill(Colors.white())

// 从文件加载
let loadedPixmap = QPixmap.load("/path/to/image.png")

// 获取信息
let w = pixmap.width()
let h = pixmap.height()

// QImage 用法
let image = QImage.withSize(400, 300)  // 默认 ARGB32 格式
let iw = image.width()
let ih = image.height()
```

**QPixmap 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空图像 |
| `withSize(w, h)` | 创建指定大小图像（静态方法） |
| `load(path: String)` | 从文件加载（静态方法） |
| `width(): Int32` | 获取宽度 |
| `height(): Int32` | 获取高度 |
| `isNull(): Bool` | 是否为空 |
| `isValid(): Bool` | 检查是否有效 |
| `fill(c: QColor)` | 填充颜色 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

**QImage 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空图像 |
| `withSize(w, h)` | 创建指定大小图像，格式为 ARGB32（静态方法） |
| `width(): Int32` | 获取宽度 |
| `height(): Int32` | 获取高度 |
| `isNull(): Bool` | 是否为空 |
| `isValid(): Bool` | 检查是否有效 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

> 说明：当前封装中 QImage 不支持 `load()` 与 `fill()`（与 QPixmap 不同），加载图片请使用 `QPixmap.load()`。

**ImageFormat 枚举值**:
| 枚举值 | 说明 |
|--------|------|
| `Invalid` | 无效格式 |
| `Mono` | 单色（1位） |
| `MonoLSB` | 单色（LSB优先） |
| `Indexed8` | 8位索引色 |
| `RGB32` | 32位RGB |
| `ARGB32` | 32位ARGB |
| `ARGB32_Premultiplied` | 预乘ARGB32 |
| `RGB16` | 16位RGB |
| `RGB888` | 24位RGB |
| `RGBA8888` | 32位RGBA |

---

## QPainter - 绘图器

QPainter 是当前封装中最核心的绘图入口，主要用于把绘制命令提交给一个已有的设备对象，例如 QPixmap 或 QWidget 的绘制上下文。

```cangjie
let pixmap = QPixmap.withSize(400, 300)
pixmap.fill(Colors.white())

let painter = QPainter(pixmap.getPtr())
painter.setRenderHint(RenderHint.Antialiasing.value())

let pen = QPen(Colors.black())
pen.setWidth(2)
painter.setPen(pen)

let brush = QBrush(Colors.cyan())
painter.setBrush(brush)

painter.drawRect(20, 20, 100, 80)
painter.drawCircle(200, 100, 40)
painter.drawEllipse(280, 20, 100, 60)

let font = QFont("Arial", 16)
font.setBold(true)
painter.setFont(font)
painter.setPenColor(Colors.black())
painter.drawText(50, 250, "Hello QPainter!")

painter.end()
```

**QPainter 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空绘图器对象 |
| `init(device: Int64)` | 基于设备指针创建绘图器 |
| `fromPtr(ptr: Int64)` | 从现有指针创建 QPainter（不拥有所有权） |
| `begin(device: Int64): Bool` | 开始对指定设备绘制 |
| `end(): Bool` | 结束当前绘制 |
| `isActive(): Bool` | 是否处于绘制活跃状态 |
| `setPen(p: QPen)` | 设置画笔 |
| `setPenColor(c: QColor)` | 设置画笔颜色 |
| `setBrush(b: QBrush)` | 设置画刷 |
| `setFont(f: QFont)` | 设置字体 |
| `setRenderHint(h: Int32)` | 设置渲染提示，当前使用整数值 |
| `setOpacity(o: Float32)` | 设置透明度 |
| `drawLine(x1, y1, x2, y2)` | 绘制线条 |
| `drawRect(x, y, w, h)` | 绘制矩形 |
| `drawEllipse(x, y, w, h)` | 绘制椭圆 |
| `drawCircle(cx, cy, r)` | 绘制圆 |
| `drawArc(x, y, w, h, start, span)` | 绘制弧 |
| `drawPie(x, y, w, h, start, span)` | 绘制饼 |
| `drawText(x, y, s)` | 在指定位置绘制文本 |
| `drawTextRect(x, y, w, h, flags, s)` | 在矩形区域内绘制文本，`flags` 传入文本对齐位标志 |
| `drawPixmap(x, y, p)` | 绘制 QPixmap |
| `drawImage(x, y, i)` | 绘制 QImage |
| `drawPath(p)` | 绘制路径 |
| `fillPath(p, b)` | 使用画刷填充路径 |
| `fillRect(x, y, w, h, b)` | 使用画刷填充矩形 |
| `fillRectColor(x, y, w, h, c)` | 使用颜色填充矩形 |
| `translate(dx, dy)` | 平移坐标系 |
| `scale(sx, sy)` | 缩放坐标系 |
| `rotate(a)` | 旋转坐标系 |
| `save()` | 保存当前状态 |
| `restore()` | 恢复上一次保存的状态 |
| `device(): Int64` | 返回当前设备指针 |
| `getPtr(): Int64` | 返回原生指针 |

**RenderHint 枚举值**:
| 枚举值 | 说明 |
|--------|------|
| `Antialiasing` | 抗锯齿 |
| `TextAntialiasing` | 文字抗锯齿 |
| `SmoothPixmapTransform` | 平滑像素变换 |
| `HighQualityAntialiasing` | 高质量抗锯齿 |
| `NonCosmeticDefaultPen` | 非装饰默认笔 |

> 说明：当前封装里的 `QPainter` 不是通过终结器自动释放的；如果你是从外部指针创建，通常只需直接使用，不要手动 `delete()`。在普通场景下，仍应在不再使用时显式释放像 `QPen`、`QBrush`、`QFont`、`QPixmap` 这类对象。
---

## 文本对齐

使用 `TextAlignment` 结构体（支持位运算组合）：

```cangjie
// 预定义对齐方式
let center = TextAlignment.Center        // 居中
let topLeft = TextAlignment.TopLeft      // 左上
let topRight = TextAlignment.TopRight    // 右上

// 自定义组合
let custom = TextAlignment.Left | TextAlignment.VCenter
```

**TextAlignment 常量**:
| 常量 | 值 | 说明 |
|------|------|------|
| `Left` | 0x0001 | 左对齐 |
| `Right` | 0x0002 | 右对齐 |
| `HCenter` | 0x0004 | 水平居中 |
| `Top` | 0x0020 | 顶部对齐 |
| `Bottom` | 0x0040 | 底部对齐 |
| `VCenter` | 0x0080 | 垂直居中 |
| `Center` | 0x0084 | 完全居中 |
| `Default` | 0x0081 | 默认（左 | 垂直居中） |

---

## ⚠️ 内存管理

**绘图类终结器已禁用** — QColor、QPen、QBrush、QFont、QPixmap 等绘图类的终结器已被禁用（原因同控件类：GC可能在不正确的时机调用终结器）。请在不再使用时显式调用 `delete()` 释放资源。

最佳实践：

1. **游戏/高频渲染场景**：手动释放，避免 GC 不确定时机
   ```cangjie
   let color = QColor(255, 0, 0)
   // 使用 color...
   color.delete()  // 手动释放
   ```

2. **缓存常用对象**：避免重复创建
   ```cangjie
   class MyRenderer {
       let cachedColor: QColor
       let cachedPen: QPen
       
       public init() {
           cachedColor = QColor(255, 0, 0)
           cachedPen = QPen(cachedColor)
       }
       
       func render(painter: QPainter) {
           painter.setPen(cachedPen)
       }
       
       func cleanup() {
           cachedColor.delete()
           cachedPen.delete()
       }
   }
   ```

---

## QIcon - 图标

图标资源，可空构造或从文件加载，用于按钮、窗口标题等。

```cangjie
let icon = QIcon(":/icons/app.png")  // 或 QIcon("app.png")
if (!icon.isNull()) {
    window.setWindowIcon(icon.getPtr())
}
icon.addFile(":/icons/app_high.png")  // 添加多分辨率/状态图标
icon.delete()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空图标 |
| `init(filename: String)` | 从文件路径创建图标 |
| `isNull(): Bool` | 图标是否为空 |
| `addFile(filename: String)` | 添加图标文件（支持多模式/状态） |
| `getPtr(): Int64` | 获取指针 |
| `close()` / `delete()` | 释放资源 |

---

## QCursor - 光标

鼠标光标，可设置形状或全局屏幕位置。静态方法控制整个屏幕的光标位置。

```cangjie
let cursor = QCursor(CursorShape.pointingHand())  // 手型
cursor.setShape(CursorShape.cross())              // 改为十字

// 全局光标位置（静态方法）
QCursor.setPos(800, 450)
let x = QCursor.posX()
let y = QCursor.posY()
cursor.close()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建默认光标 |
| `init(shape: Int32)` | 创建指定形状的光标 |
| `shape(): Int32` | 获取光标形状 |
| `setShape(shape: Int32)` | 设置光标形状 |
| `setPos(x: Int32, y: Int32)` | 设置全局光标屏幕位置（静态方法） |
| `posX(): Int32` / `posY(): Int32` | 获取光标屏幕 X/Y 位置（静态方法） |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

**CursorShape 光标形状常量**（部分常用）:
| 常量 | 值 | 说明 |
|------|-----|------|
| `CursorShape.arrow()` | 0 | 标准箭头 |
| `CursorShape.cross()` | 2 | 十字 |
| `CursorShape.waitCursor()` | 3 | 等待 |
| `CursorShape.iBeam()` | 4 | 文本编辑 I 形 |
| `CursorShape.sizeAll()` | 9 | 四方向调整大小 |
| `CursorShape.blank()` | 10 | 空白（隐藏光标） |
| `CursorShape.pointingHand()` | 13 | 手型 |
| `CursorShape.forbidden()` | 14 | 禁止 |
| `CursorShape.openHand()` | 17 | 张开的手型 |
| `CursorShape.closedHand()` | 18 | 握紧的手型 |
| `CursorShape.dragCopy()` | 19 | 拖拽复制 |
| `CursorShape.dragMove()` | 20 | 拖拽移动 |
| `CursorShape.dragLink()` | 21 | 拖拽链接 |

---

## QPalette - 调色板

定义控件在不同状态组（普通/禁用/激活等）下各角色的颜色，用于统一样式。

```cangjie
let palette = QPalette()
// 设置普通状态下窗口文字为白色（ARGB）
palette.setColor(0, 0, 255, 255, 255, 255)
let argb = palette.color(0, 0)  // 读取颜色（ARGB 值）
palette.close()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建默认调色板 |
| `color(group: Int32, role: Int32): Int64` | 获取指定状态组、角色的颜色（返回 ARGB 值） |
| `setColor(group: Int32, role: Int32, r: Int32, g: Int32, b: Int32, a: Int32)` | 设置指定状态组、角色的颜色（RGBA 0-255） |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

> 说明：`group` 对应 Qt `QPalette::ColorGroup`，`role` 对应 `QPalette::ColorRole`。常见组合：group=0 普通状态，role=0 窗口文字。数值见 Qt 官方文档。

---

## QFontMetrics - 字体度量

提供指定字体下文本的宽度、高度、行距等测量数据，用于精确排版。

```cangjie
let font = QFont("Arial", 12)
let metrics = QFontMetrics(font.getPtr())
println("行高: ${metrics.height()}")
println("文本宽度: ${metrics.horizontalAdvance("Hello")}")
metrics.close()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(fontPtr: Int64)` | 创建字体度量对象（QFont 指针） |
| `height(): Int32` | 字体总高度（ascent + descent + leading） |
| `ascent(): Int32` | 上伸部分高度（基线以上） |
| `descent(): Int32` | 下伸部分高度（基线以下） |
| `leading(): Int32` | 行距（额外间距） |
| `lineSpacing(): Int32` | 行间距（ascent + descent + leading） |
| `averageCharWidth(): Int32` | 字符平均宽度 |
| `horizontalAdvance(text: String): Int32` | 指定文本的水平宽度（像素） |
| `maxWidth(): Int32` | 字符最大宽度 |
| `fontFamily(): String` | 字体族名称 |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

---

## QFontInfo - 字体信息

提供字体实际解析后的属性（实际使用的字体族、字号、样式等）。

```cangjie
let font = QFont("Arial", 12)
let info = QFontInfo(font.getPtr())
println("实际字体: ${info.family()}")
println("字号: ${info.pointSizeF()}")
println("加粗: ${info.bold()}")
info.close()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(fontPtr: Int64)` | 创建字体信息对象（QFont 指针） |
| `family(): String` | 实际使用的字体族名称 |
| `pointSize(): Int32` / `pointSizeF(): Float64` | 字号（磅，整数/浮点） |
| `pixelSize(): Int32` | 像素字号 |
| `bold(): Bool` | 是否加粗 |
| `italic(): Bool` | 是否斜体 |
| `underline(): Bool` | 是否有下划线 |
| `strikeOut(): Bool` | 是否有删除线 |
| `fixedPitch(): Bool` | 是否等宽字体 |
| `weight(): Int32` | 字重（400 常规，700 粗体） |
| `styleHint(): Int32` | 字体风格提示 |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

---

## QStyleHelper - 样式查询辅助

提供 QStyle 指针获取、像素度量查询与标准图标获取（全部为静态方法）。

```cangjie
let stylePtr = QStyleHelper.widgetStyle(window.getPtr())  // 控件样式指针
let iconSize = QStyleHelper.buttonIconSize(window.getPtr())  // 按钮图标大小
let iconPtr = QStyleHelper.standardIcon(stylePtr, StandardIcon.messageBoxInformation())  // 标准图标
```

**静态方法**:
| 方法 | 说明 |
|------|------|
| `widgetStyle(widgetPtr: Int64): Int64` | 获取控件的 QStyle 指针 |
| `applicationStyle(): Int64` | 获取应用的 QStyle 指针 |
| `pixelMetric(stylePtr, metric: Int32): Int32` | 查询像素度量值 |
| `widgetPixelMetric(widgetPtr, metric): Int32` | 从控件查询像素度量（自动取 QStyle） |
| `standardIcon(stylePtr, iconType: Int32): Int64` | 获取标准图标（返回 QIcon 指针） |
| `widgetStandardIcon(widgetPtr, iconType): Int64` | 从控件获取标准图标 |
| `buttonIconSize(widgetPtr): Int32` | 按钮图标大小 |
| `smallIconSize(widgetPtr): Int32` / `largeIconSize(widgetPtr): Int32` | 小/大图标大小 |
| `toolBarIconSize(widgetPtr): Int32` | 工具栏图标大小 |
| `listViewIconSize(widgetPtr): Int32` | 列表视图图标大小 |
| `titleBarHeight(widgetPtr): Int32` | 标题栏高度 |
| `scrollBarExtent(widgetPtr): Int32` | 滚动条宽度 |
| `sliderThickness(widgetPtr): Int32` | 滑块厚度 |
| `progressBarHeight(widgetPtr): Int32` | 进度条高度 |

**StandardIcon 标准图标常量**（部分常用）:
| 常量 | 值 | 说明 |
|------|-----|------|
| `StandardIcon.messageBoxInformation()` | 9 | 信息图标 |
| `StandardIcon.messageBoxWarning()` | 10 | 警告图标 |
| `StandardIcon.messageBoxCritical()` | 11 | 严重图标 |
| `StandardIcon.messageBoxQuestion()` | 12 | 询问图标 |
| `StandardIcon.fileIcon()` | 25 | 文件图标 |
| `StandardIcon.folderIcon()` | 38 | 文件夹图标 |
| `StandardIcon.arrowUp()` | 50 | 上箭头 |
| `StandardIcon.arrowDown()` | 51 | 下箭头 |
| `StandardIcon.arrowLeft()` | 52 | 左箭头 |
| `StandardIcon.arrowRight()` | 53 | 右箭头 |
| `StandardIcon.mediaPlay()` | 61 | 播放 |
| `StandardIcon.mediaStop()` | 62 | 停止 |
| `StandardIcon.mediaPause()` | 63 | 暂停 |
| `StandardIcon.dialogCancel()` | 40 | 取消 |
| `StandardIcon.dialogYes()` | 48 | 是 |
| `StandardIcon.dialogNo()` | 49 | 否 |

**PixelMetric 像素度量常量**（部分常用，传入 `pixelMetric`/`widgetPixelMetric`）:
| 常量 | 值 | 说明 |
|------|-----|------|
| `PixelMetric.buttonIconSize()` | 72 | 按钮图标大小 |
| `PixelMetric.tabBarBaseHeight()` | 22 | 标签栏基座高度 |
| `PixelMetric.titleBarHeight()` | 26 | 标题栏高度 |
| `PixelMetric.scrollBarExtent()` | 9 | 滚动条宽度 |
| `PixelMetric.sliderThickness()` | 11 | 滑块厚度 |
| `PixelMetric.sliderLength()` | 13 | 滑块长度 |
| `PixelMetric.toolBarIconSize()` | 59 | 工具栏图标大小 |
| `PixelMetric.listViewIconSize()` | 60 | 列表图标大小 |
| `PixelMetric.smallIconSize()` | 62 | 小图标大小 |
| `PixelMetric.largeIconSize()` | 63 | 大图标大小 |

---

## 完整示例

```cangjie
import cjqt6.paint.*
import cjqt6.widgets.*

main(): Int32 {
    let app = QApplication()
    let label = QLabel()
    label.resize(400, 300)
    
    let pixmap = QPixmap.withSize(400, 300)
    pixmap.fill(Colors.white())
    
    let painter = QPainter(pixmap.getPtr())
    painter.setRenderHint(RenderHint.Antialiasing.value())
    
    // 绘制渐变背景
    let gradient = QLinearGradient.fromInt(0, 0, 0, 300)
    gradient.setColorAt(0.0f32, QColor(100, 150, 255))
    gradient.setColorAt(1.0f32, QColor(255, 255, 255))
    let brush = QBrush(gradient)
    painter.fillRect(0, 0, 400, 300, brush)
    gradient.delete()
    
    // 绘制图形
    let pen = QPen(Colors.black())
    pen.setWidth(2)
    painter.setPen(pen)
    painter.drawCircle(200, 150, 50)
    
    // 绘制文字
    let font = QFont("Arial", 20)
    painter.setFont(font)
    painter.drawTextRect(100, 250, 200, 30, TextAlignment.Center.value, "Hello!")
    
    painter.end()
    
    label.setPixmap(pixmap.getPtr())
    label.show()
    
    let result = app.exec()
    
    // 清理资源
    pen.delete()
    brush.delete()
    font.delete()
    pixmap.delete()
    
    return result
}
```