@echo off
rem JAS_DRIVE.bat (build d1, 9 Nov 2026) - D:\JAS = GitHub ka taaza copy. 0 token (Claude nahi chalta).
rem Pehli dafa: clone. Baad mein: sirf naya utaro (pull). D:\JAS ke andar khud kuch mat badlein.
set D=D:\JAS
where git >nul 2>&1 || (echo Git nahi mila - Claude ko batayein & pause & exit /b 1)
if not exist "%D%\.git" (
  git clone --depth 1 https://github.com/JALAL786451/JAS-SNIPER-BOT "%D%"
) else (
  git -C "%D%" pull --ff-only --depth 1
)
echo %date% %time% sync done >> D:\JAS_sync_log.txt
echo.
echo JAS_DRIVE d1: D:\JAS taaza hai. Kaam ki list = D:\JAS\KAAM.md
