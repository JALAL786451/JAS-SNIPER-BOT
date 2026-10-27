# TRADING — har nayi chat SIRF ye ek file parhe

**Nayi chat ka message (copy-paste):**
sirf `TRADING` (ye branch 14 Oct se GitHub default - nayi chat seedha yahin khulti hai).
Agar kabhi kaam na kare to lamba: `TRADING — repo JALAL786451/JAS-SNIPER-BOT, branch claude/jas-desk-v3-0110-yu3w2h. Sirf TRADING.md parho aur wahin se shuru karo.`

Aakhri update: 27 Oct 2026 (20vi chat). Ye file **~8 KB se lambi NA ho**. Baqi sab
sirf zaroorat par, poori file nahi - `grep` se:
- `docs/trading-pakki.md` - accounts, user ki method, har pakka sabaq ki ek line, live kitab
- `docs/sabaq-tafseel.md` - sabaq ke poore number
- `docs/purana-haal.md` - purana haal, koshish 1-15 ke pehle se likhe qaide
- `docs/roznamcha/README.md` - **din ba din** (har tareekh ki file, git commits): user "X tareekh tak peechhe jao" kahe to yahin se
- `docs/files-tafseel.md` - har file ki lambi kahani; files ki list bhi yahin; `CLAUDE.md` - sirf EA/MQL5 qaide

Purana naam `TRADING-MERI-KAHANI` = `docs/trading-pakki.md`; `TRADING-ABHI-KAHAN-HAIN` = ye file.

---

## 1. User aur baat ka tareeqa (saari hidayat: `grep -i <lafz> docs/roznamcha/HIDAYAT.md`, poori nahi)

- Jalal, Pakistan (PKT, UTC+5), gold trader. **Roman Urdu**, chhota, **"aap"**, misaal + table.
- **SBS:** ek qadam, user "D" likhta hai; pehle poochho phir file. **Faisle Claude kare** - A/B/C nahi, sirf AGLA EK QADAM.
- Link click wala + commit hash raw link. Yaad-dihani / "aaraam karo" / ehtiyat ka lecture NAHI. Chart saaf (extra BAND).
- **Live KABHI nahi** jab tak 6 mahine demo nateeja na ho (user 17 Oct) - Claude live ka mashwara na de.
- **Pata na ho:** andaza nahi - poochho "roznamcha mein X tareekh dekhun?" (ek din). EA kaam: pehle `CLAUDE.md`.

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

**Kitab (16 Oct, LIVE):** 183 pos, NET 0, balance 50,089, equity ~43,743 - har lot `data/kitab/JasDeskView_XAUUSDc_2026-10-16_1230.csv`.
**20-27 Oct (20vi chat):** AAINA a15 (P/L spread ke baad) TV ✅: 15m -$0.18/trade, 1D -$0.03 = spread kha jata. a16 (EMA+IBS+Kachhua
ek number) = khichdi, user rad - hata di. a18 `c06dadd` = chart khaali (nishan / Record default band). Strategy `strategies/jas_aaina_test.pine`
t2 `abd5cfa` (Settings 7 "Trade kab se"): 1D 2019+ 1974 trades -$623, PF 0.968 = **FAIL** (spread se pehle bhi ~0). Aaina sirf dekhna.
**Tide+SMC:** s2.10 S/R ✅ · s2.11 (6 agent, har TF SMC) TV runtime error · **s2.12 `4e02fe9`** = nishan + RISK dabba WAQT se (error theek),
SMC + S/R default BAND (user: "bohot complicated") -> SMC ke liye TV ka **LuxAlgo "Smart Money Concepts"** saath. Versions: s2.8 `e48459b`, s2.9 `b35c676`.
**AGLI CHAT pehla kaam:** user s2.12 TV par lagaye (1m / 1H / 1D par tikta hai?) + LuxAlgo - screenshot dekho; error ho to SIRF wohi line theek.
**RUKE HUE KAAM (user jab kahe - khud mat chhero; Pine par sirf yaad dilao "sahi nateeja MT5 / data milne par Python"):**
- JasIbsEA i3 (sec 6). Demo 3 EA (sec 7): 6 mahine (~Apr 2027), har trade TV se milao.
- QDM export (user, Generic bar, M1, Timezone Original): USATECHIDXUSD 2023-24, XAUUSD 2021-22, 2023-24 (+ 2015-2020) -> upload ->
  Python #21 (`JasOrb5EA`, UTC->NY) phir #22. 2025+ mat kholo. #23 (1D rukh + 15m entry, Python) - aaina FAIL ke baad kamzor, user kahe to.
