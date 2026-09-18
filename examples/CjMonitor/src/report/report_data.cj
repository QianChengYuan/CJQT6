package CjMonitor.report

import std.collection.*
import cjqt6.paint.*
import cjqt6.print.*
import CjMonitor.common.*

// ============================================================
// 巡检报告 PDF（三页）
//   第 1 页：摘要（平台 / 采集器 / 样本数 / 间隔统计 / 各通道峰值均值 / 告警次数）
//   第 2 页：历史曲线（CPU 与 内存，自绘折线）
//   第 3 页：进程 TOP10
//
// 事实说明（已核实）：
//   - 打印常量类名是 OutputFormat / PageSize / PageOrientation
//     （**不是** PrintFormat / Orientation）
//   - QPainter 可绑定 QPrinter：QPainter(printer.getPtr())
//   - 翻页用 QPrinter.newPage()（QPainter 侧未封装 newPage）
//   - PDF 是白底，因此本模块**不复用**深色主题配色，另建打印色板
// ============================================================

// ---- 打印色板（白底可读）----
let PDF_TEXT = Rgb(28, 32, 40)
let PDF_MUTED = Rgb(112, 120, 132)
let PDF_ACCENT = Rgb(0, 138, 122)
let PDF_GRID = Rgb(214, 219, 226)
let PDF_CPU = Rgb(0, 138, 122)
let PDF_MEM = Rgb(36, 112, 178)

/// 报告数据（由调用方装配；report 包不反向依赖 ui/app）
public class ReportData {
    public let platform: String
    public let probeName: String
    public let generatedAt: String
    public let sampleCount: Int64
    public let intervalSummary: String
    public let channelPeak: ArrayList<Float64>
    public let channelAvg: ArrayList<Float64>
    public let alertCount: Int64
    public let curve: ArrayList<Sample>
    public let topProcLines: ArrayList<String>

    public init(
        platform: String,
        probeName: String,
        generatedAt: String,
        sampleCount: Int64,
        intervalSummary: String,
        channelPeak: ArrayList<Float64>,
        channelAvg: ArrayList<Float64>,
        alertCount: Int64,
        curve: ArrayList<Sample>,
        topProcLines: ArrayList<String>
    ) {
        this.platform = platform
        this.probeName = probeName
        this.generatedAt = generatedAt
        this.sampleCount = sampleCount
        this.intervalSummary = intervalSummary
        this.channelPeak = channelPeak
        this.channelAvg = channelAvg
        this.alertCount = alertCount
        this.curve = curve
        this.topProcLines = topProcLines
    }
}

