package charts_demo

import cjqt6.core.*
import cjqt6.charts.*
import cjqt6.widgets.*

// ============================================================
// Qt Charts 全序列示例
// ------------------------------------------------------------
// 用 QTabWidget 分页演示 17 页（13 种序列 + 极坐标图 + 3 种轴 + 饼图切片）：
//   1. 折线图    QLineSeries
//   2. 柱状图    QBarSeries + QBarSet
//   3. 饼图      QPieSeries
//   4. 散点图    QScatterSeries
//   5. 区域图    QAreaSeries
//   6. 样条曲线  QSplineSeries
//   7. 百分比柱  QPercentBarSeries
//   8. 堆叠柱    QStackedBarSeries
//   9. 箱线图    QBoxPlotSeries + QBoxSet
//  10. K线图     QCandlestickSeries + QCandlestickSet
//  11. 极坐标图  QPolarChart
//  12. 饼图切片  QPieSlice（爆炸/颜色/标签位置）
//  13. 日期时间轴 QDateTimeAxis
//  14. 对数轴    QLogValueAxis
//  15. 水平柱状图 QHorizontalBarSeries
//  16. 水平百分比 QHorizontalPercentBarSeries
//  17. 水平堆叠柱 QHorizontalStackedBarSeries
//
// 运行：cjpm run（需 Qt 运行时 + Qt6Charts.dll 在 PATH 中）
// ============================================================

// QAreaSeries 不拥有 upper/lower QLineSeries，需手动管理生命周期
var areaUpper: ?QLineSeries = None
var areaLower: ?QLineSeries = None

// ---- 辅助函数：为每种序列创建 QChartView ----

func createLineChartView(): QChartView {
    let series = QLineSeries()
    series.setName("温度")
    series.append(0.0, 10.0)
    series.append(1.0, 15.0)
    series.append(2.0, 20.0)
    series.append(3.0, 18.0)
    series.append(4.0, 25.0)
    series.append(5.0, 22.0)
    series.append(6.0, 30.0)

    let chart = QChart()
    chart.addSeries(series)
    chart.setTitle("一周温度变化（折线图）")
    chart.createDefaultAxes()
    chart.setTheme(ChartTheme.dark)
    chart.setAnimationOptions(ChartAnimation.series)

    let view = QChartView()
    view.setChart(chart)
    return view
}

func createBarChartView(): QChartView {
    let series = QBarSeries()
    let set1 = QBarSet("产品A")
    set1.append(10.0); set1.append(20.0); set1.append(30.0); set1.append(40.0)
    let set2 = QBarSet("产品B")
    set2.append(15.0); set2.append(25.0); set2.append(35.0); set2.append(45.0)
    series.append(set1)
    series.append(set2)

    let chart = QChart()
    chart.addSeries(series)
    chart.setTitle("季度销量对比（柱状图）")
    chart.createDefaultAxes()
    chart.setAnimationOptions(ChartAnimation.series)

    let view = QChartView()
    view.setChart(chart)
    return view
}

func createPieChartView(): QChartView {
    let series = QPieSeries()
    series.append("苹果", 30.0)
    series.append("香蕉", 25.0)
    series.append("橙子", 20.0)
    series.append("葡萄", 25.0)
    series.setHoleSize(0.3)

    let chart = QChart()
    chart.addSeries(series)
    chart.setTitle("水果销量占比（饼图）")
    chart.setAnimationOptions(ChartAnimation.series)

    let view = QChartView()
    view.setChart(chart)
    return view
}

func createScatterChartView(): QChartView {
    let series = QScatterSeries()
    series.setName("测量点")
    series.append(1.0, 10.0)
    series.append(2.0, 25.0)
    series.append(3.0, 18.0)
    series.append(4.0, 32.0)
    series.append(5.0, 15.0)
    series.setMarkerShape(ScatterMarkerShape.circle)
    series.setMarkerSize(10.0)
    series.setColor(0, 100, 200)

    let chart = QChart()
    chart.addSeries(series)
    chart.setTitle("数据分布（散点图）")
    chart.createDefaultAxes()

    let view = QChartView()
    view.setChart(chart)
    return view
}

func createAreaChartView(): QChartView {
    let upper = QLineSeries()
    upper.append(0.0, 30.0); upper.append(1.0, 35.0); upper.append(2.0, 40.0)
    upper.append(3.0, 38.0); upper.append(4.0, 45.0); upper.append(5.0, 42.0)
    let lower = QLineSeries()
    lower.append(0.0, 10.0); lower.append(1.0, 12.0); lower.append(2.0, 15.0)
    lower.append(3.0, 13.0); lower.append(4.0, 18.0); lower.append(5.0, 16.0)

    // 保存到全局变量，以便最后手动 close
    areaUpper = Some(upper)
    areaLower = Some(lower)

    let area = QAreaSeries(upper, lower)
    area.setColor(100, 150, 200)

    let chart = QChart()
    chart.addSeries(area)
    chart.setTitle("温度区间（区域图）")
    chart.createDefaultAxes()

    let view = QChartView()
    view.setChart(chart)
    return view
}

