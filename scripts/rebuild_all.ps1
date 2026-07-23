# rebuild_all.ps1 - rebuild native FFI bridge + CJQT6 subpackages + example
# Run from CJQT6 root: powershell -ExecutionPolicy Bypass -File scripts\rebuild_all.ps1
#
# IMPORTANT ORDER: the native bridge MUST be rebuilt BEFORE `cjpm build`
# links the Cangjie subpackages. The subpackage DLLs link against
# releases/windows-x64/cjqt6_bridge.dll, so any NEW `foreign func qXxx`
# added to the bindings needs the freshly compiled bridge first, or the
# link step fails with "undefined symbol: qXxx".

$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $RootDir
Set-Location $RootDir
Write-Host "Working dir: $RootDir"

# ---- Step 1: find cjpm ----
$cjpm = Get-Command cjpm -ErrorAction SilentlyContinue
if (-not $cjpm) {
    $candidates = @(
        "$env:USERPROFILE\.cangjie\tools\bin\cjpm.exe",
        "C:\CodeTools\cangjie\cangjie_1.1.0\tools\bin\cjpm.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { $cjpm = Get-Command $c; break }
    }
}
if (-not $cjpm) {
    Write-Host "ERROR: cjpm not found in PATH"
    exit 1
}
Write-Host "cjpm found: $($cjpm.Source)"

# ---- Step 2: clean old build artifacts ----
Write-Host "Cleaning old builds..."
if (Test-Path "examples\all_controls_demo\target") {
    Remove-Item -Recurse -Force "examples\all_controls_demo\target"
}
if (Test-Path "target") {
    Remove-Item -Recurse -Force "target"
}

# ---- Step 3: rebuild native FFI bridge FIRST (subpackages link against it) ----
Write-Host "Building native FFI bridge (must precede cjpm build)..."
& "cmd.exe" /c "call `"$RootDir\scripts\build_bridge.bat`""
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: bridge build failed"
    exit 1
}

# ---- Step 4: build cjqt6 subpackages (now links against fresh bridge) ----
Write-Host "Building cjqt6 subpackages..."
& $cjpm build
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: cjpm build failed"
    exit 1
}

# ---- Step 5: build example + deploy Qt ----
Write-Host "Building example all_controls_demo..."
Set-Location "examples\all_controls_demo"
& $cjpm build
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: example build failed"
    exit 1
}

# Deploy Qt runtime
$deployScript = "$RootDir\examples\all_controls_demo\deploy_qt.ps1"
if (Test-Path $deployScript) {
    & $deployScript
}

Write-Host "DONE. Now run: cjpm run"
