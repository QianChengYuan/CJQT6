package cjqt6.test

import cjqt6.core.*
import cjqt6.charts.*
import std.unittest.*

// =====================================================================
// QPieSlice / QDateTimeAxis / QLogValueAxis /
// QHorizontalBarSeries / QHorizontalPercentBarSeries / QHorizontalStackedBarSeries 测试
// =====================================================================

@Test
class QPieSliceDateTimeLogHorizontalTests {
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

    // ---- QPieSlice ----

    @TestCase
    func testPieSliceCreateEmpty() {
        let slice = QPieSlice()
        @Expect(slice.getPtr() != 0, true)
        slice.close()
        @Expect(slice.getPtr(), 0)
    }

    @TestCase
    func testPieSliceCreateLabelValue() {
        let slice = QPieSlice("产品A", 40.0)
        @Expect(slice.getPtr() != 0, true)
        @Expect(slice.value(), 40.0)
        @Expect(slice.label(), "产品A")
        slice.close()
    }

    @TestCase
    func testPieSliceSetLabel() {
        let slice = QPieSlice("初始", 10.0)
        slice.setLabel("修改后")
        @Expect(slice.label(), "修改后")
        slice.close()
    }

    @TestCase
    func testPieSliceSetValue() {
        let slice = QPieSlice()
        slice.setValue(55.5)
        @Expect(slice.value(), 55.5)
        slice.close()
    }

    @TestCase
    func testPieSliceLabelVisible() {
        let slice = QPieSlice("测试", 20.0)
        slice.setLabelVisible(true)
        @Expect(slice.isLabelVisible(), true)
        slice.setLabelVisible(false)
        @Expect(slice.isLabelVisible(), false)
        slice.close()
    }

    @TestCase
    func testPieSliceLabelPosition() {
        let slice = QPieSlice("测试", 20.0)
        slice.setLabelPosition(PieSliceLabelPosition.outside)
        @Expect(slice.labelPosition(), PieSliceLabelPosition.outside)
        slice.setLabelPosition(PieSliceLabelPosition.insideHorizontal)
        @Expect(slice.labelPosition(), PieSliceLabelPosition.insideHorizontal)
        slice.close()
    }

    @TestCase
    func testPieSliceExploded() {
        let slice = QPieSlice("测试", 20.0)
        slice.setExploded(true)
        @Expect(slice.isExploded(), true)
        slice.setExploded(false)
        @Expect(slice.isExploded(), false)
        slice.close()
    }

    @TestCase
    func testPieSliceColor() {
        let slice = QPieSlice("测试", 20.0)
        slice.setColor(255, 0, 0)
        slice.setBorderColor(0, 0, 255)
        slice.setBorderWidth(2)
        slice.setLabelColor(0, 255, 0)
        // 无 getter 验证颜色，只要不崩溃即可
        @Expect(slice.getPtr() != 0, true)
        slice.close()
    }

    @TestCase
    func testPieSliceArmLengthFactor() {
        let slice = QPieSlice("测试", 20.0)
        slice.setLabelArmLengthFactor(0.15)
        @Expect(slice.labelArmLengthFactor(), 0.15)
        slice.close()
    }

    @TestCase
    func testPieSliceExplodeDistanceFactor() {
        let slice = QPieSlice("测试", 20.0)
        slice.setExplodeDistanceFactor(0.05)
        @Expect(slice.explodeDistanceFactor(), 0.05)
        slice.close()
    }

    @TestCase
    func testPieSliceWithSeries() {
        let series = QPieSeries()
        let slice1 = QPieSlice("产品A", 30.0)
        let slice2 = QPieSlice("产品B", 70.0)
        series.append(slice1)
        series.append(slice2)
        @Expect(series.count(), 2)
        @Expect(series.sum(), 100.0)
        // percentage 在 series 中才有意义
        @Expect(slice1.percentage(), 0.3)
        @Expect(slice2.percentage(), 0.7)
        series.close()
    }

