@echo off
REM JAS_M1ZIP m1 (31 Oct 2026) - QDM ki M1 export (poori muddat ki EK CSV har symbol) ko SAAL BA SAAL tod kar alag zip
REM (GitHub web 25 MB hadd) -> M1_UPLOAD folder; phir woh folder aur GitHub upload page (data/qdm/M1) khud khulte hain.
REM Kahan rakhein: QDM M1 export wale folder mein (misaal D:\QDM_M1). Bas double-click. Nakal "(2)" files chhor deta hai.
REM Folder ka naam (M1_UPLOAD) is file ke naam se ALAG hai - JAS_ZIP z2 wali chakkar ghalti yahan nahi.
setlocal
cd /d "%~dp0"
title JAS_M1ZIP m1
set OUT=%~dp0M1_UPLOAD
set URL=https://github.com/JALAL786451/JAS-SNIPER-BOT/upload/claude/jas-desk-v3-0110-yu3w2h/data/qdm/M1
echo M1 files saal ba saal tod raha hoon... (bari file = kuch minute)
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$src = '%~dp0'; $out = '%OUT%'; New-Item -ItemType Directory -Force $out | Out-Null; Get-ChildItem -LiteralPath $src -Filter *.csv | Where-Object { $_.Name -match '-M1-' -and $_.Name -notmatch '\(\d+\)' } | ForEach-Object { $b = $_.BaseName; if ($b -match '^\d{4}\.\d{2}\.\d{2}(.+?)-M1') { $sym = $matches[1] } else { $sym = $b -replace '[^A-Za-z0-9]', '_' }; Write-Host ('  ' + $_.Name + ' ...'); $r = [System.IO.StreamReader]::new($_.FullName); $hdr = $r.ReadLine(); $w = @{}; while (($ln = $r.ReadLine()) -ne $null) { if ($ln.Length -lt 4) { continue }; $y = $ln.Substring(0, 4); if (-not $w.ContainsKey($y)) { $w[$y] = [System.IO.StreamWriter]::new((Join-Path $out ($sym + '_M1_' + $y + '.csv'))); $w[$y].WriteLine($hdr) }; $w[$y].WriteLine($ln) }; $r.Close(); foreach ($k in @($w.Keys)) { $w[$k].Close() }; foreach ($k in @($w.Keys)) { $f = Join-Path $out ($sym + '_M1_' + $k + '.csv'); $z = $f -replace '\.csv$', '.zip'; Compress-Archive -LiteralPath $f -DestinationPath $z -Force; Remove-Item -LiteralPath $f; $mb = [math]::Round((Get-Item $z).Length / 1MB, 1); Write-Host ('    ' + (Split-Path $z -Leaf) + '  ' + $mb + ' MB'); if ($mb -ge 25) { Write-Host '      25 MB se bari - GitHub web nahi lega!' -ForegroundColor Red } } }; Write-Host ''; Write-Host ('KHATAM -> ' + $out)"
echo.
echo Ab M1_UPLOAD folder aur GitHub upload page khul rahe hain (GitHub par Sign in hona chahiye):
echo   folder mein Ctrl+A, sab zip khench kar GitHub page par chhorein, phir neeche "Commit changes".
explorer "%OUT%"
start "" "%URL%"
pause
