package analog_clock

import CJQT6.core.*
import CJQT6.paint.*
import CJQT6.widgets.*
import std.math.*

// ============================================================
// 全局状态
// ============================================================
var gWidget: ?QEventWidget = None
var gTimer: ?QTimer = None
var gHourHandColor: ?QColor = None
var gMinuteHandColor: ?QColor = None
var gSecondHandColor: ?QColor = None
var gTickColor: ?QColor = None
var gFaceColor: ?QColor = None
var gBorderColor: ?QColor = None

// 时钟尺寸
let CLOCK_SIZE: Int32 = 300
let CENTER_X: Int32 = 200
let CENTER_Y: Int32 = 200

// ============================================================
// 绘制时钟
// ============================================================

// 绘制回调 - 使用 CFunc 类型
let onPaintCallback: CFunc<(Int64) -> Unit> = { painterPtr: Int64 =>
    let painter = QPainter.fromPtr(painterPtr)
    
    // 设置抗锯齿
    painter.setRenderHint(RenderHint.Antialiasing)
    
    // 绘制时钟表盘
    drawClockFace(painter)
    
    // 获取当前时间
    let now = QTime.currentTime()
    let hour = now.hour()
    let minute = now.minute()
    let second = now.second()
    
    // 绘制指针
    drawHand(painter, hour % 12, minute, second)
    
    // 绘制中心点
    drawCenter(painter)
}

// 绘制时钟表盘
func drawClockFace(painter: QPainter): Unit {
    let cx = CENTER_X
    let cy = CENTER_Y
    let radius = CLOCK_SIZE / 2
    
    // 绘制外圈
    if (let Some(borderColor) <- gBorderColor) {
        let pen = QPen(borderColor)
        pen.setWidth(4)
        painter.setPen(pen)
        if (let Some(faceColor) <- gFaceColor) {
            let brush = QBrush(faceColor)
            painter.setBrush(brush)
        }
        painter.drawEllipse(cx - radius, cy - radius, radius * 2, radius * 2)
    }
    
    // 绘制刻度
    if (let Some(tickColor) <- gTickColor) {
        let tickPen = QPen(tickColor)
        tickPen.setWidth(2)
        painter.setPen(tickPen)
        
        // 12个小时刻度
        for (i in 0..12) {
            let angle = Float32(i * 30 - 90)
            let rad = angle * Float32(3.14159265) / 180.0
            let innerR = Float32(radius - 15)
            let outerR = Float32(radius - 5)
            let x1 = Float32(cx) + innerR * cos(rad)
            let y1 = Float32(cy) + innerR * sin(rad)
            let x2 = Float32(cx) + outerR * cos(rad)
            let y2 = Float32(cy) + outerR * sin(rad)
            painter.drawLine(Int32(x1), Int32(y1), Int32(x2), Int32(y2))
        }
        
        // 60个分钟刻度
        tickPen.setWidth(1)
        painter.setPen(tickPen)
        for (i in 0..60) {
            if (i % 5 != 0) {  // 跳过小时刻度位置
                let angle = Float32(i * 6 - 90)
                let rad = angle * Float32(3.14159265) / 180.0
                let innerR = Float32(radius - 10)
                let outerR = Float32(radius - 5)
                let x1 = Float32(cx) + innerR * cos(rad)
                let y1 = Float32(cy) + innerR * sin(rad)
                let x2 = Float32(cx) + outerR * cos(rad)
                let y2 = Float32(cy) + outerR * sin(rad)
                painter.drawLine(Int32(x1), Int32(y1), Int32(x2), Int32(y2))
            }
        }
    }
    
    // 绘制数字
    drawNumbers(painter, cx, cy, radius)
}

