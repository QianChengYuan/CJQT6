# ============================================================
# gen-api-index.ps1 - CJQT6 API 参考索引生成器（P3-1）
# ------------------------------------------------------------
# 背景：cjpm doc（类级参考站）在仓颉 1.1.0 不存在（`cjpm doc` = unknown command），
# 故按清单 P3-1 兜底方案：从 docs/api/*.md 手工维护的章节提取类级小节，生成：
#   1. docs/api/INDEX.md —— 全库类级索引（可搜索、可链接，含 README.md 的模块导入注释）
#   2. 覆盖校验 —— src/ 公共类 vs 文档小节，缺文档的类告警（默认仅警告）
#
# 用法（在 CJQT6 根目录）：
#   pwsh -File scripts\gen-api-index.ps1
#   pwsh -File scripts\gen-api-index.ps1 -FailOnMissing   # 缺文档即退出码 1
#
# 选项：
#   -FailOnMissing  有 src/ 公共类未在 docs/api 中出现时退出码 1（门禁模式）
# ============================================================

param(
    [switch]$FailOnMissing
)

$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $RootDir
Set-Location $RootDir

$apiDir = Join-Path $RootDir "docs\api"
$files = Get-ChildItem -LiteralPath $apiDir -Filter "*.md" | Where-Object { $_.Name -ne "README.md" -and $_.Name -ne "INDEX.md" } | Sort-Object Name
if (-not $files) {
    Write-Host "错误: docs\api\ 下无章节文件" -ForegroundColor Red
    exit 1
}

# ---- 收集每个文件的类级小节 ----
$rows = New-Object System.Collections.ArrayList
$classNames = New-Object System.Collections.Generic.HashSet[string]
$totalClasses = 0
foreach ($f in $files) {
    $lines = Get-Content -LiteralPath $f.FullName
    $module = ""
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $l = $lines[$i]
        # 类小节：## / ### 开头；类名可能是合并标题（如 `## QJsonDocument / QJsonObject / ...`）
        if ($l -match '^#{2,3}\s+(.+)') {
            $headText = $Matches[1].Trim()
            # 去掉尾部说明（` - 说明`、`- 说明`），再按 `/` 拆分类名
            $headBody = $headText -replace '\s*[-–—].*$', ''
            $clsCandidates = $headBody -split '\s*/\s*' | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^Q[A-Za-z0-9_]+$' }
            if ($clsCandidates.Count -gt 0) {
                $desc = ""
                if ($headText -match '^Q[A-Za-z0-9_]+(?:\s*/\s*Q[A-Za-z0-9_]+)*\s*[-–—]\s*(.+)$') {
                    $desc = $Matches[1].Trim()
                }
                $first = $clsCandidates[0]
                # GitHub 风格锚点：小写、空格→'-'、去标点（中文保留）
                $anchorText = ($first + " - " + $desc).ToLower()
                $anchorText = [regex]::Replace($anchorText, '[^a-z0-9\u4e00-\u9fff\- ]', '')
                $anchorText = $anchorText -replace ' +', '-'
                foreach ($c in $clsCandidates) {
                    [void]$rows.Add([pscustomobject]@{
                        Class = $c
                        Desc = $desc
                        Module = $module
                        File = $f.Name
                        Anchor = $anchorText
                    })
                    [void]$classNames.Add($c)
                }
                $totalClasses += $clsCandidates.Count
            } else {
                # 无类名的章节标题 = 模块小节
                $module = $headText
            }
        }
    }
}

# ---- 覆盖校验：src/ 公共类 ----
$srcFiles = Get-ChildItem -LiteralPath "src" -Recurse -Filter "*.cj" -File | Where-Object { $_.FullName -notmatch '[\\/]test[\\/]' }
$missing = New-Object System.Collections.ArrayList
foreach ($sf in $srcFiles) {
    $lines = Get-Content -LiteralPath $sf.FullName
    foreach ($l in $lines) {
        if ($l -match '^\s*public\s+(?:open\s+)?class\s+(Q[A-Za-z0-9_]+)') {
            $c = $Matches[1]
            if (-not $classNames.Contains($c)) {
                [void]$missing.Add($c)
            }
        }
        # 一个文件可能多个 public class，但非全大写 Q 开头的工具类不计（如 WindowFlags 扩展枚举类）
        if ($l -match '^\s*public\s+class\s+') { }
    }
}
$missing = @($missing | Sort-Object -Unique)

# ---- 生成 INDEX.md ----
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("# CJQT6 API 类索引")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("> 本索引由 \`scripts\gen-api-index.ps1\` 自动生成（P3-1）。手工维护，重新生成即覆盖。")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("共 **$totalClasses** 个类，分布在 $($files.Count) 个章节文件。")
[void]$sb.AppendLine("")
$curFile = ""
$curModule = ""
$tick = [char]0x0060
foreach ($r in $rows) {
    if ($r.File -ne $curFile) {
        $curFile = $r.File
        $curModule = ""
        [void]$sb.AppendLine("---")
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine("## $curFile")
        [void]$sb.AppendLine("")
    }
    if ($r.Module -ne $curModule) {
        $curModule = $r.Module
        [void]$sb.AppendLine("### $curModule")
        [void]$sb.AppendLine("")
    }
    $link = "$curFile#$($r.Anchor)"
    $inlineCode = "$tick$($r.Class)$tick"
    [void]$sb.AppendLine("- **[$inlineCode]($link)**$([string]::IsNullOrEmpty($r.Desc) ? '' : " — $($r.Desc)")")
    [void]$sb.AppendLine("")
}


if ($missing.Count -gt 0) {
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("## ⚠️ src/ 中存在但 docs/api 未收录的公共类")
    [void]$sb.AppendLine("")
    foreach ($m in $missing) {
        [void]$sb.AppendLine("- `$m`（提示：请在 docs/api/ 对应章节补 `### $m - 说明` 小节）")
    }
    [void]$sb.AppendLine("")
}
$outPath = Join-Path $apiDir "INDEX.md"
[System.IO.File]::WriteAllText($outPath, $sb.ToString(), [System.Text.UTF8Encoding]::new($false))

Write-Host "已生成 $($files.Count) 个章节 / $totalClasses 个类的索引 → docs\api\INDEX.md" -ForegroundColor Green
if ($missing.Count -gt 0) {
    Write-Host "⚠️ 未收录的 src/ 公共类 ($($missing.Count) 个): $($missing -join ', ')" -ForegroundColor Yellow
    if ($FailOnMissing) {
        Write-Host "错误: 存在未文档化的公共类（-FailOnMissing 门禁）" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "覆盖校验: src/ 公共类 100% 收录 ✓" -ForegroundColor Green
}
exit 0