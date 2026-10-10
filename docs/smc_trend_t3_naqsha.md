# JAS SMC Trend t3 - naqsha (10 Oct 2026)

Halat: **manzoor (10 Oct, user ne link manga) - t3 BAN GAYA `indicators/smc_trend_pro.pine` mein, TradingView compile baqi.** Ye naqsha 6-agent workflow (2 jaanch + 3 alag naqshe + judge) se bana.
User ka sawal: "kya is line ki jagah MA50 aur S/R ki lines bhi (advance) bana sakte hain?"
Ishara, NAAP aur pehle se likha qaida t2 jaise rahenge - sirf dikhawa badlega.

## User ke liye khulasa

| Cheez | Kya |
|---|---|
| MA50 (EMA, SMA option) | EMA21 lakeer ki jagah. Rang wahi: hara/laal = ishara chalu, sleti = khatam. MA ki JAGAH ka matlab nahi, sirf RANG |
| Narangi S/R lakeer (ek) | Chhote structure (pivot 2) ki woh lakeer jahan BAND candle par rang badal sakta hai. Hara/laal: yahan band = khatam (pakka). Sleti: yahan band + jaan = naya ishara (agar bari TF khilaf na ho) |
| Sleti nuqte wali S/R (doosri taraf) | Is ke paar rang kabhi nahi badalta (BOS ya bari TF se ruka darwaza) |
| Teer, qila lakeer, candle rang, S/R price label | Band (settings mein) |
| Table | Har TF ka APNA rukh number (4H har chart par ek jaisa), "Narangi lakeer" row, "khatam N candle pehle", qila alag row, purana SL hata |

## Judge ka poora spec

### Base
Design 1 ("MA50 + Narangi Lakeer") is the base. Why:
- Its two lines are a real S/R pair: S is always below the last close and R always above (0 side violations in 60,000 random candles).
- Both lines come from the SMALL structure (pivot 2/2), the same structure that creates the advance ishara. So "S/R (advance)" means what the user asked for.
- Orange is a colour of its own. It does not reuse the teal/pink that already mean "BUY/SELL chalu" on the MA.
- It has no on-chart labels, so the chart stays the cleanest of the three.
- It is the only design that also fixes the rukh number when the market is closed. Today is Saturday and the next screenshots are XAUUSD, so that fix matters now.

### Final spec

JAS SMC Trend t3: final spec. The base is Design 1; the grafts are listed separately. Everything below is either display or plumbing. These must stay logically identical to t2: f_struct, f_local, the logic lines of f_internal, sigUp/sigDn, lastDir/lastBar/lastPx/lastSL, ended/adv, the NAAP arrays and their loop, TP_ATR/SL_ATR/MAX_BARS/NEED_N, isDef, the Faisla thresholds, leadDir and "Rukh se pehle" (still on the combined `score`), and both alertconditions.

