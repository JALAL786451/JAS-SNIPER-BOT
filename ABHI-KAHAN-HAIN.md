# ABHI KAHAN HAIN — nayi chat ke liye

**Pehchan ka code: `JAS-DESK-V3-0110`** — ye code mile to pehle `MERI-KAHANI.md`, phir ye file.

**Nayi chat ka code (copy-paste):** `JAS-DESK-V3-0110 — repo JALAL786451/JAS-SNIPER-BOT, branch claude/jas-desk-v3-0110-yu3w2h. Pehle MERI-KAHANI.md, phir ABHI-KAHAN-HAIN.md parho aur wahin se shuru karo.`

Aakhri update: 13 Oct 2026 raat (chhati chat). Ye file **chhoti** rehni chahiye (~150 line);
purana haal `docs/purana-haal.md` mein (grep se dhoondo, poori mat parho).

**Usage (13 Oct raat):** hafta 71% (reset Itwar 18 Oct 02:00 PKT). Koi agent/workflow nahi,
jawab chhote, bara kaam nayi chat mein. CLAUDE.md har message ke saath lagti hai - usay sirf
nayi file par ek line ke liye chhoona.

---

## AGLA KAAM: JasIbsEA i3 (user ka 'D' BAQI - pehle poochho)

**Kyun:** i2 ke Tester ki 8 trades TradingView (`strategies/jas_ibs_test.pine`) se milayin:
6/8 ka signal din same, 2 MT5 ne zyada li, TV ki 3 MT5 ne nahi li; 6 mili trades TV -0.07R vs
MT5 -0.93R. Engine ki ghalti NAHI (jahan candle ek, trade bilkul mili). Wajah:
1. **Candle ka waqt:** OANDA (TradingView) ki daily candle 17:00 New York par band, Exness ki
   00:00 GMT (20:00 NY) par -> IBS alag -> signal/band ka din kabhi aage peeche.
2. **Jumma:** Pine Jumma ke close par khareedta/bechta hai; EA Itwar raat bazaar khulne par
   (weekend gap: 24 Jul entry +46 mehngi, 11 Sep band -42).

**i3 ka naqsha (Claude ka faisla, D baqi):**
- EA apni daily candle khud banaye: H1 (ya M1) se, **17:00 NY par band** (OANDA jaisi; US DST
  khud - NY waqt ka code `JasImomEA.mq5` mein `UsDst` / `InpServerGMT` - repo se copy, user ke
  MT5 mein JasImomEA ki zaroorat NAHI).
- Faisla 17:00 NY se **~5 minute pehle** (abhi ki qeemat = close): entry / band Pine ki tarah
  close par, Jumma ko bhi. Agar us waqt tick na aaye (chhutti / jaldi band) to bazaar khulne par
  mukammal candle se (i2 jaisa).
- Baqi qaide WAHI: IBS < 0.2 + close > SMA200 = BUY; band IBS > 0.8 ya 5 din; SL signal close
  se 3 ATR(14) RMA; 1%; SL wale din nayi nahi; magic 20261022; Journal TRADE lines (i2 wali).
- **Jaanch foran:** wahi Tester run (US500m Daily, Custom 2015.01.01 - aaj, 1 minute OHLC,
  10000 USD). July-Oct ki trades ke signal din TV list se BILKUL milne chahiye:
  13 Jul, 20 Jul, 24 Jul, 05 Aug, 14 Aug, 28 Aug, 04 Sep, 23 Sep, 30 Sep (signal din, OANDA).
- Phir demo (qaida neeche).

## IBS (koshish #15) ka haal

- **Radar b2 ASLI PASS:** TALAASH S&P 320 trades +0.047 -> IMTIHAN 2019+ 190 trades
  +0.082R (±0.053), Exp - 2SE +0.029.
- **`strategies/jas_ibs_test.pine` t1 compile ✅:** OANDA:SPX500USD 1D, 510 trades =
  radar (320 ✓ / 190 ✓), PF 1.52, +35%, DD 3.4%. Band: IBS 423 · 5 din 58 · SL 29.
  Table mein aakhri 12 trades (signal din = OANDA candle band hone ka din).
- **JasIbsEA i1 -> i2 compile ✅.** Tester (US500m, Exness data sirf 21 Sep 2025 se, SMA200 ki
  wajah se trade ~July 2026 se): 8 trades, -0.84R (shor - faisla nahi). i2 Journal mein har
  trade ki `TRADE n | signal | khuli | band | R` line.
