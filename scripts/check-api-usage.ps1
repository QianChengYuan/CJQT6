# ============================================================
# check-api-usage.ps1 - 示例/测试代码对 cjqt6 API 的「存在性」校验（P3-1 门禁）
# ------------------------------------------------------------
# 背景（docs/internal/cjmonitor-findings.md P3-1）：
#   examples/*/ 与方案文档中长期存在「写法在库里根本不存在」的 API
#   （如 import cjqt6.process.*、QChartView.fromChart、Toast.show、
#     QSqlQuery.addBindValue、QLabel.setMinimumWidth ...），
#   照抄即编译失败，是新项目成本被放大的首要来源。
#   `gen-api-index.ps1` 解决「src/ 公共类是否被 docs/api 收录」，
#   本脚本解决另一半：**示例代码调用的 API 是否真实存在**。
#
# 校验三类（基于 src/ 的声明建立符号表，不看文档）：
#   1. 包名   import cjqt6.<pkg>[.*]   → <pkg> 必须被 src/ 中某文件 package 声明过
#   2. 类型名 代码中出现的 QXxx        → 必须是 src/ 中的 class/interface/struct/enum
#   3. 方法名 可推导接收者：同文件内 `let/var x = QXxx(...)` 之后（**按行就近生效**）
#             的 `x.method(...)`；以及静态形式 `QXxx.method(...)`
#             两者都要求 method 出现在 QXxx 的公共成员中（不区分静态/实例，减少误报）
#
# 已做的降噪处理（避免误报）：
#   - 去掉行注释 / 块注释 / 单行与**多行**字符串字面量内容（QSS 文案里会出现 QTabBar 等）
#   - 类型名识别要求形如 `Q` + 大写 + 小写（QLabel/QSqlQuery），排除 QSS_XXX 这类常量
#   - 局部变量→类型映射按行推进：同名变量复用于不同类型时不会串味
#
# 用法（仓库根目录）：
#   pwsh -File scripts\check-api-usage.ps1                     # 报告模式（退出码恒为 0）
#   pwsh -File scripts\check-api-usage.ps1 -Strict             # 门禁模式：有违规即退出码 1
#   pwsh -File scripts\check-api-usage.ps1 -Scope examples\CjMonitor
#   pwsh -File scripts\check-api-usage.ps1 -Scope examples,src\test -Strict
#
# 误报登记：scripts\lib\api-usage-allowlist.txt
#   package:cjqt6.xxx / type:QXxx / method:QXxx.method / file:<子串>
# ============================================================

[CmdletBinding()]
param(
    [string[]]$Scope = @("examples", "src\test"),
    [switch]$Strict
)

$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $RootDir
Set-Location $RootDir

# 类型名形状：Q + 大写字母 + 小写字母（QLabel / QSqlQuery / QAbstractItemView …）
$rxType = [regex]'\bQ[A-Z][a-z][A-Za-z0-9_]*\b'

# 「未知类型接收者」检查的内置跳过表：标准库 / FFI / 常用全局对象（非 cjqt6 类型）
$stdReceivers = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($n in @(
    'LibC', 'std', 'Path', 'File', 'Directory', 'Environment', 'Console', 'Process',
    'Array', 'ArrayList', 'HashMap', 'HashSet', 'LinkedList', 'TreeMap', 'Queue', 'Stack',
    'Mutex', 'Sync', 'AtomicInt64', 'AtomicBool', 'Thread', 'ThreadLocal', 'Future', 'Duration',
    'DateTime', 'Regex', 'Random', 'String', 'Rune', 'Byte', 'Text', 'Math', 'Option', 'Argument'
)) { [void]$stdReceivers.Add($n) }

