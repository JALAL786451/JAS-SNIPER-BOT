# Koshish #109s - gold 4H SELL: V1 EMA20/50 + V2 sirf EMA50 (69vi, 19 Nov 2026, user ki hidayat)
User: "BUY ke liye EMA50/200 + D1 sahi; SELL ke liye EMA20/50 ya sirf EMA50 aur 4H." #108r (D1 rally-SELL) FAIL ke baad.
Qaida test se PEHLE likha aur commit kiya, badalna MANA. Code `tools/sell4h109.py`. Data `data/ftmo/XAU_XAG_H1_dukascopy.zip` (2003+), 4H = 17:00 NY se 4 ghante.
Ginti (bina nateeja): V1 gold 718 / silver 797 TALAASH; V2 gold 841 / silver 927.

## Qaide (4H, band candle)
- V1: EMA20 < EMA50 aur close < EMA50; high >= EMA20 aur close < EMA20 -> SELL close par; exit close > EMA20.
- V2: EMA50 neeche ja rahi (pichli candle se kam); high >= EMA50 aur close < EMA50 -> SELL; exit close > EMA50.
- Dono: SL entry + 2 x ATR14 (4H) = 1R (gap = open), ek waqt ek trade, kharcha 0.03% har taraf, swap 0.

## PASS (TALAASH < 2019), har variant alag - SAKHT (gold SELL ki 7vi koshish, 2 variant)
gold n >= 100, gold Exp > 0, gold Exp - 2.5SE > 0, silver Exp > 0. PASS par hi IMTIHAN 2019+ ek dafa: gold Exp > 0 aur silver Exp > 0.
FAIL dono = gold SELL EMA wale sab band. PASS = Pine ittila + demo qaida; t5 (gold 4H BUY) se takrao ka hal pehle (ek market ek position).
