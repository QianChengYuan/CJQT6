// ============================================================
// 坦克大战 - CJQT6 游戏示例
// ============================================================

package tank_battle

import CJQT6.core.*
import CJQT6.paint.*
import CJQT6.gui.*
import CJQT6.widgets.*
import CJQT6.multimedia.*
import std.random.*
import std.collection.*

// ============================================================
// 游戏常量
// ============================================================
let TILE_SIZE: Int64 = 32
let MAP_WIDTH: Int64 = 26
let MAP_HEIGHT: Int64 = 26
let WINDOW_WIDTH: Int32 = 832
let WINDOW_HEIGHT: Int32 = 892
let BULLET_SPEED: Int32 = 8
let TANK_SPEED: Int32 = 2
let ENEMY_COUNT: Int64 = 3

// ============================================================
// 全局状态
// ============================================================
var gPlayerX: Int32 = 288
var gPlayerY: Int32 = 768
var gPlayerDir: Int32 = 0  // 0=Up, 1=Down, 2=Left, 3=Right
var gPlayerLives: Int32 = 3
var gPlayerAlive: Bool = true
var gPlayerCooldown: Int32 = 0

var gEnemies: ArrayList<(Int32, Int32, Int32, Bool, Int32)> = ArrayList<(Int32, Int32, Int32, Bool, Int32)>()  // (x, y, dir, alive, cooldown)
var gBullets: ArrayList<(Int32, Int32, Int32, Bool, Bool)> = ArrayList<(Int32, Int32, Int32, Bool, Bool)>()  // (x, y, dir, active, isPlayer)
var gExplosions: ArrayList<(Int32, Int32, Int32, Bool)> = ArrayList<(Int32, Int32, Int32, Bool)>()  // (x, y, frame, active)
var gMap: Array<Array<Int32>> = []  // 0=Empty, 1=Brick, 2=Steel, 3=Water, 4=Grass, 5=Base

var gScore: Int32 = 0
var gLevel: Int32 = 1
var gGameOver: Bool = false
var gPaused: Bool = false
var gBaseDestroyed: Bool = false
var gEnemySpawnTimer: Int32 = 0
var gTotalEnemies: Int32 = 10
var gSpawnedEnemies: Int32 = 0

var gKeyState: Array<Bool> = [false, false, false, false, false]  // up, down, left, right, fire

var gApp: ?QApplication = None
var gWidget: ?QEventWidget = None
var gTimer: ?QTimer = None
var gRenderer: ?GameRenderer = None
var gRandom: Random = Random()

// ============================================================
// 方向常量
// ============================================================
let DIR_UP: Int32 = 0
let DIR_DOWN: Int32 = 1
let DIR_LEFT: Int32 = 2
let DIR_RIGHT: Int32 = 3

// ============================================================
// 地图元素常量
// ============================================================
let TILE_EMPTY: Int32 = 0
let TILE_BRICK: Int32 = 1
let TILE_STEEL: Int32 = 2
let TILE_WATER: Int32 = 3
let TILE_GRASS: Int32 = 4
let TILE_BASE: Int32 = 5

// ============================================================
// 辅助函数
// ============================================================
func initMap(): Unit {
    gMap = Array<Array<Int32>>(MAP_HEIGHT, { i => 
        Array<Int32>(MAP_WIDTH, { j => TILE_EMPTY })
    })
    
    // 基地周围的砖墙
    setTile(11, 23, TILE_BRICK)
    setTile(12, 23, TILE_BRICK)
    setTile(13, 23, TILE_BRICK)
    setTile(11, 24, TILE_BRICK)
    setTile(13, 24, TILE_BRICK)
    setTile(12, 24, TILE_BASE)
    
    // 障碍物
    addTiles(3, 5, 4, 2, TILE_BRICK)
    addTiles(18, 5, 4, 2, TILE_BRICK)
    addTiles(8, 8, 2, 4, TILE_BRICK)
    addTiles(15, 8, 2, 4, TILE_BRICK)
    addTiles(11, 10, 3, 1, TILE_STEEL)
    addTiles(3, 14, 2, 3, TILE_BRICK)
    addTiles(20, 14, 2, 3, TILE_BRICK)
    addTiles(6, 18, 3, 2, TILE_WATER)
    addTiles(16, 18, 3, 2, TILE_WATER)
    addTiles(10, 16, 5, 2, TILE_BRICK)
    addTiles(4, 10, 3, 3, TILE_GRASS)
    addTiles(18, 10, 3, 3, TILE_GRASS)
}

