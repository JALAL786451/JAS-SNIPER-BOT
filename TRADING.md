# TRADING — har nayi chat SIRF ye ek file parhe

## 0. MT5 NAQSHA (sirf user ke SS se; har nayi chat ka PEHLA jawab ye table dikhaye, user tasdeeq kare)
MT5 ko hamesha TITLE BAR ke account number se bulao ("pehla/doosra" NAHI - user ne naam nahi rakhe). Yahan na ho = "pata nahi", andaza NAHI.
| Title bar account | Server | Qism | Balance | EA (chart) | Algo (ON/OFF) | Pakka |
|---|---|---|---|---|---|---|
| 474832446 | Exness-MT5Trial15 | FTMO demo, Standard USD | **balance 99,380.91, equity 99,463.63 (+82.72 khuli)** (shuru 100k se -619.09) | JasIbsEA i6 (US500m+USTECm D1), JasTrendEA t5 (XAU/XAG/US500/USTEC H4), JasKhirkiEA k2 (DE30m D1), **JasTideRadarEA e2 (BTCUSDm H4, 15 Nov TRADE CHALU)** | ON; khuli 2 (t5): US500 BUY 2.13 @7562.35 SL 7210.48 (+71.48, +0.10R) + USTEC BUY 0.36 @28170.41 SL 26138.98 (+11.24, +0.02R); e2 trade 0 (Juma ki candle par koi naya signal nahi; gold SELL 3852.301 / chandi SELL 48.465 se neeche D1 close par); band: i6 3 (+565.66, USTEC SL -996.43, +584.73 = +153.96), t5 3 (XAU +47.83, XAG -168.20, US500 -662.41 = -782.78), DIV +7.16; target baqi 10,536, aaj (16 Nov CET) farsh 95,381; k2 0; ML 37,808% | 16 Nov SS ~4-5 AM PKT (60vi, FTMO VIEW + e2 panel) |
| 472716649 | Exness-MT5Trial16 | demo **Standard USD (CENT NAHI)** | balance = equity 2,153.25, khuli 0 | JasIbsCentEA c1 (US500m D1), band trade 0; XAG SELL 0.05 (2 Nov, SL khali = hamara EA nahi) user ne 3 Nov band +153.25; Magic/Comment SS baqi (purana: `docs/purana-haal.md`) | ON | 4 Nov SS |
| 253687618 | Exness-MT5Real34 | LIVE Standard Cent (USC), swap-free | **16 Nov SS (61vi): equity 38,763.76; gold BUY 7.27 (73 tk, avg 4059.06) / SELL 7.27 (16 tk, avg 4030.49) = NET 0 (tala-band), P/L -20,943.10, tk 166 / 200, gold ~3853, rukh 1D + 4H DOWN; popup A) Close By SELL 1.06 @4051.993 + BUY 0.35 @3881.245 = +5976.18 (Claude: YES theek, NET wahi)** (pehle 12 Nov: equity 37,804.88, P/L -34,063, tk 152, WASOOLI 9237.32) (pehle 9 Nov: equity 38,995.64; purani tafseel `docs/purana-haal.md` grep "TRADING sec 0 se hataya (60vi") | JasMauqa **m8.4** user ke paas (repo mein m8.3; file K0 baqi), XAUUSDc + BTCUSDc | **ON** (YES/NO popup) | 16 Nov SS (61vi) |

**Nayi chat ka message (copy-paste):**
sirf `TRADING` (ye branch 14 Oct se GitHub default - nayi chat seedha yahin khulti hai).
Agar kabhi kaam na kare to lamba: `TRADING — repo JALAL786451/JAS-SNIPER-BOT, branch claude/jas-desk-v3-0110-yu3w2h. Sirf TRADING.md parho aur wahin se shuru karo.`

Aakhri update: 1 Nov 2026 (29vi chat). Ye file **~8 KB se lambi NA ho**. Baqi sab
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

- Hafte ki limit Itwar reset (1 Nov reset hui). Nayi chat bar bar mat kaho (user).
  Agent / workflow sirf jab user naam le kar maange; 50%+ par bilkul nahi.
- Nayi chat ~1 lakh token se shuru hoti hai (app ki apni hidayat ~40-60k). Effort **medium/high**
  (xhigh nahi), chhota kaam Sonnet. Har tool qadam par poori chat dobara parhi jati hai -
  kam qadam, chhote jawab, bari file `grep` se. **~15-20 message ya kaam khatam = user "chat khatam"
  likhe -> sec 5 likh kar push -> nayi chat "TRADING"** (chat bharne / summary ka intezar NAHI).

## 3. Accounts (tafseel `docs/trading-pakki.md` sec 2)

