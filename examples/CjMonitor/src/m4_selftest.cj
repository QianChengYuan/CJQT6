package CjMonitor

import std.env.*
import std.fs.*
import cjqt6.core.*
import CjMonitor.common.*
import CjMonitor.ui.*
import CjMonitor.app.*
import CjMonitor.probe.*
import CjMonitor.store.*
import CjMonitor.alert.*

// ============================================================
// M4 自测：降采样攒批落库 → 区间查询 → 历史图表重建 → 三页 PDF 导出
//
// 触发：CJMONITOR_M4_SELFTEST=<观察秒数>（默认 8，最小 4）
//   $env:CJMONITOR_M4_SELFTEST = "10"
//   pwsh -File scripts\run_debug.ps1
//
// **不显示窗口**：M4 的验收对象是数据通路与报告，不是布局（布局见界面自测 M3）。
// 报告落盘 cjmonitor_m4_selftest.txt；PDF 输出 cjmonitor_m4_selftest.pdf。
//
// 验收口径（见 .agents/skills/cjmonitor/references/acceptance.md）：
//   1) 降采样比 = 采样数 / 落库行数 ≈ 10（每 10 次采样降采样 1 行）
//   2) 数据库体积按「行/小时 × 每行字节」外推 1 小时 < 5MB
//   3) 区间查询有数据、历史图表按区间重建（点数 = 查询行数）
//   4) PDF **三页**（按 "/Type /Page" 计数，排除 "/Type /Pages" 对象树根）
// ============================================================

let M4_REPORT_FILE = "cjmonitor_m4_selftest.txt"
let M4_PDF_FILE = "cjmonitor_m4_selftest.pdf"
let M4_DB_FILE = "cjmonitor_m4_selftest.db"
/// 查询窗口：最近 10 分钟
let M4_QUERY_SPAN_MS: Int64 = 600000
/// 1 小时外推用的采样周期（实测约 110ms，见 acceptance.md）
let M4_SAMPLE_PERIOD_MS: Int64 = 110
/// 降采样比：每 10 次采样落 1 行
let M4_DOWNSAMPLE: Int64 = 10
/// 数据库体积上限（M4 指标）
let M4_DB_LIMIT_BYTES: Int64 = 5 * 1024 * 1024

var gM4State: ?AppState = None
var gM4Timer: ?QTimer = None
var gM4StartMs: Int64 = 0
var gM4TargetMs: Int64 = 0
var gM4Done: Bool = false

let onM4Tick: VoidCallback = {=>
    m4Tick()
}

/// 读取观察秒数（未设置或非法则为 0）
public func m4SelfTestSeconds(): Int64 {
    match (getVariable("CJMONITOR_M4_SELFTEST")) {
        case Some(v) => toI64Safe(v)
        case None => 0
    }
}

func m4Tick(): Unit {
    if (monoMs() - gM4StartMs >= gM4TargetMs) {
        finishM4SelfTest()
    }
}

/// 文件字节数；不存在或读失败返回 -1
func fileBytes(path: String): Int64 {
    try {
        Int64(File.readFrom(Path(path)).size)
    } catch (_: Exception) {
        -1
    }
}

/// 统计 PDF 页数：按 "/Type /Page" 计数（排除 "/Type /Pages"）
func countPdfPages(data: Array<Byte>): Int64 {
    let pat = "/Type /Page".toArray()
    let plen = Int64(pat.size)
    let total = Int64(data.size)
    var n: Int64 = 0
    var i: Int64 = 0
    while (i + plen <= total) {
        var j: Int64 = 0
        var ok = true
        while (j < plen) {
            if (data[i + j] != pat[j]) {
                ok = false
                break
            }
            j += 1
        }
        if (ok) {
            let after = i + plen
            var isPagesRoot = false
            if (after < total && data[after] == UInt8(115)) {
                isPagesRoot = true   // 's' → /Pages（对象树根，不计）
            }
            if (!isPagesRoot) {
                n += 1
            }
        }
        i += 1
    }
    n
}

func finishM4SelfTest(): Unit {
    if (gM4Done) {
        return
    }
    gM4Done = true
    if (let Some(t) <- gM4Timer) {
        t.stop()
    }
    if (let Some(s) <- gM4State) {
        writeM4Report(s)
    }
    QApp.quit()
}

