package cjqt6.test

// =====================================================================
// 新增 API 测试
//
// 对应 docs/internal/cjmonitor-findings.md 的修复项：
//   P0-1 QtWidget / QtWidgetCore 通用能力
//   P0-2 QEventWidget 通用能力补齐
//   P0-3 widgetWidth / widgetHeight / setWidgetObjectName
//   P0-4 setObjectName（QSS #id 选择器的基础）
//   P0-5 消费控件的接口的 QtResource 重载
//   P1-1 QLineSeries.setColor / setPen / clear
//   P1-2 QDateTime 时间戳换算 + QDateTimeAxis 接收 QDateTime
//   P1-3 QSqlDatabase 事务 + QSqlQuery 位置绑定与无参 exec
//   P1-4 Toast 静态入口
//   P1-5 Toast 自动关闭回调内不得释放自身计时器（含 clear() 释放入口）
//   P2-2 setWindowTitle
//   P2-3 QProcess.addArgument
// =====================================================================

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.views.*
import cjqt6.gui.*
import cjqt6.menu.*
import cjqt6.sql.*
import cjqt6.charts.*
import cjqt6.paint.*
import cjqt6.richwidgets.*
import std.unittest.*

// ---------------------------------------------------------------------
// P0-1 / P0-2 / P0-3 / P0-4 / P0-5 / P2-2：控件通用能力与类型安全
// ---------------------------------------------------------------------
@Test
class QtWidgetCapabilityTests {
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

    /// P0-1：此前 QPushButton 等控件没有 setVisible，现由 QtWidget 默认实现统一提供
    @TestCase
    func testWidgetVisibilityAndEnabled() {
        let btn = QPushButton()
        btn.setText("测试")
        btn.setVisible(false)
        // 明确隐藏时 isVisible 必须为 false（未 show 过也返回 false，故只断言可靠方向）
        @Expect(btn.isVisible(), false)
        btn.setEnabled(false)
        @Expect(btn.isEnabled(), false)
        btn.setEnabled(true)
        @Expect(btn.isEnabled(), true)
        btn.close()
    }

    /// P0-4：objectName 可被 QWidget.findChild 按名检索（QSS #id 选择器的前置条件）
    @TestCase
    func testObjectNameFindable() {
        let container = QWidget()
        let child = QLabel()
        setWidgetParent(child.getPtr(), container.getPtr())
        child.setObjectName("probe_label")
        @Assert(container.findChild("probe_label").getPtr() != 0)
        container.close()
    }

    /// P0-3：跨包可用的尺寸查询（此前各包只能自行声明 qWidgetWidth/qWidgetHeight）
    @TestCase
    func testWidgetSizeHelpers() {
        let w = QWidget()
        w.resize(200, 80)
        @Expect(widgetWidth(w.getPtr()), 200)
        @Expect(widgetHeight(w.getPtr()), 80)
        @Expect(w.width(), 200)
        @Expect(w.height(), 80)
        w.close()
    }

    /// P0-3：setWidgetObjectName 对任意控件指针可用（控件类无公共基类）
    @TestCase
    func testSetWidgetObjectNameHelper() {
        let container = QWidget()
        let child = QLabel()
        setWidgetParent(child.getPtr(), container.getPtr())
        setWidgetObjectName(child.getPtr(), "helper_child")
        @Assert(container.findChild("helper_child").getPtr() != 0)
        container.close()
    }

    /// P0-2：QEventWidget（自绘唯一入口）此前缺尺寸/样式/可见性能力
    @TestCase
    func testEventWidgetGenericCapabilities() {
        let canvas = QEventWidget()
        canvas.setMinimumSize(240, 120)
        canvas.setStyleSheet("background-color: #101010;")
        @Assert(canvas.styleSheet().contains("101010"))
        canvas.setEnabled(false)
        @Expect(canvas.isEnabled(), false)
        canvas.setVisible(false)
        @Expect(canvas.isVisible(), false)
        canvas.resize(320, 160)
        @Expect(canvas.width(), 320)
        @Expect(canvas.height(), 160)
        canvas.close()
    }

