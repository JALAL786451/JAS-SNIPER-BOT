# JAS-SNIPER-BOT

MetaTrader 5 Expert Advisors and a TradingView Pine strategy, for XAUUSD.

**Har nayi chat sab se pehle `MERI-KAHANI.md` (user ki pakki kahani, accounts,
qaide) aur phir `ABHI-KAHAN-HAIN.md` (abhi kya chal raha hai) parhe.** User ko
apni kahani 0 se dohrani na pare. Koi bara faisla ya nateeja aaye to dono mein
se munasib file update kar ke commit + push karein.

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
| `JasDeskView.mq5` | JAS Desk VIEW — wohi hisaab jo `JasDesk.mq5` karta hai, magar **sirf parhne wala**. Is file mein koi `#include` nahi, koi button nahi, aur `OrderSend`/`PositionClose` ka naam tak sirf header comment mein hai — sirf `PositionGetTicket`/`PositionGetDouble`/`AccountInfoDouble` jaise parhne wale function. Broker ke Close-All dialog wali ginti (sab/faide wali/nuqsan wali/BUY/SELL) **aur woh jo dialog nahi batata**: dono taraf ke LOTS, **har lot SIZE ki alag ginti** (0.01 ki kitni, 0.05 ki kitni, 1.00 ki kitni — size x ginti = kul lot, aur us group ka paisa), ausat price, har lot par ausat, NET kis taraf jhuka hai, barabar ka price, ek taraf band karne ke baad kitni harkat chahiye, sab se buri N lots, aur stop out kitni door. **Chart par lakeerein**: ausat BUY, ausat SELL, barabar ka price, sab se buri lot, aur (switch se) har lot ki apni lakeer — price aur P/L tooltip mein. **Nikalne ka plan** (user ne khud chuna qaida: buri lot ko faide wali se dhaanp kar nikalo): PLAN A sirf sab se buri lot nikalta hai aur batata hai kitni faide wali lots uske saath band karni hongi; PLAN B batata hai ke maujooda kul faide se kitni buri lots dhaanki ja sakti hain. Dono greedy hain — behtareen jori nahi, qareeb tareen. Har plan ke neeche **"NET baad mein"** likha hota hai aur kitab jami na rahe (NET `InpNetWarn` 0.20 se upar) to laal KHATRA — kyunke PLAN A/B paise se jori banate hain, lot se nahi. **v4: BARI LOT KI JORI** — sab se bari lot (user ki 1.50 SELL) ke saath ulti taraf ki itni lots jo mil kar BARABAR lot hon, pehle woh jo behtar price par khuli (bari SELL ke NEECHE wali BUY, sasti pehle). Lot barabar hain to kitab jami rehti hai aur jori ka nateeja qeemat se nahi badalta; chart par bari lot narangi, jori wali hari lakeer. Currency account se uthata hai (USD ya USC) aur symbol chart se — `XAUUSDm`, `XAUUSDc`, BTC, sab par chalta hai. **Abhi tak compile nahi hua** |
| `JasJoriClose.mq5` | **SCRIPT** (EA nahi — MetaEditor ke `Scripts` folder mein). JasDeskView ki "BARI LOT KI JORI" ko asal mein band karta hai: wohi `PickBigPair`, phir har chuni hui lot ke saath **sirf `TRADE_ACTION_CLOSE_BY`** — koi nayi lot nahi, bazaar par koi close nahi, spread nahi, kitab har qadam par jami. Shuru hi nahi karta agar account hedge na ho, jori adhoori ho, ya andazan nateeja `InpMinResult` (0) se kam ho. **Ek** Yes/No (pehle se No), phir sab; ek bhi Close By fail ho to wahin ruk kar batata hai. Live account ke liye user ne 1 Oct ko khud manga. **Compile ho gaya; demo par 150/150 Close By kamyab** (EA-LAWS.md) |
| `JasChakkarEA.mq5` | JAS Chakkar EA (**k4**, "trend ko dost bana kar") — user ne 3 Oct ko khud naam le kar manga: jami ki shart hata kar EA khud lots khole/band kare. Qaide: (Q0) koi lot ya jori **nuqsan par band nahi**, sirf 0 ya faida; (Q1) H1 EMA50 rukh ke khilaf kabhi jhukao nahi; (Q2) rukh ke saath har step ek 0.01: pehle faide wali ulti 0.01 band, warna nayi 0.01; (Q3) NET hadd `InpMaxNet` 0.05; (Q4) lot kabhi 0.01 se bari nahi; (Q5) behtareen qeemat se 1 step ulti chaal, rukh badle, news se pehle ya Jumma par fauran hedge (NET 0), phir `InpHedgePauseSec`; (Q6) bari lot ki jori Close By se, sab se faide wali, nateeja >= 0; (Q7) har jhukao ke second panel/CSV mein; (Q8) attach ki equity ka 95% par naya jhukao band, 90% par hedge + ruk (`InpResume`). Jhukao ka nateeja = us dauran equity ka farq. (Q9, k4) user ka apna qaida **Close All**: symbol ki saari lots ka mila hua P/L `InpCloseAll` (+30) par sab band, phir khali kitab se rukh ke saath naya setup - k3 mein ye na hone se hedge har dafa nayi lots jorta tha aur kitab 270+ lots tak barhi. Step gold $5, BTC ATR(M15). k3a compile ho gaya (0 errors); **k4 compile nahi hua; qaide naape nahi gaye**
| `MERI-KAHANI.md` | User ki pakki kahani: kaun hai, kaise baat karni hai (Roman Urdu, "aap", SBS + "D"), dono accounts, method ka khulasa, naape hue sabaq, tools ka haal, routines. Har nayi chat pehle ye parhe |
| `ABHI-KAHAN-HAIN.md` | Abhi kya chal raha hai + agla kaam. Code `JAS-DESK-V3-0110` |
| `EA-LAWS.md` | EA ke qanoon ki chalti hui list - jo bhi testing mein nikle, yahan likha jata hai. Saath mein kaam ka tareeqa (do tabs wala jaal) |
| `EA-CHECKLIST.md` | Nayi file lagane ke 23 qadam, tarteeb se. Jo qadam baar baar chhootte hain un par nishan |
| `indicators/smc_coach_pro_v4.pine` | SMC Coach Pro **v4.0, Pine v6** (7 Oct) — v3 ka wohi kaam, saat kharabiyan durust (HTF/DXY non-repaint lookahead_on + [1], ek swing par dobara BOS/zone nahi, TP1 room sab ulte zones se, naye signal ka naqsha purani trade ke saath nahi mit-ta, purana wick guard, v6 lazy eval ke liye ta.* bahar), aur naya **PIP HISAAB**: 1m andar ki candles se 1D/1H candle ka raasta (upar/neeche/kul/asal farq/kaam %) aur price profile (har pip par minute ya volume, POC, VA). Table har chart par. **v4.1 TradingView par compile + 1m/15m/1h/1D par chal raha (8 Oct)**. Do jaanch (8 + 6 agent) ke baad v4.1: 90% signal sirf poori TF candles par (history = live), hafte ke pichle din daily candles se, MTF trade na-SL se atakti nahi, ek pivot = ek zone, purana naqsha apne SL/TP3 par mit-ta hai, DXY EMA apni candles par; pip profile apni candle ke andar, 8 din ki window |
| `indicators/jas_seerhi.pine` | **JAS Seerhi s1.2** (Pine v6, 8 Oct) — user ne "pro level trade samajhne wala script, SL/TP wala" manga aur faisle Claude par chhore. Top-down: (1) RUKH 1D band candle se - structure HH+HL / LH+LL + 1D trend line (do swing low/high) salamat + EMA21/63, teeno ka ittifaq; (2) JAGAH chart TF (1H; 30m/15m bhi) par MA21 tak pullback; (3) ENTRY pullback ke andar ke chhote swing (2/2) ka band candle se toot. SL pullback low - 0.2 ATR (0.5-3 ATR, zyada door = trade nahi), TP1 1R aadhi + BE, TP2 2R ya 1D ka agla swing (TP1 se qareeb = trade nahi), band: SL/TP2/rukh ulta/100 candle. Kharcha $0.30 R mein ghata kar Exp. Panel har seerhi ✓/✗ aur "Aakhri baat" (trade kyun bani/nahi bani), 1D trend lines + HH/HL label, pullback rang, entry/SL lakeerein, khuli trade ka dabba, purane nateeje R mein, aur "Kaise band huin" (SL / TP1→BE / TP2 / rukh ulta / waqt). **s1.1 TradingView par compile + 15m/30m/1H par chal raha (8 Oct)**; s1.2 sirf panel badla (signal wahi) |
| `strategies/jas_seerhi_test.pine` | JAS Seerhi ke wohi qawaid Pine **strategy** mein (rukh function jyon ka tyon - indicator badle to yahan bhi). Risk % equity, commission $0.15/oz har taraf, TP1 aadhi + BE, Exp R fi entry (netprofit ke farq se). **Compile ho gaya. Tester OANDA:XAUUSD 1h, Jan 2025 - Oct 2026: -5.73%, PF 0.862, DD 12.38%, 72 entries (Tester 144 dikhata hai - har entry do tukre). -0.09R +- 0.13R = koi edge sabit nahi.** Tuning mana; faisle ka qaida ABHI-KAHAN-HAIN mein |
| `docs/smc_v4_rehnuma.html` | SMC Coach Pro v4.1 ki Roman Urdu guide (artifact https://claude.ai/artifact/3KW2vaKYHTALRdzvXXS6LQ): har table column, chart drawing, POC/VA/Kaam %, ghar 15m chart, demo ke 9 qadam, saboot ki shart. Script badle to ye bhi update karein (wohi file publish karne se wohi URL) |
| `indicators/smc_coach_pro_v3.pine` | SMC Coach Pro v3 (pehle v2) — zones, BOS/CHOCH, risk engine. Tables sirf 1m/15m par: har TF ki chalti candle, mila hua BUY/SELL pressure. 1m par 9 TF / 90% signal, 15m par 15m-1H-4H-1D / 80% signal + 1H rukh; sirf khuli trade ka laal/hara dabba aur apni expectancy |
| `indicators/jas_pro_box.pine` | JAS Pro Box — Claude Code ka tohfa. Teen tareeqe saath saath (A: MA21/63 pullback, B: swing par engulfing/pin bar, C: SMC sweep → CHOCH → FVG), har ek ka TradingView jaisa laal/hara Entry/SL/TP dabba, lot ka hisaab (cent/standard: 0.01 lot = $1 par 1), aur teeno ki alag Trades / Jeet % / Expectancy table. Sirf observation; trade nahi karta |
| `indicators/jas_tide_signal.pine` | JAS Tide ke wohi qawaid, magar indicator ki shakal mein - haath se trade karne ke liye. BUY/SELL, entry, SL, TP aur lot ka hisaab batata hai |
| `strategies/jas_tide_v1.pine` | JAS Tide v1.1 — Donchian breakout + HTF EMA filter (Turtle soch), Pine **strategy** so the Strategy Tester gives real numbers. Claude's own design, not the user's method. **8 Oct jaanch: 2R par aadhi band kabhi nahi chali (p1Done bug) - 458 / PF 1.564 us system ka naap hai jo poori position SL/trail par band karta hai. Tafseel `docs/tide-jaanch-8oct.md`** |
| `indicators/jas_tide_seekh.pine` | **JAS Tide Seekh t1.1** (Pine v6, 8 Oct) — user ne Tide ke liye Seerhi jaisa seekhne wala panel manga (B) aur NAYI file (2); purani `jas_tide_signal.pine` waisi. Wohi 458 wale qaide (10/5/14/2.0, D1 EMA50/200, ATR >= 0.25%), har qaida ✓/✗, naali ke level aur ATR mein faasla, plan + cent lot, khuli trade + sarakta SL + abhi kitne R, "Der se entry?" (abhi ki qeemat se lot), "Aakhri baat", purane nateeje R mein (kharcha $0.30/oz + swap input, default 0), kaise band huin. Switch "2R par aadhi" (C): BAND default = jo 458 mein naapa gaya, CHALU = jo likha tha. Engine sirf band candle par, strategy jaisa (gap par open; ek candle mein SL + 2R dono hon to TradingView ka raasta - open high ke qareeb = pehle upar; D1 palta/sarakta SL close par, us candle par nayi nahi). **t1 TradingView par compile ho gaya (user "D", 8 Oct)**; t1.1 sirf 2R CHALU wala raasta |
| `strategies/jas_tide_seekh_test.pine` | Upar wale indicator ke wohi qaide Strategy Tester ke liye (v6). v1.1 ki kharabiyan durust: partial ki pehchan `strategy.closedtrades` se, P1 par bhi stop, SL entry candle par hi, defaults 10/5, commission $0.15/oz har taraf, capital 100k, size mincontract tak gol. Table (neeche baayen): entries, jeet, Exp R, PF, DD, kaise band huin, chhooti trades (size), pointvalue != 1 ki khabar. Swap nahi ginta. t1.2. Do agent jaanch: compile ki koi ghalti nahi. **Compile + Tester baqi** |
| `docs/tide-jaanch-8oct.md` | JAS Tide (strategy, signal, EA) ki 8 Oct jaanch: kharabiyan, MT5 farq, user ke faisle (B = seekhne wala panel, nayi file `indicators/jas_tide_seekh.pine`) aur baqi sawal |
| `strategies/jas_pro_box_test.pine` | JAS Pro Box ke wohi qawaid (A/B/C/ITTIFAQ, signal code indicator se jyon ka tyon) Pine **strategy** mein, taake Strategy Tester 1D par 2015 se ek dafa mein naap de. Ek waqt mein ek tareeqa (input se), 1% risk, TP1 aadhi + BE, TP2, $0.30/oz kharcha. Indicator ke signal hisse badlein to yahan bhi badlein |
| `strategies/tony_ema_scalper_test.pine` | A YouTube EMA-cross indicator the user brought in, converted faithfully to a Pine strategy so it can be measured. Not improved on purpose |
| `strategies/fishing_lots_test.pine` | Fishing Lots — user ki apni method (METHOD.md ke chhe phase) machine mein daal kar naapne ke liye. Live trade nahi karta; equity curve banata hai aur woh do number nikalta hai jo METHOD.md khud kehti hai kabhi naape nahi gaye: ek saath sab se zyada lots, aur kitab sab se gehri kahan gayi. Behtar banane ki koshish jaan boojh kar nahi ki gayi |
| `indicators/fishing_live.pine` | Fishing Live — Fishing Lots method chart par chalti hui, **koi setting badle baghair**. Har symbol aur TF ke liye qadam khud naapta hai (ATR/sqrt(minute)), jis se gold par theek wohi qawaid nikalte hain jo user ke hain ($1 / $3.50 / $4) aur BTC par khud ba khud bare ho jate hain. Sab hisaab USC mein (Exness StandardCent). Har khuli lot ki lakeer aur P/L, barabar ka price, agli lot kahan, aur upar ABHI kaun sa phase |
| `indicators/candle_xray.pine` | Candle X-Ray — ek bari candle (1D/1W) ko kholta hai aur uske andar ki chhoti candles (1m/5m/15m) chart ke saath khali jagah mein dikhata hai. Rang ka gehrapan volume, upar MA lines (unhi chhoti candles se, pichhle dino ke seed ke saath), saath mein price profile aur 1m-se-1W MTF patti. Waqt apni ghari par set hota hai. Sirf dekhne ka aala, koi signal nahi |
| `indicators/supertrend_v6.pine` | Supertrend — user ne jo file bheji thi us par v6 likha tha magar andar ka code v2/v3 ka tha, chalta hi nahi tha. Hisaab jyon ka tyon, zabaan v6, aur signal ab sirf band candle par (repaint band). Optional HTF filter. Trailing stop hai, peshangoi nahi |
| `indicators/ob_radar.pine` | OB Radar — wugamlo ke Order Block Finder ka qaida jyon ka tyon, magar 9 timeframe (1m se 1W) ek legend mein: har TF ka taza OB, Bull%/Bear% (OB ginti se), MA20/50, S/R, FVG, LGB, Supply/Demand zone aur NET vote. Har value us TF ki BAND candle se ([1] request.security ke andar). Chhoti TF ka data sirf ABHI ke liye bharosey ka hai, peeche ke chart ke liye nahi |
| `indicators/gainzalgo_ml_smc.pine` | GainzAlgo ka "ML Smart Money Concepts" — CHoCH par KNN se purani misaalein dhoond kar % aur TP1/TP2/TP3 banata hai. Hisaab jyon ka tyon, do tabdeeliyan: (1) khali array wala loop guard kiya — woh script ko band kar deta tha (wahi RE10045 jaal), (2) badge ab `80% (4/5)` likhta hai taake namoonon ki ginti saamne rahe. Chart sust ho to "Neon Wick Trace" aur "CHoCH Region Fill" band kar dein |
| `indicators/analogue_matcher_v2.pine` | Analogue Matcher v2 (a3) — user ke bheje hue GainzAlgo "Analogue Matcher" ka qaida, teen buniyadi durustiyon ke saath. (1) Match ab **poori shakal** se hota hai: aakhri N candles ka raasta z-score mein badal kar har purane raaste se qadam-ba-qadam naapa jata hai. Asal script sirf ek number (jhukaav) dekhta tha, aur woh bhi `time` (milliseconds) par — slope ~5e-11 aur tolerance 0.004, yani gate hamesha khula, filter murda; a1 mein 1000 candles ke 548 "match" ban jate the. (2) Ek match nahi, **K match** (default 10): un ka ausat raasta, ooper/neeche ki hadd, aur "kitne upar gaye" ki asli ginti. (3) Dual Mode hata diya — woh jaan boojh kar ek upar aur ek neeche jane wala match chunta tha, is liye hamesha dono taraf dikhata tha. "Conf (R²)" ka naam bhi badla: woh chance nahi thi. Table **buniyad se moqabala** karta hai: "Aam taur par" batata hai ke SAB misaalon mein kitne upar gaye, aur "FARK" us se aage/peeche. Gold Daily par a2 ne "10/10 = 100% upar" likha tha — hunar nahi, us arse mein gold har jagah se upar hi gaya tha; ab woh saamne aa jata hai. Table khud **KAMZOR** likh deta hai jab shakal ki safai (R²) kam ho, match door hon, ginti barabar ho, ya buniyad se fark 15% se kam ho. Peshangoi nahi, aur Tester is par nahi chalta |
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
