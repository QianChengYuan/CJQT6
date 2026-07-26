package signal_smoke

import cjqt6.core.*
import cjqt6.widgets.*

// 全局计数器（VoidCallback 不能捕获局部变量，按 cjqt6 约定用全局）
var gCountA: Int32 = 0
var gCountB: Int32 = 0
var gCountBBefore: Int32 = 0
var gWatchdogTicks: Int32 = 0
var gTimer: ?QTimer = None

// P2：SignalEmitter 验证用的全局计数（VoidCallback 不能捕获局部变量）
var gEmVoid: Int32 = 0
var gEmInt: Int32 = 0
var gEmDouble: Float64 = 0.0
var gEmString: String = ""
var gEmCross: Int32 = 0

// 阶段1 回调：连接 A。到阈值后 stop 定时器（避免已入队的事件再次触发）再 quit。
let onTimeoutA: VoidCallback = { =>
    if (gCountA < 3) { gCountA += 1 }
    println("  [timeout] callback A fired, countA = ${gCountA}")
    if (gCountA >= 3) {
        if (let Some(t) <- gTimer) { t.stop() }
        QApp.quit()
    }
}

// 阶段2 回调：用 B 替换 A（验证替换式连接：A 不应再触发）
let onTimeoutB: VoidCallback = { =>
    if (gCountB < 3) { gCountB += 1 }
    println("  [timeout] callback B fired, countB = ${gCountB}")
    if (gCountB >= 3) {
        if (let Some(t) <- gTimer) { t.stop() }
        QApp.quit()
    }
}

// 阶段3 看门狗：仅用于控制 phase3 的事件循环退出（与 timer 无关）
let onWatchdog: VoidCallback = { =>
    gWatchdogTicks += 1
    if (gWatchdogTicks >= 3) {
        QApp.quit()
    }
}

// 用于验证闭包捕获外部可变状态：用对象字段承载可变计数，
// 规避 Cangjie「捕获可变变量需直接调用」的限制（捕获不可变引用，改其字段）。
class CaptureCounter {
    public var value: Int32 = 0
}

