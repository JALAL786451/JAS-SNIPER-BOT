# Factors ki GEHRI research (4 Nov 2026, 35vi chat, research agent) - test se PEHLE

Koi backtest NAHI, 2019+ data NAHI khola. Sirf paper + repo ke purane nateeje + data files ke naam.
Pehla jaiza: `factors-buniyaad.md`. Darwaza (G1-G10): `test-se-pehle-shartein.md`. U = tasdeeq baqi.

## 0. Khulasa (seedhi baat)

- Jo 3 factor CFD + FTMO par sab se mazboot hain (trend, reversal, calendar) - t5 / i6 / k2 **pehle hi unhi par** hain.
- Baqi "evergreen" factor (carry, value, low-vol, VRP) ya to CFD par nahi chalte, ya swap / broker ka hissa unhein kha jata hai.
- Sirf **2 ummeedwar** saare darwaze (kuch shart ke saath) paar karte hain: **C2 = #85 index bear-state SELL** aur
  **C1d = commodity curve + trend (tel, gas, copper)**. Teesra nahi mila - zabardasti nahi bhara.
- **Sach:** dono "bure daur ka bachao" hain, raftaar ki mashin nahi. Har ek **+0.5 se +1.5 trade / mahina** aur FTMO median par
  **0 se -1 mahina** asar. **6 mahine / 18 trade mahina** kisi bhi purane, saabit factor se is account (CFD, forex band, 1 position) par nahi aata.

## 1. Factor table A - saboot (kitna purana, chhapne ke baad)

Aam qaida (McLean-Pontiff 2016, 97 anomaly): chhapne ke baad faida **~58% kam** (sirf ~42% bachta). Harvey-Liu-Zhu 2016: naya factor
tab maano jab t > 3. Hou-Xue-Zhang 2020: 452 mein se ~65% dobara nahi bane (zyada tar chhote / "friction" wale); Jensen-Kelly-Pedersen 2023:
93 mulk mein zyada tar bade factor dobara bante hain. Matlab: TALAASH ka nateeja live mein ~aadha samjho.

| # | Factor | Asal paper | Sab se purana / bara saboot | Chhapne ke baad? | Sharpe (andaza, kharche se pehle) |
|---|---|---|---|---|---|
| 1 | Trend (time-series momentum) | Moskowitz-Ooi-Pedersen 2012 | Hurst-Ooi-Pedersen 2017: 1880-2016, 67 market | Haan magar 2012-18 phika, 2022 tez. Huang et al 2020: zyada faida "drift" se | 1 market 0.3-0.4; 50+ market ~1.0 |
| 2 | Short-term reversal / liquidity | Jegadeesh 1990, Lehmann 1990, Nagel 2012 | Share: 1934+ US. **Index: Baltussen-van Bekkum-Da 2019 - 20 index, 15 mulk: 1990 tak ulta (trend), 2000 ke baad reversal** (index fund / ETF ki wajah) | Haan (index par sirf ~25 saal, US sab se tez) | US index 0.5-0.8 |
| 3a | Turn of month (TOM) | Ariel 1987 | McConnell-Xu 2008: 1926-2005, 35 mulk mein 30 | Kamzor | 0.3-0.5 |
| 3b | Chutti se pehle | Ariel 1990, Lakonishok-Smidt 1988 | DJIA 1897-1986 (90 saal) | Haan, chhota | din par bara, saal par chhota |
| 3c | Halloween (Nov-Apr behtar) | Bouman-Jacobsen 2002 | Zhang-Jacobsen 2021: UK 300+ saal, 114 mulk | Haan (2002 ke baad bhi) | timing se +0.2-0.3 |
| 4 | Carry (roll / dividend - sood) | Koijen-Moskowitz-Pedersen-Vrugt 2018 | 1972/83-2012, 5 asset class | Haan | 1 class ~0.5 |
| 4b | Commodity basis / backwardation | Keynes 1930, Gorton-Rouwenhorst 2006 | **Levine et al 2018: 1877-2015** (backwardation 7.7%/saal vs contango 1.8%); Gorton-Hayashi-Rouwenhorst 2013: 31 commodity 1969-2006 | Haan (2014-20 achha) | 0.5-0.8 (trend ke saath ~1, Fuertes-Miffre-Rallis 2010, 37 commodity) |
| 5 | Value | Fama-French 1992, Asness-Moskowitz-Pedersen 2013 | 8 asset class 1972-2011 | US 2007-20 lamba nuqsan | 0.3-0.5 |
| 6 | Low-vol / defensive (BAB) | Frazzini-Pedersen 2014, Ang et al 2006 | 1926-2012, 20 mulk | Mila jula (2017-20 kamzor); vol-sizing OOS kamzor (Cederburg et al 2020) | 0.7 (shares, leverage ke saath) |
| 7 | Volatility risk premium | Coval-Shumway 2001, Carr-Wu 2009 | 1990+ options | Haan | ~1 magar bhayanak crash (Feb 2018) |
| 8 | Crisis alpha / bear-state | MOP 2012, Goulding-Harvey-Mazzoleni 2023 | HOP 2017: 60/40 ke 10 mein 8 bade nuqsan mein trend musbat; GHM: US 1926+ 4 haalat | Haan (2008, 2022) | SELL leg akela ~0.3 |
| 9 | Cross-asset signal | Driesprong 2008 (tel -> share, 48 mulk); Pitkajarvi 2020 (bond -> share, 20 mulk) | 1973+ / 1980+ | Kamzor | 0.3-0.6 |
| 10 | Commodity hedging pressure / mausam | de Roon et al 2000, Basu-Miffre 2013 | 1986+ (COT data) | Haan, chhota | 0.3-0.5; natgas mausam curve mein pehle se = edge nahi |
| 11 | Raat / intraday momentum | Cliff-Cooper-Gulen 2008; Gao 2018; Baltussen 2021 | 1993+ US; 60+ futures 1974+ | Haan | kharche se pehle bara, CFD par khatam |

