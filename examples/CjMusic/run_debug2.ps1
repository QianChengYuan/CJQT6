$env:PATH = 'C:\Qt\6.9.1\msvc2022_64\bin;C:\CodeTools\cangjie_git\CJQT6\releases\windows-x64;' + $env:PATH
$env:CJQT6_ROOT = 'C:\CodeTools\cangjie_git\CJQT6'
$env:QT_QPA_FONTDIR = 'C:\Windows\Fonts'
$env:QT_PLUGIN_PATH = 'C:\Qt\6.9.1\msvc2022_64\plugins'

$p = 'C:\CodeTools\cangjie_git\CJQT6\examples\CjMusic\target\release\bin\main.exe'
& $p 2>&1
$LASTEXITCODE