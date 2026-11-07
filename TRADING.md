# TRADING — har nayi chat SIRF ye ek file parhe

## 0. MT5 NAQSHA (sirf user ke SS se; har nayi chat ka PEHLA jawab ye table dikhaye, user tasdeeq kare)
MT5 ko hamesha TITLE BAR ke account number se bulao ("pehla/doosra" NAHI - user ne naam nahi rakhe). Yahan na ho = "pata nahi", andaza NAHI.
| Title bar account | Server | Qism | Balance | EA (chart) | Algo (ON/OFF) | Pakka |
|---|---|---|---|---|---|---|
| 474832446 | Exness-MT5Trial15 | FTMO demo, Standard USD | **balance 98,909.17, equity 99,011.00 (+101.83 khuli)** | JasIbsEA i6 (US500m D1), JasTrendEA t5 (XAUUSDm H4), JasKhirkiEA k2 (DE30m D1) | ON; i6 USTEC BUY 0.56 SL par BAND -994.31 (-1.00R; 99,903.48 -> 98,909.17); i6 band 2: US500 +0.57R, USTEC -1.00R (kul -0.43R); khuli 3: i6 US500 BUY 2.81 @7349.48 SL 6994.65 (5 Nov 21:16, +42.91), t5 XAU 0.03 @4001.869 SL 3755.378 (+118.12), XAG 0.02 @51.996 SL 45.881 (-59.20); target baqi 10989, aaj farsh 95903; k2 0 | 6 Nov SS (FTMO VIEW v1.1) |
| 472716649 | Exness-MT5Trial16 | demo **Standard USD (CENT NAHI)** | balance = equity 2,153.25, khuli 0 | JasIbsCentEA c1 (US500m D1), band trade 0; XAG SELL 0.05 (2 Nov, SL khali = hamara EA nahi) user ne 3 Nov band +153.25; Magic/Comment SS baqi (purana: `docs/purana-haal.md`) | ON | 4 Nov SS |
| 253687618 | Exness-MT5Real34 | LIVE Standard Cent (USC), swap-free | balance 38,074.99 (5 Nov report); **6 Nov 00:13 PKT app SS: equity 37,865.32, khuli 4 = -216.55 USC (aaj 3 fishing band +5.30)**; 00:07 wala: (gold bid ~4101.0): BUY 0.10 @4127.090 SL KHALI (-260.86), BUY 0.01 @4108.182 (-7.18), SELL 0.01 @4109.047 (+7.80), BUY 0.01 @4105.457 (-4.46), BUY 0.01 @4101.255 (~-0.26); net BUY 0.12 = ~12 USC har $1, barabar ~4123 | **m7.4 CHAL RAHA (6 Nov SS: equity 38,675.99, P/L +157.90, 41 ticket, BUY 0.88 avg 4053.334 / SELL 0.85 avg 4054.908, net +0.03, breakeven 4015.36)**; JasMauqa XAUUSDc H4; NFP 6 Nov 18:30 PKT | **ON** (YES/NO popup) | 6 Nov app SS |

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