| | Number | Kya |
|---|---|---|
| LIVE | 253687618 | Exness-MT5Real34, StandardCent, XAUUSDc, USC, swap-free, Hedge, 1:2000. Koi EA nahi |
| DEMO | 472716649 | (31 Oct raat user ne DELETE kiya) |
| **FTMO DEMO** | **474832446** | Exness-MT5Trial15, Standard, USD **$100k**, 1:100 (31 Oct) - #53: JasTrendEA t5 + JasIbsEA i6 + JasKhirkiEA k2 (1 Nov) |

Doosre demo bhi delete (31 Oct). EA wale chart ke saath live par login kabhi nahi.

## 4. Test ka qaida (13 Oct - badalna mana)

1. Naya idea sirf **TALAASH** data par: MT5 2021-2024, TradingView shuru-2018. Jitni koshish chahein.
2. TALAASH PASS (trades >= 100, Exp - 2SE > 0, saal ka hissa musbat) -> **IMTIHAN** (MT5 2025-aaj /
   TV 2019-aaj) **ek dafa**, bina tabdeeli. IMTIHAN data tab tak chhupa.
3. IMTIHAN Exp > 0 + trades >= 30 = **ASLI PASS** -> demo. Nateeja dekh kar market chuna to IMTIHAN
   sakht: **Exp - 2SE > 0**. IMTIHAN FAIL = idea band.
4. Qaida test se PEHLE likho; har koshish sec 8 ki ginti mein. Gold 2025-26 tezi: BUY/SELL alag dekho.

## 5. PICHLI CHAT (har chat ke aakhir mein sirf ye hissa naya likho)

**61vi chat (16 Nov)** - **K9 HUA:** jor #101 tajziya (`docs/k9-jor-tajziya.md`): hissa i6 45% / e2 28% / t5 23% / k2 4%, mel <= 0.22, rokta + raftar dono t5, din ki hadd ka khatra sirf t5 + i6 US index ek saath (4 Jan 2016 -4.37%). **#105 behtar taqseem = CHUNAO FAIL** (IMTIHAN nahi khola) -> abhi wali theek, demo par kuch na badlein.
**K10 HUA:** demo 474832446 ki 8 / 8 trade Python signal se mili (`docs/k10-demo-milaan.md`, `tools/milaan_k10.py`). QDM ki screen Smart App Control ne roki -> `qdmcli.exe` seedha (symbol USA500IDXUSD / USATECHIDXUSD); chandi MT5 Export Bars se.
**User ka ASAL maqsad (K6):** "jis tarha trade leta hoon uska EA" - profit lots + jori khud band, loss par DEEWAR (ulti lot; user ne khud maanga), dohri lot pakre. m8.4 `.mq5` + 4 log aaye (K0 HUA; `JasMauqa_m84.mq5`, `data/live_253687618/mauqa_20261116/`).
**Nayi files (F7 BAQI, cloud mein compile nahi):** `JasLarai.mq5` **j2** (m8.4 + A / B jori KHUD + C KHUD jab NET na barhe + W) DEEWAR default OFF + X) DOHRI LOT popup; KHUD ki hadd InpAutoMax 1000) -> demo 472716649. `JasMauqa_m85.mq5` (m8.4 + popup mein Balance / Equity pehle -> baad) -> LIVE, user ne maanga.
LIVE 16 Nov: equity ~38,770, gold BUY 7.29 / SELL 7.27 (NET +0.02), BTC NET +0.02, tala-band ~-48,000, tk 167 / 200. Claude: jori (A / B) YES be-khatar (equity sirf spread jitni barhti), C (profit ticket) NA lein (deewar toot-ti).
**AGLA (62vi):** K11 = user se F7 SS (m8.5 + JasLarai j2) -> error theek -> j2 demo par imtihan (deewar OFF, phir popup ke saath), m8.5 LIVE par m8.4 ki jagah (InpWReset false). ~20 Nov FTMO Black Friday check. Demo 474832446: e2 / k2 ki pehli trade aaye to milaan.
**60vi chat** -> `docs/purana-haal.md` (grep "60vi").
**59vi chat** -> `docs/purana-haal.md` (grep "59vi").
**58vi / Fable K4 chat** -> `docs/purana-haal.md` (grep "Fable K4").
**57vi chat** -> `docs/purana-haal.md` (grep "57vi").
**56vi chat** -> `docs/purana-haal.md` (grep "56vi").
**55vi chat** -> `docs/purana-haal.md` (grep "55vi").
**54vi chat** -> `docs/purana-haal.md` (grep "54vi").
**53vi chat** -> `docs/purana-haal.md` (grep "53vi").

## 6-7. Demo (1 Nov): SIRF FTMO DEMO 474832446 chalu (user SS ✅)

