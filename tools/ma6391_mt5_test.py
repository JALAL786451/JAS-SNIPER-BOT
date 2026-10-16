#!/usr/bin/env python3
"""Koshish #18 MA 63/91 (m3 qaida) - MT5 M1 data par TALAASH (2021-24 ka jo hissa mile).
m3: EMA63 x EMA91 cross band candle par = entry (close); SL 1.5 x ATR14 (RMA), TP 2 x SL; ek waqt ek trade,
khuli trade par ulta cross = kuch nahi; kharcha $0.26/oz. SL aur TP ek hi candle mein = SL (sakht).
Usage: python3 tools/ma6391_mt5_test.py <M1 csv> <minutes: 60 / 1>
"""
import sys, math
from datetime import datetime

FAST, SLOW, FEE = 63, 91, 0.26
mins = int(sys.argv[2])
bars = []
for ln in open(sys.argv[1], encoding='utf-8', errors='ignore'):
    p = ln.strip().split('\t')
    if len(p) < 6 or not p[0][:1].isdigit():
        continue
    t = datetime.strptime(p[0] + ' ' + p[1], '%Y.%m.%d %H:%M:%S')
    if t.year < 2021 or t.year > 2024:
        continue
    o, h, l, c = map(float, p[2:6])
    k = t.replace(minute=(t.minute // mins) * mins if mins < 60 else 0, second=0)
    if mins >= 60:
        k = k.replace(hour=(t.hour // (mins // 60)) * (mins // 60))
    if bars and bars[-1][0] == k:
        b = bars[-1]; b[2] = max(b[2], h); b[3] = min(b[3], l); b[4] = c
    else:
        bars.append([k, o, h, l, c])
n = len(bars)
def ema(v, n_):
    out, a, e = [], 2 / (n_ + 1), None
    for x in v:
        e = x if e is None else e + a * (x - e); out.append(e)
    return out
C = [b[4] for b in bars]
f, s = ema(C, FAST), ema(C, SLOW)
atr, a = [], None
for i, b in enumerate(bars):
    tr = b[2] - b[3] if i == 0 else max(b[2] - b[3], abs(b[2] - C[i-1]), abs(b[3] - C[i-1]))
    a = tr if a is None else (a * 13 + tr) / 14; atr.append(a)
R, yr, pos = [], {}, None
for i in range(SLOW + 1, n):
    t, o, h, l, c = bars[i]
    if pos:
        d, e, sl, tp, rk = pos
        hitS = l <= sl if d == 1 else h >= sl
        hitT = h >= tp if d == 1 else l <= tp
        px = None
        if hitS: px = (min(o, sl) if d == 1 else max(o, sl))
        elif hitT: px = tp
        if px is not None:
            r = ((px - e) * d - FEE) / rk
            R.append(r); yr.setdefault(t.year, []).append(r); pos = None
    if pos is None:
        up = f[i-1] <= s[i-1] and f[i] > s[i]
        dn = f[i-1] >= s[i-1] and f[i] < s[i]
        if up or dn:
            d = 1 if up else -1; rk = 1.5 * atr[i]
            pos = (d, c, c - d * rk, c + d * 2 * rk, rk)
m = len(R); ex = sum(R) / m
se = math.sqrt(sum((x - ex) ** 2 for x in R) / (m - 1)) / math.sqrt(m)
w = [x for x in R if x > 0]; ls = [x for x in R if x <= 0]
pf = sum(w) / -sum(ls) if ls else float('inf')
print(f'{mins}m: {bars[0][0].date()} - {bars[-1][0].date()}, {m} trades, jeet {100*len(w)/m:.1f}%, PF {pf:.2f}, '
      f'Exp {ex:+.3f}R (±{se:.3f}), Exp-2SE {ex-2*se:+.3f}, kul {sum(R):+.1f}R')
print('  saal:', ' '.join(f'{y}:{sum(v):+.1f}R({len(v)})' for y, v in sorted(yr.items())))
ok = m >= 100 and ex - 2 * se > 0 and sum(1 for v in yr.values() if sum(v) > 0) * 2 > len(yr)
print('  QAIDA:', 'PASS' if ok else 'FAIL')
