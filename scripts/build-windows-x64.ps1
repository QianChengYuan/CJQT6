# PowerShell script for Windows x64 build (MSVC 2022)

param(
    [string]$QtDir = $env:QTDIR
)

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "构建 FFI Bridge - Windows x64 (MSVC 2022)" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# 检测Qt6路径
if ([string]::IsNullOrEmpty($QtDir)) {
    # 尝试常见路径
    $commonPaths = @(
        "C:\Qt\6.10.3\msvc2022_64",
        "C:\Qt\6.5.0\msvc2019_64"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            $QtDir = $path
            break
        }
    }
}

if ([string]::IsNullOrEmpty($QtDir)) {
    Write-Host "错误: 未找到Qt6安装路径" -ForegroundColor Red
    Write-Host "请设置环境变量 QTDIR 或通过参数指定" -ForegroundColor Yellow
    Write-Host "示例: .\build-windows-x64.ps1 -QtDir 'C:\Qt\6.10.3\msvc2022_64'" -ForegroundColor Yellow
    exit 1
}

Write-Host "Qt6路径: $QtDir" -ForegroundColor Green

# 创建构建目录
$buildDir = "native\build_windows"
if (-not (Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
}

# CMake配置
Write-Host "配置CMake..." -ForegroundColor Yellow
Push-Location $buildDir

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

# 构建
Write-Host "开始构建..." -ForegroundColor Yellow
cmake --build . --config Release

if ($LASTEXITCODE -ne 0) {
    Write-Host "构建失败!" -ForegroundColor Red
    Pop-Location
    exit 1
}

# 验证构建产物
$artifact = "bin\cjqt6_bridge.dll"
if (Test-Path $artifact) {
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "构建成功!" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "产物位置: $(Join-Path (Get-Location) $artifact)" -ForegroundColor Green
    
    # 同步到 releases/
    $releaseDir = "..\..\releases\windows-x64"
    New-Item -ItemType Directory -Force -Path $releaseDir | Out-Null
    Copy-Item $artifact $releaseDir -Force
    Copy-Item "lib\cjqt6_bridge.lib" $releaseDir -Force
    Write-Host "已同步到: $releaseDir" -ForegroundColor Green
    
    # 显示DLL信息
    Write-Host ""
    Write-Host "DLL信息:" -ForegroundColor Yellow
    dumpbin /headers $artifact | Select-String "machine"
    dumpbin /exports $artifact | Select-Object -First 20
} else {
    Write-Host "错误: 构建产物未生成" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location
