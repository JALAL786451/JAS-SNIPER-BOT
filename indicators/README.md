# SMC Coach — Pro v2

TradingView indicator (Pine v5): `smc_coach_pro_v2.pine`

SMC structure engine + risk engine + MTF dashboard. v1 sirf signal deta tha —
v2 poora trade plan deta hai (Entry / SL / TP1-2-3 / position size), signal ki
quality score karta hai, aur chart history par apni performance khud track karta hai.

---

## 1. Install

1. TradingView → **Pine Editor** → poori file paste karein
2. **Add to chart**
3. Preset (neeche section 6) apply karein

---

## 2. Chart par kya dikhta hai

| Cheez | Matlab |
|---|---|
| Green/Red box + line | Demand (DZ) / Supply (SZ) zone, BOS ya CHOCH se bana |
| Aqua / Fuchsia line | EMA20 / EMA50 |
| Green/Red step line | Supertrend |
| `Buy` / `Sell` triangle | Final signal (saare filters pass) |
| Blue line | Entry |
| Red dashed line | Stop Loss |
| Green lines | TP1 (solid), TP2/TP3 (dotted) |
| Right side label | Trade plan: Entry, SL, TP1/2/3, score, units |
| **TEACHER** panel | Signal kyun bana — ya kya missing hai |
| **LEGEND** panel | 1m → 1W dashboard: har TF ka trend, FVG, LGB, pressure |
| **TRACKER** panel | Ab tak ki hit-rate aur expectancy (R) |

### Teacher panel padhna
Jab signal nahi hai, panel batata hai **exactly kya missing hai**:

```
BUY missing:
• DZ touch / breakout
• HTF long gate
• Score 45 < 60
```

Matlab: setup ka structure to theek hai, par higher timeframe khilaf hai aur
confluence score minimum se kam hai. Ye "kyun nahi" wali list hi asal seekhne
wali cheez hai — force entry se bachati hai.

---

## 3. Signal kaise banta hai

Do raaste hain, dono ko same filters se guzarna parta hai:

**A. Zone entry** — price DZ/SZ ko touch kare + recent BOS/CHOCH + trend align
+ (mode ke hisab se) FVG ya liquidity sweep.

**B. Momentum entry** — swing high/low ka breakout impulse candle ke sath,
ya BOS ke baad EMA par retest.

Dono ko ye gates pass karni hoti hain:

```
HTF (4H/1D)  ·  Supertrend  ·  DXY (gold)  ·  Volume  ·  Session
Chop filter  ·  Confluence score ≥ minimum  ·  Cooldown  ·  TP1 ke liye room
```

**"Room" check** — agar long ka TP1 se pehle hi supply zone khara hai, signal
reject ho jata hai. Ye woh trades kaat deta hai jinme profit ki jagah hi nahi hoti.

---

## 4. Confluence Score (0-100)

Har signal ko 8 cheezon par points milte hain:

| Factor | Default weight |
|---|---|
| EMA trend align | 20 |
| BOS / CHOCH recent | 15 |
| FVG ya LGB | 15 |
| HTF alignment (dono TF = poore points, ek = aadhe) | 20 |
| Supertrend align | 10 |
| ADX strength | 10 |
| Fresh zone (pehli baar test) | 5 |
| Volume above average | 5 |

`Minimum score to fire` = 60 default.

- **Score 75+** → A-setup, full risk
- **60-74** → normal
- **< 60** → block

Agar signals bohot kam mil rahe hain: score 50 karein. Agar bohot zyada aur
kachre wale: 70 karein. Ye sab se seedha "quality knob" hai — baaki filters ko
haath lagane ki zaroorat nahi.

---

## 5. Risk Engine

**Stop modes:**
- `Structure + ATR buffer` (default, best) — swing low/high aur zone edge me se jo
  door ho, uske neeche ATR buffer
- `ATR only` — pure volatility stop
- `Zone edge` — zone ke bilkul neeche/upar

Stop hamesha `Min stop distance` aur `Max stop distance` (ATR multiples) ke beech
clamp hota hai — is se na spread ke andar stop lagta hai, na 5-ATR ka bekaar stop.

**Targets:** TP1 = 1R, TP2 = 2R, TP3 = 3R (adjustable).

**Position size:** `Account size` aur `Risk per trade %` daalein — label me
approx units aa jayengi. Formula: `units = (account × risk%) / (entry − SL)`.

> Aap ka broker/lot conversion alag ho sakta hai. Ye raw units hain — gold par
> 1 unit = 1 oz, forex par base currency units. Apna lot size khud verify karein.

---

## 6. Presets

