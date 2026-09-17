# ============================================================
# run_debug.ps1 —— CjMonitor 调试运行（Windows）
#
# 作用：把 Qt6 运行时与桥接库加入 PATH，注入 CJQT6_ROOT，
#       然后直接启动已构建的 main.exe。
# 路径全部由脚本位置推导，不写死本机绝对路径。
#
# 前置：已在 examples/CjMonitor 下执行过 cjpm build
# 用法：powershell -ExecutionPolicy Bypass -File scripts\run_debug.ps1
# ============================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ExampleRoot = Split-Path -Parent $ScriptDir
$RepoRoot = (Resolve-Path (Join-Path $ExampleRoot "..\..")).Path

$BinDir = Join-Path $ExampleRoot "target\release\bin"
$Exe = Join-Path $BinDir "main.exe"

if (-not (Test-Path $Exe)) {
    Write-Host "[!] 未找到 $Exe" -ForegroundColor Yellow
    Write-Host "    请先在 examples/CjMonitor 下执行: cjpm build" -ForegroundColor Yellow
    exit 1
}

# ---- 定位 Qt6 ----
$QtCandidates = @()
if ($env:QTDIR) { $QtCandidates += $env:QTDIR }
$QtCandidates += @(
    "C:\Qt\6.9.1\msvc2022_64",
    "C:\Qt\6.7.0\msvc2022_64"
)
$QtRoot = $null
foreach ($q in $QtCandidates) {
    if (Test-Path (Join-Path $q "bin\Qt6Core.dll")) { $QtRoot = $q; break }
}
if (-not $QtRoot) {
    Write-Host "[!] 未找到 Qt6 msvc2022_64 安装，请设置 QTDIR 或修改候选列表" -ForegroundColor Yellow
    exit 1
}
Write-Host "[*] Qt    : $QtRoot"
Write-Host "[*] 仓库根: $RepoRoot"

# ---- 运行时环境 ----
$env:PATH = (Join-Path $QtRoot "bin") + ";" +
            (Join-Path $RepoRoot "releases\windows-x64") + ";" +
            $BinDir + ";" + $env:PATH
$env:CJQT6_ROOT = $RepoRoot
$env:QT_QPA_FONTDIR = "C:\Windows\Fonts"
$env:QT_PLUGIN_PATH = Join-Path $QtRoot "plugins"

Set-Location $ExampleRoot
Write-Host "[*] 启动: $Exe`n"
& $Exe
exit $LASTEXITCODE
