# KHUD NAZAR - EA ka mizaj, market ka intikhab, aur ASLI PASS ka jhol (17 Nov 2026, 66vi chat)

User (17 Nov): "Aisi observation poochhne par kyun? Claude khud dekhe, bataye, samjhaye. Main miss kar doon to 1 saal ka
intezar. Mera itna nuqsan trading par nahi hoga jitna testing par." -> Qaida `CLAUDE.md` + `docs/trading-pakki.md` 1-NAYA (6-8).

## 1. Jo baat poochhe bina batani thi (FTMO demo 474832446, History 17 Nov 22:19, 8 band trades)
1. **8 mein se 8 BUY, SELL 0.** i6 sirf BUY; t5 ne abhi tak sirf BUY. Market lambi gire to sab EA ek taraf phanste hain.
2. **t5 + i6 dono US500 / USTEC par.** Dono ek saath BUY ho kar index gap se gire = dono saath haarte. Test mein 7 saal mein 1 bara din
   (4 Jan 2016, -4.37%; FTMO din ki hadd 5%). Demo par 4-5 Nov yahi hua (t5 US500 -662.41 + i6 USTEC -996.43).
3. **t5 ke andar bhi US500 + USTEC = taqreeban EK hi daao** (dono US index, aapas mein bohot milte). 16 Nov 18:00 4H palta to t5 ki
   dono ek saath band: US500 -232.53 + USTEC -294.85. Yani US index par ek waqt mein 4 tak BUY (t5 x2 + i6 x2) ho sakti hain.
4. i6 USTEC poora SL (-996, ~1%): i6 ka ek nuqsan ~2 jeet ke barabar = munafa jeet ki dar (test 71%) par tika. Demo 2/3.
5. t5 5 mein 4 haara: test mein t5 "jhoola" (bura bhi wahi, acha bhi wahi) - abhi had ke andar; 15-20 trade par yahi = khatre ka nishan.
6. Gold / silver t5 trade 6-8 din khuli: t5 ki aadat, swap-free hai - khatra nahi.

