# Research daur 5 (1 Nov 2026): SELL mirrors S1/S2 for #68
No backtest, no 2019+ returns. V = fetched 1 Nov · U = unverified · #n = ours.

**Bottom line:** shorts on drifting markets earn mainly in slow bear markets. Pure mirror = likely FAIL.
Pre-register S1 with the daily SMA200 filter (0 new parameters) + S2 as planned. Expect ~+2-3 tr/mo, not +9.

## 1-2. Evidence
| Source | Finding |
|---|---|
| NBIM note 2014, 47 futures 1990-2013 V | most TSMOM profit from LONG signals; short adds value only in FX + commodities; equity futures 1-wk reversal t~-5 |
| Moskowitz-Ooi-Pedersen 2012 V | TSMOM beats always-long in 90% of 58 assets, only 26% significant |
| Huang et al. JFE 2020 V | per-asset TSM weak; result ~ same as a drift (sample-mean) rule |
| Hurst-Ooi-Pedersen 2017 V | + in 8/10 worst 60/40 drawdowns 1880-2016 (bears ~15 mo); not fast crashes (1987) |
| Man AHL 2016 V | no-long equity: more crisis alpha, lower mean |
| Zakamulin 2014, S&P 1926-2012 V | SMA timing gain only from 4 bears; ~80% of out-of-market spells index beat cash (= short loses) |
| Lemperiere et al. 2014 V | trend t~10 since 1800 after drift; SHORT-horizon trends withered |
| Baltussen-vBekkum-Da JFE 2019 V | index serial corr. negative since 2000s (20 idx) = reversal both ways |
| arXiv 2306.12434 (ETFs 2009-19) V | IBS short-only Sharpe < long-only in every bucket; 1-day effect |
| Connors-Alvarez 2008 U | overbought short < SMA200; in-sample |
| Hartford Funds 1996-2025 V | 76% of best S&P days in bear mkts / first 2 bull months = squeeze risk |
| #24 / #50 / #58 | gold 1D SELL -$0.22 vs BUY +$5.71; SELL -0.152R; dip-BUY below SMA200 -0.007R |

**Identity (stop-and-reverse):** SELL gross = BUY gross - buy&hold. #34 TALAASH BUY (<2019) vs buy&hold -> unfiltered SELL/trade
~ US500 -0.22R, USTEC -0.22R, XAU -0.02R, XAG -0.04R gross (R = 6 ATR; ATR% assumed, +-50%; IBS blocking ignored), ~-0.13R net.
The 4H BUY edge < drift in all 4. The SMA200 filter removes most drift periods.

## 3-4. Pre-register (one version per leg)
| Leg | Rule | Why |
|---|---|---|
| S1 | mirror + last daily close (17:00 NY) < SMA200 at the flip; 4 markets; rest unchanged | drift removed; shorts pay in slow bears; SMA200 already in IBS; no IBS-BUY clash; no market picking |
| S2 | as planned (has SMA200) | already regime-filtered; tiny N, no extra filter |

Gold/silver: do NOT drop by name. Pre-2019 gold was the least-bad short (identity, #24); NBIM: commodity shorts add value.
Risks real (central banks > 1,000 t/yr 2022-24, WGC V; safe-haven jumps, Baur-Lucey 2010 V; silver lease ~35-39% Oct 2025 U;
XAG spread 7.5x XAU), but dropping because we know 2019-26 = hindsight on IMTIHAN. SMA200 handles it for all 4.

## 5. Numbers
| Version | +tr/mo | P(TALAASH) | P(improves #68) |
|---|---|---|---|
| Pure mirror S1+S2 | +5-7 | 0.15 | 0.05 |
| **S1-SMA200 + S2** | +2-3 (0 bull, 6-8 bear) | 0.50 | 0.20 (joint 0.12) |

2012-18 alone = metals bear + index bull: a pass would be mostly metal shorts. Use #34 windows (XAU/XAG 2003-18, idx 2012-18).
S2 has ~30-40 tr in 2012-18: also test on TV long history like #58 (SPX/NDX, < 2019).

## 6. FTMO
- Swap: FTMO US says index dividends sit inside swap (U) -> index shorts pay (~1.3%/yr S&P, ~0.7% NDX + markup); gold shorts often earn
  (other broker XAU -60 / +19 pips, V). Before TALAASH: MT5 Specification screenshot (swap long/short) US500/US100/XAU/XAG; use max(3%, real).
- Weekend: allowed in Challenge/Verification; funded Standard no, Swing yes (FTMO FAQ V). Same as BUY legs.
- Gaps/squeezes: S1+S2 on both US idx = 3.5% open risk on one move; 4% guard matters. SELL SL = ASK (rollover spikes).
- Hedge rule (CLAUDE.md): SELL EA must see other magics' BUYs; close-on-BUY = seconds of overlap (hedging acct OK).

Sources: nbim.no note 2014#1 · stern.nyu.edu TSMOM pdf · repec jfinec v135p774, v132p26 · fairmodel.econ.yale.edu/ec439/hurst.pdf ·
man.com crisis-alpha · cxoadvisory SMA · arxiv 1404.3274, 2306.12434 · hartfordfunds · gold.org GDT FY2024 · opus.lib.uts.edu.au 10453/14038 ·
ftmo.oanda.com/faq · robomarkets XAUUSD
