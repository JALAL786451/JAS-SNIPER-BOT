@echo off
REM JAS_DATA_BG g2 (29 Oct 2026; g2: 'pehle se chal raha' asli window se, flag se nahi) - sab data PEECHHE (background): low priority, chhoti (minimized) window, aap kaam karte rahein.
REM Kahan rakhein: QDM ke folder mein (jahan qdmcli.exe hai) - ya kahin bhi (Desktop\JAS). Bas double-click.
REM 1) qdmcli.exe mila (is file ke saath ya C:\QuantDataManager) aur QDM ki window band = QDM se update + export, ek ek symbol.
REM 2) jo QDM se na bana (qdmcli nahi / free version / QDM khula) = tools/duka_get.py d4 se seedha Dukascopy, aahista.
REM Nateeja: D:\JAS_DATA\<INSTRUMENT>\<INSTRUMENT>_H1.zip, _M1_<saal>.zip (D: na ho to C:\JAS_DATA) - har file mukammal hote hi.
REM Hadd: QDM ka apna database bahar se nahi likh sakte - Dukascopy wali file QDM ke andar nahi dikhti, sirf JAS_DATA mein.
REM Ruk jaye / laptop band = dobara double-click: bani hui file chhor kar wahin se aage. Log: JAS_DATA\log.txt
setlocal
if /i "%~1"=="run" goto run
title JAS_DATA_BG g1
set URL=https://raw.githubusercontent.com/JALAL786451/JAS-SNIPER-BOT/claude/jas-desk-v3-0110-yu3w2h/tools/duka_get.py

set BASE=D:\JAS_DATA
mkdir "%BASE%" 2>nul
if not exist "%BASE%\" set BASE=C:\JAS_DATA
mkdir "%BASE%" 2>nul
if not exist "%BASE%\" (
  echo %BASE% nahi bana - is file ko kisi aur folder mein rakh kar chalayein.
  pause
  exit /b 1
)
set WORK=%BASE%\_kaam
set FLAG=%WORK%\chal_raha.txt
set LOG=%BASE%\log.txt
mkdir "%WORK%" 2>nul

REM pehle se chal raha? (peechhe wali "JAS_DATA_BG.bat run" window zinda hai)
powershell -NoProfile -Command "if(Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'cmd.exe' -and $_.CommandLine -match 'JAS_DATA_BG\.bat\W+run' }){exit 1}"
if errorlevel 1 (
  echo JAS_DATA_BG pehle se chal raha hai - taskbar par chhoti window dekhein. Kuch karne ki zaroorat nahi.
  pause
  exit /b 0
)
for /f %%Y in ('powershell -NoProfile -Command "(Get-Date).Year"') do set YEAR=%%Y

REM QDM
set QDM=
set QDMGUI=
if exist "%~dp0qdmcli.exe" set QDM=%~dp0
if not defined QDM if exist "C:\QuantDataManager\qdmcli.exe" set QDM=C:\QuantDataManager\
tasklist /fi "imagename eq QuantDataManager.exe" 2>nul | find /i "QuantDataManager.exe" >nul && set QDMGUI=1

REM Python + duka_get d4
set PY=
py -3 -c "import lzma" >nul 2>&1 && set PY=py -3
if not defined PY python -c "import lzma" >nul 2>&1 && set PY=python
if not defined PY if not defined QDM (
  echo Na qdmcli.exe mila na Python. Python abhi winget se install karoon? ^(~2 minute^)
  choice /c YN /m "Y = haan, N = nahi"
  if errorlevel 2 exit /b 1
  winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements
  echo Python install ho gaya. Ye window band kar ke JAS_DATA_BG.bat DOBARA double-click karein.
  pause
  exit /b 0
)
set DUKA=
if defined PY (
  curl -sSL -o "%WORK%\duka_get.new" %URL% && move /y "%WORK%\duka_get.new" "%WORK%\duka_get.py" >nul
  if exist "%WORK%\duka_get.new" del "%WORK%\duka_get.new"
  if exist "%~dp0duka_get.py" findstr /c:"per-folder" "%~dp0duka_get.py" >nul && copy /y "%~dp0duka_get.py" "%WORK%\duka_get.py" >nul
  findstr /c:"per-folder" "%WORK%\duka_get.py" >nul 2>&1 && set DUKA=1
)

echo.
echo Data yahan aayega: %BASE%\^<INSTRUMENT^>\
if defined QDM echo QDM:       %QDM%qdmcli.exe
if not defined QDM echo QDM:       qdmcli.exe nahi mila - sirf Dukascopy
if defined QDMGUI echo           QDM ki window khuli hai - is dafa QDM nahi, sirf Dukascopy. Agli dafa QDM band kar ke chalayein.
if defined DUKA echo Dukascopy: haan - %PY%
if not defined DUKA echo Dukascopy: nahi - Python / duka_get.py nahi
if not defined DUKA if not defined QDM goto none
if not defined DUKA if defined QDMGUI goto none

start "JAS_DATA_BG" /min /low cmd /c ""%~f0" run"
echo.
echo SHURU. Taskbar par chhoti window "JAS_DATA_BG" - use BAND NA KAREIN. Aap apna kaam karte rahein.
echo Laptop jaagta rahega jab tak data aa raha hai ^(lid band na karein^). Haal: %LOG%
timeout /t 30
exit /b 0

:none
echo Kuch chal nahi sakta. QDM band kar ke dobara chalayein, ya Python install karein.
pause
exit /b 1

