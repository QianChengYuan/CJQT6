package CjMonitor.ui

import std.collection.*
import CjMonitor.common.*
import CjMonitor.probe.*
import CjMonitor.app.*
import CjMonitor.report.*

// ============================================================
// 巡检报告装配
//
// ui 可以同时看到 app（状态）、report（打印）与进程页，
// 因此报告数据的**装配点放在 ui**，report 包只负责排版输出，
// 保持 report → common 的单向依赖。
// ============================================================

/// 导出巡检报告到指定路径
public func exportInspectionReport(path: String): Unit {
    if (let Some(s) <- gAppState) {
        let peaks = ArrayList<Float64>()
        let avgs = ArrayList<Float64>()
        var i: Int64 = 0
        while (i < Int64(Channel.COUNT)) {
            let st = s.channelStats(Int32(i))
            peaks.add(st.max())
            avgs.add(st.avg())
            i += 1
        }

        let procLines = match (gProcessTab) {
            case Some(pt) => pt.topLines(10)
            case None => ArrayList<String>()
        }

        let alerts = match (s.alerterRef()) {
            case Some(a) => a.count()
            case None => 0
        }

        // 曲线取最近 10 分钟落库数据（未落库时为空，报告会注明）
        let now = epochMs()
        let rows = s.queryHistory(now - 600000, now, 2000)

        let data = ReportData(
            Platform.name(),
            s.probeName(),
            wallClockHms(),
            s.totalSamples(),
            s.intervalStats().summary(),
            peaks,
            avgs,
            alerts,
            rows,
            procLines
        )

        let ok = exportPdf(data, path)
        if (ok) {
            publishStatus("巡检报告已导出：${path}")
            setAlertText("巡检报告已导出：${path}", 0)
        } else {
            publishStatus("巡检报告导出失败：${path}")
            setAlertText("巡检报告导出失败，请检查路径与打印支持", 2)
        }
    } else {
        publishStatus("状态未就绪，无法导出报告")
    }
}