== A. WHAT THE CHART SHOWS BY DEFAULT ==
At most 3 objects plus the table:
1. The MA50, coloured by t2's adv rule unchanged: teal #00897B = ▲ chalu, pink #D81B60 = ▼ chalu, grey #90A4AE = khatam or none. Width 2. This is the only object with history.
2. ONE solid orange S/R line (#FB8C00, width 1), current level only.
3. ONE faint dotted grey S/R line (#90A4AE at transparency 30, width 1) on the other side of price, current level only.

Teer (arrows), the qila stepline, candle colours and S/R labels stay OFF. No old S/R levels, zones, boxes or fills.

Meaning, for the user and the guide:
- S is always below the last close and R always above.
- NARANGI = the line where a BAND candle can change the MA colour.
  - While the MA is hara/laal, it is the KHATAM level: a close beyond it ends the ishara for sure.
  - While the MA is sleti, it is the open DARWAZA: a close beyond it gives a new ishara only if the candle has jaan (body >= 0.5 ATR or FVG).
- SLETI NUQTE = a close beyond it NEVER changes the colour. It is either a BOS in the same direction, or a darwaza that the bari TF blocks.
- When the bari TF blocks the only darwaza, BOTH lines are dotted and the table explains why.
- The MA's position (price above or below it) means nothing in this indicator. Only its colour does.

== B. HEADER + BUILD ==
BUILD = "t3". Add a Roman Urdu header block that says:
- MA21 lakeer ki jagah MA50 (EMA default, SMA option), rang wahi ishara.
- Do S/R lakeerein chhote structure se, sirf abhi ki, aakhri BAND candle se pakki: narangi = yahan band candle par rang badal sakta hai (hara/laal: khatam; sleti: darwaza, jaan chahiye); sleti nuqte = is ke paar rang kabhi nahi badalta (BOS ya bari TF se ruka darwaza).
- ~1% edge: isi candle par nayi chhoti swing ban kar lakeer khud hat jati hai.
- Rukh table mein har TF ka APNA number (80 -> 100); "Rukh se pehle" ab bhi mila hua score.
- Peshangoi / bounce ka daawa nahi; ishara, naap aur pehle se likha qaida t1/t2 jaise.
Update line 8 ("SIRF: ek ADVANCE MA lakeer (MA21)") to match.

== C. INPUTS (group gShow, all display = display.none, none of them in isDef) ==
- showLine: title "Advance MA lakeer (rang = ishara)".
- NEW lineType = input.string("EMA", "MA ki qisam", options = ["EMA", "SMA"]).
- lineLen = input.int(50, "MA ki lambai", minval = 2). Tooltip: "Sirf dikhawa. Ishara, rukh (MA21/63) aur naap is se nahi badalte. MA ki JAGAH ka koi matlab nahi, sirf RANG."
- lineWidth: unchanged.
- NEW showSR = input.bool(true, "S/R lakeerein (narangi = yahan band candle par rang badal sakta hai)").
- NEW showDot = input.bool(true, "Doosri S/R (sleti nuqte) bhi").
- NEW showSRLab = input.bool(false, "S/R ke saath chhota price likho").
- Keep showMarks, showTable, tablePos, tableFont, showNaap, showQila (t2 stepline, default off) and colorBars as they are.
- Do NOT touch emaFastLen/emaSlowLen (21/63). They feed the score and are in isDef.

== D. ENGINE PLUMBING (no logic change) ==
D1. f_internal: add `var int ishB = na` and `var int islB = na`.
- In `if not na(ph)` add `ishB := bar_index - lr`.
- In `if not na(pl)` add `islB := bar_index - lr`.
- Return `[idir, flip, isl, ish, islB, ishB]`.
- The only call site becomes `[iDir, iFlip, iSL, iSH, iSLB, iSHB] = f_internal(intLR)`.

D2. After t2's `if sigDn` block, add a NEW separate block:
```
var int lastSLBar = na
if sigUp
    lastSLBar := na(iSL) ? bar_index : iSLB
if sigDn
    lastSLBar := na(iSH) ? bar_index : iSHB
```

D3. Between `var bool ended = false` and t2's `if barstate.isconfirmed` adv block, insert:
`bool endedPrev = ended`
After the adv block, add:
```
var int endBar = na
if barstate.isconfirmed and ended and not endedPrev
    endBar := bar_index
```

D4. S/R state, stored only at a close. Put it right after D3:
```
var float srS = na
var int srSB = na
var float srR = na
var int srRB = na
var int srAdv = 0
var int srIDir = 0
if barstate.isconfirmed
    float nS = iSL
    int nSB = iSLB
    float nR = iSH
    int nRB = iSHB
    if adv == 1 and (na(iSL) or lastSL > iSL)
        nS := lastSL
        nSB := lastSLBar
    if adv == -1 and (na(iSH) or lastSL < iSH)
        nR := lastSL
        nRB := lastSLBar
    srS := nS
    srSB := nSB
    srR := nR
    srRB := nRB
    srAdv := adv
    srIDir := iDir
```
Why this is exact:
- Hara ends at the first close below lastSL OR below isl (iDir flips). So the khatam level is max(lastSL, isl). Laal is the mirror: min(lastSL, ish).
- In sleti, the CHOCH (darwaza) level exists only on the side opposite iDir.
- iDir/iSL/iSH are provisional on the live candle, so draw only from these stored vars, never from them directly.

== E. RUKH DISPLAY FIX (A + B + C) ==
Cause: row 1 shows locS + the bari TF's ±20 vote; row 2 shows the bari TF's own 80 points × 100/80. Confirmed from the screenshots:
- 4H's own score is -80. The 4H chart shows -80 + 20 = -60; the 1H chart shows -80 × 1.25 = -100.
- 1D's own score is 60. The 1D chart shows 60 + 20 = 80; the 4H chart shows 60 × 1.25 = 75.

Code:
- f_htfScore():
```
f_htfScore() =>
    [s, d, q] = f_local(mainLR)
    [s[1], s, time_close]
```
- The single request becomes `[htfRaw, htfNowRaw, htfTC] = request.security(syminfo.tickerid, htf, f_htfScore(), barmerge.gaps_off, barmerge.lookahead_on)`. htfRaw is the same s[1] as before, so htfS, htfPart, score and the filter are unchanged.
- After `score = ...` add:
```
ownS = locS * 100.0 / 80.0
// SIRF DIKHAWA (table row 2 + S/R ka ruka/khula). KABHI ishare, naap ya score mein nahi:
// htfNowRaw lookahead_on ke saath BINA [1] hai - sirf aakhri candle par, jab bari candle sach mein mukammal ho.
htfDone = htfOK and barstate.islast and barstate.isconfirmed and not na(htfTC) and (time_close >= htfTC or timenow >= htfTC)
hsShow = htfDone ? nz(htfNowRaw) * 100.0 / 80.0 : htfS
```
- In the table: `sc = barstate.isconfirmed ? ownS : ownS[1]`, and `hs = hsShow`. This replaces t2's `htfS[1]` on the live bar, which was one bari candle stale on the first chart candle of each new bari candle.
- The alert() "Rukh" text uses `f_stTxt(ownS)`. barcolor uses `f_stCol(ownS)`.

Expected at the screenshot candles:
| Chart | Rukh row 1 | Rukh row 2 |
|---|---|---|
| 1H | 1H RANGE -25 | 4H TEZ NEECHE -100 |
| 4H | 4H TEZ NEECHE -100 | 1D TEZ UPAR 75 |
| 1D | 1D TEZ UPAR 75 | 1W TEZ UPAR 75 |
BTC runs 24/7, so htfDone never fires there. It matters for gold when the market is closed: the XAUUSD 15m chart's "Rukh 1H" row must then equal the 1H chart's "Rukh 1H" row.

== F. CHART CODE (CHART section) ==
- MA, computed globally because of v6 lazy evaluation:
```
maE = ta.ema(close, lineLen)
maS = ta.sma(close, lineLen)
advMA = lineType == "SMA" ? maS : maE
```
  Plot title "Advance MA", colour advCol unchanged.
- Globals:
```
sellRuka = htfOK and hsShow >= 30
buyRuka = htfOK and hsShow <= -30
srSOr = srAdv == 1 or (srAdv == 0 and srIDir >= 0 and not sellRuka)
srROr = srAdv == -1 or (srAdv == 0 and srIDir <= 0 and not buyRuka)
```
  On the live bar, hsShow = htfS is exactly the filter this close will use. When the market is closed, it is the completed bari candle, which is the next close's filter.
- Constants: `SR_EXT = 5`, `C_OR = color.new(#FB8C00, 0)`, `C_DOT = color.new(#90A4AE, 30)`.
- Drawing vars: `var line lnS = na`, `var line lnR = na`, `var label lbS = na`, `var label lbR = na`.
- `if barstate.islast`:
  - line.delete and label.delete all four, then set them to na.
  - If `showSR and not na(srS) and (srSOr or showDot)`:
    - `color cS = srSOr ? C_OR : C_DOT`
    - `lnS := line.new(x1 = math.max(nz(srSB, bar_index), bar_index - 499), y1 = srS, x2 = bar_index + SR_EXT, y2 = srS, xloc = xloc.bar_index, extend = extend.none, color = cS, style = srSOr ? line.style_solid : line.style_dotted, width = 1)`
    - If showSRLab: `lbS := label.new(x = bar_index + SR_EXT, y = srS, text = "S " + f_px(srS), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(#FFFFFF, 100), textcolor = cS, size = size.tiny)`
  - The same for R, with srR, srRB, srROr and "R ".
- The line starts at the swing candle that made the level (the S/R convention). No history is drawn.

== G. TABLE (11 rows) ==
`table.new(f_pos(tablePos), 2, 11, ...)`, `table.clear(tb, 0, 0, 1, 10)`. Keep f_row's signature; add tooltips with `table.cell_set_tooltip(tb, 1, r, txt)`.

- Row 0: "JAS TREND" | BUILD (+ " (settings badli)").
- Row 1: "Rukh <TF>" | f_stTxt(sc) + " " + round(sc).
  Tooltip: "Sirf is TF ka apna rukh: structure 35 + MA21/63 20 + Supertrend 15 + ADX 10 = 80, 100 par. Is liye ek TF ka number har chart par ek jaisa."
- Row 2: "Rukh <htf>" | the same formula on hs.
  Tooltip: "Bari TF ka apna number - yahi ishare ka filter dekhta hai (BUY ke liye > -30, SELL ke liye < 30)."
- Row 3: "Ishara".
  Text: `lastDir == 0 ? "abhi nahi" : (lastDir == 1 ? "▲ BUY" : "▼ SELL") + " · " + str.tostring(bar_index - lastBar) + " candle pehle · " + f_px(lastPx) + (adv == 0 ? " · khatam" + (na(endBar) ? "" : " " + str.tostring(bar_index - endBar) + " candle pehle") : " · chalu")`
  Background colours as in t2.
- Row 4: "Narangi lakeer" (column 0 text #E65100). Text nTxt:
  - srAdv == 1: "S " + f_px(srS) + " · neeche band = BUY khatam"
  - srAdv == -1: "R " + f_px(srR) + " · upar band = SELL khatam"
  - srSOr and srROr: "S " + f_px(srS) + " · R " + f_px(srR)
  - srSOr: na(srS) ? "abhi nahi · nayi chhoti swing ka intezar" : "S " + f_px(srS) + " · neeche band + jaan = ▼ SELL ho sakta"
  - srROr: na(srR) ? (same wait text) : "R " + f_px(srR) + " · upar band + jaan = ▲ BUY ho sakta"
  - otherwise (blocked): "abhi nahi · " + f_lab(htf) + " " + f_stTxt(hs) + (srIDir == 1 ? ", ▼ ruka" : ", ▲ ruka")
  Text colour: #E65100 when an orange line exists, #78909C otherwise. Background bgW.
  Tooltip: "Narangi: is ke paar BAND candle par MA ka rang badal sakta hai. Hara/laal ho to khatam (pakka). Sleti ho to naya ishara sirf jab candle mein jaan ho (body >= " + str.tostring(dispATR, "0.0#") + " ATR ya FVG) aur bari TF khilaf na ho. Sleti nuqte wali ke paar rang kabhi nahi badalta. ~1% dafa isi candle par nayi chhoti swing ban kar lakeer khud hat jati hai. Peshangoi nahi: ye nahi batati ke qeemat kis taraf jayegi."
- Row 5: "Qila (bara rukh)" | (md == 1 ? "▲ " : md == -1 ? "▼ " : "") + f_px(qv).
  Tooltip: "Bare structure (pivot 3) ka qila: is ke paar BAND candle = bara rukh palta (rukh ke 35 number)."
  The old "SL · Qila" row goes away, so the ended-signal SL is no longer shown.
- Rows 6-9: Naap / FARK / Faisla / Rukh se pehle. Texts are identical to t2.
  Row 9 tooltip: "Yahan rukh bana = mila hua score (apni TF 80 + bari TF 20) >= 30 / <= -30, t1/t2 wala hisaab."
- Row 10: the spacer when the table is at the bottom.

== H. CHECKS BEFORE HANDING OVER (the cloud cannot compile Pine; say so) ==
1. Run `python3 tools/pinecheck.py indicators/smc_trend_pro.pine`.
2. Extend tools/trend_check.py:
   - Leave run() and summary() untouched, so the existing KUL print stays identical to t2.
   - Add sr_run(), ported from /tmp/claude-0/-home-user-JAS-SNIPER-BOT/c13aad5f-b44a-50a2-9637-2dcb71bc296b/scratchpad/hybrid_check.py. It uses a synthetic bari TF: constant over 4-bar blocks, drawn from {-100, -62.5, -25, 0, 25, 62.5, 100}, Random(seed + 1000). The line APPLIED to bar t is the state after t-1 plus the HTF value of bar t.
   - Assert all of these over 12 × 5000 candles:
     (a) every colour change closes beyond the applied orange line, on the right side;
     (b) no dotted-line crossing changes the colour;
     (c) S <= close <= R after every close;
     (d) every silent orange crossing (no colour change and no flip) is on a candle that confirms a new small pivot.
   - Already measured: 2733/2733, 0 of 3299, 19 of 2800 silent (all on new-pivot candles), 0 side errors.
3. Update docs: the CLAUDE.md files-table row for smc_trend_pro (t3, compile baqi) and ABHI-KAHAN-HAIN.md (t3 plus the combine rule from screenshotsNeeded). Then commit and push.
4. User steps:
   - Open "JAS SMC Trend" in Pine Editor, select all, paste, Save.
   - REMOVE the old indicator from the chart and ADD it again, otherwise the saved EMA21 input can stay.

== I. EXPECTED LOOK ON THE BTC CHARTS (inferred, not verified) ==
- 1H: the SELL ended because the small structure flipped up, and 4H blocks BUY. Expect an orange S below price ("neeche band + jaan = ▼ SELL ho sakta") and a dotted R above.
- 4H and 1D: the BUY ended because the small structure flipped down. Expect an orange R above price ("upar band + jaan = ▲ BUY ho sakta") and a dotted S below.
- On 4H, if the small structure has since flipped back up without a BUY, both lines are dotted and the row says "abhi nahi · 1D TEZ UPAR, ▼ ruka".

== J. REPLY NOTES ("check bhi aap karein") ==
- No calculation bug. Every table number comes out of the code.
- The rukh mismatch was a display formula (fixed in E).
- The colour runs match the ishara rules (pixel scan).
- All three signals ended because the small structure turned against them, not because of the SL. That is why the 1D line is grey next to TEZ UPAR: a pullback started; the trend did not end.
- SL = Qila on 1H and 1D is a real coincidence (the same pullback candle).
- The 2SE values recompute correctly. The ~33.5% aam rate is the random-walk 1/3, which shows the naap has no lookahead.
- The t1 and t2 4H naap numbers are identical, so t2 did not change the signal.
- The 1H header price 85,606 belongs to the 7 Oct candle under the cursor; the live price was 82,689.

### Doosre naqshon se liya

From Design 2:
- When the bari TF blocks a darwaza, draw it as a dotted grey line instead of orange. This gives two strict rules: orange = "the colour can change here", and dotted = "the colour never changes here". I verified both against a synthetic bari-TF filter (2733/2733 and 0/3299); none of the three prototypes had tested blocking.
- Store the S/R state in `var` variables that are written only under barstate.isconfirmed, so nothing is drawn from the provisional live-bar iDir/iSL/iSH.
- Use table.cell_set_tooltip and leave f_row's signature alone; pinecheck flagged a typed default parameter.
- Tell the user to remove the indicator and add it again, so the new MA50 default takes effect.

From Design 3:
- Optional tiny price label on the S/R lines, default OFF.
- Tooltip texts for the own-TF rukh rows and the "Rukh se pehle" row.
- Reject the nested request.security for the bari TF's full score.

From Design 1, kept beyond the base:
- Fix B (market closed): the completed bari candle is shown only on the last candle. That is also the next close's filter, so row 2 and the blocking test stay exact on weekends.
- The EMA/SMA option for "MA50".

From check 1:
- "khatam N candle pehle" in the Ishara row.
- Remove the stale SL of an ended signal (the SL·Qila row becomes Narangi plus Qila).
- The explanation of why the line is grey while the table says TEZ UPAR.

From check 2:
- Write down how XAUUSD 15m and 1H combine BEFORE the first gold screenshot.
- Ask for no more BTC or other-symbol screenshots for the decision (multiple-testing risk).

### Chhora gaya

From Design 2:
- The qila line drawn by default, with labels on the chart. That makes 4+ objects, and the qila is already in the table plus t2's optional stepline.
- Colouring the S/R level teal/pink. A pink "SELL darwaza" line next to a grey MA reads as "SELL chalu".
- Its single level can sit on the same side of price as the qila, so the pair does not read as S/R.
- The ATR distance in the table (row width).
- The showHist step plots (not asked for; plot.style_steplinebr is uncertain).
- The merge tolerance, which is not needed without a qila line.

From Design 3:
- Big-structure (pivot 3) CHOCH/BOS lines as the S/R. That is not the structure the advance ishara is born on. Each side is missing about 20% of the time. The qila can sit far from price (4H: 87,173 vs 82,726) and squeeze the scale.
- Expanding f_struct's return tuple. It runs inside request.security; leave it untouched.
- The default parameter on f_row.
- Replacing showQila with showSRHist.

From Design 1:
- Keeping the key line orange even when the bari TF blocks it. A novice would watch price cross the orange line and see nothing happen.

From check 1:
- Its smaller alternative of renaming row 1 to "1H+4H" instead of fixing the formula.

From check 2:
- The H2 rukh-score trend-filter test. It is a new hypothesis the user did not ask for and it enlarges the test family; park it until the gold H1 result.
- A cost hurdle (FARK > c/3) inside the indicator. Costs are judged at the Tester step, which the pre-registered rule already requires before any demo.

General:
- A displaced or forward-shifted MA, which adds no information.
- Using MA50 or the S/R lines in the signal, score or isDef. That would be a new claim and would void the pre-registered naap.
- Any alert on S/R crossings.
- SMA as the default. The user's own tools use EMA50 (Chakkar Q1, Tide D1, METHOD EMA 20/50).

### Pine ke khatre

This cloud container cannot compile Pine. pinecheck and the Python port are not a compiler; TradingView must compile it.

1. v6 lazy evaluation: ta.ema and ta.sma for the MA must be global. Never put them in a ternary or an if. Do not add any ta.* call inside conditionals.
2. Tuple changes:
   - f_internal now returns 6 values and has one call site.
   - f_htfScore returns `[s[1], s, time_close]`, a mixed float/float/int tuple from a single request.security. If TradingView rejects the mixed tuple, drop Fix B only: return s[1] as in t2 and set hsShow = htfS. Everything else stands.
3. htfNowRaw is a lookahead_on value WITHOUT [1]. It is safe only because hsShow uses it on barstate.islast, on a confirmed bar, when the bari candle is complete. It needs the loud "kabhi signal mein nahi" comment so nobody reuses it. If htfTC is na or nominal, hsShow falls back to htfS. On weekends a 1W time_close may not have passed, so the 1W row can stay one week old.
4. Repaint safety:
   - The S/R vars are written only under barstate.isconfirmed.
   - iDir/iSL/iSH are never drawn directly, because they are provisional on the live bar.
   - adv/endBar change only at a close. ownS[1] is used on the live bar, as in t2.
   - Only the MA value moves intrabar, as any MA does.
5. Drawings:
   - Two lines and two labels, deleted and recreated on islast (line.delete on na is a no-op).
   - x1 = max(nz(srSB, bar_index), bar_index - 499) and x2 = bar_index + 5 are inside the drawing limits.
   - Use xloc.bar_index explicitly and named arguments.
6. Table:
   - 11 rows: table.new(..., 2, 11), clear(0, 0, 1, 10), spacer in row 10.
   - The ▲ ▼ characters are already in use.
   - table.cell_set_tooltip exists in v5/v6.
7. Placement order:
   - `bool endedPrev = ended` goes after `var bool ended` and before the adv block.
   - The lastSLBar block goes after iSLB/iSHB exist.
   - sellRuka/buyRuka/srSOr/srROr go after hsShow and the srAdv vars.
8. New global names: ownS, htfNowRaw, htfTC, htfDone, hsShow, iSLB, iSHB, lastSLBar, endedPrev, endBar, srS, srSB, srR, srRB, srAdv, srIDir, sellRuka, buyRuka, srSOr, srROr, maE, maS, lineType, showSR, showDot, showSRLab, SR_EXT, C_OR, C_DOT, lnS, lnR, lbS, lbR. pinecheck must report no duplicates; table locals are sc, qv, md, hs and nTxt.
9. Saved t2 inputs can keep EMA21. The user must remove the indicator and add it again.
10. Known edge: about 0.7% of orange crossings are silent. On those candles a new small swing is confirmed and replaces the line. Document it in the header and tooltip; removing it would change the engine.
11. The bari TF's structure inside request.security can start from a different first bar than on its own chart. A rare residual difference in the rukh number is possible.
12. Do not add lineType, lineLen, showSR, showDot or showSRLab to isDef. Do not touch emaFastLen/emaSlowLen.
