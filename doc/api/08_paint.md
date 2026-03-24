# CJQT6 绘图模块

本模块提供绑定Qt的绘图功能，包括颜色、画笔、画刷、渐变、绘图路径和绘图器。

```cangjie
import CJQT6.paint.*
```

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
| `delete()` | 释放资源 |

---

## QPen - 画笔

画笔用于绘制线条和边框。

```cangjie
let pen = QPen(Colors.black())
pen.setWidth(2)
pen.setStyle(PenStyle.DashLine)
```

**QPen 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建默认画笔 |
| `init(color: QColor)` | 创建指定颜色画笔 |
| `setColor(c: QColor)` | 设置颜色 |
| `setWidth(w: Int32)` | 设置宽度 |
| `width(): Int32` | 获取宽度 |
| `setStyle(s: Int32)` | 设置样式 |
| `delete()` | 释放资源 |

**画笔样式常量** (PenStyle):
```cangjie
NoPen      // 无线条
SolidLine  // 实线
DashLine   // 虚线
DotLine    // 点线
```

---

## QBrush - 画刷

画刷用于填充形状。

```cangjie
let brush = QBrush(Colors.red())

// 渐变画刷
let gradient = QLinearGradient.fromInt(0, 0, 100, 100)
gradient.setColorAt(0.0, Colors.red())
gradient.setColorAt(1.0, Colors.blue())
let gradientBrush = QBrush(gradient)
```

**QBrush 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建默认画刷 |
| `init(color: QColor)` | 创建纯色画刷 |
| `init(gradient: QLinearGradient)` | 创建渐变画刷 |
| `setColor(c: QColor)` | 设置颜色 |
| `setStyle(s: Int32)` | 设置样式 |
| `delete()` | 释放资源 |

**画刷样式常量** (BrushStyle):
```cangjie
NoBrush       // 无填充
SolidPattern  // 纯色填充
```

---

## QLinearGradient - 线性渐变

```cangjie
let gradient = QLinearGradient.fromInt(0, 0, 200, 0)  // 水平渐变
gradient.setColorAt(0.0, Colors.red())     // 起点：红色
gradient.setColorAt(0.5, Colors.yellow())  // 中间：黄色
gradient.setColorAt(1.0, Colors.blue())    // 终点：蓝色
```

**QLinearGradient 方法**:
| 方法 | 说明 |
|------|------|
| `init(x1, y1, x2, y2)` | 创建渐变（Float32坐标） |
| `fromInt(x1, y1, x2, y2)` | 创建渐变（Int32坐标，静态方法） |
| `setColorAt(pos, color)` | 设置位置颜色（pos: 0.0~1.0） |
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
| `delete()` | 释放资源 |

---

## QPainterPath - 绘图路径

用于创建复杂形状。

```cangjie
let path = QPainterPath()
path.moveTo(100.0, 20.0)
path.lineTo(180.0, 80.0)
path.lineTo(140.0, 160.0)
path.closeSubpath()

// 预定义形状
let ellipsePath = QPainterPath()
ellipsePath.addEllipse(50.0, 50.0, 100.0, 80.0)

let rectPath = QPainterPath()
rectPath.addRect(20.0, 20.0, 150.0, 100.0)
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
| `delete()` | 释放资源 |

---

## QPixmap - 图像

```cangjie
// 创建空白图像
let pixmap = QPixmap.withSize(400, 300)
pixmap.fill(Colors.white())

// 从文件加载
let loadedPixmap = QPixmap.load("/path/to/image.png")

// 获取信息
let w = pixmap.width()
let h = pixmap.height()
let isNull = pixmap.isNull()
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
| `fill(c: QColor)` | 填充颜色 |
| `delete()` | 释放资源 |

---

## QPainter - 绘图器

核心绘图类，用于在设备上绘图。

```cangjie
let pixmap = QPixmap.withSize(400, 300)
pixmap.fill(Colors.white())

let painter = QPainter(pixmap.getPtr())
painter.setRenderHint(RenderHint.Antialiasing)

// 设置画笔和画刷
painter.setPen(QPen(Colors.black()).setWidth(2))
painter.setBrush(QBrush(Colors.cyan()))

// 绘制形状
painter.drawRect(20, 20, 100, 80)
painter.drawCircle(200, 100, 40)
painter.drawEllipse(280, 20, 100, 60)

// 绘制线条
painter.drawLine(20, 150, 380, 150)

// 绘制文字
let font = QFont("Arial", 16).setBold(true)
painter.setFont(font)
painter.setPenColor(Colors.black())
painter.drawText(50, 250, "Hello QPainter!")

// 绘制饼图
painter.drawPie(20, 200, 100, 100, 0, 90*16)  // 90度

painter.end()

// 显示在标签上
label.setPixmap(pixmap.getPtr())
```

**QPainter 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建绘图器 |
| `init(device: Int64)` | 在设备上创建绘图器 |
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

**渲染提示常量** (RenderHint):
```cangjie
Antialiasing       // 抗锯齿
TextAntialiasing   // 文字抗锯齿
```

**文字对齐常量** (TextFlag):
```cangjie
AlignLeft      // 左对齐
AlignRight     // 右对齐
AlignHCenter   // 水平居中
AlignTop       // 顶部对齐
AlignBottom    // 底部对齐
AlignVCenter   // 垂直居中
AlignCenter    // 居中
```
