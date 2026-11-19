# Koshish #110s - gold 1H SELL (69vi, 19 Nov 2026, user "4H ki jagah 1H + apna hisab")
Qaida test se PEHLE likha aur commit kiya, badalna MANA. Code `tools/sell1h110.py`. Data `data/ftmo/XAU_XAG_H1_dukascopy.zip` (2003+).
Ginti (bina nateeja): A gold 2955 / silver 3410 TALAASH; B gold 949 / silver 1606.

## Qaide (1H, band candle)
- A (user): EMA20 < EMA50 aur close < EMA50; high >= EMA20 aur close < EMA20 -> SELL close par; exit close > EMA20.
- B (Claude): A + sirf jab pichle mukammal din D1 EMA50 < EMA200 (BUY qaida "BUY mat lo" kahe = t5 / g3.1 se takrao kam).
- SL entry + 2 x ATR14 (1H) = 1R (gap = open), ek waqt ek trade, swap 0.

## PASS (TALAASH < 2019) har variant alag, SAKHT (gold SELL 9vi-10vi koshish)
kharcha 0.03% har taraf par: gold n >= 100, Exp > 0, Exp - 2.5SE > 0, silver Exp > 0. PASS par hi IMTIHAN 2019+ (gold + silver Exp > 0).
Ittila (faisla NAHI, pehle se elaan): gold kharcha 0.015% aur bina kharcha. 0.015% par hi musbat ho = pehle demo par asli spread naapna, phir baat.
Claude andaza (pehle): 1H par kharcha ~0.1R / trade -> A FAIL ~90%, B FAIL ~85%.

## NATEEJA (19 Nov, Python, TALAASH 2003-2018) - **A aur B dono FAIL**
| Variant | Market | tr | jeet | Exp 0.03% | -2.5SE | Exp 0.015% | bina kharcha |
|---|---|---|---|---|---|---|---|
| A (user) | gold | 2955 | 18.3% | -0.078R | -0.136 | -0.022R | +0.034R |
| A | silver | 3410 | 17.2% | -0.117R | -0.155 | - | - |
| B (A + D1 EMA50<200) | gold | 949 | 20.0% | -0.002R | -0.141 | **+0.062R (SE 0.055)** | +0.127R |
| B | silver | 1606 | 17.7% | -0.134R | -0.190 | - | - |
- B gold sab se qareeb: D1 filter ne kharche se pehle ka faida 0.034 -> 0.127R kiya. Magar 0.015% par bhi sirf ~1.1 SE (2.5 chahiye), silver bilkul ulta (-0.134R), aur ye gold SELL ki 10vi shakal = itna "acha" ek shor se bhi aa jata hai.
- Pehle se likhi shart (0.015% par musbat = demo spread naapo) lagu hoti hai, magar asli spread se bhi 2.5SE paar nahi hoga -> demo NAHI. IMTIHAN dekha NAHI.
- Sabaq: chhoti TF par kharcha faisla karta hai; D1 rukh ka filter madad karta hai. Gold SELL band (10 shaklein).
