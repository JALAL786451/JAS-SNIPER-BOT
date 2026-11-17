# KAAM - Jalal ka EK register (har nayi chat ko hook KHUD dikhata hai)

JAWAB CHHOTA (user 10 Nov). User kuch bhi bataye (faisla, khabar) -> USI jawab mein yahan EK line, chat khatam ka intezar NAHI.
Kaam ho jaye -> qatar hata do, ek line `docs/purana-haal.md` mein. **Ye file ~4 KB se lambi NA ho.** Purana: `grep "KAAM se hataya" docs/purana-haal.md`.

## Pehle jawab mein KHUD (user ko 0 se batana na pare - user 16 Nov)
1. MT5 naqsha table (upar hook mein) - user tasdeeq.
2. Neeche "Khule kaam" se AGLA kaam khud batao + salah ("kya karein?" mat poochho).
3. 1 nayi maloomat (`docs/nayi-maloomat.md` mein na ho; bata kar wahan likho).
4. KAHANI.txt / poori TRADING.md NA parho - hook kaafi hai; purani baat sirf `grep`.

## Pakki baatein (bhoolna mana)
- **Purane EA / Pine mein KOI tabdeeli NAHI** (user 16 Nov) - naya kaam NAYI file mein. Naya version banane se pehle ijazat + abhi ka haal (SS).
- Risk hadd khud se NAHI barhana. Backtest -> demo -> live. LIVE par deewar / KHUD wala EA abhi NAHI (pehle demo).
- FTMO: swap-free milta (email 5 Nov); khareedne se pehle "Swing 2-Step 100k par?" likhwana baqi. FundingPips = hamare EA wahan NAHI (EA mana). EA plan sirf FTMO.
- User faisle (15 Nov): t5 hi chalne dein (1D filter nahi); gold par tokri BAND, K5 tab tak nahi; demo chalne dein. #105: 4 EA ki taqseem na badlein.
- **User ka ASAL maqsad (16 Nov):** "jis tarha mein trade leta hoon uska EA" - profit lots + jori khud band, loss par DEEWAR (ulti lot, user ne khud maanga), dohri lot pakre. Poora auto 2 dafa fail (tk2, K4). Deewar nuqsan ROKTI hai, wapas nahi lati.
- LIVE 253687618 (16 Nov): m8.4 chal raha; equity ~38,770, gold BUY 7.29 / SELL 7.27, BTC NET +0.02, tala-band ~-48,000, tk 167 / 200. Jori (A / B) YES be-khatar; C (profit ticket) NA lein.
- FTMO demo 474832446 (16 Nov): t5 US500 + USTEC BUY khuli; e2 TRADE CHALU, trade 0 (gold SELL 3852.301 / chandi SELL 48.465 se neeche D1 close par).
- **PC Claude + TV Bridge se Pine / chart ka kaam NAHI** (user 17 Nov: bohot token) - TV ka kaam user khud + SS.
- Data user ne diya: US500 / USTEC M1 2012-26 + gold M1 (QDM). Kitabi ideas #102-104 FAIL (list khatam).
- **TOKEN BACHAT (user 16 Nov "haan"):** nayi chat KHUD nahi khulti (user kholta, "TRADING" likhta); shuru mein sirf hook; chat khatam = halki rasm (CLAUDE.md). Rozmarra kaam sasta model, Fable sirf mushkil kaam.

- **User ki hasrat (16 Nov raat, 62vi):** "3 mahine se 3 EA meri hasrat ke hisab se nahi bane - tasalli hai, magar expectation tak nahi pohncha". Chahiye: (1) FTMO ke mahine kam karne wala extraordinary EA, (2) BUY / SELL ka pro level Pine idea, (3) mere tareeqe wala TESTED fighting EA (fishing lots, bohot si BUY / SELL mein perfect fighter). SS 11:30 PM (usage reset) ke baad.

- **TEST #3 HUA (17 Nov, 62vi): DEEWAR FAIL** aap ki asli LIVE gold trades (18 Aug - 5 Nov) par (`tools/larai_deewar_test.py`): asal -19,884 USC, deewar ke saath -32,720 (12,836 bura); sab se bari girawat 27,142 -> 47,265; 158 deewar, ek waqt 426 ticket (hadd 200). Gold ki $15 ulti-seedhi chaal mein deewar har dafa nuqsan pakka karti. => `InpWall` OFF hi rahe; JasLarai sirf jori / C / dohri lot (equity par asar nahi) ke liye.
- **TEST #2 HUA (17 Nov): Rehnuma r2** 4H 0.75% + 1H idea 0.25% (`tools/rehnuma_r2_jor.py`): 2003-18 kul +41.3% girawat 9.5%; 2019-26 +35.2% girawat 7.6%, bura mahina -2.1%; 1H idea SL 2 / 3 / 4 ATR teeno plus (mazboot). Dono akele bhi barabar (~+17-20%). Saal ~+4-5% (gold sirf) = pass jaldi nahi karata, magar saaf.

