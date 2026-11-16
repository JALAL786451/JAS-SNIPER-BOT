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
- Data user ne diya: US500 / USTEC M1 2012-26 + gold M1 (QDM). Kitabi ideas #102-104 FAIL (list khatam).
- **TOKEN BACHAT (user 16 Nov "haan"):** nayi chat KHUD nahi khulti (user kholta, "TRADING" likhta); shuru mein sirf hook; chat khatam = halki rasm (CLAUDE.md). Rozmarra kaam sasta model, Fable sirf mushkil kaam.

## Khule kaam (upar wala pehle)
| # | Kaam | Haal |
|---|---|---|
| **K11** | `JasMauqa_m85.mq5` (LIVE, m8.4 ki jagah, InpWReset false) + `JasLarai.mq5` j2 (demo 472716649: deewar OFF, phir InpWall true + popup) | **user ka F7 SS baqi** (dono cloud mein compile nahi) -> error theek (nayi build, usi file mein) |
| **R2** | `indicators/jas_gold_rehnuma_r2.pine` (r1 + design + chhota BUY idea 1H + SELL ittila; naap `tools/rehnuma_r2_test.py`) | **user ka TV compile SS baqi** (gold 15m / 1H chart) |
| K6 | LIVE report se user ka asli tareeqa (naqsha, test nahi) | K11 ke baad; user ki haan |
| K7 | Kachhua e2 demo 474832446 | pehli asli trade (chandi / gold SELL) ka SS aaye to milaan (k2 bhi) |
| K1 | D:\JAS = GitHub ka copy (`tools/JAS_DRIVE.bat`) | user SBS kar raha |
| K5 | Tokri EA tk2 demo par | ruka (user: tokri band) |
| K8 | TV Store update ho to robocopy dobara | jab update aaye |
| FTMO | ~20 Nov Black Friday offer ftmo.com par check (`docs/bank.md` yaad dilao) | tareekh par |
