# Verification tools

Pine Script only compiles inside TradingView — there is no offline compiler — so
these two scripts cover what can be checked outside it. Run both after any edit
to `xauusd_combined_indicator.pine`, then paste the result into the Pine editor.

## `pinecheck.py` — structural check

```
python3 tools/pinecheck.py xauusd_combined_indicator.pine
```

Catches the failure classes that cost a round-trip to TradingView: typos in
identifiers, `:=` on a name that was never declared, unbalanced brackets, tabs,
indentation that is not a multiple of four, and statements that accidentally
wrap onto a second line (Pine's continuation-indent rule is a trap).

It is not a compiler and does not type-check.

## `simulate.py` + `test_logic.py` — behavioural check

```
python3 tools/test_logic.py
```

`simulate.py` is a line-for-line Python port of the indicator's logic: same EMA
bias, same pivot/BOS/CHoCH state machine, same FVG lifecycle, same entry gating.
`test_logic.py` drives it with hand-built candle sequences whose correct output
is known, plus 8000 bars of random walk to assert the invariants.

If a logic change breaks an invariant here, it breaks it on the chart too. Keep
the port in step with the Pine whenever the Pine changes — a stale port that
passes proves nothing.

### One trap worth knowing

`ta.pivothigh` / `ta.pivotlow` need a **strict** extreme. Perfectly monotonic
test data produces no pivots at all, and candles that tie at a turning point are
not pivots either. Both cost time while writing these tests; `walk()` in
`test_logic.py` deliberately gives each turning bar a deeper wick because of it.