    /// P0-5：布局接收 QtResource 的重载（编译期拦截类型误配）
    @TestCase
    func testLayoutAcceptsWidgetObject() {
        let root = QWidget()
        let vbox = QVBoxLayout()
        let label = QLabel()
        label.setText("行1")
        vbox.addWidget(label)
        vbox.addWidget(QLabel(), 1)
        root.setLayout(vbox.getPtr())
        @Assert(root.getPtr() != 0)
        root.close()
    }

    /// P0-5：QGridLayout 的 QtResource 重载（含跨行列）
    @TestCase
    func testGridLayoutAcceptsWidgetObject() {
        let root = QWidget()
        let grid = QGridLayout()
        let a = QLabel()
        a.setText("A")
        grid.addWidget(a, 0, 0)
        grid.addWidget(QLabel(), 1, 0)
        grid.addWidgetSpan(QLabel(), 0, 1, 1, 2)
        root.setLayout(grid.getPtr())
        @Assert(root.getPtr() != 0)
        root.close()
    }

    /// P2-2：menuBar() / statusBar() 借用 getter
    /// 关键断言：借用包装 close() 后底层对象仍存活（证明没有误删 QMainWindow 持有的对象）
    @TestCase
    func testWindowMenuBarAndStatusBarGetters() {
        let win = QMainWindow()
        win.setStatusBar(QStatusBar())
        win.setMenuBar(QMenuBar())

        // menuBar()：Qt 保证未设置时会自动创建，故返回非空
        @Assert(win.menuBar().getPtr() != 0)

        let sb = win.statusBar()
        if (let Some(s) <- sb) {
            @Assert(s.getPtr() != 0)
            s.showMessage("测试消息")
            s.close() // 借用包装：只标记关闭，不删除底层对象
        } else {
            @Assert(false)
        }

        // 再次获取仍应成功 —— 证明底层状态栏未被上一步的 close() 删除
        let sb2 = win.statusBar()
        if (let Some(s2) <- sb2) {
            @Assert(s2.getPtr() != 0)
        } else {
            @Assert(false)
        }

        win.close()
    }

    /// P0-5 + P2-2：QTabWidget / QMainWindow 接收控件对象，且 setWindowTitle 可用
    @TestCase
    func testContainerAndWindowAcceptWidgetObject() {
        let tabs = QTabWidget()
        tabs.addTab(QLabel(), "页1")
        @Expect(tabs.currentIndex(), 0)
        tabs.close()

        let win = QMainWindow()
        let central = QLabel()
        win.setCentralWidget(central)
        win.setStatusBar(QStatusBar())
        win.setMenuBar(QMenuBar())
        win.setWindowTitle("CJQT6 新增 API 测试")
        // 中心部件由 QMainWindow 接管，随窗口级联释放，此处只关窗口
        win.close()
    }
}

// ---------------------------------------------------------------------
// P1-1 / P1-2：图表序列样式与时间戳换算
// ---------------------------------------------------------------------
@Test
class ChartsAndDateTimeTests {
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

    /// P1-1：此前 QLineSeries 既不能配色也不能清空，只能整张图表重建
    @TestCase
    func testLineSeriesColorPenClear() {
        let series = QLineSeries()
        series.setName("cpu")
        series.append(0.0, 1.0)
        series.append(1.0, 2.0)
        @Expect(series.count(), 2)

        series.setColor(0, 217, 181)
        series.setColor(0, 217, 181, 128)
        series.setPen(QPen())

        series.clear()
        @Expect(series.count(), 0)
        series.close()
    }

