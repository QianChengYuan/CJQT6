package CjMonitor.widget

import std.collection.*
import cjqt6.core.*
import cjqt6.paint.*
import CjMonitor.common.*

// ============================================================
// 多通道实时曲线（自绘）
//
// 性能红线：
//   - 取点走环形缓冲，回调内**零分配**（步长等中间量预计算为 Float64）
//   - 绘图对象用 QPainter.fromPtr 包装 canvas 传入的借用对象，不新建
//   - 字体在 init 建好复用，不在每帧 new
//
// 数据来源：直接持有 common 的环形缓冲（widget 不依赖 app，避免成环）
// ============================================================

// 顶层全局 + 回调：CFunc 不能捕获局部变量，只能经全局变量路由。
// （声明顺序要求：被函数体引用的顶层绑定必须先于使用处出现。）
var gCurveWidget: ?CurveWidget = None

let onCurvePaint: CFunc<(Int64) -> Unit> = { painterPtr: Int64 =>
    if (let Some(w) <- gCurveWidget) {
        w.paint(painterPtr)
    }
}

public class CurveWidget {
    private let canvas: QEventWidget
    private let nameFont: QFont
    private let valueFont: QFont
    private let frames = FrameStats()
    // 最近一次绘制回调收到的画布尺寸（诊断用；0 表示回调未触发或尺寸不足）
    private var lastW: Int32 = 0
    private var lastH: Int32 = 0

    private var buffers: ArrayList<RingBuffer> = ArrayList<RingBuffer>()
    private var visiblePoints: Int64 = 300

    public init() {
        canvas = QEventWidget()
        nameFont = QFont("Microsoft YaHei UI", 9)
        valueFont = QFont("Consolas", 9)
        canvas.setOnPaint(onCurvePaint)
    }

    /// 绑定数据缓冲（由装配点注入）
    public func setBuffers(bs: ArrayList<RingBuffer>): Unit {
        buffers = bs
    }

    /// 可见窗口点数（≤ 缓冲容量）
    public func setVisiblePoints(n: Int64): Unit {
        if (n >= 2) {
            visiblePoints = n
        }
    }

    /// 最小高度：QEventWidget 无 setMinimumSize，需经 FFI 调用
    public func setMinimumHeight(h: Int32): Unit {
        unsafe { qWidgetSetMinimumSize(canvas.getPtr(), 0, h) }
    }

    public func getPtr(): Int64 {
        canvas.getPtr()
    }

    /// 请求重绘（采样回调里只调它，不直接绘制）
    public func requestRepaint(): Unit {
        canvas.update()
    }

    public func frameStats(): FrameStats {
        frames
    }

    /// 最近一次绘制回调收到的画布尺寸（诊断用；0 表示回调未触发或尺寸不足）
    public func lastPaintWidth(): Int32 {
        lastW
    }

    public func lastPaintHeight(): Int32 {
        lastH
    }

    /// 诊断文本：当前画布尺寸 + 可见性（不依赖绘制回调，用于定位「绘制未触发」）
    public func diagText(): String {
        let w = unsafe { qWidgetWidth(canvas.getPtr()) }
        let h = unsafe { qWidgetHeight(canvas.getPtr()) }
        "${w} × ${h}，visible=${canvas.isVisible()}"
    }

    public func dispose(): Unit {
        nameFont.delete()
        valueFont.delete()
        canvas.close()
    }

    // ========================================================
    // 绘制
    // ========================================================

    func paint(painterPtr: Int64): Unit {
        // 先记账再判尺寸：尺寸不足时也要能观察到「回调确实被触发过」
        frames.onFrame()
        let w = unsafe { qWidgetWidth(canvas.getPtr()) }
        let h = unsafe { qWidgetHeight(canvas.getPtr()) }
        lastW = w
        lastH = h
        if (w <= 4 || h <= 4) {
            return
        }

        let painter = QPainter.fromPtr(painterPtr)
        painter.fillRectColor(0, 0, w, h, rgbSolid(C_BG_PANEL))

        // 绘图区（留出顶部图例与底部时间轴）
        let padL: Int32 = 10
        let padR: Int32 = 10
        let padT: Int32 = 24
        let padB: Int32 = 20
        let plotW = w - padL - padR
        let plotH = h - padT - padB
        if (plotW <= 4 || plotH <= 4) {
            return
        }

        // 横向网格（3 条分隔线 → 4 格）
        painter.setPenColor(rgbSolid(C_BORDER))
        var gi: Int32 = 1
        while (gi < 4) {
            let y = padT + plotH * gi / 4
            painter.drawLine(padL, y, padL + plotW, y)
            gi += 1
        }

        let n = Int64(buffers.size)
        var ch: Int64 = 0
        while (ch < n) {
            drawChannel(painter, ch, padL, padT, plotW, plotH)
            ch += 1
        }

        // 时间轴
        painter.setFont(valueFont)
        painter.setPenColor(rgbSolid(C_TEXT_MUTED))
        painter.drawText(padL, h - 6, wallClockHms())

        drawLegend(painter, w)
    }

    func drawChannel(painter: QPainter, ch: Int64, x0: Int32, y0: Int32, pw: Int32, ph: Int32): Unit {
        let buf = buffers[ch]
        let total = buf.size()
        if (total < 2) {
            return
        }
        let shown = if (visiblePoints > total) { total } else { visiblePoints }
        if (shown < 2) {
            return
        }
        let start = total - shown

        // 量程：百分比通道固定 0~100；速率通道按窗口峰值自适应
        let fixed = Channel.fixedMax(Int32(ch))
        var vmax = fixed
        if (vmax <= 0.0) {
            var m = 1.0
            var i: Int64 = start
            while (i < total) {
                let v = buf.at(i)
                if (m < v) {
                    m = v
                }
                i += 1
            }
            vmax = m * 1.15
        }

        painter.setPenColor(rgbSolid(channelColor(Int32(ch))))
        let step = Float64(pw) / Float64(shown - 1)
        let fph = Float64(ph)

        var i: Int64 = 0
        while (i < shown - 1) {
            let v1 = buf.at(start + i)
            let v2 = buf.at(start + i + 1)
            let x1 = x0 + Int32(Float64(i) * step)
            let x2 = x0 + Int32(Float64(i + 1) * step)
            let y1 = y0 + ph - Int32(clamp01(v1 / vmax) * fph)
            let y2 = y0 + ph - Int32(clamp01(v2 / vmax) * fph)
            painter.drawLine(x1, y1, x2, y2)
            i += 1
        }
    }

    func drawLegend(painter: QPainter, w: Int32): Unit {
        let total = Int64(Channel.COUNT)
        let slot = w / Int32(total)
        var ch: Int64 = 0
        while (ch < total) {
            let cx = 12 + Int32(ch) * slot
            painter.setPenColor(rgbSolid(channelColor(Int32(ch))))
            painter.drawCircle(cx, 12, 4)

            var v = 0.0
            if (ch < Int64(buffers.size)) {
                v = buffers[ch].last(0.0)
            }
            let txt = Channel.name(Int32(ch)) + " " + fmt1(v) + Channel.unit(Int32(ch))
            painter.setFont(nameFont)
            painter.setPenColor(rgbSolid(C_TEXT_SECONDARY))
            painter.drawText(cx + 10, 16, txt)
            ch += 1
        }
    }
}

/// 创建并登记曲线控件（回调经 gCurveWidget 路由，必须先登记再挂载）
public func createCurveWidget(): CurveWidget {
    let w = CurveWidget()
    w.setMinimumHeight(160)
    gCurveWidget = Some(w)
    w
}
