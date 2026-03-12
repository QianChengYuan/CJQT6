// CJQT6 绘图示例 - 演示 QPainter 绑定功能
// 在 QPixmap 上绘图并显示在 QLabel 中
package paint_demo

import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.paint.*
import CJQT6.gui.*

// 全局变量 - 使用指针延迟初始化
var gLabelPtr: Int64 = 0
var canvasWidth: Int32 = 480
var canvasHeight: Int32 = 320

// 获取标签指针
func getLabelPtr(): Int64 {
    gLabelPtr
}

// 设置标签指针
func setLabelPtr(p: Int64): Unit {
    gLabelPtr = p
}

// 绘制基本形状
func drawShapes(): Unit {
    let pixmap = QPixmap.withSize(canvasWidth, canvasHeight)
    pixmap.fill(Colors.white())
    
    let painter = QPainter(pixmap.getPtr())
    painter.setRenderHint(RenderHint.Antialiasing)
    
    // 绘制彩色矩形
    painter.fillRectColor(20, 20, 80, 50, Colors.red())
    painter.fillRectColor(120, 20, 80, 50, Colors.green())
    painter.fillRectColor(220, 20, 80, 50, Colors.blue())
    painter.fillRectColor(320, 20, 80, 50, Colors.yellow())
    
    // 绘制带边框的矩形
    let pen = QPen(Colors.black()).setWidth(2)
    painter.setPen(pen)
    painter.setBrush(QBrush(Colors.cyan()))
    painter.drawRect(20, 90, 120, 70)
    
    // 绘制圆形和椭圆
    painter.setBrush(QBrush(Colors.magenta()))
    painter.drawCircle(250, 125, 35)
    
    painter.setBrush(QBrush(QColor.rgba(255, 128, 0, 200)))
    painter.drawEllipse(340, 90, 100, 70)
    
    // 绘制线条
    painter.setPen(QPen(Colors.darkGray()).setWidth(3))
    painter.drawLine(20, 180, 450, 180)
    
    // 绘制虚线和点线
    painter.setPen(QPen(Colors.blue()).setWidth(2).setStyle(PenStyle.DashLine))
    painter.drawLine(20, 200, 450, 200)
    
    painter.setPen(QPen(Colors.red()).setWidth(2).setStyle(PenStyle.DotLine))
    painter.drawLine(20, 220, 450, 220)
    
    // 绘制饼图
    painter.setPen(QPen(Colors.black()))
    painter.setBrush(QBrush(Colors.red()))
    painter.drawPie(20, 250, 90, 90, 0, 90 * 16)
    painter.setBrush(QBrush(Colors.green()))
    painter.drawPie(20, 250, 90, 90, 90 * 16, 120 * 16)
    painter.setBrush(QBrush(Colors.blue()))
    painter.drawPie(20, 250, 90, 90, 210 * 16, 150 * 16)
    
    // 绘制弧线
    painter.setPen(QPen(Colors.magenta()).setWidth(3))
    painter.drawArc(140, 250, 90, 90, 0, 180 * 16)
    
    // 绘制文字
    let font = QFont("Arial", 14).setBold(true)
    painter.setFont(font)
    painter.setPenColor(Colors.black())
    painter.drawText(260, 280, "CJQT6 绘图演示")
    
    painter.end()
    
    // 直接设置 pixmap
    unsafe { qLabelSetPixmap(gLabelPtr, pixmap.getPtr()) }
}

