# Judge: Koshish #71 and #72 (1 Nov 2026)

Re-ran all of them; every recorded number reproduces exactly (68: 64/2 36.3, 83/0 10.8; 71: 66/0, 83/0 14.4; 72: 61/5, 46/25, 38/35, 25/51).

## #71 G2 DXY filter: CLEAN (FAIL stands)
- Weights and signs match ICE (sum |w| = 1).
- No look-ahead. For all 436 XAU and 383 XAG trades, `x[0]-1` is the last H1 of signal block j.
  The DXY block used is the same 4H block in 431/436 (the other 5 are 2003, before DXY data, so kept) and 382/383 (1 block is 3h older).
  The DXY block always closes at or before the gold entry open.
- `up=True` means up: when up, close > close 6 blocks ago 71% of the time; when down, 29%. ftmo71.py:104 stops trades on up. Correct.
- The baseline in ftmo71 is the same as ftmo68: same symbols, grid, trades, costs and risks.

## #72 fx 4H trend: CLEAN (FAIL stands)
- The sed copy has no leftover Tide logic. Only the name `TIDE` and the comment at ftmo72.py:42 remain.
  Costs are 0.75 x 0.0084 / 0.0085 / 0.0149%. Slot keys are unique (fx 41-43). SELL trades are handled correctly in run_cost.
- No JPY or ATR bug. P&L is risk/SL-normalised, so the quote currency cancels. Median SL is 1.75-2.19% of price (minimum 0.77%), and the worst trade is -1.00R.
  Three USDJPY trades checked by hand: SELL SL 166 pips, hit on the first H1 with High >= SL; BUY flip exit +4.10R; SELL flip exit +1.01R.
- Why it fails: before costs fx makes about +0.01R per trade. Cost plus swap is about 0.045-0.049R per trade, because the system is always in the market and notional is about 50x risk.
  All 25 fails at 0.25% are 10% max-loss breaches (no daily-loss fails). The fx book is about -3% in the failing phase. Slow bleed, not a blow-up.

## Bug found (does not change any verdict): swap night count depends on the grid
ftmo53_asli.py:56-59 (also ftmo_test.py:276-282) charges swap once for each CET date that appears in the union grid, not for each calendar night.
2012-18 has 2557 nights. The 11-market grid charges 1936 of them (Sunday 123x). Adding fx adds Sunday 23:00 CET bars, so the 14-market grid charges 2189.
This is the whole cause of 64/2 versus 61/5. With swap off, both grids give an identical 68/0.
I re-ran the tests in a scratch copy that charges swap per calendar night:
#68 64/2 on both grids; #71 CHUNAO 64/2 -> 66/0 PASS, IMTIHAN median 11.4 -> 14.4 FAIL;
#72 baseline 64/2 vs fx 0.25% 49/21 FAIL; #68 IMTIHAN still PASS (83/0, 11.4 vs #53 11.9).
Absolute medians are about 0.5-2 months optimistic. Comparisons inside the same run are fair.

## Data (EURUSD, USDJPY, USDSEK, AUDUSD from QDM)
- Times are UTC. Hourly-return correlation peaks at lag 0 against GBPUSD, USDCHF, NZDUSD and XAUUSD, in both US-DST and standard time, in 2012-14, 2015-18 and 2019-26.
  Sunday/Friday hours match GBPUSD.
- No duplicate times. All bars are on the hour. O/H/L/C are consistent. The only gaps are the New Year 73h gaps, the same as GBPUSD.
- **AUDUSD has no data at all from 2020-01-01 to 2021-01-03.** This does not affect #72 CHUNAO, but fix it before any 2019+ use of AUDUSD.
