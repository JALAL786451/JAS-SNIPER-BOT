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

## More to come
Jalal will add further items before anything is applied.

- [ ] …
- [ ] …
