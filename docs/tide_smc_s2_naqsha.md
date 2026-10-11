# JAS Tide + SMC s2 - naqsha (11 Oct 2026)

Halat: **BAN GAYA** (`indicators/jas_tide_smc.pine` build s2). Compile user karega (cloud mein Pine nahi chalta).

User (11 Oct): "Is script par agents aur judges lagaein. Script universal ho, har timeframe par trade lena
aasan ho. Pehle samjhein kis concept par bani hai, phir 1H par entry box theek karein, chart par clear samajh aaye."

Kaam ka tareeqa (workflow): 3 agent ne script parhi (concept / chart ki safai / universal), 3 designer ne
alag zaviye se naqsha banaya (A novice-first, B MT5-execution-first, C minimal + risk-first), 3 judge
(imaandari, novice, Pine engineering) ne har naqshe ko 5 cheezon par 1-10 diya. Kul: A 114, B 115, C 116;
judges ke winner C / A / B. Neeche ka spec C par bana, A/B ki achhi cheezein aur har judge ka must-fix shamil.

## Build mein spec se farq (Claude ke faisle)
- Dabbe ki chaurai 12 nahi **20 candle** (text ke liye jagah); text dabbe ke andar, wrap auto.
- LOT mein currency rate nahi: V usi symbol ka MT5 se liya jata hai (vSym guard), is liye zaroorat nahi.
- SL chhu jane ke din SHART dabba saath nahi (table "nayi trade sirf band daily candle ke toot se" kehta hai).
- Purane trade ke liye sirf chhota "Tide ±R" label (aakhri 5); bara ▲ label hata diya.
- Naap "2019 se" ka saal entry ke din se (tester ki daur row jaisa) - is liye BTC par 81 aana chahiye.

---

# JAS Tide + SMC s2: final build spec

**Base:** Design C (best total, 116) for the quiet chart. Added on top: B's "MT5 mein" row and alerts, A's "faisla" line, exit reason and today's candle from a daily request, and every judge must_fix. **Nothing here was compiled in the cloud**, and the user has to run the checks at the end.

## Concept (user ke liye)
1. Trade ka faisla sirf **Tide** karta hai. Ye Turtle tareeqa hai aur sirf **DAILY** candle par chalta hai.
2. Rukh D1 EMA50/200 se aata hai: upar ho to sirf BUY, neeche ho to sirf SELL.
3. Daily candle pichle 10 din ke high ke upar **band** ho to BUY, low ke neeche band ho to SELL. Entry wahi daily close hai.
4. SL entry se 2 ATR door hota hai, aur yahi 1R hai. SL roz sirf aage sarakta hai, 5 din ke low/high tak. **TP nahi hai.**
5. Bahar teen tareeqon se: SL chhu jaye, D1 rukh palat jaye, ya close SL ke paar ho jaye.
6. 1H, 15m ya 1D, kisi bhi chart par **wohi ek trade** hai, aur Tester ne cent tak saabit kiya. Chart ki TF sirf dekhne ka zariya hai.
7. SMC (zones, FVG, BOS) **sirf dikhawa** hai, naapa nahi gaya. Is se trade nahi leni.
8. Naap: BTC 2019 se 81 trades, Exp +0.58R (±0.47). Jeet ~45%, kamai chand bari trades se aati hai.

## Engine (f_tide): sirf naye values, koi if/else nahi badalni
New `var` values inside `f_tide`, returned at the end of the tuple (18 → 29 values):

