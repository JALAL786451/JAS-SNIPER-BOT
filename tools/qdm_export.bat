@echo off
REM qdm_export q1 (29 Oct 2026) - QDM se ek command mein sab data: docs/qdm-data-list.md (38 H1 + 4 index M1).
REM Chalao:  tools\qdm_export.bat test   (pehle sirf EURUSD H1 - file dekh lo)
REM          tools\qdm_export.bat        (sab: update + export + zip; ghante lag sakte)
REM QDM band rakho (GUI khula ho to CLI data file par atak sakta hai).

set QDM=C:\QuantDataManager
set OUT=%USERPROFILE%\Desktop\JAS_DATA
set FMT=format=Custom cIncludeHeader=true cHeader=Date,Time,Open,High,Low,Close,Volume cFormat=[Date:yyyyMMdd],[Time:HH:mm:ss],[Open],[High],[Low],[Close],[Volume]

set H1_INDEX=USA30.IDX/USD USSC2000.IDX/USD DEU.IDX/EUR GBR.IDX/GBP FRA.IDX/EUR EUS.IDX/EUR JPN.IDX/JPY AUS.IDX/AUD HKG.IDX/HKD ESP.IDX/EUR NLD.IDX/EUR CHE.IDX/CHF CHI.IDX/USD
set H1_COMMODITY=LIGHT.CMD/USD BRENT.CMD/USD GAS.CMD/USD COPPER.CMD/USD XPTUSD XPDUSD COCOA.CMD/USD COFFEE.CMD/USX SUGAR.CMD/USD COTTON.CMD/USX SOYBEAN.CMD/USX
set H1_FOREX_CRYPTO=EURUSD GBPUSD USDJPY AUDUSD USDCAD USDCHF NZDUSD EURJPY GBPJPY EURGBP AUDJPY EURCHF BTCUSD ETHUSD
set M1_INDEX=USA500.IDX/USD USATECH.IDX/USD USA30.IDX/USD DEU.IDX/EUR

if not exist "%QDM%\qdmcli.exe" (
  echo qdmcli.exe nahi mila: %QDM%  - is file mein "set QDM=" ko apne QDM folder par badlein.
  pause
  exit /b 1
)
cd /d "%QDM%"
if not exist "%OUT%" mkdir "%OUT%"
set LOG=%OUT%\log.txt
echo qdm_export q1 %date% %time% > "%LOG%"

if /i "%1"=="test" (
  call :h1 EURUSD test
  echo.
  echo TEST khatam. %OUT%\test mein EURUSD ki CSV kholein: pehli line "Date,Time,Open,High,Low,Close,Volume" honi chahiye.
  pause
  exit /b 0
)

for %%S in (%H1_INDEX%) do call :h1 %%S H1_index
for %%S in (%H1_COMMODITY%) do call :h1 %%S H1_commodity
for %%S in (%H1_FOREX_CRYPTO%) do call :h1 %%S H1_forex_crypto
for %%S in (%M1_INDEX%) do call :m1 %%S

echo Zip bana raha hoon...
for %%D in (H1_index H1_commodity H1_forex_crypto) do (
  powershell -NoProfile -Command "Compress-Archive -Path '%OUT%\%%D\*' -DestinationPath '%OUT%\%%D.zip' -Force"
)
for %%D in (M1_2021_24 M1_2025_aaj) do (
  powershell -NoProfile -Command "Get-ChildItem '%OUT%\%%D\*.csv' | ForEach-Object { Compress-Archive -Path $_.FullName -DestinationPath ('%OUT%\' + $_.BaseName + '_%%D.zip') -Force }"
)
echo.
echo KHATAM. %OUT% mein .zip files GitHub data/qdm/ par upload karein. Masle: %LOG%
pause
exit /b 0

:h1
echo [H1] %1
"%QDM%\qdmcli.exe" -data action=update symbols=%1 >> "%LOG%" 2>&1
"%QDM%\qdmcli.exe" -data action=export symbols=%1 timeframe=H1 %FMT% outputdir=%OUT%\%2 >> "%LOG%" 2>&1
if errorlevel 1 echo NAHI HUA: %1 H1 >> "%LOG%"
exit /b 0

:m1
echo [M1] %1
"%QDM%\qdmcli.exe" -data action=update symbols=%1 >> "%LOG%" 2>&1
"%QDM%\qdmcli.exe" -data action=export symbols=%1 timeframe=M1 datefrom=2021.01.01 dateto=2024.12.31 %FMT% outputdir=%OUT%\M1_2021_24 >> "%LOG%" 2>&1
if errorlevel 1 echo NAHI HUA: %1 M1 2021-24 >> "%LOG%"
"%QDM%\qdmcli.exe" -data action=export symbols=%1 timeframe=M1 datefrom=2025.01.01 %FMT% outputdir=%OUT%\M1_2025_aaj >> "%LOG%" 2>&1
if errorlevel 1 echo NAHI HUA: %1 M1 2025-aaj >> "%LOG%"
exit /b 0
