package cjqt6.test

import cjqt6.core.*
import cjqt6.charts.*
import std.unittest.*

// =====================================================================
// QBarCategoryAxis / QCategoryAxis / QLegend 测试（GUI 环境）
// =====================================================================

@Test
class QAxisLegendTests {
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

    // ---- QBarCategoryAxis ----

    @TestCase
    func testBarCategoryAxisCreateAndClose() {
        let axis = QBarCategoryAxis()
        @Expect(axis.getPtr() != 0, true)
        axis.close()
        @Expect(axis.getPtr(), 0)
    }

    @TestCase
    func testBarCategoryAxisAppendAndCount() {
        let axis = QBarCategoryAxis()
        axis.append("周一")
        axis.append("周二")
        axis.append("周三")
        @Expect(axis.count(), 3)
        axis.close()
    }

    @TestCase
    func testBarCategoryAxisRemove() {
        let axis = QBarCategoryAxis()
        axis.append("周一")
        axis.append("周二")
        axis.append("周三")
        axis.remove("周二")
        @Expect(axis.count(), 2)
        axis.close()
    }

    @TestCase
    func testBarCategoryAxisInsert() {
        let axis = QBarCategoryAxis()
        axis.append("周二")
        axis.append("周三")
        axis.insert(0, "周一")
        @Expect(axis.count(), 3)
        axis.close()
    }

    @TestCase
    func testBarCategoryAxisClear() {
        let axis = QBarCategoryAxis()
        axis.append("周一")
        axis.append("周二")
        axis.append("周三")
        axis.clear()
        @Expect(axis.count(), 0)
        axis.close()
    }

    @TestCase
    func testBarCategoryAxisSetRange() {
        let axis = QBarCategoryAxis()
        axis.append("周一")
        axis.append("周二")
        axis.append("周三")
        axis.setMin("周一")
        axis.setMax("周三")
        axis.setRange("周一", "周二")
        @Assert(true)
        axis.close()
    }

    @TestCase
    func testBarCategoryAxisReplace() {
        let axis = QBarCategoryAxis()
        axis.append("周一")
        axis.append("周二")
        axis.replace("周二", "周四")
        @Expect(axis.count(), 2)
        axis.close()
    }

    @TestCase
    func testBarCategoryAxisCloseThenUseThrows() {
        let axis = QBarCategoryAxis()
        axis.close()
        @ExpectThrows[ResourceDisposedException](axis.append("x"))
    }

    // ---- QCategoryAxis ----

    @TestCase
    func testCategoryAxisCreateAndClose() {
        let axis = QCategoryAxis()
        @Expect(axis.getPtr() != 0, true)
        axis.close()
        @Expect(axis.getPtr(), 0)
    }

    @TestCase
    func testCategoryAxisAppendAndCount() {
        let axis = QCategoryAxis()
        axis.setRange(0.0, 30.0)
        axis.append("低", 10.0)
        axis.append("中", 20.0)
        axis.append("高", 30.0)
        @Expect(axis.count(), 3)
        axis.close()
    }

    @TestCase
    func testCategoryAxisLabelsPosition() {
        let axis = QCategoryAxis()
        axis.setLabelsPosition(CategoryAxisLabelsPosition.onValue)
        @Expect(axis.labelsPosition(), CategoryAxisLabelsPosition.onValue)
        axis.setLabelsPosition(CategoryAxisLabelsPosition.center)
        @Expect(axis.labelsPosition(), CategoryAxisLabelsPosition.center)
        axis.close()
    }

    @TestCase
    func testCategoryAxisInheritedValueAxis() {
        let axis = QCategoryAxis()
        axis.setRange(0.0, 100.0)
        axis.setTickCount(11)
        axis.setLabelFormat("%.0f")
        axis.setMin(0.0)
        axis.setMax(100.0)
        axis.setStartValue(0.0)
        @Assert(true)
        axis.close()
    }

    @TestCase
    func testCategoryAxisRemoveAndReplaceLabel() {
        let axis = QCategoryAxis()
        axis.setRange(0.0, 30.0)
        axis.append("低", 10.0)
        axis.append("中", 20.0)
        axis.replaceLabel("中", "中等")
        axis.remove("低")
        @Expect(axis.count(), 1)
        axis.close()
    }