# ---- 读入误报白名单 ----
$allowPackages = New-Object 'System.Collections.Generic.HashSet[string]'
$allowTypes    = New-Object 'System.Collections.Generic.HashSet[string]'
$allowMethods  = New-Object 'System.Collections.Generic.HashSet[string]'
$allowFiles    = New-Object 'System.Collections.Generic.HashSet[string]'
$allowListPath = Join-Path $RootDir "scripts\lib\api-usage-allowlist.txt"
if (Test-Path $allowListPath) {
    foreach ($raw in (Get-Content -LiteralPath $allowListPath)) {
        $line = $raw.Trim()
        if ($line -eq "" -or $line.StartsWith("#")) { continue }
        if ($line.StartsWith("package:")) { [void]$allowPackages.Add($line.Substring(8)) }
        elseif ($line.StartsWith("type:"))    { [void]$allowTypes.Add($line.Substring(5)) }
        elseif ($line.StartsWith("method:"))  { [void]$allowMethods.Add($line.Substring(7)) }
        elseif ($line.StartsWith("file:"))    { [void]$allowFiles.Add($line.Substring(5)) }
    }
}

# ---- 建立符号表（src/，排除 src/test/）----
$srcRoot = Join-Path $RootDir "src"
$declFiles = Get-ChildItem -LiteralPath $srcRoot -Recurse -Filter "*.cj" -File |
    Where-Object { $_.FullName -notmatch '[\\/]test[\\/]' }

$packages = New-Object 'System.Collections.Generic.HashSet[string]'
$types = @{}

foreach ($f in $declFiles) {
    $cur = $null
    $curKind = ""
    foreach ($line in (Get-Content -LiteralPath $f.FullName)) {
        if ($line -match '^\s*package\s+([\w\.]+)') { [void]$packages.Add($Matches[1]) }
        if ($line -match '^\s*(?:public\s+|internal\s+|protected\s+|private\s+)?(?:open\s+|sealed\s+|abstract\s+)?(class|interface|struct|enum)\s+([A-Za-z_]\w*)(.*)$') {
            $kind = $Matches[1]
            $nm = $Matches[2]
            $bases = @()
            if ($Matches[3] -match '<:\s*(.+)$') {
                $bases = ($Matches[1] -replace '\{.*$', '') -split '&' |
                    ForEach-Object { ($_.Trim() -replace '<.*$', '').Trim() } |
                    Where-Object { $_ -ne "" }
            }
            if (-not $types.ContainsKey($nm)) {
                $types[$nm] = [pscustomobject]@{
                    Name    = $nm
                    Kind    = $kind
                    Bases   = @($bases)
                    Methods = New-Object 'System.Collections.Generic.HashSet[string]'
                    File    = $f.Name
                }
            }
            $cur = $types[$nm]
            $curKind = $kind
            continue
        }
        # `extend QXxx { ... }` 里的公共成员也算该类型的能力
        if ($line -match '^\s*(?:public\s+|internal\s+)?extend\s+([A-Za-z_]\w*)') {
            $nm = $Matches[1]
            if (-not $types.ContainsKey($nm)) {
                $types[$nm] = [pscustomobject]@{
                    Name    = $nm
                    Kind    = "extend"
                    Bases   = @()
                    Methods = New-Object 'System.Collections.Generic.HashSet[string]'
                    File    = $f.Name
                }
            }
            $cur = $types[$nm]
            $curKind = "extend"
            continue
        }
        if ($line -match '^\}') { $cur = $null; $curKind = ""; continue }
        if ($null -ne $cur) {
            if ($line -match '^\s*public\s+(static\s+)?(?:open\s+)?func\s+(\w+)') {
                [void]$cur.Methods.Add($Matches[2])
            } elseif ($curKind -eq "interface" -and $line -match '^\s*(?:public\s+)?func\s+(\w+)') {
                # 接口成员默认 public
                [void]$cur.Methods.Add($Matches[1])
            } elseif ($line -match '^\s*public\s+(static\s+)?(?:let|var|const)\s+(\w+)') {
                [void]$cur.Methods.Add($Matches[2])
            } elseif ($line -match '^\s*public\s+(static\s+)?prop\s+(\w+)') {
                [void]$cur.Methods.Add($Matches[2])
            }
        }
    }
}

