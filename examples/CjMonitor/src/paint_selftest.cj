package CjMonitor

import std.collection.*
import std.env.*
import cjqt6.core.*
import CjMonitor.common.*
import CjMonitor.ui.*
import CjMonitor.widget.*

// ============================================================
// 绘制自测（M2 验收入口）
//
// 触发：设环境变量 CJMONITOR_PAINT_SELFTEST=<帧数>
//   $env:CJMONITOR_PAINT_SELFTEST = "300"
//   pwsh -File scripts\run_debug.ps1        # 会短暂弹出窗口（约 3 秒）
//
// ⚠ 必须用**真实平台**运行：`QT_QPA_PLATFORM=offscreen` 下窗口虽 visible=true、
//   画布尺寸也正确（实测 1226×428），但 Qt **不会派发 paintEvent**，本自测会
//   记录到「0 绘制帧」而误判为未达标。自绘相关验收一律走真实平台。
//
// 做法：**不启动采集**，直接向实时页的曲线/仪表注入合成的 600 点 × 4 通道
// 数据，以固定间隔驱动重绘，跑到目标帧数（或 20 秒兜底）后把报告落盘——
// GUI 进程 stdout 未必可见，故结果以文件为准。
//
// 「每帧 QPainter 已 close()」的口径：绘制路径经 `QPainter.fromPtr` 包装
// canvas 传入的**借用**对象（`owned=false`，`close()` 为空操作），全程不新建
// owning `QPainter` —— 每帧都不产生需要释放的绘图对象（见
// `.agents/skills/cjqt6-realtime/references/api-cheatsheet.md` 3.3）。
// 因为不持有所有权，绘制中的提前 `return` 也不会漏释放。
// ============================================================

let PAINT_SELFTEST_REPORT_FILE = "cjmonitor_paint_selftest.txt"

/// 验收口径：600 点 × 4 通道（对应 60 秒窗口）
let PAINT_SELFTEST_POINTS: Int64 = 600

/// 驱动间隔：10ms（比采样周期 100ms 更密，用来验证绘制吞吐有余量）
let PAINT_SELFTEST_DRIVE_MS: Int32 = 10

/// 墙钟兜底：绘制异常慢时也要收口，避免自测挂住
let PAINT_SELFTEST_MAX_MS: Int64 = 20000

/// M2 指标下限
let PAINT_SELFTEST_MIN_FPS: Float64 = 10.0

// ---- 全局状态（CFunc 回调不能捕获局部变量）----

var gPaintTimer: ?QTimer = None
var gPaintCurve: ?CurveWidget = None
var gPaintGauge: ?GaugePanel = None
var gPaintTarget: Int64 = 300
var gPaintDriven: Int64 = 0
var gPaintCurveFrames: Int64 = 0
var gPaintGaugeFrames: Int64 = 0
var gPaintStartMs: Int64 = 0

/// 驱动回调：只读全局状态
let onPaintDrive: VoidCallback = {=>
    drivePaintFrame()
}

/// 读取绘制自测帧数（未设置或非法则为 0）
func paintSelfTestFrames(): Int64 {
    match (getVariable("CJMONITOR_PAINT_SELFTEST")) {
        case Some(v) => toI64Safe(v)
        case None => 0
    }
}

/// 合成采样值：锯齿波 + 通道偏置。不依赖数学库，形状确定、可复现。
func synthPoint(ch: Int32, i: Int64): Float64 {
    let phase = Float64(i % 120) / 120.0
    let tri = if (phase < 0.5) { phase * 2.0 } else { 2.0 - phase * 2.0 }
    if (ch == Channel.NET) {
        // 网络通道是 KB/s，量级与百分比通道不同：顺带验证自适应缩放
        200.0 + tri * 800.0
    } else {
        20.0 + tri * 60.0 + Float64(ch) * 6.0
    }
}

/// 收割绘制帧计数（`FrameStats.takeFps()` 是「取走并清零」，故累计求和）
func harvestPaintFrames(): Unit {
    if (let Some(c) <- gPaintCurve) {
        gPaintCurveFrames += Int64(c.frameStats().takeFps())
    }
    if (let Some(g) <- gPaintGauge) {
        gPaintGaugeFrames += Int64(g.frameStats().takeFps())
    }
}

/// 每轮：先收割上一轮已完成的绘制，再请求下一帧重绘
func drivePaintFrame(): Unit {
    harvestPaintFrames()
    if (let Some(c) <- gPaintCurve) {
        c.requestRepaint()
    }
    if (let Some(g) <- gPaintGauge) {
        g.requestRepaint()
    }
    gPaintDriven += 1

    let elapsed = monoMs() - gPaintStartMs
    if (gPaintDriven >= gPaintTarget || elapsed >= PAINT_SELFTEST_MAX_MS) {
        // 最后一次驱动可能已经画完，再收割一次
        harvestPaintFrames()
        if (let Some(t) <- gPaintTimer) {
            t.stop()
        }
        QApp.quit()
    }
}

