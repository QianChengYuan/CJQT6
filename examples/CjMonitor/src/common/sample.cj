package CjMonitor.common

// ============================================================
// 采样数据结构与通道定义
// ============================================================

/// 通道标识（顺序即界面展示顺序）
public class Channel {
    public static let CPU: Int32 = 0
    public static let MEM: Int32 = 1
    public static let DISK: Int32 = 2
    public static let NET: Int32 = 3
    public static let COUNT: Int32 = 4

    /// 通道显示名
    public static func name(idx: Int32): String {
        match (idx) {
            case 0 => "CPU"
            case 1 => "内存"
            case 2 => "磁盘"
            case 3 => "网络"
            case _ => "未知"
        }
    }

    /// 通道单位
    public static func unit(idx: Int32): String {
        match (idx) {
            case 3 => "KB/s"
            case _ => "%"
        }
    }

    /// 该通道的固定量程上限；<= 0 表示需要自适应缩放
    public static func fixedMax(idx: Int32): Float64 {
        match (idx) {
            case 0 => 100.0
            case 1 => 100.0
            case 2 => 100.0
            case _ => 0.0 // 网络速率自适应
        }
    }
}

/// 一次采样的结果。
/// CPU / 内存 / 磁盘为百分比（0~100），网络为收发速率（KB/s）。
public class Sample {
    public let tsMs: Int64
    public let cpu: Float64
    public let mem: Float64
    public let disk: Float64
    public let netRx: Float64
    public let netTx: Float64

    public init(tsMs: Int64, cpu: Float64, mem: Float64, disk: Float64, netRx: Float64, netTx: Float64) {
        this.tsMs = tsMs
        this.cpu = cpu
        this.mem = mem
        this.disk = disk
        this.netRx = netRx
        this.netTx = netTx
    }

    /// 取某通道的标量值（供环形缓冲与曲线绘制使用）
    public func channel(idx: Int32): Float64 {
        match (idx) {
            case 0 => cpu
            case 1 => mem
            case 2 => disk
            case 3 => netRx + netTx
            case _ => 0.0
        }
    }

    /// 全零样本（采集失败或基线帧使用）
    public static func zero(tsMs: Int64): Sample {
        Sample(tsMs, 0.0, 0.0, 0.0, 0.0, 0.0)
    }

    /// 单行摘要（控制台验收用）
    public func summary(): String {
        "ts=${tsMs} CPU=${fmt1(cpu)}% MEM=${fmt1(mem)}% DISK=${fmt1(disk)}% NET=${fmt1(netRx)}/${fmt1(netTx)}KB/s"
    }
}

/// 保留一位小数的格式化（避免引入额外依赖）
public func fmt1(v: Float64): String {
    let scaled = v * 10.0
    let rounded = if (scaled >= 0.0) {
        Int64(scaled + 0.5)
    } else {
        Int64(scaled - 0.5)
    }
    let neg = rounded < 0
    let abs = if (neg) {
        -rounded
    } else {
        rounded
    }
    let head = abs / 10
    let tail = abs % 10
    let body = "${head}.${tail}"
    if (neg) {
        "-" + body
    } else {
        body
    }
}

/// 保留两位小数的格式化
public func fmt2(v: Float64): String {
    let scaled = v * 100.0
    let rounded = if (scaled >= 0.0) {
        Int64(scaled + 0.5)
    } else {
        Int64(scaled - 0.5)
    }
    let neg = rounded < 0
    let abs = if (neg) {
        -rounded
    } else {
        rounded
    }
    let head = abs / 100
    let tail = abs % 100
    var tailStr = "${tail}"
    if (tail < 10) {
        tailStr = "0" + tailStr
    }
    let body = "${head}.${tailStr}"
    if (neg) {
        "-" + body
    } else {
        body
    }
}

/// 截断到 [0, 1]（自绘归一化用）
public func clamp01(v: Float64): Float64 {
    if (v < 0.0) {
        0.0
    } else if (v > 1.0) {
        1.0
    } else {
        v
    }
}