    // ---- QDateTimeAxis ----

    @TestCase
    func testDateTimeAxisCreate() {
        let axis = QDateTimeAxis()
        @Expect(axis.getPtr() != 0, true)
        axis.close()
        @Expect(axis.getPtr(), 0)
    }

    @TestCase
    func testDateTimeAxisSetRange() {
        let axis = QDateTimeAxis()
        let baseTime = 1787616000.0  // 2026-08-25
        let day = 86400.0
        axis.setRange(baseTime, baseTime + day * 4.0)
        @Expect(axis.min(), baseTime)
        @Expect(axis.max(), baseTime + day * 4.0)
        axis.close()
    }

    @TestCase
    func testDateTimeAxisSetMin() {
        let axis = QDateTimeAxis()
        axis.setMin(1787616000.0)
        @Expect(axis.min(), 1787616000.0)
        axis.close()
    }

    @TestCase
    func testDateTimeAxisSetMax() {
        let axis = QDateTimeAxis()
        axis.setMax(1787961600.0)
        @Expect(axis.max(), 1787961600.0)
        axis.close()
    }

    @TestCase
    func testDateTimeAxisSetFormat() {
        let axis = QDateTimeAxis()
        axis.setFormat("yyyy-MM-dd")
        @Expect(axis.format(), "yyyy-MM-dd")
        axis.close()
    }

    @TestCase
    func testDateTimeAxisSetTickCount() {
        let axis = QDateTimeAxis()
        axis.setTickCount(5)
        @Expect(axis.tickCount(), 5)
        axis.close()
    }

    @TestCase
    func testDateTimeAxisWithChart() {
        let chart = QChart()
        let axis = QDateTimeAxis()
        axis.setFormat("yyyy-MM-dd")
        axis.setRange(1787616000.0, 1787961600.0)
        chart.addAxis(axis, AxisAlignment.bottom)
        @Expect(axis.getPtr() != 0, true)
        chart.close()
    }

    // ---- QLogValueAxis ----

    @TestCase
    func testLogValueAxisCreate() {
        let axis = QLogValueAxis()
        @Expect(axis.getPtr() != 0, true)
        axis.close()
        @Expect(axis.getPtr(), 0)
    }

    @TestCase
    func testLogValueAxisSetRange() {
        let axis = QLogValueAxis()
        axis.setRange(1.0, 10000.0)
        @Expect(axis.min(), 1.0)
        @Expect(axis.max(), 10000.0)
        axis.close()
    }

    @TestCase
    func testLogValueAxisSetMin() {
        let axis = QLogValueAxis()
        axis.setMin(0.1)
        @Expect(axis.min(), 0.1)
        axis.close()
    }

    @TestCase
    func testLogValueAxisSetMax() {
        let axis = QLogValueAxis()
        axis.setMax(1000.0)
        @Expect(axis.max(), 1000.0)
        axis.close()
    }

    @TestCase
    func testLogValueAxisSetLabelFormat() {
        let axis = QLogValueAxis()
        axis.setLabelFormat("%.0f")
        @Expect(axis.labelFormat(), "%.0f")
        axis.close()
    }

    @TestCase
    func testLogValueAxisSetBase() {
        let axis = QLogValueAxis()
        axis.setBase(10.0)
        @Expect(axis.base(), 10.0)
        axis.setBase(2.0)
        @Expect(axis.base(), 2.0)
        axis.close()
    }

    @TestCase
    func testLogValueAxisSetMinorTickCount() {
        let axis = QLogValueAxis()
        axis.setMinorTickCount(9)
        @Expect(axis.minorTickCount(), 9)
        axis.close()
    }

    @TestCase
    func testLogValueAxisWithChart() {
        let chart = QChart()
        let axis = QLogValueAxis()
        axis.setRange(1.0, 1000.0)
        axis.setBase(10.0)
        axis.setLabelFormat("%.0f")
        chart.addAxis(axis, AxisAlignment.bottom)
        @Expect(axis.getPtr() != 0, true)
        chart.close()
    }

