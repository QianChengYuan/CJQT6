package CjMonitor.ui

import std.collection.*
import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.views.*
import CjMonitor.common.*
import CjMonitor.probe.*
import CjMonitor.app.*

// ============================================================
// 进程页：PID / 名称 / CPU% / 内存(MB)
//
// 采集方式：系统工具 + QProcess 读取（CJQT6 未封装系统 API）。
//   - Windows      : 临时 PowerShell 脚本（Get-Process），输出统一 4 字段行
//   - Linux / macOS: ps -eo pid,comm,%cpu,%mem
//
// 统一行格式（空格分隔）：pid name cpu% memMB
//
// 刷新策略（关键）：表格是重控件，**必须降频**。
//   本轮启动子进程 → 下一拍读取并填表 → 立即启动下一轮，
//   既不阻塞 UI 线程，也不需要额外的 stdout/finish 回调路由。
// ============================================================

/// Windows 端进程采集脚本（纯 ASCII）
let PROC_SCRIPT_NAME = "cjmonitor_procs.ps1"

let PROC_SCRIPT = """
$ErrorActionPreference = 'SilentlyContinue'
Get-Process |
    Sort-Object -Property CPU -Descending |
    Select-Object -First 60 |
    ForEach-Object {
        $n = $_.ProcessName
        $c = 0.0
        if ($_.CPU) { $c = [math]::Round($_.CPU, 1) }
        $m = [math]::Round($_.WorkingSet64 / 1MB, 1)
        Write-Output ("{0} {1} {2} {3}" -f $_.Id, $n, $c, $m)
    }
"""

// ---- M3 验收统计（顶层变量：界面自测直接读取；避免跨文件取 gProcessTab 形成文件级循环）----

/// 1s 定时器已触发的 tick 数
public var gProcTicks: Int64 = 0
/// 完成「采集 → 填表」的轮数
public var gProcRounds: Int64 = 0
/// 最近一轮「解析 + 填表」耗时（ms）
public var gProcRoundLastMs: Int64 = 0
/// 单轮填表耗时上限（ms）
public var gProcRoundMaxMs: Int64 = 0
/// 最近一次实际展示的行数
public var gProcRows: Int64 = 0

/// 进程行
class ProcRow {
    let pid: String
    let name: String
    let cpu: Float64
    let memMB: Float64

    init(pid: String, name: String, cpu: Float64, memMB: Float64) {
        this.pid = pid
        this.name = name
        this.cpu = cpu
        this.memMB = memMB
    }
}

/// 进程表（表格 + 1s 降频刷新）
public class ProcessTab {
    private let page: QWidget
    private let table: QTableWidget
    private let timer: QTimer
    private var proc: Option<QProcess> = None
    private var procCreated: Bool = false
    private var hasProc: Bool = false
    private var roundStartMs: Int64 = 0
    private var buffer: String = ""

    /// 最近一次成功解析的行（供巡检报告导出 TOP N 使用）
    private var lastRows: ArrayList<ProcRow> = ArrayList<ProcRow>()

    /// 表格最多展示行数（超出截断）
    private let maxRows: Int64 = 60

    public init() {
        page = QWidget()

        let v = QVBoxLayout()
        v.setMargin(10)
        v.setSpacing(8)

        let hint = QLabel()
        hint.setText("进程列表按 1 秒降频刷新（与曲线 100ms 解耦）")
        hint.setStyleSheet(qssSubtitle())
        v.addWidget(hint.getPtr())

        table = QTableWidget()
        table.setColumnCount(4)
        let headers = Array<String>(4, repeat: "")
        headers[0] = "PID"
        headers[1] = "名称"
        headers[2] = "CPU%"
        headers[3] = "内存(MB)"
        table.setHorizontalHeaderLabels(headers)
        table.setEditTriggers(0)
        table.setAlternatingRowColors(true)
        table.setShowGrid(false)
        table.setColumnWidth(0, 90)
        table.setColumnWidth(1, 320)
        table.setColumnWidth(2, 100)
        table.setHorizontalHeaderStretchLastSection(true)
        v.addWidget(table.getPtr(), 1)

        page.setLayout(v.getPtr())

        timer = QTimer()
        timer.setInterval(1000)
        timer.setOnTimeoutCapture({ => this.onTick() })
    }

    public func widget(): QWidget {
        page
    }

    public func start(): Unit {
        timer.start()
    }

    /// 取 CPU 降序的前 n 行文本（巡检报告用）
    public func topLines(n: Int64): ArrayList<String> {
        let cnt = if (lastRows.size < n) { lastRows.size } else { n }
        let out = ArrayList<String>()
        var i: Int64 = 0
        while (i < cnt) {
            let r = lastRows[i]
            out.add("PID=${r.pid}  名称=${r.name}  CPU=${fmt1(r.cpu)}%  内存=${fmt1(r.memMB)}MB")
            i += 1
        }
        out
    }