func createSplineChartView(): QChartView {
    let series = QSplineSeries()
    series.setName("平滑曲线")
    series.append(0.0, 10.0)
    series.append(1.0, 25.0)
    series.append(2.0, 15.0)
    series.append(3.0, 30.0)
    series.append(4.0, 20.0)
    series.append(5.0, 35.0)

    let chart = QChart()
    chart.addSeries(series)
    chart.setTitle("平滑数据趋势（样条曲线）")
    chart.createDefaultAxes()
    chart.setAnimationOptions(ChartAnimation.series)

    let view = QChartView()
    view.setChart(chart)
    return view
}

func createPercentBarChartView(): QChartView {
    let series = QPercentBarSeries()
    let set1 = QBarSet("产品A")
    set1.append(10.0); set1.append(20.0); set1.append(30.0)
    let set2 = QBarSet("产品B")
    set2.append(20.0); set2.append(30.0); set2.append(40.0)
    let set3 = QBarSet("产品C")
    set3.append(30.0); set3.append(10.0); set3.append(20.0)
    series.append(set1)
    series.append(set2)
    series.append(set3)
    series.setLabelsVisible(true)

    let chart = QChart()
    chart.addSeries(series)
    chart.setTitle("市场份额（百分比柱状图）")
    chart.createDefaultAxes()

    let view = QChartView()
    view.setChart(chart)
    return view
}

func createStackedBarChartView(): QChartView {
    let series = QStackedBarSeries()
    let set1 = QBarSet("产品A")
    set1.append(10.0); set1.append(20.0); set1.append(30.0)
    let set2 = QBarSet("产品B")
    set2.append(15.0); set2.append(25.0); set2.append(35.0)
    let set3 = QBarSet("产品C")
    set3.append(20.0); set3.append(15.0); set3.append(25.0)
    series.append(set1)
    series.append(set2)
    series.append(set3)

    let chart = QChart()
    chart.addSeries(series)
    chart.setTitle("累计销量（堆叠柱状图）")
    chart.createDefaultAxes()

    let view = QChartView()
    view.setChart(chart)
    return view
}

func createBoxPlotChartView(): QChartView {
    let series = QBoxPlotSeries()
    series.setBoxWidth(0.5)
    let box1 = QBoxSet(10.0, 20.0, 30.0, 40.0, 50.0)
    let box2 = QBoxSet(15.0, 25.0, 35.0, 45.0, 55.0)
    let box3 = QBoxSet(20.0, 30.0, 40.0, 50.0, 60.0)
    let box4 = QBoxSet(12.0, 22.0, 32.0, 42.0, 52.0)
    series.append(box1)
    series.append(box2)
    series.append(box3)
    series.append(box4)

    let chart = QChart()
    chart.addSeries(series)
    chart.setTitle("数据分布统计（箱线图）")
    chart.createDefaultAxes()

    let view = QChartView()
    view.setChart(chart)
    return view
}

func createCandlestickChartView(): QChartView {
    let series = QCandlestickSeries()
    series.setIncreasingColor(255, 0, 0)
    series.setDecreasingColor(0, 200, 0)
    series.setCapsVisible(true)

    // 模拟 5 天 K 线数据（timestamp 为 Unix 时间戳秒数）
    // 2026-08-25 ~ 2026-08-29 共 5 个交易日
    let baseTime = 1787616000.0  // 2026-08-25 00:00:00 UTC
    let day = 86400.0            // 一天的秒数
    let c1 = QCandlestickSet(100.0, 108.0, 95.0, 102.0, baseTime)
    let c2 = QCandlestickSet(102.0, 110.0, 100.0, 98.0, baseTime + day)
    let c3 = QCandlestickSet(98.0, 105.0, 92.0, 103.0, baseTime + day * 2.0)
    let c4 = QCandlestickSet(103.0, 115.0, 101.0, 112.0, baseTime + day * 3.0)
    let c5 = QCandlestickSet(112.0, 118.0, 108.0, 110.0, baseTime + day * 4.0)
    series.append(c1)
    series.append(c2)
    series.append(c3)
    series.append(c4)
    series.append(c5)

    let chart = QChart()
    chart.addSeries(series)
    chart.setTitle("股价走势（K线图）")
    chart.createDefaultAxes()

    let view = QChartView()
    view.setChart(chart)
    return view
}

