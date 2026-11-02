# Research daur 10 (2 Nov 2026): COUNTER to the BUY basket (#68)
No backtest, no 2019+ price data loaded. V = source fetched/read 2 Nov · U = memory / search summary only · #n = ours.
Basket = B1 Trend 4H BUY (XAU XAG US500 USTEC) + B2 IBS BUY (US500 USTEC) + B3 Khirki BUY (7 non-US index). All LONG risk.

**Bottom line:** the basket bleeds in 3 kinds of daur: (a) **demand / liquidity crash** (2008, 2011 Aug-Sep, 2015-16, 2018 Q4,
2020 Mar) - everything risky falls, gold too at first; (b) **real-rate / USD shock** (2013, 2022) - gold AND Nasdaq fall together;
(c) **chop** (no trend: gold 2013 H2-2015, 2021). Without bonds/USD/JPY (banned or not tradable) the only non-forex things that
rise in (a) are SHORT industrial assets (copper, oil, indices); in (b) only ENERGY rose (2021-22). Nothing here helps (c).
Two counters: **K1 Dr. Copper risk-off SELL** (best timing fit) and **K2 oil backwardation long/flat** (2022-type only). Both
small-N, both partly designed with hindsight of 2020/2022 -> priors are low. Neither is a mirror of B1/B2/B3.

## 1. Which daur hurt this basket type (and why)
| Daur | What happened | Driver | Basket hit |
|---|---|---|---|
| 2008 Mar-Oct | SPX -57% peak-trough 07-09; gold fell ~-30% Mar-Oct 08 (U), bottomed before SPX (VanEck V-summary) | credit crash, USD squeeze | B1 index + gold stops, B2 dips keep failing |
| 2011 Aug-Sep | SPX -19%; gold peak 6 Sep 2011 then -18% in weeks; silver -30% (U) | Euro crisis, margin hikes | B1 gold/silver whipsaw at the top |
| 2013 Apr-Jun | gold -28% year, silver -36% (U); SPX +30% year | taper tantrum, real yields up; gold vs real yield corr ~-0.82 1997-2012 (Erb-Harvey U) | gold legs bleed, index legs offset |
| 2015 Aug-2016 Feb | SPX/DAX/HSI -15..-25%, oil -75% 14-16, copper -25% (U) | China/oil/USD | **#53 daily year 2015 -8.6%** (repo #53) |
| 2018 Q4 | SPX -20% Oct-Dec; gold UP ~+7% Q4 (U) | Fed + growth scare | B2 IBS buys falling dips; B1 gold helps |
| 2020 Feb-Mar | SPX -34% in 23 days; gold -12% 9-19 Mar (forced selling, VanEck V); oil negative | liquidity "dash for cash" | all legs at once; FTMO daily limit risk (repo sabaq 809) |
| 2022 | SPX ~-19%, NDX ~-33%, BTC -64%, gold ~-1% (-20% Mar-Oct), Brent +10%, WTI +7%, GSCI petroleum +44.6% (U, several summaries) | inflation + fastest Fed hikes; "first year SPX and 10y UST both down double digits" (Direxion V) | **#53 year 2022 -5.8%** (repo) |
Pattern: our basket = long "risk + gold". Gold is a hedge only in slow crises (2008 Q4-2011, 2018 Q4); in liquidity crashes
and rate shocks it falls WITH stocks. Correlated legs falling together on the same day is what breaks FTMO (repo sabaq 809).

## 2. What rose / fell in those daur (tradable, non-forex)
| Daur | Up (long would win) | Down (short would win) | Stable? |
|---|---|---|---|
| 2008 | gold only from Oct 08 | oil -75% after Jul, copper -60%, all indices | short-industrial = stable in demand crashes |
| 2011 Aug-Sep | gold until 6 Sep | copper -30%, indices | same |
| 2013 | US/JP indices (already in basket) | gold, silver, XPT | internal offset already exists |
| 2015-16 | gold from Dec 15 | oil, copper, HSI, DAX | stable |
| 2018 Q4 | gold, (XPD) | oil -40%, indices; copper flat | oil yes, copper weak |
| 2020 Mar | nothing non-forex (bonds/USD/JPY only) | oil, copper, every index, BTC | short only, and fast (1-4 weeks) |
| 2022 | oil, UKOIL, XNG (H1), long/flat trend commodity index +9.18% (Direxion COM V) | NDX, BTC, copper (Mar-Jul -30%), gold (Mar-Oct) | energy-up = regime-specific (supply shock) |
- **Commodities vs equities corr = +0.48, vs USD -0.50 (Bloomberg 2010-11/2022, Direxion V).** Oil is NOT a hedge on average; it
  only diverged in 2021-22 (supply shock). Commodity futures are "an inconsistent, if not tenuous, hedge against unexpected
  inflation"; hedge works best in hard-to-store goods with good roll return (Erb-Harvey NBER w11222, abstract U).
