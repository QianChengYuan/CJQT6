# ============================================================
# update-bridge.ps1 - 重新编译 bridge 并同步到 releases/windows-x64/
# ------------------------------------------------------------
# 用法:
#   pwsh -File .\scripts\update-bridge.ps1                            # 默认重建 bridge
#   pwsh -File .\scripts\update-bridge.ps1 -QtDir "C:\Qt\6.10.3\msvc2022_64"   # 指定 Qt6 路径
#   pwsh -File .\scripts\update-bridge.ps1 -RunTests                   # 编 + 跑桥接层 C++ 单元测试
#   pwsh -File .\scripts\update-bridge.ps1 -RunTests -Asan             # 启用 AddressSanitizer
# 首次使用或 cmake 未配置时自动运行 cmake configure
# 共享函数(探测 Qt / 打印步骤):scripts/lib/common.ps1
# ============================================================

[CmdletBinding()]
param(
    [string]$QtDir = "",
    [switch]$RunTests,   # 编译并运行桥接层 C++ 单元测试(复用同一构建目录,避免二次编译)
    [switch]$Asan        # 桥接层测试启用 AddressSanitizer(依赖 VC 运行时 cl.exe /fsanitize=address)
)

$ErrorActionPreference = "Stop"

# dot-source 共享函数库
. "$PSScriptRoot\lib\common.ps1"

$RootDir = Get-RootDir -ScriptPath $PSCommandPath
Set-Cjqt6RootEnv -RootDir $RootDir
Set-Location $RootDir

# ---- 探测 Qt6 ----
$QtDir = Find-QtDir -QtDir $QtDir
if (-not $QtDir) {
    Write-Host "❌ 未找到Qt6,请用 -QtDir 指定(如 C:\Qt\6.10.3\msvc2022_64 或设置 `$env:QTDIR)" -ForegroundColor Red
    exit 1
}
$env:QTDIR = $QtDir
$env:PATH = "$QtDir\bin;$env:PATH"

Write-Section "update-bridge"
Write-Host "Qt6:  $QtDir"
Write-Host "Root: $RootDir"

$buildDir = "native\build_windows_x64"

# ---- Step 1: cmake configure if needed ----
$testOpt = if ($RunTests) { "-DCJQT6_BUILD_TESTS=ON" } else { "" }
$asanOpt = if ($Asan)     { "-DCJQT6_NATIVE_TESTS_ASAN=ON" } else { "" }
if (-not (Test-Path "$buildDir\CMakeCache.txt")) {
    Write-Host "[1/4] 首次使用,运行 cmake configure..." -ForegroundColor Yellow
    if (-not (Test-Path $buildDir)) {
        New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
    }
    Push-Location $buildDir
    cmake ..\.. -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="$QtDir" -DCMAKE_BUILD_TYPE=Release $testOpt $asanOpt
    if ($LASTEXITCODE -ne 0) {
        Pop-Location
        Write-Host "❌ cmake 配置失败" -ForegroundColor Red
        exit 1
    }
    Pop-Location
} elseif ($RunTests -or $Asan) {
    # 缓存已存在,但需确保测试目标 / ASAN 已启用(增量 configure,不触发重编)
    Write-Host "[1/4] 重新 cmake configure(启用测试/ASAN)..." -ForegroundColor Yellow
    Push-Location $buildDir
    cmake . $testOpt $asanOpt
    if ($LASTEXITCODE -ne 0) {
        Pop-Location
        Write-Host "❌ cmake 配置失败" -ForegroundColor Red
        exit 1
    }
    Pop-Location
} else {
    Write-Host "[1/4] cmake 缓存已存在,跳过 configure" -ForegroundColor Green
}

# ---- Step 2: build ----
Write-Host "[2/4] 编译 C++ bridge (MSVC 2022)..." -ForegroundColor Cyan
Push-Location $buildDir
cmake --build . --config Release
if ($LASTEXITCODE -ne 0) {
    Pop-Location
    Write-Host "❌ 编译失败" -ForegroundColor Red
    exit 1
}
Pop-Location

# ---- Step 3: sync to releases ----
Write-Host "[3/4] 同步到 releases\windows-x64..." -ForegroundColor Cyan
Copy-Item "$buildDir\bin\cjqt6_bridge.dll" "releases\windows-x64\" -Force
Copy-Item "$buildDir\lib\cjqt6_bridge.lib" "releases\windows-x64\" -Force
Write-Host "  ✓ cjqt6_bridge.dll"
Write-Host "  ✓ cjqt6_bridge.lib (MSVC 导入库)"

Write-Host "[4/4] 完成。release 目录已更新,所有依赖项目 cjpm build 将自动使用最新 bridge (MSVC 2022)。"

# ---- 可选:运行桥接层 C++ 单元测试 ----
if ($RunTests) {
    Write-Host ""
    Write-Host "运行桥接层 C++ 单元测试(P0-3)..." -ForegroundColor Cyan
    $env:PATH = "$QtDir\bin;$env:PATH"
    Push-Location $buildDir
    ctest --output-on-failure -C Release -R bridge_core_tests
    $code = $LASTEXITCODE
    Pop-Location
    if ($code -ne 0) {
        Write-Host "❌ 桥接层测试失败" -ForegroundColor Red
        exit $code
    }
    Write-Host "✅ 桥接层 C++ 单元测试全部通过" -ForegroundColor Green
}