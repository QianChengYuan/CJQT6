#!/usr/bin/env pwsh
# CJQT6 Windows编译脚本
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$BuildDir = Join-Path $ProjectRoot "build"
$ReleaseDir = Join-Path $ProjectRoot "releases\windows-x64"

Write-Host "=== 编译Windows x64桥接库 ===" -ForegroundColor Green

# 检测Qt路径
$PossibleQtPaths = @(
    "C:\Qt\6.10.2\mingw_64",
    "C:\Qt\6.9.0\mingw_64",
    "C:\Qt\6.8.0\mingw_64",
    "$env:QTDIR"
)

$QtPath = $null
foreach ($Path in $PossibleQtPaths) {
    if ($Path -and (Test-Path $Path)) {
        $QtPath = $Path
        break
    }
}

if (-not $QtPath) {
    Write-Host "❌ 错误: 未找到Qt6" -ForegroundColor Red
    Write-Host "请设置QTDIR环境变量或修改脚本中的路径" -ForegroundColor Yellow
    exit 1
}

Write-Host "Qt路径: $QtPath" -ForegroundColor Cyan

# 检测MinGW路径
$PossibleMingwPaths = @(
    "C:\Qt\Tools\mingw1310_64\bin",
    "C:\Qt\Tools\mingw1230_64\bin",
    "C:\Qt\Tools\mingw1120_64\bin"
)

$MingwPath = $null
foreach ($Path in $PossibleMingwPaths) {
    if (Test-Path $Path) {
        $MingwPath = $Path
        break
    }
}

if (-not $MingwPath) {
    Write-Host "❌ 错误: 未找到MinGW" -ForegroundColor Red
    exit 1
}

Write-Host "MinGW路径: $MingwPath" -ForegroundColor Cyan

# 清理旧构建
if (Test-Path $BuildDir) {
    Remove-Item -Recurse -Force $BuildDir
}
New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null

# 设置环境
$env:PATH = "$QtPath\bin;$MingwPath;$env:PATH"

# 配置CMake
Write-Host "配置CMake..." -ForegroundColor Yellow
Set-Location $BuildDir
cmake .. `
    -G "MinGW Makefiles" `
    -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_PREFIX_PATH=$QtPath `
    -DCMAKE_CXX_COMPILER="$MingwPath\g++.exe"

# 编译
Write-Host "编译中..." -ForegroundColor Yellow
mingw32-make -j4

# 安装
New-Item -ItemType Directory -Force -Path $ReleaseDir | Out-Null
Copy-Item "bin\libcjqt6_bridge.dll" $ReleaseDir

Write-Host ""
Write-Host "✅ 编译完成: $ReleaseDir\libcjqt6_bridge.dll" -ForegroundColor Green
Get-Item "$ReleaseDir\libcjqt6_bridge.dll" | Format-List Length, LastWriteTime
