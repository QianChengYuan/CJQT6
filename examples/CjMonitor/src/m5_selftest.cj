package CjMonitor

import std.collection.*
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
// M5 自测：告警去抖/去重、提示音缺失降级、深色主题、阈值窗口
//
// 触发：CJMONITOR_M5_SELFTEST=<观察秒数>（默认 6，最小 4）
//   $env:CJMONITOR_M5_SELFTEST = "6"
//   pwsh -File scripts\run_debug.ps1
//
// 不显示主窗口（阈值窗口会短暂出现，属被验收对象）。报告落盘 cjmonitor_m5_selftest.txt。
//
// 验收口径（M5）：① 连续 3 次超阈值才告警；② 同类告警 5s 内仅一次；
//                 ③ 深色主题全局生效；④ 提示音缺失静默降级；⑤ 阈值窗口可用。
//
// 设计说明：① ② 用**合成样本**做确定性验证（不依赖真实数据波动）；
// 真实采样的集成检查（告警确实到达界面）单独统计。
// 另注：判定层用的是「breaches == requiredBreaches」精确等值，因此**持续**超阈
// 只会告警一次；5s 去重窗口作用于「回落至阈值下、再次连续达标」的情形。
// ============================================================

let M5_REPORT_FILE = "cjmonitor_m5_selftest.txt"
let M5_SOUND_PATH = "res/alert.wav"
let M5_REQUIRED_BREACHES: Int64 = 3
let M5_TOAST_WINDOW_MS: Int64 = 5000
/// 集成检查用的通道阈值（设成 1% 以保证真实采样持续超阈）
let M5_LOW_THRESHOLD: Float64 = 1.0
var gM5State: ?AppState = None
var gM5Timer: ?QTimer = None
var gM5Alerter: ?Alerter = None
var gM5StartMs: Int64 = 0
var gM5TargetMs: Int64 = 0
var gM5Done: Bool = false

/// 集成路径（真实采样）告警统计
var gM5RealFires: Int64 = 0
var gM5FirstFireMs: Int64 = -1
var gM5LastFireText: String = ""

/// 确定性路径（合成样本）告警次数
var gM5DetFires: Int64 = 0
let onM5RealAlert: (String, Int32) -> Unit = {
    msg: String, level: Int32 =>
        if (gM5RealFires == 0) {
            gM5FirstFireMs = monoMs() - gM5StartMs
        }
        gM5RealFires += 1
        gM5LastFireText = msg
        setAlertText(msg, level)
}
let onM5DetAlert: (String, Int32) -> Unit = {
    msg: String, level: Int32 => gM5DetFires += 1
}
let onM5Tick: VoidCallback = {
    => m5Tick()
}

/// 读取观察秒数（未设置或非法则为 0）
public func m5SelfTestSeconds(): Int64 {
    match (getVariable("CJMONITOR_M5_SELFTEST")) {
        case Some(v) => toI64Safe(v)
        case None => 0
    }
}

func m5Tick(): Unit {
    if (monoMs() - gM5StartMs >= gM5TargetMs) {
        finishM5SelfTest()
    }
}

/// 子串包含检测（按字节比较，避开 String API 差异）
func containsAscii(haystack: Array<Byte>, needle: Array<Byte>): Bool {
    let nlen = Int64(needle.size)
    let total = Int64(haystack.size)
    if (nlen == 0) {
        return true
    }
    var i: Int64 = 0
    while (i + nlen <= total) {
        var j: Int64 = 0
        var ok = true
        while (j < nlen) {
            if (haystack[i + j] != needle[j]) {
                ok = false
                break
            }
            j += 1
        }
        if (ok) {
            return true
        }
        i += 1
    }
    false
}

func okText(b: Bool): String {
    if (b) {
        "通过"
    } else {
        "失败"
    }
}

/// 合成一个仅 CPU 通道有值的样本
func mkCpuSample(cpu: Float64): Sample {
    Sample(epochMs(), cpu, 0.0, 0.0, 0.0, 0.0)
}

