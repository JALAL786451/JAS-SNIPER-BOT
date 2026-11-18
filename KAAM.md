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
- LIVE 253687618: m8.5 chal raha (haal = hook table). Jori (A / B) YES be-khatar; C (profit ticket) NA lein.
- **PC Claude + TV Bridge se Pine / chart ka kaam NAHI** (user 17 Nov: bohot token) - TV ka kaam user khud + SS.
- Data user ne diya: US500 / USTEC M1 2012-26 + gold M1 (QDM). Kitabi ideas #102-104 FAIL (list khatam).
- **TOKEN BACHAT (user 16 Nov "haan"):** nayi chat KHUD nahi khulti (user kholta, "TRADING" likhta); shuru mein sirf hook; chat khatam = halki rasm (CLAUDE.md). Rozmarra kaam sasta model, Fable sirf mushkil kaam.

- **User ki hasrat (16 Nov raat, 62vi):** "3 mahine se 3 EA meri hasrat ke hisab se nahi bane - tasalli hai, magar expectation tak nahi pohncha". Chahiye: (1) FTMO ke mahine kam karne wala extraordinary EA, (2) BUY / SELL ka pro level Pine idea, (3) mere tareeqe wala TESTED fighting EA (fishing lots, bohot si BUY / SELL mein perfect fighter). SS 11:30 PM (usage reset) ke baad.

- **64vi sabaq (17 Nov):** SELL 11 market FAIL; YouTube / ICT / 15m idea sab FAIL (`docs/research/`); Kachhua 12 market + 0.25% = sab se behtar (FTMO sim 0 fail); risk ki aakhri had 0.45 (us se upar faida nahi). Naya video = Gemini khulasa paste -> save + test. Weekly limit 50%+ = agent nahi.

- **LIVE report 18 Nov 03:09 (67vi):** gold SELL 3.70 @4057.762 (+76,999) ke NEECHE BUY 37 tk = **3.15 lot** (avg 4047.217, -62,307); upar BUY 22 tk = 3.22 lot (-86,975). Kul gold BUY 6.37 / SELL 6.26; equity 75,783 USC. User plan: SELL 3.70 se 3.15 neeche wali BUY Close By, phir neeche EK bari BUY (size baqi; Claude ne khatra hisab diya). Close By sahi nateeja ~+3,322 USC (pehle 14,690 ghalat kaha). User soch: pehle SELL lock = net 0. 18 Nov SS: BUY 6.40 / SELL 6.22 = net +0.18 (lock ab 0.18), equity 75,219.84, gold 3799.9, margin level 204,736%, stop out 0%.
- 18 Nov: naya Exness demo #17000740869 ($750, browser). EA browser par nahi; MT5 desktop (C:\MT5_DEMO2 portable) mein login = K11 ka option. Pine sirf TV par.
- 18 Nov: zones test #105z FAIL (`tools/zone_test.py`): A +0.37 SE, B ulta -0.34 SE (shart 2 SE) = zones sirf naqsha, 5EA qaide wahi.

## Khule kaam (upar wala pehle)
| # | Kaam | Haal |
|---|---|---|
| **K11** | m8.5 LIVE par **HUA 17 Nov** (SS: chart par m8.5). `JasLarai` j2 = Navigator mein `JasLarai1_EA` -> demo 472716649 par lagana, **deewar OFF** (test #3 fail) | **17 Nov SS: PC par sirf 2 MT5 khule (474832446 FTMO demo + 253687618 LIVE); 472716649 KISI par login NAHI** (= c1 bhi nahi chal raha). Salah: 3rd MT5 alag folder C:\MT5_DEMO2 mein 472716649 login + j2; purane 2 MT5 mein login KABHI na badlein (un ke EA naye account par chalne lagen) |
| R2 | Rehnuma r2 | **TV par CHAL RAHA (17 Nov SS, XAUUSD 4h, error nahi)** - ab sirf nazar; 1H BUY idea demo pehle |
| K6 | LIVE report se user ka asli tareeqa (naqsha, test nahi) | K11 ke baad; user ki haan |
| K7 | Kachhua e2 demo 474832446 | PEHLI TRADE 17 Nov: XAG SELL 0.01 @47.148 SL 51.560 (= Python). k2 ki pehli trade ka intezar |
| K5 | Tokri EA tk2 demo par | ruka (user: tokri band) |
| K12 | PC Claude: PowerShell `cd D:\JAS` -> `claude.cmd`, pehle `git pull`; D:\JAS mein faltu file NAHI | MT5 test ke liye ALAG `C:\MT5_TEST` |
| T1 | t5 Forward gold H4 HUI (3.0 curve-fit NAHI, munafa 2024-26 ki chaal se) | agla: wahi US500m H4 - user ki marzi |
| **K19** | Kachhua Naqsha Pine (j3.2 jaisa) | **k1 BANA 17 Nov** `indicators/jas_kachhua_naqsha.pine` (j3.2 nahi chhua), pinecheck saaf. Agla: user TV par paste (gold 4H / 1D) + SS; error ho to k1.1 |
| K8 | TV Store update ho to robocopy dobara | jab update aaye |
| FTMO | ~20 Nov Black Friday offer ftmo.com par check (`docs/bank.md` yaad dilao) | tareekh par |