| Name | Set when | Value |
|---|---|---|
| `_eT` | entry | `time_close[1]` (time of the signal day's close) |
| `_lD, _lE, _lRk` | trade closes | `_d, _e, _r` (before `_d := 0`) |
| `_lX, _lXt` | trade closes | `_px`, `time_close[1]` |
| `_lEt` | trade closes | `_eT` |
| `_xWhy` | trade closes | 1 = SL hit during the day, 2 = D1 rukh palta, 3 = close past the SL |
| `_n19, _s19, _q19` | trade closes and `time_close[1] >= statFrom` | n, ΣR, ΣR² |

- The starting SL is never stored. It is always `tE - tD*tR`, and for the last trade `lE - lD*lRk`.
- `ta.*` calls stay global.
- `strategies/jas_tide_smc_test.pine` is not touched in this change.
- New call, used **only on `barstate.islast`**: `[dO, dH, dL, dCt] = request.security(tk, "D", [open, high, low, time_close], lookahead_on)`.
- `slHit`:
  - On `islast`, take it from `dO/dH/dL`.
  - On historical bars with TF ≤ 1D, keep the s1.1 chart-candle logic.
  - On TF > 1D it is `na`.
- On `timeframe.isticks`, use chart OHLC instead of the `timeframe.period` request.

## Inputs (new or changed)

**Group "2 · Tide chart par"**
- `showBox` = true: "Tide box (shart / trade / nateeja)"
- `showSLplot` = true: "Sarakta SL ki lakeer"
- `showFaisla` = true: "Faisle ki lakeer (daily close)"
- `nMarks` = 5 (0–10): "Purane nateeje (±R)"

**Group "3 · SMC (sirf dikhawa, NAAPA NAHI)"**
- `smcOn` = true. Tooltip: "Trade ka faisla sirf Tide box. Ye 15m se kam aur 1D se upar khud band."
- `showMA` = false, titled "MA21/63 (chart TF), Tide ka rukh NAHI"
- `showLGB` = false
- `showBOS`, `showZone`, `showFVG` stay true

**Group "4 · Lot (MT5)"**
- `bal` = 0: "Balance (account currency)"
- `cur` = "USC"
- `riskPct` = 1.0, maxval 2.0
- `V` = 0: "0.01 lot par qeemat 1.00 hile = kitne". Tooltip: "XAUUSDc 1 · BTCUSDc 0.01 · XAUUSDm 1. MT5 se milayein."
- `vSym` = "": "V kis symbol ki (jaise XAUUSD, bina c/m)"

**Group "5 · Table"**
- `tablePos` default "Top Right"
- `tz` = "Asia/Karachi"
- `statFrom` = timestamp 2019-01-01

**Unchanged:** the declared limits `max_boxes 50 / lines 50 / labels 100`. Do not lower them.

## Objects (Tide)
- All Tide objects use `xloc.bar_time`. They are `var` objects, created lazily on `islast` (create if na, otherwise `set_*`), and hidden when TF > 1D.
- `bd = timeframe.in_seconds()*1000`. If that is na or 0, show no boxes.
- `firstT` = `var int firstT = time`, read in the chart context.
- Left edge: `L = max(eT, firstT)`. When it is clamped, the text adds "Entry 18 Sep (chart se pehle)".
- Right edge: `R = time + 12*bd`. On weekends the box stretches; that is display only and gets a code comment.

**PLAN box** (`tD == 0`, `tRk != 0`, ATR ok)
- Price: top `tUp`, bottom `tUp - atrMult*tAtr` (mirrored for SELL).
- Time: left `time + 2*bd`. Right on intraday charts = `min(max(dCt, time+12*bd), time+40*bd)`; on 1D = `time+12*bd`.
- Style: dotted grey border #78909C, **no fill**.
- The bottom edge is a dotted line labelled "SL ~".
- Text, tiny, top-left:
  > SHART · abhi trade NAHI
  > Yahan se UPAR DAILY close = BUY (05:00 PKT)
  > SL ~82,540 (kal ki ATR) · 1R ~4,630
  > BUY Stop / pending mat lagayein, sirf daily close
- If price is already past the level during the day, the first line becomes "Qeemat level ke paar, DAILY close ka intezar, abhi entry NAHI".
- If ATR is too low, the border is dashed and the text is "Bazaar susat, toot aaye to bhi NAHI".
- If there is no rukh, or fewer than 200 days of data, no box is drawn.

**RISK box** (`tD != 0`)
- Time: `L` → `R`. Price: `tE` ↔ `tE - tD*tR`.
- Fill red #EF5350 at 85% for both BUY and SELL.
- Text:
  > ▲ TIDE BUY · din N · entry 80,820.37 (18 Sep daily close)
  > SL abhi 84,100 → SL par band ~+0.71R (qaide se; gap ho to kam, swap/spread nahi gina)
  > TP NAHI: SL roz aage sarkao

**ABHI box**
- Time: last bar → `R`. Price: `tE` ↔ `stC`.
- Fill green or red at **93%** (lighter than the HAAL cell), so it reads as P/L, not direction.
- Text: "abhi +0.4R".

**Kal ka SL line**
- Dotted orange #E65100 at `csT`, from the last bar to `R`.
- Drawn only when `csT != tSL`.

**SL CHHU GAYA**
- The RISK border turns dashed, the text becomes "AAJ SL CHHU GAYA @ slPx · ~±R (qaide se) · MT5 mein band karein", and the ABHI box hides.
- If the toot condition still holds, the PLAN box is shown too, because the engine can reopen at today's close.

**RESULT box** (last closed trade, drawn on `islast` from engine values)
- Time: `max(lEt, firstT)` → `lXt`. Price: `lE` ↔ `lX`.
- Grey border, green or red fill at 92%.
- Text: "+0.44R · SL sarka" / "−1.00R · SL" / "rukh palta" / "close SL ke paar".

**History**
- `plot` of `tSL` with `style_linebr`, width 2, #E65100, only while `tD != 0`.
- Small "±R" labels with no fill, last `nMarks`.

**Faisla line**
- Intraday only and only when `dCt > timenow`: one dotted vertical line #78909C at `dCt`.

## SMC changes
- Delete `side`, `f_dirCol` and the islast recolour loop (L383-409).
- One colour, #90A4AE: border at 50%, fill at 95%. Text: DZ, SZ, FVG↑, FVG↓, BOS, CHOCH.
- Remove `extend.right`. On `islast`, `set_right(bar_index+4)`.
- What is shown:
  - 1 nearest unbroken DZ below price
  - 1 nearest SZ above price
  - 2 nearest FVGs
  - last 2 BOS/CHOCH, with the label at the line's right end
  - Everything else in the arrays is hidden (100% transparent).
- `smcAct = smcOn and timeframe.in_seconds() >= 900 and timeframe.in_seconds() <= 86400`.

## Table (Top Right, 2 columns, at most 8 rows, about 40 characters each)

**Row 0: `TIDE 1D · s2` | `<ticker> · faisla 1D`**
Tooltip: feed name, "TradingView din 17:00 NY, Exness D1 00:00 UTC: level JasTideRadarEA panel se milayein", "SELL ka SL ask par, spread jitna pehle", "SMC naapa nahi", "Din ki hadd: TradingView Session breaks on karein". When TF > 1D the right cell reads "Tide 1D ka system, 1D/4H/1H par dekhein", and only rows 0, 1 and 6 are shown.

**Row 1: HAAL** (only this cell is coloured, and only for an open trade)
- `INTEZAR · rukh UPAR (sirf BUY)`
- `▲ BUY chalu · N din`
- `AAJ SL CHHU GAYA`
- `rukh saaf nahi` / `200 din data chahiye`

**Row 2: MT5 MEIN** (the first line that applies)
1. flat: `Kuch nahi · 05:00 PKT ke baad dekhein`
2. `tAge==0`: `BUY kholein · SL 76,184 · TP khali`
3. `tAge>=1`: `Nayi entry NAHI · SL rakhein 84,100`
4. `csT!=tSL`: `Close ke baad SL → 85,300`
5. `tRk==-tD`: `D1 rukh palta · close par band`
6. `slHit`: `MT5 mein band hui? check karein`

**Row 3: KAB**
- `Daily band 05:00 PKT · 3g 20m`, built with `str.format_time(dCt,"HH:mm",tz)` and `dCt - timenow`.
- If `dCt <= timenow`: `bazaar band · agle session ki daily close`.

**Row 4: RISK**
- flat: `SL ~X · 1R ~Y`
- trade: `abhi +1.4R · SL par ~+0.7R`

**Row 5: LOT**
- `rate = syminfo.currency == "USD" ? 1 : request.currency_rate(syminfo.currency, "USD")`
- `lot = floor(bal*riskPct/100 / (dist*V*rate/0.01) / 0.01) * 0.01`
- `dist`: before the trade `atrMult*tAtr`; at entry `tR`.
- What the row prints:
  - `V==0` or `bal==0`: `Balance aur V bharein (Settings)`
  - guard fails: `V <vSym> ki hai · is symbol ki bharein`. Guard is `str.contains(str.upper(syminfo.ticker), str.upper(vSym))`.
  - `lot < 0.01`: `0.01 = X% risk (aap ne 1%) · trade NAHI`. **Never round up.**
  - otherwise: `~0.11 (1% = 530 USC)`, plus the grey line `0.01 lot ka 1R = 46.4 · MT5 se milayein`.
- Never use `syminfo.pointvalue` or the gold-only `/(dist*100)`.

**Row 6: NAAP** (grey, **never green**)
- `Sab: 164 · Exp +x ±2SE · PF y`
- `2019 se: n · Exp ±2SE`
- Then `SABIT` if n ≥ 30 and Exp − 2SE > 0, otherwise `SABIT NAHI`.
- Then `swap/spread nahi gina`.

**Row 7: DHYAN** (only when needed)
- (a) Feed day does not close at 00:00 UTC: `Feed ka din 17:00 NY · MT5 level thora alag`.
- (b) Only when `tAge==0` and the user is entering after the close (late entry): `Der se: faasla 1.2R · lot ~0.09 · NAAPA NAHI`. If price is past the SL: `qeemat SL ke paar · entry NAHI`.

## Alerts
- `alert()` with `freq_once_per_bar`, only when `not barstate.ishistory`.
- Fires on a change in `tD`, `tN` or `csT` against a `var` copy, so at most once per daily decision:
  - "Tide BUY/SELL khuli · SL X"
  - "SL sarkao → X"
  - "Tide band ±R"

## Removed from s1.1
- `stepline_diamond` toot plots and the entry `linebr` plot (the box edges replace them).
- The 20 big ▲ labels.
- The "Agla" sentence, the "D1 rukh" row and the "SMC" row.
- Teal colour on SMC, and `extend.right`.
- Bottom Right as the default table position.
- MA and LGB as defaults.
- Green colour on the NAAP row.

## Optional experiment: OFF, nothing built in s2
**Late entry (`lateH`).** Write the rule in ABHI-KAHAN-HAIN.md **before** running it, and make the change in a separate commit to the tester only.
- Test: BTC 4H, `lateH` 0 vs 8, same window.
- PASS if n ≥ 30, mean(R_late − R_rule) ≥ −0.10R, and mean + 2SE ≥ 0.
- Until it passes, every late-entry text says "NAAPA NAHI".

There is **no SMC entry rule**. The user's earlier SMC signals measured as no edge.

## Kaise parhein (1H par)
1. Table mein **MT5 MEIN** wali line parhein. Sirf wahi karna hai.
2. Dotted sleti dabba (SHART) ka matlab hai abhi trade nahi. Upar wali hadd ke paar **daily candle band ho** (KAB row ka waqt) tabhi trade banegi. 1H candle ke paar hone se trade nahi banti.
3. Laal dabba ka matlab hai Tide trade chal rahi hai. Laal hissa aap ka 1R risk hai. Halka hara/laal dabba batata hai abhi kitne R.
4. Narangi lakeer SL hai. Narangi nuqte nazar aayein to close ke baad MT5 mein SL wahan sarkayein. TP kabhi nahi lagana.
5. LOT row se lot lein aur pehle demo par MT5 se milayein.
6. Sleti SMC dabbe sirf naqsha hain. Un se trade nahi leni.

## Checks (user, TradingView par, pehle se likhe)
1. Compile karein: 0 errors.
2. CRYPTO:BTCUSD 1D par NAAP row s1.1 jaisi ho: 164 trades, wohi Exp, 2SE aur PF.
3. Table 1D, 4H, 1H aur 15m par ek jaisi ho.
4. 1H par RISK dabba 18 Sep 05:00 PKT se shuru ho, ya clamp ho kar "chart se pehle" likha ho.
5. 1W par jhoota "AAJ SL CHHU GAYA" na aaye.
6. XAUUSDc aur BTCUSDc par lot demo ke test order se mile.

Main file: `/home/user/JAS-SNIPER-BOT/indicators/jas_tide_smc.pine`