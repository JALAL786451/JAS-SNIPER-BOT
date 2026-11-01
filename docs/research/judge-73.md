# Judge: Koshish #73 TALAASH (1 Nov 2026)

**Verdict: small BUG, FAIL stands.** `ftmo73.py` re-run = 226 tr -0.004R exactly. Corrected: **KUL 228 tr -0.0032R (Exp-2SE -0.093) = FAIL.**

## BUG: tarjeeh applied after the trades are made (sell73.py:94 + 98-111)
1. A skipped/cut S2 still blocks new S2 until its raw exit (`j = jj + 1`); a real EA re-checks next day.
   Missed: USTEC 2012-12-27 +0.268R -> KUL 227 tr -0.0032R.
2. :105/:107 compare H1 indices, but S2/B2 happen at the previous bar's close (idx = next H1), so a trend BUY
   opening at bar `ei` counts as open at the S2 entry (should be: S2 opens, cut at that open). Missed: US500 2018-12-26 -0.008R.

Event-driven rerun (BUYs checked live, exact times) changes only these 2. S1 identical in all 4 markets.

## Clean
- Mirror: negated prices give identical trades. S1: XAU 437, XAG 384, US500 288, USTEC 300. S2: US500 94, USTEC 92.
- Spread: BUY and SELL both pay 0.75 x spread per side (consistent). SL on ASK: 0 trades change. No TALAASH SELL hits SL
  (all exit by flip, IBS/time or cut); worst bid excursion 0.953R vs spread <= 0.004R. Rollover spikes: not visible in H1 bid data.
- Gate: all 1409 flip-downs vs an independent version: 0 mismatches, no close after the entry bar. A naive cut at L gives 48
  mismatches, all where the signal block is not the day's last (partial day) = the 3/200 artifact.
- Tarjeeh: S1 on metals never skipped/cut; every S1 entry = B1 exit at the same open, correctly allowed (b1 == ei).
  S2: 26 skipped, 23 cut, all by trend BUYs; cut price = BUY entry open (hand check: US500 2012-11-21).
- Windows: data XAU 2003-05, XAG 2003-08, idx 2012-01-19; 0 trades exit in 2019+.
- net_r: KUL gross +0.018, cost 0.006, swap 0.016. Nights UTC/CET/17:00 NY/fractional: -0.0044/-0.0044/-0.0045/-0.0043.

Note: 2012 idx data covers cash hours only (~9 bars/day; BUY legs use the same data); 4 SELLs come from 2012.
EA note: S1 entry and B1 exit share one open; the SELL EA must not count the closing B1 as open.
