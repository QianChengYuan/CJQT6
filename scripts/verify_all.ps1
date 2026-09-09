# ============================================================
# verify_all.ps1 - CJQT6 一键门禁脚本(P0 工程质量)
# ------------------------------------------------------------
# 顺序(不可颠倒):
#   1. 重编 C++ FFI 桥接库并同步 releases/(update-bridge.ps1)
#   2. cjpm build(链接新桥接库)
#   3. 部署 Qt 运行时 + offscreen 平台 + 全量测试(deploy-qt-test.ps1 -RunTest)
#   4. 覆盖率报告(cjcov,默认开启,-SkipCoverage 可跳过)
#   5. 冒烟示例构建(可选,默认 all_controls_demo)
#
# 用法(在 CJQT6 根目录):
#   powershell -ExecutionPolicy Bypass -File scripts\verify_all.ps1                                        # 全量:bridge + build + test + coverage + 示例
#   powershell -ExecutionPolicy Bypass -File scripts\verify_all.ps1 -SkipBridge -SkipExample               # 跳过桥接库重编和示例,加速本地验证
#   powershell -ExecutionPolicy Bypass -File scripts\verify_all.ps1 -Example notepad                       # 指定冒烟示例名(默认 all_controls_demo)
#   powershell -ExecutionPolicy Bypass -File scripts\verify_all.ps1 -QtDir "C:\Qt\6.10.3\msvc2022_64"     # 指定 Qt6 路径,跳过探测
#   powershell -ExecutionPolicy Bypass -File scripts\verify_all.ps1 -SkipCoverage                         # 跳过覆盖率门禁(仅验证构建+测试)
#   powershell -ExecutionPolicy Bypass -File scripts\verify_all.ps1 -CoverageThreshold 75                  # 自定义含测试覆盖率阈值(默认 70)
#   powershell -ExecutionPolicy Bypass -File scripts\verify_all.ps1 -TestTimeoutSec 600                     # 测试整体硬超时 600s(默认 900s),超时强杀并报错
# ============================================================

[CmdletBinding()]
param(
    [switch]$SkipBridge,
    [switch]$SkipTest,
    [switch]$SkipCoverage,
    [switch]$SkipExample,
    [string]$Example = "all_controls_demo",
    [string]$QtDir = "",
    [double]$CoverageThreshold = 70.0,
    [double]$LibraryCoverageThreshold = 52.0,
    [int]$TestTimeoutSec = 1800       # 测试整体硬超时(秒),兜底并行 cjc 挂死;机器慢可加大
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\lib\common.ps1"

$RootDir = Get-RootDir -ScriptPath $PSCommandPath
Set-Location $RootDir
Set-Cjqt6RootEnv -RootDir $RootDir

Write-Section "CJQT6 一键门禁验证(verify_all)"

# ---- 查找 cjpm ----
$cjpm = Find-Cjpm
if (-not $cjpm) {
    Write-Host "错误: 未在 PATH 中找到 cjpm" -ForegroundColor Red
    exit 1
}
Write-Host "cjpm: $($cjpm.Source)" -ForegroundColor Gray

# ---- 第 1 步: 桥接库 ----
if ($SkipBridge) {
    Write-Step 1 5 "跳过桥接库重编(-SkipBridge)" Skip
} else {
    Write-Step 1 5 "重编 C++ FFI 桥接库..."
    $args = @()
    if ($QtDir) { $args += "-QtDir"; $args += $QtDir }
    & "$RootDir\scripts\update-bridge.ps1" @args
    if ($LASTEXITCODE -ne 0) {
        Write-Host "错误: 桥接库构建失败" -ForegroundColor Red
        exit 1
    }
}

# ---- 第 2 步: cjpm build ----
Write-Step 2 5 "cjpm build..."
& $cjpm build
if ($LASTEXITCODE -ne 0) {
    Write-Host "错误: cjpm 构建失败" -ForegroundColor Red
    exit 1
}

# ---- 第 3 步: 部署 + 全量测试(headless offscreen,带覆盖率插桩)----
if ($SkipTest) {
    Write-Step 3 5 "跳过测试(-SkipTest)" Skip
} else {
    Write-Step 3 5 "部署 Qt 运行时 + 全量测试(offscreen,--coverage,上限 ${TestTimeoutSec}s)..."
    & pwsh -ExecutionPolicy Bypass -File "$RootDir\scripts\deploy-qt-test.ps1" -RunTest -SkipBuild -TestTimeoutSec $TestTimeoutSec
    if ($LASTEXITCODE -ne 0) {
        Write-Host "错误: 测试失败" -ForegroundColor Red
        exit 1
    }
}

# ---- 第 4 步: 覆盖率报告(cjcov)----
if ($SkipTest -or $SkipCoverage) {
    Write-Step 4 5 "跳过覆盖率报告(-SkipTest/-SkipCoverage)" Skip
} else {
    Write-Step 4 5 "生成覆盖率报告(cjcov)..."
    $cjcov = Find-Cjcov
    if (-not $cjcov) {
        Write-Host "错误: 未在 PATH 中找到 cjcov,跳过覆盖率报告" -ForegroundColor Yellow
    } else {
        if (-not (Test-Path "cov_output")) {
            Write-Host "警告: cov_output/ 不存在——测试未生成覆盖率数据,跳过" -ForegroundColor Yellow
        } else {
            Remove-Item "cov_output\report" -Recurse -Force -ErrorAction SilentlyContinue
            & $cjcov.Source --root=cov_output --source=src --output=cov_output/report --html-details --json --xml 2>&1 | Select-Object -Last 3
            if ($LASTEXITCODE -ne 0) {
                Write-Host "错误: cjcov 报告生成失败" -ForegroundColor Red
                exit 1
            }
            # 覆盖率门禁(P0-1 遗留闭环):双口径 + 阈值,低于即失败(委托 check-coverage.ps1)
            & "$RootDir\scripts\check-coverage.ps1" -CoverageThreshold $CoverageThreshold -LibraryCoverageThreshold $LibraryCoverageThreshold
            if ($LASTEXITCODE -ne 0) {
                Write-Host "详细报告: cov_output\report\index.html" -ForegroundColor Yellow
                exit 1
            }
        }
    }
}

# ---- 第 5 步: 冒烟示例 ----
if ($SkipExample) {
    Write-Step 5 5 "跳过示例构建(-SkipExample)" Skip
} else {
    Write-Step 5 5 "构建冒烟示例 $Example ..." -ForegroundColor Cyan
    if (-not (Test-Path "examples\$Example")) {
        Write-Host "错误: 示例不存在 examples\$Example" -ForegroundColor Red
        exit 1
    }
    Push-Location "examples\$Example"
    & $cjpm build
    $code = $LASTEXITCODE
    Pop-Location
    if ($code -ne 0) {
        Write-Host "错误: 示例 $Example 构建失败" -ForegroundColor Red
        exit $code
    }
}

Write-Host "==============================================" -ForegroundColor Green
Write-Host " 全部通过 ✓  CJQT6 一键门禁验证完成" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
exit 0