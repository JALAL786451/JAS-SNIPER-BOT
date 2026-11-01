# Research agent daur 3 (1 Nov 2026): FX on our 11 Dukascopy pairs. Literature only, no 2019+ data touched
V = fetched and read 1 Nov 2026 · U = unverified, or from memory · "ours" = an earlier koshish in this repo

## A) Catalog: 28 FX families
| # | Family: mechanism | Evidence | Today |
|---|---|---|---|
| 1 | G10 carry: rate gap, monthly | Andrews+ JFE 2024: Sharpe 0.99 (1995-7/08), 0.11 (8/08-2020) V; DBV carry ETF closed Mar 2023 (NAV 24.05->25.09 over 2021-22) V | decayed, crash risk |
| 2 | Dollar carry (LRV 2014) | Sharpe >0.5 in 1983-2010 V(daur2); Hsu-Taylor-Wang JIMF 2024: carry rules fail out of sample (48 countries, 1983-2015) V | decayed |
| 3 | Forward-premium (dynamic) carry | Hassan-Mano QJE 2019: "no statistically reliable evidence" V | weak |
| 4 | TSMOM 12-1 (MOP 2012) | JFE 2012 V; Hutchinson+ RIBAF 2022: FX technical rules Sharpe 0.66 in-sample -> 0.06 OOS, killed by costs V | decayed |
| 5 | Short trend (Supertrend, MA, Turtle) on 4H/D1 | ours #47 #48 #51 #72 | dead here |
| 6 | Cross-sectional momentum (Menkhoff 2012) | cost-sensitive, works mostly in minor currencies V; Quantpedia: OOS slightly negative V | decayed |
| 7 | Value / PPP (AMP 2013, MSSS 2017) | RFS 2017 (1970-2014) V; DB index 1989-2009 Sharpe 0.36, OOS slightly negative V | slow, weak |
| 8-12 | Taylor rule / output gap, net foreign assets, slope carry, option vol premium, CLS order flow | papers U; slope carry works in bonds, not spot V | no data / not spot |
| 13 | **FOMC-day short USD** (Mueller-Tahbaz-Salehi-Vedolin JF 2017) | 1994-2010: DOL +12.45 bp on FOMC days vs ~0 on other days, t 2.4; Sharpe 0.5 net of spread V | **untested after 2010** |
| 14-15 | Pre-FOMC/ECB drift; macro news drift | equities only, gone after 2015 V(daur2); news priced within seconds U | dead |
| 16 | **Month-end hedge flow** (Melvin-Prins JFM 2015) | 2004-12: a 10% equity rise gives 14 bp FX in the hour before the 4pm fix V | thin, pre-2015 only |
| 17 | London fix "W" (KMW JF 2024) | negative net of full spread V(daur1) | rejected |
| 18 | **Gotobi / Tokyo fix** | EBS 2018-20: PF 1.46 V(daur1); after 2020, vendor claims only U | waiver only |
| 19-21 | Time of day (Breedon-Ranaldo 2013); day of week/turn of month; Jan/Dec USD | to ~2008, a few bp V; Kumar 2015 (INR market): gone after 2008 V; 1 trade/yr V | dead / too few to test |
| 22 | Daily reversal (RSI2, IBS) on FX | ours #51 #52 | dead here |
| 23 | Cross reversion (AUDNZD, AUDCAD) | ours #10 #11 fail; no peer-reviewed evidence | folklore |
| 24 | USDJPY intervention trades | about 10 episodes since 2010 U | untestable |
| 25-26 | Risk-off (AUDJPY/VIX); commodity FX (CAD-oil, AUD-gold) | BNP 2008: moves with VIX, VIX does not lead V; Ferraro-Rogoff-Rossi 2015: daily link at the same time, lagged link fades V | no lead |
| 27 | Session breakout, news straddle, scalping | no peer-reviewed evidence | folklore |
| 28 | Grid, martingale, hedged basket, swap arbitrage | n/a | **not allowed for our EAs** |

**Key cost fact (FTMO).** We assume swap of ~3%/yr on notional. A G10 pair has vol of about 8-9%/yr, so even a Sharpe of 0.3 earns only ~2.5%/yr on notional.
After 2008 the Sharpe is ~0.1, which is ~0.9%/yr. So swap >= edge, whatever the stop size (SL 2% = 1.5R/yr of swap). **Any FX trade held for several days dies on FTMO.**
Only trades of 1 day or less, with no rollover, can work. FTMO FX commission is $3-5 per lot round turn (third-party, U), about 0.004%. Check it in the platform.

