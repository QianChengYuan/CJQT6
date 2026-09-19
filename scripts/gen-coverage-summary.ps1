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

# 共享函数(双口径覆盖率统计):scripts/lib/common.ps1
. "$PSScriptRoot\lib\common.ps1"

if (-not (Test-Path -LiteralPath $CoverageJson)) {
    Write-Host "::warning::$CoverageJson 不存在,跳过 markdown 生成"
    exit 0
}

# 双口径统计走 lib::Get-CoverageStats（与 check-coverage.ps1 共用同一实现，口径不再各写一份）
$cov = Get-CoverageStats -CoverageJson $CoverageJson
$total = $cov.Total; $hit = $cov.Hit; $pct = $cov.Pct
$libTotal = $cov.LibTotal; $libHit = $cov.LibHit; $libPct = $cov.LibPct

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