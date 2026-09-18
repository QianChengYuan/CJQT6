package CjMonitor.widget

import std.collection.*
import cjqt6.core.*
import cjqt6.paint.*
import CjMonitor.common.*

// ============================================================
// 四通道环形仪表（自绘，单画布）
//
// 设计取舍：四枚仪表**合并到同一块 QEventWidget** 上绘制。
// 相比四个独立控件，只需一个 setOnPaint 回调与一个全局变量，
// 既省去回调路由样板，也减少一次绘制事件分发。
//
// 数值带轻量插值过渡（每帧向目标逼近 18%），避免读数跳变。
// ============================================================

var gGaugePanel: ?GaugePanel = None

let onGaugePaint: CFunc<(Int64) -> Unit> = { painterPtr: Int64 =>
    if (let Some(g) <- gGaugePanel) {
        g.paint(painterPtr)
    }
}

/// 速率通道归一化参考值（KB/s）：超过即视为满圈
let NET_REFERENCE_KBPS = 1000.0

/// 插值系数：过小则迟钝，过大则跳动
let SMOOTH_FACTOR = 0.18

public class GaugePanel {
    private let canvas: QEventWidget
    private let nameFont: QFont
    private let valueFont: QFont
    private let frames = FrameStats()
    // 最近一次绘制回调收到的画布尺寸（诊断用；0 表示回调未触发或尺寸不足）
    private var lastW: Int32 = 0
    private var lastH: Int32 = 0

    private let bgPen: QPen
    private let valPens: ArrayList<QPen> = ArrayList<QPen>()

    private var buffers: ArrayList<RingBuffer> = ArrayList<RingBuffer>()
    private var thresholds: ArrayList<Float64> = ArrayList<Float64>()
    private var smoothed: Array<Float64> = Array<Float64>(4, repeat: 0.0)
    private var smoothedInit: Bool = false

    public init() {
        canvas = QEventWidget()
        nameFont = QFont("Microsoft YaHei UI", 11)
        valueFont = QFont("Consolas", 18)

        bgPen = QPen(rgbSolid(C_BORDER))
        bgPen.setWidth(9)

        var i: Int64 = 0
        while (i < Int64(Channel.COUNT)) {
            let p = QPen(rgbSolid(channelColor(Int32(i))))
            p.setWidth(9)
            valPens.add(p)
            i += 1
        }

        canvas.setOnPaint(onGaugePaint)
    }

    public func setBuffers(bs: ArrayList<RingBuffer>): Unit {
        buffers = bs
    }

    public func setThresholds(ts: ArrayList<Float64>): Unit {
        thresholds = ts
    }

    public func setMinimumHeight(h: Int32): Unit {
        unsafe { qWidgetSetMinimumSize(canvas.getPtr(), 0, h) }
    }

    public func getPtr(): Int64 {
        canvas.getPtr()
    }

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
        bgPen.delete()
        var i: Int64 = 0
        while (i < Int64(valPens.size)) {
            valPens[i].delete()
            i += 1
        }
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
        let count = Int64(Channel.COUNT)
        if (w <= 8 || h <= 8) {
            return
        }

        let painter = QPainter.fromPtr(painterPtr)
        painter.fillRectColor(0, 0, w, h, rgbSolid(C_BG_PANEL))

        let cellW = w / Int32(count)
        let cy = h / 2 - 8
        var radius = cellW / 2 - 16
        let maxR = h / 2 - 18
        if (radius > maxR) {
            radius = maxR
        }
        if (radius < 10) {
            return
        }

        // 先更新插值状态，再绘制
        updateSmoothed(count)

        var ch: Int64 = 0
        while (ch < count) {
            let cx = cellW * Int32(ch) + cellW / 2
            let left = cx - radius
            let top = cy - radius
            let side = radius * 2

            // 底环
            painter.setPen(bgPen)
            painter.drawArc(left, top, side, side, 0, 360 * 16)

            // 值环（从 12 点方向顺时针）
            let span = -Int32(smoothed[ch] * 360.0 * 16.0)
            if (span != 0) {
                valPens[ch].setColor(rgbSolid(colorFor(ch)))
                painter.setPen(valPens[ch])
                painter.drawArc(left, top, side, side, 90 * 16, span)
            }

            // 中心读数
            var v = 0.0
            if (ch < Int64(buffers.size)) {
                v = buffers[ch].last(0.0)
            }
            painter.setFont(valueFont)
            painter.setPenColor(rgbSolid(colorFor(ch)))
            let txt = fmt1(v)
            painter.drawTextRect(left, cy - 14, side, 28, centerFlags(), txt)

            // 通道名
            painter.setFont(nameFont)
            painter.setPenColor(rgbSolid(C_TEXT_MUTED))
            let nm = Channel.name(Int32(ch)) + " " + Channel.unit(Int32(ch))
            painter.drawTextRect(left, cy + radius + 2, side, 18, topCenterFlags(), nm)

            ch += 1
        }
    }

    func updateSmoothed(count: Int64): Unit {
        var ch: Int64 = 0
        while (ch < count) {
            var raw = 0.0
            if (ch < Int64(buffers.size)) {
                raw = buffers[ch].last(0.0)
            }
            let fixed = Channel.fixedMax(Int32(ch))
            var norm = clamp01(raw / fixed)
            if (fixed <= 0.0) {
                norm = clamp01(raw / NET_REFERENCE_KBPS)
            }
            if (!smoothedInit) {
                smoothed[ch] = norm
            } else {
                smoothed[ch] = smoothed[ch] + (norm - smoothed[ch]) * SMOOTH_FACTOR
            }
            ch += 1
        }
        smoothedInit = true
    }

    /// 超阈值转危险色，否则用通道色
    func colorFor(ch: Int64): Rgb {
        if (ch < Int64(thresholds.size)) {
            let th = thresholds[ch]
            if (th > 0.0 && ch < Int64(buffers.size)) {
                if (buffers[ch].last(0.0) >= th) {
                    return C_DANGER
                }
            }
        }
        channelColor(Int32(ch))
    }

    func centerFlags(): Int32 {
        (TextAlignment.HCenter | TextAlignment.VCenter).value
    }

    func topCenterFlags(): Int32 {
        (TextAlignment.HCenter | TextAlignment.Top).value
    }
}

/// 创建并登记仪表盘（必须先登记再挂载）
public func createGaugePanel(): GaugePanel {
    let g = GaugePanel()
    g.setMinimumHeight(120)
    gGaugePanel = Some(g)
    g
}
