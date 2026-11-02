# Research daur 9 (2 Nov 2026): SELL-only systems, not mirrors
No backtest, no 2019+ data loaded. V = fetched/read 2 Nov · U = unverified (search summary only) · #n = ours.
Builds on `daur5-sell-agent.md` (mirror = FAIL; shorts pay in slow bears; short side adds value in commodities).

**Bottom line:** the only SELL with solid, mechanism-backed evidence is **commodity carry + momentum** (short contangoed
losers: oil/gas/copper). Index shorts work only in a confirmed **Bear state** and must **exit at the first up month**
(rebounds are strong, so never fade them). Fading bounces, vol-breakdowns and post-shock shorts are rejected on evidence.

## 1. How falls behave (what a SELL rule must respect)
| Fact | Source | Design rule |
|---|---|---|
| US stocks 1969-2018, next-month ann. return by state: Bull +9.5%, Correction +6.5%, **Bear -7.7%** (vol 20.8%), **Rebound +9.6%** | Goulding-Harvey-Mazzoleni "Momentum Turning Points" (AEA 2021 draft, JFE) V | short only when 12m AND 1m are down; cover when 1m turns up; never sell a rebound |
| Bear state = 16.7% of months; Rebound 10.5% | same V | few index trades; 2012-18 CFD data is almost all Bull |
| Lagged vol has little relation to average return | Moreira-Muir JF 2017 U | high vol alone is no SELL signal |
| Daily autocorr. turns negative when vol is high | LeBaron J.Bus 1992 + replications U | daily breakdowns in panic tend to revert = no breakdown-chasing |
| +returns days 1-3 after big one-day drops | Cox-Peterson JF 1994 U | never short the panic day itself |
| 76% of best S&P days in bears / early bulls | Hartford, in daur5 V | squeezes are violent: wide SL, small risk, fast exit |
| Short "contangoed losers" (low roll yield + neg. momentum), 37 futures 1979-2007: their futures return **-7.26%/yr** (TS-only -2.2%, mom-only -1.4%); costs only ~0.9%/yr | Fuertes-Miffre-Rallis JBF 2010, text read V | combine BOTH signals; one alone is weak on the short side |
| Same paper: long-short profits "mainly driven by long backwardated"; short leg alone insignificant | same V | honest: short leg is the weaker half |
| NG front contract ~-25%/yr 2010-2022, mostly roll cost; contango builds Apr-Dec, backwardation ~Jan-Apr | Vontobel "Costa de Roll" U (403; period incl. 2019-22, literature only) | NG is the cleanest structural short, but only in contango |
| UNG -88% to -98% since 2007 (sources differ) | UNG 10-K / press U | same |
| Weeks 1/3/5 after FOMC: -0.17 / -0.17 / -0.12% avg excess (1994-2013); hold odd weeks only -2.67%/yr, Sharpe -0.18; EM odd weeks -6.5 bp/day (t -2.84) | Cieslak-Morse-Vissing-Jorgensen 2015 draft (JF 2019), Table 3 read V | a real SELL-only calendar edge, but small; authors say shorting adds vol |

## 2. Candidates (all SELL-only, none is a flipped BUY rule)

### C1 - Commodity carry-momentum SELL ("contangoed loser") - best
- **Markets:** USOIL, UKOIL, XNGUSD, XCUUSD (all 4, no picking). Not in #68 = no clash with any live BUY.
- **TF:** 1D, decision only on the **last trading day of the month** at 17:00 NY close (paper rebalances monthly; keeps XNG cost low).
- **Signal data:** TradingView futures front + second: CL1!/CL2!, BRN1!/BRN2! (U: check ticker), NG1!/NG2!, HG1!/HG2!.
  Momentum on the **back-adjusted** front series (= futures excess return, includes roll).
- **Entry SELL:** F2 > F1 (contango, 0 parameters) **AND** 63-day back-adjusted return < 0.
- **Exit:** at a month-end when either condition fails. **No TP** (edge is an accrual - roll + drift, not a target).
- **SL:** 4 x ATR(20) daily above entry, fixed (gas squeezes 10-18% in a day happen; tight SL = sure loss).
- **Regime:** the contango test IS the regime: backwardation (tight supply, 2021-22 type) = no shorts at all.
- **Mechanism:** contango = oversupply + storage cost; hedger flow (producers short) and roll make longs pay; negative
  momentum confirms the glut is not ending. Falls in a glut are slow and steady - the one place shorts earn "like a trend".
