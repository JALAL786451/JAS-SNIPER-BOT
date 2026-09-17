@echo off
REM MQL5 compile — PowerShell script ko chalata hai
REM Istemal:  tools\compile.bat            (saari .mq5 files)
REM           tools\compile.bat MyEA.mq5   (sirf ek file)
setlocal
if "%~1"=="" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0compile.ps1"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0compile.ps1" -File "%~1"
)
exit /b %ERRORLEVEL%
