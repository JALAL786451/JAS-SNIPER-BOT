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
- Hamesha backtest -> demo -> live. Live par koi EA tab tak nahi jab tak demo PASS.
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

**16 Oct (navi chat):** `ob_radar.pine` r2 - user ka MA = EMA 63/93 (20/50 nahi). Legend ke neeche SIGNAL qatar:
1D+4H MA ek taraf + 1H/2H zone ke ANDAR + 15m naya OB (2 candles) = TAYYAR. TEST NAHI HUA (koshish #19 SMC zone 4H PF 1.19 dekho). Compile ✅ (16 Oct, 4 chart: "Intezar SELL taraf", 15m OB 6 purana). r3 legend transparent ✅. r4 = MA default 63/93 (paste par 20/50 ho gaya tha). r5 = RUKH KI SEERHI (jo bhi MA): KHINCH (X ATR door) / MOD (fast MA jhukao palta) / PAKKA (cross) + alerts, compile ✅ magar MOD ka jungle. r6 ✅. r7 = user: chart par SIRF OB khaane + aakhri ▲▼ + legend; MA lakeer aur seerhi default BAND (alert chalu), compile BAQI.

**14 Oct (aathvi chat):** CLAUDE.md 5 -> 2 KB. Koshish #16 = user ka draft `docs/es_orderflow_draft.md`
(Carmine Rosato ES order flow -> XAUUSD 5m). Pine `indicators/jas_of_draft.pine` d4 (compile ✅): Q1-Q3 signal +
T-YES/T-NO/MISS (5m ~1.5 din: 2 signal -2R, MISS -2.8R) aur box toot ginti. **d4 barabar paimana (±1 ATR):
1D 179/378 = 47% (±5) · 4H 66/131 = 50% (±9) · 5m 121/254 = 48% (±6) = teeno SIKKA**, box toot ke saath ya
ulta 1:1 par koi edge nahi (Kachhua ki edge 1:1 se nahi naapi jati - lambi jeet). Footprint/heatmap gold CFD par
mumkin nahi. i3 (sec 6) user ne roka. Agents/judges user ne band kiye (18 Oct 02:00 reset tak).
`jas_tide_smc` s2.8 (S/R sirf dekhna, default band). `docs/peshgoi-kitab.md` #1: 3,886.47 toote, 13 Nov tak.
**LIVE kitab (14 Oct, JasDeskView v5.2):** 186 pos (BUY 2.17 ausat 4189.9 / SELL 2.14 ausat 4165.4), NET +0.03 jami,
Close All ~-5,590, Balance 49,026, Equity 43,483. Teh: neeche sasti BUY · beech SELL · oopar mehngi BUY.
SAB SELL band = har $1 par 217 USC, ~$200 girawat = account khatam -> NET 0.50 se zyada NAHI, 0.20 tukde.
Mashwara: abhi jori/band kuch NAHI. **Claude ki ghalti:** "bina nuqsan jori" ka mashwara diya jo neeche wali
BUY kha jati - user ne pakra. Sabaq: jori se pehle BACHI kitab dekho. JasDeskView v5.3 (QEEMAT KI SEERHI $10 +
har lot CSV `MQL5\Files\JasDeskView_XAUUSDc.csv`) compile BAQI. JasJoriClose s2 (InpMehngiPehle, default false).
v5.3 compile ✅, CSV mili (14 Oct 17:32, bid 4088.9). **Kitab = 3 hissay:** (a) SELL 2.14 (4153-4189) +16,321 ≈
(b) mehngi BUY 1.44 (4190-4367) -16,368 = aapas mein barabar; (c) baqi BUY 0.73 (4101-4190, ausat ~4165) = poora
nuqsan -5,540. Swap-free, NET 0.03 -> 3900 par -6.1k, 4300 par -4.9k. (a)+(b) band = 0.73 BUY khuli (har $1 = 73 USC) - NAHI.
**Koshish #17 idea (user, 14 Oct):** SELL (BUY se oopar) gold oopar jaye to +0.30 USC/0.01 par band; wapsi = band qeemat
par ya chotti se $5 neeche (jo oopar ho) wohi lot SELL dobara. User ne "HAN" kaha (14 Oct, test ki ijazat). Kitab NET +0.03 BUY; EA band SELL milaa kar NET 0.50 se zyada NAHI.
Peshgoi #2 LGB (4066-4155, PASS = 4185 pehle) - `docs/peshgoi-kitab.md`, har nayi chat check.
Lot Guard EA idea (0.10+ nayi position foran band) - user ne "abhi nahi" kaha.
**Agla:** live par kuch nahi; 18 Oct ke baad #17 Python test (X = 3/5/10) + MT5 Q1.

## 6. RUKA HUA (user ne yaad mein rakha, 14 Oct): JasIbsEA i3

**Kyun:** i2 Tester ki 8 trades TradingView (`strategies/jas_ibs_test.pine`) se milayin: 6/8 signal
din same; 6 mili trades TV -0.07R vs MT5 -0.93R. Engine ki ghalti NAHI. Wajah:
1. **Candle ka waqt:** OANDA (TV) daily candle 17:00 New York par band, Exness 00:00 GMT (20:00 NY).
2. **Jumma:** Pine Jumma close par trade karta hai, EA Itwar raat (weekend gap: 24 Jul +46, 11 Sep -42).

**Naqsha:**
- EA apni daily candle H1 (ya M1) se banaye, **17:00 NY par band** (US DST khud - `UsDst` /
  `InpServerGMT` code `JasImomEA.mq5` se copy).
- Faisla 17:00 NY se **~5 minute pehle**, Jumma ko bhi. Tick na aaye (chhutti) to bazaar khulne par
  mukammal candle se (i2 jaisa).
- Baqi WAHI: IBS < 0.2 + close > SMA200 = BUY; band IBS > 0.8 ya 5 din; SL 3 ATR(14) RMA; 1%;
  SL wale din nayi nahi; magic 20261022; Journal TRADE lines (i2).
- **Jaanch:** Tester US500m Daily, 2015.01.01 - aaj, 1 minute OHLC, 10000 USD. Signal din TV se
  BILKUL milein: 13 Jul, 20 Jul, 24 Jul, 05 Aug, 14 Aug, 28 Aug, 04 Sep, 23 Sep, 30 Sep.

## 7. Demo (472716649) aur IBS ka haal

| EA | Chart | Magic | Markets | Haal 13 Oct |
|---|---|---|---|---|
| JasTideRadarEA e1 (Kachhua) | XAUUSDm D1 | 20261009 | XAU, XAG, EUR, GBP, AUD, JPY, CHF, US500, BTC | USDJPYm BUY 0.33 @ 158.527, SL 156.394 |
| JasRsi2EA c2 | US500m D1 | 20261012 | US500, USTEC, US30 | intezar |
| JasTideRadarEA e1 (Commodity) | XPTUSDm D1 | 20261018 | USOIL, UKOIL, XNGUSD, XCUUSD, XPTUSD, XPDUSD | intezar |

- Har EA ka faisla: kam az kam 3 mahine + 10-15 band trades (~Jan 2027), har trade TV se mile.
- **IBS #15:** TALAASH S&P 320 trades +0.047 -> IMTIHAN 190 trades +0.082R (±0.053), sakht +0.029.
  `jas_ibs_test.pine` t1 = radar (510 trades, PF 1.52, DD 3.4%). JasIbsEA i2 compile ✅, Tester 8
  trades (Exness US500 data Sep 2025 se) = shor. Faide ka saboot TV IMTIHAN hai, demo nahi.
- **IBS demo qaida (pehle se likha):** naya US500m D1 chart (RSI2 wala alag), InpTrade true, 3 mahine +
  10 band trades. PASS = har trade TV IBS signal din (±1) se mile, sirf BUY, koi bina SL nahi.

## 8. Koshish ginti (tafseel `docs/purana-haal.md`)

1-2 Holy Grail FAIL · 3 Volatility Breakout FAIL · 4 TSMOM FAIL · 5 Turn-of-Month FAIL ·
**6 Kachhua commodity ASLI PASS (demo)** · 7-8 Ichimoku FAIL · 9 Intraday Momentum FAIL ·
10-11 Cointegration FAIL · 12 user ka 15m $1/$2 FAIL · 13 Kachhua 4H FAIL · 14 IBS 10 index FAIL ·
**15 IBS S&P ASLI PASS (JasIbsEA)** · 18 MA 63/91 (`jas_ma6391_test.pine` m3 ATR SL 1.5x, TP 2x): TV 1H 2025-26 72 tr 40% PF 1.86 +$863;
4H 2023-26 40 tr PF 1.48; 1m 90 tr Exp +0.10 (±0.16) = abhi SABIT NAHI (TV data kam) -> MT5 1H 2021-24 TALAASH (18 Oct ke baad).
19 SMC (`jas_smc_test.pine` k1, D1 rukh, SL wick+0.1ATR, TP 2R): LGB 15m/1H/4H/1D sab FAIL (1H 150 tr PF 0.64);
FVG 1D kul 420 tr PF 1.32 magar TALAASH (2018 tak) PF ~0.7 = FAIL (faida sirf 2019+ tezi); DZ/SZ 4H 2023-26 162 tr PF 1.19 -> MT5 TALAASH baqi. Gold intraday 8 idea bhi FAIL (purane qaide se).
Faida sirf daily par mila; zyada trades chahiye to zyada MARKET, chhoti TF nahi.

## 9. Chat ke aakhir mein (ye file zinda rahe)

- Sec 5 "PICHLI CHAT" naya likho (2-4 line: kya hua, agla kaam, "D" baqi ya nahi); kaam badla to sec 6-7.
- Naya pakka sabaq -> `docs/trading-pakki.md` sec 4 mein EK line, poore number `docs/sabaq-tafseel.md`.
- Ye file 8 KB se lambi ho to purana hissa `docs/purana-haal.md` mein. `docs/files-tafseel.md` ki chhoti list mein nayi
  file ki ek line. Commit + push.