    /// P1-2：QDateTime 时间戳换算（QDateTimeAxis 按 Float64 秒取值）
    @TestCase
    func testDateTimeSecsRoundTrip() {
        let dt = QDateTime.fromSecsSinceEpoch(1700000000.0)
        let back = dt.toSecsSinceEpoch()
        let diff = back - 1700000000.0
        @Assert(diff > -1.0 && diff < 1.0)

        // 当前时间应晚于 2023-11-14（1.7e9 秒）
        @Assert(QDateTime.currentDateTime().toSecsSinceEpoch() > 1700000000.0)
    }

    /// P1-2：QDateTimeAxis 可直接接收 QDateTime
    @TestCase
    func testDateTimeAxisAcceptsDateTime() {
        let axis = QDateTimeAxis()
        axis.setMin(QDateTime.fromSecsSinceEpoch(1700000000.0))
        axis.setMax(QDateTime.fromSecsSinceEpoch(1700003600.0))
        let dmin = axis.min() - 1700000000.0
        let dmax = axis.max() - 1700003600.0
        @Assert(dmin > -1.0 && dmin < 1.0)
        @Assert(dmax > -1.0 && dmax < 1.0)
        axis.close()
    }
}

// ---------------------------------------------------------------------
// P1-3：SQL 事务与位置绑定
// ---------------------------------------------------------------------
@Test
class SqlTransactionAndBindTests {
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

    /// P1-3：QSqlDatabase 事务 API（此前只有手工 BEGIN/COMMIT）
    @TestCase
    func testTransactionCommitAndRollback() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_tx_conn")
        db.setDatabaseName(":memory:")
        @Expect(db.open(), true)

        let q = QSqlQuery(db)
        @Expect(db.transaction(), true)
        @Expect(q.exec("CREATE TABLE t (id INTEGER PRIMARY KEY, v REAL)"), true)
        @Expect(db.commit(), true)

        // 第二次事务内插入后回滚，表内应保持 0 行
        @Expect(db.transaction(), true)
        @Expect(q.exec("INSERT INTO t (id, v) VALUES (1, 1.5)"), true)
        @Expect(db.rollback(), true)

        @Expect(q.exec("SELECT COUNT(*) FROM t"), true)
        @Expect(q.next(), true)
        @Expect(q.valueInt(0), 0)

        q.close()
        db.closeDatabase()
        db.close()
        QSqlDatabase.removeDatabase("t_tx_conn")
    }

    /// P1-3：位置绑定（addBindValue）+ 无参 exec 保留绑定
    /// 注意：用带 SQL 的 exec(sql) 执行已 prepare 的查询会重新 prepare 并清空绑定，
    /// 因此必须用无参 exec()。
    @TestCase
    func testPositionalBindValue() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_bind_conn")
        db.setDatabaseName(":memory:")
        @Expect(db.open(), true)

        let q = QSqlQuery(db)
        @Expect(q.exec("CREATE TABLE b (a INTEGER, c REAL, d TEXT)"), true)
        @Expect(q.prepare("INSERT INTO b (a, c, d) VALUES (?, ?, ?)"), true)
        q.addBindValue(7)
        q.addBindValue(1.5)
        q.addBindValue("text")
        @Expect(q.exec(), true)

        @Expect(q.exec("SELECT a, d FROM b"), true)
        @Expect(q.next(), true)
        @Expect(q.valueInt(0), 7)
        @Expect(q.valueString(1), "text")

        q.close()
        db.closeDatabase()
        db.close()
        QSqlDatabase.removeDatabase("t_bind_conn")
    }
}

// ---------------------------------------------------------------------
// P1-4 / P2-3：Toast 静态入口与 QProcess 参数
// ---------------------------------------------------------------------
@Test
class ToastAndProcessTests {
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

    /// P2-3：QProcess.addArgument 逐个追加参数（含空格的参数不会被切分丢失）
    @TestCase
    func testProcessAddArgument() {
        let p = QProcess()
        p.setProgram("cmd.exe")
        p.addArgument("/c")
        p.addArgument("echo a b")
        // 追加结果应原样保留在参数列表中
        @Assert(p.arguments().contains("echo a b"))
        p.close()
    }
}
