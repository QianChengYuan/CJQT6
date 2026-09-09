# ============================================================
# build-native-tests.ps1 - 编译并运行桥接层 C++ 单元测试
# ------------------------------------------------------------
# 用法:
#   pwsh -File .\scripts\build-native-tests.ps1                              # 默认编译并跑测试
#   pwsh -File .\scripts\build-native-tests.ps1 -Asan                        # 启用 AddressSanitizer
#   pwsh -File .\scripts\build-native-tests.ps1 -QtDir "C:\Qt\6.10.3\msvc2022_64"   # 指定 Qt6 路径
# 使用独立构建目录 native\build_native_tests,不影响 bridge 主构建
# ============================================================

[CmdletBinding()]
param(
    [string]$QtDir = "",
    [switch]$Asan       # 启用 AddressSanitizer(字符串泄漏检测)
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\lib\common.ps1"

$RootDir = Get-RootDir -ScriptPath $PSCommandPath
Set-Location $RootDir

# ---- 探测 Qt6 ----
$QtDir = Find-QtDir -QtDir $QtDir
if (-not $QtDir) {
    Write-Host "❌ 未找到Qt6,请指定 -QtDir 参数或设置 `$env:QTDIR" -ForegroundColor Red
    exit 1
}

$buildDir = "native\build_native_tests"

# ---- configure ----
Write-Host "[1/3] cmake configure ($buildDir)..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
Push-Location $buildDir
$asanOpt = if ($Asan) { "-DCJQT6_NATIVE_TESTS_ASAN=ON" } else { "-DCJQT6_NATIVE_TESTS_ASAN=OFF" }
cmake ..\.. -G "Visual Studio 17 2022" -A x64 `
    -DCMAKE_PREFIX_PATH="$QtDir" `
    -DCMAKE_BUILD_TYPE=Release `
    -DCJQT6_BUILD_TESTS=ON `
    $asanOpt
if ($LASTEXITCODE -ne 0) {
    Pop-Location
    Write-Host "❌ cmake 配置失败" -ForegroundColor Red
    exit 1
}
Pop-Location

# ---- build ----
Write-Host "[2/3] 编译 bridge_core_tests..." -ForegroundColor Cyan
Push-Location $buildDir
cmake --build . --config Release --target bridge_core_tests
if ($LASTEXITCODE -ne 0) {
    Pop-Location
    Write-Host "❌ 编译失败" -ForegroundColor Red
    exit 1
}
Pop-Location

# ---- run ----
Write-Host "[3/3] ctest 运行..." -ForegroundColor Cyan
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