## B) FTMO: top 4, ranked (H1 bars in UTC, time conversion with DST)
| Rank | Rules | Trades | Params | P(TALAASH+IMTIHAN) / P(improves #68) |
|---|---|---|---|---|
| **1 F1 FOMC DOL** | Scheduled FOMC statement days only (Fed list written down first, emergency meetings dropped). **Short USD** vs all: long EUR, GBP, NZD, AUD; short USDJPY, USDCAD, USDCHF, USDSEK. Pairs with spread > 0.03%/side are dropped. Entry: open of the 18:00 ET bar the day before (after rollover). Exit: close of the bar ending 16:00 ET on the announcement day. SL 1xATR20(D1) = 1R, 0.12%/pair (one ~1% bet). No swap. Unit = basket-event. TALAASH 2003-18: N=128, Exp-2SE>0, and the placebo (same window on non-FOMC Tue-Thu) must be <= half of Exp. IMTIHAN: about 62 events. | 8/yr | 0 | **0.15 / 0.06** |
| 2 F2 Gotobi | daur1 C2 rules unchanged. **Needs M1 data**: on H1, the 09:00 JST bar holds both the 09:55 fix and its reversal. | ~5/mo | 0 | 0.15 / 0.05 |
| 3 F3 Month-end | Last London business day, 15:00: S = month-to-date return of the foreign index (DE40 for EUR, UK100, JP225, AUS200, CHE20) minus US500. If \|S\| >= 2%, sell the currency of the market that did better. Exit 16:00 London (the fix). SL 0.5xATR20(D1). Edge ~5 bp vs cost ~2 bp. | 2-3/mo | 1 | 0.07 / 0.03 |
| 4 F4 Dollar carry | = daur2 G3 (monthly). Only if the FTMO swap on the carry side, after markup, is >= 0. **Measure first.** | 1-2/mo | table | 0.05 / 0.03 |

- F1 evidence (MTV, 1994-2010, V): the return spans the whole announcement day, and a 14:15 sample alone is not significant. It is bigger for high-rate currencies (AUD, NZD ~20 bp) and not significant for JPY and CHF.
  Gross is about 0.15-0.2R per pair, costs about 0.04R. Risks: TALAASH 2003-10 overlaps the paper's own sample, so only 2011-18 is truly new; there is no evidence after 2010 (U); on Fed days it is correlated with the #68 gold/index longs.
- Low P(improves #68): 8-60 small bets a year cannot move a median of 11.4 months, and FX legs raised fails before (#72).

## C) Personal Exness StandardCent (swap-free, Hedge, 1:2000), separate list
Swap-free removes the swap killer. EA rules still apply: one position per market, a stop on every trade, no grid/martingale/hedge.
| Idea | Real edge? | Verdict |
|---|---|---|
| P1 TSMOM 12-1 on 8 USD pairs: sign of r(t-12..t-1), checked on the 1st Mon-Thu of the month at 08:00 UTC, SL 6xATR20(D1), exit at the flip | academic, decayed | best slow idea here, P 0.10, ~1-2 trades/mo |
| P2 F1 FOMC DOL | as for FTMO | yes, if the StandardCent spread is <= 0.03%/side |
| P3 Gotobi; P4 Value/PPP quarterly (OECD PPP + CPI, 2 longs / 2 shorts vs USD) | waiver; decayed | only after an M1 TALAASH; P 0.05 |
| Carry (any form) | **no**: no interest is paid, so only spot is left, and high-rate currencies depreciate partly (Hassan-Mano V) | **not on this account** |
| "Reverse carry" (hold the low-yielder for free) | tiny, U; Exness may cancel swap-free status for abuse (third-party, U) | skip |
| AUDNZD/AUDCAD range grids, swap arbitrage, martingale, hedged baskets | folklore / **not allowed for our EAs** | n/a |
| London/Asia breakout, news straddle, scalping, intervention fade, AUDJPY or oil lead | folklore or untestable | skip |
1:2000 leverage adds no edge; it only lowers margin.

## D) Data needed
1. AUDUSD 2020 is missing: `duka_get.py h1 AUDUSD` on the laptop (cloud is blocked). AUDCAD/AUDCHF are thin in 2006-09 (gaps up to 900h) -> use them from 2010.
2. Rate table: BIS CBPOL monthly https://data.bis.org/topics/CBPOL (V, doc 24 Sep 2026; Japan has no policy rate 2001-06 and 2013-16 -> use the call rate ~0).
   Or FRED/OECD 3m interbank `IR3TIB01xxM156N` (SE V, to Sep 2026; other IDs U). Freeze the table before the test.
3. FOMC dates: federalreserve.gov/monetarypolicy/fomc_historical_year.htm (V, to 2020) + fomccalendars.htm.
4. USDJPY M1 + XTKS calendar (F2); spreads for NZD/CAD/SEK; FTMO swap + commission from the symbol spec.

## E) Honest bottom line
The literature after 2008 matches our #47/#48/#51/#72: classic G10 FX factors now have Sharpe ~0-0.1, and on FTMO swap kills any FX trade held for days.
Only **F1 FOMC-day short-USD** has peer-reviewed evidence, 0 tuned parameters and an FTMO-compatible shape: one pre-registered try (+1 count), P ~0.15, and it will barely change #68.
Personal account: only **P1 TSMOM** and F1 deserve a TALAASH test. Carry is wrong for a swap-free account.

**URLs (V):** MTV fmg.ac.uk/sites/default/files/publications/dp-54.pdf · Andrews doi.org/10.1016/j.jfineco.2024.103874 · Hsu-Taylor-Wang ideas.repec.org/p/cpr/ceprdp/15052.html ·
Hutchinson doi.org/10.1016/j.ribaf.2022.101779 · Melvin-Prins ideas.repec.org/a/eee/finmar/v22y2015icp50-72.html · Hassan-Mano nber.org/papers/w20294 ·
DBV sec.gov/Archives/edgar/data/1354730/000095017023010813/dbv-20221231.htm · quantpedia.com/strategies/currency-momentum-factor · Ferraro-Rogoff-Rossi nber.org/papers/w17998
