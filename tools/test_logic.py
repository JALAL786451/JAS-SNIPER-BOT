#!/usr/bin/env python3
import math
import random
import sys

from simulate import Sim

FAILS = []


def check(name, cond, detail=''):
    if cond:
        print(f'  PASS  {name}')
    else:
        print(f'  FAIL  {name}  {detail}')
        FAILS.append(name)


def warmup(sim, n=60, price=100.0):
    for _ in range(n):
        sim.step(price, price + 0.5, price - 0.5, price)


# =============================================================================
print('\n[1] FVG detection and lifecycle (hand-built, exact expectations)')
# =============================================================================
sim = Sim()
warmup(sim)
sim.step(100, 101, 99, 100)      # bar A - its high (101) is the gap floor
sim.step(100, 110, 100, 109)     # bar B - bullish impulse
r = sim.step(109, 112, 105, 111)  # bar C - low 105 > 101 => bullish FVG

live = [f for f in sim.fvgs if not f['dead']]
check('one bullish FVG created', len(live) == 1 and live[0]['bull'], live)
check('gap bounds are [high[2], low] = [101, 105]',
      live and abs(live[0]['top'] - 105) < 1e-9 and abs(live[0]['bot'] - 101) < 1e-9, live)
check('NOT marked filled on its own creation bar (regression)',
      live and live[0]['state'] == 0, live)
check('no tap reported on the creation bar (regression)', not r['in_bull_fvg'])

r = sim.step(111, 113, 106, 112)  # stays above the gap
check('still untouched while price holds above', live[0]['state'] == 0 and not r['in_bull_fvg'])

r = sim.step(112, 112, 103, 104)  # dips into the gap but not through it
check('partial fill flagged on a genuine retest', live[0]['state'] == 1)
check('tap reported on the retest bar', r['in_bull_fvg'])

r = sim.step(104, 105, 100, 100)  # trades through the floor
check('fully filled once price closes the gap', live[0]['state'] == 2)
check('a filled gap no longer counts as a tap', not r['in_bull_fvg'])

# bearish mirror
sim2 = Sim()
warmup(sim2)
sim2.step(100, 101, 99, 100)
sim2.step(100, 100, 90, 91)       # bearish impulse
sim2.step(91, 95, 88, 89)         # high 95 < low[2] 99 => bearish FVG
live2 = [f for f in sim2.fvgs if not f['dead']]
check('bearish FVG mirrors correctly [95, 99]',
      len(live2) == 1 and not live2[0]['bull']
      and abs(live2[0]['top'] - 99) < 1e-9 and abs(live2[0]['bot'] - 95) < 1e-9, live2)

# the size filter
sim3 = Sim(fvg_min_atr=5.0)
warmup(sim3)
sim3.step(100, 101, 99, 100)
sim3.step(100, 110, 100, 109)
sim3.step(109, 112, 105, 111)
check('sub-threshold gaps are filtered out by the ATR filter',
      len([f for f in sim3.fvgs if not f['dead']]) == 0)

# =============================================================================
print('\n[2] Structure: BOS vs CHoCH on a scripted reversal')
# =============================================================================
sim = Sim(swing=3, choch_valid=100)

# A monotonic staircase has NO pivots at all - every high is below the last, so
# ta.pivothigh never fires. Real structure needs a zig-zag: lower highs AND
# lower lows, each leg long enough for a pivot to confirm.
def walk(turns, per_leg=7):
    """Interpolate between turning points, one candle per step.

    The bar that ends a leg gets a deeper wick on the side it is turning from,
    so the extreme is unique. Without that the last bar of a down-leg and the
    first bar of the next up-leg share an identical low, and a tie is not a
    pivot - ta.pivothigh/pivotlow both require a strict extreme.
    """
    out, prev = [], turns[0]
    for target in turns[1:]:
        down = target < prev
        for k in range(1, per_leg + 1):
            px = prev + (target - prev) * k / per_leg
            o = prev + (target - prev) * (k - 1) / per_leg
            turn = k == per_leg
            hi = max(o, px) + (1.5 if turn and not down else 0.4)
            lo = min(o, px) - (1.5 if turn and down else 0.4)
            out.append((o, hi, lo, px))
        prev = target
    return out

# down-legs make lower lows, up-legs make lower highs, then a decisive reversal
bars = walk([2000, 1980, 1992, 1968, 1980, 1956, 1968, 2020], per_leg=7)

evs = []
for b in bars:
    r = sim.step(*b)
    for flag, name in (('choch_bear', 'CHoCH_bear'), ('choch_bull', 'CHoCH_bull'),
                       ('bos_bear', 'BOS_bear'), ('bos_bull', 'BOS_bull')):
        if r[flag]:
            evs.append((name, r['i']))

kinds = [e[0] for e in evs]
print(f'        (structure events: {kinds})')
check('the zig-zag actually produces structure breaks', len(kinds) > 0, kinds)
check('downtrend produces bearish breaks',
      any(k.endswith('bear') for k in kinds), kinds)
check('the FIRST bearish break from no trend is a CHoCH',
      next((k for k in kinds if k.endswith('bear')), None) == 'CHoCH_bear', kinds)
check('continuation breaks downward are BOS, not repeated CHoCH',
      kinds.count('BOS_bear') > 0, kinds)