func setTile(x: Int64, y: Int64, tile: Int32): Unit {
    if (x >= 0 && x < MAP_WIDTH && y >= 0 && y < MAP_HEIGHT) {
        gMap[y][x] = tile
    }
}

func addTiles(startX: Int64, startY: Int64, width: Int64, height: Int64, tile: Int32): Unit {
    for (y in startY..startY + height) {
        for (x in startX..startX + width) {
            setTile(x, y, tile)
        }
    }
}

func resetGame(): Unit {
    gPlayerX = 288
    gPlayerY = 768
    gPlayerDir = DIR_UP
    gPlayerLives = 3
    gPlayerAlive = true
    gPlayerCooldown = 0
    
    gEnemies.clear()
    gBullets.clear()
    gExplosions.clear()
    
    gScore = 0
    gLevel = 1
    gGameOver = false
    gPaused = false
    gBaseDestroyed = false
    gEnemySpawnTimer = 0
    gTotalEnemies = 10
    gSpawnedEnemies = 0
    
    for (i in 0..5) {
        gKeyState[i] = false
    }
    
    initMap()
}

// ============================================================
// 游戏更新函数
// ============================================================
func updateGame(): Unit {
    if (gPaused || gGameOver) {
        return
    }
    
    updatePlayer()
    updateEnemies()
    spawnEnemies()
    updateBullets()
    updateExplosions()
    checkGameState()
}

func updatePlayer(): Unit {
    if (!gPlayerAlive) { return }
    
    let ts = Int32(TILE_SIZE)
    
    if (gKeyState[0]) {  // Up
        gPlayerDir = DIR_UP
        let newY = gPlayerY - TANK_SPEED
        if (newY >= 0 && !checkTankCollision(gPlayerX, newY)) {
            gPlayerY = newY
        }
    } else if (gKeyState[1]) {  // Down
        gPlayerDir = DIR_DOWN
        let newY = gPlayerY + TANK_SPEED
        if (newY <= WINDOW_HEIGHT - ts - 60 && !checkTankCollision(gPlayerX, newY)) {
            gPlayerY = newY
        }
    } else if (gKeyState[2]) {  // Left
        gPlayerDir = DIR_LEFT
        let newX = gPlayerX - TANK_SPEED
        if (newX >= 0 && !checkTankCollision(newX, gPlayerY)) {
            gPlayerX = newX
        }
    } else if (gKeyState[3]) {  // Right
        gPlayerDir = DIR_RIGHT
        let newX = gPlayerX + TANK_SPEED
        if (newX <= WINDOW_WIDTH - ts && !checkTankCollision(newX, gPlayerY)) {
            gPlayerX = newX
        }
    }
    
    if (gKeyState[4] && gPlayerCooldown <= 0) {  // Fire
        fireBullet(gPlayerX + ts / 2, gPlayerY + ts / 2, gPlayerDir, true)
        gPlayerCooldown = 20
    }
    
    if (gPlayerCooldown > 0) {
        gPlayerCooldown--
    }
}

func checkTankCollision(x: Int32, y: Int32): Bool {
    let ts = Int32(TILE_SIZE)
    let tx1 = Int64(x / ts)
    let ty1 = Int64(y / ts)
    let tx2 = Int64((x + ts - 1) / ts)
    let ty2 = Int64((y + ts - 1) / ts)
    
    for (ty in ty1..ty2 + 1) {
        for (tx in tx1..tx2 + 1) {
            if (tx >= 0 && tx < MAP_WIDTH && ty >= 0 && ty < MAP_HEIGHT) {
                let tile = gMap[ty][tx]
                if (tile == TILE_BRICK || tile == TILE_STEEL || tile == TILE_WATER || tile == TILE_BASE) {
                    return true
                }
            }
        }
    }
    return false
}

