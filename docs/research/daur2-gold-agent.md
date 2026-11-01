# Research agent daur 2 (1 Nov 2026) - gold / dollar add-ons to #68 (literature only, no 2019+ data touched)

**Bottom line, honestly:** after 2015 the published gold literature has one robust edge, **trend/momentum**, and #53 already holds it.
Seasonal, fundamental, FOMC and reversal effects for gold are either not significant or have decayed. So the realistic options are
cheap **filters on the #53 metal leg**, plus one dollar leg that is not trend (carry). The expected gain is small. Each one must be
pre-registered and judged on the FTMO sim: TALAASH 2012-18 first, then IMTIHAN 2019+ once (pass count up / median days down, 0 fails).

| # | Candidate | Market / TF | Trades/mo | Params | Overlap with #53 | agent P(improves #68) |
|---|---|---|---|---|---|---|
| G1 | 24-month gold momentum regime filter | XAU (+XAG) 4H trend leg, monthly gate | 0 new (removes trades) | 1 | filter itself | 0.20 |
| G2 | Dollar counter-trend filter (DXY Supertrend) | XAU/XAG 4H longs gated by DOLLARIDX 4H | 0 new | 0 (reuses 10x3) | filter itself | 0.15 |
| G3 | Dollar carry basket (LRV) | 7 USD pairs, monthly, daily stop | ~1-2 entries | 1 (rate table) | low (FX, not trend) | 0.10 |
| G4 | Gold + US bond 12m dual momentum gate | XAU 4H leg, monthly gate | 0 new | 1 | filter itself | 0.08 |

**Rules**
- G1: on the last daily close of each month, compute r24 = XAU close / close 24 months earlier - 1. If r24 <= 0, block new #53 XAU (and XAG,
  same gate) longs next month. Open trades keep their SL/flip exit. Signals use only earlier data (no repaint).
- G2: take a new XAU/XAG 4H Supertrend BUY only if the DOLLARIDXUSD 4H Supertrend (10x3, NY-17:00 bars, same code as #47) is DOWN
  on the same bar close. Nothing else changes.
- G3: once a month, use a pre-written table of central-bank policy rates (written down before the test). If the average G10 foreign
  rate is above the US rate, go short USD vs all 7 (EUR, GBP, AUD, NZD long; USDJPY, USDCAD, USDCHF short), otherwise go long USD.
  One position per pair, SL 3x ATR20 D1 = 1R, exit at the monthly flip, risk 0.15% per pair (1.05% total = one bet). Count it as ONE
  factor (the pairs are about 0.6-0.8 correlated).
- G4: on the last daily close of each month, allow #53 XAU longs only if the 12m return of gold > 0 AND the 12m return of the US T-bond > 0.

**Evidence (all fetched 1 Nov 2026)**
- G1: Bartsch, Baur, Dichtl & Drobetz, "Investing in gold - market timing or buy-and-hold?", IRFA 71 (2020). Over 4,000 rules on data
  1979-2015, OOS from 1990, Hansen SPA test. Only 1-3 technical rules beat buy-and-hold, led by **24-month momentum**. Seasonal and
  fundamental rules failed. Very few trades. https://ideas.repec.org/a/eee/finana/v71y2020ics1057521918306227.html ,
  https://quantpedia.com/an-extensive-test-of-market-timing-strategies-in-the-gold-market/ . Caveat: after 2018 gold's r24 was
  almost always > 0, so in IMTIHAN the gate will barely ever block a trade (it mainly helps 2013-16). The expected 2019+ change is close to zero.
- G2: CXO (UUP vs GLD/USO, 2007-2018): gold moves opposite the dollar, but the link is **coincident at daily frequency; the dollar does not
  lead gold**. https://cxoadvisory.com/?p=21168 . So a filter can only drop trades that go against the dollar trend. #47 showed that
  trend trading the DOLLARIDX itself loses (USD fx -0.049R), but here it is used only as a gate. No paper tests this exact filter (UNVERIFIED as an edge).
- G3: Lustig, Roussanov & Verdelhan, JFE 111(3) 2014, "Countercyclical currency risk premia": the dollar carry Sharpe was **> 0.5** (working
  paper, 1983-2010). https://www.nber.org/papers/w16427.pdf ; Daniel, Hodrick & Lu, CFR 2017: the dollar component drives carry
  https://business.columbia.edu/sites/default/files-efs/pubfiles/6378/Daniel.Hodrick.Lu.Carry%20Trade.Critical%20Finance%20Review.2017.pdf .
  **Decay:** JIMF 2022 "Currency carry trade: the decline in performance after the 2008 GFC"
  https://ideas.repec.org/a/eee/intfin/v76y2022ics1042443121001670.html . No post-2015 test of dollar carry was found (UNVERIFIED).
  Also, FTMO swap markup may eat the carry.
- G4: QuantifiedStrategies (GLD + IEF 12m both > 0): it claims a lower drawdown over 50 years, but since 2004 it made about 6% a year vs about 10%
  a year for buy-and-hold. Not peer-reviewed. https://quantifiedstrategies.substack.com/p/a-gold-strategy

**Rejected (checked, do not test)**
- Gold "autumn effect" (Baur 2013, Sep/Nov, 1981-2010): the OOS replication **reversed it**. September turned negative in Dec 2010-Jul 2022, Chow
  test p = 0.027, and only January was positive (Potrykus & Augustynowicz, IJME 2024) = decay.
  https://reference-global.com/download/article/10.2478/ijme-2024-0011.pdf
- Gold contrarian move the day after an abnormal day (Caporale & Plastun, FMPM 2021, 2009-2020): hourly timing parameters are fitted
  in-sample, and the gold simulation was weaker than oil's. It is the same family as RSI(2), which gave zero on gold.
  https://bura.brunel.ac.uk/bitstream/2438/21825/6/FullText.pdf
- Pre-FOMC drift: it shows up in equities only (not FX or bonds), and Kurov, Wolfe & Gilbert found it had largely disappeared after 2015.
  No gold study was found. https://www.skidmore.edu/economics/documents/KurovWolfeGilbert-TheDisappearingPre-FOMC-Announce-Drift-200914.pdf
- Gold/silver ratio regime: no peer-reviewed evidence for gold (only blogs and Schaeffer's tables), and the pairs tests already failed (#10-11).
- Pre-holiday effect in commodities (Quantpedia 2024): tested only on oil and gasoline, not gold. Already C5 in daur 1.

**Data:** G1 and G2 run on data the project already has (data/ftmo XAU/XAG, JAS_ZIP DOLLARIDXUSD), with costs from the `ASLI` dict.
**Missing**, to download with tools/duka_get.py: **EURUSD, AUDUSD, USDJPY** (for G3; these IDs are already in the duka_get H1 list),
**US T-bond CFD** (Dukascopy ID probably `USTBONDTRUSD`, not in duka_get - UNVERIFIED) for G4, and **XPTUSD** (Dukascopy ID UNVERIFIED) only if
platinum should join the metal leg. A G10 policy-rate table is needed for G3 (write it by hand from central-bank pages before the test).

**Suggested order:** G1 and G2 together as one pre-registered filter attempt (each counts +1). G3 only if the user wants an FX leg. Skip G4 unless the bond data comes easily.
