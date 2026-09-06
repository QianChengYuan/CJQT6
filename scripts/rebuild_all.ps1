# rebuild_all.ps1 - 完整构建：FFI 桥接库 + CJQT6 子包 + 示例
# 在 CJQT6 根目录运行: powershell -ExecutionPolicy Bypass -File scripts\rebuild_all.ps1
#
# 用法:
#   .\scripts\rebuild_all.ps1                          # 构建 all_controls_demo（默认）
#   .\scripts\rebuild_all.ps1 -Example dormitory_manager  # 构建指定示例
#   .\scripts\rebuild_all.ps1 -SkipExample              # 跳过示例构建
#   .\scripts\rebuild_all.ps1 -SkipBridge              # 跳过桥接库编译（仅 cjpm build + 示例）
#
# 重要顺序: 必须先构建桥接库，再执行 `cjpm build`。
# 子包的 DLL 链接到 releases/windows-x64/cjqt6_bridge.dll，
# 新增的任何 `foreign func qXxx` 绑定都需要先编译新桥接库，
# 否则链接阶段会报 "undefined symbol: qXxx"。
# 仅当桥接库已是最新且未改动 native/ 下 C++ 代码时，可用 -SkipBridge 加速重建。

param(
    [string]$Example = "all_controls_demo",
    [switch]$SkipExample,
    [switch]$SkipBridge,
    [string]$QtDir = ""
)

$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $RootDir
Set-Location $RootDir
Write-Host "工作目录: $RootDir"

# ---- 第1步: 查找 cjpm ----
$cjpm = Get-Command cjpm -ErrorAction SilentlyContinue
if (-not $cjpm) {
    $candidates = @(
        "$env:CANGJIE_HOME\tools\bin\cjpm.exe",
        "$env:USERPROFILE\.cangjie\tools\bin\cjpm.exe",
        "C:\CodeTools\cangjie\cangjie_1.1.0\tools\bin\cjpm.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { $cjpm = Get-Command $c; break }
    }
}
if (-not $cjpm) {
    Write-Host "错误: 未在 PATH 中找到 cjpm" -ForegroundColor Red
    exit 1
}
Write-Host "找到 cjpm: $($cjpm.Source)"

# ---- 第2步: 清理旧构建产物 ----
Write-Host "清理旧构建..."
if (Test-Path "examples\$Example\target") {
    Remove-Item -Recurse -Force "examples\$Example\target"
}
if (Test-Path "target") {
    Remove-Item -Recurse -Force "target"
}

# ---- 第3步: 先构建原生 FFI 桥接库（子包链接依赖它） ----
if ($SkipBridge) {
    Write-Host "跳过桥接库编译（已指定 -SkipBridge，使用 releases/ 现有产物）"
} else {
    Write-Host "构建原生 FFI 桥接库（必须在 cjpm build 之前）..."
    $updateArgs = @()
    if ($QtDir) { $updateArgs += "-QtDir"; $updateArgs += $QtDir }
    & "$RootDir\scripts\update-bridge.ps1" $updateArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "错误: 桥接库构建失败" -ForegroundColor Red
        exit 1
    }
}

# ---- 第4步: 构建 cjqt6 子包（链接到新桥接库） ----
Write-Host "构建 cjqt6 子包..."
& $cjpm build
if ($LASTEXITCODE -ne 0) {
    Write-Host "错误: cjpm 构建失败" -ForegroundColor Red
    exit 1
}

# ---- 第5步: 构建示例 + 部署 Qt ----
if ($SkipExample) {
    Write-Host "跳过示例构建（已指定 -SkipExample）"
} else {
    Write-Host "构建示例 $Example..."
    Set-Location "examples\$Example"
    & $cjpm build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "错误: 示例构建失败" -ForegroundColor Red
        exit 1
    }

    # 部署 Qt 运行时
    $deployScript = "$RootDir\examples\$Example\deploy_qt.ps1"
    if (Test-Path $deployScript) {
        & $deployScript
    }
}

Write-Host "完成。运行: cjpm run"
