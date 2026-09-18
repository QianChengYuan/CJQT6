package CjMonitor.ui

import std.collection.*
import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.charts.*
import CjMonitor.common.*
import CjMonitor.app.*

// ============================================================
// 历史页：区间选择 + 查库 + 图表重建
//
// 与实时页的区别（也是本项目的对照实验之一）：
//   - 低频：只在点击查询时重建，不参与 100ms 刷新
//   - 用 cjqt6.charts 绘制，而非自绘
//
// 图表重建而非复用：QLineSeries 没有 setColor/setPen/clear，
// 改数据或改配色只能换一块新图（详见技能 api-cheatsheet）。
// ============================================================

public class HistoryTab {
    private let page: QWidget
    private let chartView: QChartView
    private let summary: QLabel
    private let combo: QComboBox
    private let status: QLabel

    public init() {
        page = QWidget()

        let v = QVBoxLayout()
        v.setMargin(10)
        v.setSpacing(8)

        // ---- 顶部：区间选择 + 查询 ----
        let bar = QHBoxLayout()
        bar.setSpacing(8)

        let label = QLabel()
        label.setText("时间区间")
        label.setStyleSheet(qssSubtitle())
        bar.addWidget(label.getPtr())

        combo = QComboBox()
        combo.addItem("最近 1 分钟")
        combo.addItem("最近 5 分钟")
        combo.addItem("最近 1 小时")
        combo.setCurrentIndex(1)
        bar.addWidget(combo.getPtr())

        let queryBtn = QPushButton()
        queryBtn.setText("查询")
        bar.addWidget(queryBtn.getPtr())

        bar.addStretch()

        summary = QLabel()
        summary.setText("区间摘要：—")
        summary.setStyleSheet(qssSubtitle())
        bar.addWidget(summary.getPtr())
        v.addLayout(bar.getPtr())

        // ---- 中部：图表 ----
        chartView = QChartView()
        v.addWidget(chartView.getPtr(), 1)

        // ---- 底部：状态 ----
        status = QLabel()
        status.setText("提示：历史页低频重建，用 cjqt6.charts；实时页 100ms 自绘，两者可做性能对照")
        status.setStyleSheet(qssMuted())
        v.addWidget(status.getPtr())

        page.setLayout(v.getPtr())

        // 回调必须在所有成员初始化完成后再注册：init 期间捕获 this 会触发
        // “not allowed to be accessed before all member variables are initialized”
        queryBtn.setOnClickCapture({ => this.runQuery() })
    }

    public func widget(): QWidget {
        page
    }

    /// 查询状态文本（M4 自测读取：含重建点数与跨度）
    public func statusText(): String {
        status.text()
    }

    /// 区间摘要文本（峰值/均值）
    public func summaryText(): String {
        summary.text()
    }

    public func dispose(): Unit {
        chartView.close()
        page.close()
    }

    // ========================================================
    // 查询与重建
    // ========================================================

    public func runQuery(): Unit {
        if (let Some(s) <- gAppState) {
            let idx = combo.currentIndex()
            var spanMs: Int64 = 300000
            match (idx) {
                case 0 => spanMs = 60000
                case 2 => spanMs = 3600000
                case _ => spanMs = 300000
            }
            let now = epochMs()
            let rows = s.queryHistory(now - spanMs, now, 2000)
            rebuild(rows)
        } else {
            status.setText("状态未就绪，无法查询")
        }
    }

    func rebuild(rows: ArrayList<Sample>): Unit {
        if (rows.size == 0) {
            summary.setText("区间摘要：无数据")
            status.setText("该区间没有落库数据。落库按 1/10 降采样、每 60 条攒批提交，请先让程序运行约 1 分钟。")
            return
        }

        let baseTs = rows[0].tsMs
        let cpuSeries = QLineSeries()
        cpuSeries.setName("CPU %")
        let memSeries = QLineSeries()
        memSeries.setName("内存 %")

        let cpuStats = ChannelStats()
        let memStats = ChannelStats()

        var i: Int64 = 0
        while (i < rows.size) {
            let r = rows[i]
            let x = Float64(r.tsMs - baseTs) / 1000.0
            cpuSeries.append(x, r.cpu)
            memSeries.append(x, r.mem)
            cpuStats.update(r.cpu)
            memStats.update(r.mem)
            i += 1
        }

        let chart = QChart()
        chart.setTitle("历史区间对照（${rows.size} 点）")
        chart.addSeries(cpuSeries)
        chart.addSeries(memSeries)
        chart.createDefaultAxes()
        chartView.setChart(chart)

        summary.setText("CPU 峰值=${fmt1(cpuStats.max())}% 均值=${fmt1(cpuStats.avg())}% · " +
            "内存 峰值=${fmt1(memStats.max())}% 均值=${fmt1(memStats.avg())}%")
        status.setText("已重建图表：${rows.size} 点，跨度 ${(rows[rows.size - 1].tsMs - baseTs) / 1000}s（图表对象每次重建，不复用）")
    }
}

/// 构建历史页
public func createHistoryTab(): HistoryTab {
    HistoryTab()
}
