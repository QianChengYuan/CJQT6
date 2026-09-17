package CjMonitor.app

import std.collection.*
import cjqt6.core.*
import CjMonitor.common.*
import CjMonitor.probe.*
import CjMonitor.widget.*
import CjMonitor.store.*
import CjMonitor.alert.*

// ============================================================
// AppState —— 全局状态与采样调度
//
// 职责：
//   1. 以固定周期驱动 Probe 采样；
//   2. 把样本写入环形缓冲并累计统计；
//   3. 记录采样间隔误差（验收指标）；
//   4. 驱动自绘控件重绘，并按 1s 向状态栏推送一行摘要。
//
// 分层约束：本包**不依赖 ui**。界面对象由装配点（main.cj）通过
// attachViews / setOnStatus 注入，避免 ui ↔ app 循环依赖。
//
// 对象寿命：QTimer 一旦被 GC 采集就会停摆（终结器已禁用），
// 因此定时器由本类强引用持有，退出时显式释放。
// ============================================================

public class AppState {
    // ---- 采集 ----
    private let probe: Probe
    private var timer: Option<QTimer> = None

    // ---- 数据 ----
    private let buffers: ArrayList<RingBuffer>
    private let stats: ArrayList<ChannelStats>
    private let intervals: IntervalStats

    // ---- 运行状态 ----
    private var sampleCount: Int64 = 0
    private var idleTicks: Int64 = 0
    private var paused: Bool = false
    private var latest: Option<Sample> = None
    private var lastFps: Int32 = 0

    // ---- 外部注入 ----
    private var curve: Option<CurveWidget> = None
    private var gauge: Option<GaugePanel> = None
    private var store: Option<SampleStore> = None
    private var alerter: Option<Alerter> = None
    private var onStatus: Option<(String) -> Unit> = None

    // ---- 开关 ----
    private var verbose: Bool = false
    private var stopAfter: Int64 = 0

    // ---- 阈值（告警与仪表配色共用）----
    private let thresholds: ArrayList<Float64>

    /// capacity：每个通道的滑动窗口点数（600 点 ≈ 1 分钟 @100ms）
    /// intervalTolMs：采样间隔容差（相对期望周期）
    public init(probe: Probe, capacity: Int64, intervalTolMs: Int64) {
        this.probe = probe
        this.intervals = IntervalStats(100, intervalTolMs)

        let bufs = ArrayList<RingBuffer>()
        let sts = ArrayList<ChannelStats>()
        let ths = ArrayList<Float64>()
        var i: Int64 = 0
        while (i < Int64(Channel.COUNT)) {
            bufs.add(RingBuffer(capacity))
            sts.add(ChannelStats())
            ths.add(defaultThreshold(Int32(i)))
            i += 1
        }
        this.buffers = bufs
        this.stats = sts
        this.thresholds = ths
    }

    // ========================================================
    // 生命周期
    // ========================================================

    /// 启动采样（intervalMs 为采样周期，建议 100）
    public func start(intervalMs: Int32): Unit {
        intervals.setExpected(Int64(intervalMs))
        let t = QTimer()
        t.setInterval(intervalMs)
        // Capture 回调可捕获 this，无需全局变量中转
        t.setOnTimeoutCapture({ => this.onTick() })
        t.start()
        timer = Some(t)
    }

    /// 停止采样（保留数据）
    public func stop(): Unit {
        if (let Some(t) <- timer) {
            t.stop()
        }
    }

    /// 释放全部资源（幂等）
    public func dispose(): Unit {
        if (let Some(t) <- timer) {
            t.stop()
            t.close()
        }
        timer = None
        // 落库收尾：把攒批中未提交的行刷盘后再关连接
        if (let Some(st) <- store) {
            st.close()
        }
        store = None
        if (let Some(a) <- alerter) {
            a.dispose()
        }
        alerter = None
        probe.dispose()
    }

    // ========================================================
    // 采样主循环
    // ========================================================

