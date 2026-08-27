package cjqt6.test

import cjqt6.core.*
import cjqt6.charts.*
import std.unittest.*

// =====================================================================
// QBarSet / QBarSeries / QPieSeries / QScatterSeries 测试（GUI 环境）
// =====================================================================

@Test
class QSeriesTests {
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

    // ---- QBarSet ----

    @TestCase
    func testBarSetCreateAndClose() {
        let set = QBarSet("产品A")
        @Expect(set.getPtr() != 0, true)
        set.close()
        @Expect(set.getPtr(), 0)
    }

    @TestCase
    func testBarSetAppendAndCount() {
        let set = QBarSet("产品A")
        set.append(10.0)
        set.append(20.0)
        set.append(30.0)
        @Expect(set.count(), 3)
        set.close()
    }

    @TestCase
    func testBarSetSum() {
        let set = QBarSet("产品A")
        set.append(10.0)
        set.append(20.0)
        set.append(30.0)
        @Expect(set.sum(), 60.0)
        set.close()
    }

    @TestCase
    func testBarSetInsert() {
        let set = QBarSet("产品A")
        set.append(20.0)
        set.append(30.0)
        set.insert(0, 10.0)
        @Expect(set.count(), 3)
        set.close()
    }

    @TestCase
    func testBarSetRemove() {
        let set = QBarSet("产品A")
        set.append(10.0)
        set.append(20.0)
        set.append(30.0)
        set.remove(1)
        @Expect(set.count(), 2)
        set.close()
    }

    @TestCase
    func testBarSetReplace() {
        let set = QBarSet("产品A")
        set.append(10.0)
        set.append(20.0)
        set.append(30.0)
        set.replace(1, 99.0)
        @Expect(set.count(), 3)
        @Expect(set.sum(), 139.0)
        set.close()
    }

    @TestCase
    func testBarSetLabelAndColor() {
        let set = QBarSet("产品A")
        set.setLabel("产品B")
        set.setColor(255, 0, 0)
        set.setBorderColor(0, 0, 0)
        @Assert(true)
        set.close()
    }

    @TestCase
    func testBarSetCloseThenUseThrows() {
        let set = QBarSet("产品A")
        set.close()
        @ExpectThrows[ResourceDisposedException](set.append(1.0))
    }

    // ---- QBarSeries ----

    @TestCase
    func testBarSeriesCreateAndClose() {
        let series = QBarSeries()
        @Expect(series.getPtr() != 0, true)
        series.close()
        @Expect(series.getPtr(), 0)
    }

    @TestCase
    func testBarSeriesAppendSet() {
        let series = QBarSeries()
        let set1 = QBarSet("产品A")
        set1.append(10.0)
        let set2 = QBarSet("产品B")
        set2.append(20.0)
        series.append(set1)
        series.append(set2)
        @Expect(series.count(), 2)
        // set 所有权已转给 series，series.close 级联释放
        series.close()
    }

    @TestCase
    func testBarSeriesClear() {
        let series = QBarSeries()
        let set1 = QBarSet("产品A")
        set1.append(10.0)
        series.append(set1)
        series.clear()
        @Expect(series.count(), 0)
        series.close()
    }

    @TestCase
    func testBarSeriesProperties() {
        let series = QBarSeries()
        series.setBarWidth(0.8)
        series.setLabelsVisible(true)
        series.setLabelsPosition(BarLabelsPosition.outsideEnd)
        @Assert(true)
        series.close()
    }

    @TestCase
    func testBarSeriesCloseThenUseThrows() {
        let series = QBarSeries()
        series.close()
        @ExpectThrows[ResourceDisposedException](series.clear())
    }

    // ---- QPieSeries ----

    @TestCase
    func testPieSeriesCreateAndClose() {
        let series = QPieSeries()
        @Expect(series.getPtr() != 0, true)
        series.close()
        @Expect(series.getPtr(), 0)
    }

    @TestCase
    func testPieSeriesAppendAndCount() {
        let series = QPieSeries()
        series.append("苹果", 30.0)
        series.append("香蕉", 25.0)
        series.append("橙子", 45.0)
        @Expect(series.count(), 3)
        series.close()
    }

    @TestCase
    func testPieSeriesSum() {
        let series = QPieSeries()
        series.append("苹果", 30.0)
        series.append("香蕉", 25.0)
        series.append("橙子", 45.0)
        @Expect(series.sum(), 100.0)
        series.close()
    }