# 沿继承链查方法（getPtr/setPos 这类成员常定义在基类或接口里）
function Test-MethodExists {
    param([string]$TypeName, [string]$Method, [hashtable]$Table, $Visited)
    if ($Visited.Contains($TypeName)) { return $false }
    [void]$Visited.Add($TypeName)
    if (-not $Table.ContainsKey($TypeName)) { return $false }
    if ($Table[$TypeName].Methods.Contains($Method)) { return $true }
    foreach ($b in $Table[$TypeName].Bases) {
        if (Test-MethodExists -TypeName $b -Method $Method -Table $Table -Visited $Visited) { return $true }
    }
    return $false
}

# 去掉注释与字符串字面量（含 `"""` 多行字符串），避免文档/文案里的 QXxx 误报
function Get-CodeOnly([string[]]$lines) {
    $result = New-Object 'System.Collections.Generic.List[string]'
    $inBlock = $false
    $inStr = $false
    foreach ($l in $lines) {
        $out = New-Object System.Text.StringBuilder
        $i = 0
        while ($i -lt $l.Length) {
            if ($inBlock) {
                if ($i + 1 -lt $l.Length -and $l[$i] -eq '*' -and $l[$i + 1] -eq '/') { $inBlock = $false; $i += 2 } else { $i += 1 }
                continue
            }
            if ($inStr) {
                if ($i + 2 -lt $l.Length -and $l.Substring($i, 3) -eq '"""') { $inStr = $false; $i += 3 } else { $i += 1 }
                continue
            }
            if ($i + 1 -lt $l.Length -and $l[$i] -eq '/' -and $l[$i + 1] -eq '/') { break }
            if ($i + 1 -lt $l.Length -and $l[$i] -eq '/' -and $l[$i + 1] -eq '*') { $inBlock = $true; $i += 2; continue }
            if ($i + 2 -lt $l.Length -and $l.Substring($i, 3) -eq '"""') { $inStr = $true; $i += 3; [void]$out.Append('""'); continue }
            if ($l[$i] -eq '"') {
                $i += 1
                while ($i -lt $l.Length -and $l[$i] -ne '"') { if ($l[$i] -eq '\') { $i += 1 }; $i += 1 }
                $i += 1
                [void]$out.Append('""')
                continue
            }
            [void]$out.Append($l[$i])
            $i += 1
        }
        [void]$result.Add($out.ToString())
    }
    return $result
}

# ---- 预扫目标范围，收集各文件自身声明的类型（示例项目内部的类型不应被当成「未知类型」）----
$scopeTypes = New-Object 'System.Collections.Generic.HashSet[string]'
$scopeFiles = New-Object 'System.Collections.Generic.List[object]'
foreach ($scopeItem in $Scope) {
    $dir = Join-Path $RootDir $scopeItem
    if (-not (Test-Path $dir)) { continue }
    foreach ($f in (Get-ChildItem -LiteralPath $dir -Recurse -Filter "*.cj" -File)) {
        $rel = Resolve-Path -LiteralPath $f.FullName -Relative
        $skip = $false
        foreach ($pat in $allowFiles) { if ($rel -like "*$pat*") { $skip = $true } }
        if ($skip) { continue }
        [void]$scopeFiles.Add($f)
        foreach ($line in (Get-Content -LiteralPath $f.FullName)) {
            if ($line -match '^\s*(?:public\s+|open\s+|sealed\s+|abstract\s+)*(?:class|interface|struct|enum)\s+([A-Za-z_]\w*)') {
                [void]$scopeTypes.Add($Matches[1])
            }
        }
    }
}

# ---- 扫描目标代码 ----
$violations = New-Object System.Collections.ArrayList
$scanned = 0

foreach ($scopeItem in $Scope) {
    $dir = Join-Path $RootDir $scopeItem
    if (-not (Test-Path $dir)) { continue }
    foreach ($f in (Get-ChildItem -LiteralPath $dir -Recurse -Filter "*.cj" -File)) {
        $rel = Resolve-Path -LiteralPath $f.FullName -Relative
        $skip = $false
        foreach ($pat in $allowFiles) { if ($rel -like "*$pat*") { $skip = $true } }
        if ($skip) { continue }
        $scanned += 1

        $code = Get-CodeOnly (Get-Content -LiteralPath $f.FullName)
        $locals = @{}   # 变量名 -> 类型（按行就近生效）
        $localTypes = New-Object 'System.Collections.Generic.HashSet[string]'  # 本文件自身声明的类型（如测试类）

        for ($i = 0; $i -lt $code.Count; $i++) {
            $line = $code[$i]
            $ln = $i + 1

            # 函数/构造器/类型边界处重置局部变量表——同名变量在不同函数/不同类里含义不同，
            # 跨作用域沿用会造成大规模误报（如字段 e: QTableWidget 与局部 e: QLineEdit 串味）
            if ($line -match '^\s*(?:public\s+|static\s+|private\s+|protected\s+|open\s+|override\s+|redef\s+)*func\s+\w+' -or
                $line -match '^\s*(?:public\s+|static\s+|private\s+)*init\s*\(' -or
                $line -match '^\s*(?:public\s+|open\s+|sealed\s+|abstract\s+)*(?:class|interface|struct|enum)\s+\w+') {
                $locals = @{}
            }

            # (1) 包名。导入可能是 `import cjqt6.pkg.*`（通配）或 `import cjqt6.pkg.Symbol`（符号），
            #     因此先剥掉尾部的大写开头段（符号名），再要求剩余路径**精确**是一个已知包。
            #     注意不能用「前缀匹配」——根包 `cjqt6` 本身存在，前缀匹配会放过 cjqt6.process.* 这类错误。
            if ($line -match 'import\s+(cjqt6\.[\w\.\*]+)') {
                $imp = $Matches[1].TrimEnd('*').TrimEnd('.')
                $parts = New-Object 'System.Collections.Generic.List[string]'
                foreach ($seg in $imp.Split('.')) { [void]$parts.Add($seg) }
                # 注意：必须用 -cmatch（区分大小写）——PowerShell 的 -match 默认忽略大小写，
                # 会把 `process` 也当成「大写开头的符号段」剥掉，从而误判为根包 cjqt6。
                while ($parts.Count -gt 1 -and $parts[$parts.Count - 1] -cmatch '^[A-Z]') {
                    $parts.RemoveAt($parts.Count - 1)
                }
                $pkg = ($parts -join '.')
                if (-not $packages.Contains($pkg) -and -not $allowPackages.Contains($pkg)) {
                    [void]$violations.Add([pscustomobject]@{ File = $rel; Line = $ln; Kind = "包"; Target = $pkg; Detail = "src/ 中不存在该包（原文: import $imp）" })
                }
            }

            # (2) 类型名（本文件自身声明的类型也算存在）
            if ($line -match '^\s*(?:public\s+|open\s+|sealed\s+|abstract\s+)*(?:class|interface|struct|enum)\s+([A-Za-z_]\w*)') {
                [void]$localTypes.Add($Matches[1])
            }
            foreach ($m in $rxType.Matches($line)) {
                $t = $m.Value
                if (-not $types.ContainsKey($t) -and -not $localTypes.Contains($t) -and -not $allowTypes.Contains($t)) {
                    [void]$violations.Add([pscustomobject]@{ File = $rel; Line = $ln; Kind = "类型"; Target = $t; Detail = "src/ 中不存在该公共类型" })
                }
            }

            # (3) 方法名（先校验，再更新局部变量表——保证「就近生效」）
            foreach ($name in @($locals.Keys)) {
                $t = $locals[$name]
                if (-not $types.ContainsKey($t)) { continue }
                foreach ($m in [regex]::Matches($line, [regex]::Escape($name) + '\.(\w+)\s*\(')) {
                    $meth = $m.Groups[1].Value
                    if (-not (Test-MethodExists -TypeName $t -Method $meth -Table $types -Visited (New-Object 'System.Collections.Generic.HashSet[string]'))) {
                        $key = "$t.$meth"
                        if (-not $allowMethods.Contains($key)) {
                            [void]$violations.Add([pscustomobject]@{ File = $rel; Line = $ln; Kind = "方法"; Target = $key; Detail = "局部变量 $name : $t 及其基类上均无该方法" })
                        }
                    }
                }
            }
            foreach ($m in [regex]::Matches($line, '\b(Q[A-Z][a-z][A-Za-z0-9_]*)\.(\w+)\s*\(')) {
                $t = $m.Groups[1].Value
                $meth = $m.Groups[2].Value
                if (-not $types.ContainsKey($t)) { continue }
                if (-not (Test-MethodExists -TypeName $t -Method $meth -Table $types -Visited (New-Object 'System.Collections.Generic.HashSet[string]'))) {
                    $key = "$t.$meth"
                    if (-not $allowMethods.Contains($key)) {
                        [void]$violations.Add([pscustomobject]@{ File = $rel; Line = $ln; Kind = "方法"; Target = $key; Detail = "类型限定调用，该类型及其基类上均无该方法" })
                    }
                }
            }

            # 说明：曾尝试增加「未知类型接收者」检查（抓 ToastType 这类臆造类型），
            # 但枚举常量的限定写法（如 RGB32.value、NonCosmeticDefaultPen.value）会产生
            # 大量误报（实测 92 处），收益不抵维护成本，故不保留。

            # 更新局部变量类型（let/var x = QXxx(...) / let x: QXxx = ...）
            if ($line -match '(?:let|var)\s+(\w+)\s*:\s*(Q[A-Z][a-z][A-Za-z0-9_]*)\s*=') {
                $locals[$Matches[1]] = $Matches[2]
            } elseif ($line -match '(?:let|var)\s+(\w+)\s*=\s*(Q[A-Z][a-z][A-Za-z0-9_]*)\s*\(') {
                $locals[$Matches[1]] = $Matches[2]
            } elseif ($line -match '(\w+)\s*=\s*(Q[A-Z][a-z][A-Za-z0-9_]*)\s*\(') {
                # 再赋值（同名变量换类型）：覆盖，避免串味
                $locals[$Matches[1]] = $Matches[2]
            }
        }
    }
}

# ---- 输出 ----
Write-Host "check-api-usage: 扫描 $scanned 个 .cj 文件（$($Scope -join ', ')）" -ForegroundColor Cyan
Write-Host "符号表: $($types.Count) 个类型 / $($packages.Count) 个包（来自 src/，不含 src/test）" -ForegroundColor Gray

if ($violations.Count -eq 0) {
    Write-Host "API 存在性校验通过：未发现不存在的包 / 类型 / 方法 ✓" -ForegroundColor Green
    exit 0
}

$byFile = $violations | Group-Object File | Sort-Object Name
foreach ($g in $byFile) {
    Write-Host ""
    Write-Host "$($g.Name)" -ForegroundColor Yellow
    foreach ($v in ($g.Group | Sort-Object Line)) {
        Write-Host ("  L{0,-5} [{1}] {2}  ({3})" -f $v.Line, $v.Kind, $v.Target, $v.Detail) -ForegroundColor Red
    }
}

Write-Host ""
$fileCount = ($violations | Select-Object -ExpandProperty File -Unique).Count
Write-Host "合计 $($violations.Count) 处可疑调用，涉及 $fileCount 个文件。" -ForegroundColor Yellow
Write-Host "如为误报，请登记到 scripts\lib\api-usage-allowlist.txt（package:/type:/method:/file:）。" -ForegroundColor Gray

if ($Strict) {
    Write-Host "错误: 存在不存在的 API 引用（-Strict 门禁）" -ForegroundColor Red
    exit 1
}
exit 0
