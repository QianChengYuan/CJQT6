package CjMonitor

import std.env.*
import cjqt6.core.*
import CjMonitor.common.*
import CjMonitor.app.*
import CjMonitor.ui.*
import CjMonitor.probe.*
import CjMonitor.store.*
import CjMonitor.alert.*

/// 自测报告文件名（结果同时落盘，避免控制台未附加时取不到数据）
let SELFTEST_REPORT_FILE = "cjmonitor_selftest.txt"

/// 自测专用数据库文件（与运行期主库隔离，避免互相污染）
let SELFTEST_DB_FILE = "cjmonitor_selftest.db"

/// 启动跟踪文件：GUI 进程 stdout 不可见，逐点追加写是定位启动期崩溃最可靠的手段。
/// 设 CJMONITOR_TRACE=0 可关闭。
let TRACE_FILE = "cjmonitor_startup.log"

var gTraceOn: Bool = true

/// 记录一个启动阶段（失败静默，不影响主流程）
func trace(stage: String): Unit {
    if (gTraceOn) {
        let _ = appendTextFile(TRACE_FILE, stage + "\n")
    }
}

/// 开始新一轮跟踪（截断旧内容）
func traceReset(): Unit {
    if (gTraceOn) {
        let _ = writeTextFile(TRACE_FILE, "=== CjMonitor 启动跟踪 ===\n")
    }
}

/// 是否启用启动跟踪（CJMONITOR_TRACE=0 关闭）
func traceEnabled(): Bool {
    match (getVariable("CJMONITOR_TRACE")) {
        case Some(v) => v != "0"
        case None => true
    }
}

// ============================================================
// CjMonitor 入口
// 唯一装配点：创建 QApplication → 应用主题 → 构建主窗口或运行采集自测
// → 事件循环 → 显式释放。
//
// 采集自测模式：设环境变量 CJMONITOR_SELFTEST=<样本数>，
// 则不建窗口，仅跑采集并输出间隔统计后退出（供控制台验收与 CI 使用）。
// ============================================================

main(): Int64 {
    gTraceOn = traceEnabled()
    traceReset()
    trace("1. 进程启动")

    let app = QApplication()
    trace("2. QApplication 已创建")

    // 主题依赖 QApplication 实例，必须在其之后应用
    applyDarkTheme()
    trace("3. 主题已应用")

    let selfTest = selfTestCount()
    if (selfTest > 0) {
        return runSelfTest(app, selfTest)
    }

    // 绘制自测（M2 验收）：不启动采集，直接驱动自绘路径并统计帧率
    let paintFrames = paintSelfTestFrames()
    if (paintFrames > 0) {
        trace("4'. 进入绘制自测")
        return runPaintSelfTest(app, paintFrames)
    }

    // 界面自测（M3 验收）：装配与正常运行一致，额外采样布局/降频/状态栏
    let uiSeconds = uiSelfTestSeconds()
    if (uiSeconds > 0) {
        trace("5'. 进入界面自测")
        return runUiSelfTest(app, uiSeconds)
    }

    // M4 自测：降采样攒批落库 → 区间查询 → 历史图表重建 → 三页 PDF
    let m4Seconds = m4SelfTestSeconds()
    if (m4Seconds > 0) {
        trace("6'. 进入 M4 自测")
        return runM4SelfTest(app, m4Seconds)
    }

    // M5 自测：告警去抖/去重、提示音降级、深色主题、阈值窗口
    let m5Seconds = m5SelfTestSeconds()
    if (m5Seconds > 0) {
        trace("7'. 进入 M5 自测")
        return runM5SelfTest(app, m5Seconds)
    }

    // ---- 采集与界面装配（main.cj 是唯一装配点）----
    // 容量 1200 点：支持最长 120 秒窗口（100ms × 1200）
    let state = AppState(createPlatformProbe(), 1200, 20)
    trace("4. AppState 已创建（采集器=${state.probeName()}）")
    setAppState(state)
    state.setOnStatus(publishStatus)
    trace("5. 界面上下文已注入")

    // 降采样落库：每 10 次采样降采样一次，攒满 60 条（≈1 分钟）批量提交
    trace("5b. 准备构造落库器")
    let store = SampleStore("cjmonitor", 10, 60)
    trace("5c. 落库器已构造，开始 open")
    let opened = store.open("cjmonitor.db")
    trace("5d. open 返回 ${opened}")
    if (opened) {
        state.attachStore(store)
        trace("6. 落库已接入")
    } else {
        println("[警告] 数据库打开失败，转为纯内存运行：${store.error()}")
        trace("6. 落库打开失败：${store.error()}")
    }

    // 阈值告警：连续 3 次去抖 + 同类 5 秒展示去重；提示音缺失静默降级
    let alerter = Alerter(3, 5000)
    alerter.attachThresholds(state.thresholdsRef())
    alerter.setOnAlert(setAlertText)
    alerter.setSoundPath("res/alert.wav")
    state.attachAlerter(alerter)
    trace("7. 告警已接入")

    let window = createMainWindow()
    trace("8. 主窗口已构建")

    if (let Some(c) <- realtimeCurve()) {
        if (let Some(g) <- realtimeGauge()) {
            state.attachViews(c, g)
        }
    }
    trace("9. 自绘控件已注入")

    window.show()
    trace("10. 窗口已显示")

    state.start(100)
    trace("11. 采样已启动")
    setStatusText("采样已启动 · 采集器=" + state.probeName())

    let code = app.exec()

    // 显式释放（仓颉终结器已被刻意禁用，不可依赖 GC）
    state.dispose()
    disposeMainWindow()
    app.delete()

    Int64(code)
}

