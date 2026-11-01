# Research agent daur 4 (1 Nov 2026): best instrument + strategy to add to #68
No 2019+ returns computed; repo data checked for dates/gaps only. V = fetched 1 Nov 2026 · U = unverified · "ours" = repo koshish.

**Bottom line.** Only one candidate is a real edge AND a new asset class for #68: **BTCUSD daily Kachhua (trend)**.
Every other FTMO market/idea is already in #68, already failed here, decayed in the papers, or hits the same dip days as our IBS.
Nothing is likely to cut the 11.4-month median by much. Single best next attempt: **#73 = #68 + BTC Kachhua** (two checks first, below).

## Ranked top 3
| # | Pair | Tr/mo | New params | Corr. with #68 | P(TALAASH+IMTIHAN) | P(improves #68) |
|---|---|---|---|---|---|---|
| 1 | BTCUSD D1 Kachhua (Tide 1 10/5, frozen since 9 Oct), FTMO crypto leg | ~0.9 | 1 (risk 0.25/0.5) | low-mid: BTC-S&P daily corr 0.01 (2017-19) -> 0.36 (2020-21) V | 0.45 (2019+ already SEEN) | **0.25** |
| 2 | US2000 IBS (#15 rule unchanged), 3rd IBS slot | ~2 | 1 (risk 0.5) | **high**: same dip days as US500/USTEC IBS | 0.20 | 0.10 |
| 3 | Trend-leg vol cap (scale down only, no new signal) | 0 | 2 (pre-set) | lowers it on crash days | n/a (FTMO sim only) | 0.05 |

## Rules
**1. BTC Kachhua.** Close breaks 10-bar high (BUY) / low (SELL), side from D1 EMA50/200, ATR14 >= 0.25%, SL 2xATR14 = 1R,
SL trails to 5-bar low/high, exit at close on side flip. D1 = FTMO server day, 7 days/week. One position. Risk 0.25 or 0.5% picked in CHUNAO (like #60).
Cost: commission 0.0325%/side (V daur1), spread JasSpreadNaap x1.5, **swap = measured FTMO value**. Other brokers charge ~20-25%/yr on
long notional (IG 25% p.a., Admiral ~0.056%/day, V). At SL ~7% of price, 20%/yr = ~0.008R/day held = ~0.15R/trade at ~20 days (estimate) vs +0.58R gross.
Evidence: ours TV CRYPTO:BTCUSD 2019-Oct 2026 81 tr +0.58R (±0.47) PF 2.67; Exness MT5 79 tr +44R (two feeds agree), but SEEN = IMTIHAN not clean.
Zarattini-Pagani-Barbon 2025 (SFI RP 25-80, SSRN 5209907; 2010-Mar 2025; long-only Donchian ensemble; top-20 rotation net Sharpe > 1.5; BTC-only figures U) V.
Quantpedia 2024: BTC 10-50-day-high breakout stayed effective OOS Feb 2022-Aug 2024; 10-day-low dip-buy did not (no costs) V.
Threats: drift (prior agent: long-only crypto trend 1.4x drift < our 2x); maturing BTC, lower vol after spot ETFs (U);
funded Standard must close before weekends, no crypto exception found (third-party) -> Swing (crypto lev 1:1, U): 0.5% at 7% SL = 7% notional, fits.

**2. US2000 IBS.** #15 exactly: IBS < 0.2 and close > SMA200 -> BUY at close; exit IBS > 0.8 or 5 days; SL 3xATR14 = 1R; long only; decision 16:15 NY (i6).
Risk 0.5%, not 1% (3 IBS slots on one dip day = up to 2.5% plus trend legs, near the 4% guard).
Evidence: Baltussen-van Bekkum-Da, JFE 132(1) 2019: index serial correlation turned negative in most of 20 indices, tied to futures/ETFs V (= why index IBS works).
IBS on ETFs: Pandey-Joshi arXiv 2306.12434 (~10 yrs, 1-day horizon only) V. Ours #14 (< 2019): US2000 313 tr +0.044R, ~0 after 2SE = borderline.
FTMO lists US2000.cash since 7 Feb 2022 V. Threats: #52 US500 IBS weak 2019+; correlation. Not US30: same days as US500 IBS, 2019+ seen.

**3. Vol cap.** Per trend market at signal: f = min(1, median(sigma20 over 250 d) / sigma20); risk = 0.75% x f, never above 0.75%.
Two-sided targeting widens risk = only if Jalal asks by name (CLAUDE.md). Evidence: Harvey et al. JPM 45(1) 2018: Sharpe up only for equity/credit
(US ~0.40 -> ~0.5), ~0 for commodities/FX, smaller left tail V. Cederburg et al. JFE 138 2020: OOS vol-managed beat plain in only 53/103 V.
Our 6xATR SL already sizes by vol. It can only cut fails; #68 has 0 fails 2019+, so the median likely gets LONGER.

## Checked and rejected
| Idea | Why |
|---|---|
| US30/US2000 pre-holiday | #59/#60 family (bank), same days |
| Index pre-FOMC / FOMC cycle | gone after 2015 (Kurov-Wolfe-Gilbert, daur2 V) |
| Gold FOMC | no study; only minutes-scale reaction (Awartani et al.) V |
| Gold holiday drift (Quantpedia 5 Aug 2025: Xmas, Eid, Diwali, Lunar NY, D-1..D+2, Sharpe 0.71) | 2005-25 in-sample, no costs V; ~4/yr -> TALAASH N ~56 < 100; overlaps gold trend + Xmas khirki |
| Nikkei/DAX overnight vs day | = #42 drift; fails drift rule by construction |
| Turn of the year | ~1/yr, N too small |
| Opex week | prior agent rejected; weekly (2016+) / 0DTE (2022+) options changed it (U) |
| Stock CFD PEAD / momentum | PEAD gone in large caps since ~2006 (Martineau CFR 2022 V, contested 2025); mega-cap list = drift trap (#61); earnings gaps jump SL |
| Commodity term structure | CFD has no curve; carry sits in swap; untestable |
| ETH/alt trend, BTC hour, BTC dip-buy | ours ETH not robust; C4 rejected; dip-buy failed OOS (V) |

## Data (coverage only)
- BTCUSD Dukascopy H1 2017-05-08..2026-10-29 (2017 thin) -> CHUNAO 2012-18 has ~1.6 yr of BTC. Need BTC D1 2014-17 (TV BITSTAMP:BTCUSD export, or Bitstamp/Gemini via CryptoDataDownload, U). D1 is enough for a D1 system.
- US2000 Dukascopy starts 2019-03-20 = no TALAASH/CHUNAO. Need TV TVC:RUT D1 + H1 2012-18 (RTY futures, paid, U).
- US30 2013-09+, 2015-17 thin (~3,700-4,400 H1/yr vs ~5,900).
- FTMO Free Trial: BTCUSD + US2000.cash spec (swap long/short, spread, hours).

## Single best next attempt (pre-register first, +1 count)
**#73 = #68 + BTC Kachhua.** Step 0: FTMO BTC swap; long swap > 40%/yr -> stop (net < ~0.25R/trade).
CHUNAO 2014-18 (external BTC D1), risk 0.25/0.5%: (pass - fail) >= #68, P1 fail < 20%. IMTIHAN 2019+ once: fail 0, pass >= 83, median < 10.8.
2019+ BTC is seen -> demo forward has the last word.

**Sources (V):** imf.org/en/blogs/articles/2022/01/11/crypto-prices-move-more-in-sync-with-stocks-posing-new-risks · ideas.repec.org/p/chf/rpseri/rp2580.html ·
quantpedia.com/revisiting-trend-following-and-mean-reversion-strategies-in-bitcoin/ · ideas.repec.org/a/eee/jfinec/v132y2019i1p26-48.html · arxiv.org/abs/2306.12434 ·
ftmo.com/vi/trading-update-16-12-2021-2-2-2-2-2-2 (US2000.cash) · people.duke.edu/~charvey/Research/Published_Papers/P135_The_impact_of.pdf ·
lehigh.edu/~xuy219/research/COWY.pdf · quantpedia.com/?p=41789 · ideas.repec.org/a/now/jnlcfr/104.00000122.html ·
IG "bitcoin MT4 product details" help page · Awartani et al. pure.kfupm.edu.sa (gold intraday vs FOMC)
