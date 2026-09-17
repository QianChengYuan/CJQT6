package CjMonitor.probe

// ============================================================
// macOS 采集：常驻 sh 子进程
//
// ⚠ 状态：本实现按 POSIX 工具约定编写，但**未在 macOS 实机验证**
//   （开发机为 Windows，Linux 走 /proc 直读路径）。
//   首次在 macOS 上运行时，请先单独核对脚本输出格式：
//     CJMONITOR_TICKS=5 sh <temp>/cjmonitor_probe.sh
//   若某通道解析失败，采集器会保留上一帧值并在状态栏提示不可用。
//
// 通道来源：
//   CPU  —— ps 汇总全部进程 %cpu（除以核数归一）
//   内存 —— vm_stat 的 active + wired + compressed 页 × 页大小 / 物理内存
//   网络 —— netstat -ib 的 Ibytes/Obytes 累计值求差 → KB/s
//   磁盘 —— df -k / 的已用空间占比（与 Windows 口径一致）
// ============================================================

/// 采样脚本文件名（不含空格）
let MAC_PROBE_SCRIPT_NAME = "cjmonitor_probe.sh"

/// 采样脚本（纯 ASCII）
///
/// 每约 100ms 输出一行，空格分隔：cpu% mem% disk% rx_KBps tx_KBps
/// 设环境变量 CJMONITOR_TICKS 可限制循环次数（自动化验证用）。
let MAC_PROBE_SCRIPT = """
LIMIT="$CJMONITOR_TICKS"
[ -z "$LIMIT" ] && LIMIT=0

NCPU=$(sysctl -n hw.ncpu 2>/dev/null)
[ -z "$NCPU" ] && NCPU=1

TOTALMEM=$(sysctl -n hw.memsize 2>/dev/null)
[ -z "$TOTALMEM" ] && TOTALMEM=0

PAGESIZE=$(sysctl -n hw.pagesize 2>/dev/null)
[ -z "$PAGESIZE" ] && PAGESIZE=4096

prevrx=0
prevtx=0
first=1
tick=0

while : ; do
    sleep 0.1

    # ---- 网络累计与 CPU 汇总 ----
    net=$(netstat -ib 2>/dev/null | awk '
        $1 != "lo0" && /Link#/ { rx += $7; tx += $10 }
        END { printf "%d %d", rx + 0, tx + 0 }')
    rx=$(echo "$net" | awk '{ print $1 + 0 }')
    tx=$(echo "$net" | awk '{ print $2 + 0 }')

    cpu=$(ps -A -o %cpu= 2>/dev/null | awk -v n="$NCPU" '
        { s += $1 }
        END { v = s / n; if (v > 100) v = 100; if (v < 0) v = 0; printf "%.1f", v + 0 }')

    mem=$(vm_stat 2>/dev/null | awk -v tm="$TOTALMEM" -v ps="$PAGESIZE" '
        /Pages active/ { a = $3 }
        /Pages wired down/ { w = $4 }
        /Pages occupied by compressor/ { c = $5 }
        END {
            used = (a + w + c) * ps;
            if (tm > 0) { printf "%.1f", used / tm * 100 } else { printf "0.0" }
        }')

    disk=$(df -k / 2>/dev/null | awk '
        NR == 2 { if ($2 + 0 > 0) { printf "%.1f", ($2 - $4) / $2 * 100 } else { printf "0.0" } }')

    if [ "$first" = "1" ]; then
        prevrx=$rx
        prevtx=$tx
        first=0
    else
        rate=$(awk -v a="$rx" -v b="$prevrx" -v c="$tx" -v d="$prevtx" 'BEGIN {
            r1 = (a - b) / 1024.0 / 0.1;
            r2 = (c - d) / 1024.0 / 0.1;
            if (r1 < 0) { r1 = 0 }
            if (r2 < 0) { r2 = 0 }
            printf "%.1f %.1f", r1, r2 }')
        rxr=$(echo "$rate" | awk '{ print $1 + 0 }')
        txr=$(echo "$rate" | awk '{ print $2 + 0 }')

        prevrx=$rx
        prevtx=$tx

        echo "$cpu $mem $disk $rxr $txr"
    fi

    tick=$((tick + 1))
    if [ "$LIMIT" -gt 0 ] && [ "$tick" -ge "$LIMIT" ]; then
        break
    fi
done
"""

/// 创建 macOS 采集器
public func createMacProbe(): ProcessProbe {
    ProcessProbe("sh 采样脚本", "sh", MAC_PROBE_SCRIPT_NAME, MAC_PROBE_SCRIPT)
}