// 绘制渐变效果
func drawGradients(): Unit {
    let pixmap = QPixmap.withSize(canvasWidth, canvasHeight)
    pixmap.fill(Colors.white())
    
    let painter = QPainter(pixmap.getPtr())
    painter.setRenderHint(RenderHint.Antialiasing)
    
    // 线性渐变 - 水平
    let grad1 = QLinearGradient.fromInt(20, 20, 200, 20)
    grad1.setColorAt(0.0, Colors.red()).setColorAt(1.0, Colors.blue())
    painter.setBrush(QBrush(grad1))
    painter.setPen(QPen(Colors.black()))
    painter.drawRect(20, 20, 180, 60)
    
    // 线性渐变 - 垂直
    let grad2 = QLinearGradient.fromInt(240, 20, 240, 80)
    grad2.setColorAt(0.0, Colors.green()).setColorAt(1.0, Colors.yellow())
    painter.setBrush(QBrush(grad2))
    painter.drawRect(240, 20, 180, 60)
    
    // 线性渐变 - 对角
    let grad3 = QLinearGradient.fromInt(20, 100, 200, 180)
    grad3.setColorAt(0.0, Colors.cyan()).setColorAt(0.5, Colors.magenta()).setColorAt(1.0, Colors.yellow())
    painter.setBrush(QBrush(grad3))
    painter.drawRect(20, 100, 180, 80)
    
    // 渐变椭圆
    let grad4 = QLinearGradient.fromInt(240, 100, 420, 180)
    grad4.setColorAt(0.0, Colors.red()).setColorAt(1.0, Colors.green())
    painter.setBrush(QBrush(grad4))
    painter.drawEllipse(240, 100, 180, 80)
    
    // 半透明效果
    painter.fillRectColor(100, 200, 280, 100, QColor.rgba(0, 0, 255, 128))
    painter.fillRectColor(150, 220, 280, 100, QColor.rgba(255, 0, 0, 128))
    
    // 文字
    let font = QFont("Arial", 16)
    painter.setFont(font)
    painter.setPenColor(Colors.black())
    painter.drawText(180, 300, "渐变与透明效果")
    
    painter.end()
    
    unsafe { qLabelSetPixmap(gLabelPtr, pixmap.getPtr()) }
}

// 绘制路径
func drawPaths(): Unit {
    let pixmap = QPixmap.withSize(canvasWidth, canvasHeight)
    pixmap.fill(Colors.white())
    
    let painter = QPainter(pixmap.getPtr())
    painter.setRenderHint(RenderHint.Antialiasing)
    
    // 绘制多边形路径
    let path1 = QPainterPath()
    path1.moveTo(100.0, 20.0)
    path1.lineTo(180.0, 80.0)
    path1.lineTo(140.0, 160.0)
    path1.lineTo(60.0, 160.0)
    path1.lineTo(20.0, 80.0)
    path1.closeSubpath()
    painter.setBrush(QBrush(QColor(255, 200, 100)))
    painter.setPen(QPen(Colors.black()).setWidth(2))
    painter.fillPath(path1, QBrush(QColor(255, 200, 100)))
    
    // 绘制曲线
    let path2 = QPainterPath()
    path2.moveTo(220.0, 100.0)
    path2.lineTo(280.0, 50.0)
    path2.lineTo(340.0, 120.0)
    path2.lineTo(400.0, 60.0)
    path2.lineTo(450.0, 100.0)
    painter.setPen(QPen(Colors.red()).setWidth(3))
    painter.drawPath(path2)
    
    // 绘制椭圆路径
    let path3 = QPainterPath()
    path3.addEllipse(50.0, 200.0, 150.0, 80.0)
    painter.setBrush(QBrush(Colors.cyan()))
    painter.setPen(QPen(Colors.blue()).setWidth(2))
    painter.fillPath(path3, QBrush(Colors.cyan()))
    
    // 矩形路径
    let path4 = QPainterPath()
    path4.addRect(250.0, 200.0, 180.0, 100.0)
    let grad = QLinearGradient.fromInt(250, 200, 430, 300)
    grad.setColorAt(0.0, Colors.green()).setColorAt(1.0, Colors.blue())
    painter.fillPath(path4, QBrush(grad))
    
    painter.end()
    
    unsafe { qLabelSetPixmap(gLabelPtr, pixmap.getPtr()) }
}

