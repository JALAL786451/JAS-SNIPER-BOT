# Factors ki buniyaad (4 Nov 2026, 35vi chat) - "evergreen" research, kitab / paper se (agent nahi)

Factor = market mein ek DOHRAYI jane wali wajah jis se faida aata hai. Strategy = factor ko pakadne ka tareeqa.
Sirf wo factor jo (1) 50-100+ saal, (2) kai mulk / market, (3) chhapne ke BAAD bhi chale (out-of-sample).

| # | Factor (asal wajah) | Sab se purana / bara saboot | CFD + FTMO par chalta? | Hamara test | Nateeja |
|---|---|---|---|---|---|
| 1 | **Trend / time-series momentum** (log der se react karte, herding) | Hurst-Ooi-Pedersen 2017 "A Century of Evidence" 1880+, 67 market; Moskowitz-Ooi-Pedersen 2012 | HAAN (index, metal, tel) | t5 JasTrend 4H (#26/#49/#53), Kachhua #6, Radar | **CHAL RAHA (t5)**; commodity jor #96 FAIL |
| 2 | **Short-term reversal / liquidity provision** (ghabraahat mein bechne walon ko khareedar ka inaam) | Lehmann 1990, Nagel 2012 (RFS), Connors IBS/RSI2 index | HAAN, sirf US index (stock index ka mizaaj) | i6 IBS (#15, #52), RSI2, Double 7 (#45) | **CHAL RAHA (i6)**; 4 market IBS #28 FAIL |
| 3 | **Calendar / flows** (tankhwah, fund ka paisa, chutti ka mood) | Ariel 1987/1990 (TOM, pre-holiday), Lakonishok-Smidt 1988 (90 saal), McConnell-Xu 2008 | HAAN | k2 khirki (#67/#68), TOM #5/#64, chutti #59/#60 | **CHAL RAHA (k2)**; TOM #64 IMTIHAN FAIL |
| 4 | Carry (dheere wala zyada sood / roll) | Koijen-Moskowitz-Pedersen-Vrugt 2018 | NAHI: forex BAND (user), commodity curve CFD par nahi, swap kha jata | #50 jaisa | - |
| 5 | Value (sasta vs mehenga) | Asness-Moskowitz-Pedersen 2013 | NAHI: saalon ka kaam, FTMO 30 din / 12 mahine | - | - |
| 6 | Volatility risk premium (option bechna) | Carr-Wu 2009 | NAHI: option chahiye, CFD par nahi | VIX #65 | FAIL |
| 7 | Cross-sectional momentum (behtareen market BUY, bura SELL) | Jegadeesh-Titman 1993 (share) | Kamzor (index par chhota) | #50 | FAIL |
| 8 | Overnight / raat ka faida | Cliff-Cooper-Gulen 2008 | Kharcha zyada (har din 2 trade) | #92 (gold) | FAIL |
| 9 | Crisis / bear-state SELL (bure daur mein index girte saath) | Moskowitz 2012 (trend crisis alpha) | Shayad | #85/#86 (qaida likha) | TEST BAQI |

**Natija (imaandar):** CFD + FTMO par jo 3 "evergreen" factor chal sakte hain (trend, reversal, calendar),
hamare 3 chalte EA (t5, i6, k2) unhi teen par hain - yani mansooba #68 factor ke hisaab se sahi bana hai.
Baqi factor ya to is account par nahi chalte (carry, value, VRP) ya test mein FAIL hue.

**Trades kyun nahi barhti:** Grinold ka qaida - faida ~ (har trade ki taqat) x sqrt(KITNI ALAG trades).
Same factor ke naye market (US500 ke saath USTEC, DAX...) zyada tar ek saath chalte -> "alag" trade nahi banti.
Isi liye #96 (commodity) aur #28 (IBS 4 market) se median nahi ghata. Sirf asal mein alag factor (#9 crisis SELL) median ghata sakta hai.
