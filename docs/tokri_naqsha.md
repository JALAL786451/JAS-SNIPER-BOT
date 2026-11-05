# TOKRI EA - naqsha (user Jalal ke apne alfaaz se; sirf likha, TEST NAHI)
User ne 5 Nov 2026 naam le kar maanga: trend se lot, DHAAL (hedge), sahi jori close, mauqe par nayi lot, ulti SL.
Qaida: pehle qaide likho -> backtest -> demo -> live. Andaza NAHI - jo user ne nahi kaha wo "?".

## User ke qaide (5 Nov)
Q1. Upar se SELL ki lot neeche ja rahi ho (faide mein) to bachao lot bhi SELL ki hi.
Q2. DHAAL kab (BUY tokri nuqsan mein, gold gir raha):
    - equity ka nuqsan ~200 USC ho (5 Nov: equity ~37,800 USC par)
    - AUR trend aisa ke neeche ke chances barh rahe hon (ishara = ?)
    - AUR gold abhi abhi bohot neeche se wapas na aaya ho (aaya ho to dhaal NAHI)
    -> EK SELL lot (size = ?)
Q3. Dhaal SELL nuqsan mein aa jaye (qeemat us se upar) -> ek BUY se use "pakar" lo (jori/taala),
    taake neeche jaye to bhi sahara rahe; phir intezar ke nuqsan cover ho.
Q4. Ulta bhi wahi: trend upar ja kar SELL tokri ko nuqsan de -> sahara BUY lot.

Q5. MOOD = bara trend 1D + 4H (5 Nov). Mood UPAR ho aur qeemat OVERSOLD ke bawajood neeche ja rahi ho
    = "darana" (dara rahi hai) -> dhaal NAHI, khamosh intezar, equity par nazar. (dhaal sirf jab 1D + 4H dono neeche = HAAN, Q6). Mood kis cheez se (EMA / Supertrend / Naqsha Rukh) = ?

Q6. MILA-JULA (5 Nov 15:26 SS, gold 4H ~4124): 1D NEECHE (neeche ka chance 50+) MAGAR 4H par BUY chal rahi
    (Naqsha n5.9 CHALU BUY +0.5R) -> is soorat mein dhaal NAHI = intezar. **User HAAN (5 Nov).**
    => DHAAL SHART: 1D NEECHE + 4H bhi neeche mura (dono) + nuqsan ~200 USC + abhi neeche se wapas na aaya. (Ulta BUY ke liye.)
    Mood napna = JAS Naqsha "Rukh" line (Claude ka mashwara, user ko technical nahi poochna).

Q7. DHAAL SIZE (5 Nov, jawab "d"): size trend + equity ki BARDASHT se. Misaal: equity mazboot, gold pehle hi bohot gir
    chuka, phir bhi MAZEED 200 USC nuqsan -> EK 0.01 SELL (chhoti!) jo neeche ko rok le; palte aur SELL nuqsan mein jaye
    to itna ke ek BUY use cover kar le (Q3 pakar). Equity bardasht kare to aur 0.01 BUY bhi theek (fishing).
    => har 200 USC mazeed nuqsan par ek 0.01 dhaal? (user tasdeeq baqi). "Bardasht" ka number = ?

Q8. WAPASI HADD (5 Nov, user: "Claude khud calculate kare"; `tools/tokri_q8q9.py`, gold 4H 2005-2026, 1D+4H neeche wale 2878 mauqe):
    pichhle 2 din (12 x 4H) ki low se wapasi, din ke ATR14 mein -> SELL ka 4 din aage ausat faida:
    0-1 ATR: +0.20-0.25 ATR (jeet ~51-54%) | 1-1.5 ATR: +0.02 (faida khatam) | 1.5+ ATR: -0.59 (jeet 27%, bura).
    => QAIDA: wapasi >= 1 x din ka ATR = "neeche se wapas aaya" = dhaal NAHI. (aaj ATR ~$60; 2 Nov 13:48 wapasi ~$69 = NAHI, hadd par.)
