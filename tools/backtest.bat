@echo off
REM MT5 Strategy Tester — misaal:  tools\backtest.bat TrendMomentumEA
setlocal
if "%~1"=="" (
    echo Istemal: tools\backtest.bat ^<ExpertName^>
    echo Misaal : tools\backtest.bat TrendMomentumEA
    exit /b 2
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0backtest.ps1" -Expert "%~1"
exit /b %ERRORLEVEL%
