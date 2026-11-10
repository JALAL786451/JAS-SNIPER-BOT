# TRADING — har nayi chat SIRF ye ek file parhe

## 0. MT5 NAQSHA (sirf user ke SS se; har nayi chat ka PEHLA jawab ye table dikhaye, user tasdeeq kare)
MT5 ko hamesha TITLE BAR ke account number se bulao ("pehla/doosra" NAHI - user ne naam nahi rakhe). Yahan na ho = "pata nahi", andaza NAHI.
| Title bar account | Server | Qism | Balance | EA (chart) | Algo (ON/OFF) | Pakka |
|---|---|---|---|---|---|---|
| 474832446 | Exness-MT5Trial15 | FTMO demo, Standard USD | **balance 99,494.00, equity 100,053.90 (+559.90 khuli)** | JasIbsEA i6 (US500m D1), JasTrendEA t5 (XAUUSDm H4), JasKhirkiEA k2 (DE30m D1) | ON; **i6 US500 BUY 2.81 BAND 9 Nov 21:16 @7557.57 (IBS 0.90 > 0.80) = +584.73 (~+0.59R)**; i6 band 3, jeet 2, kul +0.15R; intezar IBS < 0.2. khuli 2: t5 XAU 0.03 @4001.869 SL 3755.378 (+417.90, +0.57R), XAG 0.02 @51.996 SL 45.881 (+142.00, +0.23R); target baqi 9946, aaj farsh 94909; k2 0; margin level 58150% | 9 Nov SS #3 (FTMO VIEW v1.1) |
| 472716649 | Exness-MT5Trial16 | demo **Standard USD (CENT NAHI)** | balance = equity 2,153.25, khuli 0 | JasIbsCentEA c1 (US500m D1), band trade 0; XAG SELL 0.05 (2 Nov, SL khali = hamara EA nahi) user ne 3 Nov band +153.25; Magic/Comment SS baqi (purana: `docs/purana-haal.md`) | ON | 4 Nov SS |
| 253687618 | Exness-MT5Real34 | LIVE Standard Cent (USC), swap-free | **9 Nov SS (52vi): equity 38,995.64; balance ~50,975 (equity + khula nuqsan)**; GOLD P/L -8540.80: BUY 35 tk 3.75 lot avg 4091.183 / SELL 17 tk 3.74 avg 4068.458, NET +0.01 (nuqsan TALA-BAND, price se nahi badalta), gold 4139; BARI LOT 6 tk (max 3.31); popup B pair +210.61, C +349. BTC P/L -3438.86: BUY 75 tk 2.81 avg 75660.29 / SELL 7 tk 2.50 avg 74401.88, NET BUY +0.31, BTC 74767, breakeven 85860 | JasMauqa **m8.1** (10 Nov 15:21 server SS: equity 39,194, balance 64,394, gold BUY 3.98 avg 4121.3 / SELL 3.79 avg 4067.8 NET +0.19, BTC NET +0.04, tk 133, WASOOLI 871.90, gold InpA=false); purana: m7.8 (F7 0 error, 9 Nov; m7.9 AUTO-B F7 ✅ 10 Nov dono chart par, AUTO OFF); 10 Nov SS: equity 39,012.07, gold P/L -10,060 NET +0.02, BTC -3,442 NET +0.01, tk 119; XAUUSDc H4 + BTCUSDc H4; BTC SS #2: equity 39,049.70, BTC P/L -3441.69, BUY 65 tk 3.13 / SELL 12 tk 3.12 = NET +0.01 (ab BTC bhi TALA-BAND), bari lot 5 tk max 2.40, gold NET -0.01, margin level 655196%; RUKH: gold 4H UP, BTC 4H DOWN, dono 'nayi BUY nahi - intezar'; tickets 134/200; margin level 282987% | **ON** (YES/NO popup) | 9 Nov SS (52vi) |

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

**53vi chat (10 Nov)** - LIVE gold: subah BUY 2.50@4117.416 (user) = aadha nuqsan; m7.9 ko user ne "ajeeb" kaha -> **m8.0** (AUTO HATA, A = bari BUY/SELL
Close By, WASOOLI panel) + **m8.1** (LOG `MQL5\Files\JasMauqa_<sym>.txt` + `_waqiat.txt`; user file chat mein upload karta) F7 ✅ dono chart (file naam
`JsMouqaEA script.mq5`). Joriyan YES: A +116.50 (2.50 jori), B ... -> **WASOOLI 871.90**, balance 64,394. CPI: Algo OFF, dhaal NET +0.09 -> gold -38 = sirf ~-485.
Gold chart **InpA=false** (A dhaal 3.31 kaat raha tha; gold 4117+ par true). Exness PDF -> `tools/exness_pdf.py`: chhoti lot +32,687, bari SELL -36,932.
User: jawab CHHOTA. **AGLA (54vi):** popup jaanch (B YES, C NO) + log file se haal; m8.2 ijazat (A sirf nuqsan wali bari lot / bara nateeja pehle, label m8.0 fix); phir K1/K4.
**52vi chat (9-10 Nov)** - K3 HUA (gold M1 2019/20/25/26 saaf, `tools/gold_m1_jaanch.py`). JasMauqa **m7.8** (NET < 0.05 = "TALA-BAND", breakeven
number nahi) + **m7.9** (InpAuto true = SIRF B) PAIR CLOSE khud YES; A/C/D popup; jawab na aaye = NO + dobara nahi) F7 ✅ dono chart, AUTO ON dono;
pehli AUTO jori gold +59.00 (01:07 server). Gold + BTC NET ~0 (tala-band), equity ~39,0k, balance 52,644. FTMO demo: i6 US500 +584.73 qaide se band.
Sawal-jawab: breakeven, t5 TP/SL, PC Claude band/khol, push (user ke phone par sirf Exness app), Claude Code course 19 (`docs/claude-code-19.md`).
User 10 Nov: naya EA version se PEHLE haal (SS) + ijazat poochho. GitHub red ❌ (python-package-conda.yml) 10 Nov DELETE HUA - (namoona, environment.yml
nahi) - delete ki ijazat user se BAQI. **AGLA (53vi):** K1 (D:\JAS_DRIVE.bat + schtasks SS) -> raat ki AUTO joriyan History se -> K4 qaide user "haan".
**51vi chat** -> `docs/purana-haal.md` (grep "51vi").
**50vi chat** -> `docs/purana-haal.md` (grep "50vi").
**49vi chat** -> `docs/purana-haal.md` (grep "49vi").
**48vi chat** -> `docs/purana-haal.md` (grep "48vi").
**47vi chat** -> `docs/purana-haal.md` (grep "47vi").
**46vi chat** -> `docs/purana-haal.md` (grep "46vi").

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
