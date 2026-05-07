// ============================================================
// 贪吃蛇游戏 - CJQT6 示例
// ============================================================

package snake_game

import cjqt6.core.*
import cjqt6.paint.*
import cjqt6.widgets.*
import std.random.*
import std.collection.*

// ============================================================
// 游戏常量
// ============================================================
let CELL_SIZE: Int32 = 20
let GRID_WIDTH: Int32 = 30
let GRID_HEIGHT: Int32 = 25
let WINDOW_WIDTH: Int32 = CELL_SIZE * GRID_WIDTH
let WINDOW_HEIGHT: Int32 = CELL_SIZE * GRID_HEIGHT + 50
let GAME_SPEED: Int32 = 100

// ============================================================
// 方向常量
// ============================================================
let DIR_UP: Int32 = 0
let DIR_DOWN: Int32 = 1
let DIR_LEFT: Int32 = 2
let DIR_RIGHT: Int32 = 3
let ALIGN_CENTER: Int32 = 0x0084  // TextAlignment.Center.value

// ============================================================
// 全局状态
// ============================================================
var gApp: ?QApplication = None
var gWidget: ?QEventWidget = None
var gTimer: ?QTimer = None
var gRenderer: ?SnakeRenderer = None
var gRandom: Random = Random()

// 游戏状态
var gSnake: ArrayList<(Int32, Int32)> = ArrayList<(Int32, Int32)>()
var gDirection: Int32 = DIR_RIGHT
var gNextDirection: Int32 = DIR_RIGHT
var gFood: (Int32, Int32) = (10, 10)
var gScore: Int32 = 0
var gHighScore: Int32 = 0
var gGameOver: Bool = false
var gPaused: Bool = false
var gGameStarted: Bool = false

// ============================================================
// 游戏逻辑函数
// ============================================================
func initGame(): Unit {
    gSnake.clear()
    gSnake.add((5, 12))
    gSnake.add((4, 12))
    gSnake.add((3, 12))
    
    gDirection = DIR_RIGHT
    gNextDirection = DIR_RIGHT
    gScore = 0
    gGameOver = false
    gPaused = false
    gGameStarted = true
    
    spawnFood()
}

func spawnFood(): Unit {
    var validPosition = false
    var attempts = 0
    
    while (!validPosition && attempts < 100) {
        let randX = gRandom.nextUInt64()
        let randY = gRandom.nextUInt64()
        let x = Int32(randX % UInt64(GRID_WIDTH))
        let y = Int32(randY % UInt64(GRID_HEIGHT))
        
        validPosition = true
        for (segment in gSnake) {
            let (sx, sy) = segment
            if (sx == x && sy == y) {
                validPosition = false
                break
            }
        }
        
        if (validPosition) {
            gFood = (x, y)
        }
        attempts++
    }
}

func updateGame(): Unit {
    if (gGameOver || gPaused || !gGameStarted) {
        return
    }
    
    gDirection = gNextDirection
    
    let (headX, headY) = gSnake[0]
    var newX = headX
    var newY = headY
    
    match (gDirection) {
        case 0 => newY = headY - 1
        case 1 => newY = headY + 1
        case 2 => newX = headX - 1
        case 3 => newX = headX + 1
        case _ => ()
    }
    
    if (newX < 0 || newX >= GRID_WIDTH || newY < 0 || newY >= GRID_HEIGHT) {
        gGameOver = true
        if (gScore > gHighScore) {
            gHighScore = gScore
        }
        return
    }
    
    for (segment in gSnake) {
        let (sx, sy) = segment
        if (sx == newX && sy == newY) {
            gGameOver = true
            if (gScore > gHighScore) {
                gHighScore = gScore
            }
            return
        }
    }
    
    gSnake.add((newX, newY))  // 添加到头部
    gSnake = reverseList(gSnake)  // 反转使新元素在头部
    
    let (foodX, foodY) = gFood
    if (newX == foodX && newY == foodY) {
        gScore += 10
        spawnFood()
    } else {
        // 没吃到食物，移除尾部（反转后的第一个元素）
        if (gSnake.size > 0) {
            gSnake = removeLast(gSnake)
        }
    }
}

// 反转列表
func reverseList(list: ArrayList<(Int32, Int32)>): ArrayList<(Int32, Int32)> {
    let result = ArrayList<(Int32, Int32)>()
    for (i in list.size - 1..=0) {
        result.add(list[i])
    }
    return result
}

// 移除最后一个元素
func removeLast(list: ArrayList<(Int32, Int32)>): ArrayList<(Int32, Int32)> {
    let result = ArrayList<(Int32, Int32)>()
    for (i in 1..list.size) {
        result.add(list[i])
    }
    return result
}