    func onTick(): Unit {
        if (paused) {
            return
        }
        let s = probe.sample()
        if (let Some(sv) <- s) {
            idleTicks = 0
            handleSample(sv)
        } else {
            handleIdle()
        }
    }

    func handleSample(s: Sample): Unit {
        sampleCount += 1
        intervals.record(monoMs())

        var i: Int64 = 0
        while (i < Int64(Channel.COUNT)) {
            let v = s.channel(Int32(i))
            buffers[i].push(v)
            stats[i].update(v)
            i += 1
        }
        latest = Some(s)

        // 降采样攒批落库（写放大降低一个数量级）
        if (let Some(st) <- store) {
            st.onSample(s)
        }

        // 阈值告警（判定层已做连续 N 次去抖）
        if (let Some(a) <- alerter) {
            a.onSample(s)
        }

        // 实时重绘：只请求，不在采样回调里画
        if (let Some(c) <- curve) {
            c.requestRepaint()
        }
        if (let Some(g) <- gauge) {
            g.requestRepaint()
        }

        if (verbose && (sampleCount % 10 == 0)) {
            println("[#${sampleCount}] ${s.summary()}")
        }

        // 1 秒一次的界面状态推送（取走帧率计数）
        if (sampleCount % 10 == 0) {
            if (let Some(c) <- curve) {
                lastFps = c.frameStats().takeFps()
            }
            if (let Some(h) <- onStatus) {
                h(statusLine())
            }
        }

        if (stopAfter > 0 && sampleCount >= stopAfter) {
            QApp.quit()
        }
    }

    func handleIdle(): Unit {
        idleTicks += 1
        if (verbose && (idleTicks % 50 == 0)) {
            println("[等待] 尚无数据（空 tick ${idleTicks}）—— 采集器「${probe.probeName()}」可用=${probe.available()}")
        }
        // 自测模式下的兜底：长时间无数据则退出，避免 CI 挂死
        if (stopAfter > 0 && idleTicks >= 300) {
            println("[超时] 30 秒未取得任何样本，终止自测")
            println("       平台=${Platform.name()} 采集器=${probe.probeName()} 可用=${probe.available()}")
            QApp.quit()
        }
    }

    /// 自测报告文本（同时用于控制台输出与落盘，避免控制台未附加时取不到结果）
    public func summaryText(): String {
        let sb = StringBuilder()
        sb.append("========== CjMonitor 采集自测报告 ==========\n")
        sb.append("平台     : ${Platform.name()}\n")
        sb.append("采集器   : ${probe.probeName()}\n")
        sb.append("可用性   : ${probe.available()}\n")
        sb.append("样本数   : ${sampleCount}\n")
        sb.append("空 tick  : ${idleTicks}\n")
        sb.append("已落库   : ${storedRows()} 行\n")
        let serr = storeError()
        if (!serr.isEmpty()) {
            sb.append("落库错误 : ${serr}\n")
        }
        let alerts = match (alerter) {
            case Some(a) => a.count()
            case None => 0
        }
        sb.append("告警次数 : ${alerts}\n")
        sb.append("间隔统计 : ${intervals.summary()}\n")
        sb.append("采集诊断 : ${procDiag()}\n")
        sb.append("-------------------------------------------\n")
        var i: Int64 = 0
        while (i < Int64(Channel.COUNT)) {
            let name = Channel.name(Int32(i))
            let unit = Channel.unit(Int32(i))
            let st = stats[i]
            let sz = buffers[i].size()
            let cap = buffers[i].capacity()
            sb.append("  ${name}: 当前=${fmt1(st.last())}${unit} 峰值=${fmt1(st.max())} 均值=${fmt1(st.avg())} 窗口=${sz}/${cap}\n")
            i += 1
        }
        sb.append("===========================================")
        sb.toString()
    }

    // ========================================================
    // 装配与访问
    // ========================================================