func fireBullet(x: Int32, y: Int32, dir: Int32, isPlayer: Bool): Unit {
    let ts = Int32(TILE_SIZE)
    var bx = x
    var by = y
    
    match (dir) {
        case 0 => by = y - 4  // Up
        case 1 => by = y + ts + 4  // Down
        case 2 => bx = x - 4  // Left
        case 3 => bx = x + ts + 4  // Right
        case _ => ()
    }
    
    gBullets.add((bx, by, dir, true, isPlayer))
}

func updateEnemies(): Unit {
    for (i in 0..gEnemies.size) {
        let (x, y, dir, alive, cooldown) = gEnemies[i]
        if (!alive) { continue }
        
        var newX = x
        var newY = y
        var newDir = dir
        var newCooldown = cooldown
        
        // 随机改变方向
        if (gRandom.nextUInt64() % 60 == 0) {
            newDir = Int32(gRandom.nextUInt64() % 4)
        }
        
        let ts = Int32(TILE_SIZE)
        match (newDir) {
            case 0 => newY = y - TANK_SPEED
            case 1 => newY = y + TANK_SPEED
            case 2 => newX = x - TANK_SPEED
            case 3 => newX = x + TANK_SPEED
            case _ => ()
        }
        
        // 边界检查
        if (newX >= 0 && newX <= WINDOW_WIDTH - ts && newY >= 0 && newY <= WINDOW_HEIGHT - ts - 60) {
            if (!checkTankCollision(newX, newY)) {
                gEnemies[i] = (newX, newY, newDir, true, newCooldown)
            } else {
                gEnemies[i] = (x, y, newDir, true, newCooldown)
            }
        } else {
            gEnemies[i] = (x, y, newDir, true, newCooldown)
        }
        
        // 射击
        if (newCooldown <= 0 && gRandom.nextUInt64() % 30 == 0) {
            let (cx, cy, cdir, _, _) = gEnemies[i]
            fireBullet(cx + ts / 2, cy + ts / 2, cdir, false)
            gEnemies[i] = (cx, cy, cdir, true, 20)
        }
        
        if (newCooldown > 0) {
            let (cx, cy, cdir, _, cc) = gEnemies[i]
            gEnemies[i] = (cx, cy, cdir, true, cc - 1)
        }
    }
}

func spawnEnemies(): Unit {
    if (gEnemies.size < ENEMY_COUNT && Int64(gSpawnedEnemies) < Int64(gTotalEnemies)) {
        gEnemySpawnTimer++
        if (gEnemySpawnTimer >= 120) {
            gEnemySpawnTimer = 0
            let idx = Int32(gRandom.nextUInt64() % 3)
            let spawnX: Int32 = if (idx == 0) { 0 } else if (idx == 1) { 384 } else { 768 }
            gEnemies.add((spawnX, 0, DIR_DOWN, true, 0))
            gSpawnedEnemies++
        }
    }
}

