# ============================================================
# run-example.ps1 — CJQT6 示例一键运行(Windows)
# ------------------------------------------------------------
# 换一个示例名就能跑起来。脚本自动处理三类最常见的踩坑:
#   1) CJQT6_ROOT 指向「当前这份仓库」—— 避免误用其它克隆目录的产物;
#   2) 只保留与 bridge ABI 匹配的 Qt(默认 QTDIR / C:\Qt\6.9.1\msvc2022_64),
#      把其它 Qt 版本从 PATH 中剔除,并在启动前做一次 ABI 自检;
#   3) 构建后把 Qt 运行时 / cjqt6 依赖 / bridge 部署到 exe 同目录,
#      使 exe 即便 PATH 里有别的 Qt 也能加载到正确的 DLL。
#
# 用法(在仓库根或 examples 目录下均可):
#   .\examples\run-example.ps1                      # 列出全部可运行示例
#   .\examples\run-example.ps1 CjMusic              # 构建 + 部署 + 运行
#   .\examples\run-example.ps1 hello_cjqt6 -NoRun   # 只构建 + 部署,不启动
#   .\examples\run-example.ps1 CjMusic -SkipBuild   # 跳过构建,直接部署 + 运行
#   .\examples\run-example.ps1 qq_chat_lan/server   # 子目录工程(相对 examples/ 的路径)
#   .\examples\run-example.ps1 CjMusic -QtDir "C:\Qt\6.9.1\msvc2022_64"
#
# 参数:
#   -Name      示例名(位置参数 0);可带子目录,如 qq_chat_lan/client
#   -QtDir     指定 Qt6(msvc2022_64)目录;不传则用 $env:QTDIR 或自动探测
#   -SkipBuild 跳过 cjpm build(适用于已构建过、只想重新部署运行)
#   -NoRun     只构建 + 部署,不启动程序
#
# 说明文档: examples/README.md
# ============================================================

[CmdletBinding()]
param(
    [Parameter(Position = 0)][string]$Name = "",
    [string]$QtDir = "",
    [switch]$SkipBuild,
    [switch]$NoRun
)

$ErrorActionPreference = "Stop"

# 复用仓库共享函数(Get-RootDir / Find-QtDir / Set-QtEnv / Set-Cjqt6RootEnv / Write-* 等)
. "$PSScriptRoot\..\scripts\lib\common.ps1"

$RootDir = Get-RootDir -ScriptPath $PSCommandPath
$ExamplesDir = Join-Path $RootDir "examples"

# ---------- bridge 与 Qt 的 ABI 自检 ----------
# 原理: bridge 由某个 Qt 版本编译, 其导入表里记录了 Qt6Core 的符号签名(MSVC mangled 名)。
#   Qt 6.9 → 6.10 之间 QEventDispatcherWin32::registerTimer 的签名发生过变化, 签名对不上时
#   Windows 会在加载期弹出「无法定位程序输入点 ... 于 cjqt6_bridge.dll 上」。
#   这里在启动前直接比对符号, 把天书弹窗换成一句看得懂的报错。
# 返回 $null 表示无法判定(缺文件/找不到锚点), 此时不做拦截。
function Test-BridgeQtAbi {
    param(
        [Parameter(Mandatory = $true)][string]$QtDir,
        [Parameter(Mandatory = $true)][string]$BridgePath
    )
    if (-not (Test-Path $BridgePath)) { return $null }
    $qtCore = Join-Path $QtDir "bin\Qt6Core.dll"
    if (-not (Test-Path $qtCore)) { return $null }

    $anchor = '?registerTimer@QEventDispatcherWin32@@'
    $bridgeText = [Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes($BridgePath))
    $i = $bridgeText.IndexOf($anchor)
    if ($i -lt 0) { return $null }
    $need = $bridgeText.Substring($i, [Math]::Min(72, $bridgeText.Length - $i))

    $qtText = [Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes($qtCore))
    $j = $qtText.IndexOf($anchor)
    if ($j -lt 0) { return @{ Ok = $false; Need = $need; Have = "(Qt6Core.dll 未导出该符号)" } }
    $have = $qtText.Substring($j, [Math]::Min(72, $qtText.Length - $j))

    return @{ Ok = ($have -eq $need); Need = $need; Have = $have }
}

# ---------- 不带参数: 列出所有可运行示例 ----------
if ([string]::IsNullOrEmpty($Name)) {
    Write-Section "CJQT6 可运行示例"
    Write-Host "用法: .\run-example.ps1 <示例名> [参数]" -ForegroundColor DarkGray
    Write-Host ""
    Get-ChildItem $ExamplesDir -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName "cjpm.toml") } |
        Sort-Object Name |
        ForEach-Object {
            $desc = ""
            $toml = Get-Content (Join-Path $_.FullName "cjpm.toml") -Raw -ErrorAction SilentlyContinue
            if ($toml -match '(?m)^\s*description\s*=\s*"([^"]*)"') { $desc = $matches[1] }
            Write-Host ("  {0,-20} {1}" -f $_.Name, $desc)
        }
    Write-Host ""
    Write-Host "子目录工程: qq_chat_lan/server(先起服务端) 与 qq_chat_lan/client" -ForegroundColor DarkGray
    Write-Host "其它资源目录: examples/resource(素材)、examples/CjDash(方案文档, 无 cjpm 工程)" -ForegroundColor DarkGray
    return
}