// 绘制小时数字
func drawNumbers(painter: QPainter, cx: Int32, cy: Int32, radius: Int32): Unit {
    let font = QFont("Arial", 14)
    font.setBold(true)
    painter.setFont(font)
    
    if (let Some(tickColor) <- gTickColor) {
        painter.setPenColor(tickColor)
    }
    
    for (i in 1..13) {
        let angle = Float32(i * 30 - 90)
        let rad = angle * Float32(3.14159265) / 180.0
        let textR = Float32(radius - 35)
        let x = Float32(cx) + textR * cos(rad)
        let y = Float32(cy) + textR * sin(rad)
        
        let numStr = "${i}"
        painter.drawTextRect(Int32(x) - 10, Int32(y) - 10, 20, 20, TextFlag.AlignCenter, numStr)
    }
}

// 绘制指针
func drawHand(painter: QPainter, hour: Int32, minute: Int32, second: Int32): Unit {
    let cx = CENTER_X
    let cy = CENTER_Y
    let radius = CLOCK_SIZE / 2
    
    // 时针角度: (hour * 30) + (minute * 0.5) - 90
    let hourAngle = Float32(hour * 30 + minute / 2 - 90)
    drawSingleHand(painter, hourAngle, radius - 80, 6, gHourHandColor)
    
    // 分针角度: (minute * 6) + (second * 0.1) - 90
    let minuteAngle = Float32(minute * 6 + second / 10 - 90)
    drawSingleHand(painter, minuteAngle, radius - 50, 4, gMinuteHandColor)
    
    // 秒针角度: second * 6 - 90
    let secondAngle = Float32(second * 6 - 90)
    drawSingleHand(painter, secondAngle, radius - 30, 2, gSecondHandColor)
}

// 绘制单个指针
func drawSingleHand(painter: QPainter, angle: Float32, length: Int32, width: Int32, color: ?QColor): Unit {
    if (let Some(c) <- color) {
        let pen = QPen(c)
        pen.setWidth(width)
        painter.setPen(pen)
    }
    
    let rad = angle * Float32(3.14159265) / 180.0
    let x = Float32(CENTER_X) + Float32(length) * cos(rad)
    let y = Float32(CENTER_Y) + Float32(length) * sin(rad)
    
    painter.drawLine(CENTER_X, CENTER_Y, Int32(x), Int32(y))
}

// 绘制中心点
func drawCenter(painter: QPainter): Unit {
    if (let Some(c) <- gSecondHandColor) {
        let brush = QBrush(c)
        painter.setBrush(brush)
    }
    painter.drawCircle(CENTER_X, CENTER_Y, 8)
}

// 定时器回调 - 每秒更新
let onTimerCallback: VoidCallback = { =>
    if (let Some(w) <- gWidget) {
        w.update()
    }
}

// ============================================================
// 主函数
// ============================================================
main(): Int32 {
    let app = QApplication()
    
    // 初始化颜色
    gHourHandColor = QColor(30, 30, 30)       // 深灰色时针
    gMinuteHandColor = QColor(60, 60, 60)     // 灰色分针
    gSecondHandColor = QColor(200, 50, 50)    // 红色秒针
    gTickColor = QColor(50, 50, 50)           // 深灰色刻度
    gFaceColor = QColor(255, 255, 255)        // 白色表盘
    gBorderColor = QColor(40, 40, 40)         // 深灰色边框
    
    // 创建窗口
    let widget = QEventWidget()
    widget.setTitle("模拟时钟")
    widget.resize(400, 450)
    gWidget = widget
    
    // 设置绘制回调
    widget.setOnPaint(onPaintCallback)
    
    // 创建定时器 - 每秒刷新
    let timer = QTimer()
    timer.setInterval(1000)  // 1000毫秒 = 1秒
    timer.setOnTimeout(onTimerCallback)
    timer.start()
    gTimer = timer
    
    // 显示窗口
    widget.show()
    
    let result = app.exec()
    
    // 清理资源
    if (let Some(t) <- gTimer) {
        t.stop()
        t.delete()
    }
    if (let Some(w) <- gWidget) {
        w.delete()
    }
    
    return result
}