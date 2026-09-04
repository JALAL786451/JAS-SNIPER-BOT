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
| `smc_simple_strategy.pine` | Strategy version of `smc_simple.pine` — same logic, but places orders so TradingView's Strategy Tester can report on it. Unrelated to the EAs |
| `forward_test_log.md` | Demo forward test record — every signal and its outcome, filled in as they happen |
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

## smc_simple_strategy backtest results (XAUUSD, OANDA, TradingView)

Eight tests, one variable at a time, commission 0.30 and slippage 3 set in
Properties. Three of the eight made things worse, which is the point — the
settings below were not reached by accepting every change.

| Change | Profit factor | Verdict |
|---|---|---|
| Baseline: cooldown 8, TP1 50% | 1.108 | thin |
| Cooldown 8 → 20 | 1.097 | worse, reverted |
| TP1 50% → 0% | 1.124 | better |
| Cooldown 8 + TP1 0% | 1.174 | better still |
| HTF filter on (240) | 1.152 | worse, reverted |
| 2H instead of 1H | 1.332 | better |
| 4H, Jan 2023 – Sep 2026 | 1.217 | **the one that matters** |

Two later runs, kept for the lessons rather than the numbers:

| Change | Profit factor | Period | Verdict |
|---|---|---|---|
| 1W chart | 1.594 | Jan 1833 – Aug 2026 | discard, see below |
| 5M chart | 1.122 | Aug 10 – Sep 5 2026 | too short to use |
| 15M chart | 1.292 | Jun 1 – Sep 5 2026 | best fit for a small account |

The weekly run's 1.594 is the best profit factor in this file and the least
trustworthy. Gold was price-fixed at $20.67 until 1933 and $35.00 until 1971,
so most of those 193 years contain no tradeable market at all, and the float
after 1971 is one enormous one-way move that flatters any trend system. The
fixed commission also means the same $0.30 is 1.5% of a trade in 1900 and
0.007% of one today. A high profit factor from the wrong era is worth less
than a low one from the right era.

The 5M run is the honest answer to "does the edge survive on a low
timeframe": 1.122 over 639 trades, with costs set about 2.3x higher than the
real spread. It suggests the edge does not vanish. It proves nothing, because
TradingView's free plan only serves about four weeks of 5M history, and 639
trades from one month all share that month's character.

Across timeframes the profit factor falls away at the bottom: 1.122 on 5M
against 1.292 on 15M and 1.217 on 4H. That is what per-trade cost does to a
thin edge — 5M takes about 24 trades a day and pays the spread on every one.
5M is not worth pursuing. 15M takes about 7 a day, which a person can
actually follow, and its stop of roughly $8 is 1.6% of a $500 account, so it
is the only tested timeframe a small account can carry at a sane risk.

Its three months all sit inside a rising gold market, so the long/short
split still has to be checked before it means anything.

The 4H run is the only one covering three years, so it is the only result not
fitted to the 2025-26 gold rally, and it holds at 1.217 with a 13.56% drawdown
over 275 trades. Settings: 4H chart, cooldown 8, TP1 partial 0, HTF filter off.

Two findings worth keeping. Cutting trade count did not improve quality, so
the edge is uniformly thin rather than diluted by junk signals. And in the
first run BUY made +4,327 while SELL lost -878 — gold trended up throughout,
so a long-only version would backtest beautifully and fail the moment the
trend turned. That is the curve-fit to refuse.

Not validated forward yet. Demo before live.

## Account size decides the timeframe, not preference

Stop distances measured from the script's own signals, against what a 1%
risk per trade requires at Exness's 0.01 lot minimum (1 ounce, so risk in
dollars equals the stop in dollars):

| TF | Stop | Account needed for 1% risk |
|---|---|---|
| 5M | ~$4 (estimated from ATR) | $400 |
| 15M | ~$8 (estimated from ATR) | $800 |
| 1H | $90.27 (measured) | $9,000 |
| 4H | $90.39 (measured) | $9,000 |
| D | $180.48 (measured) | $18,000 |

So the validated 4H configuration cannot be traded on a small account: at
$500 its stop is 18% of the account, and the minimum lot cannot be made
smaller. A small account is forced onto low timeframes, which is exactly
where the evidence is thinnest. That tension is real and should not be
papered over by trading a 4H signal at a size the account cannot carry.

## What cannot be done in a cloud session

Claude Code running on claude.ai/code is a Linux container with no MetaTrader
and a restricted network: `mql5.com`, `tradingview.com` and the Debian package
mirrors are all blocked, so MQL5 cannot be compiled and Pine cannot be run
there. In that case say so plainly instead of implying the code was verified,
and review the source by hand.

## Why a signal appears on 1M but not on 1H (asked more than once)

`sigBuy`/`sigSell` in `smc_simple.pine` are gated on `barstate.isconfirmed`, so
a signal only exists once the chart's candle has closed. On 1M that is a
one-minute wait; on 1H it is up to an hour, and on 4H up to four. A live
candle that currently looks like a huge bearish bar is not a signal yet, and
may not be one when it closes.

Do not remove that gate to make higher timeframes fire sooner. Without it the
signal repaints — it can appear mid-candle and vanish when the candle closes
green — and every backtest number in this file was produced from closed bars,
so they would no longer describe the script.

Two settings scale with the timeframe for the same reason: `coolBars = 8` is
eight minutes on 1M and eight hours on 1H, and `pivLen = 5` means a new swing
is confirmed five bars later, i.e. five hours on 1H. Fewer signals on a higher
timeframe is the intended behaviour: the validated 4H run took 275 trades in
about three years, roughly one every four days.

## TradingView candles do not match the broker's, and cannot be made to

Signals are developed and backtested on `OANDA:XAUUSD`; the user trades
Exness `XAUUSDm`. Exness is not on TradingView, so the two feeds can never be
made identical. Two separate effects produce the mismatch, and the user has
already noticed it as "the same candle is blue here and red on my phone":

1. **Different feed.** OANDA and Exness quote slightly different prices, so
   open and close can land on opposite sides of each other.
2. **Different candle boundaries.** MT5 aligns intraday candles to the
   broker's server midnight (Exness is GMT+3); TradingView aligns forex
   candles to its own session start. On 1H and below the hour lines coincide
   and the effect is small. On 4H and 1D the two charts are cutting different
   spans of time, so one can be up while the other is down for the same hours.

Setting the TradingView timezone to UTC+3 removes most of the boundary
effect. The feed difference stays. So an entry, SL or TP price that the
indicator prints will not be exactly reachable on the broker, and a level can
be hit on one chart and not the other. Measuring that gap is one of the real
reasons to forward test on demo before risking money.

When the user reports a discrepancy, compare OHLC numbers, not candle colours.
