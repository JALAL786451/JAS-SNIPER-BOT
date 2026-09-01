<#
    compile.ps1 — MQL5 file(s) ko MetaEditor se compile karta hai aur
    errors ko UTF-8 mein print karta hai (MetaEditor ka log UTF-16 hota hai,
    isi liye seedha parhne par ajeeb characters aate hain).

    Misaal:
        .\tools\compile.ps1
        .\tools\compile.ps1 -File .\TrendMomentumEA.mq5
        .\tools\compile.ps1 -MetaEditor "D:\MT5\metaeditor64.exe"
#>
param(
    [string]$File       = "",   # khali = folder ki saari .mq5 files
    [string]$MetaEditor = "",   # khali = khud dhoondh lega
    [string]$Include    = ""    # MQL5 folder, agar file us ke bahar hai
)

$ErrorActionPreference = "Stop"

function Find-MetaEditor {
    if ($env:METAEDITOR -and (Test-Path $env:METAEDITOR)) { return $env:METAEDITOR }

    $candidates = @(
        "C:\Program Files\MetaTrader 5\metaeditor64.exe",
        "C:\Program Files (x86)\MetaTrader 5\metaeditor64.exe"
    )
    foreach ($c in $candidates) { if (Test-Path $c) { return $c } }

    # Broker ke apne naam se laga hua MT5 (e.g. "Exness MT5")
    foreach ($root in @("C:\Program Files", "C:\Program Files (x86)")) {
        if (Test-Path $root) {
            $hit = Get-ChildItem -Path $root -Filter "metaeditor64.exe" -Recurse -ErrorAction SilentlyContinue |
                   Select-Object -First 1
            if ($hit) { return $hit.FullName }
        }
    }
    return $null
}

if (-not $MetaEditor) { $MetaEditor = Find-MetaEditor }

if (-not $MetaEditor) {
    Write-Host "metaeditor64.exe nahi mila." -ForegroundColor Red
    Write-Host "MT5 install karein, ya raasta khud dein:" -ForegroundColor Yellow
    Write-Host '    .\tools\compile.ps1 -MetaEditor "C:\Program Files\Broker MT5\metaeditor64.exe"'
    exit 2
}

Write-Host "MetaEditor: $MetaEditor" -ForegroundColor DarkGray

$targets = @()
if ($File) {
    $targets += (Resolve-Path $File).Path
} else {
    $targets += Get-ChildItem -Path (Get-Location) -Filter "*.mq5" -File |
                ForEach-Object { $_.FullName }
}

if ($targets.Count -eq 0) {
    Write-Host "Koi .mq5 file nahi mili." -ForegroundColor Yellow
    exit 2
}

$failed = 0

foreach ($src in $targets) {
    $name = Split-Path $src -Leaf
    Write-Host ""
    Write-Host "=== $name ===" -ForegroundColor Cyan

    $log = [System.IO.Path]::ChangeExtension($src, ".log")
    if (Test-Path $log) { Remove-Item $log -Force }

    $argLine = '/compile:"{0}" /log:"{1}"' -f $src, $log
    if ($Include) { $argLine += ' /inc:"{0}"' -f (Resolve-Path $Include).Path }

    $proc = Start-Process -FilePath $MetaEditor -ArgumentList $argLine `
                          -Wait -PassThru -NoNewWindow
    $code = $proc.ExitCode

    if (Test-Path $log) {
        # MetaEditor UTF-16 likhta hai — UTF-8 copy bana do taake har tool parh sake
        $lines = Get-Content -Path $log -Encoding Unicode |
                 Where-Object { $_ -match '\S' }
        $lines | Set-Content -Path "$log.txt" -Encoding UTF8

        $errs  = @($lines | Where-Object { $_ -match ' error ' -or $_ -match 'error[: ]' })
        $warns = @($lines | Where-Object { $_ -match ' warning ' })

        foreach ($l in $lines) {
            if ($l -match ' error ')        { Write-Host $l -ForegroundColor Red }
            elseif ($l -match ' warning ')  { Write-Host $l -ForegroundColor Yellow }
            else                            { Write-Host $l -ForegroundColor DarkGray }
        }

        if ($errs.Count -gt 0) {
            Write-Host "FAIL — $($errs.Count) error, $($warns.Count) warning" -ForegroundColor Red
            $failed++
        } else {
            $ex5 = [System.IO.Path]::ChangeExtension($src, ".ex5")
            $built = if (Test-Path $ex5) { "-> $(Split-Path $ex5 -Leaf)" } else { "" }
            Write-Host "OK — 0 error, $($warns.Count) warning $built" -ForegroundColor Green
        }
    } else {
        Write-Host "Log file nahi bani (exit code $code)." -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
if ($failed -gt 0) {
    Write-Host "$failed file(s) compile nahi huin." -ForegroundColor Red
    exit 1
}
Write-Host "Sab files compile ho gayin." -ForegroundColor Green
exit 0
