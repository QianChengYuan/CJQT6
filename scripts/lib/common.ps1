# ============================================================
# scripts/lib/common.ps1 — CJQT6 脚本共享函数(PowerShell)
# ------------------------------------------------------------
# **基线:PowerShell 7+(含 PowerShell 7.0+ / pwsh 跨平台)**
#   不兼容 Windows PowerShell 5.1
#   GitHub Actions windows-2022 runner 默认 pwsh 7.x,符合基线
#   本地开发建议升级到 PowerShell 7+(`winget install Microsoft.PowerShell`)
#
# 提供:
#   - Find-QtDir         探测 Qt6 安装路径(QtDir / QTDIR / 常见路径 / 扫描)
#   - Find-Cjpm          探测 cjpm 可执行文件(PATH / CANGJIE_HOME / 候选)
#   - Find-Cjcov          探测 cjcov 可执行文件
#   - Find-VsCrtDir      探测 MSVC 运行库(VS BuildTools / Community / Pro / Enterprise)
#   - Get-RootDir        定位 CJQT6 项目根(脚本所在目录的父目录)
#   - Set-Cjqt6RootEnv   设置 $env:CJQT6_ROOT 为项目根
#   - Set-Location-Root  Set-Location 到项目根
#   - Write-Section      打印彩色 section 标题
#   - Write-Step         打印步骤进度(第 N 步)
#   - Write-Die          错误消息 + 退出 1
#
# 用法(其他脚本 dot-source):
#   . "$PSScriptRoot\lib\common.ps1"
# ============================================================

# ---------- 防止重复 dot-source ----------
if ($MyInvocation.CommandOrigin -eq '.' -and $script:Cjqt6CommonLoaded) {
    return
}
$script:Cjqt6CommonLoaded = $true

# ---------- 定位 CJQT6 项目根 ----------
# 假设调用脚本位于 scripts/ 下,返回其父目录绝对路径
function Get-RootDir {
    param([string]$ScriptPath = $PSCommandPath)
    if ([string]::IsNullOrEmpty($ScriptPath)) {
        $ScriptPath = $MyInvocation.MyCommand.Path
    }
    $d = Split-Path -Parent $ScriptPath
    # scripts/lib/common.ps1 → scripts/lib → scripts → 项目根
    # scripts/foo.ps1        → scripts      → 项目根
    $leaf = Split-Path -Leaf $d
    if ($leaf -eq 'lib') {
        return (Split-Path -Parent (Split-Path -Parent $d))
    }
    return (Split-Path -Parent $d)
}

# ---------- Set-Location 到项目根 ----------
function Set-Location-Root {
    param([string]$RootDir = "")
    $RootDir = if ([string]::IsNullOrEmpty($RootDir)) { Get-RootDir } else { $RootDir }
    Set-Location $RootDir
    return $RootDir
}

# ---------- 设置 $env:CJQT6_ROOT 为项目根 ----------
function Set-Cjqt6RootEnv {
    param([string]$RootDir = "")
    $RootDir = if ([string]::IsNullOrEmpty($RootDir)) { Get-RootDir } else { $RootDir }
    $env:CJQT6_ROOT = $RootDir
}

# ---------- 探测 Qt6 安装路径 ----------
# 优先级:QtDir 参数 > $env:QTDIR > 常见路径 > 扫描 C:\Qt\6.*
function Find-QtDir {
    [CmdletBinding()]
    param(
        [string]$QtDir = ""
    )

    $QtDir = if ([string]::IsNullOrEmpty($QtDir)) { $env:QTDIR } else { $QtDir }

    if ([string]::IsNullOrEmpty($QtDir)) {
        $commonPaths = @(
            "C:\Qt\6.9.1\msvc2022_64",
            "C:\Qt\6.9.1\mingw_64",
            "C:\Qt\6.9.3\msvc2022_64",
            "C:\Qt\6.7.0\msvc2019_64",
            "C:\Qt\6.5.0\msvc2019_64"
        )
        $QtDir = $commonPaths | Where-Object { Test-Path "$_\bin\Qt6Core.dll" } | Select-Object -First 1
    }

    if ([string]::IsNullOrEmpty($QtDir)) {
        $qtDirs = Get-ChildItem "C:\Qt\6.*" -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending
        foreach ($d in $qtDirs) {
            $match = Get-ChildItem "$($d.FullName)\msvc*" -Directory -ErrorAction SilentlyContinue |
                Where-Object { Test-Path "$($_.FullName)\bin\Qt6Core.dll" } |
                Select-Object -First 1
            if ($match) { $QtDir = $match.FullName; break }
        }
    }

    if ([string]::IsNullOrEmpty($QtDir) -or -not (Test-Path "$QtDir\bin\Qt6Core.dll")) {
        return $null
    }
    return $QtDir
}

# ---------- 探测 cjpm 可执行文件 ----------
function Find-Cjpm {
    [CmdletBinding()]
    param()

    $cjpm = Get-Command cjpm -ErrorAction SilentlyContinue
    if ($cjpm) { return $cjpm }

    $candidates = @(
        "$env:CANGJIE_HOME\tools\bin\cjpm.exe",
        "$env:USERPROFILE\.cangjie\tools\bin\cjpm.exe",
        "C:\CodeTools\cangjie\cangjie_1.1.0\tools\bin\cjpm.exe"
    )
    foreach ($c in $candidates) {
        if ($c -and (Test-Path $c)) { return (Get-Command $c) }
    }
    return $null
}