    public func dispose(): Unit {
        timer.stop()
        timer.close()
        if (let Some(p) <- proc) {
            if (p.isRunning()) {
                p.kill()
            }
            p.close()
        }
        proc = None
        procCreated = false
        table.close()
        page.close()
    }

    // ========================================================
    // 刷新循环
    // ========================================================

    func onTick(): Unit {
        gProcTicks += 1
        if (hasProc) {
            // 给子进程一点启动时间，避免刚 start 就判为已结束
            if (monoMs() - roundStartMs < 300) {
                return
            }
            if (let Some(p) <- proc) {
                buffer += p.readAllStandardOutput()
                if (!p.isRunning()) {
                    // 计时「解析 + 填表」：用于证明 1s 周期下表格刷新不阻塞 UI
                    let t0 = monoMs()
                    fillTable(buffer)
                    let cost = monoMs() - t0
                    gProcRoundLastMs = cost
                    if (gProcRoundMaxMs < cost) {
                        gProcRoundMaxMs = cost
                    }
                    gProcRounds += 1
                    hasProc = false
                }
            }
        }
        if (!hasProc) {
            startRound()
        }
    }

    func startRound(): Unit {
        buffer = ""
        if (!procCreated) {
            proc = Some(QProcess())
            procCreated = true
        }
        if (let Some(p) <- proc) {
            if (Platform.isWindows()) {
                // 与采样器同一套规避：脚本写临时目录，参数只给不含空格的文件名
                p.setWorkingDirectory(tempDir())
                p.startWithArgs("powershell", "-NoLogo -NoProfile -ExecutionPolicy Bypass -File " + PROC_SCRIPT_NAME)
            } else {
                p.startWithArgs("ps", "-eo pid,comm,%cpu,%mem")
            }
            hasProc = true
            roundStartMs = monoMs()
        }
    }

    // ========================================================
    // 解析与填表
    // ========================================================

    func fillTable(text: String): Unit {
        let rows = ArrayList<ProcRow>()
        for (line in text.split("\n")) {
            if (let Some(r) <- parseRow(line.trimAscii())) {
                rows.add(r)
            }
        }
        if (rows.size == 0) {
            return
        }
        sortByCpuDesc(rows)
        lastRows = rows

        let shown = if (rows.size < maxRows) { rows.size } else { maxRows }
        gProcRows = shown
        table.setRowCount(Int32(shown))
        var i: Int64 = 0
        while (i < shown) {
            let r = rows[i]
            table.setItem(Int32(i), 0, r.pid)
            table.setItem(Int32(i), 1, r.name)
            table.setItem(Int32(i), 2, fmt1(r.cpu))
            table.setItem(Int32(i), 3, fmt1(r.memMB))
            i += 1
        }
    }

    /// 统一解析：Windows 为 "pid name cpu mem"；Linux/macOS 为 ps 输出
    func parseRow(line: String): ?ProcRow {
        if (line.isEmpty()) {
            return None
        }
        let f = splitFields(line)
        if (f.size < 4) {
            return None
        }
        if (!isNumber(f[0])) {
            return None   // 跳过表头
        }
        if (Platform.isWindows()) {
            Some(ProcRow(f[0], f[1], toF64(f[2]), toF64(f[3])))
        } else {
            // ps 的 comm 可能含空格 → pid 取首段，cpu/mem 取末两段，中间并入名称
            let cpu = toF64(f[f.size - 2])
            let mem = toF64(f[f.size - 1])
            var name = ""
            var i: Int64 = 1
            while (i < f.size - 2) {
                if (!name.isEmpty()) {
                    name += " "
                }
                name += f[i]
                i += 1
            }
            Some(ProcRow(f[0], name, cpu, mem))
        }
    }

    func sortByCpuDesc(rows: ArrayList<ProcRow>): Unit {
        let n = rows.size
        var i: Int64 = 0
        while (i < n - 1) {
            var best = i
            var j: Int64 = i + 1
            while (j < n) {
                if (rows[j].cpu > rows[best].cpu) {
                    best = j
                }
                j += 1
            }
            if (best != i) {
                let tmp = rows[i]
                rows[i] = rows[best]
                rows[best] = tmp
            }
            i += 1
        }
    }
}

/// 构建进程页（同时把 Windows 采集脚本写入临时目录）
public func createProcessTab(): ProcessTab {
    if (Platform.isWindows()) {
        let _ = writeTempScript(PROC_SCRIPT_NAME, PROC_SCRIPT)
    }
    ProcessTab()
}
