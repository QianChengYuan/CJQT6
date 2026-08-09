package bench

import cjqt6.core.*
import cjqt6.widgets.*
import std.time.*

// ============================================================
// CJQT6 信号/FFI 性能基准（P1 bench 工程）
// ------------------------------------------------------------
// 目标：量化四条高频路径的单次开销，为 P3 @FastNative 标注提供数据：
//   1) 纯 FFI 往返（getter/setter，含 checkValid 校验）；
//   2) 字符串过 FFI（String→CString→Qt / Qt→CString→String）；
//   3) 信号回调吞吐（DirectConnection，同线程同步触发）；
//   4) 异步路径（runOnUiThread 投递+排空 / QTimer 真实事件循环派发）。
// 运行：配好 Qt 运行时后 `cjpm run`（offscreen 平台，无显示依赖）。
// 方法：MonoTime（单调纳秒钟）测时，先 warmup 再计时，取 ns/op。
// ============================================================

const ITERS: Int64 = 200000
const ASYNC_ITERS: Int64 = 50000

// 全局累加器：防止编译器把热循环里的结果当作死代码消除（读校验值）
var gAccum: Int64 = 0

// 通用测时：warmup 后跑 iters 次，打印 ns/op 与总时长
func bench(name: String, iters: Int64, f: () -> Unit): Unit {
    for (_ in 0..10000) { f() }
    let start = MonoTime.now()
    for (_ in 0..iters) { f() }
    let end = MonoTime.now()
    let totalNs = (end - start).toNanoseconds()
    let perOp = Float64(totalNs) / Float64(iters)
    println("  ${name}: ${Int64(perOp)} ns/op   (共 ${Int64(Float64(totalNs) / 1000000.0)} ms / ${iters} 次)")
}

// 异步任务计数载体（闭包捕获不可变引用、改其字段，规避捕获可变变量的限制）
class BenchCounter {
    public var value: Int64 = 0
}

// runOnUiThread 端到端成本：投递 n 个任务 + 事件循环排空
func benchRunOnUiThread(app: QApplication, n: Int64): Unit {
    let c = BenchCounter()
    let start = MonoTime.now()
    for (_ in 0..n) {
        UiPoster.runOnUiThread({ =>
            c.value += 1
            if (c.value >= n) { QApp.quit() }
        })
    }
    app.exec()
    let end = MonoTime.now()
    let totalNs = (end - start).toNanoseconds()
    let perOp = Float64(totalNs) / Float64(n)
    println("  runOnUiThread (post+drain, n=${n}): ${Int64(perOp)} ns/op   (共 ${Int64(Float64(totalNs) / 1000000.0)} ms)")
}

// QTimer 真实事件循环信号派发成本：interval=0 定时器触发 n 次
func benchTimer(app: QApplication, n: Int64): Unit {
    let c = BenchCounter()
    let timer = QTimer()
    timer.setInterval(0)
    timer.setOnTimeoutCapture({ =>
        c.value += 1
        if (c.value >= n) { QApp.quit() }
    })
    let start = MonoTime.now()
    timer.start()
    app.exec()
    let end = MonoTime.now()
    timer.stop()
    timer.close()
    let totalNs = (end - start).toNanoseconds()
    let perOp = Float64(totalNs) / Float64(n)
    println("  QTimer(interval=0) 事件循环派发 (n=${n}): ${Int64(perOp)} ns/op   (共 ${Int64(Float64(totalNs) / 1000000.0)} ms)")
}

main() {
    println("=== CJQT6 信号/FFI 性能基准 (offscreen, MonoTime 测时) ===")
    let app = QApplication()
    let spin = QSpinBox()
    let btn = QPushButton()
    let em = SignalEmitter()

    // ---- 基线：纯仓颉闭包调用 + 整数累加（其余用例可比照扣除此成本） ----
    println("[基线]")
    bench("空 lambda + Int64 累加", ITERS, { => gAccum += 1 })

    // ---- 1) 纯 FFI 往返（每 op 含 checkValid → isObjectAlive FFI + 注册表查找 + 目标 FFI） ----
    println("[1] 纯 FFI 往返")
    bench("QSpinBox.value() (Int32 getter)", ITERS, { => gAccum += Int64(spin.value()) })
    bench("QSpinBox.setValue(7) (Int32 setter)", ITERS, { => spin.setValue(7) })
    bench("QSpinBox.isEnabled() (Bool getter)", ITERS, { => if (spin.isEnabled()) { gAccum += 1 } })

    // ---- 2) 字符串过 FFI（含 UTF-16↔UTF-8 转换 + malloc/free） ----
    println("[2] 字符串过 FFI")
    bench("QPushButton.setText (String→CString→Qt)", ITERS, { => btn.setText("CJQT6 基准") })
    bench("QPushButton.text() (Qt→CString→String)", ITERS, { => gAccum += btn.text().size })

    // ---- 3) 信号回调吞吐（AutoConnection 同线程=DirectConnection，emit 同步触发） ----
    println("[3] 信号回调吞吐 (DirectConnection)")
    em.setOnVoid({ => gAccum += 1 })
    bench("SignalEmitter.emitVoid() (void 回调)", ITERS, { => em.emitVoid() })
    em.setOnInt({ v => gAccum += Int64(v) })
    bench("SignalEmitter.emitInt(1) (int 回调)", ITERS, { => em.emitInt(1) })
    em.setOnString({ s => gAccum += Int64(s.toString().size) })
    bench("SignalEmitter.emitString(\"x\") (string 回调)", ITERS, { => em.emitString("x") })

    // ---- 4) 异步路径（含注册表增删 + 事件队列投递 + 派发） ----
    println("[4] 异步路径")
    benchRunOnUiThread(app, ASYNC_ITERS)
    benchTimer(app, ASYNC_ITERS)

    println("  (累加器校验 gAccum=${gAccum}，非零即防死代码消除生效)")
    println("=== 结论速查 ===")
    println("  @FastNative 只减 FFI thunk（数 ns 级）；若 getter 已在数十 ns 量级，标注收益有限。")
    println("  字符串转换/回调派发/事件队列是真正热点：优先减少往返与批量桥接，而非标注高频 getter。")

    em.disconnect()
    em.close()
    btn.close()
    spin.close()
    app.delete()
}
