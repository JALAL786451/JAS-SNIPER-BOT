# JAS-SNIPER-BOT

TradingView Pine Script tools for SMC-based intraday and scalp trading.

## Contents

| File | Description |
|---|---|
| [`indicators/smc_coach_pro_v2.pine`](indicators/smc_coach_pro_v2.pine) | **SMC Coach — Pro v2.** Zones (BOS/CHOCH) + FVG/LGB + Supertrend + HTF confluence, with a risk engine (SL/TP/RR/position size), a 0-100 confluence score, a virtual performance tracker, alerts, and a 1m→1W dashboard. |
| [`indicators/README.md`](indicators/README.md) | Setup guide, settings reference, and ready-made presets (scalp / intraday / swing / crypto). |
| `sniper_backtest.pine` | Original SMA-crossover backtest skeleton. |

## Quick start

1. TradingView → Pine Editor → paste `indicators/smc_coach_pro_v2.pine`
2. Add to chart
3. Pick a preset from [`indicators/README.md`](indicators/README.md#6-presets)
4. Create an alert on `Any alert() function call`, frequency *Once per bar close*

## Disclaimer

These are analysis tools, not trading advice. The on-chart tracker is an
approximation — it ignores spread, slippage, commission and partial fills.
Forward-test on a demo account before risking capital.
