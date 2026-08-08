# ============================================================
# verify_all.ps1 - CJQT6 一键门禁脚本（P0 工程质量）
# ------------------------------------------------------------
# 顺序（不可颠倒）：
#   1. 重编 C++ FFI 桥接库并同步 releases/（update-bridge.ps1）
#   2. cjpm build（链接新桥接库）
#   3. 部署 Qt 运行时 + offscreen 平台 + 全量测试（deploy_qt_test.ps1 -RunTest）
#   4. 冒烟示例构建（可选，默认 all_controls_demo）
#
# 用法（在 CJQT6 根目录）：
#   powershell -ExecutionPolicy Bypass -File scripts\verify_all.ps1
#   powershell -ExecutionPolicy Bypass -File scripts\verify_all.ps1 -SkipBridge -SkipExample
#   powershell -ExecutionPolicy Bypass -File scripts\verify_all.ps1 -Example notepad
#   powershell -ExecutionPolicy Bypass -File scripts\verify_all.ps1 -QtDir "C:\Qt\6.10.3\msvc2022_64"
#
# 选项：
#   -SkipBridge   跳过桥接库重编（仅在确定桥接层未改动时使用，加速验证）
#   -SkipTest     跳过测试（不推荐，仅示例验证）
#   -SkipExample  跳过示例构建
#   -Example <名> 指定冒烟示例（默认 all_controls_demo）
#   -QtDir <路径> Qt6 安装目录（透传给 update-bridge.ps1）
# ============================================================

param(
    [switch]$SkipBridge,
    [switch]$SkipTest,
    [switch]$SkipExample,
    [string]$Example = "all_controls_demo",
    [string]$QtDir = ""
)

$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $RootDir
Set-Location $RootDir
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " CJQT6 一键门禁验证（verify_all）" -ForegroundColor Cyan
Write-Host " 工作目录: $RootDir" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan

# ---- 查找 cjpm ----
$cjpm = Get-Command cjpm -ErrorAction SilentlyContinue
if (-not $cjpm) {
    foreach ($c in @("$env:USERPROFILE\.cangjie\tools\bin\cjpm.exe", "C:\CodeTools\cangjie\cangjie_1.1.0\tools\bin\cjpm.exe")) {
        if (Test-Path $c) { $cjpm = Get-Command $c; break }
    }
}
if (-not $cjpm) {
    Write-Host "错误: 未在 PATH 中找到 cjpm" -ForegroundColor Red
    exit 1
}
Write-Host "cjpm: $($cjpm.Source)" -ForegroundColor Gray

# ---- 第 1 步: 桥接库 ----
if ($SkipBridge) {
    Write-Host "[1/4] 跳过桥接库重编（-SkipBridge）" -ForegroundColor Yellow
} else {
    Write-Host "[1/4] 重编 C++ FFI 桥接库..." -ForegroundColor Cyan
    $args = @()
    if ($QtDir) { $args += "-QtDir"; $args += $QtDir }
    & "$RootDir\scripts\update-bridge.ps1" $args
    if ($LASTEXITCODE -ne 0) {
        Write-Host "错误: 桥接库构建失败" -ForegroundColor Red
        exit 1
    }
}

# ---- 第 2 步: cjpm build ----
Write-Host "[2/4] cjpm build..." -ForegroundColor Cyan
& $cjpm build
if ($LASTEXITCODE -ne 0) {
    Write-Host "错误: cjpm 构建失败" -ForegroundColor Red
    exit 1
}

# ---- 第 3 步: 部署 + 全量测试（headless offscreen） ----
if ($SkipTest) {
    Write-Host "[3/4] 跳过测试（-SkipTest）" -ForegroundColor Yellow
} else {
    Write-Host "[3/4] 部署 Qt 运行时 + 全量测试（offscreen）..." -ForegroundColor Cyan
    & powershell -ExecutionPolicy Bypass -File "$RootDir\tests\deploy_qt_test.ps1" -RunTest -SkipBuild
    if ($LASTEXITCODE -ne 0) {
        Write-Host "错误: 测试失败" -ForegroundColor Red
        exit 1
    }
}

# ---- 第 4 步: 冒烟示例 ----
if ($SkipExample) {
    Write-Host "[4/4] 跳过示例构建（-SkipExample）" -ForegroundColor Yellow
} else {
    Write-Host "[4/4] 构建冒烟示例 $Example ..." -ForegroundColor Cyan
    if (-not (Test-Path "examples\$Example")) {
        Write-Host "错误: 示例不存在 examples\$Example" -ForegroundColor Red
        exit 1
    }
    Push-Location "examples\$Example"
    & $cjpm build
    $code = $LASTEXITCODE
    Pop-Location
    if ($code -ne 0) {
        Write-Host "错误: 示例 $Example 构建失败" -ForegroundColor Red
        exit 1
    }
}

Write-Host "==============================================" -ForegroundColor Green
Write-Host " 全部通过 ✓  CJQT6 一键门禁验证完成" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
exit 0