### Scalp — 1H Gold / FX (default)
```
Entry Mode        : Confirm + (FVG or LGB)
Structure lookback: 3          Cooldown bars: 5
HTF agree         : Either     Min score: 60
Supertrend filter : ON         Chop filter: ON
Session filter    : ON (London + NY)
Stop mode         : Structure + ATR buffer
```

### Intraday — 15m / 30m
```
Pivot L/R         : 4          Structure lookback: 4
Cooldown bars     : 8          Min score: 65
ADX min           : 20         Chop min range: 3.0
Session filter    : ON (London + NY)
```

### Swing — 4H / 1D
```
Pivot L/R         : 5          Zone kill after N bars: 800
HTF agree         : Both       Min score: 70
Cooldown bars     : 3          Session filter: OFF
TP1/TP2/TP3       : 1.5 / 3 / 5
Max stop distance : 5.0
```

### Crypto (24/7)
```
Session filter    : OFF
DXY filter        : auto-OFF (sirf XAU/GOLD par lagta hai)
Volume filter     : ON, min 1.0
ADX min           : 20
```

---

## 7. Alerts

`Create Alert` → Condition: **SMC Coach — Pro v2** → `Any alert() function call`
→ frequency **Once per bar close**.

Message automatically bhar jata hai:
```
BUY XAUUSD 60 | Entry 2043.55 | SL 2038.10 | TP1 2049.00 | TP2 2054.45 | TP3 2059.90 | Score 78
```

Alag alag alerts bhi available hain: `SMC Coach BUY`, `SMC Coach SELL`,
`Supertrend UP`, `Supertrend DOWN`.

---

## 8. Tracker panel

Chart history par virtual trades chalte hain — har signal par entry, stop, aur
targets set hote hain, phir bar-by-bar check hota hai kya laga.

```
Tracked: 42   TP1 27 / TP2 18 / TP3 11
SL 11  |  BE 4  |  TP1 hit-rate 64.3%
Expectancy: 0.41 R / trade   Total 17.2R
```

**Expectancy hi asal number hai.** 40% win-rate 3R targets ke sath 70% win-rate
0.5R targets se behtar hai. Agar expectancy negative hai — settings tune karein,
size mat barhayein.

Rules jo tracker follow karta hai:
- Ek waqt me ek hi position (agli signal tab tak ignore jab tak pehli close na ho)
- `Move stop to BE after TP1` ON hai to TP1 ke baad stop entry par
- Same bar par SL aur TP dono touch → **SL** count hota hai (conservative)
- TP3 par trade close

> Ye backtest **nahi** hai — spread, slippage, commission, partial fills shamil
> nahi. Ye ek reality check hai, guarantee nahi.

---

## 9. v1 se kya badla

**Naya:**
- Risk engine: SL/TP/RR/position size
- Confluence score + minimum-score gate
- Session, volume, chop filters
- Cooldown + one-signal-per-zone
- Virtual performance tracker
- `alert()` with dynamic Entry/SL/TP payload
- TP1 "room" check (opposing zone blockage)

**Fixes:**
- **HTF non-repaint galat tha.** v1 me `_f[1]` chart bar shift karta tha, HTF bar
  nahi. Ab shift `request.security` ke andar hota hai — yehi sahi tareeqa hai.
  (Dashboard me bhi wahi bug tha, wo bhi fix.)
- **Array desync.** v1 me `zBoxes` aur `zLines` alag-alag trim ho rahe the —
  boxes aur lines mismatch ho sakte the. Ab ek hi kill function sab arrays ko
  sync me rakhta hai.
- **BOS har bar fire ho raha tha.** v1 me jab tak price swing high ke upar rehta,
  har bar naya BOS + naya zone banta tha. Ab ek break = ek BOS.
- **Buy aur Sell ek sath.** Ab mutually exclusive — higher score jeetta hai.
- **Zone lifecycle nahi tha.** Ab age, touch count, aur mitigation par zone marta hai.
- CHOCH par bhi zone banta hai (v1 me sirf BOS par).

---

## 10. Honest limitations

- Ye **indicator** hai, strategy nahi — TradingView Strategy Tester ke proper
  backtest results nahi milenge. Tracker approximation hai.
- Signals bar **close** par confirm hote hain (default). Entry next bar open par
  milegi — real fill thora alag hoga.
- Zone-based logic ranging market me achi, strong trending market me kam signals
  degi (momentum entries usi liye add ki hain).
- Koi indicator news spikes handle nahi karta. High-impact news se pehle band karein.
- Live jaane se pehle **kam se kam 3 mahine forward-test** karein demo par.
