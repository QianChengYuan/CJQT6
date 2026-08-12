# 用法：在 CJQT6 根目录下运行
# .\scripts\build-native-tests.ps1 [-Asan]
# 编译并运行桥接层 C++ 单元测试（P0-3：存活表三件套 + 字符串工具）。
# 使用独立构建目录 native/build_native_tests，不影响 bridge 主构建。

param(
    [string]$QtDir = "",
    [switch]$Asan       # 启用 AddressSanitizer（字符串泄漏检测）
)

$ErrorActionPreference = "Stop"
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

$buildDir = "native\build_native_tests"

# ---- configure ----
Write-Host "[1/3] cmake configure ($buildDir)..."
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
Push-Location $buildDir
$asanOpt = if ($Asan) { "-DCJQT6_NATIVE_TESTS_ASAN=ON" } else { "-DCJQT6_NATIVE_TESTS_ASAN=OFF" }
cmake ..\.. -G "Visual Studio 17 2022" -A x64 `
    -DCMAKE_PREFIX_PATH="$QtDir" `
    -DCMAKE_BUILD_TYPE=Release `
    -DCJQT6_BUILD_TESTS=ON `
    $asanOpt
if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Host "❌ cmake 配置失败" -ForegroundColor Red; exit 1 }
Pop-Location

# ---- build ----
Write-Host "[2/3] 编译 bridge_core_tests..."
Push-Location $buildDir
cmake --build . --config Release --target bridge_core_tests
if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Host "❌ 编译失败" -ForegroundColor Red; exit 1 }
Pop-Location

# ---- run ----
Write-Host "[3/3] ctest 运行..."
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
exit 0
