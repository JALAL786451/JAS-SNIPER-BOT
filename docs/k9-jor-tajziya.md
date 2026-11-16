# K9 / A - FTMO jor #101 ka tajziya + Koshish #105 (behtar taqseem) - 16 Nov 2026, 61vi chat

Jor: t5 trend 0.75% + i6 IBS 1% + k2 khirki 0.15% + Kachhua e2 0.25%. Sirf CHUNAO 2012-2018, mustaqil $100k, swap 0.
Tool: `python3 tools/jor105.py` (tajziya), `python3 tools/taqseem105.py` (#105). IMTIHAN 2019+ NAHI khula.

## 1. Har EA ka hissa (7 saal, % of 100k)
| EA | risk | trades | avg R | jeet | 2012 | 2013 | 2014 | 2015 | 2016 | 2017 | 2018 | kul | hissa |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| t5 trend | 0.75 | 494 | +0.033 | 39% | -2.5 | +1.1 | -0.3 | -6.3 | +5.8 | +12.5 | +1.3 | +11.5 | 23% |
| i6 IBS | 1.00 | 269 | +0.082 | 71% | -0.1 | +4.0 | +4.3 | +2.4 | +0.8 | +8.6 | +2.0 | +22.2 | 45% |
| k2 khirki | 0.15 | 353 | +0.035 | 60% | +0.3 | +1.0 | +0.9 | +0.6 | +0.1 | -0.7 | -0.3 | +2.0 | 4% |
| e2 Kachhua | 0.25 | 566 | +0.097 | 42% | +1.5 | +4.4 | +6.3 | +3.4 | -1.7 | 0.0 | -0.1 | +14.0 | 28% |
| **JOR** | | | | | -0.8 | +10.6 | +11.2 | +0.1 | +5.0 | +20.5 | +2.9 | **+49.6** | |

## 2. Mahana (84 mahine)
| EA | ausat % | std | musbat mahine | Sharpe | bura mahina | max girao | 1% risk par ausat |
|---|---|---|---|---|---|---|---|
| t5 | +0.14 | 1.62 | 48% | 0.29 | -3.37 | -11.8% | +0.18 |
| i6 | +0.26 | 0.89 | 56% | 1.03 | -2.14 | -5.4% | +0.26 |
| k2 | +0.02 | 0.19 | 48% | 0.43 | -0.88 | -1.5% | +0.16 |
| e2 | +0.17 | 1.02 | 50% | 0.56 | -1.87 | -6.8% | **+0.67** |
| JOR | +0.59 | 2.36 | 55% | 0.87 | -4.87 | -13.8% | |

## 3. Aapas ka mel (correlation)
Mahana: t5-i6 0.07, t5-k2 0.03, **t5-e2 0.22** (sab se zyada), i6-k2 0.08, i6-e2 0.04, k2-e2 0.03. Rozana: sab 0.16 se kam. = charon taqreeban alag (jor ka asal faida yahi).

## 4. Kaun raftar deta, kaun rokta
- Jor ke 38 manfi mahine (ausat -1.44%): **t5 -1.04**, e2 -0.28, i6 -0.11, k2 0.00. = **rokne wala t5** (jor manfi ho to t5 sirf 13% dafa musbat).
- Jor ke 20 behtareen mahine (+3.73%): **t5 +2.00**, e2 +0.85, i6 +0.83. = **raftar bhi t5** (2016-17). t5 = jhoola: bura bhi wahi, acha bhi wahi.
- Mustaqil kamai: i6 (45% hissa, Sharpe 1.03). Sab se sasta risk: e2 (1% risk par +0.67/mahina, i6 se 2.5x).
- Challenge (84): jor 69/0/15 med 15.5 | bina t5 46/0/38 med 21.0 | bina i6 61/**12 fail** med 27.0 | bina k2 69/0 med 18.0 | bina e2 68/0 med 27.6.
  Aadha: t5 66/0 med 19.4 | i6 66/3 fail med 20.7 | k2 69/0 med 16.1 | e2 68/0 med 20.5. = koi EA faltu nahi; i6 hifazat, t5 + e2 raftar, k2 chhota madadgar.

## 5. Din ki hadd (5%)
7 saal mein din <= -1%: 56 (ausat i6 -0.80, t5 -0.55), <= -2%: 2, <= -3%: **1 = 4 Jan 2016 -4.37%** (t5 -1.82 + i6 -1.91 + k2 -0.62; US index gap, dono ek saath BUY).
= hadd ka khatra sirf t5 + i6 ke US500/USTEC par ek saath BUY hone se; e2 / k2 din ki hadd mein taqreeban hissa nahi dalte.

## 6. Koshish #105 - behtar taqseem (qaida `docs/purana-haal.md` grep "Koshish #105 qaida") = **CHUNAO FAIL**
83 ummeedwar (kul khula risk <= 8.80%): **koi bhi** abhi wali (0.75 / 1.0 / 0.15 / 0.25: 69/0/15, med 15.5, bura din -4.37) se shart par behtar nahi.
Qareeb tareen: 0.625 / 1.25 / 0.15 / 0.25 = 69/0, med 15.2 magar bura din -4.54 (hadd ke aur qareeb) -> rad. e2 0.30+ k2 ke baghair = P2 fail 1-3.
**IMTIHAN nahi khola. Nateeja: abhi wali taqseem hi theek - demo par kuch na badlein.**
Sath ki baat (sirf CHUNAO, test nahi): t5 kam karne se bura din behtar (0.50 par -3.76) magar raftar 15.5 -> 18.3 mahine.
