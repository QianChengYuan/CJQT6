package CjMonitor.probe

// ============================================================
// Windows 采集：常驻 PowerShell 子进程
//
// 为什么不用 PerformanceCounter / WMI：
//   - 性能计数器类目/实例名在非英文系统上会被本地化，
//     构造 PerformanceCounter 可能直接失败；
//   - WMI（Get-CimInstance）单次开销 100ms+，无法支撑 100ms 采样。
// 改用 P/Invoke（GetSystemTimes / GlobalMemoryStatusEx），实测单 tick 约 2ms、
// 最大 16ms，在 100ms 预算内。
//
// 通道语义：磁盘通道在本平台取「系统盘已用空间占比」（容量水位线），
// 而非 Linux 的 IO 繁忙度——以换取对性能计数器零依赖的稳定性。
// ============================================================

/// 采样脚本文件名（不含空格，见 probe.cj 中关于参数按空格切分的说明）
let WIN_PROBE_SCRIPT_NAME = "cjmonitor_probe.ps1"

/// 采样脚本（纯 ASCII：PowerShell 5.1 会把无 BOM 的 UTF-8 当 ANSI 读，
/// 含非 ASCII 内容会被破坏）
///
/// 每 100ms 输出一行，空格分隔：cpu% mem% disk% rx_KBps tx_KBps
/// 设环境变量 CJMONITOR_TICKS 可限制循环次数（自动化验证用）。
let WIN_PROBE_SCRIPT = """
$ErrorActionPreference = 'SilentlyContinue'

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class CJMPerf {
    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern bool GetSystemTimes(out long idle, out long kernel, out long user);

    [StructLayout(LayoutKind.Sequential)]
    private struct MEMORYSTATUSEX {
        public uint dwLength;
        public uint dwMemoryLoad;
        public ulong ullTotalPhys;
        public ulong ullAvailPhys;
        public ulong ullTotalPageFile;
        public ulong ullAvailPageFile;
        public ulong ullTotalVirtual;
        public ulong ullAvailVirtual;
        public ulong ullAvailExtendedVirtual;
    }

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern bool GlobalMemoryStatusEx(ref MEMORYSTATUSEX lpBuffer);

    public static long Idle = 0;
    public static long Kernel = 0;
    public static long User = 0;

    public static bool SystemTimes() {
        return GetSystemTimes(out Idle, out Kernel, out User);
    }

    public static uint MemoryLoad() {
        MEMORYSTATUSEX m = new MEMORYSTATUSEX();
        m.dwLength = (uint)Marshal.SizeOf(typeof(MEMORYSTATUSEX));
        if (!GlobalMemoryStatusEx(ref m)) { return 0; }
        return m.dwMemoryLoad;
    }
}
"@

$nics = @([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
          Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -ne 'Loopback' })

$systemDrive = $env:SystemDrive
if (-not $systemDrive) { $systemDrive = 'C:' }

$limit = 0
if ($env:CJMONITOR_TICKS) { $limit = [int]$env:CJMONITOR_TICKS }

$prevIdle = 0L
$prevBusy = 0L
$prevRx = 0.0
$prevTx = 0.0
$prevMs = [DateTime]::UtcNow
$first = $true
$tick = 0

while ($true) {
    Start-Sleep -Milliseconds 100

    $now = [DateTime]::UtcNow
    $dt = ($now - $prevMs).TotalSeconds

    $rx = 0.0
    $tx = 0.0
    foreach ($n in $nics) {
        $s = $n.GetIPv4Statistics()
        if ($s) { $rx += $s.BytesReceived; $tx += $s.BytesSent }
    }

    [void][CJMPerf]::SystemTimes()
    $idle = [CJMPerf]::Idle
    $busy = [CJMPerf]::Kernel + [CJMPerf]::User

    if ($first) {
        $prevIdle = $idle
        $prevBusy = $busy
        $prevRx = $rx
        $prevTx = $tx
        $prevMs = $now
        $first = $false
        $tick++
        if (($limit -gt 0) -and ($tick -ge $limit)) { break }
        continue
    }

    $dIdle = $idle - $prevIdle
    $dBusy = $busy - $prevBusy
    $dTotal = $dIdle + $dBusy

    $cpu = 0.0
    if ($dTotal -gt 0) {
        $cpu = [math]::Round((1.0 - ($dIdle / $dTotal)) * 100.0, 1)
    }
    if ($cpu -lt 0) { $cpu = 0 }
    if ($cpu -gt 100) { $cpu = 100 }

    $mem = [CJMPerf]::MemoryLoad()

    $disk = 0.0
    $drive = New-Object System.IO.DriveInfo($systemDrive)
    if ($drive -and $drive.TotalSize -gt 0) {
        $disk = [math]::Round((1.0 - ($drive.AvailableFreeSpace / $drive.TotalSize)) * 100.0, 1)
    }

    if ($dt -le 0) { $dt = 0.1 }
    $rxK = [math]::Round(($rx - $prevRx) / 1024.0 / $dt, 1)
    $txK = [math]::Round(($tx - $prevTx) / 1024.0 / $dt, 1)
    if ($rxK -lt 0) { $rxK = 0 }
    if ($txK -lt 0) { $txK = 0 }

    Write-Output ("{0} {1} {2} {3} {4}" -f $cpu, $mem, $disk, $rxK, $txK)

    $prevIdle = $idle
    $prevBusy = $busy
    $prevRx = $rx
    $prevTx = $tx
    $prevMs = $now

    $tick++
    if (($limit -gt 0) -and ($tick -ge $limit)) { break }
}
"""

/// 创建 Windows 采集器
public func createWindowsProbe(): ProcessProbe {
    ProcessProbe("PowerShell 子进程", "powershell", WIN_PROBE_SCRIPT_NAME, WIN_PROBE_SCRIPT)
}