// ============================================================
// 回调函数
// ============================================================
func onKeyPress(key: Int32, modifiers: Int32, unicode: Int32): Unit {
    if (!gGameStarted || gGameOver) {
        if (key == Key.space() || key == Key.enter() || key == 13) {
            initGame()
        }
        return
    }
    
    if (key == Key.p() || key == 80) {
        gPaused = !gPaused
        return
    }
    
    if (key == Key.space() || key == 32) {
        gPaused = !gPaused
        return
    }
    
    if ((key == Key.up() || key == Key.w() || key == 87) && gDirection != DIR_DOWN) {
        gNextDirection = DIR_UP
    } else if ((key == Key.down() || key == Key.s() || key == 83) && gDirection != DIR_UP) {
        gNextDirection = DIR_DOWN
    } else if ((key == Key.left() || key == Key.a() || key == 65) && gDirection != DIR_RIGHT) {
        gNextDirection = DIR_LEFT
    } else if ((key == Key.right() || key == Key.d() || key == 68) && gDirection != DIR_LEFT) {
        gNextDirection = DIR_RIGHT
    }
}

func onTimer(): Unit {
    updateGame()
    if (let Some(w) <- gWidget) {
        w.update()
    }
}

func onPaint(painterPtr: Int64): Unit {
    if (let Some(r) <- gRenderer) {
        r.render(painterPtr)
    }
}

// ============================================================
// 游戏渲染器
// ============================================================
public class SnakeRenderer {
    private let pen: QPen
    private let brush: QBrush
    private let colorBackground: QColor
    private let colorGrid: QColor
    private let colorSnakeHead: QColor
    private let colorSnakeBody: QColor
    private let colorFood: QColor
    private let colorStatusBar: QColor
    private let colorText: QColor
    private let colorGameOver: QColor
    private let fontSmall: QFont
    private let fontLarge: QFont
    
    public init() {
        pen = QPen()
        brush = QBrush()
        colorBackground = QColor(20, 20, 30)
        colorGrid = QColor(40, 40, 50)
        colorSnakeHead = QColor(50, 205, 50)
        colorSnakeBody = QColor(34, 139, 34)
        colorFood = QColor(255, 69, 0)
        colorStatusBar = QColor(30, 30, 40)
        colorText = Colors.white()
        colorGameOver = QColor(220, 20, 60)
        fontSmall = QFont("Arial", 14)
        fontLarge = QFont("Arial", 28)
    }
    
    public func cleanup(): Unit {
        pen.delete()
        brush.delete()
        colorBackground.delete()
        colorGrid.delete()
        colorSnakeHead.delete()
        colorSnakeBody.delete()
        colorFood.delete()
        colorStatusBar.delete()
        colorText.delete()
        colorGameOver.delete()
        fontSmall.delete()
        fontLarge.delete()
    }
    
    public func render(painterPtr: Int64): Unit {
        let painter = QPainter.fromPtr(painterPtr)
        painter.setRenderHint(RenderHint.Antialiasing.value())
        
        painter.fillRectColor(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, colorBackground)
        renderGrid(painter)
        renderFood(painter)
        renderSnake(painter)
        renderStatusBar(painter)
        
        if (!gGameStarted) {
            renderStartScreen(painter)
        } else if (gGameOver) {
            renderGameOver(painter)
        } else if (gPaused) {
            renderPaused(painter)
        }
    }
    
    private func renderGrid(painter: QPainter): Unit {
        pen.setColor(colorGrid)
        pen.setWidth(1)
        painter.setPen(pen)
        
        for (x in 0..=GRID_WIDTH) {
            let px = x * CELL_SIZE
            painter.drawLine(px, 0, px, GRID_HEIGHT * CELL_SIZE)
        }
        
        for (y in 0..=GRID_HEIGHT) {
            let py = y * CELL_SIZE
            painter.drawLine(0, py, GRID_WIDTH * CELL_SIZE, py)
        }
    }
    
    private func renderSnake(painter: QPainter): Unit {
        var isFirst = true
        for (segment in gSnake) {
            let (x, y) = segment
            let px = x * CELL_SIZE
            let py = y * CELL_SIZE
            
            if (isFirst) {
                brush.setColor(colorSnakeHead)
                isFirst = false
            } else {
                brush.setColor(colorSnakeBody)
            }
            
            painter.setBrush(brush)
            pen.setColor(Colors.black())
            pen.setWidth(1)
            painter.setPen(pen)
            painter.drawRect(px + 1, py + 1, CELL_SIZE - 2, CELL_SIZE - 2)
        }
    }
    
    private func renderFood(painter: QPainter): Unit {
        let (x, y) = gFood
        let px = x * CELL_SIZE
        let py = y * CELL_SIZE
        
        brush.setColor(colorFood)
        painter.setBrush(brush)
        pen.setColor(Colors.black())
        pen.setWidth(1)
        painter.setPen(pen)
        painter.drawEllipse(px + 2, py + 2, CELL_SIZE - 4, CELL_SIZE - 4)
    }
    
    private func renderStatusBar(painter: QPainter): Unit {
        let barY = GRID_HEIGHT * CELL_SIZE
        
        painter.fillRectColor(0, barY, WINDOW_WIDTH, 50, colorStatusBar)
        
        painter.setFont(fontSmall)
        pen.setColor(colorText)
        painter.setPen(pen)
        
        painter.drawText(10, barY + 30, "分数: ${gScore}")
        painter.drawText(WINDOW_WIDTH / 2 - 50, barY + 30, "最高分: ${gHighScore}")
        
        let length = Int32(gSnake.size)
        painter.drawText(WINDOW_WIDTH - 100, barY + 30, "长度: ${length}")
    }
    
