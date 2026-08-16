package cjqt6.test

// =====================================================================
// 菜单模块测试（src/menu/menu.cj）
// 覆盖：QAction / QMenu / QMenuBar / QToolBar / QStatusBar / QMainWindow
// 每个类测构造/基本属性/getPtr/close/checkValid + 主要公有方法
// =====================================================================

import cjqt6.core.*
import cjqt6.menu.*
import std.unittest.*

// CFunc 回调（顶层 let，不捕获局部变量）
private let gActionTriggered: VoidCallback = { => () }
var gActionTriggeredCount: Int32 = 0

// ---------------------------------------------------------------------
// QAction 测试
// ---------------------------------------------------------------------
@Test
class QActionTests {
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
    func testCreate() {
        let act = QAction("打开")
        @Assert(act.isValid())
        @Expect(act.isClosed(), false)
        @Expect(act.getPtr() != 0, true)
        act.close()
        @Expect(act.isClosed(), true)
    }

    @TestCase
    func testTextRoundtrip() {
        let act = QAction("保存")
        @Expect(act.text(), "保存")
        act.setText("另存为")
        @Expect(act.text(), "另存为")
        act.close()
    }

    @TestCase
    func testSetShortcut() {
        let act = QAction("Open")
        act.setShortcut("Ctrl+O")
        act.close()
        @Assert(true)
    }

    @TestCase
    func testCheckable() {
        let act = QAction("Toggle")
        @Expect(act.isCheckable(), false)
        act.setCheckable(true)
        @Expect(act.isCheckable(), true)
        act.setCheckable(false)
        @Expect(act.isCheckable(), false)
        act.close()
    }

    @TestCase
    func testChecked() {
        let act = QAction("Opt")
        act.setCheckable(true)
        @Expect(act.isChecked(), false)
        act.setChecked(true)
        @Expect(act.isChecked(), true)
        act.setChecked(false)
        @Expect(act.isChecked(), false)
        act.close()
    }

    @TestCase
    func testEnabled() {
        let act = QAction("Cmd")
        @Expect(act.isEnabled(), true)
        act.setEnabled(false)
        @Expect(act.isEnabled(), false)
        act.setEnabled(true)
        @Expect(act.isEnabled(), true)
        act.close()
    }

    @TestCase
    func testVisible() {
        let act = QAction("Cmd")
        @Expect(act.isVisible(), true)
        act.setVisible(false)
        @Expect(act.isVisible(), false)
        act.setVisible(true)
        @Expect(act.isVisible(), true)
        act.close()
    }

    @TestCase
    func testSetOnTriggeredAndDisconnect() {
        let act = QAction("Run")
        act.setOnTriggered(gActionTriggered)
        act.disconnect()
        act.close()
        @Assert(true)
    }

    @TestCase
    func testSetOnTriggeredCapture() {
        gActionTriggeredCount = 0
        let act = QAction("Run")
        let conn = act.setOnTriggeredCapture({ =>
            gActionTriggeredCount += 1
        })
        @Expect(conn.isConnected(), true)
        conn.disconnect()
        @Expect(conn.isConnected(), false)
        act.close()
    }

    @TestCase
    func testCloseAndCheckValid() {
        let act = QAction("X")
        act.close()
        @Expect(act.isValid(), false)
        @ExpectThrows[ResourceDisposedException](act.checkValid())
    }

    @TestCase
    func testOperationsAfterClose() {
        let act = QAction("X")
        act.close()
        @ExpectThrows[ResourceDisposedException](act.setText("y"))
        @ExpectThrows[ResourceDisposedException](act.text())
        @ExpectThrows[ResourceDisposedException](act.setCheckable(true))
        @ExpectThrows[ResourceDisposedException](act.isEnabled())
        @ExpectThrows[ResourceDisposedException](act.setOnTriggered(gActionTriggered))
    }

    @TestCase
    func testDeleteCompatibility() {
        let act = QAction("X")
        act.delete()
        @Expect(act.isClosed(), true)
    }
}

// ---------------------------------------------------------------------
// QMenu 测试
// ---------------------------------------------------------------------
@Test
class QMenuTests {
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
    func testCreate() {
        let m = QMenu("文件")
        @Assert(m.isValid())
        @Expect(m.isClosed(), false)
        @Expect(m.getPtr() != 0, true)
        m.close()
        @Expect(m.isClosed(), true)
    }

    @TestCase
    func testAddActionReturnsAction() {
        let m = QMenu("文件")
        let a1 = m.addAction("新建")
        @Expect(a1.getPtr() != 0, true)
        @Expect(a1.text(), "新建")
        let a2 = m.addAction("打开")
        @Expect(a2.text(), "打开")
        m.close()
    }

