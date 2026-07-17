# 用法：在 CJQT6 根目录下运行
# .\scripts\update-bridge.ps1
# 重新编译 bridge 并同步到 releases/

$base = Split-Path $PSScriptRoot -Parent
Set-Location $base

Write-Host "[1/3] 编译 C++ bridge..."
Set-Location build
cmake --build . --config Release 2>&1 | Select-Object -Last 2
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 编译失败"
    exit 1
}

Set-Location $base
Write-Host "[2/3] 同步到 releases/windows-x64..."
Copy-Item build\bin\libcjqt6_bridge.dll releases\windows-x64\ -Force
Copy-Item build\lib\libcjqt6_bridge.dll.a releases\windows-x64\ -Force
Write-Host "  ✓ libcjqt6_bridge.dll"
Write-Host "  ✓ libcjqt6_bridge.dll.a"

Write-Host "[3/3] 完成。release 目录已更新，所有依赖项目 cjpm build 将自动使用最新 bridge。"
