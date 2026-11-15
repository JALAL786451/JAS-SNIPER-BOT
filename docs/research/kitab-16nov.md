# Kitabon se strategy - 3 agent (16 Nov, 60vi, user ki maang). Sirf research, test NAHI.

Kitab ke number zyada tar "unverified" (agent yaad se). Pehle se test/fail wale nahi dohraye.

## Agent 1 - girawat par khareed (Connors, Chan, Bandy, Raschke, Crabel)
1. **Double 7** (Connors & Alvarez 2008): C > SMA200 + 7 din ki neechi tareen close = BUY close par; 7 din ki oonchi tareen close par band. Kitab mein SL nahi. Dawa SPY 1995-2008 ~80% jeet. Baad: StrategyQuant PF 2.35 (kharcha 0), QuantifiedStrategies "ab bhi chalta". ~0.9 tr/mahina/index. Khatra: sirf index drift (#61-63).
2. 3-Day High/Low (Connors 2009): IBS se bohat milta. 3. Turnaround Tuesday: chhota, kam trade. 4. %b: 1-2 ki naqal. 5. Chan z-score FX cross: SELL + SL nahi, #10-11 fail.
Pehla: Double 7 (index tokri, 3 ATR SL, drift jaanch).

## Agent 2 - trend / momentum (Clenow, Carver, Greyserman, Faith, Antonacci, Kaufman, Faber)
Kitabon mein t5 + Kachhua se saaf alag trend qaida NAHI (entry kam, market/raftar zyada aham).
1. **12 mahine momentum, mahana** (Antonacci / Faber): mahine ki aakhri close > 252 din pehle = BUY, shart toote to mahine ke aakhir band, SL 3 ATR. 2014+ ghisa (PriceActionLab). 1-2 tr/mahina, Kachhua se ~0.7 milta. Chhota faida.
2. Carver Starter (SMA16/64), 3. Keltner/Donchian 20-din, 5. Clenow core = Kachhua ki naqal. 4. Index rotation: #50 jaisa, fail ka imkaan.

## Agent 3 - calendar / volatility / lot (Hirsch, Aronson, Katz, Davey, Carver, Ilmanen)
1. **Wahi-mahina seasonality long/short** (Keloharju/Linnainmaa/Nyberg JF 2016): mahine ke pehle din 15 CFD ko usi mahine ke pichhle 10+ saal ke ausat se rank, top 3 BUY / bottom 3 SELL, ATR SL, mahine ke aakhir band. ~6 tr/mahina, milawat kam. Pass imkaan 15-20% (agent). SELL shamil.
2. Turnaround Tuesday = IBS. 3. Correlation-cluster budget (Carver): US500+USTEC ek daao, bacha risk doosron ko - kuch leg ka risk BARHTA = user ki saaf ijazat chahiye; faida 0-0.7 mahina. 4. Santa rally: 1-2/saal. 5. Katz seasonal crossover: data 1998 tak.
Aronson: 6402 qaide, data-mining sudhar ke baad koi pakka nahi = ehtiyat.

## Claude ka tajziya
Tarteeb: (1) Double 7 non-US + US index tokri, (2) N1 global reversal (wahi khandaan, alag qaida), (3) wahi-mahina seasonality, (4) 12-mahine momentum. Cluster budget abhi nahi (risk hadd).
