# Judge: jas_5ea.pine (1 Nov 2026)

## p3 -> p4: verdict READY for TV
p2 TV par compile hua. p3 = chhoti table (Python number) + saaf chart. pinecheck saaf.

**Fixes (p4):**
1. L377-379 `f_auto`: share / DR / crypto = -1. Pehle GERN, CACC, CACI, HSIC, NYSE:GOLD, OSL:NAS ghalat
   DAX / CAC / HSI / XAU / USTEC ban jate the ("GER", "NAS" p3 mein aur khule hue the).
2. L388: `startswith("DAX")` (MDAX, TECDAX, SDAX ab DAX nahi). L394: "STOXX" -> "STOXX50" + "STX50"
   (STOXX600 nahi milta; ESTX50 / EUSTX50 wapas, p2 mein ESTX50 tha).
3. L494 `f_draw`: entry chart ke close ke 0.5x..2x mein na ho to lakeer nahi. SPY / QQQ / XAUJPY par OANDA
   qeemat (10-150x) ki lakeer chart ko daba deti thi.
4. Build p4: L2, L33, L35.

**Jaanch:**
- Engine p2 se `diff`: sirf `y0` / `_fy` / `f_pack` aur hisaab ki wapasi hati; state ki logic hubahu (S2/B1 fix
  samet). Tuple 4+4+8+8+14 = 38, request 11. Live E/L ka leg number sahi; "ruki" = us market mein B1/B2 khuli.
- Python number: 19/19 leg, 6 x 19 number list se bilkul barabar (leg tarteeb 0-18 bhi sahi).
- Pehchan: 11 default symbol + GER40, DE40, DE30EUR, UK100, FRA40, EU50, STOXX50, JP225, JPN225, AUS200, HK50,
  HK33HKD, US500, SPX500, US100, NAS100, USTEC, ES / NQ / GC / SI / FDAX / FESX / NKD futures = sahi.
  XAUUSD/XAGUSD, SPX/SX5E alag. Nahi milte (override se): F40, J225, US30 (hamara nahi).
- Naye construct: `chart.bg_color` / `fg_color` (input color) var table mein, plotshape `location.absolute`
  series float ke saath, `display.pane`, `for k in legs` (array<int>), table 8 x 7 (aakhri row 6) + 12 x 1 = sab theek.

**Baqi khatra (kam):** L74 `lookahead = LA` aur `var array` request ke andar (p2 mein compile ho chuke).
B3 number Python CFD ke, live haal cash index ka (likha hua). Gradient background par `chart.bg_color` = upar wala rang.

## p1 -> p2 (pehle)
`f_core` S2/B1 tarjeeh judge #73 jaisi; Python port: B1, S1, B2 100% mile, S2 = judge-73 ka theek kiya hua.
SELL note "<2019". Repaint saaf ([1] + open, 4H se upar lookahead_off, nishan confirmed).
