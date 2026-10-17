# TRADING — har nayi chat SIRF ye ek file parhe

**Nayi chat ka message (copy-paste):**
sirf `TRADING` (ye branch 14 Oct se GitHub default - nayi chat seedha yahin khulti hai).
Agar kabhi kaam na kare to lamba: `TRADING — repo JALAL786451/JAS-SNIPER-BOT, branch claude/jas-desk-v3-0110-yu3w2h. Sirf TRADING.md parho aur wahin se shuru karo.`

Aakhri update: 13 Oct 2026 raat (saatvi chat). Ye file **~8 KB se lambi NA ho**. Baqi sab
sirf zaroorat par, poori file nahi - `grep` se:
- `docs/trading-pakki.md` - accounts, user ki method, har pakka sabaq ki ek line, live kitab
- `docs/sabaq-tafseel.md` - sabaq ke poore number
- `docs/purana-haal.md` - purana haal, koshish 1-15 ke pehle se likhe qaide
- `docs/files-tafseel.md` - har file ki lambi kahani; files ki list bhi yahin; `CLAUDE.md` - sirf EA/MQL5 qaide

Purani files mein `TRADING-MERI-KAHANI` likha ho = ab `docs/trading-pakki.md`;
`TRADING-ABHI-KAHAN-HAIN` = ab ye file (purana hissa `docs/purana-haal.md`).

---

## 1. User aur baat ka tareeqa

- Jalal, Pakistan (PKT, UTC+5), gold (XAUUSD) trader ~1.5 saal. **Roman Urdu**, chhota aur
  saaf, hamesha **"aap"**. Misaal aur table, lambi tehreer nahi.
- **SBS:** ek waqt ek qadam; user har qadam ke baad **"D"** likhta hai. Pehle poochho, phir file banao.
- **Faisle Claude kare:** A/B/C mat poochho - mashwara khud lo, bata do kya aur kyun, sirf
  **AGLA EK QADAM**. Sawal sirf paisa / account / na-palatne wali cheez par.
- Chhota jawab (A/B/D) aaye aur do sawal khule hon to ek line mein poochho kis ka jawab hai.
- Link click hone wala + commit hash wala raw link. "Aaraam karo" / jawab ke aakhir mein
  yaad-dihani NAHI. "Ruk jayein" mat kaho - agla idea do.
- Chart bilkul saaf: indicator sirf ishara; lakeerein / rang / tables settings mein BAND.
- **USER KA PAKKA FAISLA (17 Oct):** koi bhi EA / Pine qaidon ke khilaf live par KABHI nahi. Koi EA live par nahi jab tak
  **6 mahine ka demo nateeja** na ho. Claude is se pehle live / "thoda live try" / qaida todne ka mashwara NA de - user jaanta hai.
  User Pine / EA maange = expert ke qaide samajhna aur test karna; ehtiyat Claude ke mashwaray se 2 guna khud rakhta hai -
  har dafa ehtiyat ka lecture NAHI, seedha kaam.
- **EA ka kaam ho to pehle `CLAUDE.md`** (hard rules: grid / martingale / hedging / averaging
  nahi, risk limit khud na barhao). Cloud mein MT5 compile nahi - user F7 kar ke screenshot bhejta hai.

## 2. Usage bachao

- Hafte ki limit **80%** (14 Oct; reset Itwar 18 Oct 02:00 PKT). Agent / workflow sirf jab
  user naam le kar maange; 50%+ par bilkul nahi.
- Nayi chat ~1 lakh token se shuru hoti hai (app ki apni hidayat ~40-60k). Effort **medium/high**
  (xhigh nahi), chhota kaam Sonnet. Har tool qadam par poori chat dobara parhi jati hai -
  kam qadam, chhote jawab, bari file `grep` se. **~15-20 message ya kaam khatam = user "chat khatam"
  likhe -> sec 5 likh kar push -> nayi chat "TRADING"** (chat bharne / summary ka intezar NAHI).

## 3. Accounts (tafseel `docs/trading-pakki.md` sec 2)

| | Number | Kya |
|---|---|---|
| LIVE | 253687618 | Exness StandardCent, XAUUSDc, USC, swap-free, Hedge, 1:2000. Koi EA nahi |
| DEMO | 472716649 | Exness-MT5Trial16, USD, Hedge - saare EA demo yahin |

Doosre demo: 472540009, 474651829 Pro. EA wale chart ke saath live par login kabhi nahi.

## 4. Test ka qaida (13 Oct - badalna mana)

1. Naya idea sirf **TALAASH** data par: MT5 2021-2024, TradingView shuru-2018. Jitni koshish chahein.
2. TALAASH PASS (trades >= 100, Exp - 2SE > 0, saal ka hissa musbat) -> **IMTIHAN** (MT5 2025-aaj /
   TV 2019-aaj) **ek dafa**, bina tabdeeli. IMTIHAN data tab tak chhupa.
