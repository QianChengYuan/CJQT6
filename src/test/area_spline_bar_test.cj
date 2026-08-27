package cjqt6.test

import cjqt6.core.*
import cjqt6.charts.*
import std.unittest.*

// =====================================================================
// QAreaSeries / QSplineSeries / QPercentBarSeries / QStackedBarSeries 测试
// =====================================================================

@Test
class QAreaSplineBarSeriesTests {
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

    // ---- QAreaSeries ----

    @TestCase
    func testAreaSeriesCreateWithUpperOnly() {
        let upper = QLineSeries()
        upper.append(0.0, 10.0)
        upper.append(1.0, 20.0)
        let area = QAreaSeries(upper)
        @Expect(area.getPtr() != 0, true)
        area.close()
        upper.close()
    }

    @TestCase
    func testAreaSeriesCreateWithUpperAndLower() {
        let upper = QLineSeries()
        upper.append(0.0, 20.0)
        upper.append(1.0, 30.0)
        let lower = QLineSeries()
        lower.append(0.0, 5.0)
        lower.append(1.0, 10.0)
        let area = QAreaSeries(upper, lower)
        @Expect(area.getPtr() != 0, true)
        area.close()
        upper.close()
        lower.close()
    }

    @TestCase
    func testAreaSeriesSetColor() {
        let upper = QLineSeries()
        upper.append(0.0, 10.0)
        let area = QAreaSeries(upper)
        area.setColor(100, 150, 200)
        area.setBorderColor(255, 0, 0)
        @Assert(true)
        area.close()
        upper.close()
    }

    @TestCase
    func testAreaSeriesSetPointsVisible() {
        let upper = QLineSeries()
        upper.append(0.0, 10.0)
        let area = QAreaSeries(upper)
        area.setPointsVisible(true)
        area.setPointsVisible(false)
        @Assert(true)
        area.close()
        upper.close()
    }

    @TestCase
    func testAreaSeriesCloseThenUseThrows() {
        let upper = QLineSeries()
        upper.append(0.0, 10.0)
        let area = QAreaSeries(upper)
        area.close()
        @ExpectThrows[ResourceDisposedException](area.setColor(1, 2, 3))
        upper.close()
    }

    // ---- QSplineSeries ----

    @TestCase
    func testSplineSeriesCreateAndClose() {
        let series = QSplineSeries()
        @Expect(series.getPtr() != 0, true)
        series.close()
        @Expect(series.getPtr(), 0)
    }

    @TestCase
    func testSplineSeriesAppendAndCount() {
        let series = QSplineSeries()
        series.append(0.0, 10.0)
        series.append(1.0, 20.0)
        series.append(2.0, 15.0)
        @Expect(series.count(), 3)
        series.close()
    }

    @TestCase
    func testSplineSeriesSetName() {
        let series = QSplineSeries()
        series.setName("平滑曲线")
        @Assert(true)
        series.close()
    }

    @TestCase
    func testSplineSeriesCloseThenUseThrows() {
        let series = QSplineSeries()
        series.close()
        @ExpectThrows[ResourceDisposedException](series.append(1.0, 1.0))
    }

    // ---- QPercentBarSeries ----

    @TestCase
    func testPercentBarSeriesCreateAndClose() {
        let series = QPercentBarSeries()
        @Expect(series.getPtr() != 0, true)
        series.close()
        @Expect(series.getPtr(), 0)
    }

    @TestCase
    func testPercentBarSeriesAppendSet() {
        let series = QPercentBarSeries()
        let set1 = QBarSet("产品A")
        set1.append(10.0)
        set1.append(20.0)
        let set2 = QBarSet("产品B")
        set2.append(30.0)
        set2.append(40.0)
        series.append(set1)
        series.append(set2)
        @Expect(series.count(), 2)
        // set 所有权已转给 series，series.close 级联释放
        series.close()
    }

    @TestCase
    func testPercentBarSeriesClear() {
        let series = QPercentBarSeries()
        let set1 = QBarSet("产品A")
        set1.append(10.0)
        series.append(set1)
        series.clear()
        @Expect(series.count(), 0)
        series.close()
    }

