package paint_app

import cjqt6.core.*
import cjqt6.paint.*
import cjqt6.widgets.*
import cjqt6.gui.*

// ============================================================
// 全局状态
// ============================================================
var gWidget: ?QEventWidget = None
var gCanvas: ?QPixmap = None
var gPainter: ?QPainter = None

var gPenColor: ?QColor = None
var gPenWidth: Int32 = 3
var gLastX: Int32 = -1
var gLastY: Int32 = -1
var gDrawing: Bool = false

// 画布尺寸
let CANVAS_WIDTH: Int32 = 600
let CANVAS_HEIGHT: Int32 = 400

// 工具栏高度偏移（窗口顶部工具栏占用的空间）
let TOOLBAR_OFFSET_Y: Int32 = 50

// 颜色按钮引用
var gColorDisplay: ?QLabel = None
var gWidthLabel: ?QLabel = None

// ============================================================
// 鼠标事件回调
// ============================================================

let onMousePress: CFunc<(Int32, Int32, Int32) -> Unit> = { button: Int32, x: Int32, y: Int32 =>
    if (button == MouseButton.left()) {
        gDrawing = true
        gLastX = x
        gLastY = y - TOOLBAR_OFFSET_Y  // 减去工具栏偏移
    }
}

let onMouseMove: CFunc<(Int32, Int32, Int32) -> Unit> = { buttons: Int32, x: Int32, y: Int32 =>
    if (gDrawing && (buttons & MouseButton.left()) != 0) {
        let adjustedY = y - TOOLBAR_OFFSET_Y  // 减去工具栏偏移
        drawLine(gLastX, gLastY, x, adjustedY)
        gLastX = x
        gLastY = adjustedY
        requestUpdate()
    }
}

let onMouseRelease: CFunc<(Int32, Int32, Int32) -> Unit> = { button: Int32, x: Int32, y: Int32 =>
    if (button == MouseButton.left()) {
        gDrawing = false
        gLastX = -1
        gLastY = -1
    }
}

// ============================================================
// 绘制函数
// ============================================================

func drawLine(x1: Int32, y1: Int32, x2: Int32, y2: Int32): Unit {
    if (let Some(painter) <- gPainter) {
        if (let Some(color) <- gPenColor) {
            let pen = QPen(color)
            pen.setWidth(gPenWidth)
            painter.setPen(pen)
        }
        painter.drawLine(x1, y1, x2, y2)
    }
}

func requestUpdate(): Unit {
    if (let Some(w) <- gWidget) {
        w.update()
    }
}

// 绘制回调
let onPaintCallback: CFunc<(Int64) -> Unit> = { painterPtr: Int64 =>
    let painter = QPainter.fromPtr(painterPtr)
    
    // 将画布绘制到窗口
    if (let Some(canvas) <- gCanvas) {
        painter.drawPixmap(0, 50, canvas)
    }
}

// ============================================================
// 工具按钮回调
// ============================================================

let onClearClick: VoidCallback = { =>
    if (let Some(canvas) <- gCanvas) {
        canvas.fill(Colors.white())
        requestUpdate()
    }
}

// 增加画笔宽度
let onIncWidthClick: VoidCallback = { =>
    if (gPenWidth < 20) {
        gPenWidth = gPenWidth + 1
        updateWidthLabel()
    }
}

// 减少画笔宽度
let onDecWidthClick: VoidCallback = { =>
    if (gPenWidth > 1) {
        gPenWidth = gPenWidth - 1
        updateWidthLabel()
    }
}

func updateColorDisplay(): Unit {
    // 由于 QLabel 没有 setStyleSheet，使用文本显示当前颜色
    if (let Some(label) <- gColorDisplay) {
        if (let Some(color) <- gPenColor) {
            label.setText("(${color.red()},${color.green()},${color.blue()})")
        }
    }
}

func updateWidthLabel(): Unit {
    if (let Some(label) <- gWidthLabel) {
        label.setText("粗细: ${gPenWidth}")
    }
}

// ============================================================
// 辅助函数
// ============================================================

func createColorButton(r: Int32, g: Int32, b: Int32, text: String): QPushButton {
    let btn = QPushButton()
    btn.setText(text)
    btn.setStyleSheet("background-color: rgb(${r}, ${g}, ${b}); color: white; min-width: 40px;")
    btn
}

func label(text: String): QLabel {
    let l = QLabel()
    l.setText(text)
    l
}

// ============================================================
// 颜色按钮回调（全局变量）
// ============================================================
let onBlackClick: VoidCallback = { => gPenColor = QColor(0, 0, 0); updateColorDisplay() }
let onRedClick: VoidCallback = { => gPenColor = QColor(255, 0, 0); updateColorDisplay() }
let onGreenClick: VoidCallback = { => gPenColor = QColor(0, 180, 0); updateColorDisplay() }
let onBlueClick: VoidCallback = { => gPenColor = QColor(0, 0, 255); updateColorDisplay() }
let onYellowClick: VoidCallback = { => gPenColor = QColor(255, 200, 0); updateColorDisplay() }
let onPurpleClick: VoidCallback = { => gPenColor = QColor(180, 0, 180); updateColorDisplay() }
let onOrangeClick: VoidCallback = { => gPenColor = QColor(255, 128, 0); updateColorDisplay() }
let onGrayClick: VoidCallback = { => gPenColor = QColor(128, 128, 128); updateColorDisplay() }

