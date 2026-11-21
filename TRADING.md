# TRADING — har nayi chat SIRF ye ek file parhe

## 0. MT5 NAQSHA (sirf user ke SS se; har nayi chat ka PEHLA jawab ye table dikhaye, user tasdeeq kare)
MT5 ko hamesha TITLE BAR ke account number se bulao ("pehla/doosra" NAHI - user ne naam nahi rakhe). Yahan na ho = "pata nahi", andaza NAHI.
| Title bar account | Server | Qism | Balance | EA (chart) | Algo (ON/OFF) | Pakka |
|---|---|---|---|---|---|---|
| 474832446 | Exness-MT5Trial15 | FTMO demo, Standard USD | **21 Nov report 01:50: balance 97,858.52, equity 98,535.55** (shuru 100k se -2,141.48; bari girawat 2.71%) | i6, t5, k2, e2 (BTCUSDm H4) | ON; band 9: t5 5 (jeet 1, -1,310.16) + i6 4 (jeet 2, -846.35; **20 Nov US500 BUY 2.52 SL -1,000.31**), PF 0.36; **khuli 3 e2 SELL = +677.03:** XAG 0.01 @47.148 SL 51.56 (+304.6, silver 41.06), AUDUSD 0.24 @0.67114 SL 0.68136 (+233.28), BTCUSD 0.04 @61,949.75 SL 67,250.66 (+139.15); k2 0 trade | 21 Nov History report 01:50 (73vi) |
| 472716649 | Exness-MT5Trial16 | demo **Standard USD (CENT NAHI)** | balance = equity 2,153.25, khuli 0 | JasIbsCentEA c1 (US500m D1), band trade 0; XAG SELL 0.05 (2 Nov, SL khali = hamara EA nahi) user ne 3 Nov band +153.25; Magic/Comment SS baqi (purana: `docs/purana-haal.md`) | ON | 4 Nov SS |
| 253687618 | Exness-MT5Real34 | LIVE Standard Cent (USC), swap-free | **19 Nov m8.5 SS (69vi): EQUITY 74,308.04, TOTAL P/L -41,918.10 (TALA-BAND); BUY 46 tk 4.75 lot avg 4083.207 (-173,177.50) / SELL 15 tk 4.75 lot avg 3995.201 (+131,259.40), NET -0.00; tk 142 / 200; WASOOLI ~+21,821; RUKH 1D + 4H DOWN; BTC NET 0; popup A +22.26 / B +337.07 / N +1.87 / C +2,660.50 (C = NA)** | **JasMauqa m8.5 CHART PAR (K11 LIVE hissa HUA)**; `JasLarai1_EA` Navigator mein (compile hua lagta) | **OFF (only status)** - 19 Nov SS | 19 Nov SS (69vi) |

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

**74vi chat (21 Nov)** - EMA test: gold 4H 10 saal -> **EMA 50/200 sirf BUY + 4 ATR stop** (Python +159%, DD -17.3%, 44 trade; TV 2023- par +110.6% mila, f2 ✅). 15M 17.6 saal: 400/1600 BUY +238%.
35 market: trend portfolio girawat aadhi par munafa kam; XAU+USATECH 9.1% DD -22.6% (~8 trade/saal). **"Roz 1 trade" 1,500+ test (gold, 35 market, ML, NFP/FOMC) = koi edge NAHI.** Pine f4 (faisla panel + 3 symbol trade ginti) `strategies/jas_ema_4h_test.pine`, TV ✅.
5th EA sawal: t5 se mel corr 0.46-0.62 (G6) -> abhi NAHI; demo-only ya Fable tak. Sab `docs/research/ema-21nov/README.md`; Fable file mein hawala (pehle NA kholo).
**AGLA (75vi):** **ITWAR 22 Nov 2 AM ke baad Fable 5.2 jaanch** (+ EMA sawal hidayat 6 mein); 5th EA user faisla; pehla 'ABHI: BUY' SS; FTMO BF 24-27 Nov.

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

## 9. Chat ke aakhir mein (HALKI rasm - user 16 Nov "haan", token bachat)
- `KAAM.md` khule kaam taza + sec 5 "PICHLI CHAT" naya (2-5 line: kya hua, agla kaam). Naya jawab -> `docs/sawal-jawab.md` EK line.
- `python3 tools/roznamcha.py`, EK commit + push (ye branch = default). Nayi chat KHUD NAHI kholni - user kholta hai.
- Sirf "poora hisaab" par: `KAHANI.txt` Sec 3 (2-5 line) + Sec 4; naya sabaq `docs/trading-pakki.md` sec 4 EK line; sec 6-7.
- Ye file 8 KB se lambi ho to purana hissa `docs/purana-haal.md` mein. Nayi file ki ek line `docs/files-tafseel.md` mein.
