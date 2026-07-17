@echo off
set "QT_DIR=C:\Qt\6.10.2\mingw_64\bin"
set "BRIDGE_DIR=%~dp0..\..\releases\windows-x64"
set "PATH=%QT_DIR%;%BRIDGE_DIR%;%PATH%"
cjpm run
