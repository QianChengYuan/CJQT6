#!/usr/bin/env pwsh
# CJQT6 运行环境配置脚本
# 设置Qt6环境变量
# 用法: .\scripts\setup-qt-env.ps1 [-QtDir "C:\Qt\6.10.3\msvc2022_64"]

param(
    [string]$QtDir = ""
)

Write-Host "=== 配置Qt6运行环境 (MSVC 2022) ===" -ForegroundColor Green

# 自动检测 Qt6 路径
if ([string]::IsNullOrEmpty($QtDir)) {
    # 1. 环境变量 QTDIR
    $QtDir = $env:QTDIR
}
if ([string]::IsNullOrEmpty($QtDir)) {
    # 2. 常见安装路径
    $commonPaths = @(
        "C:\Qt\6.10.3\msvc2022_64",
        "C:\Qt\6.10.2\msvc2022_64",
        "C:\Qt\6.7.0\msvc2019_64",
        "C:\Qt\6.5.0\msvc2019_64"
    )
    foreach ($path in $commonPaths) {
        if (Test-Path "$path\bin\Qt6Core.dll") {
            $QtDir = $path
            break
        }
    }
}
if ([string]::IsNullOrEmpty($QtDir)) {
    # 3. 扫描 C:\Qt\6.* 目录
    $qtDirs = Get-ChildItem "C:\Qt\6.*" -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending
    foreach ($d in $qtDirs) {
        $msvcDirs = Get-ChildItem "$($d.FullName)\msvc*" -Directory -ErrorAction SilentlyContinue
        foreach ($m in $msvcDirs) {
            if (Test-Path "$($m.FullName)\bin\Qt6Core.dll") {
                $QtDir = $m.FullName
                break
            }
        }
        if ($QtDir) { break }
    }
}

# 检查Qt路径
if ([string]::IsNullOrEmpty($QtDir) -or -not (Test-Path "$QtDir\bin\Qt6Core.dll")) {
    Write-Host "❌ 未找到Qt6安装路径" -ForegroundColor Red
    Write-Host "请通过参数指定: .\setup-qt-env.ps1 -QtDir 'C:\Qt\6.10.3\msvc2022_64'" -ForegroundColor Yellow
    Write-Host "或设置环境变量: `$env:QTDIR = 'C:\Qt\6.10.3\msvc2022_64'" -ForegroundColor Yellow
    exit 1
}

# 设置环境变量
$env:PATH = "$QtDir\bin;$env:PATH"
$env:QTDIR = $QtDir

Write-Host "✅ Qt6 (MSVC 2022) 环境已配置" -ForegroundColor Green
Write-Host "Qt路径: $QtDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "环境变量已设置：" -ForegroundColor Yellow
Write-Host "PATH已添加: $QtDir\bin" -ForegroundColor White
Write-Host ""
Write-Host "现在可以运行Qt应用：" -ForegroundColor Yellow
Write-Host "  cjpm run" -ForegroundColor White
Write-Host "  或直接运行exe文件" -ForegroundColor White
Write-Host ""

# 如果有参数，执行该命令
if ($args.Count -gt 0) {
    $command = $args -join " "
    Write-Host "执行命令: $command" -ForegroundColor Yellow
    Invoke-Expression $command
}
