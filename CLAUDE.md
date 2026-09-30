# JAS-SNIPER-BOT

MetaTrader 5 Expert Advisors and a TradingView Pine strategy, for XAUUSD.

The user is new to trading and reads Roman Urdu more easily than English.
Explain every change in short, plain Roman Urdu / English mix. Always point
toward backtesting and demo before live trading.

## Files

| File | What it is |
|---|---|
| `jas_sniper_ea_v21.mq5` | JAS Sniper EA v2.11 — structure + trend, TP1/TP2/TP3 partials |
| `jas_sniper_v21.pine` | Pine v5 mirror of the above, for TradingView backtests |
| `TrendMomentumEA.mq5` | TrendMomentumEA v1.01 — EMA trend + tick-volume momentum |
| `sniper_backtest.pine` | Old 14/28 SMA crossover. Unrelated to the EAs |
| `JasBasketEA.mq5` | JAS Basket EA — user ki apni basket method, EA-QAWAID.md ke qawaid par. Dono taraf lots, net aur kul lots ki hadd, equity ka farsh, market band hone se pehle kitab barabar, Close All, aur Q8: faide wali lot sab se BURI lot ke saath jori bana kar band (taake kitab behtar ho, buri nahi). Phase 6 ka hisaab chart par likhta hai magar khud nahi karta jab tak ijazat na ho. Hedging account chahiye. **Abhi tak compile nahi hua** |
| `JasBasketEA_BTC.mq5` | Wahi basket EA, magar BTC ke liye. Paise wale teen number 100 se taqseem (BTC ki 0.01 lot gold se sau guna kam hilti hai) aur magic number alag. **Haath se mat badlein** - `tools/make_btc.py` ise gold wali file se khud banati hai |
| `JasDesk.mq5` | JAS Desk — phansi hui kitab ka control panel. **Trade nahi karta.** Buy/sell lots, ausat price, barabar ka price, har raaste ki keemat (sab band / ek taraf band / buri lot / jori), aur stop out kitni door hai. Button default BAND hain; chalu karne par bhi do click mangte hain. Kisi bhi lot ko ginta hai, EA ki ho ya haath ki |
| `EA-LAWS.md` | EA ke qanoon ki chalti hui list - jo bhi testing mein nikle, yahan likha jata hai. Saath mein kaam ka tareeqa (do tabs wala jaal) |
| `EA-CHECKLIST.md` | Nayi file lagane ke 23 qadam, tarteeb se. Jo qadam baar baar chhootte hain un par nishan |
| `indicators/smc_coach_pro_v2.pine` | SMC Coach Pro v2.1 — zones, BOS/CHOCH, risk engine, MTF dashboard |
| `indicators/jas_tide_signal.pine` | JAS Tide ke wohi qawaid, magar indicator ki shakal mein - haath se trade karne ke liye. BUY/SELL, entry, SL, TP aur lot ka hisaab batata hai |
| `strategies/jas_tide_v1.pine` | JAS Tide v1 — Donchian breakout + HTF EMA filter, Pine **strategy** so the Strategy Tester gives real numbers. Claude's own design, not the user's method |
| `strategies/tony_ema_scalper_test.pine` | A YouTube EMA-cross indicator the user brought in, converted faithfully to a Pine strategy so it can be measured. Not improved on purpose |
| `strategies/fishing_lots_test.pine` | Fishing Lots — user ki apni method (METHOD.md ke chhe phase) machine mein daal kar naapne ke liye. Live trade nahi karta; equity curve banata hai aur woh do number nikalta hai jo METHOD.md khud kehti hai kabhi naape nahi gaye: ek saath sab se zyada lots, aur kitab sab se gehri kahan gayi. Behtar banane ki koshish jaan boojh kar nahi ki gayi |
| `indicators/fishing_live.pine` | Fishing Live — Fishing Lots method chart par chalti hui, **koi setting badle baghair**. Har symbol aur TF ke liye qadam khud naapta hai (ATR/sqrt(minute)), jis se gold par theek wohi qawaid nikalte hain jo user ke hain ($1 / $3.50 / $4) aur BTC par khud ba khud bare ho jate hain. Sab hisaab USC mein (Exness StandardCent). Har khuli lot ki lakeer aur P/L, barabar ka price, agli lot kahan, aur upar ABHI kaun sa phase |
| `indicators/candle_xray.pine` | Candle X-Ray — ek bari candle (1D/1W) ko kholta hai aur uske andar ki chhoti candles (1m/5m/15m) chart ke saath khali jagah mein dikhata hai. Rang ka gehrapan volume, upar MA lines (unhi chhoti candles se, pichhle dino ke seed ke saath), saath mein price profile aur 1m-se-1W MTF patti. Waqt apni ghari par set hota hai. Sirf dekhne ka aala, koi signal nahi |
| `indicators/supertrend_v6.pine` | Supertrend — user ne jo file bheji thi us par v6 likha tha magar andar ka code v2/v3 ka tha, chalta hi nahi tha. Hisaab jyon ka tyon, zabaan v6, aur signal ab sirf band candle par (repaint band). Optional HTF filter. Trailing stop hai, peshangoi nahi |
| `indicators/ob_radar.pine` | OB Radar — wugamlo ke Order Block Finder ka qaida jyon ka tyon, magar 9 timeframe (1m se 1W) ek legend mein: har TF ka taza OB, Bull%/Bear% (OB ginti se), MA20/50, S/R, FVG, LGB, Supply/Demand zone aur NET vote. Har value us TF ki BAND candle se ([1] request.security ke andar). Chhoti TF ka data sirf ABHI ke liye bharosey ka hai, peeche ke chart ke liye nahi |
| `indicators/gainzalgo_ml_smc.pine` | GainzAlgo ka "ML Smart Money Concepts" — CHoCH par KNN se purani misaalein dhoond kar % aur TP1/TP2/TP3 banata hai. Hisaab jyon ka tyon, do tabdeeliyan: (1) khali array wala loop guard kiya — woh script ko band kar deta tha (wahi RE10045 jaal), (2) badge ab `80% (4/5)` likhta hai taake namoonon ki ginti saamne rahe. Chart sust ho to "Neon Wick Trace" aur "CHoCH Region Fill" band kar dein |
| `indicators/analogue_matcher_v2.pine` | Analogue Matcher v2 — user ke bheje hue GainzAlgo "Analogue Matcher" ka qaida, teen buniyadi durustiyon ke saath. (1) Jhukaav ab `bar_index` par naapa jata hai, `time` (milliseconds) par nahi — asal script mein slope ~5e-11 hota tha aur tolerance 0.004, yani `diff <= tol` hamesha sach, filter murda. Ab jhukaav % price/candle hai. (2) Ek match nahi, **K match** (default 10): un ka ausat raasta, ooper/neeche ki hadd, aur "kitne upar gaye" ki asli ginti. (3) Dual Mode hata diya — woh jaan boojh kar ek upar aur ek neeche jane wala match chunta tha, is liye hamesha dono taraf dikhata tha. "Conf (R²)" ka naam bhi badla: woh chance nahi, sirf shakal ki mushabahat thi. Peshangoi nahi, aur Tester is par nahi chalta |
| `indicators/trend_ribbon_levels.pine` | Trend Ribbon + Levels — 10-MA gradient ribbon and pivot S/R lines |
| `tools/` | Windows compile and backtest automation, plus `make_btc.py` |
| `EA-QAWAID.md` | Basket EA ke qawaid ka masauda, Roman Urdu mein, user ki manzoori ke liye. Har qaida [AAPKA] (uski apni kitab se gina) ya [BEHTAR] (user ne khud kaha ke EA uski ghaltiyan na karey — har aisa qaida kisi naape hue number par khara hai) |
| `METHOD.md` | The trader's own Fishing Lots method, captured from him. Read it before touching anything that trades |
| `SAWAL-LIST.md` | The question list he answers by number, in Roman Urdu |