3. IMTIHAN Exp > 0 + trades >= 30 = **ASLI PASS** -> demo. Nateeja dekh kar market chuna to IMTIHAN
   sakht: **Exp - 2SE > 0**. IMTIHAN FAIL = idea band.
4. Qaida test se PEHLE likho; har koshish sec 8 ki ginti mein. Gold 2025-26 tezi: BUY/SELL alag dekho.

## 5. PICHLI CHAT (har chat ke aakhir mein sirf ye hissa naya likho)

**16 Oct shaam (dasvi chat, LIVE):** Exness email: 17 Oct se MT5 Real server par **max 200 khule orders** (user server Real 34).
Kitab 287 pos -> 150 se neeche laana ZAROORI (warna hedge ki nayi lot nahi khulegi). Tool: `JasJoriClose.mq5` **s4 QAREEB**
(bari lot ke qareeb oopar+neeche lots, nateeja >= 0) + **s5** (ek chakkar 25 jori) - live ✅: 293 -> **183 pos**, balance
49,580 -> **50,089** (+508), equity 43,743 (wahi). Kitab ab: BUY 50 pos 1.33 lot ausat 4203.3 (sab 4190+), SELL 133 x 0.01 =
1.33 ausat 4155.8 (sab 4190 se neeche), NET 0, khula -6,345. Ab koi >=0 jori nahi bachi (har BUY har SELL se oopar). `JasKitabSaathi.mq5` x3 EA (panel par 200 had)
(panel + Yes/No buttons, NET tukda 0.01 had 0.10, sirf band karta hai) compile + demo BAQI. Mobile: One Click Trading band.
Hifazat (Lot Guard 0.10+) user ne baad ke liye rakha. **Agla (SBS):** (1) DO MT5: yahi wala = LIVE (253687618, koi EA nahi, Algo band, trade levels chhupe ✅); nayi install
`C:\MT5-DEMO` = demo 472716649 + 3 PASS EA (TideRadar 20261009 XAUUSDm D1, TideRadar 20261018 XPTUSDm D1 commodity,
Rsi2 20261012 US500m D1; InpTrade true) - aaj EA demo charts se hat gaye the (login 472540009 par tha). (2) KitabSaathi **x5 compile ✅** (user
screenshot, F7 dobara NAHI; user ki MT5 file ka naam `JasKitabSathi-x4-EA.mq5` magar andar x5 - theek hai) -> USD demo 472540009 XAUUSDm, haath ki 5 BUY + 5 SELL 0.01 se test (cent demo hota hi NAHI) -> live. MT5 se fail EA delete (list chat mein).

**16 Oct raat (11vi chat):** CSV 12:30: 183 pos, jori NAHI bachi (sasti BUY 4194.30 > mehngi SELL 4188.87). **Claude ghalti:** qeemat ke paas
10 SELL -> 1 SELL 0.10 kaha = zakheera (pakki sec 4 "0/faida") toot-ta - WAPAS liya. 200 had ka sahi: mehngi BUY 0.01 (4202-4217) 10 -> 1 BUY 0.10
(NET 0, equity wahi, balance ~-380) - user ka "D" baqi. Raasta C (NET tukda 0.01, had 0.10, KitabSaathi buttons) = had wala wapsi raasta.
**17 Oct:** TideRadar EA "sirf dikhana" -> TRADE CHALU; Commodity + Rsi2 EA ka panel check BAQI. TV 1D vs 15m Tide = match (15m data sirf 2 Aug se, 0 trade dono). TV 30m/15m = data 3-5 mahine = test NAHI.
**Koshish #21 qaida (user 'D', 17 Oct, badalna mana):** paper jaisa SIRF USTEC 5m (30m/US500/US30/BTC paper mein nahi = NAHI). `JasOrb5EA.mq5` o1
bana. **Exness USTECm data sirf 2025.09.21 se** (Tester: no history 2021-24) = Exness par TALAASH NAHI ho sakti. Data: Dukascopy
website Export = SIRF EK DIN fi file (17 Oct dekha) - 1000 din haath se NAHI. Agla: Dukascopy JForex demo (Historical
Data Manager) ya free downloader (Tickstory / QuantDataManager) se 2021-24 M5 Bid+Ask -> Claude Python test; ya doosre broker ka demo MT5 sirf Tester ke liye. Phir KitabSaathi demo test.
Nayi chat: `docs/trading-pakki.md` sec 4 aur `docs/purana-haal.md` aakhri hissa bhi grep karo (mashwaray wahan).

**16 Oct (dasvi chat, tests):** #20 Kitab Tukda, #17, #18 (63/91, 63/93, 20/50 x 15m-1D) MT5 par sab FAIL (sec 8). 47 jori NAHI. Peshgoi #2 PASS.

## 6. RUKA HUA: JasIbsEA i3 (daily candle 17:00 NY) - naqsha `docs/purana-haal.md` ("RUKA HUA ... i3")

## 7. Demo (472716649) aur IBS ka haal

