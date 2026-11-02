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

**30vi chat (1 Nov)** - poori kahani `KAHANI.txt` (nayi, pehle parho); tafseel `docs/purana-haal.md` grep "Koshish #7", "jas_5ea".
#70 C1 FAIL, #71 DXY filter FAIL, #72 forex trend FAIL (user: CURRENCY POORI CHHOR DI), #73 2 SELL aaina TALAASH FAIL (228 tr -0.003R, judge CLEAN).
Judge: swap har calendar raat (bug fix) -> #68 IMTIHAN 83/0 median 11.4. Research daur 2-5 `docs/research/`. Trade page B: https://claude.ai/artifact/8mv4nJR8T9rHUXGJvBHrMK
(`tools/trade_page/`). Pine `indicators/jas_5ea.pine` p4 TV par CHALA (SPX500USD/NAS100USD 1D; USTECH = error, NAS100USD istemal). p5 commit 6adeabd
(levels, alert, Abhi R, lot, agli khirki, warning) -> p6 judge READY (commit neeche), user ko link diya; TV SS ka intezar.
**31vi (2 Nov, isi chat mein):** jas_5ea p6 TV par CHALA (XAUUSD 1D, Abhi R sahi). #74 3Commas EMA 21/50 2H x 11 TALAASH FAIL (2409 tr -0.041R, kharche se pehle 0; judge CLEAN).
#75 = user ka "B" (3Commas + 4H trend) TALAASH FAIL (1729 tr -0.019R, judge CLEAN) = 3Commas poora band.
#76 BTC Kachhua (FTMO #68 + BTC 0.5%) CHUNAO 70/0, IMTIHAN 83/0 median 11.1 = PASS kamzor (judge CLEAN).
User: #76 BANK mein (dekha hua data = saboot kamzor; HIDAYAT "dekha hua").
#77 P2 1.5x CHUNAO FAIL (Aug 2015 crash = 12 P2 fail); G (pehra-shart) akela maloomat behtar. JasDeskView v5.6 user ka chala (2 column). Research daur 6 `docs/research/daur6-agent.md`.
#78 G akela IMTIHAN FAIL (median 12.1). User sawal: crash / ek din girna ka ilaj (news?) - Claude: news calendar crash nahi pakarta; sim mein EA ka 4% din pehra (sab band) shamil nahi = agla.
**AGLA KAAM:** (a) user faisla: sim mein EA ka asli 4% din pehra (close-all) dalna (#79 qaida pehle). BTC bank #76. Alert/lot user khud ON kare.
User TV SS ka intezar. (b) Somwar demo EA ki pehli trades (user SS). (c) BTC demo: FTMO swap pehle (user ka FTMO trial nahi, Exness demo).
(d) User faisla baqi: paid FTMO challenge bhi "LIVE" (6 mahine demo) gina jaye? (e) Watchlist `docs/tv_watchlist_jas11.txt`; table mein click = TV mein na-mumkin (user ko bataya).
HIDAYAT naye: discussion = sirf jawab (agent/test sirf "D" ke baad), aasan zabaan, judge har test ke baad, KAHANI dobara banana mana.

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
**53 FTMO #49 + IBS USTEC 1% ASLI PASS (2019+ 83/0, 2012-aaj +92%, DD 13.4%) = FTMO mansooba** · 54 = #37 + asli spread: TALAASH PASS +0.113R, **IMTIHAN 2025+ FAIL** (-0.037R, bina kharcha bhi -) = band. · 55-58 FAIL (trend 1H, IBS 4H, teacher 4H trend, IBS mandi) · **59 CHUTTI se pehle wala din (SPX+NDX) ASLI PASS** (2019+ 146 tr, jeet 68%) · 60 FTMO #53 + chutti FAIL · 61-63 IBS / Tide / Trend x Dow 30 share FAIL (faida = drift). · 64 TOM, 65 VIX: IMTIHAN FAIL · 66 trend 4H dhaat FAIL · **67 khirki x 7 non-US index PASS** · **68 FTMO #53 + khirki 0.15%: 83/0, median 10.8 (11.7 se) = ASLI PASS** (swap fix 1 Nov: 11.4 vs #53 11.9) -> JasKhirkiEA. · 69 + Tide oil FAIL (fail 0->11, bank) · 70 C1 local chutti x 7 index: TV TALAASH FAIL (312 tr, -0.007R, band) · 71 #68 + G2 DXY filter gold/chandi: CHUNAO 66/0 PASS, IMTIHAN FAIL (83/0 magar median 14.4 > 10.8) = band · 72 #68 + 4H trend EURUSD/USDJPY/AUDUSD: CHUNAO FAIL (fail 5 -> 25+) = forex trend band · 73 #68 + 2 SELL aaina (S1 trend + SMA200, S2 IBS): TALAASH FAIL (226 tr -0.004R) = SELL band · 74 3Commas EMA 21/50 2H x 11: TALAASH FAIL (2409 tr -0.041R, kharche se pehle 0) = band · 75 #74 + 4H Supertrend filter: TALAASH FAIL (1729 tr -0.019R, judge CLEAN) = band · **76 FTMO #68 + Kachhua BTC 0.5%: CHUNAO 70/0 (64/2 se), IMTIHAN 83/0 median 11.1 (11.4 se) = PASS kamzor** (judge CLEAN) -> user: BANK · 77 #68 + P2 risk 1.5x (+ pehra-shart G): CHUNAO FAIL (B 18 fail; C 60/0 pass kam), maloomat G akela 65/0 median 36.5 (A 64/2 38.5) · 78 #68 + G akela: IMTIHAN FAIL (83/0 magar median 12.1 > 11.4)
Faida daily + 4H TOKRI par; chhoti TF ab asli kharche se dobara (har ek pehle se likh kar).

## 9. Chat ke aakhir mein (ye file zinda rahe)
0. `KAHANI.txt` Sec 3 mein is chat ki 2-5 line + Sec 4 (ABHI) update (dobara mat banao, user 1 Nov).

- Sec 5 "PICHLI CHAT" naya likho (2-4 line: kya hua, agla kaam, "D" baqi ya nahi); kaam badla to sec 6-7.
- Naya pakka sabaq -> `docs/trading-pakki.md` sec 4 mein EK line, poore number `docs/sabaq-tafseel.md`.
- Naya pakka jawab -> `docs/sawal-jawab.md` mein EK line. Phir `python3 tools/roznamcha.py` (din ki file + FEHRIST.txt).
- Ye file 8 KB se lambi ho to purana hissa `docs/purana-haal.md` mein. `docs/files-tafseel.md` ki chhoti list mein nayi
  file ki ek line. Commit + push - apni branch AUR default `claude/jas-desk-v3-0110-yu3w2h` dono par.
