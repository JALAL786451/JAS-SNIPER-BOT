@echo off
REM JAS_DXY x1 (1 Nov 2026) - EK CLICK: Koshish #71 ke liye sirf 3 forex H1 (EURUSD, USDJPY, USDSEK) Dukascopy se.
REM seedha Dukascopy se (tools/duka_get.py). QDM ki zaroorat nahi. Beech mein ruk jaye / band ho jaye = dobara
REM double-click: jo file aa chuki hai (cache) wahin se aage. Nateeja: is file ke saath JAS_DATA folder.
setlocal
cd /d "%~dp0"
title JAS_DXY x1
set URL=https://raw.githubusercontent.com/JALAL786451/JAS-SNIPER-BOT/claude/jas-desk-v3-0110-yu3w2h/tools/duka_get.py
set OUT=%~dp0JAS_DXY

echo [1/3] duka_get.py GitHub se le raha hoon...
curl -sSL -o duka_get.new %URL% && move /y duka_get.new duka_get.py >nul
if exist duka_get.new del duka_get.new
if not exist duka_get.py (
  echo duka_get.py nahi mili. GitHub se tools/duka_get.py isi folder mein rakhein, phir dobara chalayein.
  pause
  exit /b 1
)

echo [2/3] Python dhoond raha hoon...
set PY=
py -3 -c "import lzma" >nul 2>&1 && set PY=py -3
if not defined PY python -c "import lzma" >nul 2>&1 && set PY=python
if not defined PY (
  echo Python nahi mila. Abhi winget se install karoon? ^(~2 minute, internet^)
  choice /c YN /m "Y = haan, N = nahi"
  if errorlevel 2 (
    echo python.org se Python 3 install karein - "Add python.exe to PATH" tick karein - phir ye file dobara chalayein.
    pause
    exit /b 1
  )
  winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements
  echo.
  echo Python install ho gaya. Ye window band kar ke JAS_DATA.bat DOBARA double-click karein.
  pause
  exit /b 0
)
echo     mila: %PY%

echo [3/3] Download shuru (3 symbol, ~30-60 minute). Laptop ko SLEEP na hone dein.
set /a N=0
:loop
set /a N+=1
echo.
echo ===== Daur %N% =====
%PY% duka_get.py h1 EURUSD USDJPY USDSEK --out "%OUT%"
if "%errorlevel%"=="0" goto done
if %N% GEQ 30 goto stuck
echo Kuch file reh gayin (server ne roka). 2 minute baad wahin se dobara...
timeout /t 120 /nobreak >nul
goto loop

:done
echo.
echo SAB MUKAMMAL. %OUT%\H1 mein 3 zip: EURUSD_H1.zip, USDJPY_H1.zip, USDSEK_H1.zip
echo GitHub: branch claude/jas-desk-v3-0110-yu3w2h - folder data/duka/H1/JAS_ZIP mein ye 3 zip upload karein.
start "" "%OUT%\H1"
pause
exit /b 0

:stuck
echo 30 daur ke baad bhi adhoora. Thori der baad ye file dobara chalayein (cache se wahin se).
pause
exit /b 1
