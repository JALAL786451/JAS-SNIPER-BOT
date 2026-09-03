# JAS-SNIPER-BOT

MetaTrader 5 Expert Advisors and a TradingView Pine strategy, for XAUUSD.

The user is new to trading and reads Roman Urdu more easily than English.
Explain every change in short, plain Roman Urdu / English mix. Always point
toward backtesting and demo before live trading.

## Files

| File | What it is |
|---|---|
| `jas_sniper_ea_v21.mq5` | JAS Sniper EA v2.11 — structure + trend, TP1/TP2/TP3 partials |
| `jas_sniper_v21.pine` | Pine v5 mirror of the above, for TradingView backtests |
| `TrendMomentumEA.mq5` | TrendMomentumEA v1.01 — EMA trend + tick-volume momentum |
| `sniper_backtest.pine` | Old 14/28 SMA crossover. Unrelated to the EAs |
| `smc_coach_pro_v2.pine` | SMC Coach Pro v2 — TradingView indicator (zones, BOS/CHOCH, FVG/LGB, HTF, score, Teacher panel). Unrelated to the EAs |
| `auto_chart_patterns.pine` | Auto Chart Patterns — TradingView indicator (double top/bottom, H&S, triangle/wedge/channel, neckline + measured target). Unrelated to the EAs |
| `smc_simple.pine` | SMC Simple — stripped-down TradingView indicator: S/R zones, FVG, liquidity grab, Buy/Sell with Entry/SL/TP. No oscillators, no dashboards. Unrelated to the EAs |
| `tools/` | Windows compile and backtest automation |

## Hard rules for these EAs

Never add grid, martingale, hedging, or position averaging to any EA here
unless the user asks for it explicitly and by name in the current session.
Every EA holds at most one position at a time.

Never widen a risk limit (risk percent, daily loss cap, max trades, drawdown
cap) on your own initiative. Those defaults are deliberate.

## Compiling (Windows, MT5 installed)

```
tools\compile.bat                    :: har .mq5 compile karo
tools\compile.bat TrendMomentumEA.mq5
```

It finds `metaeditor64.exe` itself, writes `<name>.log` (UTF-16, as MetaEditor
does) plus a UTF-8 `<name>.log.txt`, and prints errors and warnings. Exit code
is non-zero when anything failed to compile. Read the `.log.txt`, fix, re-run,
and repeat until it reports zero errors — do not hand a compile error back to
the user to fix.

For `#include <Trade\Trade.mqh>` to resolve, either keep the source under
`MQL5\Experts\` in the terminal's data folder, or pass the include root:

```
powershell -File tools\compile.ps1 -Include "C:\Users\<you>\AppData\Roaming\MetaQuotes\Terminal\<hash>\MQL5"
```

## Backtesting (Windows, MT5 installed)

```
tools\backtest.bat TrendMomentumEA
powershell -File tools\backtest.ps1 -Expert TrendMomentumEA -Symbol XAUUSD -Period M5 -From 2025.01.01 -Deposit 10000
```

Close MT5 first — the tester runs its own terminal instance and shuts it down
when finished. The HTML report lands in `backtest/`; read it and report net
profit, trade count, win rate, profit factor and max drawdown rather than
asking the user to read it.

Override EA inputs for an experiment without editing the source:

```
powershell -File tools\backtest.ps1 -Expert TrendMomentumEA -Inputs "InpSL_Points=500||InpTP_Points=750"
```

Change one input at a time, so a change in the result can be attributed.

## The user's actual setup (found the hard way — don't re-derive this)

Broker is Exness, demo account, symbol `XAUUSDm`, **3 digits** (1 point =
$0.001) and the spread sits around **$0.26**. So a points-based distance is
ten times smaller than it looks: the old `InpSL_Points = 300` was a $0.30
stop against a $0.26 spread, which is why an eight-month tester run came out
at profit factor 0.69. TrendMomentumEA v1.02 defaults now use 3000/4500.

**Two MT5 data folders exist on that machine.** MetaEditor and MetaTrader do
not always point at the same one, so a file compiled from the folder
MetaEditor shows can be invisible to the running terminal. The only
reliable way to reach the right one is MetaTrader's own **File → Open Data
Folder**; anything reached from MetaEditor's navigator may be the other one.

MT5 also caches an EA's tester inputs under its file name, and "Defaults"
reloads them from the compiled `.ex5`, not from the source. If the Inputs
tab keeps showing stale values after a recompile, check that the `.ex5`
under the terminal's own `MQL5\Experts` actually rebuilt; renaming the file
sidesteps the cache entirely.

## Points vs digits

`InpSL_Points` and similar are in points, and a point depends on the symbol's
digits. On a 3-digit gold feed, 300 points is $0.30 — tight enough that the
broker rejects the order. Always check `SYMBOL_DIGITS` and
`SYMBOL_TRADE_STOPS_LEVEL` before trusting a points-based distance.

## What cannot be done in a cloud session

Claude Code running on claude.ai/code is a Linux container with no MetaTrader
and a restricted network: `mql5.com`, `tradingview.com` and the Debian package
mirrors are all blocked, so MQL5 cannot be compiled and Pine cannot be run
there. In that case say so plainly instead of implying the code was verified,
and review the source by hand.
