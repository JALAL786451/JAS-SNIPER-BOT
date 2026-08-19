# JAS-SNIPER-BOT

Sniper strategy for **XAUUSD / Gold**: it only takes engulfing-candle entries that
agree with the higher-timeframe trend, and every trade carries a hard stop, an
R-based target and risk-based position sizing.

The same model ships twice — once as **Pine Script** for TradingView backtesting,
and once as an **MQL5 Expert Advisor** for Exness MT5 (backtesting *and* live
execution).

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

| File | Platform | Purpose |
| --- | --- | --- |
| `sniper_backtest.pine` | TradingView only | Charting and backtesting |
| `mql5/JAS_Sniper_EA.mq5` | MetaTrader 5 only | Backtesting and live execution on Exness |
| `docs/MT5-SETUP.md` | — | Install, login, and Strategy Tester walkthrough (Roman Urdu) |

Pine Script never compiles in MetaTrader and MQL5 never runs in TradingView —
they are separate ecosystems, so the logic is maintained in both languages.

Note that neither the Exness web terminal nor the Exness mobile app offers
backtesting at all; that only exists in MT5 desktop and TradingView.

## How to use it — TradingView

1. Open TradingView → **Pine Editor**.
2. Paste the contents of `sniper_backtest.pine` and click **Add to chart**.
3. Load **XAUUSD** on a **15m or 1H** chart (the HTF filter expects a lower entry timeframe than 4H).
4. Open the **Strategy Tester** tab to see the backtest results.
5. Tune everything from the gear icon → **Settings → Inputs**.

## How to use it — MetaTrader 5

1. MT5 → **File → Open Data Folder** → `MQL5/Experts/`, and drop `JAS_Sniper_EA.mq5` in.
2. Refresh the **Navigator** panel, open the EA in MetaEditor and press **F7** to compile.
3. Attach it to an **XAUUSD M15 or H1** chart with **Algo Trading** enabled.
4. For backtests use **View → Strategy Tester** (`Ctrl+R`) with *Every tick based on real ticks*.

The EA refuses to start if the HTF filter is not strictly higher than the chart
timeframe, sizes every position from the stop distance and the account equity,
and reads only closed higher-timeframe bars so its signals do not repaint.

Full walkthrough — including Exness login troubleshooting — in
[`docs/MT5-SETUP.md`](docs/MT5-SETUP.md).

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
  broker by itself. Live execution goes through the MQL5 EA.
- The EA's session window is expressed in **broker server time**, not local time.
  Check the clock above Market Watch and adjust the hours accordingly.
- On a cent account the broker's minimum lot (usually 0.01) still applies. If 1%
  of equity works out smaller than that, the EA logs `calculated lot size is zero`
  and skips the trade — raise the risk percentage or switch to fixed lots.
