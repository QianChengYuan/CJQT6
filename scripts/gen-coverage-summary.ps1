# 用法(在 CJQT6 根目录下运行,由 GitHub Actions 调用):
#   pwsh -File scripts\gen-coverage-summary.ps1                                    # 读 cov_output\report\coverage.json,生成 PR 评论用的 pr_summary.md
# 读取 cov_output\report\coverage.json,生成 PR 评论用的 markdown:
#   cov_output\report\pr_summary.md
# 双口径(与 check-coverage.ps1 一致):
#   - 含测试口径:全部 fileLists
#   - 库源码口径:排除 src/test/ 测试源码

param(
    [string]$CoverageJson = "cov_output\report\coverage.json",
    [string]$OutputPath   = "cov_output\report\pr_summary.md"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $CoverageJson)) {
    Write-Host "::warning::$CoverageJson 不存在,跳过 markdown 生成"
    exit 0
}

$cov = Get-Content -LiteralPath $CoverageJson -Raw | ConvertFrom-Json
$total = 0; $hit = 0
$libTotal = 0; $libHit = 0
foreach ($f in $cov.fileLists) {
    $total += $f.totalLines
    $hit += $f.hitLines.Count
    if ($f.filepath -notmatch '(^|[\\/])test[\\/]') {
        $libTotal += $f.totalLines
        $libHit += $f.hitLines.Count
    }
}
$pct = if ($total -gt 0) { [math]::Round($hit * 100.0 / $total, 2) } else { 0 }
$libPct = if ($libTotal -gt 0) { [math]::Round($libHit * 100.0 / $libTotal, 2) } else { 0 }

# emoji 状态指示
$badge = if ($libPct -ge 52) { "🟢" } elseif ($libPct -ge 40) { "🟡" } else { "🔴" }

$md = @"
## 📊 覆盖率报告(Windows · offscreen · cjcov)

| 维度 | 命中率 | 命中行 / 总行 | 阈值 |
|---|---:|---|---|
| 含测试口径 | **$pct%** | $hit / $total | ≥ 70% |
| 库源码口径 | **$libPct%** $badge | $libHit / $libTotal | ≥ 52% |

完整 HTML 报告:见 Artifacts → coverage-windows
"@

Set-Content -LiteralPath $OutputPath -Value $md -Encoding utf8
Write-Host "==> 生成 PR 评论 markdown: $OutputPath"
Write-Host $md