# TrendMomentumEA

MetaTrader 5 Expert Advisor for XAUUSD. One idea only: **EMA trend filter +
tick-volume momentum confirmation**. No grid, no martingale, no hedging.

File: `TrendMomentumEA.mq5` (v1.01)

## Logic

| Step | Timeframe | Rule |
|---|---|---|
| 1. Trend bias | M15 | Close above EMA(50) = buy bias, below = sell bias |
| 2. Momentum | M5, last **closed** candle | Tick volume >= 20-bar average x 1.5, body >= 60% of the candle's range, and candle direction matches the bias |
| 3. Entry | — | Only when step 1 and step 2 agree |

## Risk limits

| Rule | Default |
|---|---|
| Lot size | 0.01 fixed |
| Stop loss | 300 points |
| Take profit | 450 points (~1.5R) |
| Max daily loss | $20 — no new trades that day once hit |
| Max open trades | 1 |
| Max trades per day | 5 |
| Grid / martingale / hedging | Not implemented, by design |

## Install and compile

1. Copy `TrendMomentumEA.mq5` into `MQL5/Experts/` in your terminal's data
   folder (MT5 -> File -> Open Data Folder).
2. Open it in MetaEditor and press **F7** to compile.
3. Attach to an XAUUSD chart and enable Algo Trading.

## Before going live

1. Compile in MetaEditor.
2. Backtest in the MT5 Strategy Tester on 3-6 months of XAUUSD history.
3. Only after reasonable results, run on a **demo** account for 2-4 weeks.
4. Only after that, consider small real-money size. Never skip straight to live.

## Check your SL/TP against your broker

`InpSL_Points` is in **points**, and a point depends on the symbol's digits:

| XAUUSD digits | 1 point | 300 points |
|---|---|---|
| 2 (e.g. 4516.17) | $0.01 | **$3.00** |
| 3 (e.g. 4516.175) | $0.001 | **$0.30** |

On a 3-digit gold feed the default stop is only 30 cents, which most brokers
reject as too tight. On attach the EA prints the real distances and warns if
they are below the broker's minimum; it also widens them automatically so
orders still go through. Read the Experts tab after attaching and set
`InpSL_Points` accordingly.

## v1.01 fixes over v1.00

Logic is unchanged. These were defects in the first version:

- The EMA indicator handle was created and released on every signal check.
  It is now created once in `OnInit` and released in `OnDeinit`.
- `CountOpenTrades()` matched on magic number only, so positions on other
  symbols counted toward the one-trade limit. It now checks the symbol too.
- The first bar after attaching could open a trade immediately off stale
  data. That bar is now skipped.
- SL and TP were sent without checking the broker's minimum stop distance,
  so orders could be rejected outright.
- Order filling mode and slippage were never set, which fails on brokers
  that do not accept the default filling mode.
- `PrintFormat` used `%d` for a `long` tick-volume value and `%.5f` for
  prices regardless of the symbol's digits.
- `price`, `sl` and `tp` were read while possibly uninitialized if the
  direction was neither buy nor sell.