/// 导出三页巡检报告。成功返回 true。
public func exportPdf(data: ReportData, path: String): Bool {
    let printer = QPrinter()
    printer.setOutputFormat(OutputFormat.pdfFormat())
    printer.setOutputFileName(path)
    printer.setPageSize(PageSize.a4())
    printer.setOrientation(PageOrientation.portrait())

    let painter = QPainter(printer.getPtr())
    if (!painter.isActive()) {
        painter.close()
        printer.close()
        return false
    }

    let titleFont = QFont("Microsoft YaHei UI", 16)
    let bodyFont = QFont("Microsoft YaHei UI", 10)
    let monoFont = QFont("Consolas", 9)

    let left: Int32 = 48
    let right: Int32 = 548
    let width = right - left

    // ================= 第 1 页：摘要 =================
    var y: Int32 = 72
    painter.setFont(titleFont)
    painter.setPenColor(rgbSolid(PDF_TEXT))
    painter.drawText(left, y, "CjMonitor 巡检报告")
    y += 10
    painter.setPenColor(rgbSolid(PDF_ACCENT))
    painter.drawLine(left, y, right, y)
    y += 28

    painter.setFont(bodyFont)
    painter.setPenColor(rgbSolid(PDF_MUTED))
    painter.drawText(left, y, "生成时间：${data.generatedAt}")
    y += 20
    painter.drawText(left, y, "平台：${data.platform}　采集器：${data.probeName}")
    y += 20
    painter.drawText(left, y, "样本数：${data.sampleCount}　告警次数：${data.alertCount}")
    y += 20
    painter.drawText(left, y, "采样间隔：${data.intervalSummary}")
    y += 34

    painter.setPenColor(rgbSolid(PDF_TEXT))
    painter.drawText(left, y, "各通道统计")
    y += 6
    painter.setPenColor(rgbSolid(PDF_GRID))
    painter.drawLine(left, y, right, y)
    y += 20
    painter.setPenColor(rgbSolid(PDF_MUTED))

    var i: Int64 = 0
    while (i < Int64(Channel.COUNT)) {
        let nm = Channel.name(Int32(i))
        let unit = Channel.unit(Int32(i))
        var peak = 0.0
        var avg = 0.0
        if (i < Int64(data.channelPeak.size)) {
            peak = data.channelPeak[i]
        }
        if (i < Int64(data.channelAvg.size)) {
            avg = data.channelAvg[i]
        }
        let line = "  ${nm}    峰值 ${fmt1(peak)}${unit}    均值 ${fmt1(avg)}${unit}"
        painter.drawText(left, y, line)
        y += 20
        i += 1
    }

    // ================= 第 2 页：曲线 =================
    if (!printer.newPage()) {
        painter.close()
        printer.close()
        return false
    }
    y = 72
    painter.setFont(titleFont)
    painter.setPenColor(rgbSolid(PDF_TEXT))
    painter.drawText(left, y, "历史区间曲线")
    y += 10
    painter.setPenColor(rgbSolid(PDF_ACCENT))
    painter.drawLine(left, y, right, y)
    y += 24

    let plotTop = y
    let plotH: Int32 = 380
    let plotBottom = plotTop + plotH

    // 网格
    painter.setPenColor(rgbSolid(PDF_GRID))
    var gi: Int32 = 0
    while (gi <= 4) {
        let gy = plotTop + plotH * gi / 4
        painter.drawLine(left, gy, right, gy)
        gi += 1
    }

    if (data.curve.size >= 2) {
        let n = data.curve.size
        let step = Float64(width) / Float64(n - 1)
        let fh = Float64(plotH)
        painter.setPenColor(rgbSolid(PDF_CPU))
        var k: Int64 = 0
        while (k < n - 1) {
            let v1 = clamp01(data.curve[k].cpu / 100.0)
            let v2 = clamp01(data.curve[k + 1].cpu / 100.0)
            let x1 = left + Int32(Float64(k) * step)
            let x2 = left + Int32(Float64(k + 1) * step)
            painter.drawLine(x1, plotBottom - Int32(v1 * fh), x2, plotBottom - Int32(v2 * fh))
            k += 1
        }
        painter.setPenColor(rgbSolid(PDF_MEM))
        k = 0
        while (k < n - 1) {
            let v1 = clamp01(data.curve[k].mem / 100.0)
            let v2 = clamp01(data.curve[k + 1].mem / 100.0)
            let x1 = left + Int32(Float64(k) * step)
            let x2 = left + Int32(Float64(k + 1) * step)
            painter.drawLine(x1, plotBottom - Int32(v1 * fh), x2, plotBottom - Int32(v2 * fh))
            k += 1
        }
    } else {
        painter.setFont(monoFont)
        painter.setPenColor(rgbSolid(PDF_MUTED))
        painter.drawText(left, plotTop + 40, "  （区间内无落库数据，曲线为空）")
    }

    // 图例
    painter.setFont(bodyFont)
    painter.setPenColor(rgbSolid(PDF_CPU))
    painter.drawText(left, plotBottom + 24, "■ CPU %")
    painter.setPenColor(rgbSolid(PDF_MEM))
    painter.drawText(left + 90, plotBottom + 24, "■ 内存 %")
    painter.setFont(monoFont)
    painter.setPenColor(rgbSolid(PDF_MUTED))
    painter.drawText(left, plotBottom + 48, "  纵轴 0~100，横轴为区间内相对时间；共 ${data.curve.size} 点")

    // ================= 第 3 页：进程 TOP10 =================
    if (!printer.newPage()) {
        painter.close()
        printer.close()
        return false
    }
    y = 72
    painter.setFont(titleFont)
    painter.setPenColor(rgbSolid(PDF_TEXT))
    painter.drawText(left, y, "进程 TOP10（按 CPU 降序）")
    y += 10
    painter.setPenColor(rgbSolid(PDF_ACCENT))
    painter.drawLine(left, y, right, y)
    y += 28

    painter.setFont(monoFont)
    painter.setPenColor(rgbSolid(PDF_TEXT))
    if (data.topProcLines.size == 0) {
        painter.setPenColor(rgbSolid(PDF_MUTED))
        painter.drawText(left, y, "  （进程页尚未采集到数据）")
    } else {
        var p: Int64 = 0
        while (p < Int64(data.topProcLines.size)) {
            painter.drawText(left, y, "  ${data.topProcLines[p]}")
            y += 18
            p += 1
        }
    }

    painter.close()
    titleFont.delete()
    bodyFont.delete()
    monoFont.delete()
    printer.close()
    true
}