// ---- 饼图切片（QPieSlice 高级用法）----

func createPieSliceChartView(): QChartView {
    let series = QPieSeries()
    series.setHoleSize(0.35)

    // 用 QPieSlice 对象创建切片，设置颜色、爆炸、标签位置
    let slice1 = QPieSlice("产品A", 35.0)
    slice1.setColor(255, 100, 100)
    slice1.setExploded(true)
    slice1.setExplodeDistanceFactor(0.08)
    slice1.setLabelPosition(PieSliceLabelPosition.outside)
    slice1.setLabelVisible(true)

    let slice2 = QPieSlice("产品B", 25.0)
    slice2.setColor(100, 200, 100)
    slice2.setLabelPosition(PieSliceLabelPosition.outside)
    slice2.setLabelVisible(true)

    let slice3 = QPieSlice("产品C", 20.0)
    slice3.setColor(100, 100, 255)
    slice3.setLabelPosition(PieSliceLabelPosition.outside)
    slice3.setLabelVisible(true)

    let slice4 = QPieSlice("产品D", 20.0)
    slice4.setColor(255, 200, 50)
    slice4.setLabelPosition(PieSliceLabelPosition.outside)
    slice4.setLabelVisible(true)

    series.append(slice1)
    series.append(slice2)
    series.append(slice3)
    series.append(slice4)

    let chart = QChart()
    chart.addSeries(series)
    chart.setTitle("产品占比（QPieSlice 爆炸+配色）")
    chart.setAnimationOptions(ChartAnimation.series)

    let view = QChartView()
    view.setChart(chart)
    return view
}

// ---- 日期时间轴（QDateTimeAxis）----

func createDateTimeAxisChartView(): QChartView {
    let series = QLineSeries()
    series.setName("访问量")

    // 模拟 7 天数据（timestamp 为 Unix 秒）
    let baseTime = 1787616000.0  // 2026-08-25 00:00:00 UTC
    let day = 86400.0
    let values = [120.0, 150.0, 180.0, 140.0, 200.0, 170.0, 210.0]
    for (i in 0..7) {
        series.append(baseTime + day * Float64(i), values[i])
    }

    let chart = QChart()
    chart.addSeries(series)
    chart.setTitle("一周访问量（日期时间轴）")

    // 用 QDateTimeAxis 替代默认轴
    let axisX = QDateTimeAxis()
    axisX.setFormat("MM-dd")
    axisX.setRange(baseTime, baseTime + day * 6.0)
    axisX.setTickCount(7)
    chart.addAxis(axisX, AxisAlignment.bottom)

    let axisY = QValueAxis()
    axisY.setRange(0.0, 250.0)
    axisY.setTickCount(6)
    axisY.setLabelFormat("%.0f")
    chart.addAxis(axisY, AxisAlignment.left)

    let view = QChartView()
    view.setChart(chart)
    return view
}

// ---- 对数轴（QLogValueAxis）----

func createLogValueAxisChartView(): QChartView {
    let series = QLineSeries()
    series.setName("指数增长")

    // 模拟指数增长数据 y = 2^x
    var y = 1.0
    for (i in 0..11) {
        series.append(Float64(i), y)
        y *= 2.0
    }

    let chart = QChart()
    chart.addSeries(series)
    chart.setTitle("指数增长 2^x（对数轴）")

    // X 轴用普通数值轴
    let axisX = QValueAxis()
    axisX.setRange(0.0, 10.0)
    axisX.setTickCount(11)
    axisX.setLabelFormat("%.0f")
    chart.addAxis(axisX, AxisAlignment.bottom)

    // Y 轴用对数轴
    let axisY = QLogValueAxis()
    axisY.setRange(1.0, 1024.0)
    axisY.setBase(10.0)
    axisY.setLabelFormat("%.0f")
    axisY.setMinorTickCount(8)
    chart.addAxis(axisY, AxisAlignment.left)

    let view = QChartView()
    view.setChart(chart)
    return view
}

// ---- 水平柱状图（QHorizontalBarSeries）----

func createHorizontalBarChartView(): QChartView {
    let series = QHorizontalBarSeries()

    let set1 = QBarSet("产品A")
    set1.append(10.0); set1.append(20.0); set1.append(30.0); set1.append(40.0)
    let set2 = QBarSet("产品B")
    set2.append(15.0); set2.append(25.0); set2.append(35.0); set2.append(20.0)

    series.append(set1)
    series.append(set2)

    let chart = QChart()
    chart.addSeries(series)
    chart.setTitle("产品对比（水平柱状图）")
    chart.createDefaultAxes()

    let view = QChartView()
    view.setChart(chart)
    return view
}