Q9. 4H MUR KAR UPAR (dhaal SELL khuli ho): 82 mauqe - SELL rakhna (agle neeche mor tak) ausat -0.10 ATR, 24 bar -0.06 = rakhna nuqsan.
    => QAIDA: 4H Supertrend upar mude to dhaal SELL BAND (chhota 0.01 nuqsan le lo), nayi SELL nahi. Pakar (BUY se taala) paise mein
    barabar, magar khuli jori ka jhanjhat - is liye band. (Ulta BUY dhaal ke liye bhi yahi.)

Q10-Q13 (5 Nov, user "haan, Claude khud hisaab kare"; `tools/tokri_sim.py`, gold H1, cent 37,800 USC, 0.01 lot, kharcha $0.30):
    talaash 2010-18 (486 setting) -> chuna: nayi fishing 0.01 jab qeemat pichhli lot se 1 din-ATR door (aaj ~$60), har lot TP 0.5 ATR (~$30),
    fishing max 10, BARDASHT = khula nuqsan 5% equity (~1,890 USC) par nayi fishing band, AAKHRI HADD = khula nuqsan 10% (~3,780 USC) = sab band.
    JORI close alag qaida: koi farq nahi (Q9 dhaal ko pehle hi band kar deta) -> alag qaida NAHI.
    | daur | tokri | dhaal ke baghair | sirf 0.01 BUY rakhna |
    | 2010-18 talaash | +14.5%, gehra -3.7% | +4.1% | +0.5% |
    | 2019-26 imtihan | +10.0%, gehra -8.9%, 2 dafa aakhri hadd | +3.2% | +7.4% |
    | 18 Aug-1 Nov 2026 | -5.2% (asal live -36%) | -3.3% | - |
    Aakhri hadd na ho (S=0): 2019-26 +125% magar gehra -20.6% - sirf gold 3 guna hua is liye; KHATRA, nahi chuna.
    IMAANDARI: H1 sim (MT5 tester nahi); faida chhota; dhaal ne madad ki. Dhaal hadd 10: 2019-26 +14.0% gehra -8.7%.
    EA LIKHA: `JasTokriEA.mq5` tk1 (user ne fishing + dhaal ki saaf ijazat di 5 Nov). Agla = F7 + tester XAUUSDc H1 2019-2026 -> demo.

TESTER tk1 (5 Nov, user SS, XAUUSDc H1 real ticks 2019.01.01-2026.11.01, 378 USD = 37,800 USC, DhaalStep 2): **FAIL**
    net -88.22 (-23%), equity DD 26.9%, PF 0.68, 1108 trade (long 832 jeet 77%, short 276 jeet 45%), gross +183.83 / -272.05.
    Python sim (TP fix ke baad) usi daur: +13.9%, 1110 trade (ginti barabar!), gross +20,494 / -13,134 USC => nuqsan wala hissa ~2 guna alag.
    Wajah abhi NAHI maloom (swap? hadd? data?) -> user se tester report (XML/Excel) maangi. Jab tak farq samajh na aaye: demo/live NAHI.

