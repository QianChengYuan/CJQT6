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
| `delete()` | 释放资源 |

**BrushStyle 枚举值**:
| 枚举值 | 说明 |
|--------|------|
| `NoBrush` | 无填充 |
| `SolidPattern` | 纯色填充 |
| `LinearGradient` | 线性渐变 |
| `RadialGradient` | 径向渐变 |
| `ConicalGradient` | 锥形渐变 |
| `HorPattern` | 水平线 |
| `VerPattern` | 垂直线 |
| `CrossPattern` | 十字线 |

---

## 渐变类

### QLinearGradient - 线性渐变

```cangjie
let gradient = QLinearGradient.fromInt(0, 0, 200, 0)  // 水平渐变
gradient.setColorAt(0.0f32, Colors.red())
gradient.setColorAt(0.5f32, Colors.yellow())
gradient.setColorAt(1.0f32, Colors.blue())
```

**渐变类通用方法**:
| 方法 | 说明 |
|------|------|
| `setColorAt(pos: Float32, color: QColor)` | 设置位置颜色（pos: 0.0~1.0） |
| `isValid(): Bool` | 检查是否有效 |
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
```

**QPixmap / QImage 方法**:
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
| `delete()` | 释放资源 |

**ImageFormat 枚举值**:
| 枚举值 | 说明 |
|--------|------|
| `Invalid` | 无效格式 |
| `RGB32` | 32位RGB |
| `ARGB32` | 32位ARGB |
| `ARGB32_Premultiplied` | 预乘ARGB32 |

---

## QPainter - 绘图器

核心绘图类，用于在设备上绘图。

```cangjie
let pixmap = QPixmap.withSize(400, 300)
pixmap.fill(Colors.white())

let painter = QPainter(pixmap.getPtr())
painter.setRenderHint(RenderHint.Antialiasing.value())

// 设置画笔和画刷
let pen = QPen(Colors.black())
pen.setWidth(2)
painter.setPen(pen)

let brush = QBrush(Colors.cyan())
painter.setBrush(brush)

// 绘制形状
painter.drawRect(20, 20, 100, 80)
painter.drawCircle(200, 100, 40)
painter.drawEllipse(280, 20, 100, 60)

// 绘制文字
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
| `init()` | 创建绘图器 |
| `init(device: Int64)` | 在设备上创建绘图器 |
| `fromPtr(ptr: Int64)` | 从指针创建（静态方法） |
| `begin(device: Int64): Bool` | 开始绘图 |
| `end(): Bool` | 结束绘图 |
| `isActive(): Bool` | 是否活动 |
| `setPen(pen: QPen)` | 设置画笔 |
| `setPenColor(c: QColor)` | 设置画笔颜色 |
| `setBrush(b: QBrush)` | 设置画刷 |
| `setFont(f: QFont)` | 设置字体 |
| `setRenderHint(h: Int32)` | 设置渲染提示 |
| `setOpacity(o: Float32)` | 设置透明度 |
| `drawLine(x1, y1, x2, y2)` | 绘制线条 |
| `drawRect(x, y, w, h)` | 绘制矩形 |
| `drawEllipse(x, y, w, h)` | 绘制椭圆 |
| `drawCircle(cx, cy, r)` | 绘制圆 |
| `drawArc(x, y, w, h, start, span)` | 绘制弧 |
| `drawPie(x, y, w, h, start, span)` | 绘制饼 |
| `drawText(x, y, text)` | 绘制文字 |
| `drawTextRect(x, y, w, h, flags, text)` | 在矩形内绘制文字 |
| `drawPixmap(x, y, pixmap)` | 绘制图像 |
| `drawPath(path)` | 绘制路径 |
| `fillPath(path, brush)` | 填充路径 |
| `fillRect(x, y, w, h, brush)` | 填充矩形 |
| `fillRectColor(x, y, w, h, color)` | 用颜色填充矩形 |
| `translate(dx, dy)` | 平移 |
| `scale(sx, sy)` | 缩放 |
| `rotate(a)` | 旋转（角度） |
| `save()` | 保存状态 |
| `restore()` | 恢复状态 |

**RenderHint 枚举值**:
| 枚举值 | 说明 |
|--------|------|
| `Antialiasing` | 抗锯齿 |
| `TextAntialiasing` | 文字抗锯齿 |
| `SmoothPixmapTransform` | 平滑像素变换 |

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