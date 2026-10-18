# TRADING — har nayi chat SIRF ye ek file parhe

**Nayi chat ka message (copy-paste):**
sirf `TRADING` (ye branch 14 Oct se GitHub default - nayi chat seedha yahin khulti hai).
Agar kabhi kaam na kare to lamba: `TRADING — repo JALAL786451/JAS-SNIPER-BOT, branch claude/jas-desk-v3-0110-yu3w2h. Sirf TRADING.md parho aur wahin se shuru karo.`

Aakhri update: 18 Oct 2026 raat (12vi chat). Ye file **~8 KB se lambi NA ho**. Baqi sab
sirf zaroorat par, poori file nahi - `grep` se:
- `docs/trading-pakki.md` - accounts, user ki method, har pakka sabaq ki ek line, live kitab
- `docs/sabaq-tafseel.md` - sabaq ke poore number
- `docs/purana-haal.md` - purana haal, koshish 1-15 ke pehle se likhe qaide
- `docs/roznamcha/README.md` - **din ba din** (har tareekh ki file, git commits): user "X tareekh tak peechhe jao" kahe to yahin se
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
- **Pata na ho to (user 17 Oct):** andaza NAHI - saaf kaho "ye mujhe pata nahi" aur poochho: "`docs/roznamcha/` mein
  X tareekh dekhun?" Ijazat par sirf EK DIN peechhe, phir dobara poochho. Fehrist: `docs/roznamcha/FEHRIST.txt`.
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

**Kitab (16 Oct, LIVE):** 183 pos (200 had 17 Oct se), BUY 50 pos 1.33 ausat 4203 (sab 4194+) / SELL 133 x 0.01 = 1.33
ausat 4155.8 (sab 4189 se neeche), NET 0, khula ~-6,342, balance 50,089, equity ~43,743. JasJoriClose s5 se 293->183; ab >=0 jori NAHI.
Lot Guard baad mein. Tafseel `docs/purana-haal.md` ("16 Oct shaam").

16 Oct raat (11vi chat) ka haal (200 had, Raasta C): `docs/purana-haal.md` grep "16 Oct raat (11vi".
**17 Oct:** TideRadar EA "sirf dikhana" -> TRADE CHALU; Commodity + Rsi2 EA ka panel check BAQI. TV 1D vs 15m Tide = match (15m data sirf 2 Aug se, 0 trade dono). TV 30m/15m = data 3-5 mahine = test NAHI.
**18 Oct (12vi chat):** user ka Fib indicator theek kiya -> `indicators/jas_fib_swing.pine` f5 (trade box, 1% risk, aaj/sab din table).  QDM se Dukascopy USATECHIDXUSD M1 download (2012.01-2026.10, UTC). Export (Generic bar format, M1, Timezone
Original) 2021-01-03 -> 2022-12-30 poora mila, repo mein `data/ustec/USTEC_M1_2021-2022_dukascopy.zip` (sirf Bid, Ask nahi = spread fixed, zyada rakho).
**AGLA EK QADAM:** QDM Export 2023.01.01-2024.12.31 (prefix `2023-24`) -> upload -> Python test #21 (`JasOrb5EA`, UTC->NY). 2025+ mat kholo.
Phir #22 ke liye QDM Dukascopy XAUUSD M1 2021-24 (2-2 saal export, free had ~6.8 lakh line). Phir Commodity + Rsi2 panel, KitabSaathi demo.
**Koshish #22 qaida (user 'D', 18 Oct, badalna mana) - Fib OTE (`indicators/jas_fib_swing.pine` f5):** XAUUSD 15m, swing 1H pivot 5
(band candle), entry 0.618 limit, SL swing + 5% swing, TP 1.272, intraday (din khatam band), 1 trade ek waqt / 1 fi leg, risk 1%,
ek candle mein SL+TP = SL, spread asli se zyada. TALAASH 2021-24: trades >= 100, Exp - 2SE > 0. TV par pehle dekha (2026 ke
haal ke mahine, spread nahi): BTC 15m 89 trade -6.5R, gold 15m 58 trade +2.7R - market nateeja dekh kar chuna = IMTIHAN SAKHT (Exp - 2SE > 0).
**Koshish #21 qaida (user 'D', 17 Oct, badalna mana):** paper jaisa SIRF USTEC 5m (30m/US500/US30/BTC paper mein nahi = NAHI). `JasOrb5EA.mq5` o1
bana. **Exness USTECm data sirf 2025.09.21 se** (Tester: no history 2021-24) = Exness par TALAASH NAHI ho sakti. Data: Dukascopy
website = ek din fi file; is liye QDM.
Nayi chat: `docs/trading-pakki.md` sec 4 aur `docs/purana-haal.md` aakhri hissa bhi grep karo (mashwaray wahan).

