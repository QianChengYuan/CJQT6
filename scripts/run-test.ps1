# ============================================================
# run-test.ps1 - CJQT6 Windows 一键测试脚本(完整版)
# ------------------------------------------------------------
# 用法(可在仓库根目录或任意位置调用):
#   pwsh -File scripts\run-test.ps1                                              # 完整 6 步流程(bridge + native tests + build + deploy + test + coverage)
#   pwsh -File scripts\run-test.ps1 -QtDir "C:\Qt\6.10.3\msvc2022_64"           # 指定 Qt6 路径
#   pwsh -File scripts\run-test.ps1 -SkipBridge -SkipNativeTests                # 桥接层未改动时加速
#   pwsh -File scripts\run-test.ps1 -SkipTest -SkipCoverage                     # 仅构建验证
#   pwsh -File scripts\run-test.ps1 -Asan                                       # 桥接层测试启用 AddressSanitizer
# 顺序(不可颠倒):
#   1. 探测 Qt6 并设置环境(CJQT6_ROOT / PATH / QTDIR)
#   2. 重编 C++ FFI 桥接库并同步 releases/(update-bridge.ps1)
#   3. 编译并运行桥接层 C++ 单元测试(build-native-tests.ps1)
#   4. cjpm build(链接新桥接库)
#   5. 部署 Qt 运行时 / bridge / MSVC CRT / 平台插件到
#      target/release/cjqt6,再跑 offscreen 全量测试(+--coverage)
#   6. 覆盖率报告(cjcov,可跳过)
# 关键:第 5 步必须把 releases/ 里最新的 cjqt6_bridge.dll 同步进
# target/release/cjqt6(测试进程实际加载位置),否则测试会加载过期 bridge
# ============================================================

[CmdletBinding()]
param(
    [string]$QtDir = "",
    [switch]$SkipBridge,
    [switch]$SkipNativeTests,
    [switch]$SkipTest,
    [switch]$SkipCoverage,
    [switch]$Asan
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\lib\common.ps1"

$RootDir = Get-RootDir -ScriptPath $PSCommandPath
Set-Location $RootDir
Set-Cjqt6RootEnv -RootDir $RootDir

Write-Section "CJQT6 Windows 一键测试(run-test)"

# ---- 查找 cjpm ----
$cjpm = Find-Cjpm
if (-not $cjpm) {
    Write-Host "错误: 未在 PATH 中找到 cjpm" -ForegroundColor Red
    exit 1
}
Write-Host "cjpm: $($cjpm.Source)" -ForegroundColor Gray

# ---- 第 1 步: 探测 Qt6 / 设置环境 ----
$QtDir = Find-QtDir -QtDir $QtDir
if (-not $QtDir) {
    Write-Host "错误: 未找到 Qt6,请用 -QtDir 指定(如 C:\Qt\6.10.3\msvc2022_64 或设置 `$env:QTDIR)" -ForegroundColor Red
    exit 1
}
$env:QTDIR = $QtDir
$env:PATH = "$QtDir\bin;$env:PATH"
Write-Host "[1/6] Qt6: $QtDir" -ForegroundColor Cyan

# ---- 第 2 步: 桥接库 ----
if ($SkipBridge) {
    Write-Step 2 6 "跳过桥接库重编(-SkipBridge,注意 stale-DLL 陷阱)" Skip
} else {
    Write-Step 2 6 "重编 C++ FFI 桥接库并同步 releases/(update-bridge.ps1)..."
    & "$RootDir\scripts\update-bridge.ps1" -QtDir "$QtDir"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "错误: 桥接库构建失败" -ForegroundColor Red
        exit 1
    }
}

# ---- 第 3 步: 桥接层 C++ 单元测试 ----
if ($SkipNativeTests) {
    Write-Step 3 6 "跳过桥接层 C++ 单元测试(-SkipNativeTests)" Skip
} else {
    Write-Step 3 6 "编译并运行桥接层 C++ 单元测试(build-native-tests.ps1)..."
    & "$RootDir\scripts\build-native-tests.ps1" -QtDir "$QtDir" -Asan:$Asan
    if ($LASTEXITCODE -ne 0) {
        Write-Host "错误: 桥接层测试失败" -ForegroundColor Red
        exit 1
    }
}

# ---- 第 4 步: cjpm build ----
Write-Step 4 6 "cjpm build..."
& $cjpm
if ($LASTEXITCODE -ne 0) {
    Write-Host "错误: cjpm 构建失败" -ForegroundColor Red
    exit 1
}

# ---- 第 5 步: 部署 Qt 运行时 + 全量测试 ----
if ($SkipTest) {
    Write-Step 5 6 "跳过部署+全量测试(-SkipTest)" Skip
} else {
    Write-Step 5 6 "部署 Qt 运行时 + 全量测试(offscreen,--coverage)..."
    # -SkipBuild:第 4 步已构建;该脚本负责把 releases 最新 bridge + Qt 运行时
    # 同步进 target/release/cjqt6 并设置 offscreen / 字体环境后运行 cjpm test
    & powershell -ExecutionPolicy Bypass -File "$RootDir\scripts\deploy-qt-test.ps1" -RunTest -SkipBuild -QtDir "$QtDir"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "错误: 测试失败" -ForegroundColor Red
        exit 1
    }
}

# ---- 第 6 步: 覆盖率报告 ----
if ($SkipTest -or $SkipCoverage) {
    Write-Step 6 6 "跳过覆盖率报告(-SkipTest/-SkipCoverage)" Skip
} else {
    Write-Step 6 6 "生成覆盖率报告(cjcov)..."
    $cjcov = Find-Cjcov
    if (-not $cjcov) {
        Write-Host "警告: 未在 PATH 中找到 cjcov,跳过覆盖率报告" -ForegroundColor Yellow
    } elseif (-not (Test-Path "$RootDir\cov_output")) {
        Write-Host "警告: cov_output/ 不存在——测试未生成覆盖率数据,跳过" -ForegroundColor Yellow
    } else {
        Remove-Item "$RootDir\cov_output\report" -Recurse -Force -ErrorAction SilentlyContinue
        & $cjcov.Source --root=cov_output --source=src --output=cov_output/report --html-details --json --xml 2>&1 | Select-Object -Last 3
        if ($LASTEXITCODE -ne 0) {
            Write-Host "错误: cjcov 报告生成失败" -ForegroundColor Red
            exit 1
        }
        if (Test-Path "$RootDir\cov_output\report\coverage.json") {
            $cov = Get-Content "$RootDir\cov_output\report\coverage.json" -Raw | ConvertFrom-Json
            $total = 0; $hit = 0
            foreach ($f in $cov.fileLists) {
                $total += $f.totalLines
                $hit += $f.hitLines.Count
            }
            $pct = if ($total -gt 0) { [math]::Round($hit * 100.0 / $total, 2) } else { 0 }
            Write-Host "覆盖率: $hit / $total 行 = $pct%(含测试文件,详见 cov_output\report\index.html)" -ForegroundColor Green
        } else {
            Write-Host "警告: coverage.json 未生成,报告可能不完整" -ForegroundColor Yellow
        }
    }
}

Write-Host "==============================================" -ForegroundColor Green
Write-Host " 全部通过 ✓  CJQT6 Windows 测试完成" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
exit 0