package CjMonitor.alert

import std.collection.*
import std.fs.*
import cjqt6.richwidgets.*
import cjqt6.multimedia.*
import CjMonitor.common.*

// ============================================================
// 阈值告警
//
// 两级防抖，缺一不可：
//   1. 判定层去抖：**连续 N 次**（默认 3）超阈值才触发，避免瞬时抖动误报；
//   2. 展示层去重：同类告警在时间窗内（默认 5s）只弹一次，避免刷屏堆积。
//
// 提示音按「资源缺失即静默」降级：examples/**/*.wav 被 .gitignore 忽略，
// 音频资源不随仓库分发，缺失属预期而非故障。
// ============================================================

public class Alerter {
    private let requiredBreaches: Int64
    private let toastWindowMs: Int64
    private let toastDurationMs: Int32 = 4000

    /// 各通道连续超阈值计数
    private var breaches: Array<Int64> = Array<Int64>(4, repeat: 0)
    /// 各通道上次提示时间（单调毫秒）
    private var lastFireMs: Array<Int64> = Array<Int64>(4, repeat: 0)

    // 注意：泛型嵌套的连续 '>>' 会被解析成右移运算符，必须留空格
    private var thresholds: Option<ArrayList<Float64> > = None
    private var onAlert: Option<(String, Int32) -> Unit> = None

    private var alertCount: Int64 = 0
    private var lastText: String = ""
    private var lastLevel: Int32 = 0

    // 提示音（可选，缺失即静默）
    private var soundPath: String = ""
    private var player: Option<QSoundEffect> = None
    private var playerCreated: Bool = false

    // 只保留最新一个 Toast，创建前关掉上一个，避免长期运行堆积
    private var lastToast: Option<Toast> = None

    public init(requiredBreaches: Int64, toastWindowMs: Int64) {
        this.requiredBreaches = if (requiredBreaches < 1) { 1 } else { requiredBreaches }
        this.toastWindowMs = if (toastWindowMs < 0) { 0 } else { toastWindowMs }
    }

    public func attachThresholds(ts: ArrayList<Float64>): Unit {
        thresholds = Some(ts)
    }

    public func setOnAlert(hook: (String, Int32) -> Unit): Unit {
        onAlert = Some(hook)
    }

    /// 设置提示音文件；不存在则静默降级
    public func setSoundPath(p: String): Unit {
        soundPath = p
    }

    public func count(): Int64 {
        alertCount
    }

    public func lastMessage(): String {
        lastText
    }

    /// 最近一次告警级别（0 正常 / 1 警告 / 2 危险）；方法名不能与字段同名
    public func lastAlertLevel(): Int32 {
        lastLevel
    }

    public func dispose(): Unit {
        if (let Some(t) <- lastToast) {
            t.close()
        }
        lastToast = None
        if (let Some(se) <- player) {
            se.stop()
            se.close()
        }
        player = None
        playerCreated = false
    }

    // ========================================================
    // 判定
    // ========================================================

    public func onSample(s: Sample): Unit {
        if (let Some(ts) <- thresholds) {
            var ch: Int64 = 0
            while (ch < Int64(Channel.COUNT)) {
                let th = ts[ch]
                if (th <= 0.0) {
                    ch += 1
                    continue
                }
                let v = s.channel(Int32(ch))
                if (v >= th) {
                    breaches[ch] += 1
                } else {
                    breaches[ch] = 0
                }
                if (breaches[ch] == requiredBreaches) {
                    fire(ch, v, th)
                }
                ch += 1
            }
        }
    }

    func fire(ch: Int64, v: Float64, th: Float64): Unit {
        let now = monoMs()
        if (now - lastFireMs[ch] < toastWindowMs) {
            return   // 展示层去重
        }
        lastFireMs[ch] = now
        alertCount += 1

        let level: Int32 = if (v >= th * 1.1) { 2 } else { 1 }
        lastLevel = level
        let msg = "${Channel.name(Int32(ch))} ${fmt1(v)}${Channel.unit(Int32(ch))} 超过阈值 ${fmt1(th)}"
        lastText = msg

        // 浮动提示（Toast 无静态方法，需实例）
        if (let Some(old) <- lastToast) {
            old.close()
        }
        let t = Toast(msg, toastDurationMs)
        t.show()
        lastToast = Some(t)

        playSound()

        if (let Some(h) <- onAlert) {
            h(msg, level)
        }
    }

    func playSound(): Unit {
        if (soundPath.isEmpty()) {
            return
        }
        if (!exists(Path(soundPath))) {
            return   // 资源缺失：静默降级，不阻塞主流程
        }
        if (!playerCreated) {
            let se = QSoundEffect()
            se.setSourceFile(soundPath)
            se.setVolume(0.6)
            player = Some(se)
            playerCreated = true
        }
        if (let Some(se) <- player) {
            se.play()
        }
    }
}
