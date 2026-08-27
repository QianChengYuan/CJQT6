package chart_demo

import cjqt6.core.*
import cjqt6.charts.*

// ============================================================
// Qt Charts 折线图示例
// ------------------------------------------------------------
// 验证 QChart / QChartView / QLineSeries 封装可正常渲染折线图。
// 运行：cjpm run（需 Qt 运行时 + Qt6Charts.dll 在 PATH 中）
// ============================================================

main() {
    println("=== Qt Charts 折线图示例 ===")
    let app = QApplication()

    // 1) 建折线序列，追加数据点
    let series = QLineSeries()
    series.setName("温度")
    series.append(0.0, 10.0)
    series.append(1.0, 15.0)
    series.append(2.0, 20.0)
    series.append(3.0, 18.0)
    series.append(4.0, 25.0)
    series.append(5.0, 22.0)
    series.append(6.0, 30.0)
    println("数据点数量: ${series.count()}")

    // 2) 建图表，添加序列、建默认轴、设标题与主题
    let chart = QChart()
    chart.addSeries(series)
    chart.setTitle("一周温度变化")
    chart.createDefaultAxes()
    chart.setTheme(ChartTheme.dark)
    chart.setAnimationOptions(ChartAnimation.series)

    // 3) 建视图，挂载图表，显示
    let view = QChartView()
    view.setChart(chart)
    view.resize(640, 480)
    view.show()

    // 4) 定时退出：让事件循环跑 1 秒，触发渲染
    let timer = QTimer()
    timer.setInterval(1000)
    timer.setOnTimeout({ => QApp.quit() })
    timer.start()

    println("图表已显示，1 秒后自动退出...")
    app.exec()

    println("[OK] Qt Charts 折线图渲染完成")

    // 5) 清理：view.close 级联释放 chart + series
    timer.stop()
    timer.close()
    view.close()
    app.delete()
}