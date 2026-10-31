# TRADING — har nayi chat SIRF ye ek file parhe

**Nayi chat ka message (copy-paste):**
sirf `TRADING` (ye branch 14 Oct se GitHub default - nayi chat seedha yahin khulti hai).
Agar kabhi kaam na kare to lamba: `TRADING — repo JALAL786451/JAS-SNIPER-BOT, branch claude/jas-desk-v3-0110-yu3w2h. Sirf TRADING.md parho aur wahin se shuru karo.`

Aakhri update: 31 Oct 2026 (28vi chat). Ye file **~8 KB se lambi NA ho**. Baqi sab
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

- Hafte ki limit ~50% (31 Oct; reset Itwar). Reset se pehle nayi chat ka faida nahi (user) - isi chat mein kaam.
  Agent / workflow sirf jab user naam le kar maange; 50%+ par bilkul nahi.
- Nayi chat ~1 lakh token se shuru hoti hai (app ki apni hidayat ~40-60k). Effort **medium/high**
  (xhigh nahi), chhota kaam Sonnet. Har tool qadam par poori chat dobara parhi jati hai -
  kam qadam, chhote jawab, bari file `grep` se. **~15-20 message ya kaam khatam = user "chat khatam"
  likhe -> sec 5 likh kar push -> nayi chat "TRADING"** (chat bharne / summary ka intezar NAHI).

## 3. Accounts (tafseel `docs/trading-pakki.md` sec 2)

| | Number | Kya |
|---|---|---|
| LIVE | 253687618 | Exness-MT5Real34, StandardCent, XAUUSDc, USC, swap-free, Hedge, 1:2000. Koi EA nahi |
| DEMO | 472716649 | Exness-MT5Trial16, USD, Hedge - saare EA demo yahin |
| **FTMO DEMO** | **474832446** | Exness-MT5Trial15, Standard, USD **$100k**, 1:100 (31 Oct) - #53: JasTrendEA t4 4H 0.75% + JasIbsEA i5 US500+USTEC 1% |

Doosre demo: 472540009, 474651829 Pro. EA wale chart ke saath live par login kabhi nahi.

## 4. Test ka qaida (13 Oct - badalna mana)

1. Naya idea sirf **TALAASH** data par: MT5 2021-2024, TradingView shuru-2018. Jitni koshish chahein.
2. TALAASH PASS (trades >= 100, Exp - 2SE > 0, saal ka hissa musbat) -> **IMTIHAN** (MT5 2025-aaj /
   TV 2019-aaj) **ek dafa**, bina tabdeeli. IMTIHAN data tab tak chhupa.
3. IMTIHAN Exp > 0 + trades >= 30 = **ASLI PASS** -> demo. Nateeja dekh kar market chuna to IMTIHAN
   sakht: **Exp - 2SE > 0**. IMTIHAN FAIL = idea band.
4. Qaida test se PEHLE likho; har koshish sec 8 ki ginti mein. Gold 2025-26 tezi: BUY/SELL alag dekho.

## 5. PICHLI CHAT (har chat ke aakhir mein sirf ye hissa naya likho)

**28vi chat (30-31 Oct)** - tafseel `docs/purana-haal.md` grep "28vi chat" + "Koshish #43".."#54". Purani 27vi: grep "sec 5 se (31 Oct 28vi".
DATA: 28 market H1 (`data/duka/H1/JAS_ZIP/` 24 + `data/ftmo/` 4) + M1 US500/USTEC 2021-24 (`data/qdm/M1/`). Baqi (EURUSD, USDJPY, copper, gas, sugar, NLD, ETH, AUDUSD) baad mein QDM.
#43-#52 FAIL / chhote PASS -> **#53 FTMO mansooba ASLI PASS**. #37 noise boundary FAIL (andaze ka kharcha 0.03%) -> `JasSpreadNaap` s1 ne asli spread naapa
(US500 0.40, USTEC 1.12, gold 0.24 = andaze se 10-16 guna kam; chandi 0.025 mehngi) -> **#54 TALAASH PASS** (2021-24: +0.113R, ~38 tr/mahina, saal 4/4, jeet 42%).
**1 Nov:** #54 IMTIHAN 2025+ FAIL (edge 2025-26 mein khatam), #21 ORB TALAASH FAIL (2023-24 kamzor). #53 asli kharche se median 11.7 mahine (83/0/11). #55 trend 1H FAIL.
**AGLA KAAM:** (a) agli talaash - Claude ka faisla, qaida pehle (US index intraday paper wale band: edge ghisa).
(b) **FTMO DEMO (474832446) = #53** TRADE CHALU: JasTrendEA t4 (XAUUSDm H4, 4 market, 0.75%, pehra 110k/96k/92k) + JasIbsEA i5 (US500m D1, US500+USTEC, 1%).
Somwar: pehli trades + TV `JAS FTMO 53 f2` dabba ka SS milao; 1-2 hafte baad VPS, phir FTMO challenge.
(c) Baad: asli kharche se purane chhoti TF FAIL (#41 M1, #42) dobara - har ek ka qaida pehle, alag number. BTC + Kachhua. User: "strategy badlo, 2-3 par atke hain", 2-4 tr roz ek instrument.
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

## 8. Koshish ginti (poori line `docs/purana-haal.md`, grep "Koshish ginti 31 Oct")

1-5 FAIL · **6 Kachhua commodity ASLI PASS** · 7-14 FAIL · **15 IBS S&P ASLI PASS** · 16-25 FAIL / sikka (19 SMC DZ/SZ 4H MT5 baqi; 21 ORB USTEC 5m asli kharcha FAIL 1 Nov) ·
**26 Supertrend tokri ASLI PASS** · **27 JasTrend FTMO PASS** · 28-33 FAIL · **34 JAS Trend 4H TOKRI ASLI PASS** · 35-44 FAIL (37 noise boundary 0.03% kharcha par) ·
**45 Double 7s ASLI PASS kamzor** · 46-48, 50, 51 FAIL · **49 FTMO trend + IBS S&P ASLI PASS** · **52 teacher: USTEC IBS ASLI PASS** ·
**53 FTMO #49 + IBS USTEC 1% ASLI PASS (2019+ 83/0, 2012-aaj +92%, DD 13.4%) = FTMO mansooba** · 54 = #37 + asli spread: TALAASH PASS +0.113R, **IMTIHAN 2025+ FAIL** (-0.037R, bina kharcha bhi -) = band. · 55 #34 trend tokri 1H (asli kharcha) FAIL.
Faida daily + 4H TOKRI par; chhoti TF ab asli kharche se dobara (har ek pehle se likh kar).

## 9. Chat ke aakhir mein (ye file zinda rahe)

- Sec 5 "PICHLI CHAT" naya likho (2-4 line: kya hua, agla kaam, "D" baqi ya nahi); kaam badla to sec 6-7.
- Naya pakka sabaq -> `docs/trading-pakki.md` sec 4 mein EK line, poore number `docs/sabaq-tafseel.md`.
- Naya pakka jawab -> `docs/sawal-jawab.md` mein EK line. Phir `python3 tools/roznamcha.py` (din ki file + FEHRIST.txt).
- Ye file 8 KB se lambi ho to purana hissa `docs/purana-haal.md` mein. `docs/files-tafseel.md` ki chhoti list mein nayi
  file ki ek line. Commit + push - apni branch AUR default `claude/jas-desk-v3-0110-yu3w2h` dono par.
