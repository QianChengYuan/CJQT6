# ============================================================
# deploy_qt.ps1 —— CJQT6 运行时 DLL 部署脚本（由 ui2cj 生成）
# cjpm build/run 不会部署 Qt6 运行时/平台插件/MSVC 运行库，
# 缺这些会导致启动时报 DLL 找不到或 Qt 平台插件错误（无窗口）。
# 用法：在本目录执行  powershell -ExecutionPolicy Bypass -File deploy_qt.ps1
# 然后  cjpm run  即可正常显示窗口。
# ============================================================

$ErrorActionPreference = "Stop"

$ExampleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$BinDir = Join-Path $ExampleRoot "target/release/bin"
if (-not (Test-Path $BinDir)) {
    Write-Host "[!] 找不到 $BinDir — 请先 cjpm build" -ForegroundColor Yellow
    exit 1
}

$QtCandidates = @(
    "C:\Qt\6.10.3\msvc2022_64",
    "C:\Qt\6.10.2\msvc2022_64",
    "C:\Qt\6.7.0\msvc2022_64"
)
$QtBin = $null
foreach ($q in $QtCandidates) {
    if (Test-Path (Join-Path $q "bin\Qt6Core.dll")) { $QtBin = $q; break }
}
if (-not $QtBin) {
    Write-Host "[!] 未找到 Qt6 msvc2022_64 安装，请修改脚本中的 $QtCandidates" -ForegroundColor Yellow
    exit 1
}
Write-Host "[*] 使用 Qt: $QtBin"

$QtDlls = Get-ChildItem (Join-Path $QtBin "bin") -Filter "Qt6*.dll"
foreach ($f in $QtDlls) { Copy-Item $f.FullName $BinDir -Force }
Write-Host ("[+] 已拷贝 Qt6 运行时 DLL: " + $QtDlls.Count)

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
if (-not $CrtDir) { Write-Host "[!] 未找到 MSVC 运行库，将依赖系统 PATH" -ForegroundColor Yellow }
if ($CrtDir) {
    $crtFiles = Get-ChildItem $CrtDir -Filter "msvcp140*.dll" -ErrorAction SilentlyContinue
    $crtFiles += Get-ChildItem $CrtDir -Filter "vcruntime140*.dll" -ErrorAction SilentlyContinue
    foreach ($f in $crtFiles) { Copy-Item $f.FullName $BinDir -Force }
    Write-Host ("[+] 已拷贝 MSVC 运行库: " + $crtFiles.Count)
}

$Cjqt6DepDir = Join-Path $ExampleRoot "target/release/cjqt6"
if (Test-Path $Cjqt6DepDir) {
    $depFiles = Get-ChildItem $Cjqt6DepDir -Filter "*.dll" -ErrorAction SilentlyContinue
    foreach ($f in $depFiles) { Copy-Item $f.FullName $BinDir -Force }
    Write-Host ("[+] 已拷贝 cjqt6 依赖 DLL: " + $depFiles.Count)
}

$BridgeSrc = Join-Path $ExampleRoot "../../releases/windows-x64/cjqt6_bridge.dll"
if (Test-Path $BridgeSrc) {
    Copy-Item $BridgeSrc $BinDir -Force
    Write-Host "[+] 已拷贝 cjqt6_bridge.dll"
} else {
    Write-Host "[!] 未找到 $BridgeSrc（请先重建 bridge）" -ForegroundColor Yellow
}

Write-Host ("`n[OK] 部署完成，bin 目录 DLL 总数: " + (Get-ChildItem $BinDir -Filter '*.dll').Count)
Write-Host "[*] 现在可以运行: cjpm run"