// ---- 水平百分比柱状图（QHorizontalPercentBarSeries）----

func createHorizontalPercentBarChartView(): QChartView {
    let series = QHorizontalPercentBarSeries()

    let set1 = QBarSet("Q1")
    set1.append(30.0); set1.append(40.0); set1.append(50.0)
    let set2 = QBarSet("Q2")
    set2.append(50.0); set2.append(30.0); set2.append(20.0)
    let set3 = QBarSet("Q3")
    set3.append(20.0); set3.append(30.0); set3.append(30.0)

    series.append(set1)
    series.append(set2)
    series.append(set3)

    let chart = QChart()
    chart.addSeries(series)
    chart.setTitle("季度占比（水平百分比柱）")
    chart.createDefaultAxes()

    let view = QChartView()
    view.setChart(chart)
    return view
}

// ---- 水平堆叠柱状图（QHorizontalStackedBarSeries）----

func createHorizontalStackedBarChartView(): QChartView {
    let series = QHorizontalStackedBarSeries()

    let set1 = QBarSet("线上")
    set1.append(10.0); set1.append(15.0); set1.append(20.0); set1.append(25.0)
    let set2 = QBarSet("线下")
    set2.append(20.0); set2.append(25.0); set2.append(30.0); set2.append(15.0)
    let set3 = QBarSet("其他")
    set3.append(5.0); set3.append(10.0); set3.append(8.0); set3.append(12.0)

    series.append(set1)
    series.append(set2)
    series.append(set3)

    let chart = QChart()
    chart.addSeries(series)
    chart.setTitle("渠道堆叠（水平堆叠柱）")
    chart.createDefaultAxes()

    let view = QChartView()
    view.setChart(chart)
    return view
}

func createPolarChartView(): QChartView {
    let polar = QPolarChart()
    polar.setTitle("极坐标图")

    let series = QLineSeries()
    // 螺旋线数据
    var i = 0
    while (i < 360) {

        let r = Float64(i) / 10.0
        series.append(Float64(i), r)
        i += 5
    }
    polar.addSeries(series)
    polar.createDefaultAxes()
    polar.setTheme(ChartTheme.blueNcs)

    let view = QChartView()
    view.setChart(polar)
    return view
}

// ---- 主函数 ----

main() {
    println("=== Qt Charts 全序列示例 ===")
    let app = QApplication()

    // 创建 TabWidget
    let tabs = QTabWidget()

    // 为每种序列创建一个 tab
    tabs.addTab(createLineChartView().getPtr(), "折线图")
    tabs.addTab(createBarChartView().getPtr(), "柱状图")
    tabs.addTab(createPieChartView().getPtr(), "饼图")
    tabs.addTab(createScatterChartView().getPtr(), "散点图")
    tabs.addTab(createAreaChartView().getPtr(), "区域图")
    tabs.addTab(createSplineChartView().getPtr(), "样条曲线")
    tabs.addTab(createPercentBarChartView().getPtr(), "百分比柱")
    tabs.addTab(createStackedBarChartView().getPtr(), "堆叠柱")
    tabs.addTab(createBoxPlotChartView().getPtr(), "箱线图")
    tabs.addTab(createCandlestickChartView().getPtr(), "K线图")
    tabs.addTab(createPolarChartView().getPtr(), "极坐标图")
    tabs.addTab(createPieSliceChartView().getPtr(), "饼图切片")
    tabs.addTab(createDateTimeAxisChartView().getPtr(), "日期时间轴")
    tabs.addTab(createLogValueAxisChartView().getPtr(), "对数轴")
    tabs.addTab(createHorizontalBarChartView().getPtr(), "水平柱状图")
    tabs.addTab(createHorizontalPercentBarChartView().getPtr(), "水平百分比柱")
    tabs.addTab(createHorizontalStackedBarChartView().getPtr(), "水平堆叠柱")

    tabs.resize(800, 600)
    tabs.show()

    println("共 ${tabs.count()} 个图表页，3 秒后自动退出...")

    // 定时退出
    // let timer = QTimer()
    // timer.setInterval(3000)
    // timer.setOnTimeout({ => QApp.quit() })
    // timer.start()

    app.exec()

    println("[OK] Qt Charts 全序列渲染完成")

    // 清理：tabs.close 级联释放所有 QChartView → QChart → Series
    // timer.stop()
    // timer.close()
    tabs.close()

    // QAreaSeries 不拥有 upper/lower，需手动释放
    if (let Some(upper) <- areaUpper) {
        upper.close()
    }
    if (let Some(lower) <- areaLower) {
        lower.close()
    }

    app.delete()
}