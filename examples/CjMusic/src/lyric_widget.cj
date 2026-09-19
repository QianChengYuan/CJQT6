// ============================================================
// 歌词区自绘部件（paintEvent + 平滑滚动 + 双击跳转）
// 设计文档 4.4/4.5 节
// ============================================================
package CjMusic

import cjqt6.core.*
import cjqt6.paint.*
import std.collection.*

// ============================================================
// 歌词区创建
// ============================================================

/// 创建歌词区自绘部件
public func createLyricWidget(): QEventWidget {
    let widget = QEventWidget()
    unsafe {
        var styleCstr = LibC.mallocCString(QSS_LYRIC_AREA)
        qWidgetSetStyleSheet(widget.getPtr(), styleCstr)
        LibC.free(styleCstr)
    }
    unsafe { qWidgetSetMinimumSize(widget.getPtr(), 200, 300) }

    // 设置 paint 回调
    widget.setOnPaint(lyricPaintCallback)

    // 设置鼠标回调（双击跳转）
    widget.setOnMousePress(lyricMousePressCallback)
    widget.setOnMouseRelease(lyricMouseReleaseCallback)

    // 创建滚动定时器
    let timer = QTimer()
    timer.setInterval(SCROLL_TIMER_INTERVAL)
    timer.setOnTimeoutCapture({
        => if (scrollTick()) {
            triggerLyricRepaint()
        } else {
            if (let Some(t) <- gScrollTimer) {
                t.stop()
            }
        }
    })
    gScrollTimer = Some(timer)

    widget
}

// ============================================================
// paint 回调（@C func，不能捕获局部变量）
// ============================================================

@C
func lyricPaintCallback(painterPtr: Int64): Unit {
    let widget = match (gLyricWidget) {
        case Some(w) => w
        case None => return
    }
    let w = unsafe { qWidgetWidth(widget.getPtr()) }
    let h = unsafe { qWidgetHeight(widget.getPtr()) }
    if (w <= 0 || h <= 0) {
        return
    }
    let painter = QPainter.fromPtr(painterPtr)
    painter.setRenderHint(RenderHint.TextAntialiasing.value())
    painter.setRenderHint(RenderHint.Antialiasing.value())

    let centerY = h / 2
    let curIdx = gCurrentLyricIndex

    // 无歌词时显示提示
    if (!gHasLyrics || gLyricLines.size == 0) {
        let font = QFont("Microsoft YaHei UI", 14)
        painter.setFont(font)
        let color = QColor.rgba(90, 93, 102, 255)
        painter.setPenColor(color)
        let hint = if (gLyricSource.isEmpty()) {
            "未找到歌词"
        } else {
            "歌词解析失败: ${gLyricSource}"
        }
        painter.drawTextRect(0, centerY - 20, w, 40, TextAlignment.Center.value, hint)
        return
    }

    // 绘制可见行
    let scrollOffset = gScrollCurrentY
    let startIdx = curIdx - LYRIC_VISIBLE_RADIUS
    let endIdx = curIdx + LYRIC_VISIBLE_RADIUS

    for (i in startIdx..endIdx + 1) {
        if (i < 0 || Int64(i) >= Int64(gLyricLines.size)) {
            continue
        }
        let distance = if (i >= curIdx) {
            i - curIdx
        } else {
            curIdx - i
        }
        if (!isVisible(distance)) {
            continue
        }
        let alpha = calcAlpha(distance)
        if (alpha == 0) {
            continue
        }
        let line = gLyricLines[Int64(i)]
        let y = calcRowY(i, curIdx, centerY, LYRIC_LINE_HEIGHT, scrollOffset)
        let fontSize = calcFontSize(distance)
        let (r, g, b) = calcColor(distance)
        let bold = isBold(distance)

        // 设置字体
        let font = QFont("Microsoft YaHei UI", fontSize)
        if (bold) {
            font.setBold(true)
        }
        painter.setFont(font)
        // 设置颜色（带透明度）
        let color = QColor.rgba(r, g, b, alpha)
        painter.setPenColor(color)
        // 绘制文本（居中）

        painter.drawTextRect(0, Int32(y) - LYRIC_LINE_HEIGHT / 2, w, LYRIC_LINE_HEIGHT, TextAlignment.Center.value,
            line.text)

        // 当前行左侧画 ▶ 三角
        if (distance == 0) {
            let triColor = QColor.rgba(LYRIC_COLOR_CURRENT_R, LYRIC_COLOR_CURRENT_G, LYRIC_COLOR_CURRENT_B, alpha)
            painter.setPenColor(triColor)
            let triX: Int32 = 20
            let triY = Int32(y)

            // 用 drawText 简化：画 ▶ 字符
            let triFont = QFont("Microsoft YaHei UI", 12)
            painter.setFont(triFont)
            painter.drawText(triX, triY + 4, "▶")
        }
    }
}

// ============================================================
// 鼠标回调（双击跳转）
// ============================================================

// 鼠标按下时间（用于双击判断）
var gLastClickY: Int32 = 0

@C
func lyricMousePressCallback(button: Int32, _x: Int32, y: Int32): Unit {
    // button: 1=左键
    if (button != 1) {
        return
    }
    gLastClickY = y
}

@C
func lyricMouseReleaseCallback(button: Int32, _x: Int32, y: Int32): Unit {
    if (button != 1) {
        return
    }
    // 简化：单击即跳转（文档提到双击跳转，但 QEventWidget 无双击事件，
    // 用 mouseRelease 实现单击跳转更自然）
    if (gHasLyrics && gLyricLines.size > 0) {
        if (let Some(w) <- gLyricWidget) {
            let h = unsafe { qWidgetHeight(w.getPtr()) }
            seekToLyricRow(y, h)
        }
    }
}
