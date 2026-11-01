# Judge: jas_5ea.pine (1 Nov 2026)

## p5 -> p6: verdict READY for TV
p4 TV par chala (SPX500USD, NAS100USD 1D). pinecheck saaf.

**Fixes / defaults (p6):**
1. L89 "Abhi R" aur L94 "agli chutti + khirki" ab default ON (user se wada). Alert, lot, purane nishan
   OFF; warning aur levels ON (pehle se).
2. L595 levels ka shuru `time[math.min(20, bar_index)]` -> `time - 20 x TF` (badalta history offset hata,
   chhoti / ajeeb history par mehfooz).
3. L512-513 chhupi alert plot sirf alert ON par (OFF = na; SPY / XAUJPY jaise chart ka paimana kabhi na chhue).
4. Build p6: L2, L40, L42 (+ L16, L87 likhai).

**Jaanch:**
- Engine p4 se `diff`: logic hubahu, sirf wapasi barhi (Supertrend `stv[1]` = pichhli BAND 4H, rukh `up[1]`,
  `dSma` = engine wali, aaj ka H/L + close). Tuple 8+8+14+14+21 = 65, request 11.
- Nayi values mein is candle ka high / low / close hai = history par aage ka data, MAGAR sirf
  `barstate.islast` par istemal (levels, Abhi R, warning) - nishan / alert purane engine se = repaint nahi.
- Compile: label.style_triangleup/down + yloc ternary (series string), alertcondition title / message
  literal (const), `{{plot("JAS entry")}}` sahi syntax (plot title wahi), str.format_time(ts, fmt, TZ),
  table.clear (0,0)-(8,11) phir merge, `[hT, eT] = f_nextKh()` local block mein, loop + break = theek.
  Table 9 x 12: sab ON par aakhri row 10. Lakeer <= 8, label <= 10 (hadd 30).
- Agli khirki (Python mein dobara chalaya): 2026-11-26 Thanksgiving -> BUY 2026-11-24 (TRADING ka
  "pehli khirki 24 Nov" se mila); Good Friday 2027-03-26, Juneteenth 2027-06-18 sahi.
- USTECH "error in series": p4 code mein chart-symbol par girne wali cheez NAHI mili (requests input symbol par,
  sab array index 0..10 par, x kabhi na nahi). Ab warning row (USTECH ya qeemat 0.5x-2x se bahar) +
  OANDA:NAS100USD ka mashwara. Phir aaye to TF + screenshot.

**Baqi khatra (kam):** L98 `lookahead = LA`, request ke andar `var array` (p2-p4 mein compile ho chuke).
Lot: index ka 1 lot = 1 unit maana (broker contract size alag ho sakti - table mein likha).

## p3 -> p4
Instrument pehchan: share / DR / crypto = nahi; DAX `startswith`; STOXX50 + STX50. Lakeer sirf jab entry
chart close ke 0.5x-2x mein. Python number 19 x 6 list se barabar.

## p1 -> p2
`f_core` S2/B1 tarjeeh judge #73 jaisi; Python port: B1, S1, B2 100% mile, S2 = judge-73 ka theek kiya hua.
SELL note "<2019". Repaint saaf ([1] + open, 4H se upar lookahead_off, nishan confirmed).
