package CjMonitor.common

// ============================================================
// 统计器 —— 峰值 / 均值 / 计数 / 采样间隔 / 帧率
// 供状态栏、告警判定与 PDF 巡检报告复用。
// ============================================================

/// 单通道累计统计
public class ChannelStats {
    private var n: Int64 = 0
    private var sum: Float64 = 0.0
    private var maxV: Float64 = 0.0
    private var minV: Float64 = 0.0
    private var lastV: Float64 = 0.0
    private var hasData: Bool = false

    public func update(v: Float64): Unit {
        if (!hasData) {
            maxV = v
            minV = v
            hasData = true
        } else {
            if (v > maxV) { maxV = v }
            if (v < minV) { minV = v }
        }
        sum += v
        n += 1
        lastV = v
    }

    public func count(): Int64 { n }

    public func last(): Float64 { lastV }

    public func max(): Float64 { maxV }

    public func min(): Float64 { minV }

    public func avg(): Float64 {
        if (n == 0) { 0.0 } else { sum / Float64(n) }
    }

    public func reset(): Unit {
        n = 0
        sum = 0.0
        maxV = 0.0
        minV = 0.0
        lastV = 0.0
        hasData = false
    }
}

/// 采样间隔误差统计（验收指标：期望周期 ± 容差）
///
/// 注意口径：超窗判断是「实测间隔与**期望周期**之差的绝对值 > 容差」，
/// 而不是「实测间隔 > 容差」——后者在期望周期大于容差时会全部误判为超窗。
public class IntervalStats {
    private var expectedMs: Int64 = 100
    private var tolMs: Int64
    private var n: Int64 = 0
    private var sumMs: Int64 = 0
    private var minMs: Int64 = 0
    private var maxMs: Int64 = 0
    private var outliers: Int64 = 0
    private var hasData: Bool = false
    private var lastTsMs: Int64 = 0

    public init(expectedMs: Int64, tolMs: Int64) {
        this.expectedMs = expectedMs
        this.tolMs = tolMs
    }

    /// 设置期望周期（采样周期变更时同步）
    public func setExpected(ms: Int64): Unit {
        expectedMs = ms
    }

    /// 记录一次采样时间戳，内部自动与上次求差；首次仅建立基线
    public func record(tsMs: Int64): Unit {
        if (!hasData) {
            hasData = true
            lastTsMs = tsMs
            return
        }
        let d = tsMs - lastTsMs
        lastTsMs = tsMs
        if (d < 0) {
            return
        }
        if (n == 0) {
            minMs = d
            maxMs = d
        } else {
            if (minMs > d) { minMs = d }
            if (maxMs < d) { maxMs = d }
        }
        sumMs += d
        n += 1
        let dev = if (expectedMs < d) { d - expectedMs } else { expectedMs - d }
        if (tolMs < dev) {
            outliers += 1
        }
    }

    public func count(): Int64 { n }

    public func minIntervalMs(): Int64 { minMs }

    public func maxIntervalMs(): Int64 { maxMs }

    public func avgIntervalMs(): Float64 {
        if (n == 0) { 0.0 } else { Float64(sumMs) / Float64(n) }
    }

    public func outlierCount(): Int64 { outliers }

    /// 单行摘要：样本数 / 最小 / 最大 / 平均 / 超窗次数
    public func summary(): String {
        "n=${n} 期望=${expectedMs}ms±${tolMs}ms min=${minMs}ms max=${maxMs}ms avg=${fmt1(avgIntervalMs())}ms 超窗=${outliers}"
    }

    public func reset(): Unit {
        n = 0
        sumMs = 0
        minMs = 0
        maxMs = 0
        outliers = 0
        hasData = false
        lastTsMs = 0
    }
}

/// 帧率统计：绘制回调计数，由低频定时器取走

public class FrameStats {
    private var frames: Int64 = 0
    private var lastFps: Int32 = 0

    /// 每帧调用（必须极轻量，不可在绘制路径上做字符串拼接/打印）
    public func onFrame(): Unit {
        frames += 1
    }

    /// 取走自上次调用以来的帧数，折算为 FPS
    public func takeFps(): Int32 {
        let f = frames
        frames = 0
        lastFps = Int32(f)
        lastFps
    }

    public func currentFps(): Int32 { lastFps }
}
