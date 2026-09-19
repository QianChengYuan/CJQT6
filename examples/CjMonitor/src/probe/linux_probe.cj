package CjMonitor.probe

import std.fs.*
import CjMonitor.common.*

// ============================================================
// Linux 采集：直读 /proc
//
// 全部指标基于「两次采样求差」：
//   - CPU  : 1 - idle_delta / total_delta
//   - 磁盘 : io_ms_delta / wall_ms_delta
//   - 网络 : bytes_delta / wall_ms_delta → KB/s
//   - 内存 : 瞬时值（MemTotal / MemAvailable），无需差值
//
// 首帧无基线，必须丢弃（否则 CPU 恒为 0% 或 100%）。
// ============================================================

/// CPU 累加计数（值类型，避免为多返回值引入堆分配）
struct CpuTimes {
    let total: Int64
    let idle: Int64

    init(total: Int64, idle: Int64) {
        this.total = total
        this.idle = idle
    }
}

/// 网卡累计收发字节
struct NetBytes {
    let rx: Int64
    let tx: Int64

    init(rx: Int64, tx: Int64) {
        this.rx = rx
        this.tx = tx
    }
}

public class LinuxProbe <: Probe {
    private let ready: Bool

    // ---- 差值基线 ----
    private var hasBase: Bool = false
    private var baseMonoMs: Int64 = 0
    private var prevTotal: Int64 = 0
    private var prevIdle: Int64 = 0
    private var prevNetRxBytes: Int64 = 0
    private var prevNetTxBytes: Int64 = 0
    private var prevDiskIoMs: Int64 = 0

    // ---- 最近一次成功采样的值（读失败时保留，避免曲线出现尖坑）----
    private var lastCpu: Float64 = 0.0
    private var lastMem: Float64 = 0.0
    private var lastDisk: Float64 = 0.0
    private var lastNetRx: Float64 = 0.0
    private var lastNetTx: Float64 = 0.0

    public init() {
        this.ready = exists(Path("/proc/stat")) && exists(Path("/proc/meminfo"))
    }

    public func probeName(): String {
        "/proc 直读"
    }

    public func available(): Bool {
        ready
    }

    public func baselineReady(): Bool {
        hasBase
    }

    public func dispose(): Unit {
        () // 无外部资源
    }

    public func sample(): ?Sample {
        if (!ready) {
            return None
        }

        // 首帧：只建立基线，不产出数据
        if (!hasBase) {
            let c = readCpuCounters()
            if (let Some(cv) <- c) {
                prevTotal = cv.total
                prevIdle = cv.idle
            }
            let n = readNetCounters()
            if (let Some(nv) <- n) {
                prevNetRxBytes = nv.rx
                prevNetTxBytes = nv.tx
            }
            let io = readDiskIoMs()
            if (let Some(v) <- io) {
                prevDiskIoMs = v
            }
            baseMonoMs = monoMs()
            hasBase = true
            return None
        }

        let nowMono = monoMs()
        let dtMs = nowMono - baseMonoMs
        if (dtMs <= 0) {
            return None
        }

        // CPU：差值法
        let c = readCpuCounters()
        if (let Some(cv) <- c) {
            let dTotal = cv.total - prevTotal
            let dIdle = cv.idle - prevIdle
            if (dTotal > 0) {
                lastCpu = clampPercent(Float64(dTotal - dIdle) / Float64(dTotal) * 100.0)
            }
            prevTotal = cv.total
            prevIdle = cv.idle
        }

        // 内存：瞬时值
        let m = readMemPercent()
        if (let Some(mv) <- m) {
            lastMem = clampPercent(mv)
        }

        // 网络：字节增量 → KB/s
        let n = readNetCounters()
        if (let Some(nv) <- n) {
            let dRx = nv.rx - prevNetRxBytes
            let dTx = nv.tx - prevNetTxBytes
            if (dRx >= 0 && dTx >= 0) {
                let secs = Float64(dtMs) / 1000.0
                lastNetRx = Float64(dRx) / 1024.0 / secs
                lastNetTx = Float64(dTx) / 1024.0 / secs
            }
            prevNetRxBytes = nv.rx
            prevNetTxBytes = nv.tx
        }

        // 磁盘：IO 毫秒增量 / 墙钟毫秒增量
        let io = readDiskIoMs()
        if (let Some(ioMs) <- io) {
            let dIo = ioMs - prevDiskIoMs
            if (dIo >= 0) {
                lastDisk = clampPercent(Float64(dIo) / Float64(dtMs) * 100.0)
            }
            prevDiskIoMs = ioMs
        }

        baseMonoMs = nowMono
        Sample(epochMs(), lastCpu, lastMem, lastDisk, lastNetRx, lastNetTx)
    }

