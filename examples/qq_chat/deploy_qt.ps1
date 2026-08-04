# ============================================================
# deploy_qt.ps1 —— CJQT6 示例运行时 DLL 部署脚本
# 问题背景：cjpm build/run 只把 cjqt6 自身的 DLL 拷到
#   target/release/bin，但不会部署 Qt6 运行时 / 平台插件 /
#   MSVC 运行库。这些缺失会导致启动时报 "找不到 xxx.dll"。
# 用法：在示例目录执行
#   powershell -ExecutionPolicy Bypass -File deploy_qt.ps1
# 也可在 cjpm run 之前运行一次（DLL 不会被 cjpm 删除）。
# ============================================================

$ErrorActionPreference = "Stop"

# ---- 定位示例的 bin 目录（脚本需放在示例根目录）----
$ExampleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$BinDir = Join-Path $ExampleRoot "target/release/bin"
if (-not (Test-Path $BinDir)) {
    Write-Host "[!] 找不到 $BinDir — 请先 cjpm build" -ForegroundColor Yellow
    exit 1
}

# ---- 探测 Qt msvc 安装（按候选顺序取第一个存在 Qt6Core.dll 的）----
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

# ---- 自动探测 MSVC 运行库（VS BuildTools / VS 的 Redist）----
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

# ---- 拷贝 Qt6 运行时 DLL ----
$QtDlls = Get-ChildItem (Join-Path $QtBin "bin") -Filter "Qt6*.dll"
foreach ($f in $QtDlls) { Copy-Item $f.FullName $BinDir -Force }
Write-Host ("[+] 已拷贝 Qt6 运行时 DLL: " + $QtDlls.Count)

# ---- 拷贝平台 / 样式 / 图片格式插件 ----
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

# ---- 拷贝 cjqt6 依赖 DLL（target/release/cjqt6/*.dll），使 bin 自包含 ----
$Cjqt6DepDir = Join-Path $ExampleRoot "target/release/cjqt6"
if (Test-Path $Cjqt6DepDir) {
    $depFiles = Get-ChildItem $Cjqt6DepDir -Filter "*.dll" -ErrorAction SilentlyContinue
    foreach ($f in $depFiles) { Copy-Item $f.FullName $BinDir -Force }
    Write-Host ("[+] 已拷贝 cjqt6 依赖 DLL: " + $depFiles.Count)
} else {
    Write-Host "[!] 未找到 $Cjqt6DepDir（请先 cjpm build）" -ForegroundColor Yellow
}

# ---- 拷贝原生 bridge DLL（releases/windows-x64/cjqt6_bridge.dll）----
$BridgeSrc = Join-Path $ExampleRoot "..\..\releases\windows-x64\cjqt6_bridge.dll"
if (Test-Path $BridgeSrc) {
    Copy-Item $BridgeSrc $BinDir -Force
    Write-Host "[+] 已拷贝 cjqt6_bridge.dll"
} else {
    Write-Host "[!] 未找到 $BridgeSrc（请先重建 bridge）" -ForegroundColor Yellow
}

Write-Host ("`n[OK] 部署完成，bin 目录 DLL 总数: " + (Get-ChildItem $BinDir -Filter '*.dll').Count)
Write-Host "[*] 现在可以运行: cjpm run"
