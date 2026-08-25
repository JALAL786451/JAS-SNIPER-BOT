# SMC Coach Pro v2 — Change Requests (pending)

Artifact: https://claude.ai/code/artifact/5f57e7a1-7bd1-4a2d-a4b8-1bf2fa008612
Source of truth: `indicators/smc_coach_pro_v2.pine`

Status: **collecting requests — do NOT apply yet.**
Jalal wants every change applied in ONE batch, not piecemeal.

---

## Confirmed requests

### 1. Pine Script v5 → v6
- Current: `//@version=5` (line 1)
- TradingView now accepts v6.
- Note: v6 is a real migration, not a one-line swap — boolean/`na` handling,
  `request.*` rules and a few builtins changed. Needs one careful pass plus a
  re-test on chart. v5 is still fully supported, so this is quality-of-life,
  not urgent.

### 2. Trade-plan label (green/teal sticker) — text unreadable
- Location: `indicators/smc_coach_pro_v2.pine` line 767
- Current: `color=_colBg, textcolor=color.white`
  where `_colBg = color.new(_dir == 1 ? color.teal : color.purple, 15)` (line 766)
- Problem: white text on a light teal background = low contrast.
- Fix direction: `textcolor=color.black` for the LONG (teal) sticker;
  pick per-direction text colour so the SHORT (purple) one stays readable too.

### 3. Text too small everywhere
- Labels hardcoded to `size.tiny` at lines: 202, 203, 414, 416, 642, 643, **767**, 1070
- Panels use `PFS = f_size(panelFont)` (line 158); `panelFont` input defaults to `"Small"`
- Fix direction:
  - bump the hardcoded `size.tiny` → `size.normal` (or make it an input)
  - change `panelFont` default from `"Small"` to `"Normal"`
  - consider one shared "Text size" input driving both labels and panels

---

---

# MT5 Position Panel — Change Requests (pending)

Artifact: https://claude.ai/code/artifact/fd5e297c-37bf-4b13-b3ee-48cd0c6470ff
Source of truth: `mt5/mt5_position_panel.mq5`

### 4. "BREAKEVEN — buy aur sell barabar hain" shows with ZERO positions
- Location: `mt5/mt5_position_panel.mq5` line ~233 (`else` branch of `if(haveBE)`)
- `haveBE = (MathAbs(netLots) > 0.0000001)` is false in TWO different situations,
  and both fall into the same `else`:
  - no positions open at all (`found == 0`)  ← the confusing one
  - buy lots == sell lots, both > 0 (a real full hedge)  ← message is correct here
- Fix direction: split the branch.
  `found == 0` -> "koi position khuli nahi"; true hedge -> keep current wording.

### 5. Breakeven price ignores swap and commission
- `be = (buyNot - selNot) / netLots` (line ~199) is purely price-weighted.
- But `pl = POSITION_PROFIT + POSITION_SWAP` (line ~172) — so the P/L rows carry
  swap while the BE line does not, and commission is in neither.
- Result: the gold BE line drifts away from the true zero point the longer a
  basket is held. Jalal wants this panel accurate, so BE should be cost-aware.

### 6. Near-flat hedge throws the BE line off the chart
- As `netLots` approaches 0, `(buyNot - selNot) / netLots` runs to +/- infinity.
- e.g. buy 1.00 @ 4600 vs sell 0.99 @ 4590 -> net 0.01 -> BE ~ 5590, far off chart.
- Mathematically right, visually useless and alarming.
- Fix direction: below a minimum |netLots| threshold, hide the line and print a
  plain warning row instead of a wild number.

### 7. Panel needs to be readable/teachable when positions ARE open
- Jalal understands the buy/sell lots rows; the rest is unclear, and it gets
  confusing once several positions are running.
- Fix direction: clearer row labels, and show *what to do* (kitni lots add/minus
  karni hain to flatten or to reach a target), not just raw numbers.

---

### 8. Account size 1000 -> 495  [LAGA DIYA GAYA — 26 Aug]
- `indicators/smc_coach_pro_v2.pine` line 126
- Tha:  `acctSize = input.float(1000, "Account size", step=100, minval=1, group=gRisk)`
- Ab:   `acctSize = input.float(495,  "Account size ($)", step=5, minval=1, group=gRisk)`
- Wajah: asal balance 49,549.66 USC = $495.50 (cent account). 1000 per lot size
  tqreeban dugna aa raha tha.
- Label mein `($)` isliye lagaya ke MT5 ka USC number (49,549) yahan galti se
  na daal diya jaye — ye khana dollars maangta hai, cents nahi.
- Note: TradingView per jo indicator pehle se chart per laga hua hai, woh apni
  purani saved settings rakhta hai. Ya to settings mein khud 495 karein, ya
  indicator hata kar naya add karein.

## More to come
Jalal will add further items before anything is applied.

- [ ] …
- [ ] …