| EA | Chart | Magic | Markets | Haal 13 Oct |
|---|---|---|---|---|
| JasTideRadarEA e1 (Kachhua) | XAUUSDm D1 | 20261009 | XAU, XAG, EUR, GBP, AUD, JPY, CHF, US500, BTC | 17 Oct: "SIRF DIKHANA" mila -> theek, ab TRADE CHALU (USDJPYm D1 chart). Radar ki XAG SELL (13 din) + EUR SELL (23 din) EA band hone mein chhoot gayin - TV milaap mein in ko "chhooti" likho. USDJPYm BUY 0.33 @ 158.527, SL 157.510. Gold NEECHE: SELL < 4066.30 |
| JasRsi2EA c2 | US500m D1 | 20261012 | US500, USTEC, US30 | intezar |
| JasTideRadarEA e1 (Commodity) | XPTUSDm D1 | 20261018 | USOIL, UKOIL, XNGUSD, XCUUSD, XPTUSD, XPDUSD | 16 Oct: USOIL BUY 0.05 @ 93.810, SL 86.126 (TP nahi - qaida) |

- Har EA ka faisla: kam az kam **6 mahine** (user 17 Oct, ~Apr 2027) + 10-15 band trades, har trade TV se mile. **Mila ✅ (user, pehle):** demo ki khuli trade TV Pine par bhi dikhi.
- **IBS #15:** TALAASH S&P 320 trades +0.047 -> IMTIHAN 190 trades +0.082R (±0.053), sakht +0.029.
  `jas_ibs_test.pine` t1 = radar (510 trades, PF 1.52, DD 3.4%). JasIbsEA i2 compile ✅, Tester 8
  trades (Exness US500 data Sep 2025 se) = shor. Faide ka saboot TV IMTIHAN hai, demo nahi.
- **IBS demo qaida (pehle se likha):** naya US500m D1 chart (RSI2 wala alag), InpTrade true, 3 mahine +
  10 band trades. PASS = har trade TV IBS signal din (±1) se mile, sirf BUY, koi bina SL nahi.

## 8. Koshish ginti (tafseel `docs/purana-haal.md`)

1-2 Holy Grail FAIL · 3 Volatility Breakout FAIL · 4 TSMOM FAIL · 5 Turn-of-Month FAIL ·
**6 Kachhua commodity ASLI PASS (demo)** · 7-8 Ichimoku FAIL · 9 Intraday Momentum FAIL ·
10-11 Cointegration FAIL · 12 user ka 15m $1/$2 FAIL · 13 Kachhua 4H FAIL · 14 IBS 10 index FAIL ·
**15 IBS S&P ASLI PASS (JasIbsEA)** · 17 SELL band/dobara (M1 2021-23, spread kha jata) FAIL · 20 Kitab Tukda (1D+4H EMA63/93, 4H) TALAASH FAIL · 18 MA 63/91 (`jas_ma6391_test.pine` m3 ATR SL 1.5x, TP 2x): TV 1H 2025-26 72 tr 40% PF 1.86 +$863;
4H 2023-26 40 tr PF 1.48; 1m 90 tr Exp +0.10 (±0.16). **MT5 TALAASH (16 Oct, `tools/ma6391_mt5_test.py`, M1 2021-23):** 1H 140 tr PF 0.86, Exp -0.099R
(±0.118), saal -16.2/+7.1/-4.7R; 1m 8,875 tr PF 0.51, Exp -0.48R (kharcha kha jata) = **#18 FAIL**. User ke kehne par 8 aur
(EMA 63/93 aur 20/50 x 15m/1H/4H/1D, MT5 2021-23/24): PF 0.92/0.84/0.80/0.99 aur 0.80/1.04/0.85/0.56 - sab FAIL (20/50 1H
321 tr Exp +0.025 ±0.080 sab se acha, phir bhi sikka).
19 SMC (`jas_smc_test.pine` k1, D1 rukh, SL wick+0.1ATR, TP 2R): LGB 15m/1H/4H/1D sab FAIL (1H 150 tr PF 0.64);
FVG 1D kul 420 tr PF 1.32 magar TALAASH (2018 tak) PF ~0.7 = FAIL (faida sirf 2019+ tezi); DZ/SZ 4H 2023-26 162 tr PF 1.19 -> MT5 TALAASH baqi. Gold intraday 8 idea bhi FAIL (purane qaide se).
Faida sirf daily par mila; zyada trades chahiye to zyada MARKET, chhoti TF nahi.

## 9. Chat ke aakhir mein (ye file zinda rahe)

- Sec 5 "PICHLI CHAT" naya likho (2-4 line: kya hua, agla kaam, "D" baqi ya nahi); kaam badla to sec 6-7.
- Naya pakka sabaq -> `docs/trading-pakki.md` sec 4 mein EK line, poore number `docs/sabaq-tafseel.md`.
- Ye file 8 KB se lambi ho to purana hissa `docs/purana-haal.md` mein. `docs/files-tafseel.md` ki chhoti list mein nayi
  file ki ek line. Commit + push.
