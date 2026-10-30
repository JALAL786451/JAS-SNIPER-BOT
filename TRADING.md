# TRADING — har nayi chat SIRF ye ek file parhe

**Nayi chat ka message (copy-paste):**
sirf `TRADING` (ye branch 14 Oct se GitHub default - nayi chat seedha yahin khulti hai).
Agar kabhi kaam na kare to lamba: `TRADING — repo JALAL786451/JAS-SNIPER-BOT, branch claude/jas-desk-v3-0110-yu3w2h. Sirf TRADING.md parho aur wahin se shuru karo.`

Aakhri update: 29 Oct 2026 (27vi chat, khatam). Ye file **~8 KB se lambi NA ho**. Baqi sab
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
| LIVE | 253687618 | Exness-MT5Real34, StandardCent, XAUUSDc, USC, swap-free, Hedge, 1:2000. Koi EA nahi |
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

**27vi chat (29 Oct)** - tafseel `docs/purana-haal.md` grep "27vi chat" + "Koshish #37".."#42". Purani 22-26vi: grep "sec 5 se (29 Oct 27vi".
5 naye FAIL: #38 failed breakdown, #39 TV Momentum H1, #40 VWAP, #41 Gao-Han-Li-Zhou (H1 proxy), #42 raat ka drift (asar asli, kharcha bara).
NichoR: <= H1 par CFD kharcha edge kha jata; PASS sirf 4H/daily (#34, #15). ~100 tr/mahina = ZYADA MARKET, chhoti TF nahi.
**DATA (user raat ko chalata hai):** laptop `Desktop\JAS\JAS_DATA.bat` -> `tools/duka_get.py` d3 = Dukascopy se
36 H1 all time + 4 index M1 2021-aaj (`docs/qdm-data-list.md`). Cloud se rok; d2 adhoora (4 saath + sleep), d3 aahista.
**DATA AA GAYA (31 Oct):** `data/duka/H1/JAS_ZIP/` 24 H1 zip (index, forex, oil, fasal, BTC, dollar) + `data/ftmo/` 4 = **28 market**. Kai 2017-19 se shuru
(TALAASH chhoti). Baqi (EURUSD, USDJPY, copper, gas, sugar, NLD, ETH, AUDUSD) baad mein QDM se. `tools/JAS_ZIP.bat` z3 (z2 chakkar wali ghalti theek).
**AGLA KAAM:** (a) #47 qaida PEHLE: #34 4H trend + pehra (group max 2, kul risk 3%) BARI tokri 28 market; trade ginti + FTMO. User "D".
(b) M1 -> #37 noise-boundary (qaida likha) + #41 asli. (c) din mein FTMO kaam (user: "raat = download, din = FTMO ke qareeb"). "D" nahi.
**Kitab (30 Oct raat, LIVE, gold 3,874):** 90 BUY 1.85 lot @3985.28 + 1 SELL 1.65 @3904.33 (dhaal), NET +0.20, kul -15,618 USC; equity ~34,700. $1 = 20 USC (~1,700$ door); SELL band = 185 USC/$ -> ~3,690 par khatam. Barabar 4,653.
**RUKE HUE KAAM (Pine par yaad dilao "sahi nateeja MT5 / Python"):** JasIbsEA i3 Tester US500m 2015-aaj (F7 ✅). Demo 6 EA (sec 7): ~Apr 2027 tak, har trade TV se milao.

## 6. RUKA HUA: JasIbsEA i3 (daily candle 17:00 NY) - naqsha `docs/purana-haal.md` ("RUKA HUA ... i3")

## 7. Demo (472716649) - 6 EA TRADE CHALU (t3 4H 29 Oct, user SS ✅)

| EA | Chart | Magic | Markets |
|---|---|---|---|
| JasTideRadarEA e1 (Kachhua) | XAUUSDm D1 | 20261009 | XAU, XAG, EUR, GBP, AUD, JPY, CHF, US500, BTC (9) |
| JasTideRadarEA e1 (Commodity) | XPTUSDm D1 | 20261018 | USOIL, UKOIL, XNGUSD, XCUUSD, XPTUSD, XPDUSD (6) |
| JasRsi2EA c2 | US500m H1 (EA D1 parhta) | 20261012 | US500, USTEC, US30 |
| JasIbsEA **i3** (F7 0 errors ✅) | US500m H1 (doosra chart) | 20261022 | US500 (faisla 16:55 NY) |
| **JasTrendEA t2** (28 Oct, 15 din) | XAUUSDm H1 (5wan chart) | 20261028 | XAU, XAG, US500, USTEC - pehra BAND (account par aur EA), GMT +0 ✅, Supertrend line Python se mili |
| **JasTrendEA t3 4H** (29 Oct, #34) | XAUUSDm H4 (6ta chart) | 20261029 | XAU, XAG, US500, USTEC - SL 6xATR, pehra band, Tester ✅ |

- Har EA ka faisla: kam az kam **6 mahine** (user 17 Oct, ~Apr 2027) + 10-15 band trades, har trade TV se mile. **Mila ✅ (user, pehle):** demo ki khuli trade TV Pine par bhi dikhi.
- IBS #15 (S&P ASLI PASS) ki tafseel + IBS demo qaida: `docs/purana-haal.md` (grep "IBS demo qaida").

## 8. Koshish ginti (tafseel `docs/purana-haal.md`, grep "Koshish ginti 17 Oct")

1-5 FAIL · **6 Kachhua commodity ASLI PASS (demo)** · 7-14 FAIL · **15 IBS S&P ASLI PASS (JasIbsEA)** ·
16 order flow SIKKA · 17 SELL band/dobara FAIL · 18 MA 63/91 + EMA 63/93, 20/50 (MT5) FAIL · 19 SMC: LGB/FVG FAIL, DZ/SZ 4H MT5 baqi ·
20 Kitab Tukda FAIL · **21 ORB USTEC 5m - data 2021-22 mila, 2023-24 baqi** · 22 Fib OTE gold 15m FAIL (Python M1 2021-24) · 24 Supertrend gold 1D FAIL · Aaina 1D andaza (Pine, 21 Oct) FAIL · 25 Supertrend sirf BUY FAIL · **26 Supertrend tokri TALAASH PASS**  -> **IMTIHAN 2019-aaj ASLI PASS** (165 tr +0.455R) = demo ki taraf. · **27 JasTrend FTMO Python PASS** (1%/4xATR, 2019+ 80 pass / 0 fail, ~32 mahine) · 28 IBS 4 market FAIL · 29 Kachhua 4 market FAIL · 30 gold H1 raat BUY / din SELL FAIL · 31 gold H4 RSI2 pullback FAIL · 32 gold daily rukh + H1 entry FAIL · 33 JAS Trend t2 gold 4H/1H/15m FAIL · **34 JAS Trend 4H TOKRI (XAU/XAG/US500/USTEC) ASLI PASS** (2019+ 641 tr, +0.208R, Exp-2SE +0.085, 4/4) · 35 4H tokri FTMO FAIL · 36 HTF+AOI+M30 engulfing gold FAIL · 37 noise-boundary (qaida likha, M1 baqi) · 38 failed breakdown · 39 TV Momentum H1 · 40 VWAP · 41 Gao-Han-Li-Zhou H1 · 42 raat drift = sab FAIL · 43 J Law (4H -0.11R) FAIL · 44 JJ Simon 1m (104 tr/mahina) FAIL · **45 Connors Double 7s ASLI PASS kamzor** (= IBS/RSI2 nakal, EA nahi) · 46 Bollinger squeeze + NR7 FAIL.
Faida daily + 4H TOKRI par; akela market chhoti TF par nahi.

## 9. Chat ke aakhir mein (ye file zinda rahe)

- Sec 5 "PICHLI CHAT" naya likho (2-4 line: kya hua, agla kaam, "D" baqi ya nahi); kaam badla to sec 6-7.
- Naya pakka sabaq -> `docs/trading-pakki.md` sec 4 mein EK line, poore number `docs/sabaq-tafseel.md`.
- Naya pakka jawab -> `docs/sawal-jawab.md` mein EK line. Phir `python3 tools/roznamcha.py` (din ki file + FEHRIST.txt).
- Ye file 8 KB se lambi ho to purana hissa `docs/purana-haal.md` mein. `docs/files-tafseel.md` ki chhoti list mein nayi
  file ki ek line. Commit + push - apni branch AUR default `claude/jas-desk-v3-0110-yu3w2h` dono par.
