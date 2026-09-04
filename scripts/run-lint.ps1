







    .\scripts\run-lint.ps1                 # 检查整个 src
    .\scripts\run-lint.ps1 -SourceDir src\widgets   # 仅检查 widgets 子包
    .\scripts\run-lint.ps1 -Summary        # 仅输出分类统计，不打印逐条告警
    [string]$SourceDir = "src",
    [switch]$Summary
    不污染全局 cjlint 配置，本地与 CI 一致。
    调用 cjlint -f src -c <项目根>，指向 config/cjlint_rule_list.json。
    屏蔽规则见 config/README.md（G.NAM.01/03/04/05、G.PKG.01、G.FUN.01、G.OPR.01）。
    CJQT6 项目 cjlint 静态检查入口（使用项目内 config，屏蔽与 Qt 风格冲突的规则）
    exit 0
    if ($_ -match "warning: (G\.[A-Z]+\.[0-9]+)") { $Matches[1] }
    Write-Host "----- 完整告警列表 -----" -ForegroundColor Gray
    Write-Host "✅ 未发现 lint 告警" -ForegroundColor Green
    Write-Output $raw
.DESCRIPTION
.EXAMPLE
.SYNOPSIS
)
}
}
} | Group-Object | Sort-Object Count -Descending | Format-Table Count, Name -AutoSize
# 调用 cjlint（使用项目内 config），捕获完整输出
# 定位项目根目录（脚本所在目录的父目录）
# 设置 CJQT6_ROOT（与项目其他脚本保持环境变量命名一致）
# 提取告警行并按规则分类统计
#>
<#
$env:CJQT6_ROOT = $projectRoot
$projectRoot = Split-Path -Parent $scriptDir
$raw = cjlint -f $SourceDir -c $projectRoot 2>&1 | Out-String
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$total = ($warningLines | Measure-Object).Count
$warningLines = $raw -split "`r?`n" | Where-Object { $_ -match "warning: (G\.[A-Z]+\.[0-9]+)" }
$warningLines | ForEach-Object {
if (-not $Summary) {
if ($total -eq 0) {
param(
Write-Host ""
Write-Host "=== CJQT6 cjlint 静态检查 ===" -ForegroundColor Cyan
Write-Host "⚠️  共 $total 条 lint 告警，分类统计:" -ForegroundColor Yellow
Write-Host "配置:   $projectRoot\config\cjlint_rule_list.json"
Write-Host "项目根: $projectRoot"
Write-Host "源码目录: $SourceDir"