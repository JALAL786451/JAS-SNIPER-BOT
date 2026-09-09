# Pine → MQL5 Bridge Notes

Source: SMC Coach — Pro v2 (1090-line Pine Script) → `FishingLotsEA_v3.mq5`

The EA does not try to be the whole indicator. It only needs the
hold-vs-hedge decision, not the full visual and analysis toolkit.

## What was ported

**FVG (3-candle gap)** — direct port, same formula:

- Bull: `low > high[2]`
- Bear: `high < low[2]`

**LGB / liquidity grab** — direct port of the sweep logic, using the most
recent CONFIRMED pivot high or low (`InpPivotLR` bars each side, default 3,
matching the script's "Pivot L/R" input):

- SweepBuy grabs buy-side liquidity: `high > lastPivotHigh AND close < lastPivotHigh`
- SweepSell grabs sell-side liquidity: `low < lastPivotLow AND close > lastPivotLow`

Both legs are checked on the same bar, which is what the Pine source does.

**Pivots** — strict on both sides, matching `ta.pivothigh` and `ta.pivotlow`.
A neighbouring bar that merely equals the candidate disqualifies it, so a flat
double top is not a pivot. Version 2 used a non-strict test and diverged from
Pine here.

**Trend** — EMA20 versus EMA50, with an optional ADX filter. Version 2's notes
claimed EMA but the code built `MODE_SMA` handles. That was a straight bug and
version 3 uses `MODE_EMA`.

**Signal persistence** — none, matching Pine. The script recomputes its
booleans fresh every bar with no zone tracking, and the visible FVG box is
cosmetic only. `InpSignalWindowBars` defaults to 1, which is exactly faithful.
Raising it to 2 or 3 keeps a signal alive for a few bars, which may match how
the trader actually reads the chart. Worth testing both ways on demo.

## Multi-timeframe

Every detection function takes an explicit `ENUM_TIMEFRAMES`. MQL5's `iHigh`,
`iLow` and `iClose` accept a timeframe natively, so unlike Pine there is no
need for `request.security()` and bit-packing to read another timeframe.

Three timeframe inputs are wired through:

| Input | Controls |
|---|---|
| `InpTrendTF` | the EMA trend and the ADX filter |
| `InpSignalTF` | FVG and liquidity-grab detection |
| `InpStructureTF` | the optional higher-timeframe agreement gate |

All three default to `PERIOD_CURRENT`, and `InpUseHTFGate` defaults to off, so
out of the box the EA behaves exactly like a single-timeframe build. **Which
timeframe should pair with which is still unspecified and needs the trader's
input.** The plumbing is in place so that decision costs a settings change
rather than a code change.

## Hold versus hedge

- In loss, and a sweep or FVG has fired IN THE POSITION'S OWN FAVOUR, the
  drawdown looks temporary, so hold. This is the "LG tag means don't hedge"
  rule from the screenshots.
- In loss, the EMA trend has actually flipped against the position, and no
  favourable signal is present, so the trend change is confirmed and a hedge
  opens at `InpHedgeLotMultiple` times that position's own volume.

## Hedge lifecycle

This is the part version 2 had no answer for. It could open a hedge but had no
rule for closing one.

**A hedge belongs to one specific position.** Direction is derived from the
position being hedged, not from the current trend read in isolation, so it
stays unambiguous once more than one position can be open.

**The pair closes together on combined net result, never leg by leg.** Closing
the hedge alone at its own small target while the original still sits in loss
defeats the reason the hedge was opened. The hedge is sized above 1x precisely
so it can cover the original's loss.

**Chains are tracked per pair, not by one global flag.** Each hedge carries
`HDG#<original ticket>` in its comment, so pairs are rediscovered from live
positions on every tick and survive a restart or a recompile with no saved
state. A newly opened trade is never blocked from hedging just because some
unrelated earlier chain is still open.

**A hedge is never itself hedged.** Single level only.

**Inside a chain the individual profit target and the candle-close stop are
suspended.** Only the basket target and the basket floor apply. Otherwise a
stop firing on one leg would leave the other one naked and the combined
arithmetic would fall apart.

**If the original disappears the hedge is orphaned** and falls back to
standalone management rather than being force-closed at whatever it happens to
sit at. This is logged.

### The basket floor, and why it exists

The design is worth stating plainly because the name understates the risk. At a
2x multiple this is not a hedge that freezes a loss, it is a reverse-and-add:
net exposure flips into the new direction, which is exactly why recovery is
possible at all. A 1x hedge could only ever freeze the loss.

The consequence is that the basket only turns positive if price keeps moving
the new way, and it deteriorates faster than the original alone would have if
price turns back. Worked example on gold, where one lot is one ounce:

```
Original : BUY  0.01 @ 2000
Price now: 1990              -> original P&L = -$10
Hedge    : SELL 0.02 @ 1990

Basket P&L = 1980 - X   (X = current price)

X = 1980  -> basket breakeven
X = 1970  -> basket +$10
X = 2000  -> basket -$20   (unhedged this would have been $0)
```

"Wait until combined is positive" therefore has no natural floor and is the
classic recovery-grid blowup. `InpBasketMaxLossUSD` is a hard floor that
force-closes both legs. It was not part of the original specification, it was
added as a safety requirement, and its default is a placeholder that needs
tuning on demo.

`InpBasketTargetUSD` defaults to 0.0, which honours the stated rule of closing
as soon as the combined result turns positive. Because commission is included
in that number, "positive" already means positive after costs.

## Costs

MQL5 keeps commission on deals, not on positions, so it is summed from history
via `HistorySelectByPosition` and then cached per position. Only the entry
commission exists while a position is open, so `InpAssumeRoundTurn` doubles it
to cover the exit. Without this, a position closed at a nominal profit can be a
net loss once the exit is charged. On gold a two-leg round turn can easily
exceed a fifty-cent target.

## Account type

The whole design assumes a hedging account where opposite positions coexist. On
a netting account the hedge order would silently reduce or reverse the original
position instead, breaking everything above without any visible error. The EA
refuses to start on a netting account unless `InpAllowNettingAccount` is set
deliberately.

## What was intentionally NOT ported

Support and resistance zone boxes and their lifecycle, BOS and CHOCH labels,
the confluence score, the 4H and 1D gate, the DXY filter, the session and
killzone filter, Supertrend, the virtual trade tracker, and the Teacher panel.
These stay in the Pine script for chart reading. Confirmed as deliberate
scoping, not an oversight.

## Input status: confirmed versus placeholder

Be careful not to read every default as a settled decision.

| Input | Status |
|---|---|
| `InpLotSize` 0.01 | confirmed |
| `InpHedgeLotMultiple` 2.0 | confirmed |
| `InpProfitTargetUSD` 0.50 | direction confirmed, exact number to tune on demo |
| `InpSLDistanceUSD` 3.00 | estimated from the indicator's own shown range, to tune |
| `InpMaxTotalVolume` 0.06 | placeholder, never confirmed |
| `InpMaxDailyLossUSD` 20.00 | placeholder, never confirmed |
| `InpBasketMaxLossUSD` 10.00 | placeholder, added as a safety requirement |
| `InpSlippagePoints` 30 | placeholder, tune if orders get rejected |

## Still open

- **Which timeframe pairs with which.** The multi-timeframe plumbing is built
  and defaults to neutral, but the actual pairing is still the trader's call.
- **The Exness demo account's execution mode**, instant or market, which
  decides the filling mode. `SetTypeFillingBySymbol` picks it automatically,
  but this should still be confirmed against the real account.
- **Whether that account is hedging or netting.** The EA now detects this at
  startup instead of assuming.
- **A captured screenshot of a real confirmed-hedge trigger.** Plenty exist for
  the hold case. None yet for the hedge case, so that path has been reasoned
  about but never seen live.

## Testing status

Not compiled. This environment has no MetaEditor, so version 3 has been written
and reviewed by reading, not built. It needs a compile in MetaEditor and a
Strategy Tester run before it goes anywhere near a demo chart.