/// 读取自测样本数（未设置或非法则为 0）
func selfTestCount(): Int64 {
    match (getVariable("CJMONITOR_SELFTEST")) {
        case Some(v) => toI64Safe(v)
        case None => 0
    }
}

func toI64Safe(v: String): Int64 {
    var n: Int64 = 0
    var ok = true
    for (c in v) {
        if (c >= 48 && c <= 57) {
            n = n * 10 + Int64(c - 48)
        } else if (c != 32) {
            ok = false
            break
        }
    }
    if (ok) { n } else { 0 }
}

/// 采集自测：不建窗口，验证采样周期、数据通路与间隔误差
func runSelfTest(app: QApplication, count: Int64): Int64 {
    println("========== CjMonitor 采集自测 ==========")
    println("平台     : ${Platform.name()}")
    println("目标样本 : ${count}")
    println("----------------------------------------")

    let probe = createPlatformProbe()
    println("采集器   : ${probe.probeName()}")
    println("可用性   : ${probe.available()}")
    println("----------------------------------------")

    let state = AppState(probe, 600, 20)
    state.setVerbose(true)
    state.setStopAfter(count)

    // 自测也走完整链路：降采样落库 + 阈值告警（用独立库文件，避免污染主库）
    let store = SampleStore("cjmonitor_selftest", 10, 60)
    if (store.open(SELFTEST_DB_FILE)) {
        state.attachStore(store)
    } else {
        println("[警告] 自测数据库打开失败：${store.error()}")
    }
    let alerter = Alerter(3, 5000)
    alerter.attachThresholds(state.thresholdsRef())
    alerter.setSoundPath("")
    state.attachAlerter(alerter)

    state.start(100)

    let code = app.exec()

    // 先把攒批刷盘，再出报告：否则计数会显示为 0（数据仍在待写队列里）
    state.flushStore()

    // 结果同时输出与落盘：cjpm run 会分离启动子进程，stdout 未必回流
    let report = state.summaryText()
    println(report)
    if (!writeTextFile(SELFTEST_REPORT_FILE, report)) {
        println("[警告] 自测报告写入失败：${SELFTEST_REPORT_FILE}")
    }

    state.dispose()
    app.delete()

    Int64(code)
}