// ============================================================
// 主函数
// ============================================================
main(): Int32 {
    let app = QApplication()
    
    // 初始化画笔颜色
    gPenColor = QColor(0, 0, 0)
    
    // 创建画布
    let canvas = QPixmap.withSize(CANVAS_WIDTH, CANVAS_HEIGHT)
    canvas.fill(Colors.white())
    gCanvas = canvas
    
    // 创建画家
    let painter = QPainter(canvas.getPtr())
    gPainter = painter
    
    // 创建窗口
    let widget = QEventWidget()
    widget.setTitle("画图板")
    widget.resize(CANVAS_WIDTH + 20, CANVAS_HEIGHT + 100)
    gWidget = widget
    
    // 创建主布局
    let mainLayout = QVBoxLayout()
    mainLayout.setMargin(10)
    mainLayout.setSpacing(5)
    
    // ========== 工具栏 ==========
    let toolbarLayout = QHBoxLayout()
    toolbarLayout.setSpacing(5)
    
    // 颜色选择
    toolbarLayout.addWidget(label("颜色:").getPtr())
    
    let blackBtn = createColorButton(0, 0, 0, "黑")
    blackBtn.setOnClick(onBlackClick)
    toolbarLayout.addWidget(blackBtn.getPtr())
    
    let redBtn = createColorButton(255, 0, 0, "红")
    redBtn.setOnClick(onRedClick)
    toolbarLayout.addWidget(redBtn.getPtr())
    
    let greenBtn = createColorButton(0, 180, 0, "绿")
    greenBtn.setOnClick(onGreenClick)
    toolbarLayout.addWidget(greenBtn.getPtr())
    
    let blueBtn = createColorButton(0, 0, 255, "蓝")
    blueBtn.setOnClick(onBlueClick)
    toolbarLayout.addWidget(blueBtn.getPtr())
    
    let yellowBtn = createColorButton(255, 200, 0, "黄")
    yellowBtn.setOnClick(onYellowClick)
    toolbarLayout.addWidget(yellowBtn.getPtr())
    
    let purpleBtn = createColorButton(180, 0, 180, "紫")
    purpleBtn.setOnClick(onPurpleClick)
    toolbarLayout.addWidget(purpleBtn.getPtr())
    
    let orangeBtn = createColorButton(255, 128, 0, "橙")
    orangeBtn.setOnClick(onOrangeClick)
    toolbarLayout.addWidget(orangeBtn.getPtr())
    
    let grayBtn = createColorButton(128, 128, 128, "灰")
    grayBtn.setOnClick(onGrayClick)
    toolbarLayout.addWidget(grayBtn.getPtr())
    
    // 当前颜色显示
    let colorDisplay = QLabel()
    colorDisplay.setText("(0,0,0)")
    gColorDisplay = colorDisplay
    toolbarLayout.addWidget(colorDisplay.getPtr())
    
    toolbarLayout.addStretch()
    
    // 画笔粗细
    toolbarLayout.addWidget(label("  ").getPtr())
    
    let decWidthBtn = QPushButton()
    decWidthBtn.setText("-")
    decWidthBtn.setOnClick(onDecWidthClick)
    toolbarLayout.addWidget(decWidthBtn.getPtr())
    
    let widthLabel = QLabel()
    widthLabel.setText("粗细: 3")
    gWidthLabel = widthLabel
    toolbarLayout.addWidget(widthLabel.getPtr())
    
    let incWidthBtn = QPushButton()
    incWidthBtn.setText("+")
    incWidthBtn.setOnClick(onIncWidthClick)
    toolbarLayout.addWidget(incWidthBtn.getPtr())
    
    // 清除按钮
    toolbarLayout.addWidget(label("  ").getPtr())
    let clearBtn = QPushButton()
    clearBtn.setText("清除")
    clearBtn.setOnClick(onClearClick)
    clearBtn.setStyleSheet("background-color: #e74c3c; color: white;")
    toolbarLayout.addWidget(clearBtn.getPtr())
    
    mainLayout.addLayout(toolbarLayout.getPtr())
    
    // ========== 画布区域 ==========
    widget.setOnPaint(onPaintCallback)
    widget.setOnMousePress(onMousePress)
    widget.setOnMouseMove(onMouseMove)
    widget.setOnMouseRelease(onMouseRelease)
    
    widget.show()
    
    let result = app.exec()
    
    // 清理
    if (let Some(p) <- gPainter) {
        p.end()
    }
    if (let Some(c) <- gCanvas) {
        c.delete()
    }
    if (let Some(w) <- gWidget) {
        w.delete()
    }
    
    return result
}