REM ===================== peechhe wali window =====================
:run
title JAS_DATA_BG g1 - data aa raha hai (band na karein)
echo %date% %time% > "%FLAG%"
echo ===== %date% %time% shuru  QDM=%QDM% GUI=%QDMGUI% PY=%PY% >> "%LOG%"
REM laptop jaagta rahe (sleep nahi) jab tak flag hai aur log 2 ghante ke andar likha gaya - setting nahi badalti
start "" /min powershell -NoProfile -WindowStyle Hidden -Command "$f='%FLAG%'; $g='%LOG%'; $k=Add-Type -Name P -Namespace W -PassThru -MemberDefinition '[DllImport(\"kernel32.dll\")] public static extern uint SetThreadExecutionState(uint e);'; while((Test-Path $f) -and ((Get-Date)-(Get-Item $g).LastWriteTime).TotalHours -lt 2){ [void]$k::SetThreadExecutionState([uint32]2147483649); Start-Sleep 60 }"

set FMT=format=Custom cIncludeHeader=true cHeader=Date,Time,Open,High,Low,Close,Volume cFormat=[Date:yyyyMMdd],[Time:HH:mm:ss],[Open],[High],[Low],[Close],[Volume]
set H1_LIST=USA30.IDX/USD USSC2000.IDX/USD DEU.IDX/EUR GBR.IDX/GBP FRA.IDX/EUR EUS.IDX/EUR JPN.IDX/JPY AUS.IDX/AUD HKG.IDX/HKD ESP.IDX/EUR NLD.IDX/EUR CHE.IDX/CHF CHI.IDX/USD LIGHT.CMD/USD BRENT.CMD/USD GAS.CMD/USD COPPER.CMD/USD XPTUSD XPDUSD COCOA.CMD/USD COFFEE.CMD/USX SUGAR.CMD/USD COTTON.CMD/USX SOYBEAN.CMD/USX EURUSD GBPUSD USDJPY AUDUSD USDCAD USDCHF NZDUSD EURJPY GBPJPY EURGBP AUDJPY EURCHF BTCUSD ETHUSD XAUUSD XAGUSD USA500.IDX/USD USATECH.IDX/USD
set M1_LIST=USA500.IDX/USD USATECH.IDX/USD USA30.IDX/USD DEU.IDX/EUR
set QFAIL=
if defined QDM if not defined QDMGUI call :qdm_all
if defined QDM if not defined QDMGUI if not defined QFAIL goto done
if defined DUKA call :duka_all

:done
del "%FLAG%" 2>nul
echo ===== %date% %time% khatam >> "%LOG%"
echo.
echo KHATAM. %BASE% mein har instrument ka folder. Adhoora / NAHI HUA: %LOG%
echo GitHub ^(branch claude/jas-desk-v3-0110-yu3w2h^): _H1.zip -^> data/duka/H1, _M1_ -^> data/duka/M1
pause
exit /b 0

:qdm_all
for %%S in (%H1_LIST%) do call :q %%S H1 H1 ""
for %%S in (%M1_LIST%) do for /L %%Y in (2021,1,%YEAR%) do call :q %%S M1 M1_%%Y "datefrom=%%Y.01.01 dateto=%%Y.12.31"
exit /b 0

REM :q <QDM symbol> <TF> <tag> "<tareekh>"  ->  %BASE%\<N>\<N>_<tag>.zip  (N = symbol bina . aur /)
:q
set N=%~1
set N=%N:.=%
set N=%N:/=%
set Z=%BASE%\%N%\%N%_%3.zip
if exist "%Z%" if /i not "%3"=="M1_%YEAR%" exit /b 0
echo %date% %time% > "%FLAG%"
echo [QDM] %N% %3
echo [QDM] %N% %3 %date% %time% >> "%LOG%"
"%QDM%qdmcli.exe" -data action=update symbols=%1 >> "%LOG%" 2>&1
if exist "%WORK%\q" rd /s /q "%WORK%\q"
"%QDM%qdmcli.exe" -data action=export symbols=%1 timeframe=%2 %~4 %FMT% outputdir=%WORK%\q >> "%LOG%" 2>&1
set GOT=
for /r "%WORK%\q" %%F in (*.csv) do set GOT=%%F
if not defined GOT (
  echo     NAHI HUA - baad mein Dukascopy se
  echo NAHI HUA: %N% %3 >> "%LOG%"
  set QFAIL=1
  exit /b 0
)
move /y "%GOT%" "%WORK%\q\%N%_%3.csv" >nul
powershell -NoProfile -Command "Compress-Archive -LiteralPath '%WORK%\q\%N%_%3.csv' -DestinationPath '%WORK%\q\%N%_%3.zip' -Force" >> "%LOG%" 2>&1
if not exist "%WORK%\q\%N%_%3.zip" (
  echo ZIP NAHI BANI: %N% %3 >> "%LOG%"
  set QFAIL=1
  exit /b 0
)
mkdir "%BASE%\%N%" 2>nul
move /y "%WORK%\q\%N%_%3.zip" "%Z%" >nul
timeout /t 20 /nobreak >nul
exit /b 0

:duka_all
set /a R=0
:dloop
set /a R+=1
echo %date% %time% > "%FLAG%"
echo [Dukascopy] daur %R% - %date% %time%
%PY% "%WORK%\duka_get.py" h1 --per-folder --out "%BASE%" >> "%LOG%" 2>&1
set E1=%errorlevel%
%PY% "%WORK%\duka_get.py" m1 --per-folder --out "%BASE%" >> "%LOG%" 2>&1
set E2=%errorlevel%
%PY% "%WORK%\duka_get.py" h1 XAUUSD XAGUSD USA500IDXUSD USATECHIDXUSD --per-folder --out "%BASE%" >> "%LOG%" 2>&1
set E3=%errorlevel%
if "%E1%%E2%%E3%"=="000" exit /b 0
if %R% GEQ 30 exit /b 1
echo     kuch reh gaya ^(server ne roka^) - 2 minute baad wahin se
timeout /t 120 /nobreak >nul
goto dloop
