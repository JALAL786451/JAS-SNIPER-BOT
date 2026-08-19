# JAS-SNIPER-BOT

TradingView (Pine Script v5) sniper strategy for **XAUUSD / Gold**: it only takes
engulfing-candle entries that agree with the higher-timeframe trend, and every
trade carries a hard stop, an R-based target and risk-based position sizing.

## Strategy logic

| Stage | Rule |
| --- | --- |
| **1. HTF filter** | Price on the higher timeframe (default `240` / 4H) must close above its EMA (default 50) for longs, below it for shorts. Only closed HTF bars are used (`lookahead_off` + `[1]`), so signals do not repaint. |
| **2. Entry signal** | Bullish engulfing for longs, bearish engulfing for shorts. Optional filters: body must exceed the previous body, and body must be at least `0.3 × ATR` — this drops the small, noisy engulfings. |
| **3. Stop loss** | `Swing` mode (default): beyond the low/high of the signal pair, padded by `0.25 × ATR`. `ATR` mode: `1.5 × ATR` from entry. |
| **4. Take profit** | Fixed multiple of the initial risk — default **2R**. |
| **5. Breakeven** | Once price travels **1R** in favour, the stop moves to entry. |
| **6. Sizing** | Each trade risks a fixed **1% of equity**; contracts are derived from the stop distance and the symbol's point value. |
| **7. Session** | Trades only inside `0700-2000` London time (London + New York hours, when Gold is liquid). |

One position at a time — no pyramiding, no averaging down.

## Files

- `sniper_backtest.pine` — the full strategy, ready to paste into TradingView.

## How to use it

1. Open TradingView → **Pine Editor**.
2. Paste the contents of `sniper_backtest.pine` and click **Add to chart**.
3. Load **XAUUSD** on a **15m or 1H** chart (the HTF filter expects a lower entry timeframe than 4H).
4. Open the **Strategy Tester** tab to see the backtest results.
5. Tune everything from the gear icon → **Settings → Inputs**.

## Inputs at a glance

| Group | Key settings |
| --- | --- |
| 1 · HTF Trend Filter | enable/disable, higher timeframe, EMA length |
| 2 · Engulfing Signal | ATR length, body-vs-previous-body, minimum body size in ATR |
| 3 · Risk Management | stop mode, ATR multiplier, swing buffer, R target, risk %, breakeven trigger |
| 4 · Session & Date | session window, timezone, backtest start/end |

## Alerts

Two alert conditions ship with the script — **Sniper Long** and **Sniper Short** —
so the same signals can be forwarded to a phone or a webhook.

## Notes

- Defaults are a starting point, not a tuned edge. Backtest across several years
  and forward-test on a demo account before risking real money.
- Backtest fills assume `process_orders_on_close = true` with 2 ticks of slippage.
  Real Gold spreads widen around news, so live results will differ.
- Pine Script runs inside TradingView only; it cannot place live orders on a
  broker by itself.