/// 建窗口 → 注入合成数据 → 驱动重绘 → 出报告
func runPaintSelfTest(app: QApplication, frames: Int64): Int64 {
    if (frames > 0) {
        gPaintTarget = frames
    } else {
        gPaintTarget = 300
    }

    // 1) 建完整主窗口：自绘控件在真实布局里才有正确尺寸（离屏平台同样派发绘制事件）
    let window = createMainWindow()
    window.show()

    // 2) 合成 600 点 × 4 通道并注入（不经采集，聚焦绘制路径）
    let buffers = ArrayList<RingBuffer>()
    var ch: Int64 = 0
    while (ch < Int64(Channel.COUNT)) {
        let rb = RingBuffer(PAINT_SELFTEST_POINTS)
        var i: Int64 = 0
        while (i < PAINT_SELFTEST_POINTS) {
            rb.push(synthPoint(Int32(ch), i))
            i += 1
        }
        buffers.add(rb)
        ch += 1
    }

    if (let Some(c) <- realtimeCurve()) {
        c.setBuffers(buffers)
        c.setVisiblePoints(PAINT_SELFTEST_POINTS)
        gPaintCurve = Some(c)
    }
    if (let Some(g) <- realtimeGauge()) {
        g.setBuffers(buffers)
        g.setThresholds(ArrayList<Float64>())
        gPaintGauge = Some(g)
    }

    // 3) 固定间隔驱动重绘，跑满目标帧数或超时后收口
    gPaintDriven = 0
    gPaintCurveFrames = 0
    gPaintGaugeFrames = 0
    gPaintStartMs = monoMs()

    let timer = QTimer()
    timer.setInterval(PAINT_SELFTEST_DRIVE_MS)
    timer.setOnTimeout(onPaintDrive)
    gPaintTimer = Some(timer)
    timer.start()

    let code = app.exec()
    let elapsed = monoMs() - gPaintStartMs

    // ---- 汇总 ----
    var fps = 0.0
    if (elapsed > 0) {
        fps = Float64(gPaintCurveFrames) * 1000.0 / Float64(elapsed)
    }
    var perFrame = 0.0
    if (gPaintCurveFrames > 0) {
        perFrame = Float64(elapsed) / Float64(gPaintCurveFrames)
    }
    var verdict = "未达标"
    if (gPaintCurveFrames <= 0) {
        verdict = "无绘制帧（离屏平台不派发 paintEvent？请改用真实平台运行）"
    } else if (fps >= PAINT_SELFTEST_MIN_FPS) {
        verdict = "达标"
    }
    var bottleneck = "绘制慢于驱动"
    if (gPaintCurveFrames >= gPaintDriven) {
        bottleneck = "绘制跟得上驱动（单帧绘制 < ${PAINT_SELFTEST_DRIVE_MS}ms）"
    }

    var report = "========== CjMonitor 绘制自测（M2） ==========\n"
    report += "可见点数   : ${PAINT_SELFTEST_POINTS} × ${Channel.COUNT} 通道\n"
    report += "驱动间隔   : ${PAINT_SELFTEST_DRIVE_MS}ms\n"
    report += "目标帧数   : ${gPaintTarget}\n"
    report += "----------------------------------------------\n"
    report += "驱动次数   : ${gPaintDriven}\n"
    report += "曲线绘制帧 : ${gPaintCurveFrames}\n"
    report += "仪表绘制帧 : ${gPaintGaugeFrames}\n"
    if (let Some(c) <- gPaintCurve) {
        report += "曲线画布   : ${c.diagText()}（绘制时 ${c.lastPaintWidth()}×${c.lastPaintHeight()}）\n"
    }
    if (let Some(g) <- gPaintGauge) {
        report += "仪表画布   : ${g.diagText()}（绘制时 ${g.lastPaintWidth()}×${g.lastPaintHeight()}）\n"
    }
    report += "窗口尺寸   : ${window.width()} × ${window.height()}\n"
    report += "墙钟耗时   : ${elapsed}ms\n"
    report += "曲线帧率   : ${fmt2(fps)} FPS（下限 ${fmt1(PAINT_SELFTEST_MIN_FPS)}）\n"
    report += "每帧墙钟   : ${fmt2(perFrame)}ms\n"
    report += "绘制瓶颈   : ${bottleneck}\n"
    report += "QPainter   : 全部包装 canvas 传入的借用对象（owned=false），无逐帧新建/泄漏\n"
    report += "说明       : 在完整主窗口内运行（含进程表 1s 刷新等开销），帧率为保守下限\n"
    report += "----------------------------------------------\n"
    report += "结论       : ${verdict}\n"

    println(report)
    if (!writeTextFile(PAINT_SELFTEST_REPORT_FILE, report)) {
        println("[警告] 绘制自测报告写入失败：${PAINT_SELFTEST_REPORT_FILE}")
    }

    // ---- 显式释放（终结器已禁用，不可依赖 GC）----
    if (let Some(t) <- gPaintTimer) {
        t.close()
    }
    gPaintTimer = None
    gPaintCurve = None
    gPaintGauge = None
    disposeMainWindow()
    app.delete()

    Int64(code)
}