func cpuOnlyThresholds(v: Float64): ArrayList<Float64> {
    let ts = ArrayList<Float64>()
    ts.add(v)
    var i: Int64 = 1
    while (i < Int64(Channel.COUNT)) {
        ts.add(0.0) // 0 = 该通道不启用告警
        i += 1
    }
    ts
}

/// 建一个只观察 CPU 通道的判定器
func mkDetAlerter(th: Float64, windowMs: Int64): Alerter {
    let a = Alerter(M5_REQUIRED_BREACHES, windowMs)
    a.setSoundPath(M5_SOUND_PATH) // 资源缺失 → 走静默降级
    a.attachThresholds(cpuOnlyThresholds(th))
    a.setOnAlert(onM5DetAlert)
    a
}

/// 确定性验证：去抖（连续 3 次）、去重（5s 窗口）、阈值 0 禁用、首次告警不被窗口吞掉
func runDeterministicChecks(): (Bool, Bool, Bool, Bool, Bool, Bool) {
    let th = 50.0

    // ---- 去抖 + 精确等值语义 ----
    gM5DetFires = 0
    let a1 = mkDetAlerter(th, M5_TOAST_WINDOW_MS)
    a1.onSample(mkCpuSample(80.0)) // 第 1 次超阈
    let noFireAt1 = gM5DetFires == 0
    a1.onSample(mkCpuSample(80.0)) // 第 2 次
    let noFireAt2 = gM5DetFires == 0
    a1.onSample(mkCpuSample(80.0)) // 第 3 次 → 触发
    let fireAt3 = gM5DetFires == 1
    a1.onSample(mkCpuSample(80.0)) // 第 4~6 次：精确等值 → 不再触发
    a1.onSample(mkCpuSample(80.0))
    a1.onSample(mkCpuSample(80.0))
    let noRepeat = gM5DetFires == 1

    // ---- 去重：回落后再连续达标，落在 5s 窗口内 → 被抑制 ----
    a1.onSample(mkCpuSample(10.0)) // 回落到阈值下 → 计数清零
    a1.onSample(mkCpuSample(10.0))
    a1.onSample(mkCpuSample(80.0))
    a1.onSample(mkCpuSample(80.0))
    a1.onSample(mkCpuSample(80.0)) // 再次达到 3 → 但距上次 <5s → 抑制
    let deduped = gM5DetFires == 1
    a1.dispose()

    // ---- 对照：窗口 = 0 时应立即再次触发（证明上一条是被窗口抑制，而非逻辑失效） ----
    gM5DetFires = 0
    let a2 = mkDetAlerter(th, 0)
    a2.onSample(mkCpuSample(80.0))
    a2.onSample(mkCpuSample(80.0))
    a2.onSample(mkCpuSample(80.0))
    a2.onSample(mkCpuSample(10.0))
    a2.onSample(mkCpuSample(80.0))
    a2.onSample(mkCpuSample(80.0))
    a2.onSample(mkCpuSample(80.0))
    let noWindowRefires = gM5DetFires == 2
    a2.dispose()

    // ---- 阈值 0 → 该通道禁用 ----
    gM5DetFires = 0
    let a3 = mkDetAlerter(0.0, 0)
    a3.onSample(mkCpuSample(100.0))
    a3.onSample(mkCpuSample(100.0))
    a3.onSample(mkCpuSample(100.0))
    let disabled = gM5DetFires == 0
    a3.dispose()

    // ---- 回归：首次告警不得被去重窗口吞掉 ----
    // 旧实现把「上次提示时间」初始化为 0，而 monoMs() 是进程相对时钟，
    // 于是进程启动后第一个 toastWindowMs 内的告警会被静默丢弃（真实缺陷）。
    // 这里把窗口设成远大于当前 monoMs()，即可在任意时刻复现该条件：
    //   旧实现 → 首次告警被抑制（计数 0）
    //   现实现 → 哨兵 -1 表示「从未提示」，首次必告警
    gM5DetFires = 0
    let a4 = mkDetAlerter(th, monoMs() + 60000)
    a4.onSample(mkCpuSample(80.0))
    a4.onSample(mkCpuSample(80.0))
    a4.onSample(mkCpuSample(80.0))
    let firstNotSuppressed = gM5DetFires == 1
    a4.dispose()

    (noFireAt1 && noFireAt2, fireAt3, noRepeat, deduped, noWindowRefires && disabled, firstNotSuppressed)
}

