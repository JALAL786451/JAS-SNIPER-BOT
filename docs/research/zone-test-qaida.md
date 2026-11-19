# Koshish #105z - JAS Naqsha+5EA ke ZONES (S/R = SZ/DZ) ka test (user 18 Nov "a karo, zones test karo")

Qaida test se PEHLE likha aur commit kiya gaya. Nateeja dekhne ke baad badalna MANA hai.

## Sawal
Kya 5EA (#34 / #53) ki pass hui 4H BUY trade behtar ya badtar hoti hai jab entry ke waqt qeemat kisi zone ke qareeb ho?
Agar farq sabit na ho, to zones sirf naqsha hain aur qaide mein un ka koi kirdar nahi.

## Trades (badle nahi gaye)
- #34 ke qaide: Supertrend(10,3) 4H (H1 se, NY 17:00 se jura) upar mude to agli open par BUY. Neeche mude to agli open par band.
- 1R = 3 x ATR(10). Kharcha #34 jaisa.
- 4 market: XAUUSD, XAGUSD, US500, USTEC (`data/ftmo/` Dukascopy H1).
- Code: `tools/gold_st_tf.py` / `tools/st_tokri_4h.py` ki logic jyon ki tyon.

## Zones (Pine j3.2 jaise, 4H chart par)
- Pivot 5/5 (swing high/low) teen TF par: 4H (rank 2), 1D (rank 3), 1W (rank 4). 4H chart par 1H nahi aata, isliye shamil nahi.
- Pivot tab gina jata hai jab us ke baad 5 candle band ho chuki hon (repaint nahi).
- ATR-D = 1D ATR(14), pichhla band din.
- Naya pivot kisi maujooda level se <= 0.25 x ATR-D ho to us mein jor diya jata hai (ausat qeemat, n+1, rank max). Warna naya level.
- 80 se zyada levels hon to sab se kamzor nikalta hai, Pine `f_evict` jaisa.
- Zone ki aadhi motai = 0.10 x ATR-D.
- Entry qeemat se UPAR wala level = R (supply / SZ). NEECHE wala = S (demand / DZ).
- Doori = qeemat se zone ke qareebi kinare tak, ATR-D mein. Qeemat zone ke andar ho to doori 0.

## Pehle se tay mafrooze (sirf 1.0 ATR-D, koi aur hadd nahi ghumai jayegi)
- **A (SZ sar par):** qareeb R ki doori < 1.0 ATR-D. Mafrooza: ye trade BADTAR hain.
- **B (DZ paon mein):** qareeb S ki doori < 1.0 ATR-D. Mafrooza: ye trade BEHTAR hain.

## PASS / FAIL
1. **TALAASH (entry < 2019):** farq = Exp(achha group) - Exp(bura group).
   - A ke liye achha group = A-nahi. B ke liye achha group = B-haan.
   - Farq > 2 x SE(farq) ho to wo mafrooza TALAASH PASS. Dono groups mein kam az kam 50 trade hon.
2. **IMTIHAN (2019+), sirf TALAASH PASS wale ka, EK dafa:**
   - Farq usi taraf ho.
   - Filter wali tokri ka Exp-2SE > 0, aur Exp >= poori (bina filter) tokri ka Exp.
3. Dono pass = zones ka kirdar SABIT (qaide mein shamil karne ka mashwara, phir demo).
   Warna = zones sirf naqsha, 5EA ke qaide wahi rahenge.
- Har market ka farq bhi dikhaya jayega, magar faisla sirf KUL (4 market) par.

## NATEEJA (18 Nov, `python3 tools/zone_test.py`) - **FAIL, IMTIHAN nahi chala (qaide ke mutabiq)**
Trades #34 se hoo-ba-hoo mili (760 tr, Exp +0.1070R).
- A (SZ sar par): R door 206 tr +0.142 vs R qareeb 554 tr +0.094 = farq +0.048, sirf 0.37 SE (shart 2 SE).
- B (DZ paon mein): ULTA - S qareeb 624 tr +0.099 vs S door 136 tr +0.146 = -0.34 SE.
- Market-war bhi ulat pulat (USTEC mein A aur B dono ulte, -1.1 SE). Zones ka 4H BUY par koi sabit asar NAHI = sirf naqsha.
