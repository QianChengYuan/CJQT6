# ============================================================
# check-coverage.ps1 - CJQT6 覆盖率门禁（P0-1）
# ------------------------------------------------------------
# 读取 cjcov 生成的 coverage.json，按双口径校验阈值：
#   1. 含测试口径：全部 fileLists 的 totalLines/hitLines
#   2. 库源码口径：排除 src/test/ 后的 totalLines/hitLines
# 任一低于阈值即退出码 1（门禁失败）；coverage.json 缺失时警告并退出 0。
#
# 用法（在 CJQT6 根目录，coverage.json 已由 cjcov 生成到 cov_output\report\）：
#   pwsh -File scripts\check-coverage.ps1
#   pwsh -File scripts\check-coverage.ps1 -CoverageThreshold 60 -LibraryCoverageThreshold 42
#
# 选项：
#   -CoverageJson <路径>       coverage.json 路径（默认 cov_output\report\coverage.json）
#   -CoverageThreshold <百分比>  含测试口径门禁阈值（默认 70）
#   -LibraryCoverageThreshold <百分比>  库源码口径门禁阈值（默认 52）
# ============================================================

param(
    [string]$CoverageJson = "",
    [double]$CoverageThreshold = 70.0,
    [double]$LibraryCoverageThreshold = 52.0
)

$ErrorActionPreference = "Stop"

if (-not $CoverageJson) {
    $CoverageJson = Join-Path (Get-Location) "cov_output\report\coverage.json"
}
if (-not (Test-Path -LiteralPath $CoverageJson)) {
    Write-Host "警告: coverage.json 未生成（$CoverageJson），跳过覆盖率门禁" -ForegroundColor Yellow
    exit 0
}

$cov = Get-Content -LiteralPath $CoverageJson -Raw | ConvertFrom-Json
$total = 0; $hit = 0
$libTotal = 0; $libHit = 0
foreach ($f in $cov.fileLists) {
    $total += $f.totalLines
    $hit += $f.hitLines.Count
    # 库源码口径：排除 src/test/ 测试源码
    # 注意：cjcov --source=src 生成的路径以 src 为根，src/test/*.cj 显示为 test\*.cj
    #（无前导分隔符），core\gui_test_env.cj 属于 src/core 库源码、不应排除。
    if ($f.filepath -notmatch '(^|[\\/])test[\\/]') {
        $libTotal += $f.totalLines
        $libHit += $f.hitLines.Count
    }
}
$pct = if ($total -gt 0) { [math]::Round($hit * 100.0 / $total, 2) } else { 0 }
$libPct = if ($libTotal -gt 0) { [math]::Round($libHit * 100.0 / $libTotal, 2) } else { 0 }
Write-Host "覆盖率: $hit / $total 行 = $pct%（含测试文件）| 库源码口径 $libPct%（排除 src/test/）"

# 覆盖率门禁（P0-1 遗留闭环）：双口径 + 阈值，低于即失败
$gateFail = $false
if ($libTotal -gt 0 -and $libPct -lt $LibraryCoverageThreshold) {
    Write-Host "错误: 库源码覆盖率 $libPct% 低于门禁阈值 $LibraryCoverageThreshold%" -ForegroundColor Red
    $gateFail = $true
}
if ($pct -lt $CoverageThreshold) {
    Write-Host "错误: 含测试覆盖率 $pct% 低于门禁阈值 $CoverageThreshold%" -ForegroundColor Red
    $gateFail = $true
}
if ($gateFail) {
    Write-Host "详细报告: $((Split-Path -Parent $CoverageJson))\index.html" -ForegroundColor Yellow
    exit 1
}
Write-Host "覆盖率门禁: 含测试 $pct% >= $CoverageThreshold% 且 库源码 $libPct% >= $LibraryCoverageThreshold% ✓" -ForegroundColor Green
exit 0
