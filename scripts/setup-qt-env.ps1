#!/usr/bin/env pwsh
# ============================================================
# setup-qt-env.ps1 — CJQT6 运行环境配置脚本(Windows)
# ------------------------------------------------------------
# 设置 Qt6 环境变量(MSVC 2022)。
#
# 用法:
#   .\scripts\setup-qt-env.ps1                                                       # 自动探测 Qt6 + MSVC 2022,打印可粘贴到 PowerShell 的环境变量
#   .\scripts\setup-qt-env.ps1 -QtDir "C:\Qt\6.10.3\msvc2022_64"                     # 指定 Qt6 安装目录,跳过探测
#
# 与 setup-qt-env.sh 对称(Linux/macOS/WSL);共享函数走 scripts/lib/common.ps1
# ============================================================

[CmdletBinding()]
param(
    [string]$QtDir = ""
)

$ErrorActionPreference = "Stop"

# dot-source 共享函数库
. "$PSScriptRoot\lib\common.ps1"

# 定位项目根
$RootDir = Get-RootDir -ScriptPath $PSCommandPath
Set-Cjqt6RootEnv -RootDir $RootDir

Write-Section "配置 Qt6 运行环境 (MSVC 2022)"

# 探测 Qt6
$QtDir = Find-QtDir -QtDir $QtDir
if (-not $QtDir) {
    Write-Host "❌ 未找到Qt6安装路径" -ForegroundColor Red
    Write-Host "请通过参数指定: .\setup-qt-env.ps1 -QtDir 'C:\Qt\6.10.3\msvc2022_64'" -ForegroundColor Yellow
    Write-Host '或设置环境变量: $env:QTDIR = "C:\Qt\6.10.3\msvc2022_64"' -ForegroundColor Yellow
    exit 1
}

# 设置环境变量
$env:PATH    = "$QtDir\bin;$env:PATH"
$env:QTDIR   = $QtDir

# 测试所需:offscreen 平台字体目录(不设会导致字体相关测试失败)
$env:QT_QPA_FONTDIR = "C:\Windows\Fonts"

Write-Host "✅ Qt6 (MSVC 2022) 环境已配置" -ForegroundColor Green
Write-Host "Qt路径: $QtDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "环境变量已设置:" -ForegroundColor Yellow
Write-Host "  PATH已添加: $QtDir\bin" -ForegroundColor White
Write-Host "  CJQT6_ROOT: $env:CJQT6_ROOT" -ForegroundColor White
Write-Host "  QT_QPA_FONTDIR: $env:QT_QPA_FONTDIR" -ForegroundColor White
Write-Host ""
Write-Host '现在可以运行 Qt 应用:' -ForegroundColor Yellow
Write-Host '  cjpm run' -ForegroundColor White
Write-Host '  或直接运行 exe 文件' -ForegroundColor White

# 如果有参数,执行该命令
if ($args.Count -gt 0) {
    $command = $args -join " "
    Write-Host ('执行命令: {0}' -f $command) -ForegroundColor Yellow
    Invoke-Expression $command
}