    @TestCase
    func testAddActionPtr() {
        let m = QMenu("文件")
        let external = QAction("外部")
        m.addActionPtr(external.getPtr())
        m.close()
        external.close()
        @Assert(true)
    }

    @TestCase
    func testAddSeparator() {
        let m = QMenu("文件")
        m.addAction("A")
        m.addSeparator()
        m.addAction("B")
        m.close()
        @Assert(true)
    }

    @TestCase
    func testAddMenu() {
        let m = QMenu("文件")
        let sub = m.addMenu("最近打开")
        @Expect(sub.getPtr() != 0, true)
        sub.close()
        m.close()
    }

    @TestCase
    func testSetTitle() {
        let m = QMenu("old")
        m.setTitle("new title")
        m.close()
        @Assert(true)
    }

    @TestCase
    @Tag[requires_gui_dialog]
    func testPopup() {
        let m = QMenu("ctx")
        m.popup(100, 200)
        m.close()
        @Assert(true)
    }

    @TestCase
    func testCloseAndCheckValid() {
        let m = QMenu("X")
        m.close()
        @Expect(m.isValid(), false)
        @ExpectThrows[ResourceDisposedException](m.checkValid())
    }

    @TestCase
    func testOperationsAfterClose() {
        let m = QMenu("X")
        m.close()
        @ExpectThrows[ResourceDisposedException](m.addAction("y"))
        @ExpectThrows[ResourceDisposedException](m.addSeparator())
        @ExpectThrows[ResourceDisposedException](m.setTitle("z"))
        @ExpectThrows[ResourceDisposedException](m.popup(0, 0))
    }
}

// ---------------------------------------------------------------------
// QMenuBar 测试
// ---------------------------------------------------------------------
@Test
class QMenuBarTests {
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
    func testCreate() {
        let mb = QMenuBar()
        @Assert(mb.isValid())
        @Expect(mb.isClosed(), false)
        @Expect(mb.getPtr() != 0, true)
        mb.close()
        @Expect(mb.isClosed(), true)
    }

    @TestCase
    func testAddMenu() {
        let mb = QMenuBar()
        let m1 = mb.addMenu("文件")
        @Expect(m1.getPtr() != 0, true)
        let m2 = mb.addMenu("编辑")
        @Expect(m2.getPtr() != 0, true)
        m1.close()
        m2.close()
        mb.close()
    }

    @TestCase
    func testCloseAndCheckValid() {
        let mb = QMenuBar()
        mb.close()
        @Expect(mb.isValid(), false)
        @ExpectThrows[ResourceDisposedException](mb.checkValid())
    }

    @TestCase
    func testOperationsAfterClose() {
        let mb = QMenuBar()
        mb.close()
        @ExpectThrows[ResourceDisposedException](mb.addMenu("x"))
    }

    @TestCase
    func testDeleteCompatibility() {
        let mb = QMenuBar()
        mb.delete()
        @Expect(mb.isClosed(), true)
    }
}

// ---------------------------------------------------------------------
// QToolBar 测试
// ---------------------------------------------------------------------
@Test
class QToolBarTests {
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
    func testCreateWithTitle() {
        let tb = QToolBar("主工具栏")
        @Assert(tb.isValid())
        @Expect(tb.isClosed(), false)
        @Expect(tb.getPtr() != 0, true)
        tb.close()
        @Expect(tb.isClosed(), true)
    }

    @TestCase
    func testCreateDefault() {
        let tb = QToolBar()
        @Assert(tb.isValid())
        tb.close()
    }

    @TestCase
    func testAddActionAndSeparator() {
        let tb = QToolBar("main")
        let act = QAction("Run")
        tb.addAction(act.getPtr())
        tb.addSeparator()
        act.close()
        tb.close()
        @Assert(true)
    }

    @TestCase
    func testAddWidget() {
        let tb = QToolBar("main")
        // 用任意非零指针测试 addWidget 不崩溃（实际场景传 QWidget.getPtr()）
        tb.addWidget(0)
        tb.close()
        @Assert(true)
    }

    @TestCase
    func testSetMovable() {
        let tb = QToolBar("main")
        tb.setMovable(true)
        tb.setMovable(false)
        tb.close()
        @Assert(true)
    }

    @TestCase
    func testCloseAndCheckValid() {
        let tb = QToolBar("x")
        tb.close()
        @Expect(tb.isValid(), false)
        @ExpectThrows[ResourceDisposedException](tb.checkValid())
    }

    @TestCase
    func testOperationsAfterClose() {
        let tb = QToolBar("x")
        tb.close()
        @ExpectThrows[ResourceDisposedException](tb.addSeparator())
        @ExpectThrows[ResourceDisposedException](tb.setMovable(true))
    }
}

