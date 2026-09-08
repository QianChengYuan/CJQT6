# 用法：在 CJQT6 根目录下运行
# .\scripts\sync-release-artifacts.ps1
#   从 GitHub CI（QianChengYuan/CJQT6）下载四平台编译的 cjqt6_bridge 桥接库，
#   归位到 releases/<platform>/ 对应位置，使入库的预编译库与最新代码同步。
#   默认取最近一次成功的 main CI run；也可用 -RunId 指定。
#
# .\scripts\sync-release-artifacts.ps1 -RunId 34261986569
#
# 时机：GitHub CI 四平台全绿后、推送 GitCode 主仓之前运行。
# 下载归位后请人工核对，再：git add releases/ && git commit && git push origin

param(
    [string]$RunId = ""
)

$ErrorActionPreference = "Stop"
$repo = "QianChengYuan/CJQT6"
$base = Split-Path $PSScriptRoot -Parent
Set-Location $base

# CI artifact 名 -> releases 目标相对路径（与 .github/workflows/ci.yml 的 upload-artifact 对应）
$map = [ordered]@{
    "cjqt6-bridge-windows-x64" = "releases/windows-x64/cjqt6_bridge.dll"
    "cjqt6-bridge-linux-x64"   = "releases/linux-x64/libcjqt6_bridge.so"
    "cjqt6-bridge-linux-arm64" = "releases/linux-arm64/libcjqt6_bridge.so"
    "cjqt6-bridge-macos-arm64" = "releases/macos-arm64/libcjqt6_bridge.dylib"
}

if ([string]::IsNullOrEmpty($RunId)) {
    $RunId = (gh run list --repo $repo --branch main --status success --limit 1 --json databaseId --jq ".[0].databaseId") 2>$null
    if ([string]::IsNullOrEmpty($RunId)) {
        throw "未找到成功的 main CI run，请用 -RunId <id> 指定（gh run list --repo $repo）"
    }
}
Write-Host "==> 从 CI run $RunId 同步四平台桥接库到 releases/" -ForegroundColor Cyan

$tmp = Join-Path $env:TEMP "cjqt6_bridge_artifacts_$RunId"
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

try {
    foreach ($name in $map.Keys) {
        $destRel = $map[$name]
        $dlDir = Join-Path $tmp $name
        gh run download $RunId --repo $repo --name $name --dir $dlDir 2>$null | Out-Null
        $src = Get-ChildItem $dlDir -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $src) { throw "artifact $name 下载失败或为空（run $RunId）" }
        $dest = Join-Path $base $destRel
        Copy-Item $src.FullName $dest -Force
        $sizeKB = [math]::Round((Get-Item $dest).Length / 1KB, 1)
        Write-Host ("  [OK] {0}  ({1} KB)" -f $destRel, $sizeKB) -ForegroundColor Green
    }
}
finally {
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "==> 同步完成。请核对后提交：" -ForegroundColor Cyan
Write-Host "    git add releases/ && git commit -m `"chore(releases): 同步 CI 四平台预编译桥接库 (run $RunId)`" && git push origin main"
