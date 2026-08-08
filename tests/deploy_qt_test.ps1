# ============================================================
# deploy_qt_test.ps1 - CJQT6 测试运行时 DLL 部署脚本
# 背景：`cjpm test`（根目录）会把 cjqt6 子包库拷到
#   target/release/cjqt6 并加入测试进程 PATH；若不把 Qt6 运行时
#   DLL / bridge DLL / MSVC CRT / 平台插件拷过去，测试 exe 无法启动。
# 用法：
#   cd C:\CodeTools\cangjie_git\CJQT6
#   powershell -ExecutionPolicy Bypass -File tests\deploy_qt_test.ps1
#   # 或带 -RunTest 走完整 部署+测试 流程：
#   powershell -ExecutionPolicy Bypass -File tests\deploy_qt_test.ps1 -RunTest
# ============================================================
param(
    [switch]$RunTest,        # 部署后运行 cjpm test
    [switch]$SkipBuild       # 跳过 cjpm build（已构建）
)

$ErrorActionPreference = "Stop"

# Step 0. 清理残留测试进程（避免 ld.lld Permission denied）
cmd /c "taskkill /F /IM cjqt6.test.exe /IM std.testrunner.exe 2>nul & exit 0"

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

# Step 1. 路径配置
$qtBin       = "C:\Qt\6.10.3\msvc2022_64\bin"
$qtPluginDir = "C:\Qt\6.10.3\msvc2022_64\plugins\platforms"
# offscreen 平台需要 qoffscreen.dll；qminimal.dll 作为兜底
$qtPlugins   = @("qwindows.dll", "qoffscreen.dll", "qminimal.dll")
$bridge      = "$projectRoot\releases\windows-x64\cjqt6_bridge.dll"
$crtDir      = "C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE"

$qtDlls  = @("Qt6Core.dll", "Qt6Gui.dll", "Qt6Widgets.dll", "Qt6Sql.dll",
             "Qt6Multimedia.dll", "Qt6MultimediaWidgets.dll")
$crtDlls = @("vcruntime140.dll", "vcruntime140_1.dll", "msvcp140.dll",
             "msvcp140_1.dll", "msvcp140_atomic_wait.dll")

# 目标目录：cjpm test 加入 PATH 的 cjqt6 目录（根布局）
$cjqt6Dir     = "$projectRoot\target\release\cjqt6"
$platformsDir = "$cjqt6Dir\platforms"

Write-Host "[check] detecting paths..." -ForegroundColor Cyan

function Test-Paths {
    $ok = $true
    foreach ($p in @($qtBin, $qtPluginDir)) {
        if (-not (Test-Path $p)) { Write-Host "  MISSING: $p" -ForegroundColor Red; $ok = $false }
    }
    foreach ($p in $qtPlugins) {
        if (-not (Test-Path (Join-Path $qtPluginDir $p))) { Write-Host "  MISSING plugin: $p" -ForegroundColor Red; $ok = $false }
    }
    if (-not (Test-Path $crtDir)) {
        $script:crtDir = "C:\Windows\System32"
        Write-Host "  CRT not found at VS, fallback to System32: $crtDir" -ForegroundColor Yellow
    }
    return $ok
}

if (-not (Test-Paths)) { Write-Host "ERROR: required paths missing. Abort." -ForegroundColor Red; exit 1 }

# Step 2. 构建
if (-not $SkipBuild) {
    Write-Host ""; Write-Host "[build] cjpm build -j 1..." -ForegroundColor Cyan
    cjpm build -j 1 2>&1 | Select-Object -Last 3
    if ($LASTEXITCODE -ne 0) { Write-Host "ERROR: build failed" -ForegroundColor Red; exit 1 }
    Write-Host "[build] OK" -ForegroundColor Green
}

# Step 3. 拷贝 DLL 到 cjqt6 目录（cjpm test 加入 PATH 的目录）
Write-Host ""; Write-Host "[deploy] copying DLLs..." -ForegroundColor Cyan

