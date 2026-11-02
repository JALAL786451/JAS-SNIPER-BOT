# Judge: Koshish #74 TALAASH (2 Nov 2026)

**Verdict: CLEAN, FAIL stands.** Re-run of `c3_74.py` gives exactly KUL 2409 tr, -0.041R, Exp-2SE -0.083, gross +0.005R.

## Independent re-implementation (scratch only, entry < 2019)
Own 2H bars (NY+7h floored to 2h), own EMA (SMA seed), own ATR RMA, own swing(5), H1 loop
(gap at open, then SL first, then TP). Result: **all 11 markets, 2409/2409 trades identical** (entry/exit bar, prices, 1R, side, tag).
Own cost: gross +0.0050, cost 0.0255, swap 0.0203, net -0.0408 (SE 0.0212).

## Checked, OK
- ta.ema / ta.atr / ta.crossover / ta.lowest match Pine. TP from signal close, 1R from fill, no flip, next 2H open.
- Timestamps are UTC: XAU daily break is 22 UTC in Jan and 21 UTC in Jul (= 17:00 NY), so 2H blocks line up. No weekend bars.
- Edge cases: only 4 fills beyond SL skipped, 1 TP-gap at the entry bar, 1 'dono', 5 trades exit in 2019+ (entry < 2019, per rule).
- Big R outliers come from gaps or the rule (TP from signal close). Net clipped at +-1.5R = -0.042.
- Even at zero cost: Exp-2SE about -0.037, so no cost or swap change can make it PASS.

## Data note (not a code bug)
JAS_ZIP/US index H1 data is patchy: 8-12 bars/day in 2011-12 and about 15 in 2015-17, so some 2H bars are partial.
Metals alone (24h data): -0.037R. Metals plus index 2013/14/18 only: +0.001R (SE 0.025). Still FAIL.