    @TestCase
    func testPieSeriesClear() {
        let series = QPieSeries()
        series.append("苹果", 30.0)
        series.append("香蕉", 25.0)
        series.clear()
        @Expect(series.count(), 0)
        series.close()
    }

    @TestCase
    func testPieSeriesProperties() {
        let series = QPieSeries()
        series.setHoleSize(0.4)
        series.setPieSize(0.7)
        series.setHorizontalPosition(0.5)
        series.setVerticalPosition(0.5)
        series.setPieStartAngle(0.0)
        series.setPieEndAngle(360.0)
        series.setLabelsVisible(true)
        @Assert(true)
        series.close()
    }

    @TestCase
    func testPieSeriesCloseThenUseThrows() {
        let series = QPieSeries()
        series.close()
        @ExpectThrows[ResourceDisposedException](series.clear())
    }

    // ---- QScatterSeries ----

    @TestCase
    func testScatterSeriesCreateAndClose() {
        let series = QScatterSeries()
        @Expect(series.getPtr() != 0, true)
        series.close()
        @Expect(series.getPtr(), 0)
    }

    @TestCase
    func testScatterSeriesAppendAndCount() {
        let series = QScatterSeries()
        series.append(1.0, 10.0)
        series.append(2.0, 25.0)
        series.append(3.0, 18.0)
        @Expect(series.count(), 3)
        series.close()
    }

    @TestCase
    func testScatterSeriesSetName() {
        let series = QScatterSeries()
        series.setName("测量点")
        @Assert(true)
        series.close()
    }

    @TestCase
    func testScatterSeriesMarkerShape() {
        let series = QScatterSeries()
        series.setMarkerShape(ScatterMarkerShape.circle)
        series.setMarkerShape(ScatterMarkerShape.rectangle)
        series.setMarkerShape(ScatterMarkerShape.triangle)
        series.setMarkerShape(ScatterMarkerShape.star)
        @Assert(true)
        series.close()
    }

    @TestCase
    func testScatterSeriesMarkerSizeAndColor() {
        let series = QScatterSeries()
        series.setMarkerSize(10.0)
        series.setColor(255, 0, 0)
        series.setBorderColor(0, 0, 0)
        @Assert(true)
        series.close()
    }

    @TestCase
    func testScatterSeriesCloseThenUseThrows() {
        let series = QScatterSeries()
        series.close()
        @ExpectThrows[ResourceDisposedException](series.append(1.0, 1.0))
    }

    // ---- 常量验证 ----

    @TestCase
    func testBarLabelsPositionConstants() {
        @Expect(BarLabelsPosition.center, 0)
        @Expect(BarLabelsPosition.insideEnd, 1)
        @Expect(BarLabelsPosition.insideBase, 2)
        @Expect(BarLabelsPosition.outsideEnd, 3)
    }

    @TestCase
    func testScatterMarkerShapeConstants() {
        @Expect(ScatterMarkerShape.circle, 0)
        @Expect(ScatterMarkerShape.rectangle, 1)
        @Expect(ScatterMarkerShape.rotatedRectangle, 2)
        @Expect(ScatterMarkerShape.triangle, 3)
        @Expect(ScatterMarkerShape.star, 4)
        @Expect(ScatterMarkerShape.pentagon, 5)
    }

    // ---- 集成：QChart.addSeries 重载 ----

    @TestCase
    func testChartAddBarSeries() {
        let chart = QChart()
        let series = QBarSeries()
        let set = QBarSet("产品A")
        set.append(10.0)
        set.append(20.0)
        series.append(set)
        chart.addSeries(series)
        chart.createDefaultAxes()
        @Assert(true)
        // series + set 所有权已转给 chart
        chart.close()
    }

    @TestCase
    func testChartAddPieSeries() {
        let chart = QChart()
        let series = QPieSeries()
        series.append("苹果", 30.0)
        series.append("香蕉", 70.0)
        chart.addSeries(series)
        chart.createDefaultAxes()
        @Assert(true)
        chart.close()
    }

    @TestCase
    func testChartAddScatterSeries() {
        let chart = QChart()
        let series = QScatterSeries()
        series.append(1.0, 10.0)
        series.append(2.0, 25.0)
        series.append(3.0, 18.0)
        chart.addSeries(series)
        chart.createDefaultAxes()
        @Assert(true)
        chart.close()
    }
}