main() {
    println("=== CJQT6 信号桥接 P0 修复 无头冒烟测试 (offscreen) ===")
    let app = QApplication()
    let timer = QTimer()
    gTimer = timer
    timer.setInterval(30)

    // 阶段1：连接回调 A 并运行事件循环
    println("[phase1] 连接回调 A")
    timer.setOnTimeout(onTimeoutA)
    timer.start()
    let r1 = app.exec()
    println("[phase1] 循环结束后：countA=${gCountA}, countB=${gCountB}")

    // 阶段2：用 B 替换 A（替换式语义），A 必须停止触发
    println("[phase2] 用 B 替换 A（预期 A 不再触发）")
    timer.setOnTimeout(onTimeoutB)
    timer.start()
    let r2 = app.exec()
    println("[phase2] 循环结束后：countA=${gCountA}, countB=${gCountB}")

    // 阶段3：真正断开 timer 的 timeout 信号，用 watchdog 控循环，
    //        验证断连后 B 的旧 lambda 不再被调用（旧版假断开会让 B 继续累加）
    println("[phase3] disconnectTimeout() 后预期 B 不再触发")
    let watch = QTimer()
    watch.setInterval(30)
    watch.setOnTimeout(onWatchdog)
    timer.disconnectTimeout()
    gCountBBefore = gCountB
    watch.start()
    let r3 = app.exec()
    watch.stop()
    watch.close()
    println("[phase3] 看门狗 tick=${gWatchdogTicks}, countB=${gCountB} (断开前=${gCountBBefore})")

    timer.close()
    gTimer = None

    // 阶段4：QPushButton.pressed 句柄断开（P1a/P1b）—— 按钮信号在无头环境无法触发，
    //        这里运行时验证 connect -> 句柄.disconnect()（真断开并翻转 isConnected）-> 重连 链路。
    println("[phase4] QPushButton.pressed 句柄断开 (P1a/P1b 运行时验证)")
    let btn = QPushButton()
    let pconn = btn.setOnPressed({ => /* offscreen 不触发，仅验证句柄 API */ })
    let p1 = pconn.isConnected()
    println("  setOnPressed 返回句柄, isConnected=${p1}")
    pconn.disconnect()   // 句柄断开：路由到 qButtonDisconnectPressed（新 native 真断开）+ 翻转标志
    let p2 = pconn.isConnected()
    println("  pconn.disconnect() 后 isConnected=${p2}")
    let pconn2 = btn.setOnPressed({ => })
    let p3 = pconn2.isConnected()
    println("  重新连接 isConnected=${p3}")
    pconn2.disconnect()
    btn.close()

    // 阶段5：P1c 闭包捕获 —— 端到端验证「捕获外部状态」的回调（旧 VoidCallback 路径做不到）。
    //        用 QTimer（无头环境也会触发 timeout）驱动；可变计数用对象字段承载，
    //        以规避 Cangjie「捕获可变变量需直接调用」的限制（捕获不可变引用，改其字段）。
    println("[phase5] P1c 闭包捕获 (setOnTimeoutCapture 捕获外部状态)")
    let capCounter = CaptureCounter()    // let 绑定（不可变引用），内部字段可变
    let localTag = "CAP"                 // 局部常量，被闭包捕获
    let tcap = QTimer()
    tcap.setInterval(20)
    let capConn = tcap.setOnTimeoutCapture({ =>
        capCounter.value += 1
        println("  [capture] capCounter.value=${capCounter.value}, localTag=${localTag}")
        if (capCounter.value >= 3) {
            QApp.quit()                  // 捕获并调用全局退出（证明闭包持有外部作用域）
        }
    })
    let capConnected = capConn.isConnected()
    tcap.start()
    let r5 = app.exec()
    tcap.stop()
    println("  phase5 捕获回调触发次数=${capCounter.value} (期望 >=3), isConnected=${capConnected}")

    // 断开捕获连接：native 真断开 + Cangjie 注销闭包（unregisterVoidCallback）
    let capturedBeforeDisconnect = capCounter.value
    capConn.disconnect()
    let capConnectedAfter = capConn.isConnected()
    // 用看门狗定时器驱动事件循环，期间捕获闭包不得再触发
    let wd = QTimer()
    wd.setInterval(20)
    wd.setOnTimeout({ => QApp.quit() })
    wd.start()
    let r5b = app.exec()
    wd.stop()
    wd.close()
    let capDeltaAfterDisconnect = capCounter.value - capturedBeforeDisconnect
    println("  phase5 断开后 capCounter 增量=${capDeltaAfterDisconnect} (期望 0), isConnected(after)=${capConnectedAfter}")
    tcap.close()

    // 阶段6：新增统一 disconnect()（断开该控件全部信号）—— 验证运行时真断开。
    println("[phase6] 统一 disconnect() 断开全部信号 (P0 收尾：命名统一)")
    // 6a: QTimer.disconnect() 应真正断开 timeout（含捕获连接），运行期不再发射
    let cap6 = CaptureCounter()
    let tm6 = QTimer()
    tm6.setInterval(20)
    tm6.setOnTimeoutCapture({ =>
        cap6.value += 1
        println("  [phase6] tm6 意外触发, value=${cap6.value}")
    })
    tm6.disconnect()   // 断开该控件全部信号（此处即 timeout）
    tm6.start()
    let w6 = QTimer()
    w6.setInterval(80)
    w6.setOnTimeoutCapture({ => QApp.quit() })
    w6.start()
    let r6 = app.exec()
    tm6.stop()
    w6.stop()
    w6.close()
    tm6.close()
    println("  phase6 tm6 触发次数=${cap6.value} (期望 0，证明 disconnect() 真断开)")

    // 6b: 多信号控件 QPushButton.disconnect() 应断开全部信号且不崩溃、可重连
    let btn6 = QPushButton()
    btn6.setOnClick({ => })
    btn6.setOnPressed({ => })
    btn6.disconnect()              // 断开 clicked/pressed/released/toggled/clickedChecked
    btn6.setOnClick({ => })        // 重连仍可（native 替换式连接）
    btn6.disconnectClick()
    btn6.close()
    println("  phase6 QPushButton.disconnect() 调用正常")

    // 阶段7：P2 自定义信号 + emit —— SignalEmitter 通用信号发射器
    println("[phase7] P2 自定义信号 + emit (SignalEmitter)")
    let em = SignalEmitter()

    // 7a: void 信号 —— 同线程 emit 同步触发（AutoConnection -> 同线程 DirectConnection）
    gEmVoid = 0
    em.setOnVoid({ => gEmVoid += 1 })
    em.emitVoid(); em.emitVoid(); em.emitVoid()
    let emVoidA = gEmVoid          // 期望 3（同线程同步触发）
    println("  phase7a void 信号触发次数=${emVoidA} (期望 3)")

    // 7b: 断开 void，再 emit 不应再触发
    em.disconnectVoid()
    em.emitVoid()
    let emVoidB = gEmVoid          // 期望仍为 3
    println("  phase7b 断开后 void 触发次数=${emVoidB} (期望 3)")

    // 7c: int / double / string 信号
    gEmInt = 0; gEmDouble = 0.0; gEmString = ""
    em.setOnInt({ v => gEmInt = v })
    em.setOnDouble({ v => gEmDouble = v })
    em.setOnString({ s => gEmString = s.toString() })
    em.emitInt(42)
    em.emitDouble(3.14)
    em.emitString("hello")
    let emIntA = gEmInt; let emDblA = gEmDouble; let emStrA = gEmString
    println("  phase7c int=${emIntA}, double=${emDblA}, string='${emStrA}' (期望 42/3.14/hello)")

    // 7d: 闭包捕获版本（P1c 风格）在 emitter 上同样有效
    let capEm = CaptureCounter()
    em.setOnVoidCapture({ => capEm.value += 1 })
    em.emitVoid()
    let capEmA = capEm.value       // 期望 1（仅捕获回调触发；7b 已断开旧 void 监听）
    println("  phase7d 捕获回调触发次数=${capEmA} (期望 1)")
    em.disconnectVoid()
    em.close()

    // 阶段8：跨线程 QueuedConnection —— 工作线程 emit，监听器在 GUI 线程事件循环中被调用
    println("[phase8] 跨线程 QueuedConnection (spawn 工作线程 emit, GUI 线程事件循环接收)")
    let em8 = SignalEmitter()
    gEmCross = 0
    // 关键：退出由 GUI 线程回调驱动（收到满 5 次后在本线程内调用 QApp.quit()）。
    // Queued 信号经事件循环投递到 GUI 线程，回调天然在 GUI 线程执行，quit 安全。
    em8.setOnVoid({ =>
        gEmCross += 1
        if (gEmCross >= 5) {
            QApp.quit()
        }
    }, ConnectionType.Queued)
    // 看门狗兜底：若跨线程投递异常未达，2s 后强制退出，避免死等
    let wd8 = QTimer()
    wd8.setInterval(2000)
    wd8.setOnTimeoutCapture({ => QApp.quit() })
    wd8.start()
    // 工作线程：仅跨线程 emit 5 次（Queued -> 投递到 GUI 线程事件循环）。
    // 严禁在此线程调用 QApp.quit()：若主线程尚未进入 app.exec()，exit() 会置退出
    // 标志使 exec() 立即返回，已入队的 5 个事件将被丢弃（emCrossA==0）。
    spawn { =>
        for (i in 0..5) {
            em8.emitVoid()
        }
    }
    let r8 = app.exec()
    wd8.stop()
    wd8.close()
    let emCrossA = gEmCross
    println("  phase8 跨线程 Queued 接收次数=${emCrossA} (期望 5)")
    em8.close()

    app.delete()

    println("=== 结果 ===")
    println("countA = ${gCountA} (期望 3，且 phase2 中不再增长 => 替换式生效)")
    println("countB = ${gCountB} (期望 3，phase2 由 B 触发)")
    println("phase3 countB 变化 = ${gCountB - gCountBBefore} (期望 0，证明真断开)")
    println("phase4 pressed 句柄: 连接=${p1}, 断开=${p2}, 重连=${p3} (期望 true,false,true)")
    println("phase5 捕获触发=${capCounter.value} (期望 >=3), 断开后增量=${capDeltaAfterDisconnect} (期望 0)")
    println("phase5 句柄: 连接=${capConnected}, 断开=${capConnectedAfter} (期望 true,false)")
    println("phase6 disconnect() 触发=${cap6.value} (期望 0，证明统一 disconnect() 真断开)")
    println("phase7 void: a=${emVoidA}, b=${emVoidB} (期望 3,3)")
    println("phase7 int/double/string: ${emIntA}/${emDblA}/'${emStrA}' (期望 42/3.14/hello)")
    println("phase7 捕获: ${capEmA} (期望 1)")
    println("phase8 跨线程 Queued 接收=${emCrossA} (期望 5)")

    // 验证点：
    //  1) countA == 3：phase2 用 B 替换 A 后，A 的旧 lambda 未被残留触发；
    //  2) countB == 3：phase2 中 B 正常派发，且替换式连接未导致重复叠加；
    //  3) phase3 ΔcountB == 0：disconnectTimeout 真正断开了连接（旧版假断开会让 B 继续累加）；
    //  4) phase4 p1/p2/p3 == true/false/true：按钮 pressed 句柄的 connect/disconnect/重连链路可用（P1a）；
    //  5) phase5：捕获闭包能增局部变量并触发 >=3 次（证明闭包捕获生效），且断开后增量 == 0
    //            （证明捕获连接真断开 + 闭包被注销，注册表无泄漏）。
    //  6) phase6：统一 disconnect() 断开该控件全部信号（含捕获连接的 timeout）后，tm6 不再发射
    //            （cap6.value == 0），证明新增的 disconnect() 是真正的运行时断开。
    let ok =
        (gCountA == 3) &&
        (gCountB == 3) &&
        (gCountB - gCountBBefore == 0) &&
        (p1 == true) && (p2 == false) && (p3 == true) &&
        (capCounter.value >= 3) &&
        (capDeltaAfterDisconnect == 0) &&
        (capConnected == true) && (capConnectedAfter == false) &&
        (cap6.value == 0) &&
        (emVoidA == 3) && (emVoidB == 3) &&
        (emIntA == 42) && (emDblA == 3.14) && (emStrA == "hello") &&
        (capEmA == 1) &&
        (emCrossA == 5)
    if (ok) {
        println("PASS: 回调派发 + 替换式连接 + 真断开 + 按钮 pressed 句柄 + P1c 闭包捕获 + 统一 disconnect() + P2 自定义信号/emit + 跨线程 QueuedConnection 均正常")
    } else {
        println("FAIL: 信号桥接仍异常 (countA=${gCountA}, countB=${gCountB}, phase3Δ=${gCountB - gCountBBefore}, phase4=${p1}/${p2}/${p3}, phase5=${capCounter.value}/${capDeltaAfterDisconnect}/${capConnected}/${capConnectedAfter}, phase6=${cap6.value}, phase7=${emVoidA}/${emVoidB}/${emIntA}/${emDblA}/${emStrA}/${capEmA}, phase8=${emCrossA})")
    }
}
