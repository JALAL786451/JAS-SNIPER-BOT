# Cent-account fast / martingale EA research (2 Nov 2026), data < 2019 only

Short answer: there is no tested 1m/5m/15m edge on gold or US index. A martingale only turns a small negative edge into many small winning days and then a rare large loss. To make a $10-20 median day on $1,000 you would face roughly **80-87% odds per year of losing half the account** (Monte Carlo below). Without martingale, the edges that have already passed give a realistic **$1-2 per day on average**, and the money comes in lumps.

## What I computed (only gold M1 2015 and US500 M1 2012-2018)
Scripts are in `scratchpad/sim/` (`sim.py`, `run.py`, `run2.py`, `mc.py`). Each entry is on an M5 bar, TP = SL (1:1). Costs use the measured Exness spread: gold 0.006% round trip, US500 0.40 pt. When a single M1 bar touches both TP and SL, I count the SL first.

| Test (no martingale) | Trades/day | Win | Exp R +-SE |
|---|---|---|---|
| Gold, EMA20 direction, 07-20h, SL 0.10% | 36 | 50.2% | -0.055 +-0.010 |
| Gold, EMA20 direction, SL 0.25% | 8.6 | 50.1% | -0.018 +-0.021 |
| Gold, Asian 00-06h Bollinger fade, SL 0.25% | 1.9 | 51.6% | +0.009 +-0.045 |
| Gold, alternating direction, SL 0.25% (control) | 8.6 | 50.2% | -0.016 +-0.021 |
| US500, NY 13-20h, direction, SL 0.25% | 5.8 | 50.5% | -0.017 +-0.010 |
| US500, NY session fade, SL 0.10% | 6.9 | 50.3% | -0.064 +-0.009 |

The direction filters do no better than the alternating-direction control. That matches #12 (59.8% win, -0.10R).

## Why martingale cannot create edge
- In a martingale chain every trade has the same expected value per $ risked, Exp R, so the chain's EV = Exp R x (total $ risked).
- With a x2 multiplier, the extra risk is placed after losses. That raises the total $ exposed to a negative Exp but does not change the sign.
- A chain fails when it loses n trades in a row: probability q^n, where q = 1 - p. The loss when it fails is base x (2^n - 1).
- Table of q^n for n = 3..8 steps:
  - p 0.49: 13.3%, 6.8%, 3.45%, 1.76%, 0.90%, 0.46%
  - p 0.50: 12.5%, 6.25%, 3.1%, 1.6%, 0.8%, 0.4%
  - p 0.60: 6.4%, 2.6%, 1.0%, 0.41%, 0.16%, 0.07%
- Example for $10/day: 10 chains/day, $1 base, n = 6. A failed chain costs $63. The chance of at least one failure is 1 - (1 - 0.0176)^10 = 16% per day, or almost every week. The expected failure cost is 10 x 0.0176 x $63 = $11/day, which is more than the $10 gained. Spread makes the result negative.
- One chain per day, n = 5, base $10 (target $10/day): the chain fails on 3.45% of days, about once every 29 trading days. That is a $310 loss, 31% of the account, against about $280 won over those 28 days. That is before spread.
- Monte Carlo (250 days, account stop at $500, daily stop as given, p 0.491 with cost giving about -0.05R per trade):

| Setup | P(lose 50%/yr) | Median day | Worst 5% day |
|---|---|---|---|
| n=5, 4 chains, $2.5 base, daily stop $80 | 80% | +$8.4 | -$81 |
| n=6, 8 chains, $1.25 base, daily stop $80 | 86% | +$8.0 | -$81 |
| n=4, 6 chains, $2 base, daily stop $60 | 82% | +$9.9 | -$55 |
| n=8, 10 chains, $1 base | 87% | +$7.9 | -$79 |
| No martingale, 10 trades x $1.5 | 0% (slow bleed, ends about $781) | -$0.6 | -$9.6 |
| Even with a fair coin (p 0.50, cost 0): n=5 | 22% | +$10 | -$70 |
| Only with a hypothetical p 0.70 at 1:1, which does not exist on <= M15 | 0% | +$10.8 | +$8.5 |

- Real path, gold 2015: SL 0.10%, n = 5 or 6, base $1-1.25 took $1,000 to $0 in about 200 days. At SL 0.25%, n = 6, base $1, the year ended -$127 with a $281 drawdown and a median day of only +$3.2.