**46vi chat (6 Nov, chhoti)** - TV `JAS Naqsha+5EA` j3.1: aakhri candle ke saath BOLD chalti price (transparent, candle rang) + dotted line poore chart (TV ✅ j3; bhaari script = aakhri 1-3 digit der se).
JasMauqa **m7.6 LIVE ✅** (F7 user): NET = BUY - SELL line, PROFIT split BUY/SELL, "agar sare profit ticket close" -> NET + hedge (NAYI kholo / PURANI close), NET > 0.80 laal; popup chhota neeche daayen. YES = sirf popup ka upar wala kaam, HISAAB sirf likhai (user samajh gaya).
FTMO swap-free = pakka (5 Nov support email, sawal-jawab "FTMO swap-free (Islamic)"): trade se PEHLE har stage email.
Kachhua swap 0 = #99 ASLI PASS + #101 (#68 + Kachhua 12 @0.25%) PASS (5 Nov) - bank se bahar; user "haan" (7 Nov) -> Kachhua e1 0.25% FTMO demo par (Monday tasdeeq + EA). Tide HTF (W+M) alag, FAIL.
Tide HTF h1 (XAUUSD, user SS 7 Nov): 2000-18 88 tr Exp +0.26 (±0.27), 2019+ 51 tr +0.43 (±0.48) = apne qaide par FAIL (trades <100, Exp-2SE <0). TF baqi.
LIVE report 7 Nov 04:53 (user zip): jama 58,746 USC (18 Aug) -> balance 42,311.89, equity 38,272.49 (-35%); 6701 trade, jeet 72-85% magar PF 0.94 (kul -16,434). Lot 0.01 -> 10.00 (2 Nov -5,867), 4.00 (4 Nov -5,958), 5.00 (6 Nov +4,167; 19:59 server SELL 5 + 9 haari SELL Close = -3,778). Khuli 39: BUY 4.16 avg 4073.09 / SELL 4.16 avg 4063.62, NET 0, -4,039.
Live SS: 60 ticket, BUY 5.13 = SELL 5.13 (NET 0), P/L ~-7600, equity ~38,692 - lot bahut barhi (0.88 -> 5.13), BANK yaad dilaya.
**45vi chat (6 Nov)** - Tokri tk2 sim (`tools/tokri_asli.py/.c`): gold H1 2005-26 $1000, 240 variant + M1 2009-18 = SAB account khatam.
FTMO demo 474832446 SS: USTEC SL -994 (-1R), i6 US500 BUY 2.81, balance 98,909 (sec 0). Research agent (`docs/research/agent-6nov-factors-data.md`):
Trend MAZBOOT, IBS/Khirki/Kachhua darmiyana, chutti kamzor; nayi B1 Pre-FOMC, B2 chutti non-US, B3 mahina-aakhir, B4 BTC trend...; data = Dukascopy (QDM) behtareen.
User ko PDF diya: `docs/pdf/JAS_FTMO_Plan_Monday.pdf` (+ .txt) = data guide + FTMO plan hafta 1-4 + checklist. FTMO Nov 2026 offer pakka nahi mila (2025 BF ~20%, 26-29 Nov) -> ~26-30 Nov ftmo.com checkout dekho.
Tokri Q20-Q23 (user): high/low par lot + wait; SL/TP/strategy NAHI; bhari taraf = chart se rukh, ulta bhaage to bhari taraf badlo; swing/trend hi kamyab.
Hafte ki limit ~4% bachi -> nayi chat Monday reset ke baad (user khud "TRADING").
**DATA (7 Nov):** gold M1 2019/20/25/26 repo `data/qdm/M1` (UTC, ek price, 2026 = 4 Nov tak). Baqi saal user ke QDM mein - jo chahiye Monday ko Claude KHUD maange (upload link sawal-jawab).
**47vi chat (7 Nov):** (0) HUA = `docs/live/asli-tareeqa-7nov.md` (lot 0.01-0.05 +62k, lot 0.25+ -68k, SELL -153k, 43 ticket -150k) - user haan/nahi baqi. Tokri EA tk2 LIKHA (user: test nahi, EA har soorat) - F7 + demo 472716649 baqi. Nayi hidayat: nayi maloomat KHUD roz (`docs/nayi-maloomat.md`).
**AGLA (Monday 9 Nov, PDF sec 5 hafta 1):** (0) user "haan" 7 Nov: LIVE report (`docs/live/ReportHistory-253687618-2026-11-07.zip`, 6701 trade) se user ka ASLI tareeqa nikaalo (kab kholta, kitni lot, kab band, Close By; achhe din 28-29 Oct / 5 Nov vs bure 2 / 4 Nov) = naqsha, TEST NAHI; user dekh kar haan/nahi. (1) user data push karega (gold M1 2019/20/25/26, US500/USTEC M1 2019-20, Yahoo/Stooq daily, FRED) -> Claude SIRF jaanch
(gap, timezone, BID/ASK), naya test NAHI. (2) user se: rukh chart par kaise (2-3 purane din dikhaye), kitne $ ulta par bhari taraf badle, purani lots ka kya (Q22).
(3) faisle: Kachhua e1 0.25% demo? B1 ya B2 pehle? (4) har test: discuss -> qaida pehle -> test -> judge (user naam le) -> faisla user.

