# ============================================================
# deploy_qt.ps1 —— CjMonitor 运行时 DLL 部署脚本
#
# 背景：cjpm build/run 只把 cjqt6 自身的 DLL 拷到 target/release/bin，
#       不会部署 Qt6 运行时 / 平台插件 / MSVC 运行库 / 仓颉运行时。
#       缺失会导致：
#         - 找不到模块 (0xC0000135)：缺 DLL
#         - 找不到程序入口 (0xC0000139)：找到了 DLL 但版本过旧
#
# ⚠ MSVC 运行库必须取**最新**的 x64 redist。
#   若按固定的 "Microsoft.VC143.CRT" 匹配，可能抓到 14.4x 的旧版；
#   而用新工具链（VC145 / 14.5x）编译的 cjqt6_bridge.dll 会因缺少
#   新导出而以 0xC0000139 失败。本脚本按版本号取最大者。
#
# 用法（在 examples/CjMonitor 目录执行）：
#   pwsh -ExecutionPolicy Bypass -File deploy_qt.ps1
# 只需在 cjpm build 之后跑一次（DLL 不会被 cjpm 删除）。
# ============================================================

$ErrorActionPreference = "Stop"

# ---- 定位示例的 bin 目录 ----
$ExampleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$BinDir = Join-Path $ExampleRoot "target/release/bin"
if (-not (Test-Path $BinDir)) {
    Write-Host "[!] 找不到 $BinDir — 请先 cjpm build" -ForegroundColor Yellow
    exit 1
}

# ---- 探测 Qt msvc 安装（优先 QTDIR，其次常见候选）----
$QtCandidates = @()
if ($env:QTDIR) { $QtCandidates += $env:QTDIR }
$QtCandidates += @(
    "C:\Qt\6.9.1\msvc2022_64",
    "C:\Qt\6.7.0\msvc2022_64"
)
$QtBin = $null
foreach ($q in $QtCandidates) {
    if (Test-Path (Join-Path $q "bin\Qt6Core.dll")) { $QtBin = $q; break }
}
if (-not $QtBin) {
    Write-Host "[!] 未找到 Qt6 msvc2022_64 安装，请设置 QTDIR 或修改脚本中的候选列表" -ForegroundColor Yellow
    exit 1
}
Write-Host "[*] 使用 Qt: $QtBin"

# ---- 取版本最高的 x64 MSVC 运行库目录 ----
# 注意：VS 安装布局是 <base>\<版本>\<版本名>\VC\Redist\MSVC\<crt版本>\x64\Microsoft.VC*.CRT，
# 层级不固定，故直接递归找 msvcp140.dll，只看 x64 路径，按版本号取最大者。
$CrtDir = $null
$CrtBest = -1
$CrtBestVer = ""
foreach ($base in @("C:\Program Files\Microsoft Visual Studio", "C:\Program Files (x86)\Microsoft Visual Studio")) {
    if (-not (Test-Path $base)) { continue }
    $probes = Get-ChildItem -Path $base -Recurse -Filter "msvcp140.dll" -ErrorAction SilentlyContinue |
              Where-Object {
                  # 只要桌面 x64 版本：
                  # - 排除 onecore（Windows Core 专用，桌面程序加载会失败）
                  # - 排除 x86 / arm64 / Hostx64 等工具自有副本以外的架构
                  ($_.FullName -match '\\x64\\') -and
                  ($_.FullName -notmatch '\\onecore\\')
              }
    foreach ($p in $probes) {
        $vi = $p.VersionInfo
        $score = [long]$vi.FileMajorPart * 1000000 + [long]$vi.FileMinorPart * 1000 + [long]$vi.FileBuildPart
        # 同版本下优先取 Redist（运行时发行库），而非工具链自带副本
        if ($p.FullName -match '\\VC\\Redist\\') { $score = $score * 10 }
        if ($score -gt $CrtBest) {
            $CrtBest = $score
            $CrtDir = Split-Path -Parent $p.FullName
            $CrtBestVer = $vi.FileVersion
        }
    }
}
if ($CrtDir) {
    Write-Host "[*] MSVC 运行库: $CrtDir  ($CrtBestVer)"
} else {
    Write-Host "[!] 未找到 MSVC x64 Redist，将依赖系统 PATH 中的运行库" -ForegroundColor Yellow
}

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
# sqldrivers 是 QSQLITE 驱动的载体：缺它 QSqlDatabase/QSqlQuery 会初始化失败
Copy-Plugin "sqldrivers"
# multimedia 用于告警提示音（缺失时应用按“静默降级”处理）
Copy-Plugin "multimedia"

