# 用法：在 CJQT6 根目录下运行
# .\scripts\update-bridge.ps1
# 重新编译 bridge 并同步到 releases/
# 首次使用或 cmake 未配置时自动运行 cmake configure

param(
    [string]$QtDir = ""
)

$base = Split-Path $PSScriptRoot -Parent
Set-Location $base

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

$buildDir = "native\build_windows"

# ---- Step 1: cmake configure if needed ----
if (-not (Test-Path "$buildDir\CMakeCache.txt")) {
    Write-Host "[1/4] 首次使用，运行 cmake configure..." -ForegroundColor Yellow
    if (-not (Test-Path $buildDir)) {
        New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
    }
    Push-Location $buildDir
    cmake ..\.. -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="$QtDir" -DCMAKE_BUILD_TYPE=Release
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