func updateBullets(): Unit {
    let toRemove = ArrayList<Int64>()
    
    for (i in 0..gBullets.size) {
        let (x, y, dir, active, isPlayer) = gBullets[i]
        if (!active) {
            toRemove.add(i)
            continue
        }
        
        var newX = x
        var newY = y
        match (dir) {
            case 0 => newY = y - BULLET_SPEED
            case 1 => newY = y + BULLET_SPEED
            case 2 => newX = x - BULLET_SPEED
            case 3 => newX = x + BULLET_SPEED
            case _ => ()
        }
        
        // 出界检查
        if (newX < 0 || newX > WINDOW_WIDTH || newY < 0 || newY > WINDOW_HEIGHT) {
            gBullets[i] = (newX, newY, dir, false, isPlayer)
            toRemove.add(i)
            continue
        }
        
        // 地图碰撞
        let tileX = Int64(newX / Int32(TILE_SIZE))
        let tileY = Int64(newY / Int32(TILE_SIZE))
        var bulletActive = true
        
        if (tileX >= 0 && tileX < MAP_WIDTH && tileY >= 0 && tileY < MAP_HEIGHT) {
            let tile = gMap[tileY][tileX]
            if (tile == TILE_BRICK) {
                gMap[tileY][tileX] = TILE_EMPTY
                bulletActive = false
                gExplosions.add((newX, newY, 0, true))
            } else if (tile == TILE_STEEL) {
                bulletActive = false
                gExplosions.add((newX, newY, 0, true))
            } else if (tile == TILE_BASE) {
                gMap[tileY][tileX] = TILE_EMPTY
                bulletActive = false
                gBaseDestroyed = true
                gExplosions.add((newX, newY, 0, true))
            }
        }
        
        // 坦克碰撞
        if (bulletActive) {
            let ts = Int32(TILE_SIZE)
            if (isPlayer) {
                // 检查敌人坦克
                for (j in 0..gEnemies.size) {
                    let (ex, ey, _, eAlive, _) = gEnemies[j]
                    if (!eAlive) { continue }
                    if (newX >= ex && newX <= ex + ts && newY >= ey && newY <= ey + ts) {
                        bulletActive = false
                        gEnemies[j] = (ex, ey, 0, false, 0)
                        gScore += 100
                        gExplosions.add((ex + ts / 2, ey + ts / 2, 0, true))
                    }
                }
            } else {
                // 检查玩家坦克
                if (gPlayerAlive && newX >= gPlayerX && newX <= gPlayerX + ts && newY >= gPlayerY && newY <= gPlayerY + ts) {
                    bulletActive = false
                    gPlayerLives--
                    gExplosions.add((gPlayerX + ts / 2, gPlayerY + ts / 2, 0, true))
                    if (gPlayerLives <= 0) {
                        gPlayerAlive = false
                    } else {
                        gPlayerX = 288
                        gPlayerY = 768
                        gPlayerDir = DIR_UP
                    }
                }
            }
        }
        
        gBullets[i] = (newX, newY, dir, bulletActive, isPlayer)
        if (!bulletActive) {
            toRemove.add(i)
        }
    }
    
    // 移除无效子弹（倒序删除）
    for (i in toRemove.size - 1..=0) {
        gBullets.remove(at: toRemove[i])
    }
}

func updateExplosions(): Unit {
    let toRemove = ArrayList<Int64>()
    
    for (i in 0..gExplosions.size) {
        let (x, y, frame, active) = gExplosions[i]
        if (!active) {
            toRemove.add(i)
            continue
        }
        
        let newFrame = frame + 1
        if (newFrame >= 15) {
            gExplosions[i] = (x, y, newFrame, false)
            toRemove.add(i)
        } else {
            gExplosions[i] = (x, y, newFrame, true)
        }
    }
    
    for (i in toRemove.size - 1..=0) {
        gExplosions.remove(at: toRemove[i])
    }
}

func checkGameState(): Unit {
    if (gBaseDestroyed) {
        gGameOver = true
    }
    
    if (!gPlayerAlive) {
        gGameOver = true
    }
    
    // 清除死亡的敌人
    let toRemove = ArrayList<Int64>()
    for (i in 0..gEnemies.size) {
        let (_, _, _, alive, _) = gEnemies[i]
        if (!alive) {
            toRemove.add(i)
        }
    }
    for (i in toRemove.size - 1..=0) {
        gEnemies.remove(at: toRemove[i])
    }
    
    // 检查通关
    if (gSpawnedEnemies >= gTotalEnemies && gEnemies.size == 0) {
        gLevel++
        gTotalEnemies += 5
        gSpawnedEnemies = 0
        gPlayerX = 288
        gPlayerY = 768
        initMap()
    }
}

