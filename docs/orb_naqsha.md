# JAS ORB — naqsha (11 Oct 2026, user ki manzoori se pehle)

User: "Kachhue jaisa koi doosra mashhoor idea dhoondein, 15m par roz trade
karne wala. Script aap dein, testing main karunga."

## Idea: Opening Range Breakout (ORB)

Toby Crabel ki kitaab (1990) se mashhoor hua, aaj bhi sab se zyada aazmaya
jane wala intraday idea. Soch: bara bazaar (New York) khulte waqt pehli
15 minute ki range din ka pehla faisla hoti hai; jo taraf toote, din aksar
usi taraf chalta hai. Claude ka design nahi, ek purana aam qaida.

## Qaide (sab number pehle se tay, tuning mana)

| # | Qaida |
|---|---|
| 1 | **Range** = New York ki pehli 15m candle: 9:30-9:45 NY waqt (PKT garmi 18:30-18:45, sardi 19:30-19:45; DST EA khud ginta hai) |
| 2 | **Entry** = 9:45 ke baad qeemat range ke HIGH ke upar = BUY, LOW ke neeche = SELL (jo pehle chhue). **Din mein sirf ek trade**, ek position |
| 3 | **SL** = range ka doosra kinara. Range ka size = 1R |
| 4 | **TP nahi.** Band: SL, ya 15:50 NY waqt (raat ko trade nahi) |
| 5 | **Lot** = 1% risk (broker ka OrderCalcProfit). Spread asli (Tester ka). Grid / martingale / averaging nahi |
| 6 | Koi filter nahi (rukh, ATR, din). Har filter = naya tuning ka darwaza |

## Kahan test: MT5 Tester (TradingView nahi)

TradingView 15m par sirf ~2-3 mahine deta hai (10 Oct: CRYPTO:BTCUSD 15m
sirf 1 Aug 2026 se) = ~50 trades = faisla nahi hota. Exness MT5 ke paas
M1 2017-18 se hai: 2019 se ~1,900 trades. Is liye **EA** (`JasOrbEA.mq5`),
jo Tester ke aakhir mein Journal mein khud likhe: trades, jeet, Exp R
+- 2SE, PF, kul R, girawat R, saal-wise, aur QAIDA PASS/FAIL.

## PEHLE SE LIKHA QAIDA (test se pehle, badalna mana)

- Tester: **XAUUSDm**, M15 chart, "1 minute OHLC", **2019.01.01 - 2026.10.09**,
  10,000 USD, defaults.
- **PASS = trades >= 500 AUR Exp - 2SE > 0 (spread ke baad) AUR 8 mein se
  kam az kam 5 saal musbat.** Warna FAIL = ORB nahi; settings ghuma kar
  dobara nahi.
- BTCUSDm wohi settings par = sirf maloomat (faisla gold ka).
- PASS ho to bhi agla qadam demo (Radar jaisa), live nahi.

## Imaandari

Ab tak har 15m idea (Pro Box, SMC Trend, Seerhi, Fishing, Chakkar) naap
mein fail hua; intraday mein spread roz katta hai. Is liye FAIL ka imkaan
zyada hai. Faida ye: ~1,900 trades se ek hi run mein saaf jawab (2SE
taqreeban +-0.05R) - Kachhue ki tarah saalon intezar nahi.
