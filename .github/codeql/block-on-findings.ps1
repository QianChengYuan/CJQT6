<#
.SYNOPSIS
    CodeQL 阻断门禁：本次分析存在 error/warning 级结果即失败（note 放行）。

.DESCRIPTION
    为什么需要独立门禁：codeql-action/analyze **默认不会**因告警数量失败，
    它只负责产出并上传 SARIF。因此「error/warning 阻断 PR」必须显式实现。
    两者互补——上传的 SARIF 仍会出现在 Security 页签（供处置/标记 dismissed），
    本脚本负责在 CI 上拦截。

    判定依据是**本次分析产出的 SARIF**（而非 API 查询），原因：
      - 不受 GitHub 告警索引延迟影响（刚上传立刻可判）；
      - 无需额外权限；
      - 与 Security 页签一致，都源于同一份 SARIF。

    严重度语义：CodeQL 的 problem.severity 为 error / warning / recommendation，
    GitHub 展示时 recommendation 映射为 note。查询层已用
    .github/codeql/codeql-config.yml 排除 recommendation；本脚本再按 SARIF 的
    result.level 兜底过滤一次 note，确保「note 不阻断」成立。

.PARAMETER SarifDir
    analyze 的 output 目录（递归查找 *.sarif）。

.EXAMPLE
    pwsh -NoProfile -File .github/codeql/block-on-findings.ps1 -SarifDir codeql-sarif/cpp
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SarifDir
)

$ErrorActionPreference = "Stop"

$files = @(Get-ChildItem -Path $SarifDir -Recurse -Filter *.sarif -ErrorAction SilentlyContinue)
if ($files.Count -eq 0) {
    # 没有 SARIF 说明 analyze 没产出结果 → 门禁无法判定，按失败处理（宁可红，也不静默放行）
    Write-Host "::error::未找到 CodeQL SARIF 输出（$SarifDir），无法判定阻断"
    exit 1
}

$findings = @()
$notes = 0
foreach ($f in $files) {
    $sarif = Get-Content $f.FullName -Raw | ConvertFrom-Json
    foreach ($run in $sarif.runs) {
        foreach ($res in $run.results) {
            # SARIF 未标 level 时按 warning 处理，避免漏判
            $level = if ($res.level) { $res.level } else { "warning" }
            if ($level -eq "note" -or $level -eq "none") {
                $notes += 1
                continue
            }
            $path = "(无文件)"
            $line = 1
            if ($res.locations -and $res.locations.Count -gt 0) {
                $pl = $res.locations[0].physicalLocation
                if ($pl.artifactLocation -and $pl.artifactLocation.uri) { $path = $pl.artifactLocation.uri }
                if ($pl.region -and $pl.region.startLine) { $line = $pl.region.startLine }
            }
            $msg = if ($res.message.text) { $res.message.text } else { $res.message.markdown }
            $findings += [pscustomobject]@{
                Level   = $level
                Rule    = $res.ruleId
                Message = $msg
                Path    = $path
                Line    = $line
            }
        }
    }
}

Write-Host "SARIF 文件: $($files.Count) 个；note 级（不阻断）: $notes 条；error/warning 级: $($findings.Count) 条"

if ($findings.Count -gt 0) {
    foreach ($x in $findings) {
        # ::error:: 会被 GitHub 渲染为 PR / 提交上的行内注解
        Write-Host ("::error file={0},line={1}::{2} — {3}" -f $x.Path, $x.Line, $x.Rule, $x.Message)
        Write-Host ("  [{0}] {1}  {2}  ({3}:{4})" -f $x.Level, $x.Rule, $x.Message, $x.Path, $x.Line)
    }
    Write-Host "::error::CodeQL 存在 $($findings.Count) 条 error/warning 级问题，按门禁阻断（修复问题，或调整 .github/codeql/codeql-config.yml 后重跑）"
    exit 1
}

Write-Host "✅ CodeQL 无 error/warning 级问题"
exit 0