**Koshish #24 qaida (27 Oct, badalna mana) - Supertrend 10/3 (`jas_trend_pro_test.pine` s1):** XAUUSD 1D, BUY/SELL nishan par palat (agli open), SL = line paar band, 1 oz, 0.25$/taraf. TALAASH TV shuru-2018: trades >= 100, Exp - 2SE > 0, aadhe se zyada saal musbat; BUY/SELL alag.
**Koshish #22 qaida (18 Oct, badalna mana) - Fib OTE (`jas_fib_swing.pine` f5):** XAUUSD 15m, swing 1H pivot 5 (band candle),
entry 0.618 limit, SL swing + 5% swing, TP 1.272, intraday, 1 trade ek waqt / 1 fi leg, risk 1%, ek candle SL+TP = SL, spread
asli se zyada. TALAASH 2021-24: trades >= 100, Exp - 2SE > 0. TV pehli nazar (gold 58 trade +2.7R, bina spread) = IMTIHAN SAKHT.
**Koshish #21 qaida (17 Oct, badalna mana):** sirf USTEC 5m (`JasOrb5EA.mq5` o1). Exness USTECm data sirf 2025.09.21 se = Dukascopy (QDM).
Data 2021-22 repo mein `data/ustec/USTEC_M1_2021-2022_dukascopy.zip` (sirf Bid = spread fixed, zyada rakho).

## 6. RUKA HUA: JasIbsEA i3 (daily candle 17:00 NY) - naqsha `docs/purana-haal.md` ("RUKA HUA ... i3")

## 7. Demo (472716649) aur IBS ka haal

| EA | Chart | Magic | Markets | Haal 20 Oct (SS ✅) |
|---|---|---|---|---|
| JasTideRadarEA e1 (Kachhua) | XAUUSDm D1 | 20261009 | XAU, XAG, EUR, GBP, AUD, JPY, CHF, US500, BTC | TRADE CHALU, suffix 'm'. USDJPYm BUY 0.33 @ 158.527, SL 157.543. Chhooti (EA band tha): XAG SELL, EUR SELL. USDJPYm chart wala dusra EA hatana tha (ek magic = ek chart) |
| JasRsi2EA c2 | US500m D1 | 20261012 | US500, USTEC, US30 | Pehle XPTUSDm par tha (suffix '' = 3 market "nahi mila") -> US500m, TRADE CHALU, intezar |
| JasTideRadarEA e1 (Commodity) | XPTUSDm D1 | 20261018 | USOIL, UKOIL, XNGUSD, XCUUSD, XPTUSD, XPDUSD | Inputs gold wale ho gaye the -> theek. USOIL BUY 0.05 @ 93.810, SL 88.987 (+0.78R). Chhooti: UKOIL BUY, XPT SELL, XPD SELL |

- Har EA ka faisla: kam az kam **6 mahine** (user 17 Oct, ~Apr 2027) + 10-15 band trades, har trade TV se mile. **Mila ✅ (user, pehle):** demo ki khuli trade TV Pine par bhi dikhi.
- IBS #15 (S&P ASLI PASS) ki tafseel + IBS demo qaida: `docs/purana-haal.md` (grep "IBS demo qaida").

## 8. Koshish ginti (tafseel `docs/purana-haal.md`, grep "Koshish ginti 17 Oct")

1-5 FAIL · **6 Kachhua commodity ASLI PASS (demo)** · 7-14 FAIL · **15 IBS S&P ASLI PASS (JasIbsEA)** ·
16 order flow SIKKA · 17 SELL band/dobara FAIL · 18 MA 63/91 + EMA 63/93, 20/50 (MT5) FAIL · 19 SMC: LGB/FVG FAIL, DZ/SZ 4H MT5 baqi ·
20 Kitab Tukda FAIL · **21 ORB USTEC 5m - data 2021-22 mila, 2023-24 baqi** · **22 Fib OTE gold 15m - data ka intezar** · **24 Supertrend gold 1D - TALAASH chal raha** · Aaina 1D andaza (Pine, 21 Oct) FAIL.
Faida sirf daily par mila; zyada trades chahiye to zyada MARKET, chhoti TF nahi.

## 9. Chat ke aakhir mein (ye file zinda rahe)

- Sec 5 "PICHLI CHAT" naya likho (2-4 line: kya hua, agla kaam, "D" baqi ya nahi); kaam badla to sec 6-7.
- Naya pakka sabaq -> `docs/trading-pakki.md` sec 4 mein EK line, poore number `docs/sabaq-tafseel.md`.
- Naya pakka jawab -> `docs/sawal-jawab.md` mein EK line. Phir `python3 tools/roznamcha.py` (din ki file + FEHRIST.txt).
- Ye file 8 KB se lambi ho to purana hissa `docs/purana-haal.md` mein. `docs/files-tafseel.md` ki chhoti list mein nayi
  file ki ek line. Commit + push - apni branch AUR default `claude/jas-desk-v3-0110-yu3w2h` dono par.