    @TestCase
    func testPercentBarSeriesSetLabelsVisible() {
        let series = QPercentBarSeries()
        series.setLabelsVisible(true)
        series.setLabelsVisible(false)
        @Assert(true)
        series.close()
    }

    @TestCase
    func testPercentBarSeriesCloseThenUseThrows() {
        let series = QPercentBarSeries()
        series.close()
        @ExpectThrows[ResourceDisposedException](series.clear())
    }

    // ---- QStackedBarSeries ----

    @TestCase
    func testStackedBarSeriesCreateAndClose() {
        let series = QStackedBarSeries()
        @Expect(series.getPtr() != 0, true)
        series.close()
        @Expect(series.getPtr(), 0)
    }

    @TestCase
    func testStackedBarSeriesAppendSet() {
        let series = QStackedBarSeries()
        let set1 = QBarSet("产品A")
        set1.append(10.0)
        set1.append(20.0)
        let set2 = QBarSet("产品B")
        set2.append(15.0)
        set2.append(25.0)
        series.append(set1)
        series.append(set2)
        @Expect(series.count(), 2)
        // set 所有权已转给 series，series.close 级联释放
        series.close()
    }

    @TestCase
    func testStackedBarSeriesClear() {
        let series = QStackedBarSeries()
        let set1 = QBarSet("产品A")
        set1.append(10.0)
        series.append(set1)
        series.clear()
        @Expect(series.count(), 0)
        series.close()
    }

    @TestCase
    func testStackedBarSeriesSetLabelsVisible() {
        let series = QStackedBarSeries()
        series.setLabelsVisible(true)
        series.setLabelsVisible(false)
        @Assert(true)
        series.close()
    }

    @TestCase
    func testStackedBarSeriesCloseThenUseThrows() {
        let series = QStackedBarSeries()
        series.close()
        @ExpectThrows[ResourceDisposedException](series.clear())
    }

    // ---- 集成：QChart.addSeries 重载 ----

    @TestCase
    func testChartAddAreaSeries() {
        let chart = QChart()
        let upper = QLineSeries()
        upper.append(0.0, 10.0)
        upper.append(1.0, 20.0)
        upper.append(2.0, 15.0)
        let lower = QLineSeries()
        lower.append(0.0, 5.0)
        lower.append(1.0, 8.0)
        lower.append(2.0, 6.0)
        let area = QAreaSeries(upper, lower)
        area.setColor(100, 150, 200)
        chart.addSeries(area)
        chart.createDefaultAxes()
        @Assert(true)
        // area 所有权已转给 chart；upper/lower 需手动释放
        chart.close()
        upper.close()
        lower.close()
    }

    @TestCase
    func testChartAddSplineSeries() {
        let chart = QChart()
        let series = QSplineSeries()
        series.setName("平滑曲线")
        series.append(0.0, 10.0)
        series.append(1.0, 20.0)
        series.append(2.0, 15.0)
        chart.addSeries(series)
        chart.createDefaultAxes()
        @Assert(true)
        // series 所有权已转给 chart
        chart.close()
    }

    @TestCase
    func testChartAddPercentBarSeries() {
        let chart = QChart()
        let series = QPercentBarSeries()
        let set1 = QBarSet("产品A")
        set1.append(10.0)
        set1.append(20.0)
        let set2 = QBarSet("产品B")
        set2.append(30.0)
        set2.append(40.0)
        series.append(set1)
        series.append(set2)
        series.setLabelsVisible(true)
        chart.addSeries(series)
        chart.createDefaultAxes()
        @Assert(true)
        // series + set 所有权已转给 chart
        chart.close()
    }

    @TestCase
    func testChartAddStackedBarSeries() {
        let chart = QChart()
        let series = QStackedBarSeries()
        let set1 = QBarSet("产品A")
        set1.append(10.0)
        set1.append(20.0)
        let set2 = QBarSet("产品B")
        set2.append(15.0)
        set2.append(25.0)
        series.append(set1)
        series.append(set2)
        series.setLabelsVisible(true)
        chart.addSeries(series)
        chart.createDefaultAxes()
        @Assert(true)
        // series + set 所有权已转给 chart
        chart.close()
    }
}