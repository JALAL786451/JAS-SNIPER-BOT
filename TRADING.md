# TRADING — har nayi chat SIRF ye ek file parhe

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

**29vi chat (1 Nov)** - tafseel `docs/purana-haal.md` grep "29vi chat", "Koshish #69", "Koshish #70", "Research team daur 1". Purani 28vi: grep "sec 5 se (1 Nov 29vi".
Spread naap 2 (oil, forex, BTC, XCU, XNG). **#69** #68 + Tide oil = IMTIHAN FAIL (fail 0 -> 11) -> bank. **Research daur 1** (`docs/research/`): C1 KEEP, baqi REJECT.
**JasKhirkiEA k2** (judge: Python se 843/843; k2 = 5 fix) FTMO demo par ✅ + t5/i6 pehra +20261101 ✅. FTMO fees / Swing / VPS / discount / gap qaida: `docs/sawal-jawab.md`.
**#70 C1 = TALAASH FAIL (30vi chat, user TV SS):** 312 tr, -0.007R, Exp-2kSE -0.038, ausat -0.018% < drift, saal 31/58, NI225 -0.010 HSI -0.017 = sab shart fail -> BAND (IMTIHAN nahi). CFD bhi manfi tha.
**AGLA KAAM:** (b) Demo 3 EA chalu (sec 6-7); Somwar pehli trades dekho. Pehli khirki 24 Nov. (c) **Asli FTMO se PEHLE:** t5/i6 InpServerGMT -2 (k2 jaisa) + FTMO symbol naam
(GER40.cash ...) + pehra B phir D; FTMO support se "gap trading" (IBS Jumma 16:15 NY) likhwao; Swing; ftmo.com offer (CLAUDE.md). (d) Research daur 2 (zyada trades,
mazboot; Gotobi sirf waiver). BTC + Kachhua baqi. BANK (#59, #69) KHUD yaad dilao.
**Kitab (30 Oct raat, LIVE, gold 3,874):** 90 BUY 1.85 lot @3985.28 + 1 SELL 1.65 @3904.33 (dhaal), NET +0.20, kul -15,618 USC; equity ~34,700. SELL band = ~3,690 par khatam.

## 6-7. Demo (1 Nov): SIRF FTMO DEMO 474832446 chalu (user SS ✅)

| EA | Chart | Magic | Haal |
|---|---|---|---|
| **JasTrendEA t5** | XAUUSDm H4 | 20261029 | XAU, XAG, US500, USTEC - 4H, 0.75%, SL 6 ATR, judge replay = Python same |
| **JasIbsEA i6** | US500m D1 | 20261022 | US500, USTEC - 1%, faisla 16:15 NY |
| **JasKhirkiEA k2** | DE30m D1 | 20261101 | 7 non-US index 0.15% (1 Nov SS ✅; t5/i6 pehra +20261101) |

Pehra (teeno, poora account): target 110k + din 4% (96k farsh), kul hadd band (user "1"). Purane demo 472716649 / 472540009 (Radar, RSI2, i3, t2, t3)
user ne 31 Oct raat DELETE kiye - un ki tafseel `docs/purana-haal.md` grep "sec 6-7 se (1 Nov". Exness Demo ki `JasTideRadarEA.mq5` mein ghalti se t5 code
paste hua (chart par nahi laga) - zaroorat par GitHub wali e1 dobara.

## 8. Koshish ginti (poori line `docs/purana-haal.md`, grep "Koshish ginti 31 Oct")

1-5 FAIL · **6 Kachhua commodity ASLI PASS** · 7-14 FAIL · **15 IBS S&P ASLI PASS** · 16-25 FAIL / sikka (19 SMC DZ/SZ 4H MT5 baqi; 21 ORB USTEC 5m asli kharcha FAIL 1 Nov) ·
**26 Supertrend tokri ASLI PASS** · **27 JasTrend FTMO PASS** · 28-33 FAIL · **34 JAS Trend 4H TOKRI ASLI PASS** · 35-44 FAIL (37 noise boundary 0.03% kharcha par) ·
**45 Double 7s ASLI PASS kamzor** · 46-48, 50, 51 FAIL · **49 FTMO trend + IBS S&P ASLI PASS** · **52 teacher: USTEC IBS ASLI PASS** ·
**53 FTMO #49 + IBS USTEC 1% ASLI PASS (2019+ 83/0, 2012-aaj +92%, DD 13.4%) = FTMO mansooba** · 54 = #37 + asli spread: TALAASH PASS +0.113R, **IMTIHAN 2025+ FAIL** (-0.037R, bina kharcha bhi -) = band. · 55-58 FAIL (trend 1H, IBS 4H, teacher 4H trend, IBS mandi) · **59 CHUTTI se pehle wala din (SPX+NDX) ASLI PASS** (2019+ 146 tr, jeet 68%) · 60 FTMO #53 + chutti FAIL · 61-63 IBS / Tide / Trend x Dow 30 share FAIL (faida = drift). · 64 TOM, 65 VIX: IMTIHAN FAIL · 66 trend 4H dhaat FAIL · **67 khirki x 7 non-US index PASS** · **68 FTMO #53 + khirki 0.15%: 83/0, median 10.8 (11.7 se) = ASLI PASS** -> JasKhirkiEA. · 69 + Tide oil FAIL (fail 0->11, bank) · 70 C1 local chutti x 7 index: TV TALAASH FAIL (312 tr, -0.007R, band)
Faida daily + 4H TOKRI par; chhoti TF ab asli kharche se dobara (har ek pehle se likh kar).

## 9. Chat ke aakhir mein (ye file zinda rahe)

- Sec 5 "PICHLI CHAT" naya likho (2-4 line: kya hua, agla kaam, "D" baqi ya nahi); kaam badla to sec 6-7.
- Naya pakka sabaq -> `docs/trading-pakki.md` sec 4 mein EK line, poore number `docs/sabaq-tafseel.md`.
- Naya pakka jawab -> `docs/sawal-jawab.md` mein EK line. Phir `python3 tools/roznamcha.py` (din ki file + FEHRIST.txt).
- Ye file 8 KB se lambi ho to purana hissa `docs/purana-haal.md` mein. `docs/files-tafseel.md` ki chhoti list mein nayi
  file ki ek line. Commit + push - apni branch AUR default `claude/jas-desk-v3-0110-yu3w2h` dono par.
