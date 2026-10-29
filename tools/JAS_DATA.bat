@echo off
REM JAS_DATA b1 (29 Oct 2026) - EK CLICK: docs/qdm-data-list.md ka sab data (36 H1 all time + 4 index M1 2021-aaj)
REM seedha Dukascopy se (tools/duka_get.py). QDM ki zaroorat nahi. Beech mein ruk jaye / band ho jaye = dobara
REM double-click: jo file aa chuki hai (cache) wahin se aage. Nateeja: is file ke saath JAS_DATA folder.
setlocal
cd /d "%~dp0"
title JAS_DATA b1
set URL=https://raw.githubusercontent.com/JALAL786451/JAS-SNIPER-BOT/claude/jas-desk-v3-0110-yu3w2h/tools/duka_get.py
set OUT=%~dp0JAS_DATA

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

echo [3/3] Download shuru. Laptop ko SLEEP na hone dein. Ghante lag sakte hain.
set /a N=0
:loop
set /a N+=1
echo.
echo ===== Daur %N% =====
%PY% duka_get.py h1 --out "%OUT%"
set E1=%errorlevel%
%PY% duka_get.py m1 --out "%OUT%"
set E2=%errorlevel%
if "%E1%%E2%"=="00" goto done
if %N% GEQ 30 goto stuck
echo Kuch file reh gayin (server ne roka). 2 minute baad wahin se dobara...
timeout /t 120 /nobreak >nul
goto loop

:done
echo.
echo SAB MUKAMMAL. %OUT% mein H1 aur M1 folder hain.
echo GitHub: branch claude/jas-desk-v3-0110-yu3w2h - data/duka/H1 aur data/duka/M1 mein zip upload karein.
start "" "%OUT%"
pause
exit /b 0

:stuck
echo.
echo 30 daur ke baad bhi kuch adhoora. Baad mein ye file dobara chalayein - wahin se shuru hogi.
pause
exit /b 1
