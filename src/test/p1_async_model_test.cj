package cjqt6.test

import cjqt6.core.*
import cjqt6.views.*
import cjqt6.widgets.*
import std.unittest.*

// =====================================================================
// P1 专项测试
// 1) QAbstractItemModel::notifyDataChanged / notifyLayoutChanged 局部刷新通知
//    （P1-a，配合 QTableView::setModel(QAbstractItemModel) 重载）
// 2) UiPoster / runOnUiThread / runAsync 跨线程回投 UI 线程的唯一出口
// 3) QSpinBox / QDoubleSpinBox::textChanged 文本信号（Qt6 中 valueChanged(QString)
//    已被移除，文本变化走 textChanged）
// =====================================================================

// =====================================================================
// 全局状态（CFunc 回调不捕获局部变量，只能用全局变量）
// =====================================================================
var gMdlRows: Int32 = 3
var gMdlCols: Int32 = 2
var gMdlIndexCalls: Int32 = 0
var gMdlRowQueries: Int32 = 0

// 自定义模型回调：行数/列数/索引（索引返回非零内部 ID，供 dataChanged 建索引）
let mdlRowCountCb: CFunc<(Int64, Int64) -> Int32> = { modelPtr: Int64, parentPtr: Int64 =>
    gMdlRowQueries += 1
    gMdlRows
}
let mdlColCountCb: CFunc<(Int64, Int64) -> Int32> = { modelPtr: Int64, parentPtr: Int64 => gMdlCols }
let mdlIndexCb: CFunc<(Int64, Int32, Int32, Int64) -> Int64> = { modelPtr: Int64, row: Int32, col: Int32, parentPtr: Int64 =>
    gMdlIndexCalls += 1
    Int64(row * 100 + col + 1)
}
let mdlDataCb: CFunc<(Int64, Int64, Int32) -> Int64> = { modelPtr: Int64, indexPtr: Int64, role: Int32 => 0 }
let mdlHeaderCb: CFunc<(Int64, Int32, Int32, Int32) -> Int64> = { modelPtr: Int64, section: Int32, orientation: Int32, role: Int32 => 0 }
let mdlFlagsCb: CFunc<(Int64, Int64) -> Int32> = { modelPtr: Int64, indexPtr: Int64 => 0 }

// UiPoster 测试全局状态
var gP1App: ?QApplication = None
var gP1Watchdog: ?QTimer = None
var gP1UiCount: Int32 = 0
var gP1WorkCount: Int32 = 0
var gP1Order: String = ""
var gP1MainThreadPtr: Int64 = 0
var gP1CbThreadPtr: Int64 = 0

// spinbox textChanged 测试全局状态
var gP1SpinText: String = ""
var gP1SpinValue: Int32 = -1
var gP1DspinText: String = ""
var gP1DspinValue: Float64 = -1.0

// =====================================================================
// QAbstractItemModel 局部刷新通知（P1-a）
// =====================================================================
@Test
class P1ModelNotifyTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    /// notifyDataChanged 通过 index 回调构造 topLeft/bottomRight 索引并发出 dataChanged
    @TestCase
    func testNotifyDataChangedInvokesIndex() {
        gMdlIndexCalls = 0
        let model = QAbstractItemModel()
        model.setOnRowCount(mdlRowCountCb)
        model.setOnColumnCount(mdlColCountCb)
        model.setOnIndex(mdlIndexCb)
        model.notifyDataChanged(0, 0, 2, 1)
        // C++ 侧为 topLeft/bottomRight 各取一次内部 ID
        @Expect(gMdlIndexCalls >= 2, true)
        model.close()
    }

    /// notifyLayoutChanged 发出布局变化通知，不崩溃
    @TestCase
    func testNotifyLayoutChangedSafe() {
        let model = QAbstractItemModel()
        model.setOnRowCount(mdlRowCountCb)
        model.setOnColumnCount(mdlColCountCb)
        model.setOnIndex(mdlIndexCb)
        model.notifyLayoutChanged()
        @Assert(true)
        model.close()
    }

    /// notifyDataChanged 未注册 index 回调时安全跳过（不发 dataChanged）
    @TestCase
    func testDataChangedWithoutIndexCallbackSafe() {
        let model = QAbstractItemModel()
        model.notifyDataChanged(0, 0, 1, 1)
        model.notifyLayoutChanged()
        @Assert(true)
        model.close()
    }

    /// 资源释放后 notify* 抛 ResourceDisposedException
    @TestCase
    func testNotifyThrowsAfterClose() {
        let model = QAbstractItemModel()
        model.close()
        var thrown = false
        try {
            model.notifyDataChanged(0, 0, 1, 1)
        } catch (e: ResourceDisposedException) {
            thrown = true
        }
        @Expect(thrown, true)
    }

    /// QTableView::setModel(QAbstractItemModel) 重载（P1 实时数据表挂载）+ 局部刷新
    @TestCase
    func testTableViewCustomModelOverload() {
        gMdlRowQueries = 0
        gMdlIndexCalls = 0
        let view = QTableView()
        let model = QAbstractItemModel()
        model.setOnRowCount(mdlRowCountCb)
        model.setOnColumnCount(mdlColCountCb)
        model.setOnIndex(mdlIndexCb)
        model.setOnData(mdlDataCb)
        model.setOnHeaderData(mdlHeaderCb)
        model.setOnFlags(mdlFlagsCb)
        view.setModel(model)
        // 挂载后视图会查询模型行列数
        @Expect(gMdlRowQueries >= 1, true)
        // 挂载后局部刷新通知不崩溃
        model.notifyDataChanged(0, 0, 1, 0)
        model.notifyLayoutChanged()
        @Assert(true)
        view.delete()
        model.close()
    }
}

