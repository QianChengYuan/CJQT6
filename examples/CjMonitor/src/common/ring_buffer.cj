package CjMonitor.common

// ============================================================
// 环形缓冲区 —— 滑动窗口的通用底座
//
// 设计目标：固定容量、预分配、运行时零分配。
// 100ms × 4 通道 × 600 点（1 分钟窗口），若每帧重建数组，
// 一分钟会产生 2400 次分配，GC 抖动会让曲线肉眼可见地卡顿。
// ============================================================

public class RingBuffer {
    private let cap: Int64
    private var buf: Array<Float64>
    private var head: Int64 = 0   // 下一个写入位置
    private var count: Int64 = 0  // 已填充数量

    public init(cap: Int64) {
        let c = if (cap < 2) { 2 } else { cap }
        this.cap = c
        this.buf = Array<Float64>(c, repeat: 0.0)
    }

    /// 追加一个采样值（O(1)，无分配）
    public func push(v: Float64): Unit {
        buf[head] = v
        head = (head + 1) % cap
        if (count < cap) {
            count += 1
        }
    }

    /// 按时间顺序取第 i 个（0 = 最老，size()-1 = 最新）
    ///
    /// 关键：起点必须区分「未填满」与「已绕圈」两种状态，
    /// 否则未填满时首尾会错位。
    public func at(i: Int64): Float64 {
        if (i < 0 || i >= count) {
            return 0.0
        }
        let start = if (count < cap) { 0 } else { head }
        buf[(start + i) % cap]
    }

    /// 最新值（无数据时返回 def）
    public func last(def: Float64): Float64 {
        if (count == 0) {
            return def
        }
        buf[(head - 1 + cap) % cap]
    }

    /// 窗口内最大值（用于网络等量纲不定的通道做自适应缩放）
    public func maxValue(): Float64 {
        if (count == 0) {
            return 0.0
        }
        let start = if (count < cap) { 0 } else { head }
        var m = buf[start]
        var i: Int64 = 1
        while (i < count) {
            let v = buf[(start + i) % cap]
            if (v > m) {
                m = v
            }
            i += 1
        }
        m
    }

    /// 窗口内最小值
    public func minValue(): Float64 {
        if (count == 0) {
            return 0.0
        }
        let start = if (count < cap) { 0 } else { head }
        var m = buf[start]
        var i: Int64 = 1
        while (i < count) {
            let v = buf[(start + i) % cap]
            if (v < m) {
                m = v
            }
            i += 1
        }
        m
    }

    /// 已填充数量（≤ 容量）
    public func size(): Int64 {
        count
    }

    /// 容量
    public func capacity(): Int64 {
        cap
    }

    /// 清空（保留已分配内存，不触发分配）
    public func clear(): Unit {
        head = 0
        count = 0
    }
}
