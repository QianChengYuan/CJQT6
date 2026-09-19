# ============================================================
# run-lint.ps1 - CJQT6 cjlint 静态检查入口
# ============================================================

<#
.SYNOPSIS
  CJQT6 项目 cjlint 静态检查入口（使用项目内 config，屏蔽与 Qt 风格冲突的规则）
.DESCRIPTION
  调用 cjlint -f src -c <项目根>，指向 config/cjlint_rule_list.json。
  屏蔽规则见 config/README.md（G.NAM.01/03/04/05、G.PKG.01、G.FUN.01、G.OPR.01）。
  不污染全局 cjlint 配置，本地与 CI 一致。
.EXAMPLE
  .\scripts\run-lint.ps1                 # 检查整个 src
  .\scripts\run-lint.ps1 -SourceDir src\widgets   # 仅检查 widgets 子包
  .\scripts\run-lint.ps1 -Summary        # 仅输出分类统计，不打印逐条告警
#>

param(
    [string]$SourceDir = "src",
    [switch]$Summary
)

# 共享函数(定位项目根等):scripts/lib/common.ps1
. "$PSScriptRoot\lib\common.ps1"

# 定位项目根目录（走 lib::Get-RootDir,替代手写 Split-Path × 2）
$projectRoot = Get-RootDir -ScriptPath $PSCommandPath

# 设置 CJQT6_ROOT（与项目其他脚本保持环境变量命名一致）
Set-Cjqt6RootEnv -RootDir $projectRoot

Write-Host ""
Write-Host "=== CJQT6 cjlint 静态检查 ===" -ForegroundColor Cyan
Write-Host "项目根: $projectRoot"
Write-Host "源码目录: $SourceDir"
Write-Host "配置:   $projectRoot\config\cjlint_rule_list.json"

# 调用 cjlint（使用项目内 config），捕获完整输出
$raw = cjlint -f $SourceDir -c $projectRoot 2>&1 | Out-String

# 提取告警行并按规则分类统计
$warningLines = $raw -split "`r?`n" | Where-Object { $_ -match "warning: (G\.[A-Z]+\.[0-9]+)" }
$total = ($warningLines | Measure-Object).Count

if ($total -eq 0) {
    Write-Host "✅ 未发现 lint 告警" -ForegroundColor Green
    exit 0
}

Write-Host "⚠️  共 $total 条 lint 告警，分类统计:" -ForegroundColor Yellow

if (-not $Summary) {
    Write-Host "----- 完整告警列表 -----" -ForegroundColor Gray
    $warningLines | ForEach-Object {
        Write-Output $_
    }
}

$warningLines | ForEach-Object {
    if ($_ -match "warning: (G\.[A-Z]+\.[0-9]+)") { $Matches[1] }
} | Group-Object | Sort-Object Count -Descending | Format-Table Count, Name -AutoSize