func writeM4Report(state: AppState): Unit {
    // 1) 攒批刷盘：否则落库计数为 0（数据还在待写队列里）
    state.flushStore()
    let samples = state.totalSamples()
    let now = epochMs()

    // 2) 区间查询（走 AppState → SampleStore 的真实查询路径）
    let t0 = monoMs()
    let rows = state.queryHistory(now - M4_QUERY_SPAN_MS, now, 5000)
    let queryMs = monoMs() - t0
    let rowCount = Int64(rows.size)

    // 3) 历史图表重建（走 ui 的真实路径：runQuery → rebuild）
    runHistoryQuery()
    let historyText = historyQueryText()

    // 4) 三页 PDF（走 ui 的真实装配：exportInspectionReport → report/exportPdf）
    exportInspectionReport(M4_PDF_FILE)
    let pdfBytes = fileBytes(M4_PDF_FILE)
    var pages: Int64 = -1
    if (pdfBytes > 0) {
        try {
            pages = countPdfPages(File.readFrom(Path(M4_PDF_FILE)))
        } catch (_: Exception) {
            pages = -1
        }
    }

    // 5) 先释放（关闭数据库连接、刷盘），再量体积
    state.dispose()
    let dbBytes = fileBytes(M4_DB_FILE)

    var ratio = 0.0
    if (rowCount > 0) {
        ratio = Float64(samples) / Float64(rowCount)
    }
    var perRow: Int64 = 0
    if (rowCount > 0 && dbBytes > 0) {
        perRow = dbBytes / rowCount
    }
    let rowsPerHour = 3600 * 1000 / M4_SAMPLE_PERIOD_MS / M4_DOWNSAMPLE
    let estHourBytes = rowsPerHour * perRow

    var verdict = "M4 达标"
    if (rowCount <= 0) {
        verdict = "未达标：区间查询无数据（攒批未落库？）"
    } else if (ratio < 5.0 || ratio > 20.0) {
        verdict = "未达标：降采样比偏离 1/10"
    } else if (pages != 3) {
        verdict = "未达标：PDF 页数不是 3"
    } else if (estHourBytes > M4_DB_LIMIT_BYTES) {
        verdict = "未达标：数据库体积外推超 5MB"
    }

    var report = "========== CjMonitor M4 自测（落库/历史/报告） ==========\n"
    report += "观察时长   : ${monoMs() - gM4StartMs}ms（目标 ${gM4TargetMs}ms）\n"
    report += "----------------------------------------------\n"
    report += "采样数     : ${samples}\n"
    report += "落库行数   : ${rowCount}（最近 10 分钟区间）\n"
    report += "降采样比   : ${fmt2(ratio)}（目标 ≈ ${M4_DOWNSAMPLE}）\n"
    report += "区间查询   : ${queryMs}ms（AppState.queryHistory）\n"
    report += "历史重建   : ${historyText}\n"
    report += "----------------------------------------------\n"
    report += "数据库体积 : ${dbBytes} 字节（${rowCount} 行 → 每行 ${perRow} 字节）\n"
    report += "1 小时外推 : ${rowsPerHour} 行 → ${estHourBytes} 字节（上限 ${M4_DB_LIMIT_BYTES}）\n"
    report += "PDF        : ${pdfBytes} 字节，页数 ${pages}（cf. \"三页可打开\"）\n"
    report += "----------------------------------------------\n"
    report += "结论       : ${verdict}\n"

    println(report)
    if (!writeTextFile(M4_REPORT_FILE, report)) {
        println("[警告] M4 自测报告写入失败：${M4_REPORT_FILE}")
    }
}

/// 装配（与正常运行一致，但不显示窗口）→ 采样 N 秒 → 出报告
func runM4SelfTest(app: QApplication, seconds: Int64): Int64 {
    gM4TargetMs = seconds * 1000
    if (gM4TargetMs < 4000) {
        gM4TargetMs = 4000
    }

    let state = AppState(createPlatformProbe(), 1200, 20)
    setAppState(state)
    state.setOnStatus(publishStatus)
    gM4State = Some(state)

    let store = SampleStore("cjmonitor_m4_selftest", 10, 60)
    if (!store.open(M4_DB_FILE)) {
        println("[警告] 自测库打开失败：${store.error()}")
    }
    state.attachStore(store)

    let alerter = Alerter(3, 5000)
    alerter.attachThresholds(state.thresholdsRef())
    alerter.setOnAlert(setAlertText)
    alerter.setSoundPath("")
    state.attachAlerter(alerter)

    // 建界面但不 show：历史页/进程页要存在，才能走真实的查询与报告装配路径
    let _ = createMainWindow()

    state.start(100)
    gM4StartMs = monoMs()
    gM4Done = false

    let timer = QTimer()
    timer.setInterval(500)
    timer.setOnTimeout(onM4Tick)
    gM4Timer = Some(timer)
    timer.start()

    let code = app.exec()

    if (let Some(t) <- gM4Timer) {
        t.close()
    }
    gM4Timer = None
    gM4State = None
    disposeMainWindow()
    app.delete()

    Int64(code)
}