    // ---- QHorizontalBarSeries ----

    @TestCase
    func testHorizontalBarSeriesCreate() {
        let series = QHorizontalBarSeries()
        @Expect(series.getPtr() != 0, true)
        series.close()
        @Expect(series.getPtr(), 0)
    }

    @TestCase
    func testHorizontalBarSeriesAppendCount() {
        let series = QHorizontalBarSeries()
        let set1 = QBarSet("产品A")
        set1.append(10.0)
        set1.append(20.0)
        let set2 = QBarSet("产品B")
        set2.append(15.0)
        set2.append(25.0)
        series.append(set1)
        series.append(set2)
        @Expect(series.count(), 2)
        series.close()
    }

    @TestCase
    func testHorizontalBarSeriesClear() {
        let series = QHorizontalBarSeries()
        let set1 = QBarSet("A")
        set1.append(10.0)
        series.append(set1)
        @Expect(series.count(), 1)
        series.clear()
        @Expect(series.count(), 0)
        series.close()
    }

    @TestCase
    func testHorizontalBarSeriesSetBarWidth() {
        let series = QHorizontalBarSeries()
        series.setBarWidth(0.5)
        @Expect(series.getPtr() != 0, true)
        series.close()
    }

    @TestCase
    func testHorizontalBarSeriesWithChart() {
        let chart = QChart()
        let series = QHorizontalBarSeries()
        let set1 = QBarSet("产品A")
        set1.append(10.0)
        set1.append(20.0)
        series.append(set1)
        chart.addSeries(series)
        chart.createDefaultAxes()
        @Expect(series.getPtr() != 0, true)
        chart.close()
    }

    // ---- QHorizontalPercentBarSeries ----

    @TestCase
    func testHorizontalPercentBarSeriesCreate() {
        let series = QHorizontalPercentBarSeries()
        @Expect(series.getPtr() != 0, true)
        series.close()
        @Expect(series.getPtr(), 0)
    }

    @TestCase
    func testHorizontalPercentBarSeriesAppendCount() {
        let series = QHorizontalPercentBarSeries()
        let set1 = QBarSet("产品A")
        set1.append(30.0)
        set1.append(40.0)
        let set2 = QBarSet("产品B")
        set2.append(70.0)
        set2.append(60.0)
        series.append(set1)
        series.append(set2)
        @Expect(series.count(), 2)
        series.close()
    }

    @TestCase
    func testHorizontalPercentBarSeriesWithChart() {
        let chart = QChart()
        let series = QHorizontalPercentBarSeries()
        let set1 = QBarSet("产品A")
        set1.append(30.0)
        series.append(set1)
        chart.addSeries(series)
        chart.createDefaultAxes()
        @Expect(series.getPtr() != 0, true)
        chart.close()
    }

    // ---- QHorizontalStackedBarSeries ----

    @TestCase
    func testHorizontalStackedBarSeriesCreate() {
        let series = QHorizontalStackedBarSeries()
        @Expect(series.getPtr() != 0, true)
        series.close()
        @Expect(series.getPtr(), 0)
    }

    @TestCase
    func testHorizontalStackedBarSeriesAppendCount() {
        let series = QHorizontalStackedBarSeries()
        let set1 = QBarSet("产品A")
        set1.append(10.0)
        set1.append(20.0)
        let set2 = QBarSet("产品B")
        set2.append(15.0)
        set2.append(25.0)
        series.append(set1)
        series.append(set2)
        @Expect(series.count(), 2)
        series.close()
    }

    @TestCase
    func testHorizontalStackedBarSeriesWithChart() {
        let chart = QChart()
        let series = QHorizontalStackedBarSeries()
        let set1 = QBarSet("产品A")
        set1.append(10.0)
        series.append(set1)
        chart.addSeries(series)
        chart.createDefaultAxes()
        @Expect(series.getPtr() != 0, true)
        chart.close()
    }
}