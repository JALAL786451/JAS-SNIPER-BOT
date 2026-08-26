# JAS Sniper EA v2 — Full Auto

MetaTrader 5 Expert Advisor: `jas_sniper_ea.mq5`

Structure (BOS) + trend (EMA/ADX) + HTF confluence, ek risk engine ke sath jo
broker ke asal contract specs se lot nikalta hai. **Exness standard aur cent
dono per chalta hai** — symbol aur specs khud parh leta hai.

---

## Sab se pehle: ye EA kya NAHI kar sakta

Ye jaan boojh kar code mein pukhta hai, setting mein nahi:

- **Hedge nahi kar sakta** — aik waqt mein sirf aik position
- **Average nahi kar sakta** — losing trade per add karne ka koi raasta code mein hai hi nahi
- **SL ke baghair order nahi bhej sakta** — har order SL ke sath hi jata hai
- **Risk limit se barhi lot nahi le sakta** — agar sab se choti lot bhi had se barh jaye to trade **chhor deta hai**

280 positions wala manzar is EA se bann hi nahi sakta.

---

## Install

1. MT5 → **File → Open Data Folder** → `MQL5/Experts/`
2. `jas_sniper_ea.mq5` wahan copy karein
3. MT5 → **View → Navigator** → Expert Advisors → right-click → **Refresh**
4. MetaEditor mein file khol kar **F7** (Compile) — 0 errors aane chahiye
5. XAUUSD ka **H1 chart** kholein → EA drag karein
6. Toolbar ka **Algo Trading** button green hona chahiye

---

## Exness setup

### Demo — Standard

| | |
|---|---|
| Symbol | `XAUUSD` |
| Timeframe | H1 |
| `DemoOnly` | `true` (aisa hi rehne dein) |
| `Mode` | `BOT_AUTO` |
| `RiskPercent` | `1.0` |

### Real — Standard Cent

| | |
|---|---|
| Symbol | `XAUUSDc` |
| Timeframe | H1 |
| `DemoOnly` | **`false`** ← sirf yehi badalna hai |
| `Mode` | `BOT_AUTO` |
| `RiskPercent` | `1.0` |

**Bas. Lot ka hisaab, tick value, minimum volume — sab EA khud broker se
parhta hai.** Cent account per 1% risk cent mein nikalta hai, standard per
dollar mein. Aap ko kuch convert nahi karna.

### Server time ka masla

`SessionStartHour` / `SessionEndHour` **server time** mein hain, aap ke local
time mein nahi. Market Watch mein upar server ka waqt likha hota hai — usse
milaan karein.

Default `7` se `20` London + NY dono cover karta hai agar server GMT+0 ho.
Agar aap ka server GMT+3 hai to `10` se `23` karein.

---

## Safety rails

| Setting | Default | Kya rokta hai |
|---|---|---|
| `RiskPercent` | 1.0 | Har trade per equity ka 1% |
| `MaxTradesPerDay` | 3 | Din mein 3 se zyada nahi |
| `MaxDailyLossPercent` | 6.0 | Din mein 6% gir gaye → aaj band |
| `MaxConsecutiveLosses` | 3 | Musalsal 3 losses → **hard stop** |
| `MaxTotalDDPercent` | 20.0 | Peak se 20% neeche → **hard stop** |
| `MaxMarginUsePercent` | 30.0 | Free margin ka 30% se zyada nahi |
| `MaxSpreadPoints` | 60 | Spread bara ho (news) → trade nahi |
| `CooldownBars` | 5 | Do signals ke darmiyan kam az kam 5 bars |

**Hard stop ka matlab:** EA rukh jata hai aur khud dobara chalu nahi hota.
Chart se hata kar dobara lagana parega — ye jaan boojh kar hai, taake aap ruk
kar sochein.

---

## Trade kaise manage hoti hai

```
Entry     →  poori lot, SL aur TP3 ke sath
TP1 (1R)  →  50% band, SL breakeven per
TP2 (2R)  →  bachi hui ka 50% band
TP2 ke baad → trailing stop (1.5 × ATR)
TP3 (3R)  →  baqi band
```

---

## v1 se kya theek hua

Ye asal bugs the, cosmetic nahi:

**1. HTF bias ulta chal raha tha.** v1 ka `HtfBias()` mixed haalat mein — H4 up,
D1 down — hamesha `+1` (bullish) lautata tha, aur short wali branch kabhi chalti
hi nahi thi. Yani bot ka rujhan chupke se bullish tha. Ab dono taraf barabar hai.

**2. Restart per position anaath ho jati thi.** EA band karke dobara lagane per
`g_ticket` khali ho jata tha — phir na partial close hota, na breakeven, na
trailing. Position SL/TP per hi mukammal hoti. Ab `AdoptPosition()` khuli
position dobara apna leta hai.

**3. Position ticket ghalat mil raha tha.** MT5 mein `ResultOrder()` **order**
ka ticket deta hai, position ka nahi. Ab deal se `DEAL_POSITION_ID` nikalta hai.

**4. BOS swing banne se pehle ke bars bhi ginta tha.** `StructLookback` window
swing ke bar se aage nikal jati thi, to purane closes ka naye swing se muqabla
hota tha. Ab window swing ke baad tak mehdood hai.

**5. `NormalizeDouble(lots, 2)` hardcoded tha.** Jis broker ka volume step
0.001 ho wahan lot ghalat round hoti. Ab step se decimals nikalte hain.

**6. Partial close ke baad stale data parha ja raha tha.** `PositionGetDouble`
close ke baad purani cached value deta hai. Ab re-select hota hai.

**7. Stops level ke sath freeze level nahi dekha ja raha tha.** Ab dono mein se
jo bara ho wahi minimum doori hai.

### Naya kya hai

- Musalsal losses aur kul drawdown ke hard stops
- Margin check order se pehle
- TP2 per doosra partial + ATR trailing
- `OnTradeTransaction` se asal band hone ka pata (partial closes se ginti kharab nahi hoti)
- Startup per account type, mode aur risk ka alert — taake ghalati se live per na chal pare

---

## Test karne ka tareeqa

1. **Strategy Tester** — XAUUSD H1, "Every tick based on real ticks", 6 mahine.
   Dekhein: profit factor, max drawdown, trade count.
2. **Demo per 2 hafte AUTO** — bina chhede. Journal tab mein errors dekhein.
3. Tab jaa kar `DemoOnly = false`.

Strategy Tester ke natije asal se behtar aate hain (spread aur slippage ka
poora asar nahi aata). Demo ka nateeja zyada sacha hota hai.

---

## Honest limitations

- **News filter nahi hai.** NFP, CPI, FOMC se pehle EA khud band karein.
  `MaxSpreadPoints` kuch bachata hai, sab nahi.
- Ye SMC Coach indicator ka **exact** copy nahi hai — MQL5 mein zones, FVG aur
  LGB ka poora system dobara likhna parega. EA structure + trend + HTF per chalta
  hai. Score ka hisaab bhi asaan hai (6 factors, 8 nahi).
- Backtest natije mustaqbil ki zamanat nahi.
- Aik hi chart per aik hi EA — do charts per lagaya to dono ka `MagicNumber`
  alag karein.
