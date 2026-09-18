package CjMonitor

import std.env.*
import cjqt6.core.*
import CjMonitor.common.*
import CjMonitor.ui.*
import CjMonitor.app.*
import CjMonitor.probe.*
import CjMonitor.store.*
import CjMonitor.alert.*

// ============================================================
// 界面自测（M3 验收）
//
// 触发：CJMONITOR_UI_SELFTEST=<观察秒数>
//   $env:CJMONITOR_UI_SELFTEST = "10"
//   pwsh -File scripts\run_debug.ps1        # 会弹窗，结束后自动退出
//
// 装配与正常运行**完全一致**（AppState + 落库 + 告警 + 主窗口 + 启动采样），
// 额外做三件事，报告落盘 cjmonitor_ui_selftest.txt（GUI 进程 stdout 未必可见）：
//   1) 在「设计最小尺寸 960×640」与「1920×1080」下采样关键控件几何 → 布局是否塌陷。
//      注：M3 原稿写 800×600，但主容器 `setMinimumSize(960, 640)` 是设计约定
//      （见 README「布局与页面规划」），故按设计值验收，并在报告中标注。
//   2) 统计进程表 1s 降频：tick 数 / 完成轮数 / 单轮填表耗时 / 实际行数。
//   3) 统计状态栏写入次数并抓取最终文本。
// ============================================================

let UI_SELFTEST_REPORT_FILE = "cjmonitor_ui_selftest.txt"
let UI_SELFTEST_DB_FILE = "cjmonitor_ui_selftest.db"
/// 探针节拍：500ms（比 1s 状态推送更密，便于分阶段）
let UI_PROBE_INTERVAL_MS: Int32 = 500
/// 布局验收用的两档尺寸：设计最小值 + 全高清
let UI_SIZE_MIN_W: Int32 = 960
let UI_SIZE_MIN_H: Int32 = 640
let UI_SIZE_FHD_W: Int32 = 1920
let UI_SIZE_FHD_H: Int32 = 1080

// ---- 全局状态（CFunc 回调不能捕获局部变量）----

var gUiTimer: ?QTimer = None
var gUiState: ?AppState = None
var gUiWindowPtr: Int64 = 0
var gUiTargetMs: Int64 = 0
var gUiStartMs: Int64 = 0
var gUiGeomA: String = ""
var gUiGeomB: String = ""
var gUiFinished: Bool = false

let onUiProbe: VoidCallback = {=>
    uiProbeTick()
}

/// 读取界面自测观察秒数（未设置或非法则为 0）
public func uiSelfTestSeconds(): Int64 {
    match (getVariable("CJMONITOR_UI_SELFTEST")) {
        case Some(v) => toI64Safe(v)
        case None => 0
    }
}

/// 关键控件几何是否全部非 0（布局塌陷检查）
func layoutOk(): Bool {
    if (let Some(c) <- realtimeCurve()) {
        if (c.lastPaintWidth() <= 4 || c.lastPaintHeight() <= 4) {
            return false
        }
    }
    if (let Some(g) <- realtimeGauge()) {
        if (g.lastPaintWidth() <= 4 || g.lastPaintHeight() <= 4) {
            return false
        }
    }
    if (processPageCollapsed()) {
        return false
    }
    if (statusLabelCollapsed()) {
        return false
    }
    true
}

/// 采样当前关键控件几何
func sampleGeometry(tag: String): String {
    var s = "[${tag}] 窗口 ${windowSizeText()}；"
    if (let Some(c) <- realtimeCurve()) {
        s += "曲线 ${c.diagText()}；"
    }
    if (let Some(g) <- realtimeGauge()) {
        s += "仪表 ${g.diagText()}；"
    }
    s += "进程页 ${processPageSizeText()}；"
    s += "状态栏 ${statusLabelSizeText()}"
    s
}

func uiProbeTick(): Unit {
    if (gUiFinished) {
        return
    }
    let el = monoMs() - gUiStartMs
    let total = gUiTargetMs

    // 分阶段：20% 切最小尺寸 → 35% 记 A（实时页）→ 40% 切全高清 + 进程页
    // → 60% 记 B（进程页可见）→ 100% 收口
    // 注：隐藏页签的页面不参与布局（尺寸恒为 Qt 默认 640×480），必须切过去再量。
    if (gUiGeomA.isEmpty() && el >= total * 20 / 100) {
        resizeMainWindow(UI_SIZE_MIN_W, UI_SIZE_MIN_H)
    }
    if (gUiGeomA.isEmpty() && el >= total * 35 / 100) {
        gUiGeomA = sampleGeometry("最小 960×640 · 实时页")
    }
    if (gUiGeomB.isEmpty() && el >= total * 40 / 100) {
        resizeMainWindow(UI_SIZE_FHD_W, UI_SIZE_FHD_H)
        showProcessTab()
    }
    if (gUiGeomB.isEmpty() && el >= total * 60 / 100) {
        gUiGeomB = sampleGeometry("全高清 1920×1080 · 进程页可见")
    }
    if (el >= total) {
        finishUiSelfTest()
    }
}

