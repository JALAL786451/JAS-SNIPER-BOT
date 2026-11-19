# Koshish #107g - Gold ki EK script: Tide 1D BUY + 4H BUY (t5) ek saath, aur "BUY mat lo" zone (user 18 Nov "haan")

Qaida test se PEHLE likha aur commit kiya gaya. Nateeja dekhne ke baad badalna MANA hai.

## User ki demand
Sirf gold ki Pine script chahiye:
- BUY ki tasdeeq kare.
- Zones / S/R batayein "BUY mat lo / SELL mat lo".
- Zones ASLI PASS hui strategy ke hisab se math hon.

Isliye zones = engine ke apne level:
- 10 din ka high (Tide toot)
- 5 din ka low (Tide sarakta SL)
- 4H Supertrend lakeer
- 1D EMA50 / EMA200

Gold SELL #106s mein FAIL hua, is liye SELL hamesha "mat lo".

## Engine (koi tabdeeli nahi)
- **T = Tide 1D BUY:**
  - Entry: close > pichhle 10 din ka high, D1 EMA50 > EMA200 (pichhla din), ATR14 >= 0.25%. Entry usi close par.
  - SL 2 x ATR14, har din pichhle 5 din ke low tak sarakta.
  - Band: candle SL chhuye (gap par open), ya EMA50 < EMA200 (close), ya close sarakte SL ke neeche.
  - SELL band (#106s). Radar r3 / `tools/tide_ea_check.py` jaisa.
- **F = 4H BUY (t5 / Rehnuma r1):** `tools/rehnuma_r2_test.py run(h4, +1, 6.0)` jaisa.
  - Supertrend(10,3) 4H upar mude to agli open BUY. SL 6 x ATR10(4H). Neeche mude to agli open band.
- Kharcha (dono par ek jaisa, sakht): 0.03% har taraf + swap 3% saal (BUY). FTMO / live cent swap-free hain, to asal mein kam.
- Data: `data/ftmo/XAU_XAG_H1_dukascopy.zip` (gold H1), din NY 17:00 se.
- Risk: har engine 0.5% fi trade. Account % shuru ke balance par (compounding nahi), trade band hone ke din.
- Daur: TALAASH 2003-2018 | IMTIHAN 2019-aaj (EK dafa).

## Sawal aur PASS / FAIL
**S1 - dono BUY mil kar kamate hain?**
- TALAASH:
  - T aur F dono ka Exp > 0.
  - DONO (sab trade ikatthe) Exp - 2SE > 0 (R mein).
- IMTIHAN:
  - T aur F dono ka Exp > 0.
  - DONO ka kul % > 0.
- Dono daur pass = script mein DONO BUY (lot / SL ke saath).
- Warna sirf wo engine jo dono daur mein Exp > 0 ho.

**S2 - dohra risk?** (pass / fail nahi, design ka faisla pehle se)
- Naap: jitne din T khula tha, un mein se kitne % din F bhi khula tha (aur ulta), aur mahana % ka correlation.
- Agar T ke khule dinon mein F > 50% bhi khula ho:
  - Script likhegi "dono khule = kul risk 1 trade jitna" (har ek aadha).
- Warna: har engine apna poora risk.

**S3 - bara zone (1D EMA50 < EMA200) 4H BUY ke liye "BUY mat lo" ho?**
- F ki trades do group mein:
  - zone theek (entry se pichhle din EMA50 > EMA200)
  - "mat lo" (EMA50 < EMA200)
- TALAASH: Exp(theek) - Exp(mat lo) > 2 x SE(farq), dono group >= 30 trade.
- IMTIHAN (sirf TALAASH pass par): farq usi taraf, aur filter wali F ka kul % >= bina filter ka 90%.
- PASS = script mein 4H BUY par bhi "BUY mat lo" (rok). FAIL = 4H ke liye sirf ittila. t5 EA waisa hi rahega (user 15 Nov: 1D filter nahi).
- Tide ke apne zone (10 din high, 5 din low, EMA) Tide ke liye pehle se qaida hain. Un ka koi alag test nahi.

## Imaandari note
- Dono engine ke 2019+ ke nateeje pehle alag alag dekhe ja chuke hain: #34, #106s, Rehnuma r2.
- S3 jaisa 1D **Supertrend** filter (EMA nahi) `tools/rehnuma_1d_test.py` mein pehle dekha gaya tha: aadhi trades, behtar R / trade, kul R kam.

## NATEEJA (18 Nov, `python3 tools/gold_do_buy.py`)
T ki trades Python pine_engine se hoo-ba-hoo mili (88 / 54).

| Daur | Engine | Trade | Exp R (-2SE) | Kul % (0.5% risk) | Girawat | Bura mahina |
|---|---|---|---|---|---|---|
| 2003-18 | T Tide 1D | 88 | +0.219 (-0.044) | +9.6% | 2.8% | -0.77% |
| 2003-18 | F 4H t5 | 282 | +0.099 (+0.005) | +13.9% | 3.7% | -0.74% |
| 2003-18 | **DONO** | 370 | **+0.127 (+0.033)** | **+23.5%** | 4.6% | -1.11% |
| 2019-aaj | T Tide 1D | 54 | +0.321 (-0.130) | +8.7% | 2.1% | -0.52% |
| 2019-aaj | F 4H t5 | 154 | +0.157 (+0.008) | +12.1% | 3.6% | -0.79% |
| 2019-aaj | **DONO** | 208 | **+0.200 (+0.039)** | **+20.8%** | 4.9% | -0.97% |

- **S1 PASS** (TALAASH aur IMTIHAN dono): script mein DONO BUY.
- **S2:** T ke khule dinon mein F bhi 89% (2003-18) / 82% (2019+) khula tha. Mahana corr +0.40 / +0.45.
  - 50% se zyada = qaide ke mutabiq: "dono khule = kul risk 1 trade jitna (har ek aadha)".
- **S3 FAIL** (TALAASH farq +0.053 = +0.58 SE, shart 2 SE): 4H ke liye 1D EMA zone sirf ittila.
  - Galti ka iqrar: pehle run mein code ne S3 ka IMTIHAN number bhi chhap diya tha (+0.30 SE), jo qaide ke khilaf tha. Faisla sirf TALAASH FAIL par hai. Code durust kar diya (ab IMTIHAN nahi chalta).