// ---------------------------------------------------------------------
// QStatusBar 测试
// ---------------------------------------------------------------------
@Test
class QStatusBarTests {
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
    func testCreate() {
        let sb = QStatusBar()
        @Assert(sb.isValid())
        @Expect(sb.isClosed(), false)
        @Expect(sb.getPtr() != 0, true)
        sb.close()
        @Expect(sb.isClosed(), true)
    }

    @TestCase
    func testShowMessage() {
        let sb = QStatusBar()
        sb.showMessage("就绪")
        sb.showMessage("处理中...")
        sb.clearMessage()
        sb.close()
        @Assert(true)
    }

    @TestCase
    func testShowMessageWithTimeout() {
        let sb = QStatusBar()
        sb.showMessageWithTimeout("临时消息", 2000)
        sb.clearMessage()
        sb.close()
        @Assert(true)
    }

    @TestCase
    func testAddWidget() {
        let sb = QStatusBar()
        sb.addWidget(0)
        sb.close()
        @Assert(true)
    }

    @TestCase
    func testAddWidgetWithStretch() {
        let sb = QStatusBar()
        sb.addWidgetWithStretch(0, 2)
        sb.close()
        @Assert(true)
    }

    @TestCase
    func testCloseAndCheckValid() {
        let sb = QStatusBar()
        sb.close()
        @Expect(sb.isValid(), false)
        @ExpectThrows[ResourceDisposedException](sb.checkValid())
    }

    @TestCase
    func testOperationsAfterClose() {
        let sb = QStatusBar()
        sb.close()
        @ExpectThrows[ResourceDisposedException](sb.showMessage("x"))
        @ExpectThrows[ResourceDisposedException](sb.clearMessage())
        @ExpectThrows[ResourceDisposedException](sb.addWidget(0))
    }
}

// ---------------------------------------------------------------------
// QMainWindow 测试
// ---------------------------------------------------------------------
@Test
class QMainWindowTests {
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
    func testCreate() {
        let w = QMainWindow()
        @Assert(w.isValid())
        @Expect(w.isClosed(), false)
        @Expect(w.getPtr() != 0, true)
        w.close()
        @Expect(w.isClosed(), true)
    }

    @TestCase
    func testSetTitle() {
        let w = QMainWindow()
        w.setTitle("主窗口")
        w.close()
        @Assert(true)
    }

    @TestCase
    func testResize() {
        let w = QMainWindow()
        w.resize(800, 600)
        w.close()
        @Assert(true)
    }

    @TestCase
    func testShowHide() {
        let w = QMainWindow()
        w.show()
        w.hide()
        w.close()
        @Assert(true)
    }

    @TestCase
    func testSetMenuBar() {
        let w = QMainWindow()
        let mb = QMenuBar()
        w.setMenuBar(mb.getPtr())
        mb.close()
        w.close()
        @Assert(true)
    }

    @TestCase
    func testAddToolBar() {
        let w = QMainWindow()
        let tb = QToolBar("main")
        w.addToolBar(tb.getPtr())
        tb.close()
        w.close()
        @Assert(true)
    }

    @TestCase
    func testSetStatusBar() {
        let w = QMainWindow()
        let sb = QStatusBar()
        w.setStatusBar(sb.getPtr())
        sb.close()
        w.close()
        @Assert(true)
    }

    @TestCase
    func testSetCentralWidget() {
        let w = QMainWindow()
        w.setCentralWidget(0)
        w.close()
        @Assert(true)
    }

    @TestCase
    func testFullWindowSetup() {
        let w = QMainWindow()
        w.setTitle("完整窗口")
        w.resize(1024, 768)
        let mb = QMenuBar()
        let fileMenu = mb.addMenu("文件")
        fileMenu.addAction("新建")
        fileMenu.addAction("退出")
        w.setMenuBar(mb.getPtr())
        let tb = QToolBar("主工具栏")
        let act = QAction("保存")
        tb.addAction(act.getPtr())
        w.addToolBar(tb.getPtr())
        let sb = QStatusBar()
        sb.showMessage("就绪")
        w.setStatusBar(sb.getPtr())
        act.close()
        fileMenu.close()
        mb.close()
        tb.close()
        sb.close()
        w.close()
        @Assert(true)
    }

    @TestCase
    func testCloseAndCheckValid() {
        let w = QMainWindow()
        w.close()
        @Expect(w.isValid(), false)
        @ExpectThrows[ResourceDisposedException](w.checkValid())
    }

    @TestCase
    func testOperationsAfterClose() {
        let w = QMainWindow()
        w.close()
        @ExpectThrows[ResourceDisposedException](w.show())
        @ExpectThrows[ResourceDisposedException](w.setTitle("x"))
        @ExpectThrows[ResourceDisposedException](w.resize(1, 1))
        @ExpectThrows[ResourceDisposedException](w.setMenuBar(0))
    }
}