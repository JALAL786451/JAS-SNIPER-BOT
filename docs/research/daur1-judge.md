# Research judge report (1 Nov 2026), on research1/REPORT_for_judge.md
No 2019+ backtest or price computation was run. Sources were read through WebFetch, or from the agent's downloaded PDFs (research1/dl_*). The repo was only read.

## Verdicts
- C1 local pre-holiday x 7 non-US index: KEEP (rank 1). Different events from #59/#67, almost no tuned parameters, daily data, FTMO-safe. The edge is thin and most of it is Japan and HK.
- C2 Gotobi long 03:00 to 09:55 JST: REJECT as the rules are written. There is no evidence after 2020 (Bessho ends Dec 2020), so it fails the <=H1 rule. It is the only intraday idea worth a waiver: KEEP only if the Chief or user explicitly waives that rule (rank 2).
- C3 Gotobi short after the fix: REJECT. It is a single 3-year preprint, and the conditional short also works on non-Gotobi days (PF 1.20), so it is mostly the generic post-fix reversal, which KMW show decaying. The 12:00 exit and the 09:00 filter are ad hoc. Fold it into C2 later if C2 passes.
- C4 BTC 21-23 UTC: REJECT. The hour was picked from 24, in-sample, with no costs, and 2022-23 was "rough". FTMO's crypto commission of 0.0325%/side (0.065% RT, VERIFIED) is about 70-80% of the gross ~0.08-0.09%/trade. Entry falls on the rollover. TALAASH data runs only May 2017 to 2018.
- C5 oil D-5 to D-1 before US holidays: REJECT. The window was chosen from a D-5..D+5 plot on 2006-2024, which includes IMTIHAN. It comes from a blog, with no costs and no OOS. Dukascopy oil starts in 2013, which gives about 55 trades (<100). Holidays that fall on a Friday give a Friday-close entry, which clashes with FTMO's gap rule. Oil has tail risk (#69).
- C6 FX fix W: REJECT. KMW find net returns negative at full spread, below 5%/yr by 2018-19, and no evidence after 2020. The agent also rejected it.

(details in the handback message)
