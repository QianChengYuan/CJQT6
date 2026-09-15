$base = 'C:\CodeTools\cangjie_git\CJQT6\examples\CjMusic'
$env:PATH = "$base\target\release\cjqt6;$base\target\release\bin;$base\target\release\lrc4cj;$base\target\release\charset4cj@cangjie_tpc;C:\Qt\6.10.3\msvc2022_64\bin;C:\CodeTools\cangjie_git\CJQT6\releases\windows-x64;$env:PATH"
$env:CJQT6_ROOT = 'C:\CodeTools\cangjie_git\CJQT6'
$env:QT_QPA_FONTDIR = 'C:\Windows\Fonts'
Set-Location $base

if (Test-Path 'CjMusic_debug.log') { Remove-Item 'CjMusic_debug.log' -Force }

$p = Start-Process -FilePath '.\target\release\bin\main.exe' -PassThru
Write-Output "PID=$($p.Id)"
$p.WaitForExit(8000) | Out-Null
if (-not $p.HasExited) {
    Stop-Process -Id $p.Id -Force
    Write-Output "KILLED_AFTER_8S"
} else {
    Write-Output "EXIT=$($p.ExitCode)"
}
Start-Sleep -Seconds 1
Write-Output "=== LOG ==="
if (Test-Path 'CjMusic_debug.log') {
    Get-Content 'CjMusic_debug.log'
} else {
    Write-Output "NO LOG FILE"
}
