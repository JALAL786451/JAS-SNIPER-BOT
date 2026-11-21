# EMA 50/200 4H + "roz 1 trade" jaanch - 21 Nov 2026 (72vi, Claude Sonnet 5.5)
**Fable ke liye: PEHLE NA KHOLO** (azad jaanch khatam hone ke BAAD hidayat 6 mein milane ke liye). Data/code yahin `code/` `data/`.
Sab Python, kharcha 2 bp (gold $0.50), qaida har test se pehle tay. TV ka data OANDA, mera Dukascopy/histdata/QDM - farq mumkin.

## 1. EMA trend (user ka sawal: gold 4H par EMA entry/exit, 10 saal)
- **Gold 4H, 10 saal (Nov 2016-Nov 2026), 39 EMA setup:** sirf BUY wale BUY+SELL se behtar (SELL kharab). Chuna: **EMA 50/200 cross, sirf BUY**, 4 ATR stop.
  Python +159%, DD -17.3% (bar-level), 44 trade, PF 3.6, jeet 34%, B&H +236% DD -30%. Stop 4-8 ATR barabar; 2-3 ATR kharab (tang).
- **TV mawazna (f1/f2, 3 Jan 2023-20 Nov 2026, OANDA 4H):** +106% / +110.6%, 14 / 13 trade, jeet 7; Python usi muddat +115.5%, 15 trade, 7 jeet. MIL GAYA.
  TV "Max drawdown 4.11%" = sirf band trade; asli bar-level -17.3% (Python).
- **Gold 23 saal (2003-26, H1 se 4H):** 50/200 BUY +374% vs B&H +1095%, DD -37%. 10 saal wala nateeja us muddat ki wajah se behtar tha (ghalat mat samjho).
- **15M, 17.6 saal (2009-26):** tez EMA (5/20, 10/30) kharche se barbaad (-98% / -76%); **400/1600 BUY +238%, DD -21.5%, 153 trade** (B&H +337%) = 4H 25/100 jaisa.
- **35 market (H1 se 4H), 50/200 BUY, 2 bp:** 25/35 plus, par portfolio CAGR 4.8% DD -11% Sharpe 0.6 vs barabar-hissa B&H 7.9% DD -25% Sharpe 0.69 -> girawat aadhi, munafa bhi kam. Mazboot IMTIHAN sirf BTC, USATECH, XAU, USA500; forex minus.
- **Basket 2009-26 (4 ATR, 2 bp):** XAU 6.0% DD -38%; **XAU+USATECH 9.1% DD -22.6% Sharpe 0.80** (corr 0.02, trades ~8/saal); +USA500 8.2%; +XAG 8.4%. Trades/saal: XAU 4.7, USATECH 3.9, USA500 4.0, XAG 5.4.
  Basket pre-2018 t_is>0.5 se chuna to 2018+ gold akele se kamzor (5.3% vs 11.5%).
- **t5 se mel (G6):** apna 50/200 vs t5-jaisa 4H Supertrend (ST 3,10; bina SL; NY-17 blocks nahi): daily-return corr XAU 0.59, USATECH 0.47, USA500 0.46, XAG 0.62; hamare BUY zone mein ~60% waqt t5 bhi BUY.

## 2. "Roz 1 trade" (user ka maqsad)
- Gold 72 setup 17.6 saal: koi pass nahi; 267 setup (SL/TP ATR, Asia breakout, prev-day H/L, dow): t>2 = 0, ausat -2 bp/trade.
- 35 market x 116 setup (1 bp): kharche se pehle ausat +0.14 bp, net -0.86 bp; Z>3 = 0 (`data/multi.csv`).
- ML (walk-forward 2010-26, logistic/gradboost, 152 feature, 35 market ka pichla din + Asia session): gold net -1 bp, t -0.84; placebo (shuffled labels) barabar. Har market par: gross +1.8 bp, net -0.17 bp; gross Z 6.8 = sirf drift (always-long 7.1).
- NFP + FOMC din (35 market, 224 test): t>2 = 6 (ittefaq se ~5); gold sab ~0. Sirf halka ishara: NFP ke baad US index ulta (fade) +8 se +16 bp/trade, saal mein 12 trade.
- **Nateeja:** ek din ke andar sirf qeemat se edge nahi; repo ke 14 intraday FAIL se mel khata hai. Edge sirf trend (kam trade) / calendar (kam din).

## 3. Chhote saboot / kamzoriyan (Fable dekhe)
- Itne tests (~72+267+116x35+224+ML) = multiple testing; sirf wahi baat bharose ki jo dono daur + kai market mein dikhe.
- Gold ke liye 4H 50/200 ka 10 saal nateeja 23 saal par kamzor (1 ke upar).
- FTMO fit kamzor: basket ~9% CAGR, DD -22%, 8-12 trade/saal; challenge P1 10% ke liye susat.
- Pine files: `strategies/jas_ema_4h_test.pine` (f4: faisla panel + 3 symbol trade ginti), `strategies/jas_ema_15m_test.pine` (e1).
