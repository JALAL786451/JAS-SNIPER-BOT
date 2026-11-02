# Judge: Koshish #76 CHUNAO (2 Nov 2026)

**Verdict: CLEAN, CHUNAO PASS stands (BTC 0.50%).** Re-run of `ftmo76.py` (CHUNAO only) gives exactly: #68 64 pass / 2 (1/1) / 18,
median 38.5; BTC 0.10 64/2; 0.25 67/1; **0.50 70/0/14, median 26.8**. Kachhua BTC 21 tr, +2.394R gross, first entry 2015-11-27. No 2019+ run.

## Checked, OK
- CSV: skiprows=1 skips the URL line; unix all in seconds (no ms rows), matches `date` col, no duplicates, all 00:00 UTC, OHLC sane,
  no gap before 2019. Sorted before splice; assert monotonic + unique passes.
- Splice 2017-05-08: Bitstamp 05-07 bar ends 05-08 00:00, Duka H1 starts 05-08 00:00 (open 1554 vs 1555). No overlap/gap.
- Daily bar 00:00 UTC = 19/20:00 NY prev day -> session_day = same UTC date; Sat+Sun+Mon bars fold into Monday, close = Mon bar close
  (Tue 00:00 UTC). Entry = c[t] at index last[t]+1 = next bar's 00:00 open (same moment), SL check starts at entry bar
  (whole-day low incl. entry day = conservative). Exit min(open, sl) fine. 11/21 trades pre-splice; one spans splice (index-based, OK).
- #68 baseline: ftmo68 own grid = 64/1/1/18 med 38.5; with BTC timestamps in grid (and ftmo53 run_cost) = identical. (Doc's 36.3 is an older number.)
- Swap per market via swap[mi] (BTC 20%, rest 3%), cost BTC 0.05%; slot keys 30+mi unique (assert passes).

## Possible leak tested
Daily BTC bar at its 00:00 stamp marks eq with that day's CLOSE (future) and its low only once. Conservative re-run (scratch): every grid
point inside a pre-splice daily bar gets day low/high for worst and OPEN for eq -> 0.50% still **70/0/14, median 26.8**. No effect.