func finishM5SelfTest(): Unit {
    if (gM5Done) {
        return
    }
    gM5Done = true
    if (let Some(t) <- gM5Timer) {
        t.stop()
    }
    if (let Some(s) <- gM5State) {
        writeM5Report(s)
    }
    QApp.quit()
}

func writeM5Report(state: AppState): Unit {
    let elapsed = monoMs() - gM5StartMs

    // ---- 确定性检查（合成样本）----
    let det = runDeterministicChecks()

    // ---- 主题 ----
    let qss = QApp.styleSheet()
    let qssBytes = qss.toArray()
    var bgHit = containsAscii(qssBytes, "#0E1013".toArray())
    if (!bgHit) {
        bgHit = containsAscii(qssBytes, "#0e1013".toArray())
    }
    var accentHit = containsAscii(qssBytes, "#00D9B5".toArray())
    if (!accentHit) {
        accentHit = containsAscii(qssBytes, "#00d9b5".toArray())
    }

    // ---- 提示音 ----
    let soundExists = exists(Path(M5_SOUND_PATH))

    // ---- 阈值窗口：打开 → 读回填值 → 关闭 ----
    openThresholdWindow()
    let winSize = thresholdWindowSizeText()
    let spinText = thresholdSpinText()
    closeThresholdWindow()

    // ---- 判定链路可观测性：确认「被附加到 AppState 的判定器」就是自测持有的实例，
    //      且它确实收到了全部样本（否则「0 次告警」无法区分去抖未通过 / 未喂到数据） ----
    let total = state.totalSamples()
    let attachedCount = match (state.alerterRef()) {
        case Some(a) => a.count()
        case None => -1
    }
    let seen = match (gM5Alerter) {
        case Some(a) => a.seenSamples()
        case None => -1
    }
    var lastSampleText = "（无样本）"
    if (let Some(s) <- state.latestSample()) {
        lastSampleText = s.summary()
    }

    let alertBar = alertBarText()
    var fireText = gM5LastFireText
    if (fireText.isEmpty()) {
        fireText = "（观察期内未触发）"
    }

    var verdict = "M5 达标"
    if (!det[0] || !det[1] || !det[2] || !det[3]) {
        verdict = "未达标：判定层去抖/去重语义不符"
    } else if (!det[4]) {
        verdict = "未达标：去重对照或阈值 0 禁用不符"
    } else if (!det[5]) {
        verdict = "未达标：首次告警被去重窗口吞掉（进程启动初期静默）"
    } else if (total <= 0 || seen != total) {
        verdict = "未达标：判定器未收到全部样本（判定链路未接通）"
    } else if (gM5RealFires <= 0) {
        verdict = "未达标：真实采样未触发告警"
    } else if (gM5RealFires != attachedCount) {
        verdict = "未达标：回调与所附加判定器不一致"
    } else if (gM5FirstFireMs < 200) {
        verdict = "未达标：首次告警过早（去抖未生效）"
    } else if (!bgHit || !accentHit) {
        verdict = "未达标：深色主题未全局生效"
    }

    var report = "========== CjMonitor M5 自测（告警/主题/阈值窗口） ==========\n"
    report += "观察时长   : ${elapsed}ms（目标 ${gM5TargetMs}ms）\n"
    report += "----------------------------------------------\n"
    report += "[确定性] 连续 3 次才告警（第 1、2 次不触发）: ${okText(det[0])}\n"
    report += "[确定性] 第 3 次触发                        : ${okText(det[1])}\n"
    report += "[确定性] 持续超阈不重复触发（精确等值语义）  : ${okText(det[2])}\n"
    report += "[确定性] 5s 窗口内再次达标被抑制            : ${okText(det[3])}\n"
    report += "[确定性] 窗口=0 立即再触发 + 阈值 0 禁用通道  : ${okText(det[4])}\n"
    report += "[确定性] 首次告警不被去重窗口吞掉（哨兵回归）: ${okText(det[5])}\n"
    report += "----------------------------------------------\n"
    report += "[集成] 内存阈值 ${fmt1(M5_LOW_THRESHOLD)}%，真实采样告警次数 : ${gM5RealFires}\n"
    report += "[集成] 首次告警延迟 : ${gM5FirstFireMs}ms（3 次采样 ≈ 330ms，≥200ms 即去抖生效）\n"
    report += "[集成] 样本数/判定数 : ${total} / ${seen}（应相等；附加实例告警数 ${attachedCount}）\n"
    report += "[集成] 最新样本     : ${lastSampleText}\n"
    report += "[集成] 告警文本     : ${fireText}\n"
    report += "[集成] 告警条文本   : ${alertBar}\n"
    report += "----------------------------------------------\n"
    report += "深色主题   : QSS ${qssBytes.size} 字符，命中 #0E1013=${bgHit} #00D9B5=${accentHit}\n"
    report += "提示音     : ${M5_SOUND_PATH} 存在=${soundExists}（缺失即静默降级，本机已走该路径）\n"
    report += "阈值窗口   : 尺寸 ${winSize}，回填值 ${spinText}\n"
    report += "----------------------------------------------\n"
    report += "结论       : ${verdict}\n"

    println(report)
    if (!writeTextFile(M5_REPORT_FILE, report)) {
        println("[警告] M5 自测报告写入失败：${M5_REPORT_FILE}")
    }
}