# ---------- 探测 cjcov 可执行文件 ----------
function Find-Cjcov {
    [CmdletBinding()]
    param()

    $cjcov = Get-Command cjcov -ErrorAction SilentlyContinue
    if ($cjcov) { return $cjcov }

    $candidates = @(
        "$env:CANGJIE_HOME\tools\bin\cjcov.exe",
        "$env:USERPROFILE\.cangjie\tools\bin\cjcov.exe",
        "C:\CodeTools\cangjie\cangjie_1.1.0\tools\bin\cjcov.exe"
    )
    foreach ($c in $candidates) {
        if ($c -and (Test-Path $c)) { return (Get-Command $c) }
    }
    return $null
}

# ---------- 探测 MSVC 运行库目录 ----------
# 扫描 VS 2022/2025 BuildTools/Community/Professional/Enterprise 下的 Microsoft.VC143.CRT
function Find-VsCrtDir {
    [CmdletBinding()]
    param()

    $vsRoots = @(
        "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools",
        "C:\Program Files\Microsoft Visual Studio\2022\Community",
        "C:\Program Files\Microsoft Visual Studio\2022\Professional",
        "C:\Program Files\Microsoft Visual Studio\2022\Enterprise",
        "C:\Program Files\Microsoft Visual Studio\18\Community"
    )
    foreach ($r in $vsRoots) {
        $d = Get-ChildItem -Path $r -Recurse -Filter "msvcp140.dll" -ErrorAction SilentlyContinue |
             Where-Object { $_.FullName -like "*Microsoft.VC143.CRT*" } |
             Select-Object -First 1
        if ($d) { return $d.DirectoryName }
    }
    return $null
}

# ---------- 打印 section 标题(cyan)----------
function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host " $Title" -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor Cyan
}

# ---------- 打印步骤进度(cyan "[N/M] ...")----------
function Write-Step {
    param(
        [int]$Step,
        [int]$Total,
        [string]$Text,
        [string]$Level = "Info"
    )
    $color = switch ($Level) {
        "Skip"   { "Yellow" }
        "Error"  { "Red" }
        default  { "Cyan" }
    }
    Write-Host "[$Step/$Total] $Text" -ForegroundColor $color
}

# ---------- 通用 die(Write-Error 后退出) ----------
function Write-Die {
    param([string]$Text)
    Write-Host "错误: $Text" -ForegroundColor Red
    exit 1
}

# ---------- 清理「由旧版本库构建」的示例缓存(返回 $true 表示已清理) ----------
# 背景: 示例是独立 cjpm 工程(cjqt6 = { path = "../../" })。cjpm 会把库各子包编译成
#   DLL + .cjo 放进 <示例>/target/release/cjqt6/,并连同 target/.dep-cache 指纹一起复用。
#   库的对外形态变更后(例如给接口加默认实现),旧缓存可能只被「重新链接」而不重新编译,
#   于是链接期报缺符号,形如:
#     ld.lld: error: undefined symbol: _CN10cjqt6.core12QtWidgetCore13setStyleSheetHRNat6StringE
#     ld.lld: error: undefined symbol: cjqt6.core:QtWidget.ti
#   这类失败与示例自身代码无关,清掉该示例的 target/ 即可恢复(与旧 rebuild_all.ps1 的做法一致);
#   ⚠ 必须在 cjpm build 之前清理 —— build 已经失败后再清就没意义了。
# 判据: src/**/*.cj 或根 cjpm.toml 的 mtime 晚于示例缓存里最新的 libcjqt6* 产物 → 判定陈旧。
function Clear-StaleExampleCache {
    param(
        [Parameter(Mandatory = $true)][string]$ExampleDir,
        [Parameter(Mandatory = $true)][string]$RootDir
    )
    $targetDir = Join-Path $ExampleDir "target"
    $libCacheDir = Join-Path $targetDir "release\cjqt6"
    if (-not (Test-Path $libCacheDir)) { return $false }

    # 库侧最近改动时间(src 下全部 .cj + 根 cjpm.toml)
    $libNewest = $null
    $srcDir = Join-Path $RootDir "src"
    if (Test-Path $srcDir) {
        foreach ($f in (Get-ChildItem $srcDir -Recurse -File -Filter "*.cj" -ErrorAction SilentlyContinue)) {
            if (-not $libNewest -or $f.LastWriteTime -gt $libNewest) { $libNewest = $f.LastWriteTime }
        }
    }
    $toml = Join-Path $RootDir "cjpm.toml"
    if (Test-Path $toml) {
        $t = (Get-Item $toml).LastWriteTime
        if (-not $libNewest -or $t -gt $libNewest) { $libNewest = $t }
    }
    if (-not $libNewest) { return $false }

    # 示例缓存里最新的库产物时间
    $cached = Get-ChildItem $libCacheDir -File -Filter "libcjqt6*" -ErrorAction SilentlyContinue |
              Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $cached) { return $false }
    if ($libNewest -le $cached.LastWriteTime) { return $false }

    Remove-Item $targetDir -Recurse -Force -ErrorAction SilentlyContinue
    return $true
}