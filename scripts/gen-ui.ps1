# ============================================================
# gen-ui.ps1 - Designer (.ui) 一键转仓颉代码
#
# 用法:
#   .\scripts\gen-ui.ps1 examples\ui2cj_demo\login_form.ui
#   .\scripts\gen-ui.ps1 .\login_form.ui -ProjectDir examples\ui2cj_demo
#
# 行为:
#   1. 自动探测 ui 所在 cjpm 工程（向上找 cjpm.toml），自动填 package
#   2. 默认输出到该工程的 src/main.cj
#   3. 在工程目录执行 cjpm build 验证生成物可编译
#   4. 可选 --out 指定输出文件、--no-build 跳过编译
# ============================================================
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$UiFile,

    [Parameter(Mandatory = $false)]
    [string]$ProjectDir,

    [Parameter(Mandatory = $false)]
    [string]$Out,

    [Parameter(Mandatory = $false)]
    [switch]$NoBuild
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot

if (-not (Test-Path -LiteralPath $UiFile)) {
    # 允许相对仓库根或相对当前目录
    $candidates = @(
        (Join-Path $Root $UiFile),
        (Join-Path (Get-Location) $UiFile)
    )
    $UiFile = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if (-not $UiFile) {
        Write-Error "找不到 .ui 文件: $UiFile"
        exit 1
    }
}

$UiFile = (Resolve-Path -LiteralPath $UiFile).Path
Write-Host "=== 转换 .ui → 仓颉 ===" -ForegroundColor Cyan
Write-Host "  源文件 : $UiFile"

# 组装 python 参数
$pyArgs = @($UiFile)
if ($Out) { $pyArgs += $Out }
if (-not $NoBuild) { $pyArgs += "--build" }
if ($ProjectDir) { $pyArgs += "--project-dir"; $pyArgs += $ProjectDir }

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    $python = Get-Command py -ErrorAction SilentlyContinue
}
if (-not $python) {
    Write-Error "未找到 python，请安装 Python 3 并加入 PATH"
    exit 1
}

$script = Join-Path $Root "examples\ui2cj_demo\uic2cj.py"
& $python.Source $script @pyArgs
exit $LASTEXITCODE