if (-not (Test-Path $cjqt6Dir)) { New-Item -ItemType Directory -Path $cjqt6Dir -Force | Out-Null }
if (-not (Test-Path $platformsDir)) { New-Item -ItemType Directory -Path $platformsDir -Force | Out-Null }

# bridge
Copy-Item $bridge $cjqt6Dir -Force
# Qt6 运行时
foreach ($d in $qtDlls) { Copy-Item "$qtBin\$d" $cjqt6Dir -Force }
# MSVC CRT
foreach ($d in $crtDlls) { Copy-Item "$crtDir\$d" $cjqt6Dir -Force -ErrorAction SilentlyContinue }
# Qt 平台插件（offscreen 需要 qoffscreen.dll，qminimal 兜底）
foreach ($p in $qtPlugins) { Copy-Item (Join-Path $qtPluginDir $p) $platformsDir -Force }

# SQL 驱动插件（QSqlDatabase 需要 qsqlite.dll，依赖 Qt6Sql.dll）
$sqlPluginDir  = "C:\Qt\6.10.3\msvc2022_64\plugins\sqldrivers"
$sqlDriversDir = "$cjqt6Dir\sqldrivers"
if (Test-Path $sqlPluginDir) {
    New-Item -ItemType Directory -Path $sqlDriversDir -Force | Out-Null
    Copy-Item (Join-Path $sqlPluginDir "qsqlite.dll") $sqlDriversDir -Force -ErrorAction SilentlyContinue
}

# 多媒体后端插件（QMediaPlayer/QSoundEffect/QCamera 需要 media 服务插件）
$mediaPluginDir  = "C:\Qt\6.10.3\msvc2022_64\plugins\multimedia"
$mediaDriversDir = "$cjqt6Dir\multimedia"
if (Test-Path $mediaPluginDir) {
    New-Item -ItemType Directory -Path $mediaDriversDir -Force | Out-Null
    foreach ($mp in @("ffmpegmediaplugin.dll", "windowsmediaplugin.dll")) {
        Copy-Item (Join-Path $mediaPluginDir $mp) $mediaDriversDir -Force -ErrorAction SilentlyContinue
    }
}

$count = (Get-ChildItem $cjqt6Dir -Filter "*.dll").Count
Write-Host "[deploy] $count DLLs + platforms + sqldrivers + multimedia -> target/release/cjqt6/" -ForegroundColor Green

# Step 4. 设置环境变量（headless 基线）
$env:QT_QPA_PLATFORM = "offscreen"
$env:QT_QPA_PLATFORM_PLUGIN_PATH = $platformsDir
$env:QT_PLUGIN_PATH = $cjqt6Dir
$env:QT_QPA_FONTDIR = "C:\Windows\Fonts"
Write-Host "[env] QT_QPA_PLATFORM = $env:QT_QPA_PLATFORM" -ForegroundColor Cyan
Write-Host "[env] QT_QPA_PLATFORM_PLUGIN_PATH = $env:QT_QPA_PLATFORM_PLUGIN_PATH" -ForegroundColor Cyan
Write-Host "[env] QT_PLUGIN_PATH = $env:QT_PLUGIN_PATH" -ForegroundColor Cyan
Write-Host "[env] QT_QPA_FONTDIR = $env:QT_QPA_FONTDIR" -ForegroundColor Cyan

# Step 5. 运行测试
if ($RunTest) {
    Write-Host ""; Write-Host "[test] cjpm test..." -ForegroundColor Cyan
    Set-Location $projectRoot
    cjpm test 2>&1
    if ($LASTEXITCODE -eq 0) { Write-Host "[test] PASS" -ForegroundColor Green } else { Write-Host "[test] FAIL" -ForegroundColor Red }
} else {
    Write-Host ""
    Write-Host "Done. Run: cjpm test" -ForegroundColor Green
}

Set-Location $projectRoot
