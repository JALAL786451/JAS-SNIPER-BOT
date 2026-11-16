# K10 / B - demo 474832446 vs test milaan (16 Nov 2026, 61vi)

Report: `data/demo_474832446/ReportHistory_20261115.xlsx` (user, 15 Nov 21:04 server = UTC). 8 trade (6 band + 2 khuli), sab BUY. k2 / e2 = 0 trade.

## Hissa 1 - sirf report se (HUA): lot, waqt, SL, kharcha
| # | EA | Symbol | Khuli (UTC) | Lot | Entry | SL | Risk $ | Risk % (balance) | Nateeja | R |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | i6 | US500m | 2 Nov 21:16 | 3.79 | 7563.12 | 7300.17 | 996.6 | 1.00 | +565.66 (4 Nov 21:16, qaide se) | +0.57 |
| 2 | i6 | USTECm | 2 Nov 21:16 | 0.56 | 28120.01 | 26340.67 | 996.4 | 1.00 | -996.43 (SL, 5 Nov 23:18) | -1.00 |
| 3 | t5 | XAUUSDm | 4 Nov 06:01 | 0.03 | 4001.869 | 3755.378 | 739.5 | 0.74 | +47.83 (10 Nov 18:01) | +0.06 |
| 4 | t5 | XAGUSDm | 4 Nov 10:00 | 0.02 | 51.996 | 45.881 | 611.5 | 0.61 | -168.20 (12 Nov 14:01) | -0.28 |
| 5 | t5 | US500m | 4 Nov 14:01 | 2.41 | 7659.33 | 7348.92 | 748.1 | 0.75 | -662.41 (5 Nov 18:01) | -0.89 |
| 6 | i6 | US500m | 5 Nov 21:16 | 2.81 | 7349.48 | 6994.65 | 997.1 | 1.00 | +584.73 (9 Nov 21:16) | +0.59 |
| 7 | t5 | US500m | 10 Nov 02:01 | 2.13 | 7562.35 | 7210.48 | 749.5 | 0.75 | khuli | |
| 8 | t5 | USTECm | 11 Nov 06:01 | 0.36 | 28170.41 | 26138.98 | 731.3 | 0.73 | khuli | |

- **Lot = sahi:** har trade ka risk nishane (i6 1%, t5 0.75%) par ya lot-step ki wajah se zara neeche (chandi 0.02 = 0.61%; 0.03 hota to 0.92% = hadd se upar). Kabhi upar NAHI.
- **Waqt = sahi:** i6 khulna / band hona 21:16 UTC = 16:16 NY (test: 16:15). t5 sirf 4H mombatti ki hadd par (02 / 06 / 10 / 14 / 18 UTC = test ka NY 17:00 wala block).
- **SL = sahi:** USTEC SL bilkul 26340.67 par bhara (phislan 0) = -1.00R, test jaisa.
- **Kharcha:** commission 0, swap 0 (test: swap 0 sahi). DIV +7.16 (index BUY par, test mein nahi = chhota bonus).
- **Ek position per EA per market:** sahi. US500 par i6 + t5 ek saath BUY (4-5 Nov) = K9 wala hi khatra (din ki hadd), 5 Nov ko dono ka nuqsan ek din: -662 + -996 = -1.66%.
- Nateeja ab tak: i6 +0.15R (3 trade, 2 jeet; test jeet 71%), t5 -1.10R (3 band, 1 jeet; test jeet 39%) = 6 trade, ittefaq ki hadd mein.

## Hissa 2 - signal ka milaan (16 Nov: jitna repo ke data se ho saka)
Sab branch dekhi (31) - market data sirf isi branch mein. Aakhri tareekh: USTEC M1 5 Nov, XAU M1 4 Nov, US500 M1 30 Oct, XAU/XAG/US500/USTEC H1 27 Oct. (H1 27 Oct tak + M1 se bana H1.)
| Demo trade | Python (Dukascopy) | Demo (Exness) | Faisla |
|---|---|---|---|
| #3 t5 XAU BUY | 4 Nov 06:00, SL fasla 246.23 | 4 Nov 06:01, SL fasla 246.49 | **BILKUL MILA** (wahi mombatti, SL fasla 0.1% farq; qeemat 4.3 farq = broker) |
| #2 i6 USTEC BUY | 29 Oct se khuli (EA demo par 1 Nov ko laga), SL 5 Nov 14:00 = -1R | 2 Nov 21:16 khuli, SL 5 Nov 23:18 = -1R | rukh + nateeja wahi; entry ka din alag (EA baad mein laga) = seedha milaan nahi |
Baqi 6 trade (US500 x4, XAG, USTEC 11 Nov) = data nahi (US500 30 Oct, XAG 27 Oct par khatam). User se QDM update (4 symbol, 16 Nov tak) ya MT5 Export Bars chahiye.
