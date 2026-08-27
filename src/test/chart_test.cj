package cjqt6.test

import cjqt6.core.*
import cjqt6.charts.*
import std.unittest.*

// =====================================================================
// Qt Charts 测试（GUI 环境）
// =====================================================================

@Test
class QChartTests {
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
    func testChartCreateAndClose() {
        let chart = QChart()
        @Expect(chart.getPtr() != 0, true)
        chart.close()
        @Expect(chart.getPtr(), 0)
    }

    @TestCase
    func testChartViewCreateAndClose() {
        let view = QChartView()
        @Expect(view.getPtr() != 0, true)
        view.close()
        @Expect(view.getPtr(), 0)
    }

    @TestCase
    func testLineSeriesAppend() {
        let series = QLineSeries()
        series.append(0.0, 10.0)
        series.append(1.0, 20.0)
        series.append(2.0, 15.0)
        @Expect(series.count(), 3)
        series.close()
    }

    @TestCase
    func testLineSeriesSetName() {
        let series = QLineSeries()
        series.setName("温度")
        @Assert(true)
        series.close()
    }

    @TestCase
    func testValueAxisSetRange() {
        let axis = QValueAxis()
        axis.setRange(0.0, 100.0)
        axis.setTickCount(11)
        axis.setLabelFormat("%.0f")
        @Assert(true)
        axis.close()
    }

    @TestCase
    func testChartAddSeriesAndCreateDefaultAxes() {
        let chart = QChart()
        let series = QLineSeries()
        series.append(0.0, 10.0)
        series.append(1.0, 20.0)
        chart.addSeries(series)
        chart.createDefaultAxes()
        chart.setTitle("测试图表")
        @Assert(true)
        // series 所有权已转给 chart，chart.close 级联释放
        chart.close()
    }

    @TestCase
    func testChartViewSetChart() {
        let chart = QChart()
        let series = QLineSeries()
        series.append(0.0, 10.0)
        chart.addSeries(series)
        chart.createDefaultAxes()

        let view = QChartView()
        view.setChart(chart)
        view.resize(400, 300)
        @Assert(true)
        // chart 所有权已转给 view，view.close 级联释放 chart 及 series
        view.close()
    }

    @TestCase
    func testChartThemeConstants() {
        @Expect(ChartTheme.light, 0)
        @Expect(ChartTheme.blueCerulean, 1)
        @Expect(ChartTheme.dark, 2)
        @Expect(ChartTheme.qt, 7)
    }

    @TestCase
    func testChartAnimationConstants() {
        @Expect(ChartAnimation.none, 0)
        @Expect(ChartAnimation.gridAxis, 1)
        @Expect(ChartAnimation.series, 2)
        @Expect(ChartAnimation.all, 3)
    }

    @TestCase
    func testAxisAlignmentConstants() {
        @Expect(AxisAlignment.left, 0x0001)
        @Expect(AxisAlignment.bottom, 0x0040)
    }

    @TestCase
    func testCloseThenUseThrows() {
        let chart = QChart()
        chart.close()
        @ExpectThrows[ResourceDisposedException](chart.setTitle("x"))
    }
}