    private func renderStartScreen(painter: QPainter): Unit {
        painter.setOpacity(0.7f32)
        painter.fillRectColor(0, 0, WINDOW_WIDTH, GRID_HEIGHT * CELL_SIZE, Colors.black())
        painter.setOpacity(1.0f32)
        
        painter.setFont(fontLarge)
        pen.setColor(colorSnakeHead)
        painter.setPen(pen)
        painter.drawTextRect(0, GRID_HEIGHT * CELL_SIZE / 2 - 60, WINDOW_WIDTH, 50, ALIGN_CENTER, "贪吃蛇")
        
        painter.setFont(fontSmall)
        pen.setColor(colorText)
        painter.setPen(pen)
        painter.drawTextRect(0, GRID_HEIGHT * CELL_SIZE / 2, WINDOW_WIDTH, 30, ALIGN_CENTER, "按 空格 或 回车 开始游戏")
        painter.drawTextRect(0, GRID_HEIGHT * CELL_SIZE / 2 + 30, WINDOW_WIDTH, 30, ALIGN_CENTER, "方向键 或 WASD 控制方向")
        painter.drawTextRect(0, GRID_HEIGHT * CELL_SIZE / 2 + 60, WINDOW_WIDTH, 30, ALIGN_CENTER, "P 或 空格 暂停游戏")
    }
    
    private func renderGameOver(painter: QPainter): Unit {
        painter.setOpacity(0.7f32)
        painter.fillRectColor(0, 0, WINDOW_WIDTH, GRID_HEIGHT * CELL_SIZE, Colors.black())
        painter.setOpacity(1.0f32)
        
        painter.setFont(fontLarge)
        pen.setColor(colorGameOver)
        painter.setPen(pen)
        painter.drawTextRect(0, GRID_HEIGHT * CELL_SIZE / 2 - 50, WINDOW_WIDTH, 50, ALIGN_CENTER, "游戏结束")
        
        painter.setFont(fontSmall)
        pen.setColor(colorText)
        painter.setPen(pen)
        painter.drawTextRect(0, GRID_HEIGHT * CELL_SIZE / 2, WINDOW_WIDTH, 30, ALIGN_CENTER, "最终分数: ${gScore}")
        
        if (gScore == gHighScore && gScore > 0) {
            pen.setColor(colorFood)
            painter.setPen(pen)
            painter.drawTextRect(0, GRID_HEIGHT * CELL_SIZE / 2 + 30, WINDOW_WIDTH, 30, ALIGN_CENTER, "新纪录!")
        }
        
        pen.setColor(colorText)
        painter.setPen(pen)
        painter.drawTextRect(0, GRID_HEIGHT * CELL_SIZE / 2 + 60, WINDOW_WIDTH, 30, ALIGN_CENTER, "按 空格 重新开始")
    }
    
    private func renderPaused(painter: QPainter): Unit {
        painter.setOpacity(0.7f32)
        painter.fillRectColor(0, 0, WINDOW_WIDTH, GRID_HEIGHT * CELL_SIZE, Colors.black())
        painter.setOpacity(1.0f32)
        
        painter.setFont(fontLarge)
        pen.setColor(colorText)
        painter.setPen(pen)
        painter.drawTextRect(0, GRID_HEIGHT * CELL_SIZE / 2 - 25, WINDOW_WIDTH, 50, ALIGN_CENTER, "已暂停")
        
        painter.setFont(fontSmall)
        painter.drawTextRect(0, GRID_HEIGHT * CELL_SIZE / 2 + 30, WINDOW_WIDTH, 30, ALIGN_CENTER, "按 空格 或 P 继续")
    }
}

// ============================================================
// 主函数
// ============================================================
main(): Int32 {
    gApp = QApplication()
    gWidget = QEventWidget()
    gTimer = QTimer()
    gRenderer = SnakeRenderer()
    
    if (let Some(w) <- gWidget) {
        w.resize(WINDOW_WIDTH, WINDOW_HEIGHT)
        w.setTitle("贪吃蛇 - CJQT6")
        w.setOnKeyPress({ key, modifiers, unicode => onKeyPress(key, modifiers, unicode) })
        w.setOnPaint({ painterPtr => onPaint(painterPtr) })
        w.show()
    }
    
    if (let Some(t) <- gTimer) {
        t.setInterval(GAME_SPEED)
        t.setOnTimeout({ => onTimer() })
        t.start()
    }
    
    var result: Int32 = 0
    if (let Some(a) <- gApp) {
        result = a.exec()
    }
    
    // 清理资源
    if (let Some(t) <- gTimer) {
        t.stop()
        t.delete()
    }
    if (let Some(r) <- gRenderer) {
        r.cleanup()
    }
    if (let Some(w) <- gWidget) {
        w.delete()
    }
    
    return result
}