# TRADING — har nayi chat SIRF ye ek file parhe

**Nayi chat ka message (copy-paste):**
sirf `TRADING` (ye branch 14 Oct se GitHub default - nayi chat seedha yahin khulti hai).
Agar kabhi kaam na kare to lamba: `TRADING — repo JALAL786451/JAS-SNIPER-BOT, branch claude/jas-desk-v3-0110-yu3w2h. Sirf TRADING.md parho aur wahin se shuru karo.`

Aakhri update: 28 Oct 2026 (25vi chat). Ye file **~8 KB se lambi NA ho**. Baqi sab
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
**28 Oct (22vi chat):** JasIbsEA **i3** `4483a03` likha (H1 se 17:00 NY candle, faisla 16:55 NY, Jumma bhi) - F7 + Tester baqi (user ne roka).
22vi chat tafseel (#26 tokri, indicator t2 `e691715`, TV ✅ baqi): `docs/purana-haal.md` (grep "22vi chat").
**23vi chat** (FTMO maqsad: 2 EA + 4 instrument XAU/XAG/US500/US100, 15 din demo phir challenge, Swing account): `docs/purana-haal.md` grep "23vi chat".
**28 Oct (25vi chat): Koshish #27 JasTrend FTMO (Python `tools/ftmo_test.py`, data `data/ftmo/`) = qaide se PASS** (qaida `docs/purana-haal.md` grep "Koshish #27").
CHUNAO 2012-18 (12 setting): sirf **1% risk / SL 4xATR** shart par (6 pass, 0 fail, 78 adhoora). IMTIHAN 2019+ ek dafa: 94 challenge -> **80 pass, 0 fail**,
14 adhoora, pass ~**32 mahine** (median), 19 mein 4 din kam. Imaandari: fail kabhi nahi magar BOHOT dheema (1.2 tr/mahina), 2019+ tezi ka faida; challenge overlap (azad nahi).
**Koshish #28 IBS 4 market (Python `--ibs`) = TALAASH FAIL** (731 tr, Exp -0.001R, Exp-2SE -0.031; XAU -0.025, XAG -0.043, US500 +0.034, USTEC +0.075;
saal 18/43). Gold/chandi par IBS nahi chalta. IMTIHAN nahi khola. Qaida `docs/purana-haal.md` grep "Koshish #28".
**AGLI CHAT pehla kaam:** EA2 = Kachhua (#6) TALAASH Python mein inhi 4 par (qaida pehle likho, #28 jaisa) - fail = JasTrend akela. "D" nahi chahiye.
**RUKE HUE KAAM (user jab kahe; Pine par yaad dilao "sahi nateeja MT5 / data milne par Python"):**
- JasIbsEA i3 F7 + Tester US500m D1 2015-aaj (sec 6). Demo 3 EA (sec 7): 6 mahine (~Apr 2027), har trade TV se milao.
- QDM export (user, Generic bar, M1, Timezone Original): USATECHIDXUSD 2023-24, XAUUSD 2021-22, 2023-24 (+ 2015-2020) -> upload ->
  Python #21 (`JasOrb5EA`) phir #22 (Fib OTE). Dono ke qaide `docs/purana-haal.md` (grep "Koshish #21 qaida", "#22 qaida"). 2025+ mat kholo.

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
20 Kitab Tukda FAIL · **21 ORB USTEC 5m - data 2021-22 mila, 2023-24 baqi** · **22 Fib OTE gold 15m - data ka intezar** · 24 Supertrend gold 1D FAIL (425 tr, Exp 2.76$ - 2SE = -0.91; BUY +5.71, SELL -0.22; saal 27/77) · Aaina 1D andaza (Pine, 21 Oct) FAIL · 25 Supertrend sirf BUY FAIL (1D 1975-2018: 156 tr, Exp 0.27R, SE 0.151, Exp-2SE -0.032, saal 24/44; 4H/1H/15m < 100 tr - TV data kam) · **26 Supertrend tokri TALAASH PASS** (931 tr, Exp 0.248R, Exp-2SE +0.119, 6/6 market musbat, saal 31/44; `data/koshish26/talaash.csv`)  -> **IMTIHAN 2019-aaj ASLI PASS** (165 tr, Exp 0.455R, Exp-2SE +0.214, 6/6, saal 7/8; `imtihan.csv`) = demo ki taraf. · **27 JasTrend FTMO Python PASS** (1%/4xATR, 2019+ 80 pass / 0 fail, ~32 mahine) · 28 IBS 4 market FAIL.
Faida sirf daily par mila; zyada trades chahiye to zyada MARKET, chhoti TF nahi.

## 9. Chat ke aakhir mein (ye file zinda rahe)

- Sec 5 "PICHLI CHAT" naya likho (2-4 line: kya hua, agla kaam, "D" baqi ya nahi); kaam badla to sec 6-7.
- Naya pakka sabaq -> `docs/trading-pakki.md` sec 4 mein EK line, poore number `docs/sabaq-tafseel.md`.
- Naya pakka jawab -> `docs/sawal-jawab.md` mein EK line. Phir `python3 tools/roznamcha.py` (din ki file + FEHRIST.txt).
- Ye file 8 KB se lambi ho to purana hissa `docs/purana-haal.md` mein. `docs/files-tafseel.md` ki chhoti list mein nayi
  file ki ek line. Commit + push - apni branch AUR default `claude/jas-desk-v3-0110-yu3w2h` dono par.
