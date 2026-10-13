# JAS-SNIPER-BOT

MetaTrader 5 EAs aur TradingView Pine scripts (gold, index, commodity) - user Jalal ke liye.

**Har nayi chat:** pehle `TRADING-MERI-KAHANI.md` (pakki kahani, accounts, qaide), phir
`TRADING-ABHI-KAHAN-HAIN.md` (abhi kya chal raha hai) parho. User ko kahani 0 se na
dohrani pare. Roman Urdu, chhota aur saaf, "aap". Hamesha backtest -> demo -> live.

## Usage bachao (13 Oct qaida)

- Ye file har message ke saath load hoti hai - **chhoti rakho**. Is mein sirf
  nayi file ki EK line jorni hai; haal / nateeje / tareekh yahan NAHI.
- Haal aur nateeje `TRADING-ABHI-KAHAN-HAIN.md` mein (~150 line se lambi ho to purana
  hissa `docs/purana-haal.md` mein). Pakke sabaq `TRADING-MERI-KAHANI.md` mein.
- Purani tafseel parhni ho to poori file nahi - `grep` se:
  `docs/purana-haal.md` (purana haal, koshish 1-15) aur `docs/files-tafseel.md`
  (har file ki lambi kahani, build-wise).
- Agent / workflow sirf jab user khud naam le kar maange; hafte ki limit 50%+ ho
  to bilkul nahi.

## Files (ek line har ek - tafseel `docs/files-tafseel.md`)

**Demo par chal rahe EA** (demo 472716649):
| File | Kya |
|---|---|
| `JasTideRadarEA.mq5` | Kachhua (Tide 1) ek chart se kai market. Magic 20261009 (gold wale 9) aur 20261018 (commodity 6) |
| `JasRsi2EA.mq5` | Connors RSI(2), US500/USTEC/US30, magic 20261012 |
| `JasIbsEA.mq5` | IBS sirf US500 (koshish #15 ASLI PASS), magic 20261022 - demo se pehle i3 (TRADING-ABHI-KAHAN-HAIN) |

**Live / kitab ke aalay:**
| File | Kya |
|---|---|
| `JasDeskView.mq5` | Sirf parhne wala panel: Close-All ginti, lots, ausat, NET, bari lot ki jori (live chal raha) |
| `JasJoriClose.mq5` | SCRIPT: bari lot ki jori Close By se band (live 64/64) |
| `JasDesk.mq5` | Button wala desk (user ne hata diya) |

**FAIL / band EA** (sirf record): `JasGrailEA` (#1-2), `JasVbEA` (#3), `JasTsmomEA` (#4),
`JasImomEA` (#9), `JasTrendScalpEA` (#12), `JasTide4hEA` (#13), `JasMtfEA`, `JasSmcScalpEA`,
`JasOrbEA`, `JasChakkarEA` (k4), `JasFishingEA` (f1), `JasBasketEA` + `_BTC` (user ki
basket method; `_BTC` ko `tools/make_btc.py` banata hai, haath se mat badlo), `JasTideEA` (t4).

**Pine - naap / radar (`indicators/`):** `jas_tide_radar` (Kachhua 9 market), `jas_tide_tokri`
(commodity, #6 PASS), `jas_rsi2_radar`, `jas_ibs_radar` (#14-15), `jas_tom_radar` (#5),
`jas_ichimoku_radar` (#7-8), `jas_coint_radar` (#10-11), ginti scripts (`jas_*_ginti`),
`jas_tide_smc`, `jas_tide_seekh`, `jas_tide_signal`, `jas_seerhi`, `jas_pro_box`,
`smc_coach_pro_v3/v4`, `smc_coach_scalp_v6`, `smc_trend_pro`, aur doosron ke scripts
(`supertrend_v6`, `ob_radar`, `gainzalgo_ml_smc`, `analogue_matcher_v2`, `candle_xray`,
`fishing_live`, `trend_ribbon_levels`).

**Pine - strategy Tester (`strategies/`):** `jas_ibs_test` (IBS S&P, radar jaisa, trade list),
`jas_rsi2_test`, `jas_tide_seekh_test` (Kachhua 1D), `jas_tide2_test`, `jas_tide_smc_test`,
`jas_seerhi_test`, `jas_pro_box_test`, `smc_coach_scalp_test`, `fishing_lots_test`,
`jas_tide_v1`, `tony_ema_scalper_test`. `sniper_backtest.pine` (purana SMA cross, alag).

**Docs / qaide:** `TRADING-MERI-KAHANI.md`, `TRADING-ABHI-KAHAN-HAIN.md`, `METHOD.md` (user ki Fishing Lots
method - trade wali cheez chhoone se pehle parho), `EA-LAWS.md`, `EA-QAWAID.md`,
`EA-CHECKLIST.md` (nayi file lagane ke 23 qadam), `docs/*_naqsha.md`, `docs/*rehnuma.html`
(artifact guides - file badle to wohi file publish = wohi URL).

**tools/:** `pinecheck.py` (Pine ki jaanch, compile nahi), `tide_ea_check.py`, `trend_check.py`,
`numayan_check.py`, `fishing_sim.py`, `simulate.py`, `test_logic.py`, `make_btc.py`,
`compile.bat/.ps1`, `backtest.bat/.ps1` (Windows + MT5).

## Hard rules for these EAs

Never add grid, martingale, hedging, or position averaging to any EA here
unless the user asks for it explicitly and by name in the current session.
Every EA holds at most one position per market at a time.

This rule is about the EAs in this repo, not a judgement on the user's own
Fishing Lots method (`METHOD.md`, a laddered, hedged basket by design). Describe
his method faithfully; do not graft it onto these EAs unasked.

Never widen a risk limit (risk percent, daily loss cap, max trades, drawdown
cap) on your own initiative. Those defaults are deliberate.

## MQL5 / Pine kaam ke qaide

- Har file ki pehli line par build number, panel par bhi wahi.
- `StringFormat("sirf likhai")` error deta hai - kam az kam ek value. String ke
  liye `cond ? "" : "..."` nahi, `Pick()` helper.
- Points vs digits: points-wali doori se pehle `SYMBOL_DIGITS` aur
  `SYMBOL_TRADE_STOPS_LEVEL` dekho (3-digit gold par 300 points = $0.30).
- Pine: `request.security` tuple 127 se kam; v6 mein `ta.*` if ke bahar.
- Windows par: `tools\compile.bat <file>` (log `.log.txt`, 0 errors tak theek
  karo), `tools\backtest.bat <EA>`; ek waqt mein ek input badlo.

## Cloud session mein kya nahi hota

claude.ai/code Linux container hai: MetaTrader nahi, `mql5.com` /
`tradingview.com` band. MQL5 compile aur Pine run yahan NAHI hote - saaf batao,
code haath se jaancho (`python3 tools/pinecheck.py <file>`), user F7 /
TradingView par compile kar ke screenshot bhejta hai.