// =====================================================================
// UiPoster / runOnUiThread / runAsync 跨线程回投（P1）
// =====================================================================
@Test
class P1UiPosterTests {

    @BeforeEach
    static func setUp(): Unit {
        gP1App = Some(QApplication())
        gP1Watchdog = None
    }

    @AfterEach
    static func tearDown(): Unit {
        if (let Some(w) <- gP1Watchdog) {
            w.stop()
            w.close()
        }
        gP1Watchdog = None
        if (let Some(a) <- gP1App) {
            a.delete()
        }
        gP1App = None
    }

    /// 安全看门狗：超时后强制退出事件循环，防止测试挂起
    static func armWatchdog(ms: Int32): Unit {
        let w = QTimer()
        gP1Watchdog = Some(w)
        w.setInterval(ms)
        w.setOnTimeout({ => QApp.quit() })
        w.start()
    }

    /// runOnUiThread 投递的闭包在事件循环中异步执行
    @TestCase
    func testRunOnUiThreadExecutes() {
        gP1UiCount = 0
        armWatchdog(3000)
        runOnUiThread({ =>
            gP1UiCount += 1
            QApp.quit()
        })
        if (let Some(a) <- gP1App) { a.exec() }
        @Expect(gP1UiCount, 1)
    }

    /// UiPoster.post 是 runOnUiThread 的别名
    @TestCase
    func testPostAlias() {
        gP1UiCount = 0
        armWatchdog(3000)
        UiPoster.post({ =>
            gP1UiCount += 1
            QApp.quit()
        })
        if (let Some(a) <- gP1App) { a.exec() }
        @Expect(gP1UiCount, 1)
    }

    /// 多次投递保持先进先出顺序
    @TestCase
    func testFifoOrder() {
        gP1Order = ""
        armWatchdog(3000)
        runOnUiThread({ => gP1Order = gP1Order + "a" })
        runOnUiThread({ => gP1Order = gP1Order + "b" })
        runOnUiThread({ =>
            gP1Order = gP1Order + "c"
            QApp.quit()
        })
        if (let Some(a) <- gP1App) { a.exec() }
        @Expect(gP1Order, "abc")
    }

    /// runAsync：工作线程执行 work，onDone 回投 GUI 线程（事件循环中执行）
    @TestCase
    func testRunAsyncDeliversOnGuiThread() {
        gP1UiCount = 0
        gP1MainThreadPtr = QThread.currentThreadPtr()
        gP1CbThreadPtr = 0
        armWatchdog(5000)
        runAsync({ =>
            // 工作线程：模拟耗时任务
            gP1WorkCount += 1
        }, { =>
            gP1CbThreadPtr = QThread.currentThreadPtr()
            gP1UiCount += 1
            QApp.quit()
        })
        if (let Some(a) <- gP1App) { a.exec() }
        @Expect(gP1UiCount, 1)
        @Expect(gP1WorkCount, 1)
        // onDone 必须在 GUI 线程（与测试主线程同一 QThread）执行
        @Expect(gP1CbThreadPtr == gP1MainThreadPtr, true)
    }
}

// =====================================================================
// QSpinBox / QDoubleSpinBox::textChanged 文本信号（P1 文本信号验证）
// Qt6 已移除 valueChanged(QString) 重载，文本变化统一走 textChanged
// =====================================================================
@Test
class P1SpinBoxTextTests {

    @BeforeEach
    static func setUp(): Unit {
        gP1App = Some(QApplication())
        gP1Watchdog = None
    }

    @AfterEach
    static func tearDown(): Unit {
        if (let Some(w) <- gP1Watchdog) {
            w.stop()
            w.close()
        }
        gP1Watchdog = None
        if (let Some(a) <- gP1App) {
            a.delete()
        }
        gP1App = None
    }

    /// QSpinBox::textChanged 在 setValue 时同步触发，收到完整文本
    @TestCase
    func testSpinBoxTextChanged() {
        gP1SpinText = ""
        let sp = QSpinBox()
        sp.setRange(0, 100)
        sp.setOnTextChanged({ t: CString => gP1SpinText = t.toString() })
        sp.setValue(42)
        @Expect(gP1SpinText, "42")
        sp.close()
    }

    /// QDoubleSpinBox::textChanged 在 setValue 时同步触发，收到小数文本
    @TestCase
    func testDoubleSpinBoxTextChanged() {
        gP1DspinText = ""
        let sp = QDoubleSpinBox()
        sp.setRange(0.0, 100.0)
        sp.setOnTextChanged({ t: CString => gP1DspinText = t.toString() })
        sp.setValue(3.14)
        @Expect(gP1DspinText, "3.14")
        sp.close()
    }

    /// valueChanged(数值) 与 textChanged(文本) 并存，互不覆盖
    @TestCase
    func testSpinBoxValueAndTextCoexist() {
        gP1SpinText = ""
        gP1SpinValue = -1
        let sp = QSpinBox()
        sp.setRange(0, 100)
        sp.setOnValueChanged({ v: Int32 => gP1SpinValue = v })
        sp.setOnTextChanged({ t: CString => gP1SpinText = t.toString() })
        sp.setValue(7)
        @Expect(gP1SpinValue, 7)
        @Expect(gP1SpinText, "7")
        sp.close()
    }
}
