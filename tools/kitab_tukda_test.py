#!/usr/bin/env python3
"""Koshish #20 "Kitab Tukda" - TALAASH test on MT5 H4 export (qaida 16 Oct, badalna mana).

Same rules as strategies/jas_kitab_tukda_test.pine (t1):
 rukh = 1D EMA63/93 (pichhla band din) AUR 4H EMA63/93 ek taraf; 4H band par entry;
 SL 1.5 x ATR(14) RMA; TP nahi, rukh hate to band; din (PKT) max 2; hafte ki aakhri
 4H par band, Jumma 12:00 ke baad nayi nahi; kharcha $0.26/oz. Trades 2021-2024.
Usage: python3 tools/kitab_tukda_test.py data/XAUUSDc_H4_2020_2024.csv
"""
import sys, math
from datetime import datetime, timedelta

FAST, SLOW, ATRK, MAXDAY, FEE, USC = 63, 93, 1.5, 2, 0.26, 20.0
START = datetime(2021, 1, 1)

def ema(vals, n):
    out, k, e = [], 2.0 / (n + 1), None
    for v in vals:
        e = v if e is None else e + k * (v - e)
        out.append(e)
    return out

bars = []
for ln in open(sys.argv[1], encoding='utf-8'):
    p = ln.strip().split('\t')
    if not p[0][:1].isdigit():
        continue
    t = datetime.strptime(p[0] + ' ' + p[1], '%Y.%m.%d %H:%M:%S')
    bars.append((t, float(p[2]), float(p[3]), float(p[4]), float(p[5])))
n = len(bars)
T = [b[0] for b in bars]; O = [b[1] for b in bars]; H = [b[2] for b in bars]
L = [b[3] for b in bars]; C = [b[4] for b in bars]

# daily closes (server din) -> EMA; har 4H bar pichhle band din ki EMA dekhe
days, dclose = [], {}
for t, c in zip(T, C):
    d = t.date()
    if d not in dclose:
        days.append(d)
    dclose[d] = c
dF = dict(zip(days, ema([dclose[d] for d in days], FAST)))
dS = dict(zip(days, ema([dclose[d] for d in days], SLOW)))
prevDay = {days[i]: days[i - 1] for i in range(1, len(days))}

f4, s4 = ema(C, FAST), ema(C, SLOW)
atr, a = [], None
for i in range(n):
    tr = H[i] - L[i] if i == 0 else max(H[i] - L[i], abs(H[i] - C[i - 1]), abs(L[i] - C[i - 1]))
    a = tr if a is None else (a * 13 + tr) / 14
    atr.append(a)

def rukh(i):
    pd = prevDay.get(T[i].date())
    if pd is None:
        return 0
    if dF[pd] > dS[pd] and f4[i] > s4[i]:
        return 1
    if dF[pd] < dS[pd] and f4[i] < s4[i]:
        return -1
    return 0

trades = []  # (entry_time, dir, entry, exit, risk, why)
pos = None
dayKey, nDay = None, 0
for i in range(1, n):
    wkEnd = i == n - 1 or (T[i + 1] - T[i]) > timedelta(days=1)
    friNo = T[i].weekday() == 4 and T[i].hour >= 12
    k = (T[i] + timedelta(hours=5)).date()
    if k != dayKey:
        dayKey, nDay = k, 0
    if pos:
        d, e, st, rk, t0 = pos
        hit = (L[i] <= st) if d == 1 else (H[i] >= st)
        if hit:
            px = min(O[i], st) if d == 1 else max(O[i], st)
            trades.append((t0, d, e, px, rk, 'SL')); pos = None
        elif rukh(i) != d or wkEnd or i == n - 1:
            trades.append((t0, d, e, C[i], rk, 'rukh' if rukh(i) != d else 'hafta')); pos = None
    r = rukh(i)
    if pos is None and T[i] >= START and r != 0 and not wkEnd and not friNo and nDay < MAXDAY:
        rk = ATRK * atr[i]
        pos = (r, C[i], C[i] - r * rk, rk, T[i]); nDay += 1

def stats(tr, label):
    R = [((x - e) * d - FEE) / rk for (_, d, e, x, rk, _) in tr]
    m = len(R)
    if m < 2:
        print(f'{label}: {m} trades'); return
    ex = sum(R) / m
    sd = math.sqrt(sum((x - ex) ** 2 for x in R) / (m - 1)); se = sd / math.sqrt(m)
    usc = [((x - e) * d - FEE) * USC for (_, d, e, x, rk, _) in tr]
    eq = pk = dd = 0.0
    for u in usc:
        eq += u; pk = max(pk, eq); dd = max(dd, pk - eq)
    win = sum(1 for x in R if x > 0) / m * 100
    print(f'{label}: {m} trades, jeet {win:.1f}%, Exp {ex:+.3f}R (±{se:.3f}), Exp-2SE {ex-2*se:+.3f}, '
          f'0.20 lot kul {eq:+,.0f} USC, max DD {dd:,.0f} USC')
    return ex, se, m

ex, se, m = stats(trades, 'KUL')
stats([t for t in trades if t[1] == 1], 'BUY')
stats([t for t in trades if t[1] == -1], 'SELL')
yrs = {}
for t in trades:
    yrs.setdefault(t[0].year, []).append(((t[3] - t[2]) * t[1] - FEE) / t[4])
pos_y = 0
for y in sorted(yrs):
    s = sum(yrs[y]); pos_y += s > 0
    print(f'  {y}: {len(yrs[y])} tr, {s:+.1f}R')
why = {}
for t in trades:
    why[t[5]] = why.get(t[5], 0) + 1
print('Band hone ki wajah:', why)
ok = m >= 100 and ex - 2 * se > 0 and pos_y * 2 > len(yrs)
print('QAIDA:', 'PASS -> IMTIHAN' if ok else 'FAIL', f'(trades>=100: {m>=100}, Exp-2SE>0: {ex-2*se>0}, musbat saal {pos_y}/{len(yrs)})')