    /// 注入自绘控件（同时把数据缓冲与阈值交给它们）
    public func attachViews(c: CurveWidget, g: GaugePanel): Unit {
        c.setBuffers(buffers)
        g.setBuffers(buffers)
        g.setThresholds(thresholds)
        curve = Some(c)
        gauge = Some(g)
    }

    /// 注册状态栏推送（约 1s 一次）
    public func setOnStatus(hook: (String) -> Unit): Unit {
        onStatus = Some(hook)
    }

    /// 控制台详细输出（验收用）
    public func setVerbose(v: Bool): Unit {
        verbose = v
    }

    /// 达到 n 组样本后自动退出（自测用；0 表示不限）
    public func setStopAfter(n: Int64): Unit {
        stopAfter = n
    }

    public func setPaused(p: Bool): Unit {
        paused = p
    }

    public func isPaused(): Bool {
        paused
    }

    /// 清空数据（保留缓冲内存，不触发分配）
    public func clearData(): Unit {
        var i: Int64 = 0
        while (i < Int64(Channel.COUNT)) {
            buffers[i].clear()
            stats[i].reset()
            i += 1
        }
        intervals.reset()
        sampleCount = 0
    }

    public func probeName(): String {
        probe.probeName()
    }

    public func probeAvailable(): Bool {
        probe.available()
    }

    /// 已累计的样本数（方法名不能与字段同名，故用 totalSamples）
    public func totalSamples(): Int64 {
        sampleCount
    }

    public func latestSample(): Option<Sample> {
        latest
    }

    public func buffer(idx: Int32): RingBuffer {
        buffers[Int64(idx)]
    }

    public func buffersRef(): ArrayList<RingBuffer> {
        buffers
    }

    public func channelStats(idx: Int32): ChannelStats {
        stats[Int64(idx)]
    }

    public func intervalStats(): IntervalStats {
        intervals
    }

    public func currentFps(): Int32 {
        lastFps
    }

    public func threshold(idx: Int32): Float64 {
        thresholds[Int64(idx)]
    }

    public func setThreshold(idx: Int32, v: Float64): Unit {
        thresholds[Int64(idx)] = v
    }

    public func thresholdsRef(): ArrayList<Float64> {
        thresholds
    }

    /// 注入落库器（装配点调用；未注入则纯内存运行）
    public func attachStore(s: SampleStore): Unit {
        store = Some(s)
    }

    public func storeRef(): Option<SampleStore> {
        store
    }

    /// 注入告警器（装配点调用）
    public func attachAlerter(a: Alerter): Unit {
        alerter = Some(a)
    }

    public func alerterRef(): Option<Alerter> {
        alerter
    }

    /// 历史区间查询（供历史页使用）
    public func queryHistory(fromMs: Int64, toMs: Int64, limit: Int64): ArrayList<Sample> {
        match (store) {
            case Some(st) => st.queryRange(fromMs, toMs, limit)
            case None => ArrayList<Sample>()
        }
    }

    /// 立即提交攒批（自测与退出前调用，确保数据落地）
    public func flushStore(): Unit {
        if (let Some(st) <- store) {
            st.flush()
        }
    }

    /// 落库错误（无错误返回空串）
    public func storeError(): String {
        match (store) {
            case Some(st) => st.error()
            case None => ""
        }
    }

    /// 已落库行数
    public func storedRows(): Int64 {
        match (store) {
            case Some(st) => st.rows()
            case None => 0
        }
    }

    /// 状态栏摘要文案
    public func statusLine(): String {
        "采样=${sampleCount} 间隔=${fmt1(intervals.avgIntervalMs())}ms 超窗=${intervals.outlierCount()} 帧率=${lastFps}FPS 落库=${storedRows()} 空载=${idleTicks}"
    }
}

/// 各通道默认阈值（网络速率量纲自适应，默认不告警）
public func defaultThreshold(idx: Int32): Float64 {
    match (idx) {
        case 0 => 85.0
        case 1 => 90.0
        case 2 => 90.0
        case _ => 0.0
    }
}
