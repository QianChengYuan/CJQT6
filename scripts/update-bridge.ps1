# 用法：在 CJQT6 根目录下运行
# .\scripts\update-bridge.ps1
# 重新编译 bridge 并同步到 releases/
# 首次使用或 cmake 未配置时自动运行 cmake configure

param(
    [string]$QtDir = "",
    [switch]$RunTests    # 编译并运行桥接层 C++ 单元测试（复用同一构建目录，避免二次编译）
)

$base = Split-Path $PSScriptRoot -Parent
Set-Location $base

# cjpm.toml 的 ${CJQT6_ROOT} 替换依赖此变量（替代本机绝对路径）
$env:CJQT6_ROOT = $base

# ---- 检测 Qt 路径 ----
if ([string]::IsNullOrEmpty($QtDir)) { $QtDir = $env:QTDIR }
if ([string]::IsNullOrEmpty($QtDir)) {
    $commonPaths = @(
        "C:\Qt\6.10.3\msvc2022_64",
        "C:\Qt\6.10.2\msvc2022_64",
        "C:\Qt\6.7.0\msvc2019_64"
    )
    foreach ($path in $commonPaths) {
        if (Test-Path "$path\bin\Qt6Core.dll") { $QtDir = $path; break }
    }
}
if ([string]::IsNullOrEmpty($QtDir) -or -not (Test-Path "$QtDir\bin\Qt6Core.dll")) {
    Write-Host "❌ 未找到Qt6，请指定 -QtDir 参数或设置 `$env:QTDIR" -ForegroundColor Red
    exit 1
}

$buildDir = "native\build_windows_x64"

# ---- Step 1: cmake configure if needed ----
$testOpt = if ($RunTests) { "-DCJQT6_BUILD_TESTS=ON" } else { "" }
if (-not (Test-Path "$buildDir\CMakeCache.txt")) {
    Write-Host "[1/4] 首次使用，运行 cmake configure..." -ForegroundColor Yellow
    if (-not (Test-Path $buildDir)) {
        New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
    }
    Push-Location $buildDir
    cmake ..\.. -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="$QtDir" -DCMAKE_BUILD_TYPE=Release $testOpt
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ cmake 配置失败" -ForegroundColor Red
        Pop-Location; exit 1
    }
    Pop-Location
} elseif ($RunTests) {
    # 缓存已存在，但需确保 CJQT6_BUILD_TESTS=ON（增量 configure，不触发重编）
    Write-Host "[1/4] 重新 cmake configure（启用测试目标）..." -ForegroundColor Yellow
    Push-Location $buildDir
    cmake . $testOpt
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ cmake 配置失败" -ForegroundColor Red
        Pop-Location; exit 1
    }
    Pop-Location
} else {
    Write-Host "[1/4] cmake 缓存已存在，跳过 configure" -ForegroundColor Green
}

# ---- Step 2: build ----
Write-Host "[2/4] 编译 C++ bridge (MSVC 2022)..."
Push-Location $buildDir
cmake --build . --config Release
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 编译失败" -ForegroundColor Red
    Pop-Location; exit 1
}
Pop-Location

# ---- Step 3: sync to releases ----
Write-Host "[3/4] 同步到 releases/windows-x64..."
Copy-Item $buildDir\bin\cjqt6_bridge.dll releases\windows-x64\ -Force
Copy-Item $buildDir\lib\cjqt6_bridge.lib releases\windows-x64\ -Force
Write-Host "  ✓ cjqt6_bridge.dll"
Write-Host "  ✓ cjqt6_bridge.lib (MSVC 导入库)"

Write-Host "[4/4] 完成。release 目录已更新，所有依赖项目 cjpm build 将自动使用最新 bridge (MSVC 2022)。"

# ---- 可选：运行桥接层 C++ 单元测试 ----
if ($RunTests) {
    Write-Host ""
    Write-Host "运行桥接层 C++ 单元测试（P0-3）..." -ForegroundColor Cyan
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