## 6-7. Demo (1 Nov): SIRF FTMO DEMO 474832446 chalu (user SS ✅)

| EA | Chart | Magic | Haal |
|---|---|---|---|
| **JasTrendEA t5** | XAUUSDm H4 | 20261029 | XAU, XAG, US500, USTEC - 4H, 0.75%, SL 6 ATR, judge replay = Python same |
| **JasIbsEA i6** | US500m D1 | 20261022 | US500, USTEC - 1%, faisla 16:15 NY |
| **JasKhirkiEA k2** | DE30m D1 | 20261101 | 7 non-US index 0.15% (1 Nov SS ✅; t5/i6 pehra +20261101) |

Pehra (teeno, poora account): target 110k + din 4% (96k farsh), kul hadd band (user "1"). Purane demo 472716649 / 472540009 (Radar, RSI2, i3, t2, t3)
user ne 31 Oct raat DELETE kiye - un ki tafseel `docs/purana-haal.md` grep "sec 6-7 se (1 Nov". Exness Demo ki `JasTideRadarEA.mq5` mein ghalti se t5 code
paste hua (chart par nahi laga) - zaroorat par GitHub wali e1 dobara.

**CENT DEMO (2 Nov, teesra MT5 folder "MetaTrader 5 Cent Demo"):** 472716649 Exness-MT5Trial16, USD, balance **$1000** (user ne set kiya). **JasIbsCentEA c1** US500m D1, magic 20261102,
US500m + USTECm, $10 risk x martingale 1.5x 3 qadam, $800 stop (hamesha, GV `JASIBSC_STOP_`). Panel TRADE CHALU (SS ✅). Real cent par koi EA nahi (6 mahine qaida).

## 8. Koshish ginti (poori line `docs/purana-haal.md`, grep "Koshish ginti 2 Nov")

101 koshish (**#101 FTMO #68 + Kachhua 12 @0.25% swap 0 = PASS** (2019+ 85/0 med 10.2 vs #68 83/0 med 10.6; 2012-18 med 27.6 -> 15.5); **#100 FTMO Trend vs Tide swap 0 = TREND JEETA** (2019+ 81/0 med 17.4 vs Tide 0.5% 67/0 med 22.1); **#99 Kachhua 12 market SWAP 0 = ASLI PASS patla** (TALAASH Exp-2SE +0.024, IMTIHAN +0.010, forex 2019+ minus; `tools/ftmo99.py`); #88-95 recovery 0/9; **#96 commodity jor FAIL, #97 Gao pilot FAIL, #85 C2 TV FAIL 0/9, #98 Kachhua BUY x 9 index FAIL (drift)**, `docs/purana-haal.md`). ASLI PASS: 6 Kachhua commodity, 15 IBS S&P, 26 Supertrend tokri, 27/34 JasTrend 4H, 45 Double 7s (kamzor), 49/53/68 FTMO mansooba (83/0),
52 USTEC IBS, 59 chutti (bank), 67 khirki, 76 BTC (bank), **81 IBS + martingale cent**. Baqi FAIL. Faida daily + 4H TOKRI par; 1m-15m par spread edge kha jata.

## 9. Chat ke aakhir mein (ye file zinda rahe)
0. `KAHANI.txt` Sec 3 mein is chat ki 2-5 line + Sec 4 (ABHI) update (dobara mat banao, user 1 Nov).

- Sec 5 "PICHLI CHAT" naya likho (2-4 line: kya hua, agla kaam, "D" baqi ya nahi); kaam badla to sec 6-7.
- Naya pakka sabaq -> `docs/trading-pakki.md` sec 4 mein EK line, poore number `docs/sabaq-tafseel.md`.
- Naya pakka jawab -> `docs/sawal-jawab.md` mein EK line. Phir `python3 tools/roznamcha.py` (din ki file + FEHRIST.txt).
- Ye file 8 KB se lambi ho to purana hissa `docs/purana-haal.md` mein. `docs/files-tafseel.md` ki chhoti list mein nayi
  file ki ek line. Commit + push - apni branch AUR default `claude/jas-desk-v3-0110-yu3w2h` dono par.
