package CjMonitor.common

import std.time.*

// ============================================================
// 时钟
//
// 两种时间各有用途，不可混用：
//   - epochMs()  墙钟毫秒，用于样本时间戳（落库、显示、时间轴）
//   - monoMs()   单调毫秒，用于间隔测量与耗时统计（不受系统时钟调整影响）
//
// 验收指标「采样间隔误差 100ms ± 20ms」必须用单调时钟测量，
// 否则一次 NTP 校时就会污染统计结果。
// ============================================================

/// 单调时钟基准（进程启动后首次访问时钟时建立）
let gMonoBase: MonoTime = MonoTime.now()

/// 墙钟毫秒（Unix epoch）。Cangjie 的 DateTime 无直接 epoch 毫秒方法，
/// 需经 Duration 中转。
public func epochMs(): Int64 {
    DateTime.now().toUnixTimeStamp().toMilliseconds()
}

/// 单调毫秒（相对进程内基准，仅用于求差值）
public func monoMs(): Int64 {
    (MonoTime.now() - gMonoBase).toMilliseconds()
}

/// 当前时刻的可读字符串（"HH:mm:ss"）
public func wallClockHms(): String {
    let now = DateTime.now()
    let h = now.hour
    let m = now.minute
    let s = now.second
    "${pad2(h)}:${pad2(m)}:${pad2(s)}"
}

/// 两位补零
public func pad2(v: Int64): String {
    if (v < 10) {
        "0${v}"
    } else {
        "${v}"
    }
}