TESTER REPORT tajziya (user xlsx, 5 Nov): SWAP -94.61 USD (= -9,461 USC) > kul nuqsan -88.22 => bina swap +6.39 (+1.7%, 7 saal).
    Live 253687618 history mein swap 0 (6246 tk) = asal account par swap nahi lagta; tester symbol ka swap kaat-ta hai.
    Aakhri hadd 4 dafa (Jan 2022, Nov 2022, Aug 2024, May 2026; har dafa ~-37 USD = -3,700 USC), Python mein 2 (Jun 2025, Jun 2026) = data/mood ka farq.
    Lots: FISH B 680, FISH S 54, DHAAL S 222, DHAAL B 152. NATEEJA: bina swap bhi ~0 = tokri EA ka koi asal faida NAHI (f1 + recovery #88-95 jaisa).
    Sabaq jo kaam ka: dhaal 0.01 rakho, upar ke mood mein bari SELL nahi (live -36% ki wajah) - ye haath ki trading ke liye.

Q14 (5 Nov raat, 43vi chat, user): "koi strategy nahi - basket bana kar profit nikalna". BASKET BAND = jab poori tokri ka NET
    (fees/commission ke BAAD) +0.5 ho -> sab band. (0.5 = MT5 screen ke 0.5 USC ya asli $0.5 = 50 USC? = ?)
    User (43vi): hisaab USD mein, test $1000 USD account. FEES $0.24 har 0.01 lot (BUY ho ya SELL).
    => BAND shart: tokri ka faida - (0.24 x kul 0.01 lot) >= +$0.5 (fees se barhe bina band NAHI, warna drawdown).
    User ka apna sabaq: "direction sahi add karne ka pata na hone se loss mein rehta tha" (CSV 4 bari haar din yahi dikhate: ulti taraf ki ladder).
    User: EA banana ZAROOR hai; test 1m / 5m par, gold data QDM se (repo mein M1: 2009-18 histdata, 2015 + 2021-24 qdm; 2019, 2020, 2025, 2026 BAQI).
    "4H trend test" ka matlab user bhool gaye; user (43vi): test SIRF 1m / 5m par, 4H ka koi zikr NAHI (Claude ka 4H filter mashwara HATA).
    Baqi sawal: nayi lot KAB (doori?), KIS TARAF (BUY/SELL kaise chune?), pehli lot kaise?

Q15 (43vi, user): tokri DONO taraf lot kholti hai, dekhti hai kaunsi faide mein bani -> wo BAND (fees + 0.5 ke baad);
    nuqsan wali KHULI rehti hai jab tak faide mein na aaye -> tokri chalti rehti. "Jitni volatility utna faida."
    Weekend / gold band (raat ~1 ghanta, Hafta-Itwaar) par wahi EA BTC ya ETH par. Test data: gold H1 2005-2026 (data/ftmo) + M1 14 saal jaanch.
    Baqi: har kitni doori ($) par nayi BUY + SELL jori? max khuli lot? bari hadd? BTC/ETH fees?

Q16 (43vi, user ka asli tareeqa): 0.01 lot kholo (misaal BUY). Wo $2 NUQSAN mein jaye -> ULTI taraf 0.02 (SELL) kholo,
    us ka faida (fees + 0.5) utha lo. Chaal usi taraf chalti rahe -> phir ek lot kholo, faida lo, phir doosri. Direction badle -> wahi kaam
    ulti taraf. Nuqsan wali (pehli BUY) khuli rahe; trend palte aur wo faide mein aaye -> FAURAN band.
    Baqi: pehli lot BUY ya SELL? chaal ke saath wali agli lot 0.01 ya 0.02? 0.02 bhi $2 nuqsan mein jaye to 0.04 (dugna) ya 0.02?

Q17 (43vi, user): lot sirf 0.01 ya 0.02 - lot size BARHTA NAHI (martingale NAHI). HEDGE hai (user ne naam liya): koi lot bohot
    door nuqsan mein chali jaye tab hedge, aur us ke beech wahi FISHING (0.01/0.02 faida uthao). Baqi: "bohot door" = kitne $? hedge lot kitni?

## Baqi sawal (ek ek)
- [~] Trend ishara: 1D + 4H mood (Q5); mood ki pehchan kis cheez se = ?
- [~] Dhaal size: 0.01 se (Q7); har 200 USC par ek aur? + bardasht number = ?
- [x] "Bohot neeche se wapas aaya" = 1 x din ka ATR, 2 din ki low se (Q8)
- [x] Bardasht 5% / aakhri hadd 10% (Q10-13)
- [x] Fishing: 1 ATR door, TP 0.5 ATR, max 10 (Q10-13)
- [x] Jori: alag qaida nahi (Q9)

## History (5 Nov) - `docs/research/live-history-tajziya.md`
BUY +135k USC, SELL -156k (0.01 SELL sirf -3k; bari SELL -152k). Dhaal asal mein 0.25-4 lot thi, qaida 0.01 kehta.

## Misaal (5 Nov 15:03 PKT, live 253687618)
11 tk: BUY 0.01 x9 (4124.926 .. 4134.448), BUY 0.10 @4146.317, SELL 0.10 @4134.023 (dhaal). NET +0.09, P/L ~-186, gold ~4124.7.
User: abhi nayi SELL NAHI - gold abhi neeche se wapas aaya, equity kaafi.
