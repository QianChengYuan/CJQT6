package cjqt6.core

// ============================================================
// QSizePolicy 尺寸策略常量（对应 Qt QSizePolicy::Policy）
// 值与 Qt 6.10.3 头文件 qsizepolicy.h 严格一致（已核对）：
//   PolicyFlag: GrowFlag=1, ExpandFlag=2, ShrinkFlag=4, IgnoreFlag=8
//   Fixed=0, Minimum=1(GrowFlag), Maximum=4(ShrinkFlag),
//   Preferred=5, MinimumExpanding=3, Expanding=7, Ignored=13
// ============================================================

/// 尺寸策略常量类（简洁数值常量风格，与 TickPosition/FrameShape 一致）
public class SizePolicy {
    /// 固定尺寸：不能增长也不能收缩
    public static let Fixed: Int32 = 0
    /// 最小尺寸：可增长但不可收缩
    public static let Minimum: Int32 = 1
    /// 最大尺寸：可收缩但不可增长
    public static let Maximum: Int32 = 4
    /// 首选尺寸：best 大小，可增长可收缩
    public static let Preferred: Int32 = 5
    /// 最小扩展：可增长、可扩展，但不可收缩到最小以下
    public static let MinimumExpanding: Int32 = 3
    /// 扩展尺寸：优先增长，抢占多余空间
    public static let Expanding: Int32 = 7
    /// 忽略尺寸：忽略 sizeHint，可任意伸缩
    public static let Ignored: Int32 = 13
}
