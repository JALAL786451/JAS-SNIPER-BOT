# Judge: Koshish #75 TALAASH (2 Nov 2026)

**Verdict: CLEAN, FAIL stands.** Re-run of `c3st_75.py` gives exactly KUL 1729 tr, -0.019R, SE 0.025, Exp-2SE -0.069, gross +0.027R.
Its own checks all pass: engine without filter == #74, mirror diff 0, 44 look-ahead cuts OK.

## Independent re-implementation (scratch only, entry < 2019)
Own 4H bars (NY+7h floored to 4h by time, not session_day/hour groupby), own Supertrend(10,3) written Pine-style
(RMA ATR with SMA seed, nz band carry, dir=1 while atr[1] is na). 4H bar picked by TIME: last 4H bar with start+4h <= signal 2H close
(asserted for every signal). Trade engine and signals reused from #74/#75.
Result: **all 11 markets, 1729/1729 trades identical** (no extra or missing trade). Net -0.0192 (SE 0.0248), Exp-2SE -0.0689.

## Checked, OK
- Look-ahead: 4H bar used always closed by the signal 2H close. When the 2H is the 2nd half of a 4H block, that same 4H bar
  is used (closes at the same moment, allowed); 1st half uses the previous 4H. Time-based and repo's "last H1 idx" mapping agree.
- Patchy index data could make a half-empty 4H bar look closed early, but time-based mapping gives the same trades, so no effect.
- Even at zero cost: gross Exp +0.027R, Exp-2SE -0.023 (clipped +-1.5R: -0.026). No cost/swap change can make it PASS.
- Filter cut N 2409 -> 1729 and moved Exp -0.041 -> -0.019, still well short of the bar.
