# Research daur 6 (2 Nov 2026): cutting #68's median FTMO pass time (11.4 months). Literature and reasoning only, no code run, no 2019+ data used
**Bottom line, honestly:** #68 has 0 fails in both CHUNAO and IMTIHAN, so it uses its risk budget timidly. New small legs added little:
#67 at 0.15% saved ~0.5 months and #76 BTC at 0.5% saved 0.3. The big lever is **how risk is spent**: by phase, by cushion, and by overlap.
New markets rank lower. Almost every market FTMO offers is already "dekha hua". The one market never seen in this repo is bonds, and FTMO probably does not offer them.

## A) What to download (not in data/ yet; JAS_ZIP already has 31 H1 and duka_get.py knows GAS/COPPER/SUGAR/NLD)
| # | QDM / Dukascopy symbol | TF | Why | FTMO symbol | Cost / note |
|---|---|---|---|---|---|
| 1 | USTBOND.TR/USD, BUND.TR/EUR, UKGILT.TR/GBP (names UNVERIFIED, search "BOND"/"BUND" in QDM) | H1 | Only asset class never seen here. Bonds are the classic trend diversifier, with low or negative equity correlation in sell-offs (MOP 2012) | **check, likely NOT offered** -> mostly for a personal account | Dukascopy history likely starts ~2015-17 (check) = thin TALAASH |
| 2 | GAS.CMD/USD | H1 | Natgas has ~0 correlation with equities and gold | NATGAS.cash? check | **heavy**: wide spread, contango roll in the swap; TV Kachhua already saw it (+0.025R) |
| 3 | COPPER.CMD/USD | H1 | Industrial cycle, partly separate from US tech | XCUUSD? check | measured 0.056% (ok); seen in TV basket |
| 4 | SUGAR.CMD/USD | H1 | Ag, uncorrelated, **not seen in repo** | SUGAR.c? check | **heavy** spread; ag trend failed on cost before |
| 5 | NLD.IDX/EUR | H1 | 8th market for the khirki (#67 rule unchanged) | N25.cash | cheap, but correlated with DAX/CAC = small gain |
| 6 | ETHUSD | H1 | Pair for the BTC Kachhua bank leg | ETHUSD | ~0.8 correlation with BTC, FTMO commission 0.065% round trip, seen (IMOM) |
Skip: XPT/XPD (not on Dukascopy, costs 0.25% / 0.55%), the forex crosses (user dropped currency), M1 data (not needed for the ideas below).
Wheat and corn are on FTMO, but Dukascopy has no feed (check QDM's other sources).

## B) Ranked ideas
**1. Phase-2 risk step-up (P2 = 1.5x every leg, P1 unchanged).** The mechanism: P2 needs only +5% but keeps the full 10% max-loss buffer
and a fresh daily 5%. With drift mu and vol s, P(ruin before target) ~ depends on target/loss ratio and both scale with 1/risk;
at the same risk P2's ruin odds are far below P1's, so P2 can carry more risk at a similar total fail rate. P2 is ~1/3 of
the time (target half of P1's), so 1.5x saves roughly 1/3 of P2: **~1-1.5 months off the median (11.4 -> ~10)**, plus a few P2 fails.
Evidence: gambler's-ruin / first-passage math (no market fitting); never tested (grep "P2 risk" = 0). Not a new edge, so the
"dekha hua" rule bites less: it is a structural rule, and it can be pre-registered with one number (1.5).
**This needs the user's explicit OK, because it raises risk.** Test CHUNAO first. Keep the 4% daily guard and check the worst day with every leg open at 1.5x. P(useful) ~0.6.

**2. Cushion sizing (Grossman-Zhou 1993 Math Finance; CPPI Black-Perold 1992).** Risk per trade = base x (equity - 90k)/10k,
clipped to [0.5x, 1.25x]. When ahead, size grows a little (anti-martingale, not averaging). When behind, it shrinks fast, so a run of losses can hardly reach -10%.
This is the optimal policy for a hard floor. It buys fail headroom, so base risk can stay put while the median falls (~0.5-1 month), or it pays for idea 1.
Risk: 2020-style gaps before any shrink happens. The up-side cap (1.25x) raises risk -> user OK. P ~0.45. Not tested (no grep hits).

**3. Overlap cap + equal-risk reallocation (budget neutral).** IBS on US500 and USTEC fire on the same dip days, so in practice
that is one ~2% bet. Trend on US500 and USTEC is a second shared bet. Rule: open risk in the "US equity cluster" is capped at e.g. 2%,
and the freed budget goes to gold/silver trend and the khirki (7 non-US index, the only leg with 7-way breadth).
The khirki would go from 0.15% to ~0.3%. That raises one leg's risk, so it needs the user's OK, even though the total open risk does not grow.
Effect: mostly a thinner tail, time -0 to -0.7 months. Risk: overfitting the weights on CHUNAO, so pre-register 1/N per cluster. P ~0.3.

**4. Bond TSMOM leg (new market, the truly unseen one).** Daily Kachhua or 4H Supertrend (#34 rule unchanged) on UST/Bund/Gilt.
Prior: MOP 2012 JFE and Hurst-Ooi-Pedersen 2017 (a century of trend): bonds carry some of the best TSMOM Sharpe ratios, and they
diversify equities, especially in 2022-type rate trends where equities fell. **The blocker: FTMO very likely does not list bonds (check).** If it
does not -> personal account only, no FTMO effect. If it does: ~0.5-1 month at 0.5%. Thin data (< 2019 maybe 2-4 years). P(FTMO useful) ~0.1.

**5. Halloween risk tilt on the index legs (Bouman-Jacobsen 2002 AER; Jacobsen-Zhang 2018, 300+ yrs OOS; Andrade et al 2013 OOS).**
Nov-Apr index risk x1.2 and May-Oct x0.8, budget neutral. Never tested here, but it uses seen markets and the post-2015 evidence is mixed. Effect < 0.5 months. P ~0.15.

**Not proposed (already failed or banned):** TOM, VIX, FOMC/pre-FOMC, forex anything, ag/oil/PGM trend (cost), US2000 IBS (correlated, daur4 #2),
ETH trend, vol-cap alone (daur4 #3, untested but it mostly cuts fails, same family as #2 here), grid/averaging/hedge.
**Suggested order:** #1 alone (one count, CHUNAO -> IMTIHAN once), then #2 or #3. All three are sizing rules with no new signal.
They change how fast the account moves, not the edge, so the user decides on risk, and the demo must show the 4% daily guard holds.