func finishUiSelfTest(): Unit {
    if (gUiFinished) {
        return
    }
    gUiFinished = true
    if (let Some(t) <- gUiTimer) {
        t.stop()
    }

    let elapsed = monoMs() - gUiStartMs
    let okLayout = layoutOk()
    let layoutText = if (okLayout) { "不塌（关键控件均非 0 尺寸）" } else { "塌陷（见上方几何）" }

    var statusText = lastStatusText()
    if (statusText.isEmpty()) {
        statusText = "（空）"
    }

    var verdict = "M3 达标"
    if (gProcTicks <= 0 || statusUpdateCount() <= 0) {
        verdict = "未达标：进程表或状态栏未刷新"
    } else if (!okLayout) {
        verdict = "未达标：布局塌陷"
    }

    var report = "========== CjMonitor 界面自测（M3） ==========\n"
    report += "观察时长   : ${elapsed}ms（目标 ${gUiTargetMs}ms）\n"
    report += "尺寸档位   : 设计最小 960×640 / 全高清 1920×1080\n"
    report += "             （M3 原稿的 800×600 低于主容器 setMinimumSize(960,640)，按设计值验收）\n"
    report += "----------------------------------------------\n"
    report += "布局·A ${gUiGeomA}\n"
    report += "布局·B ${gUiGeomB}\n"
    report += "布局判定   : ${layoutText}\n"
    report += "----------------------------------------------\n"
    report += "进程表 tick : ${gProcTicks}（1s 定时器触发次数）\n"
    report += "进程表 轮次 : ${gProcRounds}（采集→填表 完成轮数）\n"
    report += "进程表 单轮 : last=${gProcRoundLastMs}ms max=${gProcRoundMaxMs}ms（周期 1000ms）\n"
    report += "进程表 行数 : ${gProcRows}\n"
    report += "状态栏 写入 : ${statusUpdateCount()} 次\n"
    report += "状态栏 文本 : ${statusText}\n"
    report += "----------------------------------------------\n"
    report += "结论       : ${verdict}\n"

    println(report)
    if (!writeTextFile(UI_SELFTEST_REPORT_FILE, report)) {
        println("[警告] 界面自测报告写入失败：${UI_SELFTEST_REPORT_FILE}")
    }

    QApp.quit()
}

/// 装配（与正常运行一致）→ 定时采样 → 出报告
func runUiSelfTest(app: QApplication, seconds: Int64): Int64 {
    gUiTargetMs = seconds * 1000
    if (gUiTargetMs < 3000) {
        gUiTargetMs = 3000
    }

    let state = AppState(createPlatformProbe(), 1200, 20)
    setAppState(state)
    state.setOnStatus(publishStatus)
    gUiState = Some(state)

    // 落库用独立文件，避免污染主库；顺带验证状态栏里的库行数
    let store = SampleStore("cjmonitor_ui_selftest", 10, 60)
    if (store.open(UI_SELFTEST_DB_FILE)) {
        state.attachStore(store)
    }

    // 告警静默（界面自测不弹提示音）
    let alerter = Alerter(3, 5000)
    alerter.attachThresholds(state.thresholdsRef())
    alerter.setOnAlert(setAlertText)
    alerter.setSoundPath("")
    state.attachAlerter(alerter)

    let window = createMainWindow()
    window.show()
    gUiWindowPtr = window.getPtr()

    if (let Some(c) <- realtimeCurve()) {
        if (let Some(g) <- realtimeGauge()) {
            state.attachViews(c, g)
        }
    }
    state.start(100)

    gUiStartMs = monoMs()
    gUiGeomA = ""
    gUiGeomB = ""
    gUiFinished = false

    let timer = QTimer()
    timer.setInterval(UI_PROBE_INTERVAL_MS)
    timer.setOnTimeout(onUiProbe)
    gUiTimer = Some(timer)
    timer.start()

    let code = app.exec()

    // 兜底：若定时器未走到收口（异常路径），这里补写报告
    finishUiSelfTest()

    // ---- 显式释放（终结器已禁用）----
    if (let Some(s) <- gUiState) {
        s.flushStore()
        s.dispose()
    }
    gUiState = None
    if (let Some(t) <- gUiTimer) {
        t.close()
    }
    gUiTimer = None
    disposeMainWindow()
    app.delete()

    Int64(code)
}
