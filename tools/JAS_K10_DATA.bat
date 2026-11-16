@echo off
:: JAS_K10_DATA d1 (16 Nov 2026) - K10 demo milaan ke liye: QDM ki screen KHOLE BAGHAIR (qdmcli) 4 symbol update + M1 export (1 Oct 2026 se aaj) + ek zip.
:: QDM ki screen band honi chahiye. Nateeja: Desktop\JAS_K10\JAS_K10_M1.zip  -> chat mein attach karein.
set QDM=C:\QuantDataManager125
if not exist "%QDM%\qdmcli.exe" set QDM=C:\QuantDataManager
set OUT=%USERPROFILE%\Desktop\JAS_K10
set FMT=format=Custom cIncludeHeader=true cHeader=Date,Time,Open,High,Low,Close,Volume cFormat=[Date:yyyyMMdd],[Time:HH:mm:ss],[Open],[High],[Low],[Close],[Volume]
if not exist "%QDM%\qdmcli.exe" (
  echo qdmcli.exe nahi mila: C:\QuantDataManager125 ya C:\QuantDataManager mein. Is screen ka SS bhej dein.
  pause
  exit /b 1
)
cd /d "%QDM%"
if not exist "%OUT%\csv" mkdir "%OUT%\csv"
set LOG=%OUT%\log.txt
echo JAS_K10_DATA d1 %date% %time% > "%LOG%"
for %%S in (USA500.IDX/USD USATECH.IDX/USD XAUUSD XAGUSD) do (
  echo [update + export] %%S  ^(kuch minute lag sakte^)
  "%QDM%\qdmcli.exe" -data action=update symbols=%%S >> "%LOG%" 2>&1
  "%QDM%\qdmcli.exe" -data action=export symbols=%%S timeframe=M1 datefrom=2026.10.01 %FMT% outputdir=%OUT%\csv >> "%LOG%" 2>&1
  if errorlevel 1 echo NAHI HUA: %%S >> "%LOG%"
)
powershell -NoProfile -Command "Compress-Archive -Path '%OUT%\csv\*' -DestinationPath '%OUT%\JAS_K10_M1.zip' -Force"
echo.
echo KHATAM. Ye file chat mein attach karein:  %OUT%\JAS_K10_M1.zip
echo Agar zip khali ho to %LOG% bhi bhej dein.
explorer "%OUT%"
pause