## Khule kaam (upar wala pehle)
| # | Kaam | Haal |
|---|---|---|
| **K11** | m8.5 LIVE par **HUA 17 Nov** (SS: chart par m8.5). `JasLarai` j2 = Navigator mein `JasLarai1_EA` -> demo 472716649 par lagana, **deewar OFF** (test #3 fail) | **17 Nov SS: PC par sirf 2 MT5 khule (474832446 FTMO demo + 253687618 LIVE); 472716649 KISI par login NAHI** (= c1 bhi nahi chal raha). Salah: 3rd MT5 alag folder C:\MT5_DEMO2 mein 472716649 login + j2; purane 2 MT5 mein login KABHI na badlein (un ke EA naye account par chalne lagen) |
| R2 | Rehnuma r2 | **TV par CHAL RAHA (17 Nov SS, XAUUSD 4h, error nahi)** - ab sirf nazar; 1H BUY idea demo pehle |
| K6 | LIVE report se user ka asli tareeqa (naqsha, test nahi) | K11 ke baad; user ki haan |
| K7 | Kachhua e2 demo 474832446 | **PEHLI TRADE MILI 17 Nov:** XAG SELL 0.01 @47.148 SL 51.560 = Python (16 Nov close 47.175 < 10 din ka low 48.465 [13 Nov], Itwar Monday mein; SL C+2 ATR 51.485, farq 0.075 = chhote data ka ATR seed; lot 0.01 = $221 <= $250). Data `data/demo_474832446/XAGUSDm_D1_*.csv`. k2 ki pehli trade ka intezar |
| K5 | Tokri EA tk2 demo par | ruka (user: tokri band) |
| K12 | **PC Claude + repo JUR GAYA (17 Nov):** PowerShell `cd D:\JAS` -> `claude.cmd` (Sonnet 5.5, Claude Pro login, manual mode, TRADING = table aaya). Har dafa pehle `git pull`. Stop hook D:\JAS ki badli files khud push karta - wahan faltu file NAHI | agla: MT5 test ke liye ALAG `C:\MT5_TEST` (LIVE wala MT5 kabhi nahi) |
| T1 | t5 Forward jaanch **HUI 17 Nov** (gold H4 2019-26, Forward 1/3, mult 2.0-5.0): 7 mein se 7 dono hisson mein PLUS, koi cliff nahi = 3.0 curve-fit NAHI. Magar pehla 2/3 (2019-mid 2024) kamzor: 3.0 sirf +1.8% (DD 7%); forward (mid 2024-26) +12% DD 1.9% = munafa gold ki bari chaal se. 3.0 hi rahe | agla: wahi test US500m H4 (t5 ka demo nuqsan US500 / USTEC par) - user ki marzi |
| K13 | User 17 Nov: BUY+SELL EA (FTMO qaide) | **TEST (a) HUA 64vi** (`tools/k13_sell_regime_test.py`, 4H ST SELL + D1<SMA200, SL 6 ATR): gold 2019-26 -0.116R (30 tr), US500 +0.04R (24), USTEC -0.03R, XAG 0 = SELL phir FAIL (4th). Bina gate sab minus. Agent nahi (limit 55%). BUY+SELL = e2 pehle se. **(b) bhi HUA:** 5 forex + 2 oil (data/duka, QDM nahi chahiye - user ka QDM block 17 Nov) = SELL gated 2019-26 sirf GBPUSD +0.10R (50 tr, ittefaq), baqi 0 ya minus; oil SELL -0.09/-0.11R = FAIL. SELL EA NAHI banega; BUY+SELL = e2 hi |
| K14 | Umar Ashraf "Morning Top" (YouTube, Gemini khulasa) | **TEST HUA 64vi: FAIL** US500 / USTEC M1 2012-26 sab minus (-0.19 se -0.30R); tape wala hissa test nahi ho sakta. `docs/research/umar-ashraf-morning-top.md`. Naya video = Gemini khulasa paste (tareeqa chalta) |
| K8 | TV Store update ho to robocopy dobara | jab update aaye |
| FTMO | ~20 Nov Black Friday offer ftmo.com par check (`docs/bank.md` yaad dilao) | tareekh par |