// 绘制文字
func drawTexts(): Unit {
    let pixmap = QPixmap.withSize(canvasWidth, canvasHeight)
    pixmap.fill(Colors.white())
    
    let painter = QPainter(pixmap.getPtr())
    painter.setRenderHint(RenderHint.TextAntialiasing)
    
    var y: Int32 = 40
    
    // 不同大小的文字
    let font12 = QFont("Arial", 12)
    painter.setFont(font12)
    painter.setPenColor(Colors.black())
    painter.drawText(20, y, "字体大小: 12")
    
    let font16 = QFont("Arial", 16)
    painter.setFont(font16)
    painter.drawText(20, y + 40, "字体大小: 16")
    
    let font20 = QFont("Arial", 20)
    painter.setFont(font20)
    painter.drawText(20, y + 90, "字体大小: 20")
    
    let font24 = QFont("Arial", 24)
    painter.setFont(font24)
    painter.drawText(20, y + 140, "字体大小: 24")
    
    let font32 = QFont("Arial", 32)
    painter.setFont(font32)
    painter.drawText(20, y + 200, "大小: 32")
    
    // 粗体和斜体
    y = 300
    let boldFont = QFont("Arial", 16).setBold(true)
    painter.setFont(boldFont)
    painter.setPenColor(Colors.blue())
    painter.drawText(20, y, "粗体文字")
    
    let italicFont = QFont("Arial", 16).setItalic(true)
    painter.setFont(italicFont)
    painter.setPenColor(Colors.red())
    painter.drawText(180, y, "斜体文字")
    
    // 居中文字
    painter.drawTextRect(20, 10, 440, 30, TextFlag.AlignCenter, "CJQT6 文字绘制演示")
    
    painter.end()
    
    unsafe { qLabelSetPixmap(gLabelPtr, pixmap.getPtr()) }
}

// 清除画布
func clearCanvas(): Unit {
    let pixmap = QPixmap.withSize(canvasWidth, canvasHeight)
    pixmap.fill(Colors.white())
    
    let painter = QPainter(pixmap.getPtr())
    let font = QFont("Arial", 20)
    painter.setFont(font)
    painter.setPenColor(Colors.gray())
    painter.drawTextRect(0, 0, canvasWidth, canvasHeight, TextFlag.AlignCenter, "点击按钮开始绘图")
    painter.end()
    
    unsafe { qLabelSetPixmap(gLabelPtr, pixmap.getPtr()) }
}

// FFI 声明
foreign func qLabelSetPixmap(ptr: Int64, pixmapPtr: Int64): Unit

// 按钮回调
let onShapes: VoidCallback = { => drawShapes() }
let onGradients: VoidCallback = { => drawGradients() }
let onPaths: VoidCallback = { => drawPaths() }
let onTexts: VoidCallback = { => drawTexts() }
let onClear: VoidCallback = { => clearCanvas() }

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    
    window.setTitle("CJQT6 绘图演示")
    window.resize(500, 450)
    
    // 创建主布局
    let mainLayout = QVBoxLayout()
    
    // 创建绘图标签
    let label = QLabel()
    setLabelPtr(label.getPtr())
    mainLayout.addWidget(label.getPtr())
    
    // 创建按钮布局
    let btnLayout = QHBoxLayout()
    
    let btnShapes = QPushButton()
    btnShapes.setText("形状")
    btnShapes.setOnClick(onShapes)
    btnLayout.addWidget(btnShapes.getPtr())
    
    let btnGradients = QPushButton()
    btnGradients.setText("渐变")
    btnGradients.setOnClick(onGradients)
    btnLayout.addWidget(btnGradients.getPtr())
    
    let btnPaths = QPushButton()
    btnPaths.setText("路径")
    btnPaths.setOnClick(onPaths)
    btnLayout.addWidget(btnPaths.getPtr())
    
    let btnTexts = QPushButton()
    btnTexts.setText("文字")
    btnTexts.setOnClick(onTexts)
    btnLayout.addWidget(btnTexts.getPtr())
    
    let btnClear = QPushButton()
    btnClear.setText("清除")
    btnClear.setOnClick(onClear)
    btnLayout.addWidget(btnClear.getPtr())
    
    mainLayout.addLayout(btnLayout.getPtr())
    
    window.setLayout(mainLayout.getPtr())
    
    // 初始化画布
    clearCanvas()
    
    window.show()
    
    let result = app.exec()
    
    // 清理
    label.delete()
    btnShapes.delete()
    btnGradients.delete()
    btnPaths.delete()
    btnTexts.delete()
    btnClear.delete()
    window.delete()
    app.delete()
    
    return result
}
