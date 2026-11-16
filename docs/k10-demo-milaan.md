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

## Hissa 2 - signal ka milaan (HUA 16 Nov, 7 / 8 trade) - `python3 tools/milaan_k10.py`
Data: user ne QDM (qdmcli) se USA500IDXUSD + USATECHIDXUSD M1 1 Oct - 15 Nov diya (`data/demo_474832446/QDM_M1_20261001_1115.zip`); sona repo ke M1 (4 Nov tak) se.
| # | Demo trade | Python (Dukascopy) | Demo (Exness) | Faisla |
|---|---|---|---|---|
| 1 | i6 US500 2 Nov | 2 Nov IBS 0.12 = BUY, 3xATR 259.1; band 4 Nov (IBS 0.95) | 2 Nov 21:16, fasla 263.0; band 4 Nov 21:16 | **MILA** (Python 29 Oct se trade mein tha - EA 1 Nov ko laga; signal ka din, SL fasla, band ka din wahi) |
| 2 | i6 USTEC 2 Nov | 2 Nov IBS 0.16 = BUY, 3xATR 1755.7; SL 5 Nov | 2 Nov 21:16, fasla 1779.3; SL 5 Nov 23:18 | **MILA** (wahi wajah; fasla 1.3% farq) |
| 3 | t5 XAU 4 Nov | 4 Nov 06:00, fasla 246.2 | 4 Nov 06:01, fasla 246.5 | **BILKUL MILA** (band hona: data 4 Nov tak) |
| 4 | t5 XAG 4 Nov | data 27 Oct tak | 4 Nov 10:00 | **BAQI** (MT5 XAGUSDm Export Bars chahiye) |
| 5 | t5 US500 4 Nov | 4 Nov 14:00 @7658.7, fasla 306.6 -> 5 Nov 18:00, -0.86R | 4 Nov 14:01 @7659.3, fasla 310.4 -> 5 Nov 18:01, -0.89R | **BILKUL MILA** |
| 6 | i6 US500 5 Nov | 5 Nov @7346.2, fasla 353.7 -> 9 Nov @7553.5, +0.59R | 5 Nov 21:16 @7349.5, fasla 354.8 -> 9 Nov 21:16 @7557.6, +0.59R | **BILKUL MILA** |
| 7 | t5 US500 10 Nov | 10 Nov 02:00 @7559.7, fasla 351.0 (khuli) | 10 Nov 02:01 @7562.4, fasla 351.9 (khuli) | **BILKUL MILA** |
| 8 | t5 USTEC 11 Nov | 11 Nov 06:00 @28150.0, fasla 2023.0 (khuli) | 11 Nov 06:01 @28170.4, fasla 2031.4 (khuli) | **BILKUL MILA** |

- **Ulta bhi sahi:** 1 Nov ke baad Python ka koi US500 / USTEC signal aisa nahi jo demo mein na ho, aur demo ki koi trade aisi nahi jo Python mein na ho.
- Qeemat ka farq (2-20 point) = broker (Exness vs Dukascopy); R mein farq 0.00-0.03.
- Sabaq: EA beech mein lagne se pehli IBS trade test se alag din khulti (test purani trade mein hota) - ghalti nahi.
- QDM: screen Smart App Control ne roki (`QuantDataManager_ui.exe`, publisher nahi); `qdmcli.exe` seedha kholo -> `-symbol action=list`, `-data action=update symbols=USA500IDXUSD`, `-data action=export ...`. Symbol naam BINA nuqte / slash (USA500IDXUSD, USATECHIDXUSD).
