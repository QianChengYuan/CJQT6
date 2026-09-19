# ============================================================
# clean-example-cache.ps1 — 清理示例中「由旧版本库构建」的缓存
# ------------------------------------------------------------
# 何时需要: 改过 src/(库)后构建示例时报缺符号,例如
#   ld.lld: error: undefined symbol: _CN10cjqt6.core12QtWidgetCore13setStyleSheetHRNat6StringE
#   ld.lld: error: undefined symbol: cjqt6.core:QtWidget.ti
#   这类失败与示例自身代码无关 —— 根因与判据见
#   scripts\lib\common.ps1 的 Clear-StaleExampleCache。
#
# 用法(在仓库根目录):
#   pwsh -File scripts\clean-example-cache.ps1                 # 检查并清理全部陈旧示例
#   pwsh -File scripts\clean-example-cache.ps1 -Name CjMusic   # 只处理指定示例
#   pwsh -File scripts\clean-example-cache.ps1 -Force          # 无条件清理全部示例缓存(不看时间)
#
# 注: 只删各示例的 target/(构建产物),不动源码;清理过的示例下次
#     cjpm build 会全量重建,运行前需重跑该示例的 deploy_qt.ps1 部署 Qt 运行时。
# ============================================================

[CmdletBinding()]
param(
    [string]$Name = "",     # 示例目录名;留空 = 处理 examples/ 下全部
    [switch]$Force          # 无条件清理,不比较 src/ mtime
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\lib\common.ps1"

$RootDir = Get-RootDir -ScriptPath $PSCommandPath
Set-Location $RootDir

$examplesDir = Join-Path $RootDir "examples"
if (-not (Test-Path $examplesDir)) { Write-Die "找不到示例目录 $examplesDir" }

$targets = @()
if ($Name) {
    $one = Join-Path $examplesDir $Name
    if (-not (Test-Path $one)) { Write-Die "示例不存在: examples\$Name" }
    $targets = @(Get-Item $one)
} else {
    $targets = @(Get-ChildItem $examplesDir -Directory -ErrorAction SilentlyContinue | Sort-Object Name)
}

Write-Section "清理示例中的陈旧库缓存"

$cleaned = 0
$kept = 0
foreach ($e in $targets) {
    $targetDir = Join-Path $e.FullName "target"
    if (-not (Test-Path $targetDir)) { continue }        # 未构建过,无需处理

    if ($Force) {
        Remove-Item $targetDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host ("  [清理] {0,-24} (无条件)" -f $e.Name) -ForegroundColor Yellow
        $cleaned++
    } elseif (Clear-StaleExampleCache -ExampleDir $e.FullName -RootDir $RootDir) {
        Write-Host ("  [清理] {0,-24} 缓存早于库源码" -f $e.Name) -ForegroundColor Yellow
        $cleaned++
    } else {
        Write-Host ("  [保留] {0,-24} 缓存不早于库源码" -f $e.Name) -ForegroundColor DarkGray
        $kept++
    }
}

Write-Host ""
Write-Host "清理 $cleaned 个 / 保留 $kept 个" -ForegroundColor Green
if ($cleaned -gt 0) {
    Write-Host "被清理的示例下次 cjpm build 会全量重建;运行前记得重跑该示例的 deploy_qt.ps1。" -ForegroundColor Yellow
}
exit 0
