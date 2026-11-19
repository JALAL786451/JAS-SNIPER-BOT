# Research daur 11 (19 Nov 2026, 69vi): SIRF SELL strategy - research agent (user ne naam le kar maanga)
Research only, koi backtest nahi. Gold SELL 10 shaklein FAIL (#106s, K13, #108r, #109s, #110s) ke baad.

**Bottom line:** koi SELL-only idea achhe chance wala NAHI mila. Sirf ek long shot: C-M1, joint chance ~6%.

## C-M1 - Month-end "dash for cash" SELL, 8 index
- Saboot: Etula, Rinne, Suominen, Vaittinen (RFS 2020, draft 2014). Pension / salary / dividend mahine ke aakhir mein ->
  institutions settlement ki aakhri tareekh (T-4 jab T+3) tak share bechte hain. Index T-8..T-4 kamzor, T-3 se wapas upar.
  23 developed market mein reversal (20 significant), data 1980/later-2013. EU settlement T+3 -> T+2 (2014) par asar ek din khiska (t -3.7) = settlement se juda.
  ANcerno: institutions T-4 par net seller (~$30bn/saal). G1 HAAN (>= 20 market).
- Kamzori: girawat chhoti (non-US ~-0.03%/din, 5 din ~-0.15%; US 1995+ -0.04%/din, 1980+ -0.01%). TOM asar pichhle 10 saal se kam;
  hamara #64 TOM BUY TALAASH PASS / 2019+ FAIL.
- Kaun deta hai: pension / mutual fund jinhe cash chahiye; tareekh aur settlement pakke.
- Qaide (pre-register ke laiq): DE30, UK100, FR40, EU50, JP225, AUS200, HK50, US30 (t5 / i6 / e2 mein nahi). D1, har index ka local close.
  Settlement s: US 3 (Jun 1995) -> 2 (5 Sep 2017) -> 1 (28 May 2024); UK / FR / EU50 3 -> 2 (6 Oct 2014); JP 3 -> 2 (16 Jul 2019);
  AUS 3 -> 2 (7 Mar 2016); DE, HK 2. D = T-(s+1); SELL D-5 ke close, band D ke close (5 din). SL 3 x ATR20 (k2 jaisa), TP nahi.
  NYSE chhutti se pehle wala din window mein ho to chhor do (k2 BUY se takrao nahi). Risk 0.15% / market (8 ek hafte = ek hi daao, barhana NAHI).
- Data: data/yahoo/D1.zip, TALAASH ~1,900 trade (70-95 / saal), 2019+ ~600.
- Kharcha vs edge: gross ~0.15-0.20% / trade; kharcha 0.06% (1x) / 0.12% (2x) -> net ~+0.01-0.02R (R ~3.5-4%) = patla. Exp-2SE > 0 ko t >= 2; andaza t ~1.1-1.5 (2x), ~2 (1x).
- Mel: equity long EA ke ulat ~5 din / mahina = halka hedge; magar edge 0 ho to din ka nuqsan risk barhata (#69 sabaq).
- Chances: P(TALAASH) ~0.30, P(2019+ | TALAASH) ~0.20 -> joint ~0.06.

## Rad (ek line)
- C1d commodity curve-trend: F2 data nahi, duka oil 2013 se (G5), swap-free CFD par roll short ko nahi milta (G7).
- Post-TOM reversal short: sirf 12/23 market, TOM dabao kam ho gaya.
- Harvey-Mazzoleni-Melone 2025 rebalancing short: sirf US 1997-2023 (2019+ saaf nahi), bond data nahi.
- Intraday open-close index short: din mein do kharche > edge (#42); US intraday 2009 se musbat.
- Halloween / garmi / chaand short: kam magar musbat = drift se haar (#103).
- World Cup / khel haar short: 2-4 event / saal (G5).
- Oil -> stocks (Driesprong 2008): oil data 2013 se, chhapne ke baad kamzor.
- Commodity skew / hedging pressure: 20+ commodity + COT chahiye, hamare paas 4.
- Dividend season index short: broker ki shart ka asar, prop firm dividend arb mana.
- Gold seasonal short (Baur 2013): sirf Sep / Nov musbat, baqi flat.
- BTC short: drift mazboot, Kachhua pehle se dono taraf.

## Agent ki khud nazar
1. Duka oil H1 = bina adjust front-month futures, roll par +3..+8% jhatke (2015-16). Is file par oil test (BUY / SELL) bigarta hai.
   (Claude: Kachhua commodity #6 TradingView OANDA CFD par test hua tha, Duka par nahi; K13 (b) oil Duka par tha - FAIL hi tha.)
2. Price-index data short ka faida dividend jitna (~2-4% / saal non-US) zyada dikhata hai agar CFD short par dividend kaat-ta ho.
   Index SELL test se PEHLE FTMO + Exness ki index dividend policy ka SS. Short par kat-ta ho = C-M1 kharche par khatam.
3. US ab T+1; EU / UK T+1 Oct 2027. Month-end qaida settlement calendar se, fixed din se nahi.

## Sources
Etula et al. RFS 2020 https://academic.oup.com/rfs/article/33/1/75/5494694 ; Harvey-Mazzoleni-Melone NBER w33554 ;
QuantSeeker TOM fading https://www.quantseeker.com/p/turn-of-the-month-strategies-do-they ; EFMA 2024 JMP_GG_JAN2024.
