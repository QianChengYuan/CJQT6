package cjqt6.test

import cjqt6.core.*
import cjqt6.richwidgets.*
import cjqt6.widgets.*
import std.unittest.*

@Test
class SwitchTests {
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

    @TestCase
    func testCreateAndToggle() {
        let sw = Switch()
        @Expect(sw.isChecked(), false)
        sw.setChecked(true)
        @Expect(sw.isChecked(), true)
        sw.toggle()
        @Expect(sw.isChecked(), false)
        @Expect(sw.isValid(), true)
        sw.close()
    }

    @TestCase
    func testSetText() {
        let sw = Switch()
        sw.setText("开启")
        @Expect(sw.isValid(), true)
        sw.close()
    }

    @TestCase
    func testClose() {
        let sw = Switch()
        sw.close()
        @Expect(sw.isClosed(), true)
        @Expect(sw.isValid(), false)
    }
}

@Test
class ToastTests {
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

    @TestCase
    func testCreateAndClose() {
        let toast = Toast("加载中...", 3000)
        @Expect(toast.isClosed(), false)
        toast.close()
        @Expect(toast.isClosed(), true)
    }

    @TestCase
    func testCloseIdempotent() {
        let toast = Toast("加载中...", 3000)
        toast.close()
        toast.close()
        @Expect(toast.isClosed(), true)
    }
}

// ---------------------------------------------------------------------
// P1-5：Toast 的线程要求与回归覆盖
// 历史根因：在**非** QApplication 所属线程销毁「已显示」的顶层窗口（Toast 的裸
// QLabel），会阻塞在
//   QWidget::~QWidget → QWindow::close() → QWindowSystemInterface::flushWindowSystemEvents()
//   → QWaitCondition::wait()
// 上永久挂起（CPU 0%、不会自愈）；此前观察到的「时序敏感」其实是测试框架把用例派到
// 哪个 adopted 线程的差异（与 app 同线程则通过、否则挂起）。
// 现已在**桥接层根治**：所有 qXxxDelete 统一走 cjqt6SafeDelete，非对象所属线程的
// 删除改为 deleteLater() 排队到对象所属线程执行，不再同步 flush
// （见 native/includes/bridge_delete.h）。
// 因此现在：`close()` 可在任意线程调用；`show()`（创建/显示顶层窗口）仍要求 GUI 线程。
// ---------------------------------------------------------------------

// P1-5 回归：非 GUI 线程守卫是否生效（用文件级全局承接子线程结果）
var gToastGuardCaught: Bool = false
var gToastGuardOtherThread: Bool = false

@Test
class ToastThreadGuardTests {
    /// P1-5 回归：非 GUI 线程的 GUI 操作快速失败。
    /// 注意：Cangjie `spawn` 是 M:N 调度，新线程既可能落在与调用方不同的 OS 线程，也可能
    /// 落到「恰好就是 app 所属线程」的池线程上（此时守卫按设计不拦截）。因此多轮探测，
    /// 判据是**与 app 所属线程比较**（而非与用例线程比较）：只要测到 app 线程之外的线程，
    /// 就要求它必须抛守卫异常；一轮都没测到则视为本环境不适用（不判失败）。
    @TestCase
    func testGuardThrowsOnNonGuiThread() {
        let app = QApplication()
        let appPtr = guiThreadPtr()
        gToastGuardCaught = false
        gToastGuardOtherThread = false
        var attempt = 0
        while (attempt < 12 && !gToastGuardOtherThread) {
            let fut = spawn {
                // 仅当「不是 app 所属线程」时才有守卫可验；若本轮恰好落在 app 线程，跳过
                if (QThread.currentThreadPtr() != appPtr) {
                    gToastGuardOtherThread = true
                    try {
                        checkGuiThread("回归探针")
                    } catch (_: GuiThreadViolationException) {
                        gToastGuardCaught = true
                    }
                }
                0
            }
            fut.get()
            attempt += 1
        }
        if (gToastGuardOtherThread) {
            @Expect(gToastGuardCaught, true)
        } else {
            @Expect(true)
        }
    }

    /// 未显示过的实例：跨线程 close() 直接安全（对象销毁由桥接层按线程归属兜底）
    @TestCase
    func testCloseNotShownFromOtherThreadIsSafe() {
        let app = QApplication()
        let toast = Toast("未显示", 3000)
        let fut = spawn {
            toast.close()
            0
        }
        fut.get()
        @Expect(toast.isClosed(), true)
    }

    /// 已显示的实例：跨线程 close() 不再阻塞 —— P1-5 根治的直接回归。
    /// 修复前该调用会永久阻塞在 flush 等待上（用例超时）；若桥接层回退为「同线程外直接
    /// delete」，本用例同样会挂起。判据是「调用能返回、且状态正确置位」。
    @TestCase
    func testCloseShownToastFromOtherThreadIsSafe() {
        let app = QApplication()
        if (!isGuiThread()) {
            // 本用例线程不是 GUI 线程：按设计 show() 会抛守卫异常，故不展示顶层窗口
            @Expect(true)
            return
        }
        let toast = Toast("已显示", 3000)
        toast.show()
        gToastGuardCaught = false
        let fut = spawn {
            try {
                toast.close()
            } catch (_: GuiThreadViolationException) {
                gToastGuardCaught = true
            }
            0
        }
        fut.get()
        // 跨线程销毁已由桥接层兜底：不再抛守卫异常，且状态正确置位
        @Expect(gToastGuardCaught, false)
        @Expect(toast.isClosed(), true)
    }
}