- **Hisaab:** +0.082R ko sifar se alag dikhane ke liye ~80 trades (~3.5 saal) chahiye -
  demo faida SABIT nahi karega, sirf ye ke EA qaide par chala. Faide ka saboot = TV IMTIHAN.
- **Demo qaida (pehle se likha, badalna mana):** demo 472716649, **naya US500m D1 chart**
  (RSI2 wala chart alag - ek chart ek EA), InpTrade true. Kam az kam 3 mahine + 10 band
  trades (~Jan 2027). PASS = har EA trade TradingView IBS signal din (±1 din) se mile
  (`jas_ibs_test.pine` list = radar ki trades), rukh BUY, koi bina SL position nahi; kul
  faida/nuqsan faisla nahi. US500 par RSI2 1% + IBS 1% = kabhi 2% - theek.

## DEMO par chal rahe (472716649) - koi kaam nahi, trade khule/band ho to panel screenshot

| EA | Chart | Magic | Markets | Haal 13 Oct |
|---|---|---|---|---|
| JasTideRadarEA e1 (Kachhua) | XAUUSDm D1 | 20261009 | XAU, XAG, EUR, GBP, AUD, JPY, CHF, US500, BTC | USDJPYm BUY 0.33 @ 158.527, SL 156.394 |
| JasRsi2EA c2 | US500m D1 | 20261012 | US500, USTEC, US30 | intezar |
| JasTideRadarEA e1 (Commodity) | XPTUSDm D1 | 20261018 | USOIL, UKOIL, XNGUSD, XCUUSD, XPTUSD, XPDUSD | intezar |

Har ek ka faisla: kam az kam 3 mahine + 10-15 band trades (~Jan 2027), EA qaidon par chala ya
nahi (har trade TradingView se mile). Jald chautha: JasIbsEA (i3 ke baad).

## KOSHISH-GINTI (naya test qaida - MERI-KAHANI '1-NAYA')

TALAASH (MT5 2021-24 / TradingView shuru-2018) jitni koshish; IMTIHAN (2025+ / 2019+) ek
dafa, chhupa jab tak TALAASH PASS; nateeja dekh kar market chuna to IMTIHAN sakht (Exp - 2SE > 0).

| # | Idea | Nateeja |
|---|---|---|
| 1-2 | Holy Grail (gold/silver, phir 7 market, H1/H4) | FAIL, 18/18 manfi |
| 3 | Larry Williams Volatility Breakout, 9 market | FAIL -0.046R, 1/9 |
| 4 | TSMOM (mahana), 9 market | FAIL - Exness MN1 data chhota |
| 5 | Turn-of-the-Month, 10 index | FAIL sakht 2SE (-0.044), 10/10 musbat |
| **6** | **Kachhua commodity tokri** | **ASLI PASS -> Commodity Radar demo** |
| 7-8 | Ichimoku, 9 market | FAIL (#8 -0.003 kinare par) |
| 9 | Intraday Momentum (Gao 2018) M30 | FAIL -0.207R, 0/9 (spread) |
| 10-11 | Cointegration (ADF / bina ADF) | FAIL - jori trading band |
| 12 | User ka 15m 0.01 TP $1 SL $2 | FAIL 89,203 trades, jeet 59.8% < 66.7% |
| 13 | Kachhua 4H, 9 market | FAIL +0.021R, 4/9 |
| 14 | IBS 10 index | FAIL kinare par (sakht -0.011) |
| **15** | **IBS sirf S&P, IMTIHAN sakht** | **ASLI PASS -> JasIbsEA** |

Alag (purane qaide se, sab FAIL): gold par 8 intraday idea (Pro Box, SMC Trend, Seerhi,
Fishing, Chakkar, ORB, SMC Scalp, MTF). Tafseel: `docs/purana-haal.md`.

## Sabaq jo yaad rakhne hain (tafseel MERI-KAHANI sec 4)

- Faida sirf daily par mila (Kachhua: gold, BTC, commodity; index ki chhoti wapsi: RSI2, IBS).
  Chhoti TF = spread + shor.
- Zyada trades chahiye to zyada MARKET daily par, chhoti TF nahi.
- TradingView ka PASS broker data par dobara jaancho; candle ka waqt bhi signal badal deta hai.
- MT5 Tester purane Inputs yaad rakhta hai - har naye EA ke baad Inputs tab dekho.
- User: "koshish chhorna meri tabiyat mein nahi" - 'ruk jayein' mat kaho, agla idea do.
