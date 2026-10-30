@echo off
REM JAS_ZIP z3 (31 Oct 2026; z3: TASHEEH - folder ka naam ZIP_UPLOAD. z2 mein folder "JAS_ZIP" tha aur "start" ne
REM folder ki jagah JAS_ZIP.bat KHUD dobara chala di = chakkar, bohot tab. Ab folder explorer se khulta hai, ek dafa.
REM z2: nakal "(2)" "(3)" aur H1 ke ilawa files khud chhorta hai) - QDM export ki har CSV ki alag zip (GitHub web 25 MB hadd) + D:\JAS_DATA ki _H1.zip bhi,
REM sab EK folder (JAS_ZIP) mein; phir woh folder aur GitHub ka upload page khud khulta hai - sab zip ek saath khench kar chhoro.
REM Kahan rakhein: QDM export wale folder mein (andar ke folders bhi dhoondta hai). Bas double-click.
setlocal
cd /d "%~dp0"
title JAS_ZIP z3
set OUT=%~dp0ZIP_UPLOAD
set URL=https://github.com/JALAL786451/JAS-SNIPER-BOT/upload/claude/jas-desk-v3-0110-yu3w2h/data/duka/H1
echo Zip bana raha hoon... (har file ki alag zip)
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$src = '%~dp0'; $out = '%OUT%'; New-Item -ItemType Directory -Force $out | Out-Null; $n = 0; Get-ChildItem -LiteralPath $src -Recurse -Filter *.csv | Where-Object { $_.FullName -notlike ($out + '*') } | ForEach-Object { $b = $_.BaseName; if ($b -match '\(\d+\)') { Write-Host ('  chhori (nakal): ' + $_.Name) -ForegroundColor DarkGray; return }; if ($b -notmatch '-H1-') { Write-Host ('  chhori (H1 nahi): ' + $_.Name) -ForegroundColor DarkGray; return }; if ($b -match '^\d{4}\.\d{2}\.\d{2}(.+?)-(M1|M5|M15|M30|H1|H4|D1)') { $name = $matches[1] + '_' + $matches[2] } else { $name = $b -replace '[^A-Za-z0-9_]', '_' }; $z = Join-Path $out ($name + '.zip'); Compress-Archive -LiteralPath $_.FullName -DestinationPath $z -Force; $mb = [math]::Round((Get-Item $z).Length / 1MB, 1); Write-Host ('  ' + $name + '.zip  ' + $mb + ' MB'); if ($mb -ge 25) { Write-Host '     25 MB se bari - GitHub web nahi lega!' -ForegroundColor Red }; $n++ }; if (Test-Path 'D:\JAS_DATA') { Get-ChildItem -LiteralPath 'D:\JAS_DATA' -Recurse -Filter '*_H1.zip' | Where-Object { $_.FullName -notlike ($out + '*') } | ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $out -Force; Write-Host ('  ' + $_.Name + '  (D:\JAS_DATA se)'); $n++ } }; Write-Host ''; Write-Host ('KUL ' + $n + ' zip -> ' + $out)"
echo.
echo Ab ZIP_UPLOAD folder aur GitHub ka upload page khul rahe hain (pehle GitHub par Sign in):
echo   folder mein Ctrl+A, sab zip khench kar GitHub page par chhorein, phir neeche "Commit changes".
explorer "%OUT%"
start "" "%URL%"
pause
