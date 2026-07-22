@echo off
REM build_bridge.bat - rebuild native FFI bridge with MSVC + current Qt
REM Called by rebuild_all.ps1 or run manually from CJQT6 root
REM NOTE: keep this file ASCII-only (no non-English chars) so cmd.exe on
REM GBK-locale Windows does not mangle the bytes.

setlocal enabledelayedexpansion

REM --- Find MSVC vcvars64.bat ---
set "VSVARS="
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" (
    set "VSVARS=%ProgramFiles%\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
)
if not defined VSVARS (
    if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" (
        set "VSVARS=%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
    )
)
if not defined VSVARS (
    if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
        set "VSVARS=%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
    )
)
if not defined VSVARS (
    if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat" (
        set "VSVARS=%ProgramFiles%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat"
    )
)
if not defined VSVARS (
    if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat" (
        set "VSVARS=%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
    )
)
if not defined VSVARS (
    echo ERROR: vcvars64.bat not found
    exit /b 1
)

REM --- Find Qt6 msvc dir ---
set "QTDIR="
for %%q in (C:\Qt\6.10.3\msvc2022_64 C:\Qt\6.10.2\msvc2022_64 C:\Qt\6.7.0\msvc2019_64) do (
    if exist "%%q\bin\Qt6Core.dll" (
        if not defined QTDIR set "QTDIR=%%q"
    )
)
if not defined QTDIR (
    echo ERROR: Qt6 msvc not found
    exit /b 1
)
echo Qt: %QTDIR%

REM --- Setup MSVC env and build ---
call "%VSVARS%" >nul 2>&1

cd /d "%~dp0\..\native\build_windows"
REM Force full recompile of bridge: delete both the old artifact AND the
REM CMake-generated object dir, so patched sources / stale Qt headers are
REM never skipped by MSBuild incremental build. (We were burned once by a
REM stale bridge_qml.obj that still imported the missing qt_qFindChild_helper.)
if exist "bin\cjqt6_bridge.dll" del /F "bin\cjqt6_bridge.dll"
if exist "cjqt6_bridge.dir" rmdir /S /Q "cjqt6_bridge.dir"
if exist "CMakeCache.txt" (
    cmake ..\.. -DCMAKE_PREFIX_PATH="%QTDIR%" -DCMAKE_BUILD_TYPE=Release
) else (
    cmake ..\.. -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="%QTDIR%" -DCMAKE_BUILD_TYPE=Release
)
if errorlevel 1 (
    echo ERROR: cmake config failed
    exit /b 1
)

cmake --build . --config Release
if errorlevel 1 (
    echo ERROR: bridge build failed
    exit /b 1
)

REM --- Sync to releases ---
if not exist "..\..\releases\windows-x64" mkdir "..\..\releases\windows-x64"
copy /Y "bin\cjqt6_bridge.dll" "..\..\releases\windows-x64\" >nul
copy /Y "lib\cjqt6_bridge.lib" "..\..\releases\windows-x64\" >nul
echo Bridge synced to releases\windows-x64
exit /b 0