// ============================================================
// 回调函数
// ============================================================
func onKeyPress(key: Int32, modifiers: Int32, unicode: Int32): Unit {
    if (gGameOver) {
        if (key == Key.r() || key == 82) {  // R
            resetGame()
        }
        return
    }
    
    if (key == Key.p() || key == 80) {  // P
        gPaused = !gPaused
        return
    }
    
    if (key == Key.up() || key == Key.w() || key == 87) {
        gKeyState[0] = true
    } else if (key == Key.down() || key == Key.s() || key == 83) {
        gKeyState[1] = true
    } else if (key == Key.left() || key == Key.a() || key == 65) {
        gKeyState[2] = true
    } else if (key == Key.right() || key == Key.d() || key == 68) {
        gKeyState[3] = true
    } else if (key == Key.space() || key == Key.j() || key == 74) {
        gKeyState[4] = true
    }
}

func onKeyRelease(key: Int32, modifiers: Int32, unicode: Int32): Unit {
    if (key == Key.up() || key == Key.w() || key == 87) {
        gKeyState[0] = false
    } else if (key == Key.down() || key == Key.s() || key == 83) {
        gKeyState[1] = false
    } else if (key == Key.left() || key == Key.a() || key == 65) {
        gKeyState[2] = false
    } else if (key == Key.right() || key == Key.d() || key == 68) {
        gKeyState[3] = false
    } else if (key == Key.space() || key == Key.j() || key == 74) {
        gKeyState[4] = false
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
public class GameRenderer {
    private var pen: QPen = QPen()
    private var brush: QBrush = QBrush()
    private let TS: Int32 = 32
    
    public init() {}
    
    public func render(painterPtr: Int64): Unit {
        let painter = QPainter.fromPtr(painterPtr)
        painter.setRenderHint(RenderHint.Antialiasing)
        
        painter.fillRectColor(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, Colors.black())
        
        renderMap(painter)
        renderBullets(painter)
        renderPlayer(painter)
        renderEnemies(painter)
        renderGrass(painter)
        renderExplosions(painter)
        renderStatusBar(painter)
        
        if (gGameOver) {
            renderGameOver(painter)
        }
    }
    
    private func renderMap(painter: QPainter): Unit {
        for (y in 0..MAP_HEIGHT) {
            for (x in 0..MAP_WIDTH) {
                let tile = gMap[y][x]
                let px = Int32(x * TILE_SIZE)
                let py = Int32(y * TILE_SIZE)
                
                match (tile) {
                    case 1 => renderBrick(painter, px, py)
                    case 2 => renderSteel(painter, px, py)
                    case 3 => renderWater(painter, px, py)
                    case 5 => renderBase(painter, px, py)
                    case _ => ()
                }
            }
        }
    }
    
    private func renderGrass(painter: QPainter): Unit {
        for (y in 0..MAP_HEIGHT) {
            for (x in 0..MAP_WIDTH) {
                if (gMap[y][x] == TILE_GRASS) {
                    let px = Int32(x * TILE_SIZE)
                    let py = Int32(y * TILE_SIZE)
                    painter.fillRectColor(px, py, TS, TS, QColor(34, 139, 34))
                }
            }
        }
    }
    
    private func renderBrick(painter: QPainter, x: Int32, y: Int32): Unit {
        painter.fillRectColor(x, y, TS, TS, QColor(139, 69, 19))
        pen.setColor(QColor(101, 67, 33))
        pen.setWidth(1)
        painter.setPen(pen)
        
        for (i in 0..4) {
            for (j in 0..4) {
                painter.drawRect(x + Int32(j) * 8, y + Int32(i) * 8, 8, 8)
            }
        }
    }
    
    private func renderSteel(painter: QPainter, x: Int32, y: Int32): Unit {
        painter.fillRectColor(x, y, TS, TS, QColor(169, 169, 169))
        pen.setColor(QColor(105, 105, 105))
        pen.setWidth(2)
        painter.setPen(pen)
        painter.drawRect(x + 2, y + 2, TS - 4, TS - 4)
        painter.drawLine(x, y, x + TS, y + TS)
        painter.drawLine(x + TS, y, x, y + TS)
    }
    
    private func renderWater(painter: QPainter, x: Int32, y: Int32): Unit {
        let gradient = QLinearGradient.fromInt(x, y, x, y + TS)
        gradient.setColorAt(0.0f32, QColor(0, 100, 200))
        gradient.setColorAt(1.0f32, QColor(0, 50, 150))
        brush = QBrush(gradient)
        painter.setBrush(brush)
        painter.fillRect(x, y, TS, TS, brush)
    }
    
    private func renderBase(painter: QPainter, x: Int32, y: Int32): Unit {
        painter.fillRectColor(x, y, TS, TS, QColor(255, 215, 0))
        pen.setColor(QColor(184, 134, 11))
        pen.setWidth(2)
        painter.setPen(pen)
        painter.drawRect(x + 4, y + 4, TS - 8, TS - 8)
        painter.drawLine(x + 8, y + 8, x + TS / 2, y + TS - 8)
        painter.drawLine(x + TS - 8, y + 8, x + TS / 2, y + TS - 8)
    }
    
    private func renderPlayer(painter: QPainter): Unit {
        if (!gPlayerAlive) { return }
        
        let bodyColor = QColor(0, 150, 0)
        let darkColor = QColor(0, 100, 0)
        
        painter.fillRectColor(gPlayerX, gPlayerY, 6, TS, darkColor)
        painter.fillRectColor(gPlayerX + TS - 6, gPlayerY, 6, TS, darkColor)
        painter.fillRectColor(gPlayerX + 6, gPlayerY + 4, TS - 12, TS - 8, bodyColor)
        painter.fillRectColor(gPlayerX + 8, gPlayerY + 8, TS - 16, TS - 16, darkColor)
        
        pen.setColor(darkColor)
        pen.setWidth(4)
        painter.setPen(pen)
        
        match (gPlayerDir) {
            case 0 => painter.drawLine(gPlayerX + TS / 2, gPlayerY + TS / 2, gPlayerX + TS / 2, gPlayerY)
            case 1 => painter.drawLine(gPlayerX + TS / 2, gPlayerY + TS / 2, gPlayerX + TS / 2, gPlayerY + TS)
            case 2 => painter.drawLine(gPlayerX + TS / 2, gPlayerY + TS / 2, gPlayerX, gPlayerY + TS / 2)
            case 3 => painter.drawLine(gPlayerX + TS / 2, gPlayerY + TS / 2, gPlayerX + TS, gPlayerY + TS / 2)
            case _ => ()
        }
    }
    
    private func renderEnemies(painter: QPainter): Unit {
        for (enemy in gEnemies) {
            let (x, y, dir, alive, _) = enemy
            if (!alive) { continue }
            
            let bodyColor = QColor(200, 50, 50)
            let darkColor = QColor(150, 30, 30)
            
            painter.fillRectColor(x, y, 6, TS, darkColor)
            painter.fillRectColor(x + TS - 6, y, 6, TS, darkColor)
            painter.fillRectColor(x + 6, y + 4, TS - 12, TS - 8, bodyColor)
            painter.fillRectColor(x + 8, y + 8, TS - 16, TS - 16, darkColor)
            
            pen.setColor(darkColor)
            pen.setWidth(4)
            painter.setPen(pen)
            
            match (dir) {
                case 0 => painter.drawLine(x + TS / 2, y + TS / 2, x + TS / 2, y)
                case 1 => painter.drawLine(x + TS / 2, y + TS / 2, x + TS / 2, y + TS)
                case 2 => painter.drawLine(x + TS / 2, y + TS / 2, x, y + TS / 2)
                case 3 => painter.drawLine(x + TS / 2, y + TS / 2, x + TS, y + TS / 2)
                case _ => ()
            }
        }
    }
    
    private func renderBullets(painter: QPainter): Unit {
        for (bullet in gBullets) {
            let (x, y, _, active, isPlayer) = bullet
            if (!active) { continue }
            
            let color = if (isPlayer) { Colors.yellow() } else { Colors.red() }
            brush = QBrush(color)
            painter.setBrush(brush)
            painter.drawCircle(x, y, 4)
        }
    }
    
    private func renderExplosions(painter: QPainter): Unit {
        for (exp in gExplosions) {
            let (x, y, frame, active) = exp
            if (!active) { continue }
            
            let progress = Float32(frame) / 15.0f32
            let radius = Int32(Float32(20) * (1.0f32 - progress * 0.5f32))
            let alpha = Int32(255.0f32 * (1.0f32 - progress))
            
            let outerColor = QColor.rgba(255, 100, 0, alpha)
            brush = QBrush(outerColor)
            painter.setBrush(brush)
            painter.drawCircle(x, y, radius)
            
            let innerColor = QColor.rgba(255, 255, 0, alpha)
            brush = QBrush(innerColor)
            painter.setBrush(brush)
            painter.drawCircle(x, y, radius / 2)
        }
    }
    
    private func renderStatusBar(painter: QPainter): Unit {
        let barY = WINDOW_HEIGHT - 55
        
        painter.fillRectColor(0, barY, WINDOW_WIDTH, 55, QColor(30, 30, 30))
        
        let font = QFont("Arial", 14)
        painter.setFont(font)
        pen.setColor(Colors.white())
        painter.setPen(pen)
        painter.drawText(10, barY + 20, "分数: ${gScore}")
        painter.drawText(10, barY + 40, "生命: ${gPlayerLives}")
        
        painter.drawText(WINDOW_WIDTH - 100, barY + 20, "关卡: ${gLevel}")
        let remaining = gTotalEnemies - gSpawnedEnemies + Int32(gEnemies.size)
        painter.drawText(WINDOW_WIDTH - 100, barY + 40, "敌人: ${remaining}")
        
        if (gPaused) {
            painter.drawText(WINDOW_WIDTH / 2 - 30, barY + 30, "已暂停")
        }
    }
    
    private func renderGameOver(painter: QPainter): Unit {
        painter.setOpacity(0.7f32)
        painter.fillRectColor(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, Colors.black())
        painter.setOpacity(1.0f32)
        
        let font = QFont("Arial", 32)
        painter.setFont(font)
        pen.setColor(Colors.red())
        painter.setPen(pen)
        painter.drawTextRect(WINDOW_WIDTH / 2 - 100, WINDOW_HEIGHT / 2 - 50, 200, 50, TextFlag.AlignCenter, "游戏结束")
        
        let font2 = QFont("Arial", 16)
        painter.setFont(font2)
        pen.setColor(Colors.white())
        painter.setPen(pen)
        painter.drawTextRect(WINDOW_WIDTH / 2 - 80, WINDOW_HEIGHT / 2 + 20, 160, 30, TextFlag.AlignCenter, "最终分数: ${gScore}")
        painter.drawTextRect(WINDOW_WIDTH / 2 - 80, WINDOW_HEIGHT / 2 + 50, 160, 30, TextFlag.AlignCenter, "按 R 重新开始")
    }
}

// ============================================================
// 主函数
// ============================================================
main() {
    gApp = QApplication()
    gWidget = QEventWidget()
    gTimer = QTimer()
    gRenderer = GameRenderer()
    
    initMap()
    
    if (let Some(w) <- gWidget) {
        w.resize(WINDOW_WIDTH, WINDOW_HEIGHT)
        w.setTitle("坦克大战 - CJQT6")
        w.setOnKeyPress({ key, modifiers, unicode => onKeyPress(key, modifiers, unicode) })
        w.setOnKeyRelease({ key, modifiers, unicode => onKeyRelease(key, modifiers, unicode) })
        w.setOnPaint({ painterPtr => onPaint(painterPtr) })
        w.show()
    }
    
    if (let Some(t) <- gTimer) {
        t.setInterval(16)
        t.setOnTimeout({ => onTimer() })
        t.start()
    }
    
    if (let Some(a) <- gApp) {
        a.exec()
    }
}