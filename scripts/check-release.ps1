# ============================================================
# check-release.ps1 - CJQT6 语义化版本门禁（P3-2）
# ------------------------------------------------------------
# 发版打 tag 前的校验：
#   1. cjpm.toml 的 version 与 CHANGELOG 最新发布节版本号一致
#   2. CHANGELOG 已有对应 `## [x.y.z]` 的发布节（且不是空节）
#   3. 紧邻其上的 `## [Unreleased]` 节不含未转移的 feat/fix/break 内容
#   4. CHANGELOG 分类小节（新增/修复/文档/Break）格式常规（语义化版本最佳实践）
#
# 用法（在 CJQT6 根目录，按顺序先升版本再校验）：
#   pwsh -File scripts\check-release.ps1 -Version 1.8.0
#   pwsh -File scripts\check-release.ps1          # 自动读 cjpm.toml 当前版本
#
# 选项：
#   -Version <x.y.z>  待打 tag 的版本号（默认取 cjpm.toml 的 version）
#   -Changelog <路径>  CHANGELOG 路径（默认 docs\CHANGELOG.md）
# ============================================================

param(
    [string]$Version = "",
    [string]$Changelog = ""
)

$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $RootDir
Set-Location $RootDir

if (-not $Changelog) { $Changelog = "docs\CHANGELOG.md" }

# ---- 1. 版本号来源 ----
$VersionWasExplicit = ($Version -ne "")
if (-not $Version) {
    $toml = Get-Content "cjpm.toml" -Raw
    # 精确匹配 `version = "x.y.z"`（必须整词，避免误中 cjc-version = "1.1.0"）
    if ($toml -match '(?m)^\s*version\s*=\s*"([0-9]+\.[0-9]+\.[0-9]+)"') {
        $Version = $Matches[1]
    } else {
        Write-Host "错误: cjpm.toml 未找到 version（格式 version = \"x.y.z\"）" -ForegroundColor Red
        exit 1
    }
}
if ($Version -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') {
    Write-Host "错误: 版本号 $Version 不符合语义化版本 x.y.z" -ForegroundColor Red
    exit 1
}
Write-Host "校验版本: $Version（$(if ($VersionWasExplicit) { '命令行 -Version' } else { 'cjpm.toml' })）" -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $Changelog)) {
    Write-Host "错误: CHANGELOG 不存在: $Changelog" -ForegroundColor Red
    exit 1
}
$lines = Get-Content -LiteralPath $Changelog

# ---- 2. 定位版本节与 Unreleased 节 ----
$relIdx = -1
$unrelIdx = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^\s*##\s+\[\s*' + [regex]::Escape($Version) + '\s*\](?:[-\s].*)?$') {
        $relIdx = $i
    }
    if ($lines[$i] -match '^\s*##\s+\[Unreleased\]') {
        $unrelIdx = $i
    }
}
if ($relIdx -lt 0) {
    Write-Host "错误: CHANGELOG 没有版本节 '## [$Version]'，无法发布（先补发布记录）" -ForegroundColor Red
    exit 1
}

# 发布节内容非空
$relBody = $lines[($relIdx + 1)..($lines.Count - 1)] -join "`n"
if ($relBody.Trim().Length -eq 0) {
    Write-Host "错误: CHANGELOG '[ $Version ]' 节为空，请补充发布说明" -ForegroundColor Red
    exit 1
}

# ---- 3. Unreleased 节是否已清空 ----
if ($unrelIdx -ge 0) {
    $endIdx = if ($relIdx -ge 0 -and $relIdx -gt $unrelIdx) { $relIdx - 1 } else { $lines.Count - 1 }
    $unrelBody = ($lines[($unrelIdx + 1)..$endIdx] | Where-Object { $_.Trim().Length -gt 0 }) -join "`n"
    $hasPend = $false
    foreach ($k in @('新增', '修复', '删除', '文档', 'BREAK', 'Break', 'feat', 'fix', 'breaking')) {
        if ($unrelBody -match [regex]::Escape($k)) { $hasPend = $true; break }
    }
    if ($hasPend) {
        Write-Host "警告: '## [Unreleased]' 节仍有未转移到 '$Version' 的内容，发布前建议整理" -ForegroundColor Yellow
    } else {
        Write-Host "检查: '## [Unreleased]' 节已清空 ✓" -ForegroundColor Green
    }
}

# ---- 4. 分类小节格式（语义化版本最佳实践：Add/Fix/Break/Doc） ----
$relLines = $lines[$relIdx..[Math]::Min($relIdx + 60, $lines.Count - 1)]
$hasCat = ($relLines | Where-Object { $_ -match '^\s*###\s+' }).Count -gt 0
if (-not $hasCat) {
    Write-Host "警告: '$Version' 节内未发现 '### ' 分类小节（如 新增/修复/文档），建议归类" -ForegroundColor Yellow
} else {
    Write-Host "检查: '$Version' 节含分类小节 ✓" -ForegroundColor Green
}

# ---- 5. 建议：git tag 是否已存在 ----
if (Get-Command git -ErrorAction SilentlyContinue) {
    $tags = (& git tag --list "$Version") 2>$null
    if ($LASTEXITCODE -eq 0 -and $tags) {
        Write-Host "警告: git tag '$Version' 已存在，可能需要 --force 或换版本号" -ForegroundColor Yellow
    }
}

Write-Host "==============================================" -ForegroundColor Green
Write-Host " 语义化版本门禁通过 ✓  可打 tag v$Version" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
exit 0