## 1b. Factor table B - wajah, crash, CFD par, hamara haal

| # | Kaun paisa deta, kyun khatam nahi hota | Crash mein | 1D / 4H + CFD (kharcha, swap) | t5/i6/k2 mein? | Hamari koshish |
|---|---|---|---|---|---|
| 1 | Log der se maante (anchoring), herding, hedger | Faida (smile); V-palat mein nuqsan (2009, 2020) | HAAN; metal + US index sasta | **t5** (XAU XAG US500 USTEC, sirf BUY) | #26 #34 PASS; #47 #48 (28 market) FAIL; #96 commodity jor FAIL |
| 2 | Ghabraahat / fund flow mein bechne wala tez nikalna chahta - khareedar ko inaam | Lambi girawat mein nuqsan | HAAN, sirf US index (sab se zyada index fund) | **i6** | #15 #52 PASS; #28 (4 market), #57, #61 (share) FAIL |
| 3 | Tankhwah / pension ka paisa, chutti ka mood | Market jaisa | HAAN | **k2** (US chutti, 7 index) | #59 #67 PASS; #64 TOM, #70 local chutti FAIL |
| 3c | Garmi mein kam risk lena | - | Saal mein 1 trade = risk jhukao | nahi | test nahi (daur6 #5) |
| 4 | Jaldi wala (hedger) roll / sood deta | Risk-off mein crash | Carry **swap mein**; broker markup 2-3%/saal kha jata | nahi | forex BAND; #50 FAIL |
| 4b | Producer hedge karta (short), store ka kharcha; tight supply = backwardation | Mandi mein long girte | Sirf agar broker roll ko swap mein deta (U) | nahi | **C1d (neeche)** |
| 5 | Dar / bura naam wale sasta | Saalon ka nuqsan | Saalon ka kaam - FTMO ke liye bekaar | nahi | - |
| 6 | Leverage par pabandi | Bachata | Shares long-short + leverage chahiye | (R / ATR sizing = vol jaisa) | - |
| 7 | Bima khareedne wale (put) | Bara crash | Option CFD par nahi | nahi | #65 VIX FAIL |
| 8 | Bure daur mein bechne ka dabao, buri khabar dheere | Dheemi girawat (2001-02, 2008, 2022) mein faida; tez crash pakad nahi | HAAN (mahine ka faisla) | nahi (t5 sirf BUY) | #73 aaina SELL FAIL; **#85 likha, test baqi** |
| 9 | Dheere phailti maloomat | - | Signal theek, trade kam | nahi | #71 dollar filter FAIL; #86 likha |
| 10 | Hedger ka dabao | - | COT hafte ka data, chhota faida | nahi | - |
| 11 | Dealer ka maal (inventory) raat ko halka | - | Har din 2 kharche + swap | nahi | #42 FAIL (kharcha 0.07R > faida 0.028R), #9 #41 #92 FAIL |

## 2. Diversification ka hisaab - naye market se waqt kyun nahi ghata

**Grinold:** taqat (IR) = har trade ki samajh (IC) x sqrt(ALAG bets). "Alag" ginne ka formula:
N_alag = N / (1 + (N - 1) x rho). US500 + USTEC (rho ~0.9) = 2 / 1.9 = **1.05** - do nahi, ek hi bet. XAU + XAG (0.8) = 1.1.
Isi liye t5 ke 4 market asal mein ~2 bet hain.

**Naya system kab madad karta (Sharpe ka qaida):** jor ka Sharpe^2 = S1^2 + (S2 - rho x S1)^2 / (1 - rho^2).
Naya system tabhi faida deta jab **S2 > rho x S1**. Misaal (#68 ka S1 ~1.0, naya S2 = 0.5):

| rho (mel) naya vs #68 | Jor Sharpe | Waqt (agar kul risk dobara barabar kiya) |
|---|---|---|
| +0.5 | 1.00 | 0% tez |
| +0.2 | 1.05 | ~4% tez |
| 0.0 | 1.12 | ~11% tez |
| -0.3 | 1.30 | ~23% tez (11.4 -> ~8.7 mahine) |

**#28 (IBS 4 market):** naye market mein IBS ka faida ~0 tha (S2 ~0) -> sirf shor (noise) jura. **#96 (Kachhua commodity 0.25%):**
2019+ mein swap ke baad faida ~0 -> median 11.4 -> 11.5, fail 0 -> 2. **Dusri wajah:** 0.15-0.25% risk par naya system saal mein
~0.5-1% hi jorta, jab ke #68 ~15%/saal; to median mushkil se hilta. **Teesri wajah:** 2019+ mein fail pehle hi 0 hain - diversification
ka asal faida (kam girawat) wahan dikhta hi nahi. Waqt tab ghatta jab kam girawat ke badle **risk barhaya jaye** - ye user ka faisla
hai (risk hadd hum khud nahi barhate), aur #77 (P2 1.5x) ne 2012-18 mein 18 fail diye.
**Nateeja:** naya system tab kaam ka jab **rho <= 0** (behtar -0.2 se neeche) AUR S2 >= 0.5 x S1. Same factor ka naya market (rho 0.6-0.9) bekaar.
6 mahine ke liye ~+14%/saal aur chahiye (same fail par) - ye kisi ek saabit factor ka CFD par kaam nahi.

## 3. Ummeedwar (sirf 2) - gate table

**C2 = Koshish #85** (qaida pehle se likha, badalna mana: `purana-haal.md` grep "Koshish #85 qaida"): 9 index, mahine ke aakhir
12m < 0 AUR 1m < 0 -> SELL; pehla musbat mahina YA 12m >= 0 -> band; SL 4 x ATR20; TP nahi; FTMO 0.25%.

**C1d = Commodity curve + trend, do-rukha** (naya; daur9 C1 SELL + daur10 K2 BUY ko ek qaide mein; Fuertes-Miffre-Rallis 2010 /
Levine 2018 jaisa). Qaida (test se PEHLE `purana-haal.md` mein #97 ke naam se likhna, phir badalna mana):
- Market (sab, chunao nahi): USOIL (WTI), UKOIL (Brent), XNGUSD / NATGAS, XCUUSD. Copper sirf agar FTMO par ho (U) - test se pehle tay.
- Signal: TV futures F1 / F2: NYMEX:CL1!/CL2!, ICEEUR:BRN1!/BRN2! (na mile to Brent sirf CFD sim mein), NYMEX:NG1!/NG2!, COMEX:HG1!/HG2!.
- Faisla sirf mahine ke aakhri kaam ke din close par; entry agle din open (CFD).
- **BUY:** F1 > F2 (backwardation) AUR F1 ka 63 din return > 0. **SELL:** F2 > F1 (contango) AUR 63 din return < 0. Warna khali.
- **Band:** agle mahine ke aakhir shart toot jaye (ulti shart bane to band, phir agle din ulti trade - kabhi do position nahi).
- **SL** entry se 4 x ATR20(1D), gap par open. TP nahi. Risk 0.25% / trade (zyada nahi). Ek market ek position.
- **Swap shart (test se pehle, screenshot se):** jis market ki jis taraf ka swap Exness YA FTMO par -3%/saal se bura ho, wo taraf band.
- Kharcha: asli spread (gas 0.30%/taraf) faisla 2x + broker markup 2%/saal. TALAASH PASS (2x): 1990-2018 kul Exp - 2SE > 0,
  trades >= 100, 4 mein 3 market musbat, 1990-2004 aur 2005-18 dono musbat. 2019+ CHHUPA (input band) jab tak TALAASH PASS.
- FTMO: #85 jaisa (#68 + C1d 0.25%: CHUNAO 2012-18 fail <= #68; phir IMTIHAN 2019+ EK dafa: fail 0, pass >= 83, median <= 11.4).

| Gate | C2 (#85 bear SELL) | C1d (commodity curve-trend) |
|---|---|---|
| G1 saboot | HAAN: trend ka SELL hissa, 1880+ 67 market (HOP); GHM US 1926+ | HAAN: 1877+ (Levine), 37 commodity 1979+ (Fuertes) |
| G2 wajah | Bure daur mein zabardasti bechna + buri khabar dheere; pehla musbat mahina = nikal (rebound ka darr, Daniel-Moskowitz 2016) | Producer ka hedge (short) + store kharcha: contango mein long dete, backwardation mein short dete |
| G3 TF / FTMO | HAAN: mahine ka faisla, 1D; 9 x 0.25% = bure din max ~2.3% | HAAN: 4 x 0.25% = 1%; gas ka 20% jhatka ~1R = 0.25% |
| G4 instrument | HAAN: US500 US100 GER40 UK100 FRA40 EU50 JP225 AUS200 HK50 dono par | HAAN (tel, gas dono par); copper FTMO par U |
| G5 data | TALAASH: TV cash index 1D 1990-2018 (SP:SPX, NASDAQ:NDX, XETR:DAX, TVC:UKX, EURONEXT:PX1, TVC:SX5E, TVC:NI225, ASX:XJO, TVC:HSI) - user Pine chalaye. FTMO sim: disk par HAI (`data/ftmo` US500 USTEC, `JAS_ZIP` DEU GBR FRA EUS JPN AUS HKG). Trades ~150-300 = HAAN | TALAASH: TV futures 1D (upar wale). FTMO sim: disk par sirf BRENT + LIGHT (2013+); **user laaye: GAS.CMD/USD + COPPER.CMD/USD H1 (QDM / JAS_DATA)** + TV se mahine ka F1/F2 signal list 2012+. Trades ~200-350 = HAAN |
| G6 alag pan | Achha: sirf bure daur mein (12m < 0) - tab t5 aksar khali, i6 (SMA200 ke upar hi khareedta) bhi khali. rho andaza **-0.2 se -0.3** | Theek: t5 / i6 / k2 mein tel, gas, copper nahi. rho andaza **0 se +0.1** (mandi mein SELL bachata, 2022 jaisi mehngai mein BUY) |
| G7 kharcha | Theek magar patla: spread chhota; SELL par dividend / swap ~3%/saal x ~1.7 mahina = ~0.06R vs faida ~0.1-0.2R | **SHART:** sab swap par hai. Broker roll ko swap mein na de to faida aadha. Screenshot (USOIL UKOIL XNGUSD XCUUSD, long + short, Exness + FTMO) pehle |
| G8 qaida | HAAN (#85 likha, 3 Nov) | Upar likha - user "D" par #97 bana kar freeze |
| G9 faida | +0.3-0.5 trade/mahina (bure saal mein 2-3); median 0 se -0.5 mahina; 2012-18 fail kam ho sakte | +1-1.5 trade/mahina; 0.25% par ~+0.5-1%/saal = median ~-0.3 se -0.8 mahina |
| G10 chances | neeche | neeche |

**Ummeedwar NAHI bane (imaandar):**
- **#86 Dr Copper:** G5 FAIL (1990-2018 mein ~40-60 trade < 100), G1 kamzor (koi apna lamba paper nahi), daur C2 jaisa hi waqt.
- **Shares ka weekly reversal (long-short):** trade zyada milti magar FTMO ke bade share (AAPL, NVDA...) "high turnover" hain - un mein
  reversal ki jagah short-term momentum (Medhat-Schmeling 2022); aaj ke bade share chunna = drift ka dhoka (#61-63); multi-symbol EA.
- **Halloween jhukao:** nayi trade nahi, sirf Nov-Apr risk zyada = risk barhana (user ka faisla); asar < 0.5 mahina (daur6).
- **Bond signal se index (Pitkajarvi 2020):** chhapne ke baad saal kam; BUY t5 jaisi.
- **Agri trend:** Exness par nahi (G4), spread bhaari. **Raat drift:** #42 kharche ne khaya. **Index carry:** markup kha jata.

## 4. Chances (imaandar)

**Repo ka base rate:** ~96 koshish. Naya edge ASLI PASS sirf 8 (#6, #15, #26, #34, #45, #52, #59, #67) = **~8%**; jor / FTMO wale
milakar ~15 = ~16%. TALAASH PASS ke baad IMTIHAN: ~7-8 pass / ~5 fail (#54, #57, #64, #65) = **~60%**. #68 ke baad FTMO jor:
11 koshish mein sirf #76 (kamzor) behtar = **~10%**. Aur McLean-Pontiff: live faida ~aadha.

| | C2 (#85) | C1d |
|---|---|---|
| P(swap / data shart poori) | ~0.9 | ~0.5 (roll swap mein mile ya nahi) |
| P(TALAASH pass) | ~0.25 (9 index aapas mein jure = asal N kam; Exp - 2SE ke liye ~0.15R chahiye) | ~0.40 (agar swap theek): 1990-2018 mein gas contango SELL, 2008 / 2014 tel - magar ye kahani sab jaante hain (hindsight) |
| P(IMTIHAN pass / TALAASH pass) | ~0.45 (2019+ mein bear kam: 2020 V-palat, 2022 aage peeche; HK 2021-23 achha) | ~0.50 (2020 tel SELL, 2021-22 BUY achhe; 2023-25 mila jula) |
| P(FTMO mansooba behtar) | **~0.07** | **~0.05** (swap theek ho to ~0.10) |

## 5. Mashwara (agla qadam - test NAHI, pehle ye)

1. **Sab se pehle (muft):** user MT5 Specification screenshot - USOILm, UKOILm, XNGUSDm, XCUUSDm swap long + short (Exness) aur FTMO
   symbol list (copper hai?). Swap shart fail = C1d BANK, sirf C2 bache.
2. User faisla kare: dono ka asar chhota hai (median -0.5 / -1 mahina tak). Agar maqsad sirf raftaar hai, to factor research ka
   jawab: **naya factor nahi, risk** - aur risk barhana sirf user ka faisla (2012-18 ke fail #77 dekhein).
3. Agar user "test karo" kahe: pehle C2 (data + qaida tayyar, sab se sasta), phir C1d. EK dafa IMTIHAN, nateeja dekh kar qaida nahi badlega.

Sources (paper naam upar table mein): Baltussen et al JFE 132 (2019) · Levine et al FAJ 74 / nber w22793 · Goulding et al JFE 149 (2023).
FTMO symbol list (XCUUSD, NATGAS): 3rd-party blog = U, terminal mein dekhna.

## 6. Swap SS ka nateeja (4 Nov, user ke 4 Specification SS, Exness) = C1d G7 FAIL -> BANK
| Symbol (SS tarteeb) | Swap long | Swap short | Andaza % saal (notional) |
|---|---|---|---|
| USOILm (3 digit) | 0 | -70 pt = -$0.07/bbl/din | SHORT ~-19% (WTI ~$95) |
| UKOILm (3 digit) | 0 | -145.4 pt | SHORT ~-37% (Brent ~$102) |
| XNGUSDm (4 digit) | -254.6 pt | 0 | LONG ~-100%+ (gas ~$3) |
| XCUUSDm | -222.3 pt (Budh 3x) | 0 | LONG ~-16% (5 digit maan kar; pakka nahi) |
Sabaq: broker faide wali taraf ko roll NAHI deta (0), nuqsan wali taraf se bhaari kaat-ta. C1d ka carry (roll) hissa khatam -> sirf trend bachta (= #96, FAIL).
C1d BANK. Bacha sirf C2 (#85). (#96 mein tel swap 5% maana tha - asal 19-37% SELL par.)