- **Trades/yr:** ~8-12 spells (1-4 months each), ~15-20 short-months/yr over 4 markets. 2012-18: ~60-80 trades.
- **Test caveats (decisive, check BEFORE TALAASH):**
  1. Cash CFD price is ~spot; the roll reaches you via **swap / rollover points** (XTB/TMS NATGAS notices: long -x, short +x, U).
     If Exness/FTMO short swap in contango is NOT positive, the broker keeps the roll -> C1 is dead there. Need MT5 spec
     screenshots (swap long/short) for USOIL, UKOIL, XNGUSD, XCUUSD on Exness AND FTMO symbol list (copper may be missing, U).
  2. XNG spread 0.30%/side (our JasSpreadNaap): at 2x cost ~1.2% round trip; R = 4 ATR ~15% -> ~0.08R/trade. OK only because holds are long.
  3. Test = TV back-adjusted futures minus 2x cost minus swap markup; TALAASH 2012-2018 (+ optional pre-registered 2000-2011 for N).
- **Prior:** P(TALAASH pass) 0.35; P(then 2019+ pass) 0.6 -> joint ~0.20. Biggest risks: swap pass-through, small N.

### C2 - Index Bear-state SELL with rebound exit
- **Markets:** US500, USTEC, DE30, UK100, FR40, STOXX50, JP225, AUS200, HK50 (all 9).
- **TF:** 1D data, decision at month-end close (paper-faithful; no daily re-check).
- **Entry SELL:** 12-month price return < 0 **AND** last 1-month return < 0 (Bear state).
- **Exit:** next month-end if 1-month return >= 0 (Rebound: +9.6%/yr follows, so get out) or 12m >= 0. No TP.
- **SL:** 4 x ATR(20) above entry (Bear vol ~21%/yr ann.; SL catches 1987/2008-type squeezes only).
- **Why not a mirror:** S1 (#73) = 4H Supertrend flip + SMA200, rides until flip. C2 needs two horizons down, enters
  only after a down MONTH, and quits at the first up month - built around strong rebounds, not around trend persistence.
- **Mechanism:** Bear states come with worsening jobs/sentiment/liquidity surprises (same paper); slow bears grind
  (2001-02, 2008, 2022); fast crashes are mostly over before a monthly signal - by design it skips them.
- **Trades/yr:** ~0 in bull years, 10-25 in bear years (9 indices, correlated). 2012-18 CFD: ~15-30 -> too few.
  **TALAASH must use TV cash indices ~1990-2018** (SPX, NDX, DAX, UKX, CAC, SX5E, NI225, AS51, HSI; pre-registered, like #26).
- **Cost:** index spread tiny; short swap ~0 on Exness US500 but FTMO may charge dividends (daur5 U) -> use max(3%/yr, real).
- **Clash:** BUY priority as #73 (one position per market). Bear state is mostly below SMA200 -> IBS BUY rarely clashes;
  4H trend BUY in bear rallies will cut some SELLs.
- **Prior:** P(TALAASH on TV 1990-2018) 0.25 (US Sharpe ~0.37 per Bear month; pooled 9 correlated indices t ~1.3-1.8); joint ~0.12.

### C3 - FOMC odd-week SELL (calendar, weakest)
- **Markets:** US500, USTEC (US close). Optional pre-registered: same rule on the 7 non-US indices, next-day close (paper uses t+1).
- **Rule:** day 0 = scheduled FOMC announcement day (Fed calendar, known ahead). SELL at close of trading day 3, cover close
  day 8 (week 1); SELL close day 13, cover day 18 (week 3); SELL close day 23, cover day 28 (week 5) only if next day 0 > day 29.
  SL 3 x ATR(14), no TP, time exit = cover day. No regime filter.
- **Mechanism (paper):** Fed news arrives bi-weekly via board meetings / informal talk in even weeks; odd weeks carry no
  "Fed put", so bad macro news is not offset.
- **Trades/yr:** ~22 per market (~44 US). 2012-18: ~300.
- **Numbers:** edge ~0.15%/week vs 2x cost ~0.06% round trip; weekly sd ~2% -> needs ~2,000+ trades for t = 2.
  Sample overlaps 2012-13 (half in-sample), post-publication decay possible (U). Clashes often with IBS/trend BUY.
- **Prior:** P(TALAASH) 0.10; joint ~0.05. Keep only as the "if C1/C2 fail" note; do not build first.

## 3. Judged and rejected
| Idea | Reason |
|---|---|
| Dead-cat bounce fade (sell overbought in downtrend, quick TP) | Rebound state followed by +9.6%/yr (V) = fading rallies in bears loses; S2 IBS SELL (#73) already -0.06R |
| Volatility-expansion breakdown | vol does not predict mean (U); high vol -> negative autocorr (U) = breakdowns revert; VB #3 FAIL |
| Post-shock continuation (sell day after crash) | Cox-Peterson bounce days 1-3 (U); best days cluster in bears (V) |
| NG seasonal window alone (e.g. late Nov-Feb) | windows from 25y incl. 2019+ conflict (IG/Seasonax vs TV ideas, U) = snooped; C1 contango test covers the season |
| Gold/silver structural short | central banks + safe-haven jumps (daur5 V); #24 gold SELL -$0.22 |
| XPT/XPD short | spread 0.25/0.55%, curve = interest only (no carry info), #66 cost lesson |
| Correction-state short (12m up, 1m down) | next return still +6.5%/yr (V) = loses to drift |

## 4. Can a SELL leg cut the FTMO drawdown of the BUY basket?
- #68 bad months are of 3 types: (a) fast index crashes (Feb/Oct 2018, Mar 2020), (b) slow bears where IBS dip-buys and
  4H trend whipsaw (2001-02, 2008, 2022 type), (c) metal crashes (2013 gold).
- C2 helps only in (b) - exactly where it is active; it is blind in (a) by design and absent in (c).
- C1 is mostly uncorrelated with gold/indices, but in deflationary risk-off (2008 H2, 2014-15, 2020) oil goes into deep
  contango with negative momentum -> C1 is short while BUYs bleed. In 2021-22 backwardation it is flat (no damage).
- C3 is ~random vs the basket (5-day calendar) -> little hedge value.
- How to measure (CHUNAO, 2012-18 only): mean SELL-leg P&L in #68's worst 10 months, and monthly correlation.
  Pass rule stays #69-type (fail not up, pass >= #68). Risk 0.25-0.5% per SELL trade; do NOT widen any risk limit.
- Caution: a zero-edge hedge still adds its own daily-loss risk (#69 Tide oil: fail 0 -> 11 in 2020). Edge first, hedge second.

## 5. Order of work (for chief)
1. User screenshots: MT5 Specification swap long/short for USOILm, UKOILm, XNGUSDm, XCUUSDm (+ FTMO symbol list). Short
   swap in contango <= 0 -> C1 BANK, go to C2.
2. C1 qaida + Pine on TV (back-adjusted CL/BRN/NG/HG), TALAASH 2012-18, then IMTIHAN 2019+ once.
3. C2 qaida on TV 1990-2018 cash indices (9), then 2019+ once. C3 only if both fail.

Sources: openaccess.city.ac.uk/id/eprint/6416 (FMR 2010) · stern.nyu.edu cycle_paper_cieslak_morse_vissingjorgensen.pdf ·
benny.aeaweb.org/conference/2021/preliminary/paper/492Ds6fk (Momentum Turning Points) · nber.org/papers/22208 (Moreira-Muir) ·
ideas.repec.org/a/ucp/jnlbus/v65y1992i2p199-219 (LeBaron) · am.vontobel.com "Costa de Roll" · sec.gov UNG 10-K ·
tmsbrokers.com NATGAS rollover notices · xtb.com company news (NATGAS swap points) · quantpedia.com/?p=696 (Ghoddusi, SSRN 2820228)