# ---------- 定位示例工程 ----------
$ExDir = Join-Path $ExamplesDir $Name
if (-not (Test-Path (Join-Path $ExDir "cjpm.toml"))) {
    Write-Die "未找到示例工程 examples\$Name(不带参数运行本脚本可列出全部示例)"
}

$Total = 5
$step = 0

# ---------- 1/5. Qt 环境 ----------
$step++
Write-Step $step $Total "选定 Qt 并剔除 PATH 中的其它 Qt 版本..."
$Qt = Find-QtDir -QtDir $QtDir
if (-not $Qt) {
    Write-Die "未找到 Qt6(msvc2022_64)。请安装 Qt 6.9.1,或用 -QtDir 指定,例如 -QtDir 'C:\Qt\6.9.1\msvc2022_64'"
}
Set-Cjqt6RootEnv -RootDir $RootDir
Set-QtEnv -QtDir $Qt -RemoveOtherQtVersions | Out-Null
Write-Host "  Qt         : $Qt"
Write-Host "  CJQT6_ROOT : $env:CJQT6_ROOT"

# ---------- 2/5. bridge 与 Qt 的 ABI 自检 ----------
$step++
Write-Step $step $Total "校验 cjqt6_bridge.dll 与本机 Qt 的 ABI 是否匹配..."
$Bridge = Join-Path $RootDir "releases\windows-x64\cjqt6_bridge.dll"
$abi = Test-BridgeQtAbi -QtDir $Qt -BridgePath $Bridge
if ($null -eq $abi) {
    Write-Host "  (缺少 bridge 或 Qt6Core,跳过自检)" -ForegroundColor DarkGray
} elseif ($abi.Ok) {
    Write-Host "  ABI 匹配" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "  本机 Qt 与 cjqt6_bridge.dll 的 ABI 不匹配 —— 跑起来会弹「无法定位程序输入点 ... 于 cjqt6_bridge.dll 上」:" -ForegroundColor Red
    Write-Host "    bridge 需要 : $($abi.Need)" -ForegroundColor Yellow
    Write-Host "    本机 Qt 提供: $($abi.Have)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  处理方式(任选其一):" -ForegroundColor Cyan
    Write-Host "    1) 换成与 bridge 匹配的 Qt:  .\run-example.ps1 $Name -QtDir 'C:\Qt\6.9.1\msvc2022_64'"
    Write-Host "    2) 安装该 Qt 版本(6.9.1);release 内的 bridge 与 CI 均为 Qt 6.9.1 ABI"
    Write-Host "    3) 若已切换 Qt 版本仍报错,删掉 native\build_windows_x64 重编 bridge(见 AGENTS.md)"
    Write-Host ""
    Write-Die "Qt ABI 自检未通过,已中止"
}

# ---------- 3/5. 清理陈旧示例缓存 ----------
$step++
Write-Step $step $Total "检查示例缓存是否由旧版本库构建..."
if (Clear-StaleExampleCache -ExampleDir $ExDir -RootDir $RootDir) {
    Write-Host "  已清理陈旧缓存(库形态变更后必须重编)" -ForegroundColor Yellow
} else {
    Write-Host "  缓存有效,无需清理" -ForegroundColor DarkGray
}

# ---------- 4/5. 构建 + 部署运行时 ----------
$step++
if ($SkipBuild) {
    Write-Step $step $Total "跳过 cjpm build(-SkipBuild)" -Level Skip
} else {
    Write-Step $step $Total "cjpm build..."
    Push-Location $ExDir
    try { cjpm build } finally { Pop-Location }
    if ($LASTEXITCODE -ne 0) { Write-Die "cjpm build 失败(示例: $Name)" }
}

Write-Host "  部署 Qt 运行时 / cjqt6 依赖 / bridge 到 bin 目录..."
& (Join-Path $RootDir "scripts\deploy-qt-example.ps1") -ExampleRoot $ExDir

# ---------- 5/5. 运行 ----------
$step++
if ($NoRun) {
    Write-Step $step $Total "跳过运行(-NoRun);可自行执行: cd examples\$Name && cjpm run" -Level Skip
    return
}
Write-Step $step $Total "cjpm run(关闭程序窗口即结束)..."
# cjpm 把依赖编译到 <示例>/target/release 及其子目录(cjqt6/以及第三方依赖如 lrc4cj、
# charset4cj@cangjie_tpc 等)。这些目录必须能被 exe 找到,否则启动即报 0xC0000135(找不到 DLL)。
$relRoot = Join-Path $ExDir "target\release"
$env:PATH = "$relRoot;$env:PATH"
Get-ChildItem $relRoot -Directory -ErrorAction SilentlyContinue |
    ForEach-Object { $env:PATH = "$($_.FullName);$env:PATH" }

# Qt 插件路径: 只认本示例 bin 下的插件(部署时已放好 platforms/multimedia/sqldrivers 等)。
# 不设的话,用户级环境变量 QT_PLUGIN_PATH(常残留其它 Qt 版本,如 6.10.3)会被优先搜索,
# 日志出现大量 "uses incompatible Qt library",严重时 multimedia 等后端加载失败,
# 表现为「程序能启动、但播放音乐静默无效」。
$binDir = Join-Path $relRoot "bin"
$env:QT_PLUGIN_PATH = $binDir
$env:QT_QPA_PLATFORM_PLUGIN_PATH = Join-Path $binDir "platforms"

Push-Location $ExDir
try { cjpm run } finally { Pop-Location }