    @TestCase
    func testCategoryAxisCloseThenUseThrows() {
        let axis = QCategoryAxis()
        axis.close()
        @ExpectThrows[ResourceDisposedException](axis.append("x", 1.0))
    }

    // ---- QLegend ----

    @TestCase
    func testChartGetLegend() {
        let chart = QChart()
        let legend = chart.getLegend()
        @Expect(legend.getPtr() != 0, true)
        chart.close()
    }

    @TestCase
    func testLegendSetAlignment() {
        let chart = QChart()
        let legend = chart.getLegend()
        legend.setAlignment(AxisAlignment.bottom)
        @Expect(legend.alignment(), AxisAlignment.bottom)
        legend.setAlignment(AxisAlignment.top)
        @Expect(legend.alignment(), AxisAlignment.top)
        chart.close()
    }

    @TestCase
    func testLegendBackgroundVisible() {
        let chart = QChart()
        let legend = chart.getLegend()
        legend.setBackgroundVisible(true)
        @Expect(legend.isBackgroundVisible(), true)
        legend.setBackgroundVisible(false)
        @Expect(legend.isBackgroundVisible(), false)
        chart.close()
    }

    @TestCase
    func testLegendMarkerShape() {
        let chart = QChart()
        let legend = chart.getLegend()
        legend.setMarkerShape(LegendMarkerShape.circle)
        @Expect(legend.markerShape(), LegendMarkerShape.circle)
        legend.setMarkerShape(LegendMarkerShape.rectangle)
        @Expect(legend.markerShape(), LegendMarkerShape.rectangle)
        legend.setMarkerShape(LegendMarkerShape.triangle)
        @Expect(legend.markerShape(), LegendMarkerShape.triangle)
        chart.close()
    }

    @TestCase
    func testLegendReverseMarkers() {
        let chart = QChart()
        let legend = chart.getLegend()
        legend.setReverseMarkers(true)
        @Expect(legend.reverseMarkers(), true)
        legend.setReverseMarkers(false)
        @Expect(legend.reverseMarkers(), false)
        chart.close()
    }

    @TestCase
    func testLegendInteractive() {
        let chart = QChart()
        let legend = chart.getLegend()
        legend.setInteractive(true)
        @Expect(legend.isInteractive(), true)
        legend.setInteractive(false)
        @Expect(legend.isInteractive(), false)
        chart.close()
    }

    @TestCase
    func testLegendShowToolTips() {
        let chart = QChart()
        let legend = chart.getLegend()
        legend.setShowToolTips(true)
        @Expect(legend.showToolTips(), true)
        chart.close()
    }

    @TestCase
    func testLegendColor() {
        let chart = QChart()
        let legend = chart.getLegend()
        legend.setColor(255, 255, 255)
        legend.setBorderColor(0, 0, 0)
        legend.setLabelColor(128, 128, 128)
        @Assert(true)
        chart.close()
    }

    @TestCase
    func testLegendDetachAttach() {
        let chart = QChart()
        let legend = chart.getLegend()
        legend.detachFromChart()
        @Expect(legend.isAttachedToChart(), false)
        legend.attachToChart()
        @Expect(legend.isAttachedToChart(), true)
        chart.close()
    }

    @TestCase
    func testLegendMarkerShapeConstants() {
        @Expect(LegendMarkerShape.defaultShape, 0)
        @Expect(LegendMarkerShape.rectangle, 1)
        @Expect(LegendMarkerShape.circle, 2)
        @Expect(LegendMarkerShape.fromSeries, 3)
        @Expect(LegendMarkerShape.rotatedRectangle, 4)
        @Expect(LegendMarkerShape.triangle, 5)
        @Expect(LegendMarkerShape.star, 6)
        @Expect(LegendMarkerShape.pentagon, 7)
    }

    @TestCase
    func testCategoryAxisLabelsPositionConstants() {
        @Expect(CategoryAxisLabelsPosition.center, 0)
        @Expect(CategoryAxisLabelsPosition.onValue, 1)
    }
}