## 2. User ka shak: "ASLI PASS ke sakht imtihan mein jhol hai" - haan, 4 jhol (imandari se)
| # | Jhol | Asar |
|---|---|---|
| J1 | **Trades ko alag alag gina**, jabke US500 + USTEC (aur XAU + XAG) ek hi din ek hi taraf chalte. SE asal se chhota -> Exp-2SE behtar dikhta. (#102 se "cluster" SE shuru hua, magar #15 IBS, #34 t5 purane hisaab se PASS hue) | PASS asal se zyada pakka lagta |
| J2 | **Sirf BUY wala idea US index par 2019-26 ki tezi mein** - "buy and hold" se muqabla nahi kiya. Munafe ka kuch hissa EA ka nahi, market ki aam tezi ka (sabaq #15 mein khud likha tha) | Gira hua market aaye to EA kamzor |
| J3 | **IMTIHAN 2019+ kai dafa dekha gaya** (#34, #49, #53, #68, #101...). Har nayi jor / taqseem usi data par = woh ab "chhupa" nahi, aadhi talaash ban gaya | FTMO sim (85/0) zyada umeed afza |
| J4 | **Har EA akela pass hua; jor (4 EA) ka khatra market ke mel (same market, same taraf) par sirf CHUNAO par dekha** - demo se pehle "kitni BUY ek waqt US index par" wali shart nahi thi | 4-5 Nov / 16 Nov jaise din |

**Kya NAHI kehna:** abhi 8 trade par t5 / i6 ko FAIL kehna bhi ghalat (bohot kam). Jhol ka matlab = pass kamzor ho sakta, zaroori nahi fail.

## 3. Naya qaida (trading-pakki 1-NAYA mein 6-8)
6. Har EA / jor ke saath **mizaj card**: BUY/SELL, TF, market, kitni der khuli, kis EA ke saath kaunsa market sanjha. Demo se pehle.
7. Test mein: (a) mile hue market (US500+USTEC, XAU+XAG) ki trades **din ke hisaab se ek cluster** (SE); (b) sirf-BUY idea ka
   **buy-and-hold se muqabla**; (c) jor mein **ek waqt ek taraf ek group** ka kul risk + bura din (2019+ par bhi, sirf CHUNAO nahi).
8. IMTIHAN data kitni dafa dekha - ginti likho; 3+ dafa = woh IMTIHAN nahi. Aakhri asli imtihan ab **demo (forward)** hai.

## 4. K20 (user: "khud karein") - HUA, neeche sec 5
Chaar EA (t5, i6, k2, e2) par J1-J4 dobara: cluster SE, buy-and-hold muqabla, US index group ka kul risk. Purane EA mein tabdeeli NAHI -
sirf naap; tabdeeli chahiye ho to naya version (ijazat ke baad).

Durusti: user ka "16" = **i6** tha (t5 aur i6 ke instrument same), 16 Nov nahi.

## 5. K20 NATEEJA (17 Nov, `python3 tools/k20_jhol.py`, 9 sec; CHUNAO jor105 se bilkul mila = hisaab sahi)
ExpR = R per trade (kharcha samet). "Exp-drift" = market ki aam chaal (buy-and-hold) nikaal kar asli edge.

| EA | Mizaj | IMTIHAN 2019-26 ExpR | cluster Exp-2SE | **Exp-drift** (CHUNAO / IMTIHAN) | Matlab |
|---|---|---|---|---|---|
| t5 | **sirf BUY** (code mein SELL hai hi nahi) | +0.137 | +0.067 | **-0.005 / +0.027** | munafa taqreeban sara market ki tezi ka |
| t5 US hissa | US500+USTEC | +0.090 | +0.009 | **-0.029 / -0.024** | US par t5 ka apna edge = 0 (dono daur manfi) |
| t5 MET hissa | XAU+XAG | +0.193 | +0.075 | +0.016 / +0.088 | CHUNAO mein ExpR -0.016 tha; daur badalta hai |
| i6 | sirf BUY | +0.075 | +0.034 | **+0.039 / +0.038** | chhota magar dono daur SAME = asli edge |
| k2 | sirf BUY | +0.077 | +0.053 | **+0.022 / +0.057** | sab se saaf edge (risk 0.15 chhota) |
| e2 | BUY+SELL | +0.086 | -0.010 | +0.040 / +0.015 | patla; US hissa drift ka, MET behtar |

- **J1 (cluster):** asar chhota (t5 +0.074 -> +0.067, i6 +0.041 -> +0.034). Bara jhol nahi.
- **J2 (buy-and-hold): SAB SE BARA JHOL.** t5 ka PASS asal mein "4H upar ho to US index / gold khareedo" = market ki tezi. Market 2019-26 jaisa upar na jaye to t5 ka faida khatam; US par t5 i6 ka hi daao dohrata hai bina apne edge ke.
- **J4 (US group):** jab US par trade khuli ho to 80% waqt 2+ (sab BUY), max SL-risk ek saath **3.50%** (t5 0.75 x2 + i6 1 x2). Bura din: 2012-18 sirf 1 (-4.37%, 4 Jan 2016), 2019-26 sab se bura -2.56% (3 Feb 2025). FTMO 5% kabhi nahi chhua.
- **J3:** IMTIHAN 2019+ 5+ dafa dekha = ab sirf demo forward asli imtihan.
- **Faisla user ka (purane EA mein tabdeeli NAHI, ijazat):** (a) kuch na badlo, demo chalne do; (b) naya jor test: t5 sirf XAU/XAG ya t5 US par aadha risk - sakht shart ke saath (nateeja dekh kar chunna = sakht imtihan zaroori).

## 6. K21 (user "B", 17 Nov) - naya jor t5 ke bina US / aadha US - SHART TEST SE PEHLE (badalna MANA)
Ummeedwar: V1 = t5 sirf XAU+XAG 0.75; V2 = t5 XAU/XAG 0.75 + US 0.375; V3 = bina t5. Muqabla V0 = jor #101 abhi. Baqi (i6 1, k2 0.15, e2 0.25) wahi.
Challenge sim (run_cost, swap 0): CHUNAO 2012-18 (84) aur 2019+ (sab mahine) dono par.
**PASS shart (teeno ek saath, DONO daur):** (1) fail <= V0 ka fail; (2) median mahine <= V0 + 2; (3) girte market ka imtihan:
2022 (US -20%) + 2015-16 + 2018 Q4 ka kul P/L (mustaqil $100k) V0 se behtar ya barabar. Ek se zyada PASS = kam fail, phir kam mahine.
Koi PASS nahi = V0 hi rahe (demo waise hi). PASS = naya version banane ki ijazat user se, phir demo (purana EA nahi chhuna).

### K21 NATEEJA (`python3 tools/k21_jor.py`, 58 sec) = **koi PASS NAHI -> V0 (jor #101) hi rahe**
| Jor | CHUNAO pass/fail/adhoora, median | 2019+ pass/fail/adhoora, median | Girte daur % (2015-16, 2018Q4, 2022) | Shart |
|---|---|---|---|---|
| V0 abhi | 69 / 0 / 15, 15.5 | 85 / 0 / 9, 10.2 | -0.1, +4.1, -0.8 = +3.1 | - |
| V1 t5 sirf XAU/XAG | 62 / **6** / 16, **23.0** | 85 / 0 / 9, 12.7 | +7.6 | FAIL (fail 6) |
| V2 t5 US aadha | 68 / **3** / 13, **19.5** | 85 / 0 / 9, 11.2 | +5.4 | FAIL (fail 3) |
| V3 bina t5 | 46 / 0 / 38, **21.0** | 80 / 0 / 14, 22.7 | +5.1 | FAIL (median) |

**Sabaq:** t5 ka US hissa apna edge nahi rakhta, magar **market ki tezi hi FTMO target tak le jati hai** - nikaalo to fail aate / mahine barhte.
Girte market mein V0 sab se kamzor (+3.1 vs +5-7.6). = t5 US = jaan boojh kar liya hua "market tezi ka daao".
**KHUD NAZAR qaida:** US500 D1 close SMA200 se NEECHE jaye (lamba girta market) to Claude har chat mein KHUD bataye - tab t5 US ka khatra asli; tab hi V2 jaisa faisla dobara (user ki haan).