## Ranked candidates
| # | Candidate | P(pass strict OOS, real spread) | Ruin risk/yr | Realistic $/day |
|---|---|---|---|---|
| 1 | A: Already-passed basket on cent, fixed risk (no martingale) | High, already passed | ~0 | $1-2 (lumpy) |
| 2 | B: Capped martingale (max 3 steps) on IBS daily US500/USTEC | Medium (base edge +0.07R) | Low-medium | $1-3 |
| 3 | C: Gold Asian M5 Bollinger fade, x2, max 4 steps | Low, ~10% | Medium-high | $1-2 if edge is real |
| 4 | D: Gold M5 1:1 trend chain, x2, max 5-6 steps | ~0 (already = #12) | 80%+ | +$8 median until bust |
| 5 | E: US500 NY M5 1:1 chain | ~0 | 80%+ | negative |
| 6 | F: One-chain-a-day "1%/day" martingale | ~0 | high (31% hit about monthly) | $10 until bust |

### A. Non-martingale comparison: already-passed edges on cent
- Rules: #34 JAS Trend t2 4H basket (XAU, XAG, US500, USTEC) + JasIbsEA i6 + US holiday window, 1% risk per trade.
- Base edge is already proven: #34 IMTIHAN +0.208R over 641 trades; IBS 70% win, +0.07R.
- About 22R/yr at 1% risk = $220/yr, roughly $0.9/day, or $1.8/day at 2% risk.
- Frequency: 0.3-0.5 trades/day.
- Problem: Exness Standard Cent most likely has **no indices**, only forex and metals. Check this in MT5 Market Watch, because if so the cent account gets only the gold/silver legs.

### B. Martingale on an already-tested edge (IBS daily)
- Same IBS signal (close in the bottom of the daily range, exit at the next strong close, as in JasIbsEA). After a loss, the next IBS trade risks 1.5x. Maximum 3 steps (1, 1.5, 2.25% risk), then reset. Account stop at -20%.
- P(3 losses in a row) = 0.3^3 = 2.7% per chain. Losers are larger than winners, so the worst chain is about -4.75% x (average loss / 1R) ≈ -6%.
- It is only around 0.15 trades/day: not fast and not $10/day.
- It must be pre-registered as a new koshish on < 2019 data; IBS 2019+ results have already been seen.
- Martingale here only re-weights an edge that already exists. The Sharpe ratio does not rise.

### C. Gold Asian-session M5 Bollinger fade ("night scalper" family)
- Entry: from 01:00 to 06:00 server time (skip the 23-01h rollover spread), close of the previous M5 bar beyond BB(20,2) -> fade at the next bar's open.
- Exit: TP = SL = 0.25% (about $10 at 4000), 1:1. One position at a time.
- Martingale: x2, maximum 4 steps (15 x base). Daily stop -$60, account stop -$300.
- In 2015: 492 trades (1.9/day), Exp +0.009 +-0.045R. That is noise, not evidence.
- The martingale path in 2015 ended +$129 with an $84 drawdown at a $2 base. That is luck inside one year.
- Night-scalper EAs are a known commercial genre. The independent audits I could find say records are short and leveraged, and buyers report blown accounts ([MQL5 audit of 10 scalping/martingale EAs](https://www.mql5.com/en/blogs/post/777027), [BabyPips martingale thread](https://forums.babypips.com/t/reality-and-misconceptions-on-martingale-forex-strategy/172809), [Bobra Adept thread](https://forums.babypips.com/t/bobra-adept-ea-the-supposed-ed-holy-grail-of-eas/69497)).
- Test it first **without** martingale. It needs Exp - 2SE > 0 on Dukascopy gold M1 2003-2018, otherwise drop it.

### D. Gold M5/M15 1:1 trend chain (the standard "$10/day" EA)
- Entry: EMA20 direction, TP = SL = $4-10. Martingale x2 up to 5-6 steps, 4-10 chains/day.
- Base edge is -0.02 to -0.055R; this is #12 again.
- Monte Carlo ruin is 80-86% a year. It blew up in practice in 2015.
- Do not build it.

### E. US500/USTEC NY M5 chain
- Exp -0.017R to -0.074R after 0.40 pt spread. Indices are likely not on the cent account anyway.
- Reject.

### F. "One chain per day, stop after first win"
- n = 5, base $10. The chain fails about once a month for -$310 (31% of the account), against about +$10 on the other days.
- Spread makes it negative. Reject.

## Verdict
- $10-20/day (1-2%/day, i.e. 250-500%/yr) on $1,000 is **not achievable without high ruin risk**. Every martingale setup that reaches that median sits at roughly 80%+ yearly odds of losing half the account.
- For an honest martingale experiment, test **C first without martingale** (pre-written rule, < 2019).
  - If it passes: run x2, max 4 steps, $1-2 base, daily stop $60, account stop $300 on cent demo, then a small live amount.
  - Expect about $1-3/day.
- The safe path is A at 1-2% risk: about $1-2/day on average.
- Cent spread: unknown; may be wider than Standard. Run JasSpreadNaap on XAUUSDc before any test.


## Head of Department (research judge) faisla, 2 Nov
Code CLEAN (lookahead nahi, SL pehle, MC sahi). Natija sahi: chhoti TF par spread ke baad edge nahi; martingale edge nahi banata; $10-20/din = ~80%+ saal mein aadha account doobe.
KEEP: A (pass shuda edge, fixed risk, ~$1-2/din) > C (gold Asia M5 Bollinger fade, sirf bina-martingale TALAASH 2005-18, 2015 chhor kar, kharcha 0.012% par Exp-2SE>0, dono aadhe musbat, >=60% saal) > B (IBS 1.5x 3 qadam, cent par index shayad nahi).
REJECT: D (gold M5 1:1 chain = #12), E (US500 NY chain), F (roz ek chain).
Exness Standard Cent: zyada review = sirf forex + metals (index nahi) - user MT5 Market Watch mein dekhe.