    // ========================================================
    // /proc/stat —— CPU 累加计数
    // ========================================================

    private func readCpuCounters(): ?CpuTimes {
        let text = readTextFile("/proc/stat")
        if (let Some(t) <- text) {
            for (line in t.split("\n")) {
                if (line.startsWith("cpu ")) {
                    let f = splitFields(line)
                    // f[0]="cpu" f[1]=user f[2]=nice f[3]=system f[4]=idle
                    // f[5]=iowait f[6]=irq f[7]=softirq f[8]=steal
                    var total: Int64 = 0
                    var i: Int64 = 1
                    while (i <= 8) {
                        total += toI64(field(f, i))
                        i += 1
                    }
                    let idle = toI64(field(f, 4)) + toI64(field(f, 5))
                    return Some(CpuTimes(total, idle))
                }
            }
        }
        None
    }

    // ========================================================
    // /proc/meminfo —— 内存使用率
    // 用 MemAvailable 而非 MemFree：更贴近「真实可用」
    // ========================================================

    private func readMemPercent(): ?Float64 {
        let text = readTextFile("/proc/meminfo")
        if (let Some(t) <- text) {
            var total: Int64 = 0
            var avail: Int64 = 0
            for (line in t.split("\n")) {
                if (line.startsWith("MemTotal:")) {
                    total = toI64(field(splitFields(line), 1))
                } else if (line.startsWith("MemAvailable:")) {
                    avail = toI64(field(splitFields(line), 1))
                }
            }
            if (total > 0) {
                return Some(Float64(total - avail) / Float64(total) * 100.0)
            }
        }
        None
    }

    // ========================================================
    // /proc/net/dev —— 网卡收发字节（排除 lo 环回）
    // 前两行是表头；数据行形如 "eth0: rx_bytes ... tx_bytes ..."
    // ========================================================

    private func readNetCounters(): ?NetBytes {
        let text = readTextFile("/proc/net/dev")
        if (let Some(t) <- text) {
            var rx: Int64 = 0
            var tx: Int64 = 0
            var lineNo: Int64 = 0
            for (line in t.split("\n")) {
                lineNo += 1
                if (lineNo <= 2) {
                    continue
                }
                let trimmed = line.trimAscii()
                if (trimmed.isEmpty()) {
                    continue
                }
                let colon = trimmed.split(":", removeEmpty: true)
                if (colon.size < 2) {
                    continue
                }
                if (field(colon, 0).trimAscii() == "lo") {
                    continue
                }
                let f = splitFields(field(colon, 1))
                // 冒号后：0=rx_bytes … 8=tx_bytes
                rx += toI64(field(f, 0))
                tx += toI64(field(f, 8))
            }
            return Some(NetBytes(rx, tx))
        }
        None
    }

    // ========================================================
    // /proc/diskstats —— IO 毫秒累计（第 13 列）
    // 排除 loop / ram 虚拟设备，避免重复计数
    // ========================================================

    private func readDiskIoMs(): ?Int64 {
        let text = readTextFile("/proc/diskstats")
        if (let Some(t) <- text) {
            var total: Int64 = 0
            for (line in t.split("\n")) {
                let f = splitFields(line)
                if (f.size < 13) {
                    continue
                }
                let devName = field(f, 2)
                if (devName.startsWith("loop") || devName.startsWith("ram")) {
                    continue
                }
                total += toI64(field(f, 12))
            }
            return Some(total)
        }
        None
    }

    // ========================================================
    // 文件读取：读失败返回 None（调用方保留上一帧值）
    // ========================================================

    private func readTextFile(path: String): ?String {
        try {
            let data = File.readFrom(Path(path))
            Some(String.fromUtf8(data))
        } catch (_: Exception) {
            None
        }
    }
}
