package cjqt6.test

import cjqt6.core.*
import cjqt6.charts.*
import std.unittest.*

// =====================================================================
// QBoxSet / QBoxPlotSeries / QCandlestickSet / QCandlestickSeries / QPolarChart 测试
// =====================================================================

@Test
class QBoxPlotCandlestickPolarTests {
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

    // ---- QBoxSet ----

    @TestCase
    func testBoxSetCreateWithLabel() {
        let box = QBoxSet("样本A")
        @Expect(box.getPtr() != 0, true)
        box.close()
        @Expect(box.getPtr(), 0)
    }

    @TestCase
    func testBoxSetCreateWithFiveValues() {
        let box = QBoxSet(10.0, 20.0, 30.0, 40.0, 50.0)
        @Expect(box.getPtr() != 0, true)
        @Expect(box.count(), 5)
        box.close()
    }

    @TestCase
    func testBoxSetAppendAndCount() {
        let box = QBoxSet("样本A")
        box.append(10.0)
        box.append(20.0)
        box.append(30.0)
        @Expect(box.count(), 3)
        box.close()
    }

    @TestCase
    func testBoxSetSetValueAndAt() {
        let box = QBoxSet(10.0, 20.0, 30.0, 40.0, 50.0)
        box.setValue(2, 35.0)
        @Expect(box.at(2), 35.0)
        box.close()
    }

    @TestCase
    func testBoxSetClear() {
        let box = QBoxSet("样本A")
        box.append(10.0)
        box.append(20.0)
        box.clear()
        @Expect(box.count(), 0)
        box.close()
    }

    @TestCase
    func testBoxSetSetLabel() {
        let box = QBoxSet("样本A")
        box.setLabel("样本B")
        @Assert(true)
        box.close()
    }

    @TestCase
    func testBoxSetCloseThenUseThrows() {
        let box = QBoxSet("样本A")
        box.close()
        @ExpectThrows[ResourceDisposedException](box.append(1.0))
    }

    // ---- QBoxPlotSeries ----

    @TestCase
    func testBoxPlotSeriesCreateAndClose() {
        let series = QBoxPlotSeries()
        @Expect(series.getPtr() != 0, true)
        series.close()
        @Expect(series.getPtr(), 0)
    }

    @TestCase
    func testBoxPlotSeriesAppendBox() {
        let series = QBoxPlotSeries()
        let box1 = QBoxSet(10.0, 20.0, 30.0, 40.0, 50.0)
        let box2 = QBoxSet(15.0, 25.0, 35.0, 45.0, 55.0)
        series.append(box1)
        series.append(box2)
        @Expect(series.count(), 2)
        // box 所有权已转给 series，series.close 级联释放
        series.close()
    }

    @TestCase
    func testBoxPlotSeriesClear() {
        let series = QBoxPlotSeries()
        let box = QBoxSet(10.0, 20.0, 30.0, 40.0, 50.0)
        series.append(box)
        series.clear()
        @Expect(series.count(), 0)
        series.close()
    }

    @TestCase
    func testBoxPlotSeriesProperties() {
        let series = QBoxPlotSeries()
        series.setBoxOutlineVisible(true)
        series.setBoxWidth(0.5)
        @Assert(true)
        series.close()
    }

    @TestCase
    func testBoxPlotSeriesCloseThenUseThrows() {
        let series = QBoxPlotSeries()
        series.close()
        @ExpectThrows[ResourceDisposedException](series.clear())
    }

    // ---- QCandlestickSet ----

    @TestCase
    func testCandlestickSetCreateWithTimestamp() {
        let set = QCandlestickSet(1.0)
        @Expect(set.getPtr() != 0, true)
        @Expect(set.timestamp(), 1.0)
        set.close()
        @Expect(set.getPtr(), 0)
    }

    @TestCase
    func testCandlestickSetCreateWithOHLC() {
        let set = QCandlestickSet(100.0, 105.0, 95.0, 102.0, 1.0)
        @Expect(set.getPtr() != 0, true)
        @Expect(set.open(), 100.0)
        @Expect(set.high(), 105.0)
        @Expect(set.low(), 95.0)
        @Expect(set.closeValue(), 102.0)
        @Expect(set.timestamp(), 1.0)
        set.close()
    }

    @TestCase
    func testCandlestickSetSetters() {
        let set = QCandlestickSet(1.0)
        set.setOpen(100.0)
        set.setHigh(108.0)
        set.setLow(96.0)
        set.setClose(103.0)
        set.setTimestamp(2.0)
        @Expect(set.open(), 100.0)
        @Expect(set.high(), 108.0)
        @Expect(set.low(), 96.0)
        @Expect(set.closeValue(), 103.0)
        @Expect(set.timestamp(), 2.0)
        set.close()
    }

    @TestCase
    func testCandlestickSetCloseThenUseThrows() {
        let set = QCandlestickSet(1.0)
        set.close()
        @ExpectThrows[ResourceDisposedException](set.setOpen(1.0))
    }

    // ---- QCandlestickSeries ----

    @TestCase
    func testCandlestickSeriesCreateAndClose() {
        let series = QCandlestickSeries()
        @Expect(series.getPtr() != 0, true)
        series.close()
        @Expect(series.getPtr(), 0)
    }

