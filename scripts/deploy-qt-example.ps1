# ============================================================
# deploy-qt-example.ps1 — CJQT6 示例运行时 DLL 部署脚本(通用版)
# ------------------------------------------------------------
# 背景:cjpm build/run 只把 cjqt6 自身的 DLL 拷到 target/release/bin,
# 但不会部署 Qt6 运行时 / 平台插件 / MSVC 运行库,这些缺失会导致
# 启动时报 "找不到 xxx.dll"。
#
# 用法(在示例根目录或仓库根目录调用均可):
#   pwsh -File ..\..\scripts\deploy-qt-example.ps1 -ExampleRoot .                       # 部署当前目录为示例根,跑示例前的标准动作
#   pwsh -File ..\..\scripts\deploy-qt-example.ps1 -ExampleRoot examples\notepad        # 显式指定示例根目录(支持相对/绝对路径)
#
# 与原 tests/deploy_qt.ps1(后被合并)等价,但支持 -ExampleRoot 参数,
# 不再硬编码脚本所在目录为示例根。
#
# 共享函数(探测 Qt / MSVC CRT):scripts/lib/common.ps1
# ============================================================

[CmdletBinding()]
param(
    [string]$ExampleRoot = "."  # 示例根目录(默认当前目录)
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\lib\common.ps1"

$RootDir = Get-RootDir -ScriptPath $PSCommandPath
$ExampleRoot = (Resolve-Path $ExampleRoot).Path
$BinDir = Join-Path $ExampleRoot "target/release/bin"

if (-not (Test-Path $BinDir)) {
    Write-Host "[!] 找不到 $BinDir — 请先 cjpm build" -ForegroundColor Yellow
    exit 1
}

# ---- 探测 Qt6(msvc2022_64)----
$QtBin = Find-QtDir
if (-not $QtBin) {
    Write-Host "[!] 未找到 Qt6 msvc2022_64 安装,请用 -QtDir 指定" -ForegroundColor Yellow
    exit 1
}
Write-Host "[*] 使用 Qt: $QtBin"

# ---- 探测 MSVC 运行库 ----
$CrtDir = $null
$vsRoots = @(
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools",
    "C:\Program Files\Microsoft Visual Studio\2022\Community",
    "C:\Program Files\Microsoft Visual Studio\2022\Professional",
    "C:\Program Files\Microsoft Visual Studio\2022\Enterprise"
)
foreach ($r in $vsRoots) {
    $d = Get-ChildItem -Path $r -Recurse -Filter "msvcp140.dll" -ErrorAction SilentlyContinue |
         Where-Object { $_.FullName -like "*Microsoft.VC143.CRT*" } |
         Select-Object -First 1
    if ($d) { $CrtDir = $d.DirectoryName; break }
}
if (-not $CrtDir) {
    Write-Host "[!] 未找到 MSVC 运行库,将依赖系统 PATH" -ForegroundColor Yellow
}

# ---- 拷贝 Qt6 运行时 DLL ----
$QtDlls = Get-ChildItem (Join-Path $QtBin "bin") -Filter "Qt6*.dll"
foreach ($f in $QtDlls) { Copy-Item $f.FullName $BinDir -Force }
Write-Host ("[+] 已拷贝 Qt6 运行时 DLL: " + $QtDlls.Count)

# ---- 拷贝平台/样式/图片格式插件 ----
function Copy-Plugin($sub) {
    $src = Join-Path $QtBin "plugins/$sub"
    if (Test-Path $src) {
        $dst = Join-Path $BinDir $sub
        New-Item -ItemType Directory -Force -Path $dst | Out-Null
        foreach ($f in (Get-ChildItem $src -Filter "*.dll")) { Copy-Item $f.FullName $dst -Force }
        Write-Host ("[+] 已拷贝插件 $sub : " + (Get-ChildItem $dst -Filter '*.dll').Count)
    }
}
Copy-Plugin "platforms"
Copy-Plugin "styles"
Copy-Plugin "imageformats"

# ---- 拷贝 MSVC 运行库 ----
if ($CrtDir) {
    $crtFiles = Get-ChildItem $CrtDir -Filter "msvcp140*.dll" -ErrorAction SilentlyContinue
    $crtFiles += Get-ChildItem $CrtDir -Filter "vcruntime140*.dll" -ErrorAction SilentlyContinue
    foreach ($f in $crtFiles) { Copy-Item $f.FullName $BinDir -Force }
    Write-Host ("[+] 已拷贝 MSVC 运行库: " + $crtFiles.Count)
}

# ---- 拷贝 cjqt6 依赖 DLL(target/release/cjqt6/*.dll),使 bin 自包含 ----
$Cjqt6DepDir = Join-Path $ExampleRoot "target/release/cjqt6"
if (Test-Path $Cjqt6DepDir) {
    $depFiles = Get-ChildItem $Cjqt6DepDir -Filter "*.dll" -ErrorAction SilentlyContinue
    foreach ($f in $depFiles) { Copy-Item $f.FullName $BinDir -Force }
    Write-Host ("[+] 已拷贝 cjqt6 依赖 DLL: " + $depFiles.Count)
} else {
    Write-Host "[!] 未找到 $Cjqt6DepDir(请先 cjpm build)" -ForegroundColor Yellow
}

# ---- 拷贝原生 bridge DLL(releases/windows-x64/cjqt6_bridge.dll)----
$BridgeSrc = Join-Path $RootDir "releases\windows-x64\cjqt6_bridge.dll"
if (Test-Path $BridgeSrc) {
    Copy-Item $BridgeSrc $BinDir -Force
    Write-Host "[+] 已拷贝 cjqt6_bridge.dll"
} else {
    Write-Host "[!] 未找到 $BridgeSrc(请先重建 bridge)" -ForegroundColor Yellow
}

Write-Host ("`n[OK] 部署完成,bin 目录 DLL 总数: " + (Get-ChildItem $BinDir -Filter '*.dll').Count)
Write-Host "[*] 现在可以运行: cjpm run"