# Research daur 8 (2 Nov 2026): range bars (TradingView 1R/10R/100R/1000R) for gold - is there a proven edge?
Literature + reasoning only. No backtest run, no 2019+ data touched.

**Bottom line:** NO. I found no peer-reviewed or credible quant evidence of a trading edge that comes from
range (or renko) bars themselves. A range bar is only a different *sampling clock* (price-time instead of clock-time).
It changes how the chart looks, not what the market does. Any edge must already exist in the price path (trend or
mean reversion at that price scale); range bars cannot create one. On small R the CFD spread eats everything,
same as the repo's 15+ failed gold intraday ideas.

## 1) What the sources say
- **Origin:** Vicente M. Nicolellis Jr., a Brazilian broker/trader, ~1995 (TradeStation help; secondary sources only).
  Idea: in volatile local markets, draw a bar only when price moves a fixed range. Marketing claims ("less noise,
  clear trend") are not tests.
- **Peer-reviewed / quant work:** It is about *statistical properties*, not profit.
  - Easley, Lopez de Prado, O'Hara, "The Volume Clock", JPM 2012, and AFML (2018): volume/tick/dollar bars give returns
    closer to normal than time bars. That is useful for ML hygiene. It is not an alpha claim.
  - arXiv 2608.26158 (Jul 2026, crypto): tick renko bars are *closest to a random walk* (VR(4)-1 = 0.02, lag-1 AC 0.002).
    So the bars look cleaner, but that cleanness means there is *less* to predict. The paper makes no profit claim.
    Bars rebuilt from minute data differ from tick-built bars.
  - arXiv 2103.12419 (volume-centred range bars, ML): break-even precision ~24% before spread vs ~33% after spread,
    i.e. spread is a huge share of the bar, even in a paper built around range bars.
  - MQL5 "Beyond the Clock" pt 4 (EURUSD 2022-23, no costs): "no bar family produces a reliable edge for these rules".
  - Research Square renko preprint (BTC, TradingView sim): authors say it shows NO live profitability.
- **What HFT / quant firms really use:** order-book events, queue position, latency, market making, and order flow
  imbalance (Cont-Kukanov-Stoikov 2014, J. Fin. Econometrics: price change ~ linear in OFI at the best quotes).
  They work in event time on tick/L2 data with colocated execution and pay ~zero spread (they *earn* it).
  Retail range bars on a CFD with 0.24 spread are the opposite end. I found no firm using TV-style range bars as alpha.
- **TradingView itself warns:** "Strategy produces unrealistic results on non-standard chart types (HA, Renko, Kagi,
  P&F and Range)": the synthetic prices give "results [that] will typically not represent real market conditions".
  PineCoders FAQ: fills happen at the synthetic next-bar open, so it is not a bug, just unreal. TV moderates such publications.
- **How TV builds history:** 1R = 1 tick. The 2018 launch post says history is built from **1-minute OHLC**
  (the current help says 1-second). The live bar uses real ticks. So history != live, and small R is the worst case
  (TradeStation: a small R makes more bars in real time than in history). "Phantom bars" fill gaps with *virtual*
  bars, at prices you could never trade.
- **Bias direction:** mechanicalforex (2010): range/renko tests on 1-minute data "highly overestimate profitability and
  underestimate losses". The error grows as R shrinks and for scalping systems.