## Hard rules for these EAs

Never add grid, martingale, hedging, or position averaging to any EA here
unless the user asks for it explicitly and by name in the current session.
Every EA holds at most one position at a time.

This rule is about the EAs in this repo. It is not a judgement on the user's
own Fishing Lots method, which is a laddered, hedged, stop-less basket by
design and is documented in `METHOD.md`. Keep the two apart: describe his
method faithfully, and still do not graft it onto these EAs unasked.

Never widen a risk limit (risk percent, daily loss cap, max trades, drawdown
cap) on your own initiative. Those defaults are deliberate.

## Compiling (Windows, MT5 installed)

```
tools\compile.bat                    :: har .mq5 compile karo
tools\compile.bat TrendMomentumEA.mq5
```

It finds `metaeditor64.exe` itself, writes `<name>.log` (UTF-16, as MetaEditor
does) plus a UTF-8 `<name>.log.txt`, and prints errors and warnings. Exit code
is non-zero when anything failed to compile. Read the `.log.txt`, fix, re-run,
and repeat until it reports zero errors — do not hand a compile error back to
the user to fix.

For `#include <Trade\Trade.mqh>` to resolve, either keep the source under
`MQL5\Experts\` in the terminal's data folder, or pass the include root:

```
powershell -File tools\compile.ps1 -Include "C:\Users\<you>\AppData\Roaming\MetaQuotes\Terminal\<hash>\MQL5"
```

## Backtesting (Windows, MT5 installed)

```
tools\backtest.bat TrendMomentumEA
powershell -File tools\backtest.ps1 -Expert TrendMomentumEA -Symbol XAUUSD -Period M5 -From 2025.01.01 -Deposit 10000
```

Close MT5 first — the tester runs its own terminal instance and shuts it down
when finished. The HTML report lands in `backtest/`; read it and report net
profit, trade count, win rate, profit factor and max drawdown rather than
asking the user to read it.

Override EA inputs for an experiment without editing the source:

```
powershell -File tools\backtest.ps1 -Expert TrendMomentumEA -Inputs "InpSL_Points=500||InpTP_Points=750"
```

Change one input at a time, so a change in the result can be attributed.

## Points vs digits

`InpSL_Points` and similar are in points, and a point depends on the symbol's
digits. On a 3-digit gold feed, 300 points is $0.30 — tight enough that the
broker rejects the order. Always check `SYMBOL_DIGITS` and
`SYMBOL_TRADE_STOPS_LEVEL` before trusting a points-based distance.

## What cannot be done in a cloud session

Claude Code running on claude.ai/code is a Linux container with no MetaTrader
and a restricted network: `mql5.com`, `tradingview.com` and the Debian package
mirrors are all blocked, so MQL5 cannot be compiled and Pine cannot be run
there. In that case say so plainly instead of implying the code was verified,
and review the source by hand.
