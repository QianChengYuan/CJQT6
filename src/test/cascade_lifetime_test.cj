package cjqt6.test

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.charts.*
import cjqt6.views.*
import std.unittest.*

// =====================================================================
// 级联销毁生命周期回归测试（DEFECTS A1）
//
// 背景：charts 子对象（series/axis）经 addSeries/addAxis/setChart 把所有权
// 转移给 Qt 父对象；views 控件经布局 addWidget reparent 到父窗口。父对象
// 析构时会通过 Qt 父子树 / QChart 所有权级联销毁这些子对象。此后仓颉包装
// 句柄仍持有悬垂指针。
//
// 修复前：close() 无条件 qXxxDelete(ptr) 会 double-free / use-after-free；
//         业务方法 checkValid 不查存活状态，会解引用悬垂指针。
// 修复后：close() 级联分支识别 isObjectAlive()==false，只 untrackObject 不
//         delete；checkValid() 抛 ResourceDisposedException。
//
// destroyed 是同步信号，父对象 close 返回后子对象状态立即确定，不依赖事件
// 循环，offscreen 下结果确定性可重复。
// =====================================================================

// ---------------------------------------------------------------------
// Charts 级联销毁
// ---------------------------------------------------------------------
@Test
class QChartCascadeLifetimeTests {
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

    // chart.addSeries 后 chart 接管 series；chart.close() 级联销毁 series
    @TestCase
    func testSeriesCascadeAfterChartClose() {
        let chart = QChart()
        let series = QLineSeries()
        series.append(0.0, 10.0)
        chart.addSeries(series)
        // 父 chart 销毁 → series 被级联 delete，destroyed 同步触发
        chart.close()
        // 级联后业务方法必须抛“已失效”，而非解引用悬垂指针
        @ExpectThrows[ResourceDisposedException](series.append(1.0, 20.0))
        // close() 必须安全：守卫识别已失效，只注销不 delete（修复前此处 UAF 崩溃）
        series.close()
        @Expect(series.getPtr(), 0)
        // 幂等：重复 close 不抛异常
        series.close()
    }

    // chart.addAxis 后 chart 接管 axis；chart.close() 级联销毁 axis
    @TestCase
    func testAxisCascadeAfterChartClose() {
        let chart = QChart()
        let axis = QValueAxis()
        axis.setRange(0.0, 1.0)
        chart.addAxis(axis, AxisAlignment.bottom)
        chart.close()
        @ExpectThrows[ResourceDisposedException](axis.setMin(0.5))
        axis.close()
        @Expect(axis.getPtr(), 0)
        axis.close()
    }

    // view.setChart 后 view 接管 chart（及其 series）；view.close() 级联销毁整条链
    @TestCase
    func testChartAndSeriesCascadeAfterViewClose() {
        let chart = QChart()
        let series = QLineSeries()
        series.append(0.0, 1.0)
        chart.addSeries(series)
        let view = QChartView()
        view.setChart(chart)
        // view 销毁 → chart → series 级联销毁
        view.close()
        // chart 与 series 均已失效，业务方法均须抛异常
        @ExpectThrows[ResourceDisposedException](chart.setTitle("x"))
        @ExpectThrows[ResourceDisposedException](series.append(1.0, 2.0))
        // 二者 close() 均须安全幂等（修复前此处 UAF 崩溃）
        chart.close()
        series.close()
        @Expect(chart.getPtr(), 0)
        @Expect(series.getPtr(), 0)
    }
}

// ---------------------------------------------------------------------
// Views 控件级联销毁（addWidget reparent 后随父窗口销毁）
// ---------------------------------------------------------------------
@Test
class QViewCascadeLifetimeTests {
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

    // 表格控件加入父窗口布局后，父窗口 close 级联销毁表格
    @TestCase
    func testTableWidgetCascadeAfterParentClose() {
        let parent = QWidget()
        let layout = QVBoxLayout()
        parent.setLayout(layout.getPtr())
        let table = QTableWidget(2, 2)
        layout.addWidget(table.getPtr())
        // 父窗口销毁 → 子表格经 Qt 父子树级联销毁
        parent.close()
        // 级联后 checkValid 必须抛“已失效”（修复前不查存活状态）
        @ExpectThrows[ResourceDisposedException](table.checkValid())
        // close() 必须安全幂等（修复前此处对悬垂 ptr double-free）
        table.close()
        @Expect(table.getPtr(), 0)
        table.close()
    }

    // 树控件加入父窗口布局后，父窗口 close 级联销毁树
    @TestCase
    func testTreeWidgetCascadeAfterParentClose() {
        let parent = QWidget()
        let layout = QVBoxLayout()
        parent.setLayout(layout.getPtr())
        let tree = QTreeWidget()
        layout.addWidget(tree.getPtr())
        parent.close()
        @ExpectThrows[ResourceDisposedException](tree.checkValid())
        tree.close()
        @Expect(tree.getPtr(), 0)
        tree.close()
    }

    // 列表控件加入父窗口布局后，父窗口 close 级联销毁列表
    @TestCase
    func testListWidgetCascadeAfterParentClose() {
        let parent = QWidget()
        let layout = QVBoxLayout()
        parent.setLayout(layout.getPtr())
        let list = QListWidget()
        layout.addWidget(list.getPtr())
        parent.close()
        @ExpectThrows[ResourceDisposedException](list.checkValid())
        list.close()
        @Expect(list.getPtr(), 0)
        list.close()
    }
}
