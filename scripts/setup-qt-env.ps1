#!/usr/bin/env pwsh
# CJQT6 运行环境配置脚本
# 设置Qt6环境变量

$QtPath = "C:\Qt\6.10.2\mingw_64"
$MingwPath = "C:\Qt\Tools\mingw1310_64\bin"

Write-Host "=== 配置Qt6运行环境 ===" -ForegroundColor Green

# 检查Qt路径
if (-not (Test-Path $QtPath)) {
    Write-Host "❌ Qt6路径不存在: $QtPath" -ForegroundColor Red
    Write-Host "请修改脚本中的QtPath变量为您的Qt安装路径" -ForegroundColor Yellow
    exit 1
}

# 设置环境变量
$env:PATH = "$QtPath\bin;$MingwPath;$env:PATH"
$env:QTDIR = $QtPath

Write-Host "✅ Qt6环境已配置" -ForegroundColor Green
Write-Host "Qt路径: $QtPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "环境变量已设置：" -ForegroundColor Yellow
Write-Host "PATH已添加: $QtPath\bin" -ForegroundColor White
Write-Host "PATH已添加: $MingwPath" -ForegroundColor White
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
