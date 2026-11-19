# Koshish #108r - gold D1 RALLY-SELL (69vi, 19 Nov 2026, user "test karo")
Qaida test se PEHLE likha aur commit kiya. Nateeja dekhne ke baad badalna MANA. Code: `tools/rally_sell108.py`.
Data: `data/ftmo/XAU_XAG_H1_dukascopy.zip` (2003-05 se), D1 = 17:00 NY din. Ginti (bina nateeja, G5): gold TALAASH 53 / IMTIHAN 11, silver 82 / 32.

## Qaide
- Daur: D1 EMA50 < EMA200 aur close < EMA200.
- Ishara (band candle): high >= EMA50 aur close < EMA50 -> SELL close par. Ek waqt ek trade.
- SL = entry + 2 x ATR14 = 1R. Exit: high SL chhoye (gap = open) YA close > EMA50.
- Kharcha 0.03% har taraf, swap 0 (swap-free). TP nahi, aadhi nahi.

## PASS (TALAASH = entry < 2019) - chaaron lazmi
gold n >= 30, gold Exp > 0, gold Exp - 2SE > 0, silver Exp > 0 (sirf jaanch row). PASS par hi IMTIHAN (2019+) ek dafa: gold Exp > 0 aur silver Exp > 0.
PASS = Pine ittila + demo ka qaida alag likhna (live NAHI). FAIL = idea band, dobara NAHI.

## G1-G10 (imaandari)
G1 trend-following 100+ saal / 50+ market HAAN; magar gold SELL khaas taur par kamzor (#106s, K13) - ADHA.
G2 rally par khareedne wale der se aate hain, rukh chalta rehta hai; gold mein central bank girawat par khareedte hain - KAMZOR.
G3 D1, SL 2 ATR, 0.25% risk HAAN. G4 XAU Exness + FTMO HAAN. G5 gold 53 (<100) NAHI - silver 82 sirf sahara.
G6 t5 gold BUY ke ulat = mel kam HAAN (silver: e2 Kachhua XAG SELL se mel). G7 swap 0, spread chhota HAAN. G8 ye file HAAN.
G9 sirf girte daur mein ~3-5 trade / saal - chhota faida. G10 P(TALAASH) ~20%, P(IMTIHAN | TALAASH) ~50%, P(FTMO behtar) ~5%.
User ne G5 NAHI ke bawajood "test karo" kaha (19 Nov) - test hua, faisla upar wale qaide par.

## NATEEJA (19 Nov, Python, TALAASH 2003-2018) - **FAIL**
| Market | tr | jeet | Exp | -2SE | kul |
|---|---|---|---|---|---|
| gold | 53 | 15.1% | -0.146R | -0.319 | -7.7R |
| silver | 82 | 15.9% | -0.054R | -0.239 | -4.5R |
- Exit: gold 52 / 53 "close > EMA50" (ausat -0.13R), 1 SL. Engine theek - rally EMA50 ke upar hi band hoti rahi.
- IMTIHAN (2019+) dekha NAHI. Sabaq: gold par SELL ka 6vi alag shakal (breakout #106s, ST K13, #24/#17, #73, rally #108r) bhi manfi = gold SELL band, dobara NAHI.