- **BTC is not a counter:** corr with Nasdaq up to 0.8 (30-day, May 2022, K33 U), ~0.4-0.6 over 2021-22; fell -64% in 2022.
- **Trend-following "crisis alpha":** TSMOM positive in 8 of 10 worst 60/40 drawdowns 1880-2016; these drawdowns last ~15 months
  avg; fails in very fast crashes like 1987; its own stress = sharp reversals across markets (Hurst-Ooi-Pedersen JPM 2017, text V).
  BUT most of that crisis alpha came from bonds, FX and short equity futures - all banned/not tradable for us, or failed (#73).
- **Contango short is dead** (daur 9 C1: Exness short swap never positive). The LONG backwardated leg is the strong half of
  carry-momentum (Fuertes-Miffre-Rallis JBF 2010, V in daur 9).

## 3. Counter strategies (pre-registration drafts, NOT tested)

### K1 - "Dr. Copper" risk-off SELL (XCU only)
- **Why:** copper is the most growth-sensitive non-forex CFD; it fell hard in 2008, 2011, 2015, 2020, 2022 = the same months our
  basket bleeds. A different market from the basket, gated by the EQUITY regime -> not a mirror of B1/B2/#73.
- **TF:** 1D, decide at 17:00 NY close, enter next daily open. Signal data: TV COMEX HG1! (back to 1988) + SPX cash.
- **Regime (all three):** SPX close < SMA200(1D) AND XCU close < SMA200(1D) AND XCU close = lowest close of last 20 days.
- **Entry:** SELL XCU. **SL** 3 x ATR20(1D) above entry = 1R, fixed. **No TP.**
- **Exit:** XCU close > highest close of last 10 days, OR SPX close > SMA200, OR 40 trading days. One position max.
- **Risk:** 0.25% (new leg, small; do not touch B1/B2/B3 risk).
- **Cost:** spread 0.0558% (repo naap) x2 at 2x cost; XCU short swap 0 (Exness, given) -> cheapest short we have. Use
  max(0, real) + 3%/yr margin anyway. FTMO copper symbol may be missing (U) -> check first.
- **Expected corr with basket:** ~0 overall (flat ~80% of days: SPX < SMA200 only ~20-25% of time), clearly NEGATIVE in bleed
  months (a)-type. Does nothing in (b) gold-only shocks (2013) or (c) chop.
- **Trades/yr:** ~2-4. 2012-18 only ~8-12 trades (2012, 2015-16, 2018 Q4) -> TALAASH must be pre-registered on TV 1990-2018
  (~60-80 trades), then 2019+ ONCE.
- **Prior:** P(TALAASH 1990-2018 Exp-2SE > 0 at 2x cost) **0.25**; P(then 2019+ pass) 0.6 -> joint **~0.15**.
  P(it actually lowers #68 max DD / FTMO fails, given pass) **~0.5**: right timing, but 2020-type crash is 4 weeks and the
  basket's daily-limit hit may come before the 20-day-low entry. **Hindsight warning:** I know copper's 2020/2022 path, so the
  2019+ "out-of-sample" is mentally contaminated -> treat a 2019+ pass as weaker than usual.

### K2 - Oil backwardation momentum LONG/flat (USOIL + UKOIL)
- **Why:** the only non-forex asset that rose in a rate/inflation shock (2021-22). Backwardation = tight supply = the regime
  where energy goes up while long-duration stocks/gold fall. Long-only, so it is NOT #69 Tide (both sides, no curve filter).
- **TF:** 1D, decision only at the last trading day of the month (keeps trades few). Signal data: TV CL1!/CL2!, BRN1!/BRN2!.
- **Entry BUY:** F1 > F2 (backwardation) AND 126-day return of front > 0. **Exit** at a month-end when either fails.
- **SL:** 4 x ATR20(1D) below entry = 1R, fixed (oil 2020 / 2008 crashes). **No TP.** Risk 0.25% per market.
- **Cost / swap:** oil long swap 0 on Exness (given). Big caveat: a spot CFD with 0 long swap probably does NOT pay us the
  backwardation roll (the main source of the paper edge) -> test on the CASH CFD price only (spot change), curve only as filter.
  Exclude XNG (spread 0.30%, energy long swap -254 case) and XCU long (swap -222).
- **Expected corr with basket:** mildly positive overall (+0.48 commodities-equities, V), negative only in 2021-22-type years.
  In demand crashes it is usually out (contango arrives fast: 2008 H2, 2014-16, 2020) but the first month of a crash can hit it.
- **Trades/yr:** ~1-3 spells per market. 2012-18 ~8-12 -> also needs pre-registered TV 2000-2018. Direxion V: commodities had a
  "lost decade 2010-2020" -> 2012-18 is a hard TALAASH for any commodity long.
- **Prior:** P(TALAASH pass) **0.20**; joint with 2019+ **~0.10**. P(lowers basket DD, given pass) **~0.3** (helps only 2022;
  basket's worst FTMO risk is the fast crash, where K2 is flat or losing). Hindsight warning: #69 (2020 oil crash) already seen.

## 4. Honest verdict
- The basket's real weakness is the **fast liquidity crash** (2020 Mar): there is no non-forex BUY that rises then, and fast
  shorts are hard to time (TSMOM fails in 1987-type crashes, V). The best defence is NOT a new strategy but basket rules
  already in place: small risk per leg, one position per market, and FTMO daily-loss limits.
- K1 > K2: better timing match with the bleed months, cheaper (short swap 0), simpler. K2 is a 2022-only insurance.
- daur 9 C2 (index Bear-state SELL, joint ~0.12) is the third option for slow bears (2008, 2022); K1 and C2 overlap in regime.
- Order if user says "D": K1 TALAASH on TV 1990-2018 (pre-registered, rules above unchanged) -> only if PASS, combine with #68
  in `ftmo` sim at 0.25% using the usual CHUNAO/IMTIHAN shart. K2 only after K1. No risk widening anywhere.

Sources: fairmodel.econ.yale.edu/ec439/hurst.pdf (Hurst-Ooi-Pedersen 2017, text read V) · direxion.com/uploads/
Commentary_COM-2022-Year-End-Recap_V3.pdf (V) · vaneck.com blog "examining-golds-recovery-cycles" (search summary U) ·
nber.org/papers/w11222 (Erb-Harvey 2006, abstract U) · k33.com research "bitcoins-correlation-to-us-equities" (U) ·
mining.com "2022s-stores-of-value" (U) · lbma.org.uk alchemist issue 90 (gold vs TIPS -0.40 since 2018, U) · repo: #53, #69, #73, sabaq 809.
