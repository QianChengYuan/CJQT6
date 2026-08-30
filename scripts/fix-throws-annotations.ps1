<#
.SYNOPSIS
    批量补全 throw 所在方法的 /// throws: 异常类型 注释，消除 cjlint G.ERR.01 告警
.DESCRIPTION
    一次性修复脚本。跑 cjlint 收集 G.ERR.01 告警，对每处 throw 找所在方法声明，
    在方法文档注释末尾（或声明前）插入 /// throws: XxxException 说明 行。
    同方法同异常类型去重，从后往前插入避免行号偏移。
.EXAMPLE
    .\scripts\fix-throws-annotations.ps1
#>
param(
    [string]$ProjectRoot = (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))
)

$env:CJQT6_ROOT = $ProjectRoot

# 异常类型 → 说明文案
$exceptionDesc = @{
    "ResourceDisposedException" = "对象已释放或底层 Qt 对象失效时抛出"
    "CreateFailedException"     = "底层 Qt 对象创建失败时抛出"
    "NullPointerException"      = "空指针访问时抛出"
    "IllegalArgumentException"  = "参数非法时抛出"
}

Write-Host "跑 cjlint 收集 G.ERR.01 告警..." -ForegroundColor Cyan
$out = cjlint -f src -c $ProjectRoot 2>&1 | Out-String
$warnings = [regex]::Matches($out, "(.+?\.cj):(\d+):\d+: warning: G\.ERR\.01")
Write-Host "G.ERR.01 告警数: $($warnings.Count)"

# 按文件分组收集 (throw行号)
$fileThrowLines = @{}
foreach ($w in $warnings) {
    $file = $w.Groups[1].Value
    $ln = [int]$w.Groups[2].Value
    if (-not $fileThrowLines.ContainsKey($file)) { $fileThrowLines[$file] = @() }
    $fileThrowLines[$file] += $ln
}

$modifiedFiles = 0
$totalInserted = 0
$unresolved = @()

foreach ($file in $fileThrowLines.Keys) {
    $lines = [System.IO.File]::ReadAllLines($file, [System.Text.Encoding]::UTF8)
    # 收集 (方法声明行号, 异常类型) 去重
    $methodTasks = @{}
    foreach ($ln in $fileThrowLines[$file]) {
        if ($ln -gt $lines.Count) { continue }
        $code = $lines[$ln - 1]
        if ($code -notmatch "throw\s+(\w+Exception)") { continue }
        $exc = $Matches[1]
        # 向上找方法声明行（含 func/init/prop，非注释）
        $methodLn = -1
        for ($i = $ln - 2; $i -ge 0; $i--) {
            $l = $lines[$i]
            if ($l -match '\b(func|init|prop)\b' -and $l -notmatch '^\s*//') {
                $methodLn = $i
                break
            }
        }
        if ($methodLn -eq -1) {
            $unresolved += "$($file):$ln (未找到方法声明)"
            continue
        }
        $key = "$methodLn|$exc"
        if (-not $methodTasks.ContainsKey($key)) {
            $methodTasks[$key] = [PSCustomObject]@{ MethodLine = $methodLn; Exception = $exc }
        }
    }

    if ($methodTasks.Count -eq 0) { continue }

    # 按方法声明行号降序插入（从后往前，避免行号偏移）
    $sorted = $methodTasks.Values | Sort-Object MethodLine -Descending
    $inserted = 0
    foreach ($t in $sorted) {
        $methodLn = $t.MethodLine
        $exc = $t.Exception
        # 向上找文档注释块（连续 ///）
        $commentEnd = -1
        $j = $methodLn - 1
        while ($j -ge 0 -and $lines[$j] -match '^\s*///') {
            $commentEnd = $j
            $j--
        }
        # 检查是否已含该异常 throws
        $hasThrows = $false
        for ($k = $methodLn - 1; $k -ge 0 -and $lines[$k] -match '^\s*///'; $k--) {
            if ($lines[$k] -match "throws:\s*$exc") { $hasThrows = $true; break }
        }
        if ($hasThrows) { continue }
        # 缩进（取方法声明行的前导空格）
        $indent = "    "
        if ($lines[$methodLn] -match '^(\s*)') { $indent = $Matches[1] }
        $desc = $exceptionDesc[$exc]
        if (-not $desc) { $desc = "异常情况时抛出" }
        $throwsLine = "${indent}/// throws: $exc $desc"
        # 插入位置：注释块末尾后，或方法声明前（无注释时）
        $insertAt = if ($commentEnd -ge 0) { $commentEnd + 1 } else { $methodLn }
        # 数组插入
        if ($insertAt -eq 0) {
            $lines = ,($throwsLine) + $lines
        } else {
            $lines = $lines[0..($insertAt - 1)] + ,($throwsLine) + $lines[$insertAt..($lines.Count - 1)]
        }
        $inserted++
    }

    if ($inserted -gt 0) {
        $content = ($lines -join "`n") + "`n"
        $enc = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($file, $content, $enc)
        $modifiedFiles++
        $totalInserted += $inserted
        Write-Host "  ✓ $($file | Split-Path -Leaf)  插入 $inserted 处" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "修改文件数: $modifiedFiles" -ForegroundColor Cyan
Write-Host "插入注释数: $totalInserted" -ForegroundColor Cyan
if ($unresolved.Count -gt 0) {
    Write-Host "未解决 $($unresolved.Count) 处:" -ForegroundColor Yellow
    $unresolved | ForEach-Object { Write-Host "  $_" }
}