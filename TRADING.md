# TRADING — har nayi chat SIRF ye ek file parhe

## 0. MT5 NAQSHA (sirf user ke SS se; har nayi chat ka PEHLA jawab ye table dikhaye, user tasdeeq kare)
MT5 ko hamesha TITLE BAR ke account number se bulao ("pehla/doosra" NAHI - user ne naam nahi rakhe). Yahan na ho = "pata nahi", andaza NAHI.
| Title bar account | Server | Qism | Balance | EA (chart) | Algo (ON/OFF) | Pakka |
|---|---|---|---|---|---|---|
| 474832446 | Exness-MT5Trial15 | FTMO demo, Standard USD | balance 100,565.89, equity 101,088.85 (+522.96 khuli) | JasIbsEA i6 (US500m D1), JasTrendEA t5 (XAUUSDm H4), JasKhirkiEA k2 (DE30m D1) | ON; **i6 US500 BUY 3.79 @7563.12 BAND 4 Nov 21:16:02 @7712.37 = +565.66 (pehli band trade, +1.97%)**; khuli 4: i6 USTEC BUY 0.56 @28120.01 SL 26340.67 (+186.75), t5 XAU 0.03 @4001.869 (+191.82), XAG 0.02 @51.996 (+33.10), US500 BUY 2.41 @7659.33 SL 7348.92 (+111.29); target baqi 8911, farsh 96566; k2 0; DIV US500 chhote + | 5 Nov SS (JasFtmoView) |
| 472716649 | Exness-MT5Trial16 | demo **Standard USD (CENT NAHI)** | balance = equity 2,153.25, khuli 0 | JasIbsCentEA c1 (US500m D1), band trade 0, IBS US500 0.66 / USTEC 0.68 intezar; 2 Nov USTEC BUY CHHOOTI (min lot > 2x risk) = nahi khuli. XAG SELL 0.05 @50.271 khuli 2 Nov 11:35:26 (balance badalne ke 27 sec baad, SL KHALI = hamara EA nahi), user ne 3 Nov 19:28 @49.658 band ki +153.25; purani US500 BUY 1.87 (28 Oct, c1 se pehle) 2 Nov -184.87; Magic/Comment column abhi bhi nahi dikha | ON | 4 Nov SS |
| 253687618 | Exness-MT5Real34 | LIVE Standard Cent (USC), swap-free | **5 Nov 14:29 PKT mobile SS: equity 37,802.84 USC, Open 9 tk, P/L -147.72**; dikhi: BUY 0.10 @4146.317 (-162.62), SELL 0.10 @4134.023 (+37.28) = DHAAL (BUY 0.10 ki jori), BUY 0.01 @~4130.9; qeemat ~4130. Baqi 6 tk pata nahi (SS). Pehle 15 tk NET +0.01 (5 Nov 02:56 B) PAIR CLOSE DONE 17->15). **m6 popup D) BIG SELL PART CLOSE 0.09 of SELL 0.10 @4134.023 (+60.93, NET +0.07->+0.16) = dhaal kaatna -> mashwara NO** (user ne pakra) | JsMouqaEA = JasMauqa m6 (XAUUSDc D1); InpMinJori 5; D) band karna (m6.1) user ki haan baqi | **ON** (YES/NO popup) | 5 Nov SS |

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

**38vi chat (4-5 Nov)** - sirf live SS, koi test NAHI. Live 253687618: purani 133 tk basket user ne KHUD close all ki (balance 37,568.59 USC).
Ab MANUAL (mobile) 15 tk, NET +0.01 (taala - $1 = 1 USC, breakeven 4141). Ajeeb SELL 0.01 @4065.005 = m6 nahi (lot kholta hi nahi) -> wahi
**m6 ka pehla asli kaam:** 5 Nov 02:56:31 B) PAIR CLOSE DONE (10009), 17->15 tk. Close By = equity same, balance barhta (user samjha ✅).
InpMinJori 5 -> 0.01 jori ko $5 farq; 2 karna = user ki marzi (popup hadd, risk nahi). Purana popup = NO.
**AGLA KAAM:** (a) user "D" de to 3 sawal ek ek (pehla: equity hadd), sirf qaida. (b) 472716649 XAG SELL kis ne kholi (History Comment).
(c) FTMO 2 jawab (sawal-jawab): swap-free HAAN; Free Trial band = 3 registration -> 2 faltu account delete karwao (jalalzte rakho). (d) i6 pehli band trade +565.66 HUI (naqsha); agli band ka SS. (e) Live m6 popup / DONE ka SS aaye to naqsha update.

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

98 koshish (#88-95 recovery 0/9; **#96 commodity jor FAIL, #97 Gao pilot FAIL, #85 C2 TV FAIL 0/9, #98 Kachhua BUY x 9 index FAIL (drift)**, `docs/purana-haal.md`). ASLI PASS: 6 Kachhua commodity, 15 IBS S&P, 26 Supertrend tokri, 27/34 JasTrend 4H, 45 Double 7s (kamzor), 49/53/68 FTMO mansooba (83/0),
52 USTEC IBS, 59 chutti (bank), 67 khirki, 76 BTC (bank), **81 IBS + martingale cent**. Baqi FAIL. Faida daily + 4H TOKRI par; 1m-15m par spread edge kha jata.

## 9. Chat ke aakhir mein (ye file zinda rahe)
0. `KAHANI.txt` Sec 3 mein is chat ki 2-5 line + Sec 4 (ABHI) update (dobara mat banao, user 1 Nov).

- Sec 5 "PICHLI CHAT" naya likho (2-4 line: kya hua, agla kaam, "D" baqi ya nahi); kaam badla to sec 6-7.
- Naya pakka sabaq -> `docs/trading-pakki.md` sec 4 mein EK line, poore number `docs/sabaq-tafseel.md`.
- Naya pakka jawab -> `docs/sawal-jawab.md` mein EK line. Phir `python3 tools/roznamcha.py` (din ki file + FEHRIST.txt).
- Ye file 8 KB se lambi ho to purana hissa `docs/purana-haal.md` mein. `docs/files-tafseel.md` ki chhoti list mein nayi
  file ki ek line. Commit + push - apni branch AUR default `claude/jas-desk-v3-0110-yu3w2h` dono par.