// ---------------------------------------------------------------------
// P1-5 根治的决定性回归：非所属线程销毁「已显示」的顶层控件必须立即返回。
// 这里刻意绕开 Toast.show() 的 GUI 线程守卫（守卫拦的是「显示」动作），直接用 QLabel
// 构造最小复现条件——「已显示的顶层控件 + 非所属线程销毁」：
//   修复前 → 阻塞在 QWindowSystemInterface::flushWindowSystemEvents 的等待上，
//            本用例会一直挂到用例超时（机器可读的失败信号）；
//   修复后 → 桥接层判定非所属线程，改走 deleteLater()，调用立即返回。
// spawn 是 M:N 调度，可能落到同一 OS 线程，故多轮探测直到拿到不同线程。
// ---------------------------------------------------------------------
var gCrossThreadClosed: Bool = false
var gCrossThreadLanded: Bool = false

@Test
class CrossThreadDestroyTests {
    @TestCase
    func testDestroyShownTopLevelWidgetFromOtherThread() {
        let app = QApplication()
        let label = QLabel()
        label.setText("P1-5 跨线程销毁回归")
        label.show()
        let owner = QThread.currentThreadPtr()
        gCrossThreadClosed = false
        gCrossThreadLanded = false
        var attempt = 0
        while (attempt < 20 && !gCrossThreadLanded) {
            let fut = spawn {
                if (QThread.currentThreadPtr() != owner) {
                    gCrossThreadLanded = true
                    // 关键调用：非所属线程销毁已显示的顶层控件
                    label.close()
                    gCrossThreadClosed = true
                }
                0
            }
            fut.get()
            attempt += 1
        }
        if (gCrossThreadLanded) {
            @Expect(gCrossThreadClosed, true)
            @Expect(label.isClosed(), true)
        } else {
            // 环境始终拿到同一 OS 线程（M:N 调度偶发），本用例不适用
            label.close()
            @Expect(true)
        }
    }
}

@Test
class SearchBoxTests {
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

    @TestCase
    func testTextAndClear() {
        let box = SearchBox()
        @Expect(box.text(), "")
        box.setText("hello")
        @Expect(box.text(), "hello")
        box.clear()
        @Expect(box.text(), "")
        box.close()
    }

    @TestCase
    func testSetPlaceholder() {
        let box = SearchBox()
        box.setPlaceholder("请输入关键词")
        @Expect(box.isValid(), true)
        box.close()
    }
}

@Test
class FormTests {
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

    @TestCase
    func testAddRow() {
        let form = Form("用户信息")
        form.addRow("姓名", QLineEdit())
        form.addRow("邮箱", QLineEdit())
        @Expect(form.isValid(), true)
        form.close()
    }

    @TestCase
    func testSetTitle() {
        let form = Form()
        form.setTitle("测试表单")
        @Expect(form.isValid(), true)
        form.close()
    }
}

@Test
class DateRangePickerTests {
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

    @TestCase
    func testSetAndGet() {
        let picker = DateRangePicker()
        picker.setStartDate(2024, 1, 1)
        picker.setEndDate(2024, 12, 31)
        @Expect(picker.getStartDate().year(), 2024)
        @Expect(picker.getEndDate().month(), 12)
        @Expect(picker.getEndDate().day(), 31)
        picker.close()
    }

    @TestCase
    func testDisplayFormat() {
        let picker = DateRangePicker()
        picker.setDisplayFormat("yyyy/MM/dd")
        @Expect(picker.isValid(), true)
        picker.close()
    }
}

@Test
class PaginationTests {
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

    @TestCase
    func testCreateAndSetTotal() {
        let pg = Pagination()
        pg.setTotalPages(5)
        @Expect(pg.getTotalPages(), 5)
        @Expect(pg.getCurrentPage(), 1)
        pg.close()
    }

    @TestCase
    func testSetCurrentPage() {
        let pg = Pagination()
        pg.setTotalPages(10)
        pg.setCurrentPage(3)
        @Expect(pg.getCurrentPage(), 3)
        pg.close()
    }

    @TestCase
    func testOutOfBounds() {
        let pg = Pagination()
        pg.setTotalPages(3)
        pg.setCurrentPage(3)
        pg.setCurrentPage(5)
        @Expect(pg.getCurrentPage(), 3)
        pg.setCurrentPage(0)
        @Expect(pg.getCurrentPage(), 3)
        pg.close()
    }
}

@Test
class GroupCardTests {
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

    @TestCase
    func testCreateAndAddWidget() {
        let card = GroupCard("设置")
        card.addWidget(QLabel())
        card.addWidget(QPushButton())
        @Expect(card.isValid(), true)
        card.close()
    }

    @TestCase
    func testTitle() {
        let card = GroupCard()
        card.setTitle("卡片标题")
        @Expect(card.title(), "卡片标题")
        card.close()
    }
}
