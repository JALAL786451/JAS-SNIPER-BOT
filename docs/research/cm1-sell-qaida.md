# Koshish #111m - C-M1 month-end "dash for cash" SELL, 8 index (69vi, 19 Nov 2026, user "test karo")
Research `docs/research/daur11-sell-agent.md` (Etula et al. RFS 2020). Qaida test se PEHLE likha + commit, badalna MANA. Code `tools/cm1_sell111.py`.
Data `data/yahoo/D1.zip` (price index, dividend nahi). Ginti (bina nateeja) TALAASH: DE30 279, UK100 231, FR40 179, EU50 114, JP225 284, AUS200 194, HK50 258, US30 215 = 1,754; IMTIHAN ~605.

## Qaide
- Market + shuru: DE30 1990, UK100 1996, FR40 2000, EU50 2007, JP225 1990, AUS200 1999, HK50 1990, US30 Jun 1995.
- Settlement s: US30 3 -> 2 (5 Sep 2017) -> 1 (28 May 2024); UK / FR / EU50 3 -> 2 (6 Oct 2014); JP 3 -> 2 (16 Jul 2019); AUS 3 -> 2 (7 Mar 2016); DE, HK 2.
- T = market ka mahine ka aakhri trading din; D = T-(s+1). SELL D-5 ke close, band D ke close (5 trading din).
- SL 3 x ATR20 D1 (high chhoye; gap = open), TP nahi. Window (D-4..D) mein NYSE chhutti-se-pehle din = skip (NYSE din US500 data se).
- Kharcha 0.03% har taraf (faisla); ittila 2x aur bina kharcha. Risk 0.15% / market (sirf demo ke liye, test R mein).

## PASS (TALAASH = T < 2019)
8 market ka har mahine tokri-ausat R (ek hafte ki trades ek hi daao = mahina ek nukta): n >= 100 trade, tokri Exp > 0, Exp - 2SE > 0 (mahinon par), >= 5/8 market Exp > 0.
PASS par hi IMTIHAN 2019+ ek dafa: tokri Exp > 0 aur >= 5/8 musbat.
Dono PASS bhi ho to demo se PEHLE: FTMO + Exness index short par dividend kat-ta hai ya nahi (SS). Kat-ta ho = idea khatam.
Chances (agent): P(TALAASH) ~0.30, P(IMTIHAN | TALAASH) ~0.20.

## NATEEJA (19 Nov, Python, TALAASH 1990-2018) - **FAIL**
| Kharcha | Trade Exp | Tokri / mahina Exp | -2SE | Musbat market |
|---|---|---|---|---|
| 0.03% (faisla) | +0.008R | +0.0085R | -0.050 | 3/8 |
| 2x | -0.008R | -0.0075R | -0.066 | 3/8 |
| bina kharcha | +0.024R | +0.0245R | -0.034 | 7/8 |
Market (0.03%): US30 +0.059, UK100 +0.038, DE30 +0.028, FR40 -0.002, EU50 -0.007, JP225 -0.010, AUS200 -0.017, HK50 -0.032.
- Asar asli lagta hai (bina kharcha 7/8 musbat) magar bohot chhota (~0.02R) - kharcha kha jata. Agent ka andaza (net ~0.01-0.02R, t < 2) sahi nikla.
- IMTIHAN dekha NAHI. C-M1 band, dobara NAHI. Dividend sawal ki zaroorat nahi rahi.