| EA | Chart | Magic | Haal |
|---|---|---|---|
| **JasTrendEA t5** | XAUUSDm H4 | 20261029 | XAU, XAG, US500, USTEC - 4H, 0.75%, SL 6 ATR, judge replay = Python same |
| **JasIbsEA i6** | US500m D1 | 20261022 | US500, USTEC - 1%, faisla 16:15 NY |
| **JasKhirkiEA k2** | DE30m D1 | 20261101 | 7 non-US index 0.15% (1 Nov SS ✅; t5/i6 pehra +20261101) |
| **JasTideRadarEA e2** | BTCUSDm H4 | 20261115 | Kachhua 12 market 0.25% (#101), USD hadd 3, pehra poora account; TRADE CHALU 15 Nov (SS ✅); t5/i6/k2 ki pehra list mein 20261115 NAHI (e2 khud band karta) |

Pehra (teeno, poora account): target 110k + din 4% (96k farsh), kul hadd band (user "1"). Purane demo 472716649 / 472540009 (Radar, RSI2, i3, t2, t3)
user ne 31 Oct raat DELETE kiye - un ki tafseel `docs/purana-haal.md` grep "sec 6-7 se (1 Nov". Exness Demo ki `JasTideRadarEA.mq5` mein ghalti se t5 code
paste hua (chart par nahi laga) - zaroorat par GitHub wali e1 dobara.

**CENT DEMO (2 Nov, teesra MT5 folder "MetaTrader 5 Cent Demo"):** 472716649 Exness-MT5Trial16, USD, balance **$1000** (user ne set kiya). **JasIbsCentEA c1** US500m D1, magic 20261102,
US500m + USTECm, $10 risk x martingale 1.5x 3 qadam, $800 stop (hamesha, GV `JASIBSC_STOP_`). Panel TRADE CHALU (SS ✅). Real cent par koi EA nahi (6 mahine qaida).

## 8. Koshish ginti (poori line `docs/purana-haal.md`, grep "Koshish ginti 2 Nov")

105 koshish (**#105 jor #101 ki behtar taqseem (usi kul risk 8.80%) = CHUNAO FAIL** (83 ummeedwar, koi behtar nahi; abhi wali theek; `docs/k9-jor-tajziya.md`, 16 Nov); **#104 12-mahine momentum mahana (Kachhua 12 market) = TALAASH FAIL** (204 tr +0.128R, Exp-2SE -0.288, drift 0.76x; `tools/mom104.py`, 16 Nov); **#103 wahi-mahina seasonality long/short 12 market = TALAASH FAIL** (396 tr -0.024R, bina kharcha -0.015R, saal 2/6; `tools/season103.py`, 16 Nov); **#102 Double 7 non-US index tokri (7 index, swap 0) = TALAASH FAIL** (336 tr +0.052R, Exp-2SE cluster -0.043, drift 1.24x; `tools/double7_102.py`, 16 Nov); **#101 FTMO #68 + Kachhua 12 @0.25% swap 0 = PASS** (2019+ 85/0 med 10.2 vs #68 83/0 med 10.6; 2012-18 med 27.6 -> 15.5); #100 Trend vs Tide = trend jeeta, **#99 Kachhua 12 swap 0 = ASLI PASS patla**, #88-98 FAIL (tafseel `docs/purana-haal.md`)). ASLI PASS: 6 Kachhua commodity, 15 IBS S&P, 26 Supertrend tokri, 27/34 JasTrend 4H, 45 Double 7s (kamzor), 49/53/68 FTMO mansooba (83/0),
52 USTEC IBS, 59 chutti (bank), 67 khirki, 76 BTC (bank), **81 IBS + martingale cent**. Baqi FAIL. Faida daily + 4H TOKRI par; 1m-15m par spread edge kha jata.

## 9. Chat ke aakhir mein (ye file zinda rahe)
0. `KAHANI.txt` Sec 3 mein is chat ki 2-5 line + Sec 4 (ABHI) update (dobara mat banao, user 1 Nov).

- Sec 5 "PICHLI CHAT" naya likho (2-4 line: kya hua, agla kaam, "D" baqi ya nahi); kaam badla to sec 6-7.
- Naya pakka sabaq -> `docs/trading-pakki.md` sec 4 mein EK line, poore number `docs/sabaq-tafseel.md`.
- Naya pakka jawab -> `docs/sawal-jawab.md` mein EK line. Phir `python3 tools/roznamcha.py` (din ki file + FEHRIST.txt).
- Ye file 8 KB se lambi ho to purana hissa `docs/purana-haal.md` mein. `docs/files-tafseel.md` ki chhoti list mein nayi
  file ki ek line. Commit + push - apni branch AUR default `claude/jas-desk-v3-0110-yu3w2h` dono par.
