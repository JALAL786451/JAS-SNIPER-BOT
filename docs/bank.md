# BANK - rakhi hui strategies (pass shuda / qareeb, magar abhi istemal nahi)

**Claude:** jab neeche "kab yaad dilana" wali koi baat aaye, user ko KHUD bata do - user puchhe ya na puchhe
(user 1 Nov 2026: "main bhool bhi jaun to us waqt yaad numayan kar dena, bohot zaroori").

| # | Strategy | Saboot | Abhi kyun nahi | Kab yaad dilana |
|---|---|---|---|---|
| **59** | **Chutti se pehle wala din** - SPX + NDX, NYSE calendar; din d close BUY, chutti se pehle wale din close band. TV `indicators/jas_chutti.pine` h1, Python `tools/ftmo60.py` (`chutti_trades`) | TV 1971-2018: 688 tr, is din +0.116% vs aam +0.044%. **2019+ ASLI PASS: 146 tr, jeet 68%, +0.155R** (dono index akele bhi pass) | #60: FTMO **challenge** mein #53 ke saath jorne se fail barhe (2012-18 mein asar kamzor). ~19 tr/saal | (1) **FTMO challenge PASS ke baad** (funded: target nahi, sirf hadd) - 0.25% par jor ka naya test (2) real account ka mansooba (3) user "trade barhao" / naya jor maange (4) koi bhi naya FTMO jor test |
| **69** | **Tide (Kachhua) oil** - USOIL + UKOIL daily (`ftmo_test.kachhua_trades`, `tools/ftmo69.py`) | #6 commodity tokri ASLI PASS (TV); 2012-18 USOIL +0.175R, UKOIL +0.356R; FTMO CHUNAO 67/0 (0.5%) | #69 IMTIHAN: #68 ke saath fail 0 -> 11 (2020 tel crash) | (1) FTMO pass ke baad funded par chhote risk ka naya test (2) real account (3) commodity / trade barhane ki baat |
| **76** | **Kachhua BTC** - BTCUSD daily (`ftmo_test.kachhua_trades`), FTMO #68 + BTC 0.5% alag slot (`tools/ftmo76.py`) | CHUNAO 2012-18: 70/0 (#68 64/2); IMTIHAN 2019+: 83/0 median 11.1 (#68 11.4); judge CLEAN | Dono daur BTC pehle Radar mein dekha hua = saboot kamzor (user 2 Nov: bank); faida sirf 0.3 mahina; FTMO BTC swap maloom nahi | (1) FTMO pass ke baad funded par demo (aage ka data) (2) real account (3) crypto / trade barhane ki baat (4) koi bhi naya FTMO jor test |
| **67** | **US chutti ki khirki x 7 non-US index** (DAX, FTSE, CAC, SX5E, N225, XJO, HSI) - `indicators/jas_khirki67.pine` k2 | TALAASH 2140 tr jeet 61% +0.077R, 6.1x drift; 2019+ 505 tr jeet 64% +0.075R, 5.7x drift (aadha dekha) | **#68 FTMO PASS (83/0, median 10.8)** = bank se nikal kar mansoobe mein (JasKhirkiEA) | - |
| 65 (nazar) | VIX Stretches SPX + NDX (`indicators/jas_vix.pine` v3, Connors 2008) | TALAASH 1990-2018 357 tr jeet 76% +0.094R; 2019+ 142 tr jeet 73% +0.090R, Exp-2SE +0.008 - sirf drift shart (1.7x < 2x) par FAIL | qaida ki drift shart | index girawat-khareed / IBS ke saath jor, ya 2028+ naye data par (qaida pehle) |
| 64 (nazar) | Turn of the Month SPX + NDX (`indicators/jas_tom.pine` m1) | TALAASH 1971-2018 mazboot (980 tr, +0.230R, 2.4x drift); 2019+ 186 tr +0.185R, jeet 59% - PASS nahi (Exp-2SE -0.058, 1.35x drift) | 2019+ saabit nahi | calendar / chutti ki baat, ya 2028+ naye data par dobara (qaida pehle) |
| 57 (nazar) | JPN index 4H trend (#47 qaida) | 2019+ 163 tr +0.069R, saal 6/8 - PASS nahi (2.33 SE se kam) | saboot kamzor | Asia index / trend tokri barhane ki baat |

Naya pass shuda magar "abhi nahi" = yahan ek line + `CLAUDE.md` wali yaad-dihani qaim.