## 2) Cost reality (Exness XAUUSD, 0.24 round trip per 1.0 price unit)
| R ($) | cost/R | 2x cost/R | bars/day (rough, 2009-18 daily sd ~$12-15) | verdict |
|---|---|---|---|---|
| 1 (TV "100R" at 0.01 tick) | 24% | 48% | 300+ | dead: needs ~75% win rate at 1:1 |
| 2 | 12% | 24% | ~100 | dead (like #12: 59.8% wins < 66.7% needed) |
| 5 | 4.8% | 9.6% | ~20-25 | needs ~55% at 1:1. Very hard |
| **10** | 2.4% | 4.8% | ~5-6 | needs ~52.5% + 2SE. **Only sane size** |
| 20 | 1.2% | 2.4% | ~1.5 | close to H4/daily trend = already "dekha hua" |
Note: TV "1000R" on gold at a 0.01 tick = $10. So 10R/100R are scalping sizes, and costs kill them.
Key math: under a random walk, range-bar directions are iid 50/50 coins (each bar starts fresh at the last close).
So any "N same-colour bars" rule has Exp = -cost unless gold has real momentum or reversion at scale R.
The repo already knows: "edge TF ke saath ghatta" (#33). At $10 you are near H1-H4 scale, where gold trend was borderline.

## 3) Converting M1 OHLC to range bars (Python, conservative)
1. Intrabar path per M1 bar: if C >= O, then O -> L -> H -> C, else O -> H -> L -> C (MT5/TV convention). Walk it as straight segments.
2. Keep the current bar's hi/lo. When hi - lo >= R: close the bar at lo+R (up bar) or hi-R (down bar). The next bar opens at that close.
   One long segment can complete several bars; loop until the remainder is < R.
3. **Gaps** (M1 open != previous M1 close by more than R, e.g. weekend or news): build the bars, but tag them `gap=1`.
   No fill is allowed at a gap-bar price. The fill is the real M1 open.
4. Store with each range bar the M1 timestamp where it completed and a flag `multi` (more than one bar completed inside that same minute).
5. **Fills:** the signal is known only when a bar completes. Enter at the **next M1 open** after that minute, not at the
   synthetic bar close, plus the spread. SL/TP are checked on M1 H/L with SL first if both hit in one minute.
6. **Robustness check (must pass):** rerun with the opposite path order (always O->H->L->C). If the sign of Exp flips
   or Exp falls >30%, REJECT, because the result is path-ambiguity, not edge. Also report the % of trades inside `multi` minutes.
7. Range is $ fixed. Gold went from ~$900 to ~$1900 in 2009-18, so also log R as % of price. Optional variant: R = 0.75% of the
   rolling 20-day mean price, fixed per day. Pre-register ONE choice before running.

## 4) Candidate rules (max 2, fully mechanical, pre-registered)
**A. "Range naali" breakout (trend, R = $10).**
- Bars: $10 range bars, built as in Sec 3. Donchian channel on range-bar highs/lows, N = 20 bars (~3-4 days of movement).
- Long: a bar closes above the highest high of the prior 20 bars. Short: a bar closes below the lowest low of the prior 20. One position max.
- SL: the opposite 10-bar channel (lowest low of the last 10 bars for a long), with the initial SL capped at 3R = $30.
- Exit: trailing 10-bar opposite channel, or a reverse signal. No TP. No adding, no averaging.
- Why it might work: gold has real time-series momentum at multi-day scale (repo: Kachhua / 4H Supertrend). Range bars
  remove dead Asian-session bars, so the channel adapts to volatility automatically, like an ATR-scaled Donchian.
- Why it might not: it is the same trend that is already captured on H4/D1 (a correlated copy, little new). Cost per trade
  ~0.24 against an average win of maybe 2-4R is small, but whipsaws are frequent.
- **Prior P(Exp - 2SE > 0 at 2x cost) ~ 0.20.** If it passes, check its correlation with the existing 4H trend leg before calling it "new".

**B. Exhaustion fade (mean reversion, R = $10).**
- After **4 consecutive same-colour** $10 bars (a $40 one-way move with no $10 counter-bar), enter against the run at the next M1 open.
- SL = 2R ($20) beyond the entry. TP = 2R ($20). Time stop = 6 range bars. Skip if any of the last 4 bars has `gap=1`
  (news shock = momentum, not exhaustion). One position max.
- Why it might work: large one-way intraday gold runs partly retrace (liquidity / stop-run overshoot). It is also a clean
  test of the coin-flip null from Sec 2.
- Why it might not: the repo's intraday reversion ideas (#31 RSI2, #38) were ~0 even with no cost. News runs continue.
- **Prior ~0.08.** Cheap to run, because it reuses A's bar builder.

**Zero-cost diagnostic first (not a backtest, 5 minutes):** on 2009-2013 only, compute P(next bar same colour | k same before)
for k = 1..5 at R = $5/$10/$20 vs 0.5, with a binomial SE. If no cell exceeds 0.5 by >2SE + the 2x cost hurdle (~2.5 pts at $10),
skip A and B entirely and record it as a fail. That saves the full test.

## 5) Honest summary for Jalal
- Range bars = a different clock, not a new edge. Pros (HFT) use the order book + speed + rebates, not range bars.
- 1R/10R/100R on gold = scalping, and the spread is 12-48% of each bar = sure loss (same lesson as #12).
- If you test anything: $10 bars, rule A, Python on M1 2009-18, fills at the next real M1 open, path-flip check. TV's range-bar
  strategy tester is NOT valid evidence (TV says so itself).

Sources: TradingView support 43000481029 and 43000474007; TV blog "range bars now available" (2018); PineCoders FAQ
"Backtesting on Non-Standard Charts"; TradeStation Range Bar help; Easley-Lopez de Prado-O'Hara JPM 2012 (SSRN 2034858);
arXiv 2608.26158; arXiv 2103.12419; MQL5 article 23310; Research Square rs-11251524; Cont-Kukanov-Stoikov JFEC 2014
(arXiv 1011.6402); mechanicalforex.com 2010 "Why Renko/Range charts cannot be backtested accurately".