    @TestCase
    func testCandlestickSeriesAppendSet() {
        let series = QCandlestickSeries()
        let candle1 = QCandlestickSet(100.0, 105.0, 95.0, 102.0, 1.0)
        let candle2 = QCandlestickSet(102.0, 108.0, 100.0, 98.0, 2.0)
        series.append(candle1)
        series.append(candle2)
        @Expect(series.count(), 2)
        // set 所有权已转给 series，series.close 级联释放
        series.close()
    }

    @TestCase
    func testCandlestickSeriesClear() {
        let series = QCandlestickSeries()
        let candle = QCandlestickSet(100.0, 105.0, 95.0, 102.0, 1.0)
        series.append(candle)
        series.clear()
        @Expect(series.count(), 0)
        series.close()
    }

    @TestCase
    func testCandlestickSeriesProperties() {
        let series = QCandlestickSeries()
        series.setBodyWidth(0.5)
        series.setBodyOutlineVisible(true)
        series.setCapsWidth(0.1)
        series.setCapsVisible(true)
        series.setIncreasingColor(255, 0, 0)
        series.setDecreasingColor(0, 255, 0)
        @Assert(true)
        series.close()
    }

    @TestCase
    func testCandlestickSeriesCloseThenUseThrows() {
        let series = QCandlestickSeries()
        series.close()
        @ExpectThrows[ResourceDisposedException](series.clear())
    }

    // ---- QPolarChart ----

    @TestCase
    func testPolarChartCreateAndClose() {
        let polar = QPolarChart()
        @Expect(polar.getPtr() != 0, true)
        polar.close()
        @Expect(polar.getPtr(), 0)
    }

    @TestCase
    func testPolarChartAddSeries() {
        let polar = QPolarChart()
        let series = QLineSeries()
        series.append(0.0, 10.0)
        series.append(90.0, 20.0)
        series.append(180.0, 15.0)
        polar.addSeries(series)
        polar.createDefaultAxes()
        @Assert(true)
        // series 所有权已转给 polar
        polar.close()
    }

    @TestCase
    func testPolarChartSetTitle() {
        let polar = QPolarChart()
        polar.setTitle("极坐标图")
        @Assert(true)
        polar.close()
    }

    @TestCase
    func testPolarChartAddAxis() {
        let polar = QPolarChart()
        let radialAxis = QValueAxis()
        radialAxis.setRange(0.0, 100.0)
        let angularAxis = QValueAxis()
        angularAxis.setRange(0.0, 360.0)
        polar.addAxis(radialAxis, PolarOrientation.radial)
        polar.addAxis(angularAxis, PolarOrientation.angular)
        @Assert(true)
        // axis 所有权已转给 polar
        polar.close()
    }

    @TestCase
    func testPolarChartGetLegend() {
        let polar = QPolarChart()
        let legend = polar.getLegend()
        @Expect(legend.getPtr() != 0, true)
        legend.setAlignment(AxisAlignment.bottom)
        // legend 非拥有式，勿 close
        polar.close()
    }

    @TestCase
    func testPolarChartCloseThenUseThrows() {
        let polar = QPolarChart()
        polar.close()
        @ExpectThrows[ResourceDisposedException](polar.createDefaultAxes())
    }

    // ---- 常量验证 ----

    @TestCase
    func testPolarOrientationConstants() {
        @Expect(PolarOrientation.radial, 1)
        @Expect(PolarOrientation.angular, 2)
    }

    // ---- 集成：QChart.addSeries 重载 ----

    @TestCase
    func testChartAddBoxPlotSeries() {
        let chart = QChart()
        let series = QBoxPlotSeries()
        let box1 = QBoxSet(10.0, 20.0, 30.0, 40.0, 50.0)
        let box2 = QBoxSet(15.0, 25.0, 35.0, 45.0, 55.0)
        series.append(box1)
        series.append(box2)
        series.setBoxWidth(0.5)
        chart.addSeries(series)
        chart.createDefaultAxes()
        @Assert(true)
        // series + box 所有权已转给 chart
        chart.close()
    }

    @TestCase
    func testChartAddCandlestickSeries() {
        let chart = QChart()
        let series = QCandlestickSeries()
        series.setIncreasingColor(255, 0, 0)
        series.setDecreasingColor(0, 255, 0)
        let candle1 = QCandlestickSet(100.0, 105.0, 95.0, 102.0, 1.0)
        let candle2 = QCandlestickSet(102.0, 108.0, 100.0, 98.0, 2.0)
        series.append(candle1)
        series.append(candle2)
        chart.addSeries(series)
        chart.createDefaultAxes()
        @Assert(true)
        // series + candle 所有权已转给 chart
        chart.close()
    }

    // ---- 集成：QPolarChart.addSeries 各类型 ----

    @TestCase
    func testPolarChartAddBoxPlotSeries() {
        let polar = QPolarChart()
        let series = QBoxPlotSeries()
        let box = QBoxSet(10.0, 20.0, 30.0, 40.0, 50.0)
        series.append(box)
        polar.addSeries(series)
        polar.createDefaultAxes()
        @Assert(true)
        polar.close()
    }

    @TestCase
    func testPolarChartAddCandlestickSeries() {
        let polar = QPolarChart()
        let series = QCandlestickSeries()
        let candle = QCandlestickSet(100.0, 105.0, 95.0, 102.0, 1.0)
        series.append(candle)
        polar.addSeries(series)
        polar.createDefaultAxes()
        @Assert(true)
        polar.close()
    }
}