/// 装配（同正常运行，不显示主窗口）→ 观察 N 秒 → 出报告
func runM5SelfTest(app: QApplication, seconds: Int64): Int64 {
    gM5TargetMs = seconds * 1000
    if (gM5TargetMs < 4000) {
        gM5TargetMs = 4000
    }

    let state = AppState(createPlatformProbe(), 1200, 20)
    setAppState(state)
    state.setOnStatus(publishStatus)
    gM5State = Some(state)

    let store = SampleStore("cjmonitor_m5_selftest", 10, 60)
    if (store.open("cjmonitor_m5_selftest.db")) {
        state.attachStore(store)
    }

    // 集成检查：把**内存**通道阈值压到 1%，让真实采样必然连续超阈。
    // 刻意不用 CPU：空闲机器上 CPU% 常在 0~1% 间抖动，`v >= th` 一回落就把连续计数清零，
    // 于是永远凑不满「连续 3 次」——那测的是数据波动而不是去抖（首版 M5 即栽在这里）。
    state.setThreshold(Channel.MEM, M5_LOW_THRESHOLD)

    let alerter = Alerter(M5_REQUIRED_BREACHES, M5_TOAST_WINDOW_MS)
    alerter.attachThresholds(state.thresholdsRef())
    alerter.setOnAlert(onM5RealAlert)
    alerter.setSoundPath(M5_SOUND_PATH) // 资源缺失 → 静默降级
    state.attachAlerter(alerter)
    gM5Alerter = Some(alerter)

    // 建界面但不 show：阈值窗口、告警条都要真实存在
    let _ = createMainWindow()

    gM5RealFires = 0
    gM5FirstFireMs = -1
    gM5LastFireText = ""
    gM5StartMs = monoMs()
    gM5Done = false

    state.start(100)

    let timer = QTimer()
    timer.setInterval(300)
    timer.setOnTimeout(onM5Tick)
    gM5Timer = Some(timer)
    timer.start()

    let code = app.exec()

    if (let Some(t) <- gM5Timer) {
        t.close()
    }
    gM5Timer = None
    gM5State = None
    disposeMainWindow()
    app.delete()

    Int64(code)
}