check('the reversal produces a bullish CHoCH', 'CHoCH_bull' in kinds, kinds)
check('the first bullish break after a downtrend is CHoCH, never BOS',
      next((k for k in kinds if k.endswith('bull')), None) == 'CHoCH_bull', kinds)
check('trend ends bullish', sim.trend == 1, sim.trend)
# =============================================================================
print('\n[3] CHoCH confirmation window (strict vs grace)')
# =============================================================================
# Strict: a break whose bias has not caught up on that exact bar is discarded.
strict, lax = Sim(swing=3, grace=0), Sim(swing=3, grace=3)
random.seed(7)
p = 2000.0
path = []
for k in range(400):
    p += random.gauss(0, 3) + math.sin(k / 25.0) * 1.4
    o = p + random.gauss(0, 0.6)
    c = p + random.gauss(0, 0.6)
    hi = max(o, c) + abs(random.gauss(0, 1.2))
    lo = min(o, c) - abs(random.gauss(0, 1.2))
    path.append((o, hi, lo, c))

for b in path:
    strict.step(*b)
    lax.step(*b)
s_sig = [e for e in strict.events if e[0] in ('BUY', 'SELL')]
l_sig = [e for e in lax.events if e[0] in ('BUY', 'SELL')]
check('grace window never produces FEWER signals than strict',
      len(l_sig) >= len(s_sig), f'strict={len(s_sig)} grace={len(l_sig)}')
print(f'        (strict={len(s_sig)} signals, grace=3 -> {len(l_sig)} signals)')

# =============================================================================
print('\n[4] Entry invariants over 20 random walks (8000 bars)')
# =============================================================================
viol = {'legs': 0, 'cooldown': 0, 'per_choch': 0, 'both': 0}
total_signals = 0
for seed in range(20):
    random.seed(seed)
    sim = Sim()
    p, last_sig, sig_choch = 2000.0, None, set()
    for k in range(400):
        p += random.gauss(0, 2.5) + math.sin(k / 18.0) * 2.0
        o = p + random.gauss(0, 0.5)
        c = p + random.gauss(0, 0.5)
        hi = max(o, c) + abs(random.gauss(0, 1.0))
        lo = min(o, c) - abs(random.gauss(0, 1.0))
        r = sim.step(o, hi, lo, c)

        if r['buy'] and r['sell']:
            viol['both'] += 1
        if r['buy'] or r['sell']:
            total_signals += 1
            if r['buy'] and not (r['bias'] == 1 and r['choch_active'] == 1 and r['in_bull_fvg']):
                viol['legs'] += 1
            if r['sell'] and not (r['bias'] == -1 and r['choch_active'] == -1 and r['in_bear_fvg']):
                viol['legs'] += 1
            if last_sig is not None and r['i'] - last_sig < 8:
                viol['cooldown'] += 1
            if sim.choch_bar in sig_choch:
                viol['per_choch'] += 1
            sig_choch.add(sim.choch_bar)
            last_sig = r['i']

print(f'        ({total_signals} signals generated across 8000 bars)')
check('every signal really had all three legs true', viol['legs'] == 0, viol)
check('cooldown between signals always respected', viol['cooldown'] == 0, viol)
check('never more than one signal per confirmed CHoCH', viol['per_choch'] == 0, viol)
check('BUY and SELL never fire on the same bar', viol['both'] == 0, viol)
check('signals are actually produced (rule is not dead)', total_signals > 0, total_signals)

# =============================================================================
print('\n[5] Liquidity sweep must never overlap a structure break')
# =============================================================================
random.seed(3)
sim = Sim()
p = 2000.0
break_bars, sweep_bars = set(), set()
for k in range(1200):
    p += random.gauss(0, 2.5)
    o = p + random.gauss(0, 0.5)
    c = p + random.gauss(0, 0.5)
    hi = max(o, c) + abs(random.gauss(0, 1.5))
    lo = min(o, c) - abs(random.gauss(0, 1.5))
    r = sim.step(o, hi, lo, c)
    if r['bos_bull'] or r['choch_bull'] or r['bos_bear'] or r['choch_bear']:
        break_bars.add(r['i'])
for kind, idx in sim.events:
    if kind.startswith('sweep'):
        sweep_bars.add(idx)
check('a swept level is never also a broken level',
      len(break_bars & sweep_bars) == 0, sorted(break_bars & sweep_bars)[:5])
print(f'        ({len(break_bars)} breaks, {len(sweep_bars)} sweeps, 0 overlap)')

# =============================================================================
print('\n[6] Degenerate inputs must not crash or misbehave')
# =============================================================================
try:
    sim = Sim()
    for _ in range(200):
        sim.step(100, 100, 100, 100)   # zero-range bars, ATR collapses to 0
    check('flat market: no signals, no crash', not any(
        e[0] in ('BUY', 'SELL') for e in sim.events))
except Exception as exc:                # noqa: BLE001
    check('flat market: no signals, no crash', False, repr(exc))

try:
    sim = Sim()
    for k in range(200):
        v = 100 + k * 50
        sim.step(v, v + 40, v - 40, v + 30)   # violent one-way gap-up market
    check('extreme trending market: no crash', True)
except Exception as exc:                # noqa: BLE001
    check('extreme trending market: no crash', False, repr(exc))

print('\n' + '=' * 60)
if FAILS:
    print(f'{len(FAILS)} FAILING CHECK(S): {FAILS}')
    sys.exit(1)
print('All logic checks passed.')