## 6. RUKA HUA: JasIbsEA i3 (daily candle 17:00 NY) - naqsha `docs/purana-haal.md` ("RUKA HUA ... i3")

## 7. Demo (472716649) aur IBS ka haal

| EA | Chart | Magic | Markets | Haal 13 Oct |
|---|---|---|---|---|
| JasTideRadarEA e1 (Kachhua) | XAUUSDm D1 | 20261009 | XAU, XAG, EUR, GBP, AUD, JPY, CHF, US500, BTC | 17 Oct: "SIRF DIKHANA" mila -> theek, ab TRADE CHALU (USDJPYm D1 chart). Radar ki XAG SELL (13 din) + EUR SELL (23 din) EA band hone mein chhoot gayin - TV milaap mein in ko "chhooti" likho. USDJPYm BUY 0.33 @ 158.527, SL 157.510. Gold NEECHE: SELL < 4066.30 |
| JasRsi2EA c2 | US500m D1 | 20261012 | US500, USTEC, US30 | intezar |
| JasTideRadarEA e1 (Commodity) | XPTUSDm D1 | 20261018 | USOIL, UKOIL, XNGUSD, XCUUSD, XPTUSD, XPDUSD | 16 Oct: USOIL BUY 0.05 @ 93.810, SL 86.126 (TP nahi - qaida) |

- Har EA ka faisla: kam az kam **6 mahine** (user 17 Oct, ~Apr 2027) + 10-15 band trades, har trade TV se mile. **Mila ✅ (user, pehle):** demo ki khuli trade TV Pine par bhi dikhi.
- IBS #15 (S&P ASLI PASS) ki tafseel + IBS demo qaida: `docs/purana-haal.md` (grep "IBS demo qaida").

## 8. Koshish ginti (tafseel `docs/purana-haal.md`, grep "Koshish ginti 17 Oct")

1-5 FAIL · **6 Kachhua commodity ASLI PASS (demo)** · 7-14 FAIL · **15 IBS S&P ASLI PASS (JasIbsEA)** ·
16 order flow SIKKA · 17 SELL band/dobara FAIL · 18 MA 63/91 + EMA 63/93, 20/50 (MT5) FAIL · 19 SMC: LGB/FVG FAIL, DZ/SZ 4H MT5 baqi ·
20 Kitab Tukda FAIL · **21 ORB USTEC 5m - data 2021-22 mila, 2023-24 baqi** · **22 Fib OTE gold 15m - data ka intezar**.
Faida sirf daily par mila; zyada trades chahiye to zyada MARKET, chhoti TF nahi.

## 9. Chat ke aakhir mein (ye file zinda rahe)

- Sec 5 "PICHLI CHAT" naya likho (2-4 line: kya hua, agla kaam, "D" baqi ya nahi); kaam badla to sec 6-7.
- Naya pakka sabaq -> `docs/trading-pakki.md` sec 4 mein EK line, poore number `docs/sabaq-tafseel.md`.
- Naya pakka jawab -> `docs/sawal-jawab.md` mein EK line. Phir `python3 tools/roznamcha.py` (din ki file + FEHRIST.txt).
- Ye file 8 KB se lambi ho to purana hissa `docs/purana-haal.md` mein. `docs/files-tafseel.md` ki chhoti list mein nayi
  file ki ek line. Commit + push - apni branch AUR default `claude/jas-desk-v3-0110-yu3w2h` dono par.
