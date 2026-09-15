// ============================================================
// 歌词区坐标与样式纯函数（不依赖 Qt，可独立单测）
// 设计文档 4.4 节、4.5 节坑 2
// ============================================================
package CjMusic

// 当前行字号
let LYRIC_FONT_CURRENT: Int32 = 22
// 非当前行字号
let LYRIC_FONT_NORMAL: Int32 = 16
// 行高
let LYRIC_LINE_HEIGHT: Int32 = 36
// 当前行颜色（青绿 #00D9B5）
let LYRIC_COLOR_CURRENT_R: Int32 = 0
let LYRIC_COLOR_CURRENT_G: Int32 = 217
let LYRIC_COLOR_CURRENT_B: Int32 = 181
// 非当前行颜色（白）
let LYRIC_COLOR_NORMAL_R: Int32 = 230
let LYRIC_COLOR_NORMAL_G: Int32 = 232
let LYRIC_COLOR_NORMAL_B: Int32 = 236
// 可见行范围（当前行 ±N 行绘制）
let LYRIC_VISIBLE_RADIUS: Int32 = 6

/// 计算某行歌词的 Y 坐标（相对控件顶部）
/// rowIdx: 要计算的行索引
/// curIdx: 当前行索引
/// centerY: 控件垂直中心点（height / 2）
/// lineHeight: 行高
/// scrollOffset: 滚动偏移（平滑动画中的插值，0 表示静止）
/// 返回值：该行基线 Y 坐标（Float64 精确，绘制时转 Int32）
public func calcRowY(rowIdx: Int32, curIdx: Int32, centerY: Int32, lineHeight: Int32,
    scrollOffset: Float64): Float64 {
    let delta = Int64(rowIdx - curIdx)
    Float64(centerY) + Float64(delta) * Float64(lineHeight) + scrollOffset
}

/// 从点击 Y 坐标反查歌词行索引（用于双击跳转）
/// clickY: 点击的 Y 坐标（相对控件）
/// centerY: 控件垂直中心点
/// scrollOffset: 当前滚动偏移
/// lineHeight: 行高
/// curIdx: 当前行索引
/// 返回值：被点击的行索引（可能超出歌词范围，调用方需校验）
/// 注意：必须减去 scrollOffset，否则滚动中跳转偏移（4.5 节坑 2）
public func calcRowIndex(clickY: Int32, centerY: Int32, scrollOffset: Float64,
    lineHeight: Int32, curIdx: Int32): Int32 {
    let delta = Float64(clickY - centerY) - scrollOffset
    curIdx + Int32(delta / Float64(lineHeight))
}

/// 距当前行的距离 → 透明度（0~255）
/// distance: abs(rowIdx - curIdx)
public func calcAlpha(distance: Int32): Int32 {
    match (distance) {
        case 0 => 255
        case 1 => 160
        case 2 => 90
        case 3 => 50
        case _ =>
            if (distance > LYRIC_VISIBLE_RADIUS) {
                0   // 超出可见范围不绘制
            } else {
                25  // 递减到很淡
            }
    }
}

/// 距当前行的距离 → 字号
public func calcFontSize(distance: Int32): Int32 {
    if (distance == 0) {
        LYRIC_FONT_CURRENT
    } else {
        LYRIC_FONT_NORMAL
    }
}

/// 距当前行的距离 → 是否粗体
public func isBold(distance: Int32): Bool {
    distance == 0
}

/// 距当前行的距离 → RGB 颜色
/// 返回 (R, G, B)
public func calcColor(distance: Int32): (Int32, Int32, Int32) {
    if (distance == 0) {
        (LYRIC_COLOR_CURRENT_R, LYRIC_COLOR_CURRENT_G, LYRIC_COLOR_CURRENT_B)
    } else {
        (LYRIC_COLOR_NORMAL_R, LYRIC_COLOR_NORMAL_G, LYRIC_COLOR_NORMAL_B)
    }
}

/// 判断某行是否在可见范围内（是否需要绘制）
/// distance: abs(rowIdx - curIdx)
public func isVisible(distance: Int32): Bool {
    distance <= LYRIC_VISIBLE_RADIUS
}

/// 缓动函数：线性插值（用于平滑滚动）
/// elapsed: 已经过时间（ms）
/// duration: 总时长（ms）
/// 返回 0.0~1.0 的进度
public func easeLinear(elapsed: Int64, duration: Int64): Float64 {
    if (duration <= 0) {
        return 1.0
    }
    let p = Float64(elapsed) / Float64(duration)
    if (p < 0.0) {
        0.0
    } else if (p > 1.0) {
        1.0
    } else {
        p
    }
}

/// 缓动函数：ease-out（先快后慢，滚动更自然）
public func easeOut(elapsed: Int64, duration: Int64): Float64 {
    let t = easeLinear(elapsed, duration)
    1.0 - (1.0 - t) * (1.0 - t)
}

/// 插值计算当前滚动 Y 偏移
/// startY: 动画起点
/// targetY: 动画目标
/// elapsed: 已经过时间
/// duration: 总时长
public func interpolateScroll(startY: Float64, targetY: Float64,
    elapsed: Int64, duration: Int64): Float64 {
    let progress = easeOut(elapsed, duration)
    startY + (targetY - startY) * progress
}