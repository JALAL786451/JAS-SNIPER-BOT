# JAS-SNIPER-BOT

Sniper trading bot: HTF filtering + structure/trend logic.

## Files

| File | What it is |
|---|---|
| `jas_sniper_ea_v21.mq5` | JAS SNIPER EA v2.1 — MT5 Expert Advisor for XAUUSD (structure + trend, safety patch) |
| `sniper_backtest.pine` | TradingView Pine v5 strategy used for quick backtests |

## JAS SNIPER EA v2.1

MetaTrader 5 EA. One position at a time — it can not hedge or average.
Three modes: `ALERT` (sirf alert), `SEMI` (chart button se manzoori), `AUTO`.

**`DemoOnly` defaults to `true`.** On a live account the EA refuses to start
until you set it to `false` yourself.

### Install

1. Copy `jas_sniper_ea_v21.mq5` into `MQL5/Experts/` in your terminal's data folder
   (MT5 → File → Open Data Folder).
2. MetaEditor mein file kholein aur **Compile** (F7) dabayen.
3. Attach it to an XAUUSD chart and enable Algo Trading.

### v2.1 patches over v2.00

- Hard stop / daily-loss limit ab khuli position band bhi karti hai
  (`FlattenOnHardStop`, `FlattenOnDailyLoss`).
- Day/DD/loss counters GlobalVariables mein save hote hain — terminal restart
  se reset nahi hote.
- Day rollover `YYYYMMDD` se, sirf `dt.day` se nahi (month change safe).
- True breakeven = open ± (spread + `BeBufferPoints`), na ke plain open.
- Restart ke baad TP1/TP2/trail state GlobalVariables se wapas aati hai
  (`AdoptPosition`).
- `HtfBothMustAgree` — H4 aur D1 mixed ho to trade block.
- Commission (`CommissionPerLot`) lot sizing mein, plus fill ke baad
  `MaxRiskSlippageMult` check.
- Friday cutoff (`FridayCutoffHour`) aur weekend per nayi entry nahi.
- SEMI mode: button click per signal, lots, SL aur spread dubara verify hote hain.
- Attach wale pehle bar per signal nahi (`g_skipFirstBar`).
- Spread price mein compare hoti hai (`MaxSpreadPrice`), points mein nahi —
  gold ke 2/3-digit quotes ke liye safe.

### v2.11 — chhote account ka TP1 fix

Pehle agar lot itni choti thi ke TP1 per hissa band nahi ho sakta tha (part
`VOLUME_MIN` se kam, ya bacha hua hissa `VOLUME_MIN` se kam), tab bhi EA TP1
ko "hit" gin leta tha aur SL breakeven per le jaata tha. Nateeja: min-lot
account per har trade +1R per BE ban kar khatam ho jaati thi, munafa kuch
bhi nahi.

Ab:

- Hissa band na ho sake to TP1 skip — `g_hit1` set nahi hota aur breakeven
  bhi nahi lagta. Position TP2/TP3 tak chalti hai.
- Aisi position `g_noScaleOut` se mark hoti hai (GlobalVariable `nopart` mein
  save, restart safe). Panel per TP1 ka status `RUN` dikhta hai.
- TP2 per bhi hissa mumkin na ho to `g_hit2` set ho jaata hai sirf is liye ke
  `TrailAfterTp2` chalu ho jaye — poori runner position bila protection na rahe.
- `PositionClosePartial` fail ho (server error) to ab `g_hit1` set nahi hota;
  agle tick per dobara koshish hoti hai, 2 second ki throttle ke saath.

### Key inputs

| Input | Default | Note |
|---|---|---|
| `Mode` | `BOT_SEMI` | ALERT / SEMI / AUTO |
| `DemoOnly` | `true` | live ke liye `false` karein |
| `RiskPercent` | `1.0` | per trade, balance ka % |
| `MaxDailyLossPercent` | `6.0` | had lagne per din band |
| `MaxTradesPerDay` | `3` | |
| `MaxConsecutiveLosses` | `3` | had per hard stop |
| `MaxTotalDDPercent` | `20.0` | peak equity se |
| `CommissionPerLot` | `0.0` | Raw/Zero accounts per round-trip bharein |
| `MaxSpreadPrice` | `0.60` | gold: $0.60 (0 = `MaxSpreadPoints` use hoga) |
| `ClearHardStop` | `false` | purana saved BAND hata kar dobara start |

Agar EA "BAND" dikhaye to wajah panel per likhi hoti hai; dobara chalane ke
liye `ClearHardStop = true` karke restart karein, phir wapas `false`.

> Trading involves risk. Demo per achhi tarah test kiye baghair live per na chalayen.