# ---- 拷贝 MSVC 运行库（最新版本）----
# 先清掉 bin 中已有的旧运行库，否则残留的旧版本会遮蔽新版本，
# 导致 cjqt6_bridge.dll 以「找不到程序入口」(0xC0000139) 加载失败。
foreach ($pat in @("msvcp140*.dll", "vcruntime140*.dll", "concrt140*.dll")) {
    Get-ChildItem $BinDir -Filter $pat -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
}
if ($CrtDir) {
    $crtFiles = @()
    $crtFiles += Get-ChildItem $CrtDir -Filter "msvcp140*.dll" -ErrorAction SilentlyContinue
    $crtFiles += Get-ChildItem $CrtDir -Filter "vcruntime140*.dll" -ErrorAction SilentlyContinue
    $crtFiles += Get-ChildItem $CrtDir -Filter "concrt140*.dll" -ErrorAction SilentlyContinue
    foreach ($f in $crtFiles) { Copy-Item $f.FullName $BinDir -Force }
    Write-Host ("[+] 已拷贝 MSVC 运行库: " + $crtFiles.Count)
}

# ---- 拷贝 cjqt6 依赖 DLL，使 bin 自包含 ----
$Cjqt6DepDir = Join-Path $ExampleRoot "target/release/cjqt6"
if (Test-Path $Cjqt6DepDir) {
    $depFiles = Get-ChildItem $Cjqt6DepDir -Filter "*.dll" -ErrorAction SilentlyContinue
    foreach ($f in $depFiles) { Copy-Item $f.FullName $BinDir -Force }
    Write-Host ("[+] 已拷贝 cjqt6 依赖 DLL: " + $depFiles.Count)
} else {
    Write-Host "[!] 未找到 $Cjqt6DepDir（请先 cjpm build）" -ForegroundColor Yellow
}

# ---- 拷贝仓颉运行时（libcangjie-*.dll / libboundscheck.dll）----
# 仓颉程序的动态依赖不在 bin 中，若 PATH 上存在多个 SDK 版本会串用，故一并拷入。
$CjcCmd = Get-Command cjc -ErrorAction SilentlyContinue
if ($CjcCmd) {
    $CjRoot = Split-Path -Parent (Split-Path -Parent $CjcCmd.Source)
    $CjRuntime = Join-Path $CjRoot "runtime\lib\windows_x86_64_cjnative"
    if (Test-Path $CjRuntime) {
        $rtFiles = Get-ChildItem $CjRuntime -Filter "*.dll" -ErrorAction SilentlyContinue
        foreach ($f in $rtFiles) { Copy-Item $f.FullName $BinDir -Force }
        Write-Host ("[+] 已拷贝仓颉运行时 DLL: " + $rtFiles.Count)
    } else {
        Write-Host "[!] 未找到 $CjRuntime" -ForegroundColor Yellow
    }
}

# ---- 拷贝原生 bridge DLL ----
# 优先使用本地刚构建的产物：releases/ 中的入库版本可能按**另一个 Qt 版本**构建，
# 与本地 Qt 运行时不兼容（表现为加载期 0xC0000139「找不到程序入口」）。
# 另注：IDE 的语言服务会加载 releases/ 下的 DLL，该文件可能被占用而无法覆盖。
$BridgeCandidates = @(
    (Join-Path $ExampleRoot "..\..\native\build_windows_x64\bin\cjqt6_bridge.dll"),
    (Join-Path $ExampleRoot "..\..\releases\windows-x64\cjqt6_bridge.dll")
)
$BridgeSrc = $null
foreach ($c in $BridgeCandidates) {
    if (Test-Path $c) { $BridgeSrc = $c; break }
}
if ($BridgeSrc) {
    Copy-Item $BridgeSrc $BinDir -Force
    Write-Host "[+] 已拷贝 cjqt6_bridge.dll <- $BridgeSrc"
} else {
    Write-Host "[!] 未找到 cjqt6_bridge.dll（请先重建 bridge）" -ForegroundColor Yellow
}

Write-Host ("`n[OK] 部署完成，bin 目录 DLL 总数: " + (Get-ChildItem $BinDir -Filter '*.dll').Count)
Write-Host "[*] 现在可以运行: pwsh -File scripts\run_debug.ps1"
