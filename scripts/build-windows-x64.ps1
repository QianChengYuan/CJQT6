# PowerShell script for Windows x64 build (MSVC 2022)
# 同 rebuild_all.ps1 / update-bridge.ps1 一致的 Qt 路径发现逻辑

param(
    [string]$QtDir = ""
)

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "构建 FFI Bridge - Windows x64 (MSVC 2022)" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# ---- 检测Qt6路径 ----
if ([string]::IsNullOrEmpty($QtDir)) {
    # 1. 环境变量 QTDIR
    $QtDir = $env:QTDIR
}
if ([string]::IsNullOrEmpty($QtDir)) {
    # 2. 已知路径
    $knownPaths = @(
        "C:\Qt\6.10.3\msvc2022_64",
        "C:\Qt\6.10.2\msvc2022_64",
        "C:\Qt\6.7.0\msvc2019_64",
        "C:\Qt\6.5.0\msvc2019_64"
    )
    foreach ($p in $knownPaths) {
        if (Test-Path "$p\bin\Qt6Core.dll") {
            $QtDir = $p
            break
        }
    }
}
if ([string]::IsNullOrEmpty($QtDir)) {
    # 3. 扫描 C:\Qt\6.*
    $qtBase = "C:\Qt"
    if (Test-Path $qtBase) {
        $versions = Get-ChildItem -Directory "$qtBase\6.*" | Sort-Object Name -Descending
        foreach ($v in $versions) {
            $msvcDirs = Get-ChildItem -Directory "$($v.FullName)\msvc*" -ErrorAction SilentlyContinue
            foreach ($m in $msvcDirs) {
                if (Test-Path "$($m.FullName)\bin\Qt6Core.dll") {
                    $QtDir = $m.FullName
                    break
                }
            }
            if ($QtDir) { break }
        }
    }
}

if ([string]::IsNullOrEmpty($QtDir)) {
    Write-Host "错误: 未找到Qt6安装路径" -ForegroundColor Red
    Write-Host "请设置环境变量 QTDIR 或通过 -QtDir 参数指定" -ForegroundColor Yellow
    Write-Host "示例: .\build-windows-x64.ps1 -QtDir 'C:\Qt\6.10.3\msvc2022_64'" -ForegroundColor Yellow
    exit 1
}

Write-Host "Qt6路径: $QtDir" -ForegroundColor Green

# ---- 创建构建目录 ----
$buildDir = "native\build_windows"
if (-not (Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
}

# ---- CMake 配置 ----
Write-Host "配置CMake..." -ForegroundColor Yellow
Push-Location $buildDir

# 如果已有 CMakeCache.txt 但 Qt 路径变了，重新配置
$needConfig = $true
if (Test-Path "CMakeCache.txt") {
    $cachedQt = Select-String -Path "CMakeCache.txt" -Pattern "CMAKE_PREFIX_PATH" | Select-Object -First 1
    if ($cachedQt -and $cachedQt.ToString().Contains($QtDir)) {
        $needConfig = $false
    }
}

if ($needConfig) {
    cmake ..\.. `
        -G "Visual Studio 17 2022" `
        -A x64 `
        -DCMAKE_PREFIX_PATH="$QtDir" `
        -DCMAKE_BUILD_TYPE=Release
    if ($LASTEXITCODE -ne 0) {
        Write-Host "CMake配置失败!" -ForegroundColor Red
        Pop-Location
        exit 1
    }
} else {
    Write-Host "CMake缓存有效，跳过配置" -ForegroundColor Gray
}

# ---- 构建 ----
Write-Host "开始构建..." -ForegroundColor Yellow
cmake --build . --config Release

if ($LASTEXITCODE -ne 0) {
    Write-Host "构建失败!" -ForegroundColor Red
    Pop-Location
    exit 1
}

# ---- 同步到 releases/ ----
$artifact = "bin\cjqt6_bridge.dll"
if (Test-Path $artifact) {
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "构建成功!" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "产物位置: $(Join-Path (Get-Location) $artifact)" -ForegroundColor Green

    $releaseDir = "..\..\releases\windows-x64"
    New-Item -ItemType Directory -Force -Path $releaseDir | Out-Null
    Copy-Item $artifact $releaseDir -Force
    if (Test-Path "lib\cjqt6_bridge.lib") {
        Copy-Item "lib\cjqt6_bridge.lib" $releaseDir -Force
    }
    Write-Host "已同步到: $releaseDir" -ForegroundColor Green

    # DLL 信息（仅当 dumpbin 可用时）
    $dumpbin = Get-Command dumpbin -ErrorAction SilentlyContinue
    if ($dumpbin) {
        Write-Host ""
        Write-Host "DLL信息:" -ForegroundColor Yellow
        dumpbin /headers $artifact | Select-String "machine"
        dumpbin /exports $artifact | Select-Object -First 20
    }
} else {
    Write-Host "错误: 构建产物未生成" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location
